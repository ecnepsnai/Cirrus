#import "NSDateFormatter+Locale.h"

@implementation NSDateFormatter (Locale)

- (id) initWithLocale {
    static NSLocale * en_US_POSIX = nil;
    self = [self init];
    if (en_US_POSIX == nil) {
        en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    [self setLocale:en_US_POSIX];
    return self;
}

@end
