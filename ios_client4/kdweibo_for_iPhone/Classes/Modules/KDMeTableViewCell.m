//
//  KDMeTableViewCell.m
//  kdweibo
//
//  Created by DarrenZheng on 14-10-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDMeTableViewCell.h"

@interface KDMeTableViewCell ()

@end

@implementation KDMeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.imageViewIcon];
        [self.contentView addSubview:self.labelTitle];
    }
    return self;
}
- (UIImageView *)imageViewIcon
{
    if (!_imageViewIcon)
    {
        _imageViewIcon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 12, 45-12*2, 45-12*2)];
        _imageViewIcon.backgroundColor = [UIColor clearColor];
        _imageViewIcon.contentMode = UIViewContentModeCenter;
    }
    return _imageViewIcon;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(16 + 45-12*2 - 5 + 16, 12, 200, 45-12*2)];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.font = [UIFont systemFontOfSize:16];
    }
    return _labelTitle;
}

@end
