//
//  KDBageImageView.h
//  kdweibo
//
//  Created by 王 松 on 13-11-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDDMThreadAvatarView.h"

typedef enum {
    KDBadgeViewAlignmentTopLeft,
    KDBadgeViewAlignmentTopRight,
    KDBadgeViewAlignmentTopCenter,
    KDBadgeViewAlignmentCenterLeft,
    KDBadgeViewAlignmentCenterRight,
    KDBadgeViewAlignmentBottomLeft,
    KDBadgeViewAlignmentBottomRight,
    KDBadgeViewAlignmentBottomCenter,
    KDBadgeViewAlignmentCenter
} KDBadgeViewAlignment;

@interface KDBadgeImageView : UIView


/**
 *  iconImageView, imageView只可能一个有值
 *  iconImageView 用于 企业邮箱，收件箱，小组的显示
 *  imageView 用于短邮的显示
 */
@property (nonatomic, retain, readonly) UIImageView *iconImageView;

@property (nonatomic, retain, readonly) KDDMThreadAvatarView *imageView;

@property (nonatomic, assign) NSInteger badgeValue;

@property (nonatomic, assign) KDBadgeViewAlignment badgeAlignment;

@property (nonatomic, retain) KDDMThread *dmThread;

@property (nonatomic, retain) KDInbox    *dmInbox;

@property (nonatomic, assign) BOOL loadingAvatars;

@property (nonatomic, assign, readonly) BOOL hasUnloadAvatars;

@end
