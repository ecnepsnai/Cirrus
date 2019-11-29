#import <Foundation/Foundation.h>

@interface CFAnalyticView : NSObject

+ (id _Nonnull) viewWithTotal:(id _Nonnull)total timeSeries:(NSArray * _Nonnull)timeSeries;
- (CFAnalyticObject * _Nonnull) getObject;
- (BOOL) showStatView;
- (NSString * _Nullable) statViewTitleForIndex:(NSUInteger)index;
- (NSString * _Nullable) statViewAmountForIndex:(NSUInteger)index;
- (void) buildGraphInView:(UIView * _Nonnull)view;

@end
