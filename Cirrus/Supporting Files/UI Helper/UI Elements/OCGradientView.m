#import "OCGradientView.h"

@interface OCGradientView ()

@property (strong, nonatomic) CALayer * gradientLayer;

@end

@implementation OCGradientView

- (void) drawRect:(CGRect)rect {
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)self.firstColor.CGColor, (id)self.secondColor.CGColor];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 0);
    if (self.gradientLayer != nil) {
        [self.layer replaceSublayer:self.gradientLayer with:gradient];
    } else {
        [self.layer insertSublayer:gradient atIndex:0];
    }
    self.gradientLayer = gradient;
    [super drawRect:rect];
}

@end
