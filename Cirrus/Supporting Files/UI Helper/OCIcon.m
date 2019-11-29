#import "OCIcon.h"
#import "FontAwesome.h"
@import MaterialDesignColors;

@interface OCIcon ()

@property (nonatomic) FAIcon iconCode;
@property (strong, nonatomic) UIColor * iconColor;

@end

@implementation OCIcon

+ (OCIcon *) iconForCode:(OCIconCode)code {
    OCIcon * icon = [OCIcon new];

    switch (code) {
        case OCIconCodeActive:
            icon.iconCode = FAArrowCircleUpLight;
            break;
        case OCIconCodePaused:
            icon.iconCode = FAPauseCircleLight;
            break;
        case OCIconCodeDevMode:
            icon.iconCode = FAPlusCircleLight;
            break;
        case OCIconCodeMoved:
            icon.iconCode = FAQuestionCircleLight;
            break;
        case OCIconCodeReadOnly:
            icon.iconCode = FALockLight;
            break;
    }
    icon.iconColor = [icon colorForIconCode:code];

    return icon;
}

- (void) configureLabel:(UILabel *)label {
    label.font = [UIFont fontAwesomeFontForIcon:self.iconCode size:15.0f];
    label.textColor = self.iconColor;
    label.text = [NSString fontAwesomeIcon:self.iconCode];
}

- (UIColor *) colorForIconCode:(OCIconCode)code {
    switch (code) {
        case OCIconCodeActive:
            return [UIColor materialGreen];
        case OCIconCodePaused:
            return [UIColor grayColor];
        case OCIconCodeDevMode:
            return [UIColor materialAmber];
        case OCIconCodeMoved:
            return [UIColor materialRed];
        case OCIconCodeReadOnly:
            return [UIColor materialGrey];
    }
}

@end
