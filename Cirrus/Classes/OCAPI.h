#import <Foundation/Foundation.h>
#import "CFZone.h"
#import "CFZoneSettings.h"
#import "CFDNSRecord.h"
#import "CFPageRule.h"
#import "CFAnalyticsResults.h"
#import "CFDNSAnalyticsResults.h"
#import "CFHSTSSettings.h"
#import "CFRateLimit.h"
#import "CFFirewallAccessRule.h"
#import "CFCredentials.h"

@interface OCAPI : NSObject

/**
 Initilize a new instance of the Cloudflare API class

 @return A pointer to an initilized CFAPI instance
 */
- (id) init;


/**
 Return the shared instance of the Cloudflare API class

 @return A pointer to an initilized CFAPI instance
 */
+ (OCAPI *) sharedInstance;

#pragma mark -
#pragma mark User methods

/**
 Fetch the user details from Cloudflare

 @param account The account to get information of
 @param finished Called when finished regardless of success.
 */
- (void) getUserDetailsForAccount:(CFCredentials *)account finished:(void (^)(NSDictionary<NSString *, id> * userInfo, NSError * error))finished;

#pragma mark -
#pragma mark Zone Methods

/**
 Get all of the zones for the account

 @param account The account to fetch zones for
 @param finished Called for each page of zones loaded
 */
- (void) getZonesForAccount:(CFCredentials *)account finished:(void (^)(NSArray<CFZone *> * zones, NSError * error))finished;

/**
 Set development mode for the zone

 @param zone            The zone
 @param developmentMode TRUE to enable development mode, FALSE to disable
 @param finished        Called when finished regardless of success.
 */
- (void) setDevelopmentModeForZone:(CFZone *)zone developmentMode:(BOOL)developmentMode finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Set the paused status for the zone

 @param zone     The zone
 @param paused   TRUE to pause the zone. FALSE to unpause.
 @param finished Called when finished regardless of success.
 */
- (void) setPauseForZone:(CFZone *)zone paused:(BOOL)paused finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Delete the zone

 @param zone     The zone to delete
 @param finished Called when finished regardless of success.
 */
- (void) deleteZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Purge all cache for the provided zone

 @param zone     The zone to purge
 @param finished Called when finished regardless of success.
 */
- (void) purgeAllCacheForZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Purge cache of individual files for the provided zone

 @param zone     The zone to purge
 @param files    The files to purge
 @param finished Called when finished regardless of success.
 */
- (void) purgeFilesCacheForZone:(CFZone *)zone files:(NSArray<NSString *> *)files finished:(void (^)(BOOL success, NSError * error))finished;

# pragma mark - Zone DNS Methods

/**
 Get all DNS records for the provided zone

 @param zone     The zone to query
 @param finished Called when finished regardless of success.
 */
- (void) getAllDNSRecordsForZone:(CFZone *)zone finished:(void (^)(NSArray<CFDNSRecord *> * records, NSError * error))finished;

/**
 Update the DNS object for the zone

 @prarm object   The updated DNS object
 @param zone     The zone
 @param finished Called when finished regardless of success.
 */
- (void) updateDNSObject:(CFDNSRecord *)object forZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Create a new DNS record for the zone

 @prarm object   The updated DNS object
 @param zone     The zone
 @param finished Called when finished regardless of success.
 */
- (void) createDNSObject:(CFDNSRecord *)object forZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Delete the DNS object for the zone

 @prarm object   The DNS object to delete
 @param zone     The zone
 @param finished Called when finished regardless of success.
 */
- (void) deleteDNSObject:(CFDNSRecord *)object forZone:(CFZone *)zone finished:(void (^)(BOOL success, NSError * error))finished;

# pragma mark - Zone Option Methods

/**
 Get the zone options

 @param zone     The zone to query
 @param finished Called when finished regardless of success.
 */
- (void) getZoneOptions:(CFZone *)zone finished:(void (^)(NSDictionary<NSString *, CFZoneSettings *> * objects, NSError * error))finished;

/**
 Apply the options to the zone

 @param zone     The zone
 @param settings The settings object
 @param finished Called when finished regardless of success.
 */
- (void) applyZoneOptions:(CFZone *)zone setting:(CFZoneSettings *)settings finished:(void (^)(CFZoneSettings * setting, NSError * error))finished;

# pragma mark - Zone Page Rules Methods

/**
 Get all of the page rules for the zone

 @param zone The zone to query
 @param finished Called when finished regardless of success.
 */
- (void) getZonePageRules:(CFZone *)zone finished:(void (^)(NSArray<CFPageRule *> * rules, NSError * error))finished;

/**
 Create a new page rule for the zone

 @param zone The zone to add the rule to
 @param rule The new rule
 @param finished Called when finished regardless of success.
 */
- (void) createZonePageRule:(CFZone *)zone rule:(CFPageRule *)rule finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Update a pre-existing page rule for the zone.

 @param zone The zone the rule belongs to
 @param rule The updated rule
 @param finished Called when finished regardless of success.
 */
- (void) updateZonePageRule:(CFZone *)zone rule:(CFPageRule *)rule finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Delete a page rule for the zone.

 @param zone The zone the rule belongs to
 @param rule The rule to delete
 @param finished Called when finished regardless of success.
 */
- (void) deleteZonePageRule:(CFZone *)zone rule:(CFPageRule *)rule finished:(void (^)(BOOL success, NSError * error))finished;

# pragma mark - Zone Analytic Methods

/**
 Get the analytics information for the zone

 @param zone The zone to query
 @param timeframe The timeframe for the data
 @param finished Called when finished regardless of success.
 */
- (void) analyticsForZone:(CFZone *)zone timeframe:(CFAnalyticsTimeframe)timeframe finished:(void (^)(CFAnalyticsResults * results, NSError * error))finished;

- (void) dnsAnalyticsForZone:(CFZone *)zone timeframe:(CFDNSAnalyticsTimeframe)timeframe finished:(void (^)(CFDNSAnalyticsResults * results, NSError * error))finished;

# pragma mark - Zone HSTS Methods

/**
 Get the HSTS settings for the zone

 @param zone The zone to query
 @param finished Called when finished regardless of success.
 */
- (void) getHSTSSettingsForZone:(CFZone *)zone finished:(void (^)(CFHSTSSettings * settings, NSError * error))finished;

/**
 Set the HSTS settings for the zone

 @param zone The zone to update
 @param settings The new HSTS settings
 @param finished Called when finished regardless of success.
 */
- (void) setHSTSSettingsForZone:(CFZone *)zone settings:(CFHSTSSettings *)settings finished:(void (^)(BOOL success, NSError * error))finished;

# pragma mark - Zone Rate Limits

/**
 Get the rate limit rules for a zone

 @param zone The zone to query
 @param finished Called when finished regardless of success.
 */
- (void) getRateLimitsForZone:(CFZone *)zone finished:(void (^)(NSArray<CFRateLimit *> * limits, NSError * error))finished;

/**
 Create a new rate limit rule for a zone

 @param zone The zone to apply the rule to
 @param limit The new rate limit rule
 @param finished Called when finished regardless of success.
 */
- (void) createRateLimitForZone:(CFZone *)zone limit:(CFRateLimit *)limit finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Update an existing rate limit rule for a zone

 @param zone The zone the rule applies to
 @param limit The updated rate limit rule
 @param finished Called when finished regardless of success.
 */
- (void) updateRateLimitForZone:(CFZone *)zone limit:(CFRateLimit *)limit finished:(void (^)(BOOL success, NSError * error))finished;

/**
 Delete an existing rate limit rule for a zone

 @param zone The zone the rule applies to
 @param limit The rate limit rule to delet
 @param finished Called when finished regardless of success.
 */
- (void) deleteRateLimitForZone:(CFZone *)zone limit:(CFRateLimit *)limit finished:(void (^)(BOOL success, NSError * error))finished;

# pragma mark - Firewall Access Rules

- (void) getFirewallAccessRulesForZone:(CFZone *)zone finished:(void (^)(NSArray<CFFirewallAccessRule *> * rules, NSError * error))finished;

- (void) createFirewallAccessRule:(CFZone *)zone rule:(CFFirewallAccessRule *)rule finished:(void (^)(BOOL success, NSError * error))finished;

- (void) updateFirewallAccessRule:(CFZone *)zone rule:(CFFirewallAccessRule *)rule finished:(void (^)(BOOL success, NSError * error))finished;

- (void) deleteFirewallAccessRule:(CFZone *)zone rule:(CFFirewallAccessRule *)rule finished:(void (^)(BOOL success, NSError * error))finished;

@end
