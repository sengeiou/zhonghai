//
//  KDMessageRemoteSettingTableViewCell.h
//  kdweibo
//
//  Created by liwenbo on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

typedef enum : NSUInteger {
    kMessageRemoteSettingCellTypeNone = -1,
    kMessageRemoteSettingCellTypeSwitch = 1,
    kMessageRemoteSettingCellTypeBeginTime,
    kMessageRemoteSettingCellTypeEndTime,
} kMessageRemoteSettingCellType;


@protocol KDMessageRemoteSettingTableViewCellDelegate <NSObject>

- (void)disturbTimeButtonClick:(kMessageRemoteSettingCellType)type;

- (void)setupDisturbModel:(BOOL)isDoNotDisturbModel;

@end



@interface KDMessageRemoteSettingTableViewCell : KDTableViewCell

@property (nonatomic, assign, readonly) kMessageRemoteSettingCellType type;

@property (nonatomic, strong) UISwitch *modelSwitch;

@property (nonatomic, strong) UIButton *timeButton;

@property (nonatomic, strong) UIButton *overlayButton;

@property (nonatomic, weak) id<KDMessageRemoteSettingTableViewCellDelegate>delegate;

@property (nonatomic, assign) BOOL canClickSwitch;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Type:(kMessageRemoteSettingCellType)type;


@end





