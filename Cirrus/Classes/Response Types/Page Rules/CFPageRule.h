#import <Foundation/Foundation.h>
#import "CFPageRuleAction.h"

@interface CFPageRule : NSObject <OCSearchDelegate>

@property (strong, nonatomic) NSString * identifier;
@property (strong, nonatomic) NSString * target;
@property (strong, nonatomic) NSArray<CFPageRuleAction *> * actions;
@property (nonatomic) BOOL enabled;
@property (nonatomic) NSInteger priority;

+ (CFPageRule *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;
+ (CFPageRule *) ruleWithDefaults;

@end
