#import <Foundation/Foundation.h>

@interface CFCredentials : NSObject

@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * key;

- (BOOL) valid;

@end
