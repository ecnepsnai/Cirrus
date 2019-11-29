#import "OCObject.h"

@interface CFRequest : OCObject

typedef NS_ENUM(NSUInteger, HTTP) {
    HTTPGET,
    HTTPPOST,
    HTTPPUT,
    HTTPPATCH,
    HTTPDELETE,
};

@property (strong, nonatomic, readonly, nonnull) NSURL * url;
@property (strong, nonatomic, readonly, nullable) NSData * body;
@property (nonatomic, readonly) HTTP method;
@property (strong, nonatomic, readonly, nonnull) NSDictionary<NSString *, NSString *> * headers;

- (CFRequest * _Nonnull) initWithMethod:(HTTP)method credentials:(CFCredentials * _Nullable)credentials url:(NSURL * _Nonnull)url;
+ (CFRequest * _Nonnull) GETRequest:(CFCredentials * _Nonnull)credentials URL:(NSString * _Nonnull)format, ...;
+ (CFRequest * _Nonnull) POSTRequest:(CFCredentials * _Nonnull)credentials URL:(NSString * _Nonnull)format, ...;
+ (CFRequest * _Nonnull) PUTRequest:(CFCredentials * _Nonnull)credentials URL:(NSString * _Nonnull)format, ...;
+ (CFRequest * _Nonnull) PATCHRequest:(CFCredentials * _Nonnull)credentials URL:(NSString * _Nonnull)format, ...;
+ (CFRequest * _Nonnull) DELETERequest:(CFCredentials * _Nonnull)credentials URL:(NSString * _Nonnull)format, ...;

- (void) setJSONDictionaryBody:(NSDictionary<NSString *, id> * _Nonnull)dictionary;
- (void) setJSONArrayBody:(NSArray<id> * _Nonnull)array;
- (void) setFormDataBody:(NSDictionary<NSString *, NSString *> * _Nonnull)body;
- (void) setStringBody:(NSString * _Nonnull)body;
- (void) addQueryParameters:(NSDictionary<NSString *, NSString *> * _Nonnull)params;

- (void) request:(void (^_Nonnull)(NSURLResponse * _Nonnull response, NSDictionary<NSString *, id> * _Nullable data, NSError * _Nullable error))finished;

@end
