#import <UIKit/UIKit.h>

@protocol OCSearchDelegate <NSObject>

- (BOOL) objectMatchesQuery:(NSString * _Nonnull) query;

@end

@interface OCSearch : NSObject
@end
