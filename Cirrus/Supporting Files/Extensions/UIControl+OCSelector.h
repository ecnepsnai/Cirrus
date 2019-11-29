#import <UIKit/UIKit.h>
#import "OCSelector.h"

@interface UIControl (OCSelector)

- (void) addSelector:(OCSelector *)selector forControlEvent:(UIControlEvents)event;

@end
