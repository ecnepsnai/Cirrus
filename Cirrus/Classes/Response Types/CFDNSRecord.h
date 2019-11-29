#import <Foundation/Foundation.h>
#import "CFZone.h"

@interface CFDNSRecord : NSObject

@property (strong, nonatomic) NSString * identifier;
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * content;
@property BOOL proxiable;
@property BOOL proxied;
@property int ttl;
@property int priority;
@property (strong, nonatomic) NSString * zone_id;
@property (strong, nonatomic) NSString * zone_name;
@property (strong, nonatomic) NSString * created_on;
@property (strong, nonatomic) NSString * modified_on;
@property (strong, nonatomic) NSDictionary * data;
@property (strong, nonatomic) NSDictionary * meta;

- (NSDictionary<NSString *, id> *) dictionaryValue;
- (NSMutableDictionary<NSString *, id> *) baseDictionary;
+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (instancetype) recordWithType:(NSString *)type;

@end
