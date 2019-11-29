#import "UIViewController+ObjectSave.h"

@implementation UIViewController (ObjectSave)

- (void) updateViewForSave:(OCSelector *)saveAction confirmSave:(BOOL)confirmSave
              cancelAction:(OCSelector *)cancelAction confirmCancel:(BOOL)confirmCancel {
    appState.disableTabBarPopToRoot = YES;
    [appState.zoneListViewController disableTableView];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    OCSelector * buttonSaveAction;
    if (confirmSave) {
        buttonSaveAction = [[OCSelector alloc] initWithBlock:^(id sender) {
            [uihelper presentConfirmInViewController:self
                                               title:l(@"Confirm Changes")
                                                body:l(@"Changes may impact users ability to connect to your site.")
                                  confirmButtonTitle:l(@"Save")
                                   cancelButtonTitle:l(@"Do Nothing")
                          confirmActionIsDestructive:NO
                                           dismissed:^(BOOL confirmed) {
                                               if (confirmed) {
                                                   [saveAction performActionOnSender];
                                               }
                                           }];
        }];
    } else {
        buttonSaveAction = saveAction;
    }
    if (zoneReadWrite) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:buttonSaveAction.sender
                                                  action:buttonSaveAction.action];
    }
    
    OCSelector * buttonCancelAction;
    if (confirmCancel) {
        buttonCancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
            [uihelper presentConfirmInViewController:self
                                               title:l(@"Unsaved Changes")
                                                body:l(@"Are you sure you wish to discard your unsaved changes?")
                                  confirmButtonTitle:l(@"Yes")
                                   cancelButtonTitle:l(@"No")
                          confirmActionIsDestructive:NO dismissed:^(BOOL confirmed) {
                              if (confirmed) {
                                  [cancelAction performActionOnSender];
                              }
                          }];
        }];
    } else {
        buttonCancelAction = cancelAction;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:zoneReadWrite ? UIBarButtonSystemItemCancel : UIBarButtonSystemItemDone
                                             target:buttonCancelAction.sender
                                             action:buttonCancelAction.action];
}

- (void) restoreViewFromSave {
    appState.disableTabBarPopToRoot = NO;
    [appState.zoneListViewController enableTableView];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
