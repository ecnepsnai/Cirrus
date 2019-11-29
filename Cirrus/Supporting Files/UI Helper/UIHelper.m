
@interface UIHelper () <UITableViewDelegate, UITableViewDataSource> {
    void (^alertDismissedCallback)(NSInteger buttonIndex);
    void (^confirmDismissedCallback)(BOOL confirmed);
    void (^actionSheetDismissedCallback)(NSInteger buttonIndex);
    NSArray<NSString *> * actionSheetChoices;
    UITableViewController * tableChoiceController;
    UINavigationController * tableChoiceNavigationController;
}

@end

@implementation UIHelper

static id _instance;

- (id) init {
    if (_instance == nil) {
        UIHelper * helper = [super init];
        _instance = helper;
    }
    return _instance;
}

+ (UIHelper *) sharedInstance {
    if (!_instance) {
        _instance = [UIHelper new];
    }
    return _instance;
}

- (UIColor *) cirrusColor {
    return [UIColor colorNamed:@"CirrusBlue"];
}

- (void) setAppearance {
    [[UITabBar appearance] setTintColor:self.cirrusColor];
    [[UINavigationBar appearance] setTintColor:self.cirrusColor];
    [[UISegmentedControl appearance] setTintColor:self.cirrusColor];
    [[UIButton appearance] setTintColor:self.cirrusColor];
    [[UISwitch appearance] setOnTintColor:self.cirrusColor];
    [[UIBarButtonItem appearance] setTintColor:self.cirrusColor];
}

- (void) presentAlertController:(UIAlertController *)alertController
    inViewController:(UIViewController *)viewController {
    if (![viewController.presentedViewController isKindOfClass:[UINavigationController class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if([viewController respondsToSelector:@selector(presentViewController:animated:completion:)]){
                [viewController presentViewController:alertController animated:YES completion:nil];
            }
        });
    }
}

- (void) presentAlertInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    dismissButtonTitle:(NSString *)dismissButtonTitle
    dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    [self presentAlertInViewController:viewController
        title:title body:body buttons:@[dismissButtonTitle] dismissed:dismissed];
}

- (void) presentAlertInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    buttons:(NSArray<NSString *> *)buttons
    dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
        message:body
        preferredStyle:UIAlertControllerStyleAlert];
    NSAssert(buttons.count <= 3, @"Should not present an alert with more than 3 buttons!");

    for (NSUInteger i = 0, count = buttons.count; i < count; i ++) {
        [alertController addAction:[UIAlertAction actionWithTitle:buttons[i]
            style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            if (dismissed) {
                dismissed(i);
            }
        }]];
    }
    [self presentAlertController:alertController inViewController:viewController];
}

- (void) presentInputAlertInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    confirmButtonTitle:(NSString *)confirmButtonTitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    textFieldConfiguration:(void (^)(UITextField * textField))textFieldConfiguration
    dismissed:(void (^)(NSString * inputValue, BOOL confirmed))dismissed {


    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:body
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:textFieldConfiguration];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        dismissed(nil, NO);
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:confirmButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField * inputField = alertController.textFields.firstObject;
        dismissed(inputField.text, YES);
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [viewController presentViewController:alertController animated:YES completion:nil];
}

- (void) presentErrorInViewController:(UIViewController *)viewController
    error:(NSError *)error
    dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    NSString * message = error.localizedDescription;
    NSArray<NSDictionary *> * messages = [error.userInfo arrayForKey:@"messages"];
    if (messages && messages.count > 0) {
        NSMutableArray<NSString *> * errors = [NSMutableArray new];
        for (NSDictionary<NSString *, id> * message in messages) {
            NSString * errorMessage = [message stringForKey:@"message"];
            NSString * actualMessage = [errorMessage componentsSeparatedByString:@": "][1];
            [errors addObject:actualMessage];
        }
        message = [errors componentsJoinedByString:@"\n"];
    }
    [self presentAlertInViewController:viewController
        title:[lang key:@"An Error Occurred"]
        body:message
        dismissButtonTitle:[lang key:@"Dismiss"]
        dismissed:dismissed];
}

- (void) presentConfirmInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    confirmButtonTitle:(NSString *)confirmButtonTitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    confirmActionIsDestructive:(BOOL)confirmActionIsDestructive
    dismissed:(void (^)(BOOL confirmed))dismissed {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
        message:body
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * dismissButton = [UIAlertAction actionWithTitle:cancelButtonTitle
        style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        if (dismissed) {
            dismissed(NO);
        }
    }];
    [alertController addAction:dismissButton];
    NSInteger style = confirmActionIsDestructive ? UIAlertActionStyleDestructive : UIAlertViewStyleDefault;
    UIAlertAction * confirmButton = [UIAlertAction actionWithTitle:confirmButtonTitle
        style:style handler:^(UIAlertAction *action){
        if (dismissed) {
            dismissed(YES);
        }
    }];
    [alertController addAction:confirmButton];
    [self presentAlertController:alertController inViewController:viewController];
}

- (void) presentActionSheetInViewController:(UIViewController *)viewController
    attachToTarget:(ActionTipTarget *)target
    title:(NSString *)title
    subtitle:(NSString *)subtitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    items:(NSArray<NSString *> *)items
    dismissed:(void (^)(NSInteger itemIndex))dismissed {

    [self
     presentActionSheetInViewController:viewController
     attachToTarget:target
     title:title
     subtitle:subtitle
     cancelButtonTitle:cancelButtonTitle
     items:items
     destructiveItemIndex:-1
     dismissed:dismissed];
}

- (void) presentActionSheetInViewController:(UIViewController *)viewController
    attachToTarget:(ActionTipTarget *)target
    title:(NSString *)title
    subtitle:(NSString *)subtitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    items:(NSArray<NSString *> *)items
    destructiveItemIndex:(NSInteger)destructiveItemIndex
    dismissed:(void (^)(NSInteger itemIndex))dismissed {

    if (items.count > 5) {
        actionSheetChoices = items;
        actionSheetDismissedCallback = dismissed;
        [self presentTableChoiceViewController:viewController
                                         title:title
                                      subtitle:subtitle
                             cancelButtonTitle:cancelButtonTitle
                                         items:items
                                     dismissed:actionSheetDismissedCallback];
        return;
    }

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
        message:subtitle
        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:cancelButtonTitle
        style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (dismissed) {
                dismissed(-1);
            }
        }];
    [alertController addAction:cancelButton];
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction * button = [UIAlertAction actionWithTitle:obj
            style:(destructiveItemIndex == idx ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault)
            handler:^(UIAlertAction * _Nonnull action) {
                if (dismissed) {
                    dismissed(idx);
                }
            }];
        [alertController addAction:button];
    }];

    if (target.targetView) {
        alertController.popoverPresentationController.sourceView = target.targetView;
    }
    if (target.targetBarButtonItem) {
        alertController.popoverPresentationController.barButtonItem = target.targetBarButtonItem;
    }

    [self presentAlertController:alertController inViewController:viewController];
}

- (void) presentTableChoiceViewController:(UIViewController *)viewController
                                    title:(NSString *)title
                                 subtitle:(NSString *)subtitle
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                                    items:(NSArray<NSString *> *)items
                                dismissed:(void (^)(NSInteger itemIndex))dismissed {
    tableChoiceController = [[UITableViewController alloc] init];
    tableChoiceController.tableView.dataSource = self;
    tableChoiceController.tableView.delegate = self;
    tableChoiceController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                            initWithTitle:cancelButtonTitle
                                                            style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(dismissTableViewController)];
    tableChoiceController.title = title;
    tableChoiceController.navigationItem.prompt = subtitle;
    tableChoiceNavigationController = [[UINavigationController alloc] initWithRootViewController:tableChoiceController];
    [viewController presentViewController:tableChoiceNavigationController animated:YES completion:nil];
}

- (void) applyStylesToButton:(UIButton *)button withColor:(UIColor *)color {
    button.layer.borderWidth = 1;
    button.layer.borderColor = color.CGColor;
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.layer.masksToBounds = YES;
    button.tintColor = color;
}

# pragma mark - Table View Methods

- (void) dismissTableViewController {
    [self dismissTableViewControllerWithIndex:-1];
}

- (void) dismissTableViewControllerWithIndex:(NSInteger)index {
    [tableChoiceNavigationController dismissViewControllerAnimated:YES completion:^{
        self->actionSheetDismissedCallback(index);
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return actionSheetChoices.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"choice"];
    cell.textLabel.text = actionSheetChoices[indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissTableViewControllerWithIndex:indexPath.row];
}

@end
