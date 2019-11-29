@implementation UINavigationItem (AddButtons)

- (void) addRightBarButton:(UIBarButtonItem *)button {
    NSMutableArray<UIBarButtonItem *> * buttons = [NSMutableArray arrayWithCapacity:self.rightBarButtonItems.count+1];
    [buttons addObjectsFromArray:self.rightBarButtonItems];
    [buttons addObject:button];
    self.rightBarButtonItems = buttons;
}

- (void) addLeftBarButton:(UIBarButtonItem *)button {
    NSMutableArray<UIBarButtonItem *> * buttons = [NSMutableArray arrayWithCapacity:self.leftBarButtonItems.count+1];
    [buttons addObjectsFromArray:self.leftBarButtonItems];
    [buttons addObject:button];
    self.leftBarButtonItems = buttons;
}

@end
