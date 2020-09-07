//
//  KDAutoWifiSignInSettingCell.m
//  kdweibo
//
//  Created by lichao_liu on 1/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAutoWifiSignInSettingCell.h"
#import "UIView+Blur.h"
#import "KDAutoWifiSignInDataManager.h"
#import "NSDate+Additions.h"

#define KDOnWorkTipStr  ASLocalizedString(@"以上时间范围内第一次进入签到点WIFI区域，系统会自动签到一次，视为上班。")
#define KDOffWorkTipStr  ASLocalizedString(@"用户离开或进入签到点WIFI区域都会自动签到，但为了不给你带来困扰，系统会自动签到前三次，其他时间请手动签到。")
@interface KDAutoWifiSignInSettingCell()
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *toLabel;
@end

@implementation KDAutoWifiSignInSettingCell

+ (CGFloat)cellHeightForAutoWifiSignInSettingCellType:(KDAutoSignInSettingCellType)type
{
    switch (type) {
        case KDAutoSignInSettingCellType_offWork:
        {
           return  [KDAutoWifiSignInSettingCell cellHeightByString:KDOffWorkTipStr];
        }
            break;
        case KDAutoSignInSettingCellType_onWork:
        {
            return [KDAutoWifiSignInSettingCell cellHeightByString:KDOnWorkTipStr];
        }
            break;
        default:
            break;
    }
    return 0;
}

+ (CGFloat)cellHeightByString:(NSString *)str
{
    CGSize expectedLabelSize = [str sizeWithFont:[UIFont systemFontOfSize:14]
                                  constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20 -50 ,9999.f)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    return expectedLabelSize.height+ 120;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    self.backgroundColor = MESSAGE_CT_COLOR;
    self.titleLabel = [self getLabel];
    [self.contentView addSubview:self.titleLabel];
    
    self.fromLabel = [self getLabel];
    self.fromLabel.text = ASLocalizedString(@"从");
    [self.contentView addSubview:self.fromLabel];
    
    self.toLabel = [self getLabel];
    self.toLabel.text = ASLocalizedString(@"至");
    [self.contentView addSubview:self.toLabel];
    
    self.fromWorkTimeBtn = [self getButton];
     [self.contentView addSubview:self.fromWorkTimeBtn];
        self.fromWorkTimeBtn.tag = KDAutoSignInSettingCellBtnTag_fromBtn;
    [self.fromWorkTimeBtn addTarget:self action:@selector(whenWorkTimeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toWorkTimeBtn = [self getButton];
    self.toWorkTimeBtn.tag = KDAutoSignInSettingCellBtnTag_toBtn;
     [self.toWorkTimeBtn addTarget:self action:@selector(whenWorkTimeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.toWorkTimeBtn];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipLabel.numberOfLines = 0;
    _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tipLabel.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:_tipLabel];

    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)whenWorkTimeBtnClicked:(UIButton *)sender
{
    if(self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(whenTimeBtnClickedWithType:isFromTime:)])
    {
        [self.cellDelegate whenTimeBtnClickedWithType:self.autoSignInSettingCellType isFromTime:sender.tag == KDAutoSignInSettingCellBtnTag_fromBtn ? YES : NO];
    }
}


- (UILabel *)getLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (UIButton *)getButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:RGBACOLOR(23, 131, 253, 1.0f) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    return button;
}


- (void)layoutSubviews {
    [super layoutSubviews];
     CGFloat selfWidth = CGRectGetWidth(self.bounds);
    
    self.titleLabel.frame = CGRectMake(10, 10, 40, 24);
    self.fromLabel.frame = CGRectMake(15, 45, 50, 40);
    self.fromWorkTimeBtn.frame = CGRectMake(0, 45, CGRectGetWidth(self.frame), 40);
    
    self.toLabel.frame = CGRectMake(15, 85, 50, 40);
    self.toWorkTimeBtn.frame = CGRectMake(0, 85, CGRectGetWidth(self.frame), 40);
    
     _tipLabel.frame = CGRectMake(10, CGRectGetMaxY(self.toWorkTimeBtn.frame) + 10, selfWidth - 20, CGRectGetHeight(_tipLabel.frame));
    [_tipLabel sizeToFit];
 }

- (void)setAutoSignInSettingCellType:(KDAutoSignInSettingCellType)autoSignInSettingCellType
{
    _autoSignInSettingCellType = autoSignInSettingCellType;
    NSMutableAttributedString *attributedString = nil;
    KDAutoWifiSignInDataManager *manager = [KDAutoWifiSignInDataManager sharedAutoWifiSignInDataMananger];
    switch (autoSignInSettingCellType) {
        case KDAutoSignInSettingCellType_offWork:
        {
            self.titleLabel.text = ASLocalizedString(@"下班");
           
            [self.fromWorkTimeBtn setTitle:[self timeStringHHMMAForDate:manager.fromOffWorkTime] forState:UIControlStateNormal];
            [self.toWorkTimeBtn  setTitle:[self timeStringHHMMAForDate:manager.toOffWorkTime] forState:UIControlStateNormal];
             attributedString = [[NSMutableAttributedString alloc] initWithString:KDOffWorkTipStr];
            [attributedString addAttributes:@{NSForegroundColorAttributeName:RGBACOLOR(147, 147, 147,1),NSFontAttributeName :[UIFont systemFontOfSize:13.f]} range:NSMakeRange(0, attributedString.length)];
             [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[KDOffWorkTipStr rangeOfString:ASLocalizedString(@"前三次")]];
            [self.tipLabel setAttributedText:attributedString];
        }
            break;
        case KDAutoSignInSettingCellType_onWork:
        {
            self.titleLabel.text = ASLocalizedString(@"上班");
            [self.fromWorkTimeBtn setTitle:[self timeStringHHMMAForDate:[manager fromOnWorkTime]] forState:UIControlStateNormal];
            [self.toWorkTimeBtn  setTitle:[self timeStringHHMMAForDate:[manager toOnWorkTime]] forState:UIControlStateNormal];
             attributedString = [[NSMutableAttributedString alloc] initWithString:KDOnWorkTipStr];
            [attributedString addAttributes:@{NSForegroundColorAttributeName:RGBACOLOR(147, 147, 147,1),NSFontAttributeName :[UIFont systemFontOfSize:13.f]} range:NSMakeRange(0, attributedString.length)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(KDOnWorkTipStr.length - 8, 2)];
            [self.tipLabel setAttributedText:attributedString];
        }
            break;
        default:
            break;
    }
}

- (NSString *)timeStringHHMMAForDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"HH:mm"];
    
    //获取系统是24小时制或者12小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    //hasAMPM==TURE为12小时制，否则为24小时制
    if(hasAMPM)
    {
      [formatter setDateFormat:@"h:mm a"];
      formatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }

    NSString *ampm = [formatter stringFromDate:date];
    return ampm;
}
@end
