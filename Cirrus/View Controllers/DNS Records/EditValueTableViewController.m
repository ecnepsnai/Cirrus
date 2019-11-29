#import "EditValueTableViewController.h"
#import "NSString+Validator.h"

@interface EditValueTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource> {
    void (^finishedCallback)(BOOL, id);
}

@property (strong, nonatomic) NSDictionary<NSString *, NSString *> * options;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSString * source;
@property (nonatomic) NSUInteger inputType;
@property (strong, nonatomic) NSString * cellType;
@property (nonatomic) BOOL labelIsInCell;
@property (strong, nonatomic) NSArray<NSString *> * pickerTitles;
@property (strong, nonatomic) NSArray * pickerRealValues;
@property (nonatomic) NSUInteger pickerInitialIndex;
@property (strong, nonnull) UITextField * multiLineTextField;

@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation EditValueTableViewController

static NSInteger LabelTag = 10;
static NSInteger SingeRowHeight = 44;
static NSInteger DoubleRowHeight = 232;

typedef NS_ENUM(NSInteger, InputTag) {
    InputTagSingleline = 20,
    InputTagMultiline = 25,
    InputTagPicker = 30,
    InputTagToggle = 35
};

- (void) viewDidLoad {
    self.navigationItem.title = l(@"Edit Record");
    self.saveAction = [OCSelector selectorWithTarget:self action:@selector(saveAndClose:)];
    self.cancelAction = [OCSelector selectorWithTarget:self action:@selector(discardAndClose:)];
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:NO];
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setOptions:(NSDictionary *)options forCurrentValue:(id)value finished:(void (^)(BOOL, id))finished {
    _options = options;
    _value = value;
    finishedCallback = finished;

    NSString * dataType = _options[@"dataType"];
    if (nstrcmp(dataType, @"string")) {
        _cellType = @"OneLine";
        _inputType = InputTagSingleline;
        _labelIsInCell = YES;
    } else if (nstrcmp(dataType, @"text")) {
        _cellType = @"Multiline";
        _inputType = InputTagMultiline;
        _labelIsInCell = NO;
    } else if (nstrcmp(dataType, @"bool")) {
        _cellType = @"Toggle";
        _inputType = InputTagToggle;
        _labelIsInCell = YES;
    } else if (nstrcmp(dataType, @"int")) {
        _cellType = @"OneLine";
        _inputType = InputTagSingleline;
        _labelIsInCell = YES;
    } else if (nstrcmp(dataType, @"choice")) {
        _cellType = @"Picker";
        _inputType = InputTagPicker;
        NSDictionary<NSString *, NSArray<NSString *> *> * choices = options[@"choices"];
        _pickerTitles = [choices objectForKey:@"labels"];
        _pickerRealValues = [choices objectForKey:@"values"];
        if (value) {
            _pickerInitialIndex = [_pickerRealValues indexOfObject:value];
        } else {
            _pickerInitialIndex = 0;
        }
    }
}

- (void) saveAndClose:(id)sender {
    [self restoreViewFromSave];
    if ([self.cellType isEqualToString:@"Multiline"]) {
        self.value = self.multiLineTextField.text;
    }

    if (self.value) {
        [self dismissViewControllerAnimated:YES completion:^{
            self->finishedCallback(NO, self.value);
        }];
    }
}

- (void) discardAndClose:(id)sender {
    [self restoreViewFromSave];
    [self dismissViewControllerAnimated:YES completion:^{
        self->finishedCallback(YES, self.value);
    }];
}

#pragma mark - Table view data source

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.labelIsInCell) {
        return l(self.options[@"label"]);
    }
    return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (nstrcmp(self.cellType, @"OneLine")) {
        return SingeRowHeight;
    } else if (nstrcmp(self.cellType, @"Multiline")) {
        return DoubleRowHeight;
    } else if (nstrcmp(self.cellType, @"Toggle")) {
        return SingeRowHeight;
    } else if (nstrcmp(self.cellType, @"Picker")) {
        return DoubleRowHeight;
    }

    return SingeRowHeight;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:self.cellType forIndexPath:indexPath];

    if (self.labelIsInCell) {
        UILabel * label = [cell viewWithTag:LabelTag];
        label.text = l(self.options[@"label"]);
    }

    if (nstrcmp(self.cellType, @"OneLine")) {
        UITextField * input = [cell viewWithTag:self.inputType];
        input.enabled = zoneReadWrite;
        [self setKeyboard:input toType:self.options[@"keyboard"]];
        if (nstrcmp(self.options[@"dataType"], @"int")) {
            input.text = [(NSNumber *)self.value stringValue];
        } else {
            input.text = (NSString *)self.value;
        }
        input.placeholder = @"";
    } else if (nstrcmp(self.cellType, @"Multiline")) {
        UITextView * input = [cell viewWithTag:self.inputType];
        input.userInteractionEnabled = zoneReadWrite;
        [self setKeyboard:(UITextField *)input toType:self.options[@"keyboard"]];
        input.text = (NSString *)self.value;
    } else if (nstrcmp(self.cellType, @"Toggle")) {
        UISwitch * input = [cell viewWithTag:self.inputType];
        input.enabled = zoneReadWrite;
        input.on = [(NSNumber *)self.value boolValue];
        [input addTarget:self action:@selector(toggleChange:) forControlEvents:UIControlEventTouchUpInside];
    } else if (nstrcmp(self.cellType, @"Picker")) {
        UIPickerView * pickerView = [cell viewWithTag:self.inputType];
        pickerView.userInteractionEnabled = zoneReadWrite;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [pickerView selectRow:self.pickerInitialIndex inComponent:0 animated:YES];
        [self updateValue:self.pickerRealValues[self.pickerInitialIndex]];
        [pickerView setShowsSelectionIndicator:YES];
    }

    return cell;
}

- (void) setKeyboard:(UITextField *)keyboard toType:(NSString *)type {
    if ([type isEqualToString:@"UIKeyboardTypeDefault"]) {
        keyboard.keyboardType = UIKeyboardTypeDefault;
    } else if ([type isEqualToString:@"UIKeyboardTypeASCIICapable"]) {
        keyboard.keyboardType = UIKeyboardTypeASCIICapable;
    } else if ([type isEqualToString:@"UIKeyboardTypeNumbersAndPunctuation"]) {
        keyboard.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    } else if ([type isEqualToString:@"UIKeyboardTypeURL"]) {
        keyboard.keyboardType = UIKeyboardTypeURL;
    } else if ([type isEqualToString:@"UIKeyboardTypeNumberPad"]) {
        keyboard.keyboardType = UIKeyboardTypeNumberPad;
    } else if ([type isEqualToString:@"UIKeyboardTypePhonePad"]) {
        keyboard.keyboardType = UIKeyboardTypePhonePad;
    } else if ([type isEqualToString:@"UIKeyboardTypeNamePhonePad"]) {
        keyboard.keyboardType = UIKeyboardTypeNamePhonePad;
    } else if ([type isEqualToString:@"UIKeyboardTypeEmailAddress"]) {
        keyboard.keyboardType = UIKeyboardTypeEmailAddress;
    } else if ([type isEqualToString:@"UIKeyboardTypeDecimalPad"]) {
        keyboard.keyboardType = UIKeyboardTypeDecimalPad;
    } else if ([type isEqualToString:@"UIKeyboardTypeTwitter"]) {
        keyboard.keyboardType = UIKeyboardTypeTwitter;
    } else if ([type isEqualToString:@"UIKeyboardTypeWebSearch"]) {
        keyboard.keyboardType = UIKeyboardTypeWebSearch;
    }
    [keyboard becomeFirstResponder];
    if ([keyboard isKindOfClass:[UITextField class]]) {
        [keyboard addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventEditingChanged];
    } else {
        self.multiLineTextField = (UITextField *)keyboard;
    }
}

- (void) updateTextField:(UITextField *)field {
    NSError * validationError = nil;
    if ([self.options[@"validate"] isEqualToString:@"ipv4address"]) {
        validationError = [field.text validateIPv4Address];
    }
    if ([self.options[@"validate"] isEqualToString:@"ipv6address"]) {
        validationError = [field.text validateIPv6Address];
    }
    if ([self.options[@"validate"] isEqualToString:@"ttl"]) {
        validationError = [field.text validateTTL];
    }

    if (validationError == nil) {
        [self updateValue:field.text];
    } else {
        //validationLabel.text = validationError.localizedDescription;
    }
}

- (void) toggleChange:(UISwitch *)toggle {
    [self updateValue:[NSNumber numberWithBool:toggle.on]];
}

- (void) updateValue:(id)value {
    self.value = value;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerTitles.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return l(self.pickerTitles[row]);
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateValue:self.pickerRealValues[row]];
}

@end
