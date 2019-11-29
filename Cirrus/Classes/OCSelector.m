#import "OCSelector.h"

@interface OCSelector() {
    void (^blockCallback)(id);
}

@end

@implementation OCSelector

- (id) initWithBlock:(void (^)(id sender))action {
    self = [super init];
    blockCallback = action;
    self.sender = self;
    self.action = @selector(blockSelector:);
    return self;
}

+ (OCSelector *) selectorWithTarget:(id)sender action:(SEL)action {
    OCSelector * selector = [OCSelector new];
    selector.sender = sender;
    selector.action = action;
    return selector;
}

- (void) performActionOnSender {
    IMP imp = [self.sender methodForSelector:self.action];
    void (*func)(__strong id, SEL) = (void (*)(__strong id, SEL))imp;
    func(self.sender, self.action);
}

- (void) performActionOnSenderWithObject:(id)object {
    IMP imp = [self.sender methodForSelector:self.action];
    void (*func)(__strong id, SEL, id) = (void (*)(__strong id, SEL, id))imp;
    func(self.sender, self.action, object);
}

- (void) blockSelector:(id)sender {
    blockCallback(sender);
}

@end
