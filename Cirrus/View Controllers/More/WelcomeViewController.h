#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

- (void) presentOnViewController:(UIViewController *)parent finished:(void(^)(void))finished;

@end
