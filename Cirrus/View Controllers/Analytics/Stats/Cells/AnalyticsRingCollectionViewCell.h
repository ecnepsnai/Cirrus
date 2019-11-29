#import <UIKit/UIKit.h>
@import UICircularProgressRing;

@interface AnalyticsRingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICircularProgressRing *ring;

@end
