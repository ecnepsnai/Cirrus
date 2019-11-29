#import "OCTipManager.h"

@implementation OCTipManager

static NSMutableDictionary<NSString *, CMPopTipView *> * tipMap;
static id _instance;

- (id) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

+ (OCTipManager *) sharedInstance {
    if (!_instance) {
        _instance = [OCTipManager new];
    }
    
    return _instance;
}

- (void) showTipWithIdentifier:(NSString *)identifier configuration:(void (^)(CMPopTipView * tip))config {
    if (!tipMap) {
        tipMap = [NSMutableDictionary new];
    }
    NSDictionary<NSString *, NSNumber *> * tips = UserOptions.presentedTips;
    if (!tips) {
        tips = @{};
    }
    
    if ([tips boolForKey:identifier]) {
        UserOptions.presentedTips = tips;
        return;
    }
    
    CMPopTipView * tip = [self showTip:config];
    [tipMap setValue:tip forKey:identifier];
    
    NSMutableDictionary * updatedTips = [NSMutableDictionary dictionaryWithDictionary:tips];
    [updatedTips setObject:@1 forKey:identifier];
    UserOptions.presentedTips = updatedTips;
}

- (void) hideTipWithIdentifier:(NSString * _Nonnull)identifier {
    if (!tipMap) {
        return;
    }

    CMPopTipView * tip = [tipMap objectForKey:identifier];
    if (tip) {
        [tip dismissAnimated:YES];
        [tipMap removeObjectForKey:identifier];
    }
}

- (CMPopTipView *) showTip:(void (^)(CMPopTipView * tip))config {
    CMPopTipView * tip = [[CMPopTipView alloc] initWithMessage:@""];
    tip.backgroundColor = [UIColor whiteColor];
    tip.alpha = 0.75;
    tip.textColor = [UIColor blackColor];
    tip.borderColor = [UIColor clearColor];
    tip.hasShadow = NO;
    tip.layer.shadowOffset = CGSizeMake(0, 0);
    tip.layer.shadowRadius = 2.0f;
    tip.layer.shadowColor = [[UIColor blackColor] CGColor];
    tip.layer.shadowOpacity = 0.3f;
    tip.has3DStyle = NO;
    tip.hasGradientBackground = NO;
    tip.cornerRadius = 2.0f;
    tip.bubblePaddingY = 5.0f;
    tip.bubblePaddingX = 5.0f;
    config(tip);
    if (tip.message.length > 0) {
        if (!tipMap) {
            tipMap = [NSMutableDictionary new];
        }
        [tipMap setValue:tip forKey:tip.message];
    }
    return tip;
}

@end
