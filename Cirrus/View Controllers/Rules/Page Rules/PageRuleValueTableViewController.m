#import "PageRuleValueTableViewController.h"

@interface PageRuleValueTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource> {
    void (^finishedCallback)(BOOL, id);
}

@property (strong, nonatomic) CFPageRuleAction * action;
@property (strong, nonatomic) NSArray<id> * pickerValues;
@property (strong, nonatomic) NSMutableArray<NSString *> * pickerTitles;
@property (nonatomic) NSInteger pickerInitialIndex;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation PageRuleValueTableViewController

static NSInteger LabelTag = 10;
typedef NS_ENUM(NSInteger, InputTag) {
    InputTagPicker = 30,
    InputTagToggle = 35
};

- (void) viewDidLoad {
    self.navigationItem.title = l(format(@"pagerule::%@", self.action.identifier));
    self.saveAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:^{
            self->finishedCallback(NO, self.value);
        }];
    }];
    self.cancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self restoreViewFromSave];
        [self dismissViewControllerAnimated:YES completion:^{
            self->finishedCallback(YES, self.value);
        }];
    }];
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:NO];
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setAction:(CFPageRuleAction *)action finished:(void (^)(BOOL cancelled, id newValue))finished {
    _action = action;
    finishedCallback = finished;

    if ([[action.mapping objectForKey:@"type"] isEqualToString:@"select"]) {
        self.pickerValues = [action.mapping objectForKey:@"choices"];
        self.pickerTitles = [NSMutableArray new];
        int i = 0;
        for (id value in self.pickerValues) {
            if ([value isKindOfClass:[NSString class]]) {
                [self.pickerTitles addObject:format(@"pagerulesetting::%@::%@", action.identifier, value)];
                if ([action.value isEqualToString:value]) {
                    _pickerInitialIndex = i;
                }
            } else if ([value isKindOfClass:[NSNumber class]]) {
                [self.pickerTitles addObject:format(@"pagerulesetting::%@::%@", action.identifier, [value stringValue])];
                if ([action.value isEqualToNumber:value]) {
                    _pickerInitialIndex = i;
                }
            }

            i ++;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (nstrcmp(self.action.mapping[@"type"], @"bool")) {
        return 44;
    } else if (nstrcmp(self.action.mapping[@"type"], @"select")) {
        return 232;
    }

    return 44;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * type = [self.action.mapping objectForKey:@"type"];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:type forIndexPath:indexPath];
    if ([type isEqualToString:@"bool"]) {
        UISwitch * toggle = [cell viewWithTag:InputTagToggle];
        toggle.on = [(NSNumber *)self.action.value boolValue];
        [toggle addTarget:self action:@selector(toggleChange:) forControlEvents:UIControlEventTouchUpInside];
        UILabel * label = [cell viewWithTag:LabelTag];
        label.text = l(nstrcat(@"pagerule::", self.action.identifier));
    } else if ([type isEqualToString:@"select"]) {
        UIPickerView * pickerView = [cell viewWithTag:InputTagPicker];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [pickerView selectRow:self.pickerInitialIndex inComponent:0 animated:YES];
        [self updateValue:self.pickerValues[self.pickerInitialIndex]];
        [pickerView setShowsSelectionIndicator:YES];
    }

    return cell;
}

# pragma mark - Picker view data source

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerTitles.count;
}

- (nullable NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return l([self.pickerTitles objectAtIndex:row]);
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateValue:[self.pickerValues objectAtIndex:row]];
}

# pragma mark - Input events

- (void) updateValue:(id)newValue {
    self.value = newValue;
}

- (void) toggleChange:(UISwitch *)sender {
    [self updateValue:[NSNumber numberWithBool:[sender isOn]]];
}

@end
