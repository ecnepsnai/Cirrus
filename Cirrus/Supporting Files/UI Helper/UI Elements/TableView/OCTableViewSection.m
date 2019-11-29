#import "OCTableViewSection.h"

@implementation OCTableViewSection

- (OCTableViewSection *) init {
    self = [super init];
    self.cells = [NSMutableArray new];
    return self;
}

- (OCTableViewSection *) initWithCells:(NSArray<UITableViewCell *> *)cells {
    self = [super init];
    self.cells = [[NSMutableArray alloc] initWithArray:cells];
    return self;
}

@end
