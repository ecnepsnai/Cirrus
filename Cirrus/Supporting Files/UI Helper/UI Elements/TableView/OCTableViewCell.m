#import "OCTableViewCell.h"

@implementation OCTableViewCell

+ (OCTableViewCell *) cellWithCell:(UITableViewCell *)cell {
    OCTableViewCell * fancyCell = [OCTableViewCell new];
    fancyCell.cell = cell;
    fancyCell.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return fancyCell;
}

+ (OCTableViewCell *) cellWithCell:(UITableViewCell *)cell segueIdentifier:(NSString *)identifier {
    OCTableViewCell * fancyCell = [OCTableViewCell new];
    fancyCell.cell = cell;
    fancyCell.segueIdentifier = identifier;
    fancyCell.cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return fancyCell;
}

@end
