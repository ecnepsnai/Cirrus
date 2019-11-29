#import "DNSRecordTableViewCell.h"
#import "FontAwesome.h"

@implementation DNSRecordTableViewCell

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureForRecord:(CFDNSRecord *)record {
    self.typeView.layer.cornerRadius = 2;
    self.typeView.layer.masksToBounds = YES;
    self.typeLabel.text = record.type;

    if (record.proxiable) {
        self.cloudLabel.textColor = record.proxied ? [UIColor materialOrange] : [UIColor grayColor];
        self.cloudLabel.hidden = NO;
    } else {
        self.cloudLabel.hidden = YES;
    }

    self.nameLabel.text = record.name;
    self.contentLabel.text = record.content;
}

@end
