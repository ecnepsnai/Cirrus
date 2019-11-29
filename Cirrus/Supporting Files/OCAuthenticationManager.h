#import <Foundation/Foundation.h>

@interface OCAuthenticationManager : NSObject

/**
 Supported authentication types
 */
typedef NS_ENUM(NSUInteger, OCAuthenticationType) {
    /**
     Biometric authentication. Available since iOS 7+ and only on certain iOS models this includes
     Touch ID and Face ID. Use OCAuthenticationManager.authenticationTypeString to get appropaite
     name of authentication mechanism for this device.
     */
    OCAuthenticationTypeBiometric,
    /**
     Passcode authentication. For devices without biometric hardware, or with biometrics disabled
     this uses the users passcode to authenticate. Passcode is always second choice to biometrics.
     */
    OCAuthenticationTypePasscode,
    /**
     No authentication available. This is when the user has no password set on their device. We can
     not provide any authentication mechanism for the user.
     */
    OCAuthenticationTypeNone,
};

- (id) init;
+ (OCAuthenticationManager *) sharedInstance;

/**
 Has the user enabled device lock

 @return Enabled
 */
- (BOOL) authenticationEnabled;

/**
 Does the current device support authentication

 @return Supports auth
 */
- (BOOL) deviceSupportsAuthentication;

/**
 Authenticate the user on-demand with a given reason

 @param reason The reason to authenticate the user. Should be localized.
 @param success Called when authenticated
 */
- (void) authenticateUserWithReason:(NSString *)reason success:(void(^)(void))success;

/**
 Authenticate the user on-demand for a change

 @param dangerous Is this change considered dangerous
 @param success Called when the user authenticated
 @param cancelled Called when the user cancelled authentication
 */
- (void) authenticateUserForChange:(BOOL)dangerous success:(void(^)(void))success cancelled:(void (^)(void))cancelled;

/**
 Blur the contents of the entire application
 */
- (void) blurApplicationContents;

/**
 Remove the blur thats covering the appliction
 */
- (void) unblurApplicationContents;

/**
 Get the current authentication mode of the device.

 @return The authentication mode.
 */
+ (OCAuthenticationType) currentAuthenticationMode;

/**
 Returns a non-localized string representing the authentication mechanism for this device. This will be either:
  - Passcode
  - Touch ID
  - Face ID (iOS 11+, iPhone X only)

 @return String representing authentication mechanism
 */
+ (NSString *) authenticationTypeString;

@end
