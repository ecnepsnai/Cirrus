@import UIKit;
#import "OCTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCTableViewSection : NSObject

@property (strong, nonatomic, nullable) NSString * title;
@property (strong, nonatomic, nullable) NSString * footer;
@property (strong, nonatomic, nonnull) NSMutableArray<OCTableViewCell *> * cells;

- (OCTableViewSection *) init;
- (OCTableViewSection *) initWithCells:(NSArray<OCTableViewCell *> *)cells;

@end

NS_ASSUME_NONNULL_END
