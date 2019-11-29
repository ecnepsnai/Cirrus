#import <UIKit/UIKit.h>

@interface UnlockViewController : UIViewController

- (void) authenticateWithReason:(NSString *)reason finished:(void (^)(void))finished;

@end
