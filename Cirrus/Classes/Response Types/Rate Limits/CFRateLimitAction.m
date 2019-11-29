#import "CFRateLimitAction.h"

@implementation CFRateLimitAction

#define MODE_BAN @"ban"
#define MODE_SIMULATE @"simulate"

+ (CFRateLimitAction *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFRateLimitAction * action = [CFRateLimitAction new];

    NSString * mode = [dictionary stringForKey:@"mode"];
    if (!mode) {
        return nil;
    }
    if (nstrcmp(mode, MODE_BAN)) {
        action.mode = CFRateLimitActionModeBan;
    } else if (nstrcmp(mode, MODE_SIMULATE)) {
        action.mode = CFRateLimitActionModeSimulate;
    } else {
        d(@"Unknown rate limite action mode: %@", mode);
        return nil;
    }

    action.timeout = [dictionary unsignedIntegerForKey:@"timeout"];
    action.response = [dictionary dictionaryForKey:@"response"];

    return action;
}

+ (CFRateLimitAction *) actionWithDefaults {
    CFRateLimitAction * action = [CFRateLimitAction new];
    
    action.mode = CFRateLimitActionModeBan;
    action.timeout = 60;
    
    return action;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    NSString * modeString;
    switch (self.mode) {
        case CFRateLimitActionModeBan:
            modeString = MODE_BAN;
            break;
        case CFRateLimitActionModeSimulate:
            modeString = MODE_SIMULATE;
            break;
    }
    return @{
             @"mode": modeString,
             @"timeout": [NSNumber numberWithUnsignedInteger:self.timeout],
             @"response": self.response ?: [NSNull new]
             };
}

@end
