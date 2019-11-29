@interface OCAPI()

@property (strong, nonatomic) NSURLSession * session;

@end

@implementation OCAPI

static const NSString * CFAPI_URL = @"https://api.cloudflare.com/client/v4";

#define HTTP_GET @"GET"
#define HTTP_HEAD @"HEAD"
#define HTTP_POST @"POST"
#define HTTP_POST @"POST"
#define HTTP_PATCH @"PATCH"
#define HTTP_PUT @"PUT"
#define HTTP_DELETE @"DELETE"
#define HTTP_TRACE @"TRACE"
#define HTTP_OPTIONS @"OPTIONS"
#define JSON_CONTENT_TYPE @"application/json"

static id _instance;

# pragma mark -
# pragma mark Initilization and Configuration

- (id) init {
    if (_instance == nil) {
        OCAPI * _api = [super init];
        _instance = _api;
    }
    return _instance;
}

+ (OCAPI *) sharedInstance {
    if (!_instance) {
        _instance = [OCAPI new];
    }
    return _instance;
}

# pragma mark -
# pragma mark Request Contrustion Methods

/**
 *  Prepare a NSURLRequest object for the given URL and options. configHandler is called so that
 *  you can do any extra configuration to the request (such as add a body)
 *
 *  @param URL           The request URL
 *  @param options       The request options (optional)
 *  @param configHandler Called so you can configure the request (optional)
 *
 *  @return The configured request
 */
- (NSURLRequest *) prepareURLRequestWithURL:(NSURL *)URL withCredentials:(CFCredentials *)creds
                       configurationHandler:(void (^) (NSMutableURLRequest * request))configHandler {
    // Verify that the API key is not empty, if it is then throw and exception
    NSAssert([creds valid], @"Credentials should be valid before performing request");

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];

    // Assume GET unless otherwise configured
    [request setHTTPMethod:HTTP_GET];

    [request setValue:JSON_CONTENT_TYPE forHTTPHeaderField:@"Accept"];
    [request setValue:JSON_CONTENT_TYPE forHTTPHeaderField:@"Content-Type"];
    [request setValue:creds.email forHTTPHeaderField:@"X-Auth-Email"];
    [request setValue:creds.key forHTTPHeaderField:@"X-Auth-Key"];

    // Enable GZIP
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    if (configHandler != nil) {
        configHandler(request);
    }

    return request;
}

/**
 * Converts an NSDictionary to URL Key-Value pairs
 *
 * @param params The parameters
 *
 * @return The URL parameters
 */
- (NSString *) parseDictionaryasURLParameters:(NSDictionary *)params{
    NSString * url = @"?";
    for (int i = 0; i < params.allKeys.count; ++i){
        NSString * key = [params.allKeys objectAtIndex:i];
        NSString * value = [params valueForKey:key];
        NSString * keyValuePair = [NSString stringWithFormat:@"%@=%@&", key, value];
        url = [NSString stringWithFormat:@"%@%@", url, keyValuePair];
    }
    return [url substringToIndex:[url length]-1];
}

- (NSURL *) buildURL:(NSString *)baseURL queryParams:(NSDictionary<NSString *, NSString *> *)params {
    return url(nstrcat(baseURL, [self parseDictionaryasURLParameters:params]));
}

- (void) requestURL:(NSURL *)url credentials:(CFCredentials *)credentials callback:(void (^)(NSURLResponse *response, id results, NSError *error))callback {
    [self requestURL:url method:HTTP_GET httpBody:nil credentials:credentials callback:callback];
}

- (void) requestURL:(NSURL *)url method:(NSString *)method credentials:(CFCredentials *)credentials callback:(void (^)(NSURLResponse *response, id results, NSError *error))callback {
    [self requestURL:url method:method httpBody:nil credentials:credentials callback:callback];
}

- (void) requestURL:(NSURL *)url
             method:(NSString *)method
     jsonDictionary:(NSDictionary *)dictionary
        credentials:(CFCredentials *)credentials
           callback:(void (^)(NSURLResponse *response, id results, NSError *error))callback {
    if (!dictionary) {
        d(@"Attempted to serialize nil dictionary to JSON - aborting request");
        return;
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    [self requestURL:url
              method:method
            httpBody:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
         credentials:credentials
            callback:callback];
}

- (void) requestURL:(NSURL *)url
             method:(NSString *)method
          jsonArray:(NSArray *)dictionary
        credentials:(CFCredentials *)credentials
           callback:(void (^)(NSURLResponse *response, id results, NSError *error))callback {
    NSData * data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    [self requestURL:url
              method:method
            httpBody:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
         credentials:credentials
            callback:callback];
}


- (void) requestURL:(NSURL *)url
             method:(NSString *)method
     formDictionary:(NSDictionary<NSString *, NSString *> *)body
        credentials:(CFCredentials *)credentials
           callback:(void (^)(NSURLResponse *response, id results, NSError *error))callback {
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
    [self requestURL:url
              method:method
            httpBody:bodyString
         contentType:@"application/x-www-form-urlencoded; charset=utf-8"
         credentials:credentials
            callback:callback];
}

- (void) requestURL:(NSURL *)url
             method:(NSString *)method
           httpBody:(NSString * _Nullable)body
        credentials:(CFCredentials *)credentials
           callback:(void (^)(NSURLResponse *response, id results, NSError *error))callback {
    [self requestURL:url
              method:method
            httpBody:body
         contentType:JSON_CONTENT_TYPE
         credentials:credentials
            callback:callback];
}

- (void) requestURL:(NSURL *)url
             method:(NSString *)method
           httpBody:(NSString * _Nullable)body
        contentType:(NSString *)contentType
        credentials:(CFCredentials *)credentials
           callback:(void (^)(NSURLResponse *response, id data, NSError *error))callback {
    NSURLRequest * request = [self prepareURLRequestWithURL:url withCredentials:credentials configurationHandler:^(NSMutableURLRequest *request) {
        [request setHTTPMethod:method];
        if (body != nil) {
            [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }];

    if (!request) {
        return;
    }

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

    self.session = [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:request
                                                      completionHandler:^(NSData * _Nullable data,
                                                                          NSURLResponse * _Nullable response,
                                                                          NSError * _Nullable error) {
        id jsonData;
        if (error != nil) {
            d(@"Network Error: %@", error.description);
        }
        NSError * returnError = error;
        if (data) {
            NSError * jsonError;
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions
                                                            error:&jsonError];
            if (!jsonData && jsonError) {
                d(@"JSON Error: %@", jsonError.description);
                d(@"JSON Response: %@", [NSString stringWithUTF8String:data.bytes]);
                returnError = jsonError;
            } else {
                NSError * APIError = [self checkForAPIError:jsonData];
                if (APIError) {
                    d(@"API Error: %@", APIError.description);
                    returnError = APIError;
                    if (APIError.code == 9103) {
                        notify(NOTIF_DISMISS_ZONE);
                    }
                }
            }
        }
        callback(response, jsonData, returnError);
    }];
    [dataTask resume];
}

# pragma mark - Error Checking

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

# pragma mark - User Methods

- (void) getUserDetailsForAccount:(CFCredentials *)account finished:(void (^)(NSDictionary<NSString *, id> * userInfo, NSError * error))finished {
    [self requestURL:url(nstrcat(CFAPI_URL, @"/user")) credentials:account
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data objectForKey:@"result"], nil);
        } else {
            finished(nil, error);
        }
    }];
}

# pragma mark - Zone Methods

- (void) getZonesForAccount:(CFCredentials *)account finished:(void (^)(NSArray<CFZone *> * zones, NSError * error))finished {
    NSMutableArray<CFZone *> * allZones = [NSMutableArray new];
    [self getZonesOnPage:1 allZones:allZones forAccount:account finished:^(NSError *error) {
        if (error) {
            finished(nil, error);
            return;
        }

        finished(allZones, nil);
    }];
}

- (void) getZonesOnPage:(NSUInteger)pageNumber allZones:(NSMutableArray<CFZone *> *)allZones forAccount:(CFCredentials *)account finished:(void (^)(NSError * error))finished {
    // Needs to be outside of completion block
    NSUInteger __block page = pageNumber;

    [self requestURL:url(format(@"%@/zones?per_page=50&page=%lu", CFAPI_URL, (unsigned long)page)) credentials:account
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            for (NSDictionary * zone in [data objectForKey:@"result"]) {
                CFZone * zoneObject = [CFZone fromDictionary:zone];
                zoneObject.credentials = account;
                [allZones addObject:zoneObject];
            }
            NSDictionary<NSString *, id> * resultsInfo = [data dictionaryForKey:@"result_info"];
            NSUInteger totalPages = [resultsInfo unsignedIntegerForKey:@"total_pages"];
            if (totalPages > page) {
                [self getZonesOnPage:(page += 1) allZones:allZones forAccount:account finished:finished];
            } else {
                finished(nil);
            }
        } else {
            finished(error);
        }
    }];
}

- (void) setDevelopmentModeForZone:(CFZone *)zone developmentMode:(BOOL)developmentMode finished:(void (^)(BOOL success, NSError * error))finished {
    if (isZoneReadonly(zone)) {
        finished(NO, NSMakeError(1001, @"Zone is read only"));
        return;
    }

    [self requestURL:url(format(@"%@/zones/%@/settings/development_mode", CFAPI_URL, zone.identifier)) method:HTTP_PATCH
    httpBody:format(@"{\"value\":\"%@\"}", developmentMode ? @"on" : @"off") credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) setPauseForZone:(CFZone *)zone paused:(BOOL)paused finished:(void (^)(BOOL success, NSError * error))finished {
    if (isZoneReadonly(zone)) {
        finished(NO, NSMakeError(1001, @"Zone is read only"));
        return;
    }

    [self requestURL:url(format(@"%@/zones/%@", CFAPI_URL, zone.identifier))
    method:HTTP_PATCH
    jsonDictionary:@{
                     @"paused": (paused ? @YES : @NO)
                    }
     credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) deleteZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished {
    if (isZoneReadonly(zone)) {
        finished(NO, NSMakeError(1001, @"Zone is read only"));
        return;
    }

    [self requestURL:url(format(@"%@/zones/%@", CFAPI_URL, zone.identifier)) method:HTTP_DELETE httpBody:nil credentials:zone.credentials
            callback:^(NSURLResponse *response, id data, NSError *error) {
                if (!error) {
                    finished([data[@"success"] boolValue], nil);
                } else {
                    finished(NO, error);
                }
            }];
}

- (void) purgeAllCacheForZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/purge_cache", CFAPI_URL, zone.identifier))
    method:HTTP_DELETE
    jsonDictionary:@{
                     @"purge_everything": @YES
                     }
    credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) purgeFilesCacheForZone:(CFZone *)zone files:(NSArray<NSString *> *)files finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/purge_cache", CFAPI_URL, zone.identifier))
    method:HTTP_DELETE
    jsonDictionary:@{
                     @"files": files
                     }
     credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

# pragma mark - Zone DNS Methods

- (void) getAllDNSRecordsForZone:(CFZone *)zone finished:(void (^)(NSArray<CFDNSRecord *> * records, NSError * error))finished {
    NSMutableArray<CFDNSRecord *> * allRecords = [NSMutableArray new];
    [self getDNSRecordsOnPage:1 forZone:zone finished:^(NSArray<CFDNSRecord *> *records, BOOL lastPage, NSError *error) {
        if (error) {
            finished(nil, error);
            return;
        }
        if (records) {
            [allRecords addObjectsFromArray:records];
        }
        if (lastPage) {
            finished(allRecords, nil);
        }
    }];
}

- (void) getDNSRecordsOnPage:(NSUInteger)pg forZone:(CFZone *)zone finished:(void (^)(NSArray<CFDNSRecord *> * records, BOOL lastPage, NSError * error))finished {
    // Needs to be outside of completion block
    NSUInteger __block page = pg;

    [self requestURL:url(format(@"%@/zones/%@/dns_records?per_page=50&page=%lu", CFAPI_URL, zone.identifier, (unsigned long)page)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            NSArray * objects = [data objectForKey:@"result"];
            NSMutableArray<CFDNSRecord *> * result = [NSMutableArray new];
            for (NSDictionary * object in objects) {
                CFDNSRecord * record = [CFDNSRecord fromDictionary:object];
                if (record) {
                    [result addObject:record];
                }
            }

            NSDictionary<NSString *, id> * resultsInfo = [data dictionaryForKey:@"result_info"];
            NSUInteger totalPages = [resultsInfo unsignedIntegerForKey:@"total_pages"];
            if (totalPages > page) {
                [self getDNSRecordsOnPage:(page += 1) forZone:zone finished:finished];
            }

            finished(result, (totalPages > page ? NO : YES), nil);
        } else {
            finished(nil, YES, error);
        }
    }];
}

- (void) updateDNSObject:(CFDNSRecord *)object forZone:(CFZone *)zone
                finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/dns_records/%@", CFAPI_URL, zone.identifier, object.identifier))
    method:@"PUT" jsonDictionary:[object dictionaryValue] credentials:zone.credentials callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) createDNSObject:(CFDNSRecord *)object forZone:(CFZone *)zone
                finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/dns_records", CFAPI_URL, zone.identifier)) method:HTTP_POST
    jsonDictionary:[object dictionaryValue] credentials:zone.credentials callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) deleteDNSObject:(CFDNSRecord *)object forZone:(CFZone *)zone
                finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/dns_records/%@", CFAPI_URL, zone.identifier, object.identifier)) method:HTTP_DELETE
    httpBody:nil credentials:zone.credentials callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

# pragma mark - Domain Registration Methods

- (void) getDomainRegistraionPropertiesForZone:(CFZone *)zone finished:(void (^)(CFDomainRegistrationProperties * properties, NSError *))finished {
    [self requestURL:url(format(@"%@/accounts/%@/registrar/domains/%@", CFAPI_URL, zone.account_id, zone.name)) credentials:zone.credentials callback:^(NSURLResponse *response, id results, NSError *error) {
        if (error != nil) {
            finished(nil, error);
            return;
        }
        
        CFDomainRegistrationProperties * properties = [CFDomainRegistrationProperties fromDictionary:[results dictionaryForKey:@"result"]];
        finished(properties, nil);
    }];
}

- (void) updateDomainRegistrationProperties:(CFDomainRegistrationProperties *)properties forZone:(CFZone *)zone finished:(void (^)(BOOL, NSError *))finished {
    
}

# pragma mark - Zone Option Methods

- (void) getZoneOptions:(CFZone *)zone
               finished:(void (^)(NSDictionary<NSString *, CFZoneSettings *> * objects, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/settings", CFAPI_URL, zone.identifier)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            NSArray * objects = [data objectForKey:@"result"];
            NSMutableDictionary<NSString *, CFZoneSettings *> * results = [NSMutableDictionary new];
            CFZoneSettings * settingsObject;
            for (NSDictionary<NSString *, id> * setting in objects) {
                settingsObject = [CFZoneSettings fromDictionary:setting];
                [results setObject:settingsObject forKey:settingsObject.name];
            }
            finished(results, nil);
        } else {
            finished(nil, error);
        }
    }];
}

- (void) applyZoneOptions:(CFZone *)zone setting:(CFZoneSettings *)settings
                 finished:(void (^)(CFZoneSettings * setting, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/settings", CFAPI_URL, zone.identifier))
              method:HTTP_PATCH
      jsonDictionary:@{@"items": @[[settings dictionaryValue]]}
     credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            NSArray * result = [data objectForKey:@"result"];
            CFZoneSettings * newSetting = [CFZoneSettings fromDictionary:result[0]];
            finished(newSetting, nil);
        } else {
            finished(nil, error);
        }
    }];
}

# pragma mark - Zone Page Rules Methods

- (void) getZonePageRules:(CFZone *)zone finished:(void (^)(NSArray<CFPageRule *> * rules, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/pagerules", CFAPI_URL, zone.identifier)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id results, NSError *error) {
        if (!error) {
            NSMutableArray * rules = [NSMutableArray new];
            for (NSDictionary * rule in [results objectForKey:@"result"]) {
                [rules addObject:[CFPageRule fromDictionary:rule]];
            }
            finished(rules, nil);
        } else {
            finished(nil, error);
        }
    }];
}

- (void) createZonePageRule:(CFZone *)zone rule:(CFPageRule *)rule finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/pagerules", CFAPI_URL, zone.identifier))
    method:HTTP_POST jsonDictionary:[rule dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) updateZonePageRule:(CFZone *)zone rule:(CFPageRule *)rule finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/pagerules/%@", CFAPI_URL, zone.identifier, rule.identifier))
    method:HTTP_PATCH jsonDictionary:[rule dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) deleteZonePageRule:(CFZone *)zone rule:(CFPageRule *)rule finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/pagerules/%@", CFAPI_URL, zone.identifier, rule.identifier))
    method:HTTP_DELETE jsonDictionary:[rule dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

# pragma mark - Zone Analytic Methods

- (void) analyticsForZone:(CFZone *)zone timeframe:(CFAnalyticsTimeframe)timeframe finished:(void (^)(CFAnalyticsResults * results, NSError * error))finished {
    NSString * since;
    switch (timeframe) {
        case CFAnalyticsTimeframe6Hours:
            since = @"-360";
            break;
        case CFAnalyticsTimeframe12Hours:
            since = @"-720";
            break;
        case CFAnalyticsTimeframe24Hours:
            since = @"-1440";
            break;
        case CFAnalyticsTimeframeLastWeek:
            since = @"-10080";
            break;
        case CFAnalyticsTimeframeLastMonth:
            since = @"-43200";
            break;
    }
    [self requestURL:url(format(@"%@/zones/%@/analytics/dashboard?since=%@", CFAPI_URL, zone.identifier, since)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([CFAnalyticsResults fromDictionary:data[@"result"]], nil);
        } else {
            finished(nil, error);
        }
    }];
}

- (void) dnsAnalyticsForZone:(CFZone *)zone timeframe:(CFDNSAnalyticsTimeframe)timeframe finished:(void (^)(CFDNSAnalyticsResults * results, NSError * error))finished {
    NSDate * now = [NSDate date];
    NSDate * since;
    switch (timeframe) {
        case CFDNSAnalyticsTimeframe24Hours:
            since = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:-24 toDate:now options:0];
            break;
        case CFDNSAnalyticsTimeframe12Hours:
            since = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:-12 toDate:now options:0];
            break;
        case CFDNSAnalyticsTimeframe6Hours:
            since = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:-6 toDate:now options:0];
            break;
        case CFDNSAnalyticsTimeframe30Minutes:
            since = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute value:-30 toDate:now options:0];
            break;
    }
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithLocale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    NSURL * url = [self buildURL:format(@"%@/zones/%@/dns_analytics/report/bytime", CFAPI_URL, zone.identifier) queryParams:@{
                                                                                                                @"metrics": @"queryCount",
                                                                                                                @"dimensions": @"responseCode",
                                                                                                                @"since": [formatter stringFromDate:since],
                                                                                                                @"until": [formatter stringFromDate:now]
                                                                                                                }];
    [self requestURL:url credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            CFDNSAnalyticsResults * results = [CFDNSAnalyticsResults fromDictionary:[data dictionaryForKey:@"result"]];
            if (results == nil) {
                finished(nil, NSMakeError(-1, @"Unexpected analytics response. Try again later."));
            }
            finished(results, nil);
        } else {
            finished(nil, error);
        }
    }];
}

# pragma mark - Zone HSTS Methods

- (void) getHSTSSettingsForZone:(CFZone *)zone finished:(void (^)(CFHSTSSettings * settings, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/settings/security_header", CFAPI_URL, zone.identifier)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([CFHSTSSettings fromDictionary:data[@"result"][@"value"][@"strict_transport_security"]], nil);
        } else {
            finished(nil, error);
        }
    }];
}

- (void) setHSTSSettingsForZone:(CFZone *)zone settings:(CFHSTSSettings *)settings finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/settings/security_header", CFAPI_URL, zone.identifier))
              method:HTTP_PATCH
      jsonDictionary:@{ @"value": @{ @"strict_transport_security": [settings dictionaryValue] }}
     credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

# pragma mark - Zone Rate Limits

- (void) getRateLimitsForZone:(CFZone *)zone finished:(void (^)(NSArray<CFRateLimit *> * limits, NSError * error))finished {
    NSMutableArray<CFRateLimit *> * allRules = [NSMutableArray new];
    [self getRateLimitsForZone:zone onPage:1 allLimits:allRules finished:^(NSError *error) {
        if (error) {
            finished(nil, error);
            return;
        }

        finished(allRules, nil);
    }];
}

- (void) getRateLimitsForZone:(CFZone *)zone onPage:(NSUInteger)pg allLimits:(NSMutableArray<CFRateLimit *> *)allLimits finished:(void (^)(NSError * error))finished {
    // Needs to be outside of completion block
    NSUInteger __block page = pg;

    [self requestURL:url(format(@"%@/zones/%@/rate_limits?per_page=100&page=%lu", CFAPI_URL, zone.identifier, (unsigned long)page)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            NSArray * rule_dicts = [(NSDictionary *)data arrayForKey:@"result"];
            for (NSDictionary * rule_dict in rule_dicts) {
                [allLimits addObject:[CFRateLimit fromDictionary:rule_dict]];
            }

            NSDictionary<NSString *, id> * resultsInfo = [data dictionaryForKey:@"result_info"];
            NSUInteger totalPages = [resultsInfo unsignedIntegerForKey:@"total_pages"];
            if (totalPages > page) {
                [self getRateLimitsForZone:zone onPage:(page += 1) allLimits:allLimits finished:finished];
            } else {
                finished(nil);
            }
        } else {
            finished(error);
        }
    }];
}

- (void) createRateLimitForZone:(CFZone *)zone limit:(CFRateLimit *)limit finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/rate_limits", CFAPI_URL, zone.identifier))
    method:HTTP_POST jsonDictionary:[limit dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) updateRateLimitForZone:(CFZone *)zone limit:(CFRateLimit *)limit finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/rate_limits/%@", CFAPI_URL, zone.identifier, limit.identifier))
    method:HTTP_PUT jsonDictionary:[limit dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) deleteRateLimitForZone:(CFZone *)zone limit:(CFRateLimit *)limit finished:(void (^)(BOOL success, NSError * error))finished {
    [self requestURL:url(format(@"%@/zones/%@/rate_limits/%@", CFAPI_URL, zone.identifier, limit.identifier))
    method:HTTP_DELETE credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

# pragma mark - Firewall Access Rules

- (void) getFirewallAccessRulesForZone:(CFZone *)zone finished:(void (^)(NSArray<CFFirewallAccessRule *> * rules, NSError * error))finished {
    NSMutableArray<CFFirewallAccessRule *> * allRules = [NSMutableArray new];
    [self getFirewallAccessRulesForZone:zone onPage:1 allRules:allRules finished:^(NSError *error) {
        if (error) {
            finished(nil, error);
            return;
        }

        finished(allRules, nil);
    }];
}

- (void) getFirewallAccessRulesForZone:(CFZone *)zone onPage:(NSUInteger)pageNumber allRules:(NSMutableArray<CFFirewallAccessRule *> *)allRules finished:(void (^)(NSError * error))finished {
    // Needs to be outside of completion block
    NSUInteger __block page = pageNumber;

    [self requestURL:url(format(@"%@/zones/%@/firewall/access_rules/rules?per_page=100&page=%lu", CFAPI_URL, zone.identifier, (unsigned long)page)) credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            NSArray * rule_dicts = [(NSDictionary *)data arrayForKey:@"result"];
            for (NSDictionary * rule_dict in rule_dicts) {
                [allRules addObject:[CFFirewallAccessRule fromDictionary:rule_dict]];
            }

            NSDictionary<NSString *, id> * resultsInfo = [data dictionaryForKey:@"result_info"];
            NSUInteger totalPages = [resultsInfo unsignedIntegerForKey:@"total_pages"];
            if (totalPages > page) {
                [self getFirewallAccessRulesForZone:zone onPage:(page += 1) allRules:allRules finished:finished];
            } else {
                finished(nil);
            }
        } else {
            finished(error);
        }
    }];
}

- (void) createFirewallAccessRule:(CFZone *)zone rule:(CFFirewallAccessRule *)rule finished:(void (^)(BOOL success, NSError * error))finished {
    NSURL * reqURL;
    if (rule.scope.type == FirewallAccessRuleScopeTypeZone) {
        reqURL = url(format(@"%@/zones/%@/firewall/access_rules/rules", CFAPI_URL, zone.identifier));
    } else {
        reqURL = url(format(@"%@/user/firewall/access_rules/rules", CFAPI_URL));
    }
    [self requestURL:reqURL
    method:HTTP_POST jsonDictionary:[rule dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) updateFirewallAccessRule:(CFZone *)zone rule:(CFFirewallAccessRule *)rule finished:(void (^)(BOOL success, NSError * error))finished {
    NSURL * reqURL;
    if (rule.scope.type == FirewallAccessRuleScopeTypeZone) {
        reqURL = url(format(@"%@/zones/%@/firewall/access_rules/rules/%@", CFAPI_URL, zone.identifier, rule.identifier));
    } else {
        reqURL = url(format(@"%@/user/firewall/access_rules/rules/%@", CFAPI_URL, rule.identifier));
    }
    [self requestURL:reqURL
    method:HTTP_PATCH jsonDictionary:[rule dictionaryValue] credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

- (void) deleteFirewallAccessRule:(CFZone *)zone rule:(CFFirewallAccessRule *)rule finished:(void (^)(BOOL success, NSError * error))finished {
    NSURL * reqURL;
    if (rule.scope.type == FirewallAccessRuleScopeTypeZone) {
        reqURL = url(format(@"%@/zones/%@/firewall/access_rules/rules/%@", CFAPI_URL, zone.identifier, rule.identifier));
    } else {
        reqURL = url(format(@"%@/user/firewall/access_rules/rules/%@", CFAPI_URL, rule.identifier));
    }
    [self requestURL:reqURL method:HTTP_DELETE credentials:zone.credentials
    callback:^(NSURLResponse *response, id data, NSError *error) {
        if (!error) {
            finished([data[@"success"] boolValue], nil);
        } else {
            finished(NO, error);
        }
    }];
}

@end
