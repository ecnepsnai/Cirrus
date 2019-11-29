#import "MoreTableViewController.h"

@interface MoreTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation MoreTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    if (isRegular) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) closeView:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
