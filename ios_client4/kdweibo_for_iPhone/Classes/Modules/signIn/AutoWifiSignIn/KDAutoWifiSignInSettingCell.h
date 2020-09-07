//
//  KDAutoWifiSignInSettingCell.h
//  kdweibo
//
//  Created by lichao_liu on 1/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KDAutoSignInSettingCellType) {
    KDAutoSignInSettingCellType_onWork,
    KDAutoSignInSettingCellType_offWork
};

typedef NS_ENUM(NSInteger, KDAutoSignInSettingCellBtnTag) {
    KDAutoSignInSettingCellBtnTag_fromBtn = 101,
    KDAutoSignInSettingCellBtnTag_toBtn
};

@protocol KDAutoWifiSignInSettingCellDelegate <NSObject>

- (void)whenTimeBtnClickedWithType:(KDAutoSignInSettingCellType)cellType isFromTime:(BOOL)isFromTimeFlag;

@end

@interface KDAutoWifiSignInSettingCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *fromWorkTimeBtn;
@property (nonatomic, strong) UIButton *toWorkTimeBtn;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, assign)KDAutoSignInSettingCellType autoSignInSettingCellType;
@property (nonatomic, assign) id<KDAutoWifiSignInSettingCellDelegate> cellDelegate;
+ (CGFloat)cellHeightForAutoWifiSignInSettingCellType:(KDAutoSignInSettingCellType)type;
@end


