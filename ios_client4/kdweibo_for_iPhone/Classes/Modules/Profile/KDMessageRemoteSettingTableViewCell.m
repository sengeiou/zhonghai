//
//  KDMessageRemoteSettingTableViewCell.m
//  kdweibo
//
//  Created by liwenbo on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMessageRemoteSettingTableViewCell.h"
#import "XTSetting.h"
//#import "KDSearchHelper.h"

@interface KDMessageRemoteSettingTableViewCell()


@property (nonatomic, assign) kMessageRemoteSettingCellType type;
@end


@implementation KDMessageRemoteSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Type:(kMessageRemoteSettingCellType)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self setupViews:type];
        
    }
    return self;

}


- (void)setupViews:(kMessageRemoteSettingCellType)type
{
    self.type = type;
    
    switch (type) {
        case kMessageRemoteSettingCellTypeNone:
        {
            
        }
            break;
        case kMessageRemoteSettingCellTypeSwitch:
        {
            [self.contentView addSubview:self.modelSwitch];
            [_modelSwitch makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_modelSwitch.superview.right).with.offset(- [NSNumber kdDistance1]);
                make.centerY.equalTo(_modelSwitch.superview.centerY);
                make.width.mas_equalTo(50);
            }];
            [self.contentView addSubview:self.overlayButton];
            [_overlayButton makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_overlayButton.superview.right).with.offset(- [NSNumber kdDistance1]);
                make.centerY.equalTo(_overlayButton.superview.centerY);
                make.width.mas_equalTo(50);
                make.height.mas_equalTo(44);
            }];
        }
            break;
        case kMessageRemoteSettingCellTypeBeginTime:
        case kMessageRemoteSettingCellTypeEndTime:
        {
            [self.contentView addSubview:self.timeButton];
            [_timeButton makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_timeButton.superview.right).with.offset(- [NSNumber kdDistance1]);
                make.centerY.equalTo(_timeButton.superview.centerY);
                make.width.mas_equalTo(80);
                make.height.mas_equalTo(44);
            }];
        }
            break;
        default:
            break;
    }
}




- (void)setCanClickSwitch:(BOOL)canClickSwitch
{
    _canClickSwitch = canClickSwitch;
    if (_canClickSwitch)
    {
        [self.overlayButton removeFromSuperview];
    }
    else
    {
        [self.contentView addSubview:self.overlayButton];
    }
}


- (UISwitch *)modelSwitch
{
    if (!_modelSwitch)
    {
        _modelSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_modelSwitch setOnTintColor:[UIColor colorWithRGB:0x3BB9FF]];
        [_modelSwitch addTarget:self action:@selector(switchChangeValueAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _modelSwitch;
}


- (void)switchChangeValueAction:(UISwitch *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setupDisturbModel:)])
    {
        [self.delegate setupDisturbModel:sender.on];
    }

}


- (UIButton *)timeButton
{
    if (!_timeButton)
    {
        _timeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_timeButton addTarget:self action:@selector(timeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_timeButton.titleLabel setFont:FS4];
        [_timeButton setTitleColor:FC2 forState:UIControlStateNormal];
        
        _timeButton.backgroundColor = [UIColor clearColor];
        
    }
    return _timeButton;
}

- (UIButton *)overlayButton
{    
    if (!_overlayButton)
    {
        _overlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _overlayButton.backgroundColor = [UIColor clearColor];
        [_overlayButton addTarget:self action:@selector(overlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _overlayButton;
}

- (void)overlayButtonClick:(UIButton *)sender
{
    if (self.canClickSwitch)
    {
        [self.modelSwitch setOn:!self.modelSwitch.on animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDMessageRemoteSettingTableViewCell_allow_noti") delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:nil, nil];
        [alert show];
    }
}



- (void)timeButtonClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(disturbTimeButtonClick:)])
    {
        [self.delegate disturbTimeButtonClick:self.type];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
