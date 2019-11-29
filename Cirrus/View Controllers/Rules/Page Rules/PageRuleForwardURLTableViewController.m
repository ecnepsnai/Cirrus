#import "PageRuleForwardURLTableViewController.h"
#import "NSString+Validator.h"

@interface PageRuleForwardURLTableViewController () {
    void (^finishedCallback)(BOOL, id);
}

@property (strong, nonatomic) CFPageRuleAction * action;
@property (strong, nonatomic) NSMutableDictionary<NSString *, id> * value;

@property (weak, nonatomic) IBOutlet UISegmentedControl *statusCodeSegment;
@property (weak, nonatomic) IBOutlet UITextField *destinationInput;

@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation PageRuleForwardURLTableViewController

static NSString * url_key = @"url";
static NSString * status_key = @"status_code";

- (void) viewDidLoad {
    [super viewDidLoad];

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
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];

    if (self.value) {
        NSNumber * statusNumber = [self.value objectForKey:status_key];
        if ([statusNumber isEqualToNumber:@302]) {
            [self.statusCodeSegment setSelectedSegmentIndex:1];
        } else {
            [self.statusCodeSegment setSelectedSegmentIndex:0];
        }
        self.destinationInput.text = [self.value objectForKey:url_key];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setAction:(CFPageRuleAction *)action finished:(void (^)(BOOL cancelled, id newValue))finished {
    _action = action;
    finishedCallback = finished;
    if (action.value) {
        _value = [NSMutableDictionary dictionaryWithDictionary:action.value];
    } else {
        _value = [NSMutableDictionary new];
        [_value setObject:@301 forKey:status_key];
    }
}

- (IBAction) statusSegementChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self.value setObject:@301 forKey:status_key];
    } else {
        [self.value setObject:@302 forKey:status_key];
    }
}

- (IBAction) destinationChange:(UITextField *)sender {
    NSError * error = [sender.text validateWebURL];
    self.navigationItem.leftBarButtonItem.enabled = error == nil;
    if (!error) {
        [self.value setObject:sender.text forKey:url_key];
    }
}
@end
