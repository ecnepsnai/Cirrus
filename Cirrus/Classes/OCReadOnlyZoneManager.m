#import "OCReadOnlyZoneManager.h"

@interface OCReadOnlyZoneManager ()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> * readOnlyZones;
@property (strong, nonatomic) NSObject * token;

@end

@implementation OCReadOnlyZoneManager

static OCReadOnlyZoneManager * _instance;

+ (OCReadOnlyZoneManager * _Nonnull) sharedInstance {
    if (!_instance) {
        _instance = [OCReadOnlyZoneManager new];
    }
    return _instance;
}

- (id _Nonnull) init {
    if (!_instance) {
        _instance = [super init];
        _instance.token = [NSObject new];
        [_instance updateZoneCache];
    }
    return _instance;
}

- (void) updateZoneCache {
    @synchronized (self.token) {
        self.readOnlyZones = [NSMutableDictionary new];
        NSArray<NSString *> * readOnlyZones = UserOptions.readOnlyZones;
        for (NSString * zone in readOnlyZones) {
            [self.readOnlyZones setObject:@1 forKey:zone];
        }
        d(@"Read only zones: %@", self.readOnlyZones.allKeys);
        UserOptions.readOnlyZones = [self.readOnlyZones allKeys];
    }
}

- (void) markZoneAsReadOnly:(CFZone * _Nonnull) zone {
    @synchronized (self.token) {
        d(@"Marking zone %@ as readonly", zone.name);
        NSMutableArray<NSString *> * zones = [[NSMutableArray alloc] initWithArray:UserOptions.readOnlyZones];
        [zones addObject:zone.name];
        UserOptions.readOnlyZones = zones;
    }
    [self updateZoneCache];
}

- (void) markZoneAdReadWrite:(CFZone * _Nonnull) zone {
    @synchronized (self.token) {
        d(@"Marking zone %@ as readwrite", zone.name);
        NSMutableArray<NSString *> * zones = [[NSMutableArray alloc] initWithArray:UserOptions.readOnlyZones];
        [zones removeObject:zone.name];
        UserOptions.readOnlyZones = zones;
    }
    [self updateZoneCache];
}

- (BOOL) zoneIsReadOnly:(CFZone * _Nonnull) zone {
    @synchronized (self.token) {
        return [self.readOnlyZones objectForKey:zone.name] != nil;
    }
}

@end
