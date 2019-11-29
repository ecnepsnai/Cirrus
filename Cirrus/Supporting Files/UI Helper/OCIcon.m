#import "OCIcon.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
@import MaterialDesignColors;

@interface OCIcon ()

@property (strong, nonatomic) NSString * iconCode;
@property (strong, nonatomic) UIColor * iconColor;

@end

@implementation OCIcon

+ (OCIcon *) iconForCode:(OCIconCode)code {
    OCIcon * icon = [OCIcon new];

    switch (code) {
        case OCIconCodeActive:
            icon.iconCode = [NSString fontAwesomeIconStringForEnum:FAArrowCircleUp];
            break;
        case OCIconCodePaused:
            icon.iconCode = [NSString fontAwesomeIconStringForEnum:FApauseCircle];
            break;
        case OCIconCodeDevMode:
            icon.iconCode = [NSString fontAwesomeIconStringForEnum:FAPlusCircle];
            break;
        case OCIconCodeMoved:
            icon.iconCode = [NSString fontAwesomeIconStringForEnum:FAQuestionCircle];
            break;
        case OCIconCodeReadOnly:
            icon.iconCode = [NSString fontAwesomeIconStringForEnum:FALock];
            break;
    }
    icon.iconColor = [icon colorForIconCode:code];

    return icon;
}

- (void) configureLabel:(UILabel *)label {
    label.font = [UIFont fontAwesomeFontOfSize:15.0f];
    label.textColor = self.iconColor;
    label.text = self.iconCode;
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
