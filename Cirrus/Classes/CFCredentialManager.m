#import "CFCredentialManager.h"
#include <SAMKeychain/SAMKeychain.h>

@interface CFCredentialManager ()

@property (strong, nonatomic, readwrite) NSArray<CFCredentials *> * credentials;

@end

@implementation CFCredentialManager

static id _instance;
static NSString * KEYCHAIN_SERVICE = @"cirrus";
static NSString * KEYCHAIN_ACCOUNT_EMAILS = @"emails";

- (id) init {
    if (_instance == nil) {
        CFCredentialManager * manager = [super init];
        [manager migrateCredentialsIfNeeded];
        _instance = manager;
    }
    return _instance;
}

+ (CFCredentialManager *) sharedInstance {
    if (!_instance) {
        _instance = [CFCredentialManager new];
    }
    return _instance;
}

# pragma mark - Public methods

- (void) loadCredentialsFromStorage {
    NSArray<NSString *> * emails = [self savedEmails];
    NSInteger recentIndex = UserOptions.lastUsedAccountIndex;
    NSMutableArray<CFCredentials *> * creds = [NSMutableArray new];
    for (NSString * email in emails) {
#if !(TARGET_IPHONE_SIMULATOR)
        NSString * key = [SAMKeychain passwordForService:KEYCHAIN_SERVICE account:email];
#else
        NSString * key = [[NSUserDefaults standardUserDefaults] stringForKey:email];
#endif
        if (key != nil) {
            CFCredentials * credentials = [CFCredentials new];
            credentials.email = email;
            credentials.key = key;
            [creds addObject:credentials];
        }
    }
    self.credentials = creds;
    if (recentIndex >= self.credentials.count || recentIndex < 0) {
        recentIndex = 0;
        UserOptions.lastUsedAccountIndex = recentIndex;
    }
}

- (BOOL) credentialsExistInStorage {
#if !(TARGET_IPHONE_SIMULATOR)
    NSString * emailString = [SAMKeychain passwordForService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT_EMAILS];
#else
    NSString * emailString = [[NSUserDefaults standardUserDefaults] stringForKey:KEYCHAIN_ACCOUNT_EMAILS];
#endif
    return emailString != nil && emailString.length > 0;
}

- (NSArray<CFCredentials *> *) allCredentials {
    return self.credentials;
}

- (void) saveCredentials:(CFCredentials *)credentials {
    NSMutableArray<NSString *> * emails = [NSMutableArray arrayWithArray:[self savedEmails]];
    [emails addObject:credentials.email];
#if !(TARGET_IPHONE_SIMULATOR)
    [SAMKeychain setPassword:[emails componentsJoinedByString:@"\n"] forService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT_EMAILS];
    [SAMKeychain setPassword:credentials.key forService:KEYCHAIN_SERVICE account:credentials.email];
#else
    [[NSUserDefaults standardUserDefaults] setObject:[emails componentsJoinedByString:@"\n"] forKey:KEYCHAIN_ACCOUNT_EMAILS];
    [[NSUserDefaults standardUserDefaults] setObject:credentials.key forKey:credentials.email];
#endif
    [self loadCredentialsFromStorage];
}

- (NSArray<NSString *> *) savedEmails {
#if !(TARGET_IPHONE_SIMULATOR)
    NSString * emailString = [SAMKeychain passwordForService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT_EMAILS];
#else
    NSString * emailString = [[NSUserDefaults standardUserDefaults] stringForKey:KEYCHAIN_ACCOUNT_EMAILS];
#endif
    if (emailString == nil) {
        return @[];
    }
    return [emailString componentsSeparatedByString:@"\n"];
}

- (void) forgetCredentials:(CFCredentials *)credentials {
    NSMutableArray<NSString *> * emails = [NSMutableArray arrayWithArray:[self savedEmails]];
    [emails removeObject:credentials.email];
#if !(TARGET_IPHONE_SIMULATOR)
    [SAMKeychain setPassword:[emails componentsJoinedByString:@"\n"] forService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT_EMAILS];
    [SAMKeychain deletePasswordForService:KEYCHAIN_SERVICE account:credentials.email];
#else
    [[NSUserDefaults standardUserDefaults] setObject:[emails componentsJoinedByString:@"\n"] forKey:KEYCHAIN_ACCOUNT_EMAILS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:credentials.email];
#endif
    [self loadCredentialsFromStorage];
}

- (void) removeAllAccountsFromStorage {
    NSArray<NSString *> * emails = [self savedEmails];
    for (NSString * email in emails) {
#if !(TARGET_IPHONE_SIMULATOR)
        [SAMKeychain deletePasswordForService:KEYCHAIN_SERVICE account:email];
#else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:email];
#endif
    }
#if !(TARGET_IPHONE_SIMULATOR)
    [SAMKeychain deletePasswordForService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT_EMAILS];
#else
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEYCHAIN_ACCOUNT_EMAILS];
#endif
    self.credentials = @[];
}

# pragma mark - Private Methods

- (BOOL) credentialsAreInKeychain {
#if !(TARGET_IPHONE_SIMULATOR)
    return YES;
#else
    return NO;
#endif
}

- (void) migrateCredentialsIfNeeded {
    // Legacy versions of the application stored a binary "blob" in the keychain which
    // included TouchID status. Attempt to locate these blobs, parse them, and update
    // using the newer storage methods
    NSString * legacyKeychainService = @"orangecloud";
    NSString * legacyKeychainAccount = @"blob";

    NSData * blob = [SAMKeychain passwordDataForService:legacyKeychainService account:legacyKeychainAccount];
    if (blob == nil) {
        return;
    }

    uint8_t securityFlag;
    [blob getBytes:&securityFlag length:1];
    if (securityFlag == 1) {
        // TouchID enabled
        UserOptions.deviceLock = YES;
    }

    NSData * credentialData = [blob subdataWithRange:NSMakeRange(1, blob.length - 1)];
    NSString * blobString = [[NSString alloc] initWithData:credentialData encoding:NSUTF8StringEncoding];
    NSArray<NSString *> * components = [blobString componentsSeparatedByString:@":"];

    NSString * email;
    NSString * key;
    if (components.count == 3) {
        // Legacy keys included the IDFV at the front
        email = components[1];
        key = components[2];
    } else if (components.count == 2) {
        email = components[0];
        key = components[1];
    } else {
        d(@"Invalid string provided! (Not two components)");
        return;
    }
    CFCredentials * credentials = [CFCredentials new];
    credentials.email = email;
    credentials.key = key;

    [self saveCredentials:credentials];
    [SAMKeychain deletePasswordForService:legacyKeychainService account:legacyKeychainAccount];
    d(@"Migrated legacy credentials");
}

@end
