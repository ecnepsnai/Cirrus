#import "NavigationTableViewSection.h"

@interface NavigationTableViewSection ()

@property (strong, nonatomic, nonnull, readwrite) NSArray<NavigationTableViewCell *> * cells;
@property (strong, nonatomic, nonnull, readwrite) NSString * title;

@end

@implementation NavigationTableViewSection

+ (instancetype) sectionWithTitle:(NSString *)title cells:(NSArray<NavigationTableViewCell *> *)cells {
    NavigationTableViewSection * section = [NavigationTableViewSection new];
    section.title = title;
    section.cells = cells;
    return section;
}

@end
