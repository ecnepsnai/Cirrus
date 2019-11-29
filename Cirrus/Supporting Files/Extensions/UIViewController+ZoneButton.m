@implementation UIViewController (ZoneButton)

- (void) addZoneMenuButtonWithTitle:(NSString *)title {
    if (isRegular) {
        self.navigationItem.title = title;
        return;
    }

    CGFloat titleViewHeight = self.navigationController.navigationBar.frame.size.height;
    static float padding = 5;
    UIButton * zoneButton = [[UIButton alloc] initWithFrame:CGRectMake(padding, padding, 0, titleViewHeight - (padding * 2))];
    [zoneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:zoneButton.titleLabel.font.pointSize]];
    [zoneButton setTitle:format(@"%@ ▾", currentZone.name) forState:UIControlStateNormal];
    [zoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [zoneButton setTitleColor:[UIColor materialBlueGrey] forState:UIControlStateHighlighted];
    [zoneButton addTarget:self action:@selector(dissmissZone) forControlEvents:UIControlEventTouchUpInside];
    [zoneButton sizeToFit];
    self.navigationItem.titleView = zoneButton;
    subscribe(@selector(dissmissZone), NOTIF_DISMISS_ZONE);
}

- (void) dissmissZone {
    currentZone = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
