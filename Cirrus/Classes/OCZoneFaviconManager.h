#import <Foundation/Foundation.h>

@interface OCZoneFaviconManager : NSObject

+ (OCZoneFaviconManager *) sharedInstance;
- (id) init;
- (void) faviconForZones:(CFZone *)zone finished:(void (^)(UIImage * image, NSError * error))finished;

@end
