//
//  KDUserBasicProfileView.h
//  kdweibo
//
//  Created by laijiandong on 12-10-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDUser.h"
#import "KDUserAvatarView.h"

@class KDUserAvatarView;

@interface KDUserBasicProfileView : UIView {
 @private
    KDUser *user_;
    
    UIImageView *backgroundImageView_;
    
    KDUserAvatarView *avatarView_;
    
    UILabel *screenNameLabel_;
    UILabel *departmentLabel_;
    UILabel *jobTitleLabel_;
    
	UIView *rightView_;
    
    BOOL usingRightViewBounds_; // if this value is set true and then the rightSideWidthInPercent_ was disabled (default: NO)
    CGFloat rightSideWidthInPercent_; // the width of right view (default: 0.0 and the range is [0.0, 1.0])
    
    BOOL isDetail_;
}

@property(nonatomic, retain) KDUser *user;

@property(nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property(nonatomic, retain) UIView *rightView;

@property(nonatomic, assign) BOOL usingRightViewBounds;
@property(nonatomic, assign) BOOL isDetail;
@property(nonatomic, assign) CGFloat rightSideWidthInPercent;

- (void)update;

- (void)setBackgroundImage:(UIImage *)image;

@end
