//
//  KDTimelineStatusCell.h
//  kdweibo
//
//  Created by laijiandong on 12-9-27.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatus.h"
#import "KDStatusContainerView.h"
#import "KDUserAvatarView.h"

@interface KDTimelineStatusCell : UITableViewCell {
 @private
    KDStatusContainerView *containerView_;
}

@property(nonatomic, retain) KDStatus *status;
@property(nonatomic, retain, readonly) KDStatusContainerView *containerView;
@property(nonatomic, retain, readonly) KDUserAvatarView *avatarView;

@end
