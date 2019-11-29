#import <Foundation/Foundation.h>

@interface OCStringFormatter : NSObject

+ (OCStringFormatter *) sharedInstance;
- (id) init;

- (NSString *) formatDecimalBytes:(uint64_t)bytes;
- (NSString *) formatRoundedDecimalBytes:(uint64_t)bytes;
- (NSString *) formatBinaryBytes:(uint64_t)bytes;
- (NSString *) formatRoundedBinaryBytes:(uint64_t)bytes;
- (NSString *) formatSecondsToFriendlyTime:(uint64_t)seconds;

@end
