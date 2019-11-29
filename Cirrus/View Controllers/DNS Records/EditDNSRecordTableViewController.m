#import "EditDNSRecordTableViewController.h"
#import "EditValueTableViewController.h"

@interface EditDNSRecordTableViewController () {
    NSDictionary<NSString *, NSArray<NSString *> *> * recordTypeMap;
    NSDictionary * inputMap;
    NSIndexPath * selectedIndexPath;
    void (^finishedCallback)(BOOL);
}

@property (strong, nonatomic) CFDNSRecord * dns;

// Used to provide a visual indicator on the tableview for properties that have been modified
@property (strong, nonatomic) NSMutableArray<NSString *> * mutatedProperties;

@property (strong, nonatomic) NSMutableArray<NSString *> * inputsForRecord;

@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation EditDNSRecordTableViewController

- (void) viewDidLoad {
    /* Record Type Map:
     This map controls which inputs are visible based off of the type of DNS record

     Parent objects in the map are the record types, child object must be an array of input names
     in the order of which they will be shown.
    */
    recordTypeMap = [NSDictionary dictionaryWithContentsOfFile:
                     [[NSBundle mainBundle] pathForResource:@"recordTypeMap" ofType:@"plist"]];

    /* Input Map:
     The input map is used to set the properties of the dynamically generated inputs.
     The required options are:
        label       - string - The label shown beside the input
        dataSource  - string - Specify the property to source the data from
        dataType    - string - The type of data. string, int, text, bool, so on
     The optional options are:
        maxlength   - int    - The maximum length of the input
        keyboard    - string - The keyboard type from UIKeyboardType
        validate    - string - The validate method to run against the input
        autoCorrect - int    - Disabled by default, 1 to enable
        fromData    - bool   - If the value is located in the data dictionary of the DNS object
    */
    inputMap = [NSDictionary dictionaryWithContentsOfFile:
               [[NSBundle mainBundle] pathForResource:@"inputMap" ofType:@"plist"]];

    [super viewDidLoad];
    self.mutatedProperties = [NSMutableArray new];

    self.saveAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self showProgressControl];

        // Force TTL to automatic if proxied is enable
        if (self.dns.proxied && self.dns.ttl != 1) {
            self.dns.ttl = 1;
        }

        [authManager authenticateUserForChange:NO success:^{
            if (self.dns.identifier) {
                [api updateDNSObject:self.dns forZone:currentZone finished:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self finishedUpdatingRecord:success error:error];
                    });
                }];
            } else {
                [api createDNSObject:self.dns forZone:currentZone finished:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self finishedUpdatingRecord:success error:error];
                    });
                }];
            }
        } cancelled:nil];
    }];
    self.cancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self restoreViewFromSave];
    }];

    if (!self.dns.identifier) {
        self.title = [lang key:@"New {type} Record" args:@[self.dns.type]];
        [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    } else {
        self.title = [lang key:@"Edit {type} Record" args:@[self.dns.type]];
    }

    self.inputsForRecord = [self recordsForType];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray<NSString *> *) recordsForType {
    NSArray<NSString *> * inputNames = [recordTypeMap arrayForKey:self.dns.type];
    NSMutableArray<NSString *> * filteredInputs = [NSMutableArray arrayWithCapacity:inputNames.count];
    NSDictionary<NSString *, id> * input;
    for (NSString * inputName in inputNames) {
        input = [inputMap dictionaryForKey:inputName];
        if ([input boolForKey:@"hideOnCreate"] && !self.dns.identifier) {
            continue;
        }

        if ([inputName isEqualToString:@"proxy"] && !self.dns.proxiable) {
            continue;
        }

        [filteredInputs addObject:inputName];
    }

    return filteredInputs;
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inputsForRecord count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return l(@"Record Properties");
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    NSString * inputID = [self.inputsForRecord objectAtIndex:indexPath.row];
    NSDictionary * inputOptions = inputMap[inputID];

    cell.textLabel.text = inputOptions[@"label"] ? l(inputOptions[@"label"]) : inputID;
    cell.detailTextLabel.text = [self formatCellDataWithInput:inputOptions andInputID:inputID];

    if ([self enableCellDataWithInput:inputOptions andInputID:inputID]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }

    NSString * key = [inputOptions objectForKey:@"dataSource"] ?
        [inputOptions objectForKey:@"dataSource"] : inputID;
    if ([self.mutatedProperties containsObject:key]) {
        cell.textLabel.textColor = [UIColor orangeColor];
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    EditValueTableViewController * editValue = [self.storyboard instantiateViewControllerWithIdentifier:@"EditValue"];
    NSString * inputID = [self.inputsForRecord objectAtIndex:selectedIndexPath.row];
    NSDictionary * inputOptions = inputMap[inputID];
    NSString * dataSource = inputOptions[@"dataSource"];
    id value;
    if (inputOptions[@"fromData"]) {
        value = self.dns.data[dataSource];
    } else {
        value = [self.dns valueForKey:dataSource];
    }
    [editValue setOptions:inputOptions forCurrentValue:value finished:^(BOOL cancelled, id newValue) {
        if (!cancelled) {
            [self didUpdateValueForInput:inputOptions newValue:newValue];
        }
    }];
    UINavigationController * controller = [[UINavigationController alloc] initWithRootViewController:editValue];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) didUpdateValueForInput:(NSDictionary *)inputOptions newValue:(id)value {
    NSString * dataSource = [inputOptions objectForKey:@"dataSource"];
    if (!dataSource) {
        d(@"Unable to save new value for input because it's missing a data source!");
        return;
    }

    if (inputOptions[@"fromData"]) {
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:self.dns.data];
        if ([inputOptions[@"dataType"] isEqualToString:@"int"]) {
            NSNumber * numVal = @([value intValue]);
            [data setValue:numVal forKey:dataSource];
        } else {
            [data setValue:value forKey:dataSource];
        }
        self.dns.data = data;
    } else {
        [self.dns setValue:value forKey:dataSource];
    }

    [self.mutatedProperties addObject:dataSource];
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    [self.tableView reloadData];
}

- (NSString *) formatCellDataWithInput:(NSDictionary *)inputOptions andInputID:(NSString *)inputID {
    NSString * dataSource = inputOptions[@"dataSource"];
    NSString * dataType = inputOptions[@"dataType"];
    id currentValue;
    if (inputOptions[@"fromData"]) {
        currentValue = self.dns.data[dataSource];
    } else {
        currentValue = [self.dns valueForKey:dataSource];
    }

    if (!self.dns.identifier && ![self.mutatedProperties containsObject:dataSource]) {
        return l(@"Tap to set");
    } else if (!currentValue) {
        return l(@"Tap to set");
    }

    if (nstrcmp(dataType, @"string") || nstrcmp(dataType, @"text")) {
        return currentValue;
    } else if (nstrcmp(dataType, @"int")) {

        if (nstrcmp(dataSource, @"ttl") && self.dns.ttl == 1) {
            return l(@"Automatic");
        }

        return [NSString stringWithFormat:@"%d", [(NSNumber *)currentValue intValue]];
    } else if (nstrcmp(dataType, @"bool")) {
        return [(NSNumber *)currentValue boolValue] ? l(@"Enabled") : l(@"Disabled");
    } else if (nstrcmp(dataType, @"choice")) {
        NSArray<NSString *> * labels = inputOptions[@"choices"][@"labels"];
        NSArray<NSNumber *> * values = inputOptions[@"choices"][@"values"];
        NSUInteger index = [values indexOfObject:currentValue];
        return [labels objectAtIndex:index];
    } else {
        return l(@"Tap to set");
    }
}

- (BOOL) enableCellDataWithInput:(NSDictionary *)inputOptions andInputID:(NSString *)inputID {
    NSString * dataSource = inputOptions[@"dataSource"];
    if (nstrcmp(dataSource, @"ttl") && self.dns.proxied) {
        return NO;
    }

    return YES;
}

- (void) finishedUpdatingRecord:(BOOL)success error:(NSError *)error {
    [self hideProgressControl];
    if (error) {
        if (nstrcmp(error.domain, OCAPI_ERROR_DOMAIN)) {
            NSString * body;
            NSString * errorKey = [NSString stringWithFormat:@"CFAPI::DNSError::%li", (long)error.code];
            if ([lang keyExists:errorKey]) {
                body = [lang key:errorKey];
            } else {
                body = error.localizedDescription;
            }

            [uihelper
             presentAlertInViewController:self
             title:l(@"Error saving DNS record")
             body:body
             dismissButtonTitle:[lang key:@"Dismiss"]
             dismissed:^(NSInteger buttonIndex) {
                 // Let the user try again
             }];
            return;
        }

        [uihelper presentErrorInViewController:self error:error dismissed:^(NSInteger buttonIndex) {
            [self restoreViewFromSave];
            self->finishedCallback(YES);
        }];
    } else {
        if (success) {
            [self restoreViewFromSave];
            self->finishedCallback(NO);
        } else {
            [uihelper
             presentAlertInViewController:self
             title:l(@"Unable to save DNS record")
             body:l(@"An unexpected error occured while saving the DNS record. Your changes may not have been saved.")
             dismissButtonTitle:l(@"Dismiss")
             dismissed:^(NSInteger buttonIndex) {
                 [self restoreViewFromSave];
                 self->finishedCallback(YES);
             }];
        }
    }
}

- (void) setDnsRecord:(CFDNSRecord *)dns finished:(void (^)(BOOL cancelled))finished {
    _dns = dns;
    finishedCallback = finished;
}

@end
