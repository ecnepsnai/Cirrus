#import "CFRequest.h"

@interface CFRequest ()

@property (strong, nonatomic, readwrite, nonnull) NSURL * url;
@property (strong, nonatomic, readwrite, nullable) NSData * body;
@property (nonatomic, readwrite) HTTP method;
@property (strong, nonatomic, readwrite, nonnull) NSDictionary<NSString *, NSString *> * headers;
@property (strong, nonatomic, readwrite, nonnull) NSString * contentType;
@property (strong, nonatomic, readwrite, nullable) CFCredentials * credentials;

@end

@implementation CFRequest

static const NSString * CFAPI_URL = @"https://api.cloudflare.com/client/v4";

#define CONTENT_TYPE_JSON @"application/json"
#define CONTENT_TYPE_FORM @"application/x-www-form-urlencoded; charset=utf-8"

#define fmturl va_list args; va_start(args, format); NSString * path = [[NSString alloc] initWithFormat:format arguments:args]; va_end(args);

- (CFRequest *) initWithMethod:(HTTP)method credentials:(CFCredentials *)credentials url:(NSURL *)url {
    self = [super init];
    self.url = url;
    self.method = method;
    return self;
}

+ (CFRequest *) GETRequest:(CFCredentials *)credentials URL:(NSString *)format, ... {
    fmturl;

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", CFAPI_URL, path]];
    return [[CFRequest alloc] initWithMethod:HTTPGET credentials:credentials url:url];
}

+ (CFRequest *) POSTRequest:(CFCredentials *)credentials URL:(NSString *)format, ... {
    fmturl;

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", CFAPI_URL, path]];
    return [[CFRequest alloc] initWithMethod:HTTPPOST credentials:credentials url:url];
}

+ (CFRequest *) PUTRequest:(CFCredentials *)credentials URL:(NSString *)format, ... {
    fmturl;

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", CFAPI_URL, path]];
    return [[CFRequest alloc] initWithMethod:HTTPPUT credentials:credentials url:url];
}

+ (CFRequest *) PATCHRequest:(CFCredentials *)credentials URL:(NSString *)format, ... {
    fmturl;

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", CFAPI_URL, path]];
    return [[CFRequest alloc] initWithMethod:HTTPPATCH credentials:credentials url:url];
}

+ (CFRequest *) DELETERequest:(CFCredentials *)credentials URL:(NSString *)format, ... {
    fmturl;

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", CFAPI_URL, path]];
    return [[CFRequest alloc] initWithMethod:HTTPDELETE credentials:credentials url:url];
}

- (void) setJSONDictionaryBody:(NSDictionary<NSString *,id> *)dictionary {
    self.body = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    self.contentType = CONTENT_TYPE_JSON;
}

- (void) setJSONArrayBody:(NSArray<id> *)array {
    self.body = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    self.contentType = CONTENT_TYPE_JSON;
}

- (void) setFormDataBody:(NSDictionary<NSString *,NSString *> *)body {
    NSMutableString * bodyString = [NSMutableString new];
    NSArray<NSString *> * allKeys = body.allKeys;
    NSString * key;
    for (int i = 0; i < allKeys.count; i++) {
        key = allKeys[i];
        [bodyString appendString:format(@"%@=%@", key, body[key])];
        if (i != allKeys.count - 1) {
            [bodyString appendString:@"&"];
        }
    }
    self.contentType = CONTENT_TYPE_FORM;
}

- (void) setStringBody:(NSString *)body {
    self.body = [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) addQueryParameters:(NSDictionary<NSString *,NSString *> *)params {
    NSMutableArray<NSString *> * pairs = [NSMutableArray arrayWithCapacity:params.count];
    for (int i = 0; i < params.allKeys.count; ++i){
        NSString * key = [params.allKeys objectAtIndex:i];
        NSString * value = [params valueForKey:key];
        NSString * keyValuePair = [NSString stringWithFormat:@"%@=%@", key, value];
        [pairs addObject:keyValuePair];
    }
    NSString * url = [NSString stringWithFormat:@"%@?%@", self.url.absoluteString, [pairs componentsJoinedByString:@"&"]];
    self.url = [NSURL URLWithString:url];
}

- (void) request:(void (^)(NSURLResponse *response, NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))finished {
    NSAssert([self.credentials valid], @"Credentials should be valid before performing request");

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:self.url];

    // Assume GET unless otherwise configured
    switch (self.method) {
        case HTTPGET:
            [request setHTTPMethod:@"GET"];
            break;
        case HTTPPOST:
            [request setHTTPMethod:@"POST"];
            break;
        case HTTPPUT:
            [request setHTTPMethod:@"PUT"];
            break;
        case HTTPPATCH:
            [request setHTTPMethod:@"PATCH"];
            break;
        case HTTPDELETE:
            [request setHTTPMethod:@"DELETE"];
            break;
    }

    [request setValue:CONTENT_TYPE_JSON forHTTPHeaderField:@"Accept"];

    if (self.contentType != nil) {
        [request setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
    }
    if (self.body != nil) {
        request.HTTPBody = self.body;
    }

    [request setValue:self.credentials.email forHTTPHeaderField:@"X-Auth-Email"];
    [request setValue:self.credentials.key forHTTPHeaderField:@"X-Auth-Key"];

    // Enable GZIP
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

#if API_DEBUG
    NSMutableString * requestString = [NSMutableString new];
    [requestString appendFormat:@"%@ %@", [request.HTTPMethod uppercaseString], request.URL.path];
    if (request.URL.query) {
        [requestString appendFormat:@"?%@", request.URL.query];
    }
    [requestString appendString:@" HTTP/1.1\n"];
    NSDictionary<NSString *, NSString *> * headers = request.allHTTPHeaderFields;
    for (NSString * key in [headers allKeys]) {
        [requestString appendFormat:@"%@: %@\n", key, [headers valueForKey:key]];
    }
    if (request.HTTPBody) {
        [requestString appendString:@"\n"];
        [requestString appendString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    }
    d(@"%@", requestString);
#endif

    NSURLSessionDataTask * task = [NSURLSession.sharedSession
                                   dataTaskWithRequest:request
                                   completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                       id jsonData;
                                       NSError * returnError = error;
                                       if (data) {
                                           NSError * jsonError;
                                           jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions
                                                                                        error:&jsonError];
                                           if (!jsonData && jsonError) {
                                               returnError = jsonError;
                                           } else {
                                               NSError * APIError = [self checkForAPIError:jsonData];
                                               if (APIError) {
                                                   returnError = APIError;
                                                   if (APIError.code == 9103) {
                                                       notify(NOTIF_DISMISS_ZONE);
                                                   }
                                               }
                                           }
                                       }
                                       finished(response, jsonData, returnError);
                                   }];
    [task resume];
}

/**
 * Checks the response object for an error reponse from the Cloudflare API
 *
 * @param response The reponse dictionary
 *
 * @return nil if no error, NSError if there was an error
 */
- (NSError *) checkForAPIError:(NSDictionary *)response{
    if ([[response objectForKey:@"success"] boolValue]) {
        return nil;
    } else {
        NSDictionary * error = [[response arrayForKey:@"errors"] dictionaryAtIndex:0];
        NSArray * error_chain = [error arrayForKey:@"error_chain"];
        NSMutableDictionary<NSString *, id> * userInfo = [NSMutableDictionary new];
        NSArray<NSDictionary *> * messages = [response arrayForKey:@"messages"];
        if (messages) {
            [userInfo setValue:messages forKey:@"messages"];
        }
        if (error_chain) {
            NSDictionary * sub_error = [error_chain dictionaryAtIndex:0];
            [userInfo setValue:[sub_error objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:OCAPI_ERROR_DOMAIN
                                       code:[[sub_error objectForKey:@"code"] longValue]
                                   userInfo:userInfo];
        }
        [userInfo setValue:[error objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:OCAPI_ERROR_DOMAIN
                                   code:[[error objectForKey:@"code"] longValue]
                               userInfo:userInfo];
    }
}

@end
