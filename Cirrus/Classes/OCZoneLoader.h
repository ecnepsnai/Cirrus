#import <Foundation/Foundation.h>

@interface OCZoneLoader : NSObject

+ (OCZoneLoader *) sharedInstance;
- (void) loadAllZones:(void (^)(NSArray<CFZone *> * zones, NSError * error))finished;

@end
