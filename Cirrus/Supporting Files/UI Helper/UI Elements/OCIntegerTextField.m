#import "OCIntegerTextField.h"

@implementation OCIntegerTextField

- (void) awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet * numbers = [NSCharacterSet decimalDigitCharacterSet];
    NSString * newString = [self.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length == 0) {
        return YES;
    }

    return [newString rangeOfCharacterFromSet:numbers].location != NSNotFound && ([string rangeOfCharacterFromSet:numbers].location != NSNotFound || string.length == 0);
}

@end
