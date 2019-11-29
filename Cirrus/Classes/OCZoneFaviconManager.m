#import "OCZoneFaviconManager.h"

@interface OCZoneFaviconManager()

@property (strong, nonatomic) NSFileManager * fileManager;
@property (strong, nonatomic) NSString * faviconDirectory;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> * faviconAge;

@end

@implementation OCZoneFaviconManager

static id _instance;
static const NSUInteger MAX_CACHE_AGE = 5184000;

+ (OCZoneFaviconManager *) sharedInstance {
    if (!_instance) {
        _instance = [OCZoneFaviconManager new];
    }
    
    return _instance;
}

- (id) init {
    self = [super init];
    self.fileManager = [NSFileManager defaultManager];
    self.faviconDirectory = FAVICON_DIRECTORY;
    if (![self.fileManager fileExistsAtPath:self.faviconDirectory isDirectory:nil]) {
        [self.fileManager createDirectoryAtPath:self.faviconDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    self.faviconAge = UserOptions.faviconAge;
    if (!self.faviconAge) {
        self.faviconAge = @{};
    }

    return self;
}

- (void) faviconForZones:(CFZone *)zone finished:(void (^)(UIImage * image, NSError * error))finished {
    NSNumber * cache_date_number = [self.faviconAge numberForKey:zone.name];
    if (!cache_date_number) {
        cache_date_number = @0;
    }
    
    uint64_t cache_date = [cache_date_number unsignedLongLongValue];
    uint64_t now = time(NULL);
    
    BOOL fileExists = [self.fileManager fileExistsAtPath:[self filePathForDomain:zone.name] isDirectory:nil];
    
    if ((now - cache_date) > MAX_CACHE_AGE || !fileExists) { // Cache is expired
        cd(STORAGE_DEBUG, @"Cached favicon for '%@' is expired.", zone.name);
        [self downloadFaviconForDomain:zone.name finished:finished];
    } else {
        cd(STORAGE_DEBUG, @"Cached favicon for '%@' is not expired.", zone.name);
        [self readImageFromFileForDomain:zone.name finished:finished];
    }
}

- (NSString *) filePathForDomain:(NSString *)domain{
    return format(@"%@/%@", self.faviconDirectory, domain);
}

- (void) downloadFaviconForDomain:(NSString *)domain finished:(void (^)(UIImage * image, NSError * error))finished {
    NSString * url = format(@"https://www.google.com/s2/favicons?domain=%@", domain);
    cd(STORAGE_DEBUG, @"Getting favicon: %@", url);
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithURL:url(url)
    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            UIImage * image = [UIImage imageWithData:data];
            [data writeToFile:[self filePathForDomain:domain] atomically:YES];
            NSNumber * rightNow = [NSNumber numberWithUnsignedLongLong:time(NULL)];

            NSMutableDictionary<NSString *, NSNumber *> * updatedAge = [NSMutableDictionary dictionaryWithDictionary:self.faviconAge];
            [updatedAge setObject:rightNow forKey:domain];
            self.faviconAge = [NSDictionary dictionaryWithDictionary:updatedAge];

            cd(STORAGE_DEBUG, @"%@ cached at: %@", domain, rightNow);
            UserOptions.faviconAge = updatedAge;
            finished(image, nil);
        } else {
            finished(nil, error);
        }
    }];
    [task resume];
}

- (void) readImageFromFileForDomain:(NSString *)domain finished:(void (^)(UIImage * image, NSError * error))finished {
    NSData * imageData = [NSData dataWithContentsOfFile:[self filePathForDomain:domain]];
    UIImage * image = [UIImage imageWithData:imageData];
    finished(image, nil);
}

@end
