//
//  KDStatusContainerView.h
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDUserAvatarView.h"
#import "KDStatusContentView.h"
#import "KDThumbnailView2.h"

@class KDStatus;

@interface KDStatusContainerView : UIView {
 @private
    KDStatus *status_;
    
    KDUserAvatarView *avatarView_;
    KDStatusContentView *contentView_;
    UIView *dividerView_;
}

@property(nonatomic, retain) KDStatus *status;

@property(nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property(nonatomic, retain, readonly) KDStatusContentView *contentView;
@property(nonatomic, retain, readonly) KDThumbnailView2 *thumbnailView;
@property(nonatomic, retain) UIView *dividerView;

- (void)update;
- (void)setDividerWithImage:(UIImage *)image;

@end
