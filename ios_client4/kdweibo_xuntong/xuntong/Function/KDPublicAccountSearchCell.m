//
//  KDPublicAccountSearchCell.m
//  kdweibo
//
//  Created by Gil on 15/1/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPublicAccountSearchCell.h"
#import "PersonSimpleDataModel.h"

@interface KDPublicAccountSearchCell ()
@property (nonatomic, strong) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong) RTLabel *nameLabel;
@end

@implementation KDPublicAccountSearchCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像
        self.headerImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.headerImageView];
        
        //姓名
        self.nameLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = FS2;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = self.contentView.backgroundColor;
        self.nameLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.nameLabel];
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 68, 0, 0);
    }
    return self;
}

- (void)setPerson:(PersonSimpleDataModel *)person
{
    if (_person != person) {
        _person = person;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //头像
    self.headerImageView.person = self.person;
    self.headerImageView.frame = CGRectMake([NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - 44.0) / 2, 44.0, 44.0);
    
    //姓名
    CGFloat height = 20;
    if (isAboveiOS9) {
        height = 24.0;
    }
    if (self.person.highlightName != nil) {
        self.nameLabel.text = self.person.highlightName;
    } else {
        self.nameLabel.text = self.person.personName;
    }
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerImageView.frame) + [NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - height) / 2, ScreenFullWidth - CGRectGetMaxX(self.headerImageView.frame) - [NSNumber kdDistance1], height);
}

@end
