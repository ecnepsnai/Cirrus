#import <UIKit/UIKit.h>

@interface EditValueTableViewController : UITableViewController

/**
 Update the current DNS record field

 @param options  Input options
 @param value    Current value
 @param finished Called when the view has been dismissed with the new value
 */
- (void) setOptions:(NSDictionary *)options forCurrentValue:(id)value finished:(void (^)(BOOL cancelled, id newValue))finished;

@end
