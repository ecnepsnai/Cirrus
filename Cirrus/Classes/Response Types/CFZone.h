#import <Foundation/Foundation.h>
#import "CFCredentials.h"

@interface CFZone : NSObject

typedef NS_ENUM(NSUInteger, CFZoneStatus) {
    CFZoneStatusActive,
    CFZoneStatusPaused,
    CFZoneStatusDevMode,
    CFZoneStatusMoved
};

@property (strong, nonatomic) NSString * identifier;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * status;
@property BOOL paused;
@property (strong, nonatomic) NSString * type;
@property int development_mode;
@property (strong, nonatomic) NSArray * name_servers;
@property (strong, nonatomic) NSArray * original_name_servers;
@property (strong, nonatomic) NSString * original_registrar;
@property (strong, nonatomic) NSString * original_dnshost;
@property (strong, nonatomic) NSString * modified_on;
@property (strong, nonatomic) NSString * created_on;
@property (strong, nonatomic) NSDictionary * meta;
@property (strong, nonatomic) NSDictionary * owner;
@property (strong, nonatomic) NSArray * permissions;
@property (strong, nonatomic) NSDictionary * plan;
@property (strong, nonatomic) CFCredentials * credentials;

@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL readOnly;

+ (CFZone *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;
- (CFZoneStatus) displayStatus;

@end
