//
//  KDDMSelectedUserCell.m
//  kdweibo
//
//  Created by Tan yingqi on 12-11-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDDMSelectedUserCell.h"

@implementation KDDMSelectedUserCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = super.contentView.bounds;
    rect.origin.y = rect.size.height - super.avatarView.frame.size.height;
    rect.size = super.avatarView.frame.size;
    super.avatarView.frame = rect;
    
    super.nameLabel.hidden = YES;
    super.departmentLabel.hidden = YES;
    super.separatorView.hidden = YES;
}

@end
