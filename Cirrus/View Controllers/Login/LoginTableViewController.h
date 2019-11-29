#import <UIKit/UIKit.h>

@interface LoginTableViewController : UITableViewController

@property (nonatomic) BOOL addAdditionalAccount;
@property (nonatomic, copy) void(^ _Nonnull finishedBlock)(NSError * _Nullable, CFCredentials * _Nullable);

- (void) performLogin:(UIViewController * _Nonnull)sender finished:(void (^ _Nonnull)(NSError * _Nullable, CFCredentials * _Nullable))finished;

@end
