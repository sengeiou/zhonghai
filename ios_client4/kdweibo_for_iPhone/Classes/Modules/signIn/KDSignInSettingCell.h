//
//  KDSignInSettingCell.h
//  kdweibo
//
//  Created by Tan yingqi on 13-8-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTextField.h"

typedef void(^SwitchDidClickedBlock)(void);
typedef void(^ButtonDidClickedBlock)(void);
@class KDV8CellContentView;
@interface KDSignInSettingCell : KDTableViewCell

@property (nonatomic, strong) KDV8CellContentView           *kd_contentView;
@property (nonatomic, strong) UIButton                      *markImageBtn;
@property (nonatomic, assign) BOOL                          isShowMarkImageBtn;
@property (nonatomic, strong) UISwitch                      *accessorySwitch;
@property (nonatomic, strong) SwitchDidClickedBlock         switchDidClickedBlock;
@property (nonatomic, strong) ButtonDidClickedBlock         buttonDidClickedBlock;
@property (nonatomic, strong) UIButton                      *accessoryButton;
@property (nonatomic, strong) KDTextField                   *accessoryTextField;

//为cell添加红色New标记
- (void)addMarkImageBtn;

//为cell添加开关
- (void)addAccessorySwitch;
- (void)setSwitchStatus:(BOOL)status;

//为cell添加按钮
- (void)addButton;

//为cell添加输入框
- (void)addTextField;

@end
