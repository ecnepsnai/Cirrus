#import "DomainRegistrationTableViewController.h"
#import "OCTableViewSection.h"

@interface DomainRegistrationTableViewController ()

@property (strong, nonatomic) CFDomainRegistrationProperties * registrationProperties;
@property (strong, nonatomic) NSMutableArray<OCTableViewSection *> * sections;

@end

@implementation DomainRegistrationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.sections = [NSMutableArray new];
    [self loadData];
}

- (void) userPulledToRefresh {
    [self loadData];
}

- (void) loadData {
    [self.refreshControl beginRefreshing];
    
    [api getDomainRegistraionPropertiesForZone:currentZone finished:^(CFDomainRegistrationProperties *properties, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [uihelper presentErrorInViewController:self error:error dismissed:nil];
                [self.refreshControl endRefreshing];
                return;
            });
        }
        
        self.registrationProperties = properties;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self buildTable];
        });
    }];
}

- (void) buildTable {
    [self.sections removeAllObjects];
    
    OCTableViewSection * stateSection = [OCTableViewSection new];
    stateSection.title = l(@"Status");
    
    // State cell
    {
        UITableViewCell * stateCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        stateCell.textLabel.text = l(@"State");
        if (self.registrationProperties.registeredToCloudflare) {
            stateCell.detailTextLabel.text = l(@"Active");
            stateCell.detailTextLabel.textColor = UIColor.materialGreen;
        } else {
            stateCell.detailTextLabel.text = l(@"Not Registrered on Cloudflare");
            stateCell.detailTextLabel.textColor = UIColor.materialOrange;
        }
        [stateSection.cells addObject:[OCTableViewCell cellWithCell:stateCell]];
    }
    
    // Date Cells
    {
        NSDateFormatter * dateFormatter = [NSDateFormatter new];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        UITableViewCell * createdCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        createdCell.textLabel.text = l(@"Domain Created");
        createdCell.detailTextLabel.text = [dateFormatter stringFromDate:self.registrationProperties.firstRegistered];
        [stateSection.cells addObject:[OCTableViewCell cellWithCell:createdCell]];
        
        if (self.registrationProperties.registeredToCloudflare) {
            UITableViewCell * registeredCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
            registeredCell.textLabel.text = l(@"Registered");
            registeredCell.detailTextLabel.text = [dateFormatter stringFromDate:self.registrationProperties.registeredAt];
            [stateSection.cells addObject:[OCTableViewCell cellWithCell:registeredCell]];
        }
        
        UITableViewCell * expiresCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        expiresCell.textLabel.text = l(@"Expires");
        expiresCell.detailTextLabel.text = [dateFormatter stringFromDate:self.registrationProperties.expiresAt];
        [stateSection.cells addObject:[OCTableViewCell cellWithCell:expiresCell]];
    }
    
    // Current Registar Cell
    if (!self.registrationProperties.registeredToCloudflare) {
        UITableViewCell * currentRegistrarCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        currentRegistrarCell.textLabel.text = l(@"Current");
        currentRegistrarCell.detailTextLabel.text = self.registrationProperties.currentRegistrar;
        [stateSection.cells addObject:[OCTableViewCell cellWithCell:currentRegistrarCell]];
    }
    
    // Price cell
    {
        UITableViewCell * feeCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        feeCell.textLabel.text = l(@"Price Per Year");
        
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:[NSLocale currentLocale]];

        feeCell.detailTextLabel.text = [formatter stringFromNumber:self.registrationProperties.renewalPrice];
        [stateSection.cells addObject:[OCTableViewCell cellWithCell:feeCell]];
    }
    [self.sections addObject:stateSection];
    
    OCTableViewSection * registraionSection = [OCTableViewSection new];
    registraionSection.title = l(@"Registration");
    if (self.registrationProperties.registeredToCloudflare) {
        // Contact Cell
        UITableViewCell * contactCell = [self.tableView dequeueReusableCellWithIdentifier:@"Basic"];
        contactCell.textLabel.text = l(@"View Contact Information");
        [registraionSection.cells addObject:[OCTableViewCell cellWithCell:contactCell segueIdentifier:@"Contact"]];
    } else {
        // WHOIS Cell
        UITableViewCell * whoisCell = [self.tableView dequeueReusableCellWithIdentifier:@"Basic"];
        whoisCell.textLabel.text = l(@"View WHOIS");
        [registraionSection.cells addObject:[OCTableViewCell cellWithCell:whoisCell segueIdentifier:@"WHOIS"]];
    }
    [self.sections addObject:registraionSection];
    
    OCTableViewSection * securitySection = [OCTableViewSection new];
    securitySection.title = l(@"Security");
    
    // Locked Cell
    {
        UITableViewCell * lockCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        lockCell.textLabel.text = l(@"Transfer Lock");
        if (self.registrationProperties.transferLocked) {
            lockCell.detailTextLabel.text = l(@"Locked");
        } else {
            lockCell.detailTextLabel.text = l(@"Unlocked");
            if (self.registrationProperties.registeredToCloudflare) {
                lockCell.detailTextLabel.textColor = UIColor.materialRed;
            } else {
                securitySection.footer = l(@"Transfer domains on the Cloudflare website");
            }
        }
        [securitySection.cells addObject:[OCTableViewCell cellWithCell:lockCell]];
    }
    
    // DNSSEC Cell
    {
        UITableViewCell * dnssecCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
        dnssecCell.textLabel.text = @"DNSSEC";
        if (self.registrationProperties.transferLocked) {
            dnssecCell.detailTextLabel.text = l(@"Enabled");
            dnssecCell.detailTextLabel.textColor = UIColor.materialGreen;
        } else {
            dnssecCell.detailTextLabel.text = l(@"Disabled");
            dnssecCell.detailTextLabel.textColor = UIColor.materialOrange;
        }
        [securitySection.cells addObject:[OCTableViewCell cellWithCell:dnssecCell]];
    }
    
    [self.sections addObject:securitySection];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].cells.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.sections[section].footer;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section].cells[indexPath.row].cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * segueIdentifier = self.sections[indexPath.section].cells[indexPath.row].segueIdentifier;
    if (segueIdentifier == nil) {
        return;
    }
    
    [self performSegueWithIdentifier:segueIdentifier sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setValue:self.registrationProperties forKey:@"registrationProperties"];
}

@end
