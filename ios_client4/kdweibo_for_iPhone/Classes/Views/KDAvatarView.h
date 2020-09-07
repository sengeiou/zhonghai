//
//  KDAvatarView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KDAvatarProtocol.h"

@interface KDAvatarView : UIButton {
@protected
    id<KDAvatarDataSource> avatarDataSource_;
    
    UIView *maskView_;
    UIImageView *avatarView_;
    
    UIImageView *vipBadgeView_;
    BOOL showVipBadge_;
    
    BOOL hasAvatar_;
    BOOL loadAvatar_;
}

@property (nonatomic, retain) id<KDAvatarDataSource> avatarDataSource;

@property (nonatomic, retain, readonly) UIView *maskView;
@property (nonatomic, assign) BOOL showVipBadge;

@property (nonatomic, assign, readonly) BOOL hasAvatar;
@property (nonatomic, assign) BOOL loadAvatar;

+ (id)avatarView;

// The sub-classes can override it
- (void)didSetupAvatarView;

// Generally speaking, You can not invoke this mehtod directly, this method will call when avatar did load from
// cache or network
- (void)updateAvatar:(UIImage *)avatar;
- (void)updateVipBadgeWithImage:(UIImage *)image;

- (void)prepareReuse;

// The sub-classes must override it
- (UIImage *)defaultAvatar;

// sub-class must override it
- (void)didChangeAvatarDataSource;

- (void)layoutAvatar;

+ (void)loadImageSourceForTableView:(UITableView *)tableView withAvatarView:(KDAvatarView *)avatarView;
+ (void)loadImageSourceForTableView:(UITableView *)tableView;

@end
