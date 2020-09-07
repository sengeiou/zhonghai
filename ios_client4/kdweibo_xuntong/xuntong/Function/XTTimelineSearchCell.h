//
//  XTTimelineSearchCell.h
//  kdweibo
//
//  Created by Gil on 15/1/12.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTTimelineCell.h"
#import "XTGroupHeaderImageView.h"
#import "RTLabel.h"

@class GroupDataModel;
@class XTUnreadImageView;
@interface XTTimelineSearchCell : KDTableViewCell

@property (nonatomic, strong, readonly) XTGroupHeaderImageView *headerImageView;
@property (nonatomic, strong, readonly) XTUnreadImageView *unreadImageView;

@property (nonatomic, strong, readonly) RTLabel *nameLabel;
@property (nonatomic, strong, readonly) RTLabel *messageLabel;
@property (nonatomic, strong, readonly) UIImageView *separateLineImageView;

@property (nonatomic, strong) GroupDataModel *group;

@end
