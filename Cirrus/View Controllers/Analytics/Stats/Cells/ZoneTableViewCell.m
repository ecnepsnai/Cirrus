#import "ZoneTableViewCell.h"
#import "OCZoneFaviconManager.h"
#import "PurgeCacheTableViewController.h"
#import "ZoneMenuTableViewController.h"

@interface ZoneTableViewCell ()

@property (strong, nonatomic) CFZone * zone;
@property (strong, nonatomic) UIViewController * controller;
@property (nonatomic) BOOL showFavicon;

@property (weak, nonatomic, nullable) IBOutlet UIImageView * favicon;
@property (weak, nonatomic, nullable) IBOutlet UILabel * zoneName;
@property (weak, nonatomic, nullable) IBOutlet UILabel *readOnly;
@property (weak, nonatomic, nullable) IBOutlet UILabel * zoneStatus;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * faviconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * zoneNamePadding;

@end

@implementation ZoneTableViewCell

- (void) awakeFromNib {
    [super awakeFromNib];
    subscribe(@selector(checkFaviconSetting), NOTIF_FAVICON_CHANGED);
}

- (void) checkFaviconSetting {
    self.showFavicon = UserOptions.showFavicons;
    if (self.showFavicon) {
        [self showZoneFavicon];
    } else {
        [self hideZoneFavicon];
    }
}

- (void) configureCellForZone:(CFZone *)zone onController:(UIViewController *)controller {
    NSAssert(zone != nil, @"Zone cannot be nil");
    NSAssert(controller != nil, @"Controller cannot be nil");
    self.zone = zone;
    self.controller = controller;
    [self checkFaviconSetting];

    self.zoneName.text = self.zone.name;
    OCIconCode iconCode;

    switch ([self.zone displayStatus]) {
        case CFZoneStatusActive:
            iconCode = OCIconCodeActive;
            break;
        case CFZoneStatusPaused:
            iconCode = OCIconCodePaused;
            break;
        case CFZoneStatusDevMode:
            iconCode = OCIconCodeDevMode;
            break;
        case CFZoneStatusMoved:
            iconCode = OCIconCodeMoved;
            break;
    }

    [[OCIcon iconForCode:iconCode] configureLabel:self.zoneStatus];
    if (zone.readOnly) {
        self.readOnly.hidden = NO;
        [[OCIcon iconForCode:OCIconCodeReadOnly] configureLabel:self.readOnly];
    } else {
        self.readOnly.hidden = YES;
    }

    UILongPressGestureRecognizer * pressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(showZoneActionsheet:)];
    [self addGestureRecognizer:pressRecognizer];
}

- (void) showZoneActionsheet:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    ZoneMenuTableViewController * menu = viewControllerFromStoryboard(STORYBOARD_MAIN, @"ZoneMenu");
    [menu showZoneMenuOnController:self.controller forZone:self.zone finished:^{
        notify(NOTIF_RELOAD_ZONES);
    }];
}

- (void) showZoneFavicon {
    [[OCZoneFaviconManager sharedInstance] faviconForZones:self.zone finished:^(UIImage *image, NSError * error) {
        if (!error && image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.favicon.image = image;
                self.faviconWidth.constant = 16.0f;
                self.zoneNamePadding.constant = 8.0f;
            });
        } else {
            d(@"Error getting favicon for zone %@: %@", self.zone.name, error.description);
        }
    }];
}

- (void) hideZoneFavicon {
    self.faviconWidth.constant = 0.0f;
    self.zoneNamePadding.constant = 0.0f;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
