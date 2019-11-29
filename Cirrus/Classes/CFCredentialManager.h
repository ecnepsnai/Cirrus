#import <Foundation/Foundation.h>
#import "CFCredentials.h"

@interface CFCredentialManager : NSObject

+ (CFCredentialManager *) sharedInstance;
- (id) init;

/**
 Do credentials exist in storage

 @return Boolean if at least one email and API key are present
 */
- (BOOL) credentialsExistInStorage;

/**
 Load the most recently used credentials from storage
 */
- (void) loadCredentialsFromStorage;

/**
 Load all credentials from storage

 @return An array of crednetials, or an empty array
 */
- (NSArray<CFCredentials *> *) allCredentials;

/**
 Save the credentials in the keychain
 */
- (void) saveCredentials:(CFCredentials *)credentials;

/**
 Zero out the specific credential in the keychain
 */
- (void) forgetCredentials:(CFCredentials *)credentials;

/**
 Zero out all credentials in the keychain
 */
- (void) removeAllAccountsFromStorage;

@end
