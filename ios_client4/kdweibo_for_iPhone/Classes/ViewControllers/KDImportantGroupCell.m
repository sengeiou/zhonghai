//
//  KDImportantGroupCell.m
//  kdweibo
//
//  Created by kyle on 16/5/13.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDImportantGroupCell.h"
#import "XTGroupHeaderImageView.h"
#define HEADER_VIEW_SIDE 48.f

@implementation KDImportantGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(12, (60-40)/2, 40, 40)];
        [self.contentView addSubview:headerView];
        self.headerImageView = [[XTGroupHeaderImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [headerView addSubview:self.headerImageView];
        
        CGRect frame = headerView.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 15.0);
        //姓名或者组名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = FS3;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.nameLabel];
        
        self.extenalSignImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.extenalSignImageView.image = [UIImage imageNamed:@"message_tip_shang"];
        self.extenalSignImageView.hidden = YES;
        self.extenalSignImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.extenalSignImageView];

        self.separatorLineInset = UIEdgeInsetsMake(0, HEADER_VIEW_SIDE + 2 * [NSNumber kdDistance1], 0, 0);
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return self;
}

- (void)setGroup:(GroupDataModel *)group {
    if (_group != group) {
        _group = group;
        [self.headerImageView setGroup:group];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.isExtenal = [_group isExternalGroup];
    self.extenalSignImageView.frame = CGRectMake(12+HEADER_VIEW_SIDE+12, 22, 16, 16);
    self.extenalSignImageView.hidden = _isExtenal ? NO : YES;
    if (self.isExtenal) {
        self.nameLabel.frame = CGRectMake(MaxX(self.extenalSignImageView.frame)+3, 8, ScreenFullWidth - MaxX(self.extenalSignImageView.frame)-15, 44);
    } else {
        self.nameLabel.frame = CGRectMake(12+HEADER_VIEW_SIDE+12, (60-44)/2, ScreenFullWidth-44-12*2, 44);
    }
    
    self.nameLabel.text = self.group.groupName;
}

@end
