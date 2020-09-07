//
//  KDWifiCell.m
//  kdweibo
//
//  Created by lichao_liu on 1/27/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDWifiCell.h"

@interface KDWifiCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *crookView;
@property (nonatomic, strong) UIView      *externView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *detailTitleLabel;
@end

@implementation KDWifiCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _leftImageView.image = [UIImage imageNamed:@"signinWifi"];
        [self.contentView addSubview:_leftImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        
        _detailTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailTitleLabel.backgroundColor = [UIColor clearColor];
        _detailTitleLabel.font = [UIFont systemFontOfSize:11];
        _detailTitleLabel.textColor = [UIColor grayColor];
        _detailTitleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_detailTitleLabel];
        _detailTitleLabel.hidden = YES;
        
        _crookView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_crookView sizeToFit];
//        [self.contentView addSubview:_crookView];
        
        _externView = [[UIView alloc] initWithFrame:CGRectZero];
        _externView.backgroundColor = MESSAGE_LINE_COLOR;
        [self.contentView addSubview:_externView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        super.contentView.backgroundColor = MESSAGE_CT_COLOR;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _leftImageView.frame = CGRectMake(10, 10, 30, 30);
    _titleLabel.frame = CGRectMake(43, 7, 230, 30);
    _detailTitleLabel.frame = CGRectMake(43, 30, 200, 15);
    _crookView.frame = CGRectMake(CGRectGetWidth(self.frame)- 23- 20, 13.5, 23, 23);
    _externView.frame = CGRectMake(0, 49.5, CGRectGetWidth(self.frame), 0.5);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    
    
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.contentView.backgroundColor = highlighted?[UIColor colorWithRed:26/255.0 green:133/255.0 blue:1.0 alpha:1.0f]:[UIColor clearColor];
    _titleLabel.highlighted = highlighted;
}
- (void)hideCrookView:(BOOL)hidden{
    [_crookView setHidden:hidden];
}
- (void)setIsSelected:(BOOL)selected
{
//    if (selected)
//        [_crookView setImage:[UIImage imageNamed:@"task_checkbox_selected"]];
//    else
//        [_crookView setImage:[UIImage imageNamed:@"task_checkbox_unselected"]];
}

- (void)setWifiSsidStr:(NSString *)wifiSsidStr
{
    self.titleLabel.text = wifiSsidStr;
}

- (void)setWifiBssid:(NSString *)wifiBssid
{
    if(wifiBssid && wifiBssid.length>0)
    {
    self.detailTitleLabel.hidden = NO;
    self.detailTitleLabel.text = wifiBssid;
    }else{
        self.detailTitleLabel.hidden = YES;
        self.detailTitleLabel.text = @"";
    }
}
@end
