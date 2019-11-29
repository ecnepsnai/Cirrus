#import "AppState.h"
#import "WelcomeViewController.h"

@interface AppState ()

@property (strong, nonatomic) NSMutableArray<OCSelector *> * selectors;
@property (strong, nonatomic, nullable) UIViewController * parent;
@property (nonatomic, copy, nullable) void (^finishedBlock)(NSError *);

@end

@implementation AppState

static id _instance;

+ (AppState *) currentState {
    if (!_instance) {
        _instance = [AppState new];
    }
    
    return _instance;
}

- (id) init {
    if (!_instance) {
        AppState * state = [super init];
        state.isLoggedIn = NO;
        state.selectors = [NSMutableArray new];
        state.disableTabBarPopToRoot = NO;
        [uihelper setAppearance];
        [OCUserOptions setDefaultValues];
        _instance = [super init];
    }
    
    return _instance;
}

- (void) firstRun:(UIViewController *)controller finished:(void (^)(NSError *))finished {
    [[CFCredentialManager sharedInstance] loadCredentialsFromStorage];
    if (self.isLoggedIn) {
        finished(nil);
        return;
    }
    self.finishedBlock = finished;
    self.parent = controller;

    dispatch_async(dispatch_get_main_queue(), ^{
        WelcomeViewController * welcome = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
        welcome.modalPresentationStyle = UIModalPresentationFullScreen;
        [welcome presentOnViewController:self.parent finished:^(void) {
            self.finishedBlock(nil);
        }];
    });
}

- (void) performSelectorWhenLoggedIn:(OCSelector *)selector {
    if (!self.isLoggedIn) {
        [self.selectors addObject:selector];
    } else {
        [selector performActionOnSender];
    }
}

- (BOOL) isLoggedIn {
    return CFCredentialManager.sharedInstance.credentialsExistInStorage;
}

@end
