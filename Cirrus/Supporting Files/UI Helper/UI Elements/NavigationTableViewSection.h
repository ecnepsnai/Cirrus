#import <Foundation/Foundation.h>
#import "NavigationTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigationTableViewSection : NSObject

+ (instancetype) sectionWithTitle:(NSString * _Nonnull)title cells:(NSArray<NavigationTableViewCell *> * _Nonnull)cells;

@property (strong, nonatomic, nonnull, readonly) NSArray<NavigationTableViewCell *> * cells;
@property (strong, nonatomic, nonnull, readonly) NSString * title;

@end

NS_ASSUME_NONNULL_END
