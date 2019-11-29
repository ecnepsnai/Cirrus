#import "OCStringFormatter.h"

@implementation OCStringFormatter

static id _instance;

- (id) init {
    if (_instance == nil) {
        OCStringFormatter * formatter = [super init];
        _instance = formatter;

    }
    return _instance;
}

+ (OCStringFormatter *) sharedInstance {
    if (!_instance) {
        _instance = [OCStringFormatter new];
    }
    return _instance;
}

static const char * decimalByteUnits[] = {
    "B",
    "kB",
    "MB",
    "GB",
    "TB",
    "PB",
    "EB",
    "ZB",
    "YB"
};

static const char * binaryByteUnits[] = {
    "B",
    "KiB",
    "MiB",
    "GiB",
    "TiB",
    "PiB",
    "EiB",
    "ZiB",
    "YiB"
};

static const unsigned int maximumMultipleSize = 8;
static const unsigned int decimalBase = 1000;
static const unsigned int binaryBase = 1024;

- (NSString *) formatDecimalBytes:(uint64_t)bytes {
    return [self formatBytes:bytes base:decimalBase units:decimalByteUnits roundAmount:1];
}

- (NSString *) formatRoundedDecimalBytes:(uint64_t)bytes {
    return [self formatBytes:bytes base:decimalBase units:decimalByteUnits roundAmount:0];
}

- (NSString *) formatBinaryBytes:(uint64_t)bytes {
    return [self formatBytes:bytes base:binaryBase units:binaryByteUnits roundAmount:1];
}

- (NSString *) formatRoundedBinaryBytes:(uint64_t)bytes {
    return [self formatBytes:bytes base:binaryBase units:binaryByteUnits roundAmount:0];
}

- (NSString *) formatBytes:(uint64_t)bytes base:(unsigned int)base units:(const char *[])units roundAmount:(int)roundAmount {
    if (bytes == 0) {
        NSString * unit = [[NSString alloc] initWithUTF8String:units[0]];
        return format(@"0 %@", unit);
    }

    int mult = 0;
    while (bytes > pow(base, mult)) {
        if (mult == maximumMultipleSize) {
            return @"";
        }
        mult ++;
    }
    mult --;

    double relativeValue = bytes;
    nTimes(mult) {
        relativeValue = relativeValue / base;
    }

    NSString * unit = [[NSString alloc] initWithUTF8String:units[mult]];
    double roundedValue = round(2.0f * relativeValue) / 2.0f;

    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMaximumFractionDigits:roundAmount];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];

    return format(@"%@ %@", [formatter stringFromNumber:[NSNumber numberWithFloat:roundedValue]], unit);
}

- (NSString *) formatSecondsToFriendlyTime:(uint64_t)seconds {
    if (seconds == 1) {
        return l(@"1 second");
    } else if (seconds < 60) {
        return [lang key:@"{num}sec" args:@[format(@"%llu", seconds)]];
    } else if (seconds == 60) {
        return l(@"1 minute");
    } else if (seconds < 3600) {
        double relativeValue = (float)seconds / 60.0f;
        double roundedValue = round(2.0f * relativeValue) / 2.0f;
        NSString * numberString;
        if (ceilf(roundedValue) == roundedValue) {
            numberString = format(@"%u", (unsigned int)roundedValue);
        } else {
            numberString = format(@"%f", roundedValue);
        }
        return [lang key:@"{num}mins" args:@[numberString]];
    } else if (seconds == 3600) {
        return l(@"1 hour");
    }

    return [lang key:@"{num}sec" args:@[format(@"%llu", seconds)]];
}

@end
