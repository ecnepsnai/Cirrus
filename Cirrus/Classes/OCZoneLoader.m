#import "OCZoneLoader.h"
#import "NSAtomicNumber.h"

@interface OCZoneLoader ()

@property (strong, nonatomic) NSMutableArray<CFZone *> * zones;
@property (strong, nonatomic) NSAtomicNumber * latch;
@property (strong, nonatomic) void (^finishedBlock)(NSArray<CFZone *> *, NSError *);
@property (strong, nonatomic) NSError * fetchError;

@end

@implementation OCZoneLoader

static id _instance;
static id semaphore;

- (id) init {
    if (!_instance) {
        _instance = [super init];
        semaphore = @0;
    }
    return _instance;
}

+ (OCZoneLoader *) sharedInstance {
    if (!_instance) {
        return [[OCZoneLoader alloc] init];
    }
    return _instance;
}

- (void) loadAllZones:(void (^)(NSArray<CFZone *> *, NSError *))finished {
    NSArray<CFCredentials *> * accounts = CFCredentialManager.sharedInstance.allCredentials;
    self.finishedBlock = finished;

    self.zones = [NSMutableArray new];
    self.latch = [NSAtomicNumber numberWithInitialValue:accounts.count];
    for (CFCredentials * account in accounts) {
        [NSThread detachNewThreadSelector:@selector(getZonesForAccount:) toTarget:self withObject:account];
    }
}

- (void) getZonesForAccount:(CFCredentials *)account {
    d(@"Getting zones for %@", account.email);
    [api getZonesForAccount:account finished:^(NSArray<CFZone *> *zones, NSError *error) {
        if (error) {
            d(@"Error getting zones for account %@: %@", account.email, error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.fetchError = error;
                [self checkLatch];
            });
            return;
        }

        @synchronized(semaphore) {
            [self.zones addObjectsFromArray:zones];
        }

        [self.latch decrementAndGet];
        [self checkLatch];
    }];
}

- (void) checkLatch {
    if (self.fetchError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.finishedBlock != nil) {
                self.finishedBlock(nil, self.fetchError);
                self.finishedBlock = nil;
            }
        });
    }
    if ([self.latch getValue] == 0) {
        d(@"Finished getting zones for all accounts");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.finishedBlock != nil) {
                self.finishedBlock([self sortAndFilterZones], nil);
                self.finishedBlock = nil;
            }
        });
    }
}

- (NSArray<CFZone *> *) sortAndFilterZones {
    NSArray<CFZone *> * zones = [self.zones filteredCopy:^bool(CFZone *  _Nonnull zone, NSInteger index) {
        return !zone.hidden;
    }];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray<CFZone *> * sortedZones = [zones sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedZones;
}

@end
