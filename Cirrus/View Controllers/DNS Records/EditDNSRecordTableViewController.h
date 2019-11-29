#import <UIKit/UIKit.h>
#import "CFDNSRecord.h"

@interface EditDNSRecordTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

/**
 * Set the DNS record for the view
 *
 * @param dns      The DNS object
 * @param zone     The zone
 * @param finished Called when the view has been popped
 */
- (void) setDnsRecord:(CFDNSRecord *)dns finished:(void (^)(BOOL cancelled))finished;

@end
