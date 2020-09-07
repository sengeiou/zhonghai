//
//  KDTimelineStatusCell.h
//  kdweibo
//
//  Created by Tan yingqi on 12-11-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KWStatus.h"
#import "KWIAvatarV.h"
#import "KDStatusView.h"

@interface KDTimelineStatusCell : UITableViewCell 

@property(nonatomic, retain) KWStatus *status;
@property(nonatomic, retain) KWIAvatarV *avatarView;
@property(nonatomic, retain) KDLayouterFatherView *statusView;

@end
