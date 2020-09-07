//
//  PersonListCell.h
//  ContactsLite
//
//  Created by kingdee eas on 12-11-14.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTGroupHeaderImageView.h"
#import "SWTableViewCell.h"
#import "GroupDataModel.h"

//typedef NS_ENUM(NSUInteger, XTTimelineCellNotifyType) {
//    XTTimelineCellNotifyTypeDraft, // 草稿
//    XTTimelineCellNotifyTypeAt, // @提及
//};

@class GroupDataModel;
@class XTUnreadImageView;

@interface XTTimelineCell : SWTableViewCell


@property (nonatomic, strong, readonly) XTGroupHeaderImageView *headerImageView;
@property (nonatomic, strong, readonly) XTUnreadImageView *unreadImageView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *imageViewVoice;
@property (nonatomic, strong) UIImageView *imageViewTop;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
//是否应该显示红色未读数
@property (nonatomic, assign) BOOL shouldHideUnreadImage;
// 用途: [有人@你]... [草稿]... , 红色的消息头 added by Darren
@property (nonatomic, strong) UILabel *headerMessageLabel;
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) KDAgoraMultiCallGroupType agoraMultiCallGroupType;


@end
