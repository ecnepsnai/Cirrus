#import "WHOISViewController.h"

@interface WHOISViewController ()

@property (weak, nonatomic) IBOutlet UITextView *whoisTextView;

@end

@implementation WHOISViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!UserOptions.whoisNagSuppressed) {
        [uihelper presentAlertInViewController:self title:l(@"Notice") body:l(@"whois_nag") buttons:@[l(@"Don't Show Again")] dismissed:^(NSInteger buttonIndex) {
            UserOptions.whoisNagSuppressed = YES;
            self.whoisTextView.text = self.registrationProperties.whoisDetails;
        }];
    } else {
        self.whoisTextView.text = self.registrationProperties.whoisDetails;
    }
}

@end
