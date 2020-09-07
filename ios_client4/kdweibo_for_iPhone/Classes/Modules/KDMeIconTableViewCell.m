//
//  KDMeIconTableViewCell.m
//  kdweibo
//
//  Created by DarrenZheng on 14-10-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDMeIconTableViewCell.h"

@interface KDMeIconTableViewCell ()

@property (nonatomic, strong) UIImageView *imageViewAdmin;
@property (nonatomic, strong) UILabel *labelAdmin;

@end

@implementation KDMeIconTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.imageViewIcon];
        [self.contentView addSubview:self.labelTitle];
        [self.contentView addSubview:self.labelSubTitle];
        [self.contentView addSubview:self.imageViewAdmin];
        [self.contentView addSubview:self.labelAdmin];
    }
    return self;
}

- (UIImageView *)imageViewIcon
{
    if (!_imageViewIcon)
    {
        _imageViewIcon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 14, 90-14*2, 90-14*2)];
        _imageViewIcon.backgroundColor = [UIColor redColor];
        _imageViewIcon.layer.cornerRadius = 3;
        _imageViewIcon.clipsToBounds = YES;
    }
    return _imageViewIcon;
}


- (UIImageView *)imageViewAdmin
{
    if (!_imageViewAdmin)
    {
        _imageViewAdmin = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.labelTitle.frame) + 10 , 22, 200, 25)];
        _imageViewAdmin.image = [UIImage imageNamed:@"college_img_gly"];
        [_imageViewAdmin sizeToFit];
        _imageViewAdmin.hidden = YES;
    }
    return _imageViewAdmin;
}

- (UILabel *)labelAdmin
{
    if (!_labelAdmin)
    {
        _labelAdmin = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.labelTitle.frame) + 10 , 18, 50, 25)];
        _labelAdmin.backgroundColor = [UIColor clearColor];
        _labelAdmin.font = [UIFont systemFontOfSize:10];
        _labelAdmin.text = ASLocalizedString(@"KDMeIconTableViewCell_admin");
        _labelAdmin.textColor = [UIColor whiteColor];
        _labelAdmin.hidden = YES;

    }
    return _labelAdmin;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(6 + 90-12*2 + 16, 22, 120, 25)];
        _labelTitle.backgroundColor = [UIColor whiteColor];
        _labelTitle.font = [UIFont systemFontOfSize:16];
    }
    return _labelTitle;
}

- (UILabel *)labelSubTitle
{
    if (!_labelSubTitle)
    {
        _labelSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(6 + 90-12*2 + 16, 18 + 25 + 5, 200, 20)];
        _labelSubTitle.backgroundColor = [UIColor clearColor];
        _labelSubTitle.font = [UIFont systemFontOfSize:14];
        _labelSubTitle.textColor = MESSAGE_NAME_COLOR;
    }
    return _labelSubTitle;
}

- (void)setBAdmin:(BOOL)bAdmin
{
    _bAdmin = bAdmin;
    
    if (bAdmin)
    {
        [_labelTitle sizeToFit];
        _labelAdmin.hidden = NO;
        _imageViewAdmin.hidden = NO;
        
        SetX(_imageViewAdmin.frame, CGRectGetMaxX(self.labelTitle.frame) + 8);
        SetX(_labelAdmin.frame, CGRectGetMaxX(self.labelTitle.frame) + 12);
    }
    else
    {
        _labelAdmin.hidden = YES;
        _imageViewAdmin.hidden = YES;
    }
}


@end


