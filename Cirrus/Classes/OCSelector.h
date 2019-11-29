#import <Foundation/Foundation.h>

@interface OCSelector : NSObject

- (id) initWithBlock:(void (^)(id sender))action;
+ (OCSelector *) selectorWithTarget:(id)sender action:(SEL)action;
- (void) performActionOnSender;
- (void) performActionOnSenderWithObject:(id)object;

@property (strong, nonatomic) id sender;
@property (nonatomic) SEL action;

@end
