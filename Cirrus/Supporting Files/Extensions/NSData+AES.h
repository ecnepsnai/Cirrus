#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *) AES256EncryptWithKey:(NSString*)key;
- (NSData *) AES256DecryptWithKey:(NSString*)key;

@end
