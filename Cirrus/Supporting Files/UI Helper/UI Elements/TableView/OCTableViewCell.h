@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface OCTableViewCell : NSObject

+ (OCTableViewCell * _Nonnull) cellWithCell:(UITableViewCell * _Nonnull)cell;
+ (OCTableViewCell * _Nonnull) cellWithCell:(UITableViewCell * _Nonnull)cell segueIdentifier:(NSString * _Nonnull)identifier;

@property (strong, nonatomic, nonnull) UITableViewCell * cell;
@property (strong, nonatomic, nullable) NSString * segueIdentifier;

@end

NS_ASSUME_NONNULL_END
