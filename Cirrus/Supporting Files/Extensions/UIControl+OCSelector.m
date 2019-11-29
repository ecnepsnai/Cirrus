@implementation UIControl (OCSelector)

- (void) addSelector:(OCSelector *)selector forControlEvent:(UIControlEvents)event {
    [self addTarget:selector.sender action:selector.action forControlEvents:event];
}

@end
