#import <UIKit/UIKit.h>

@interface UIViewController (ObjectSave)

- (void) updateViewForSave:(OCSelector *)saveAction confirmSave:(BOOL)confirmSave
              cancelAction:(OCSelector *)cancelAction confirmCancel:(BOOL)confirmCancel;
- (void) restoreViewFromSave;

@end
