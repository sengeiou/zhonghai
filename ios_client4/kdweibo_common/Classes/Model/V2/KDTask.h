//
//  KDTask.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-3.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDUser.h"
@interface KDTask : NSObject
@property(nonatomic,copy)NSString *taskNewId;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,retain)NSArray *executors;
@property(nonatomic,retain)NSDate *needFinishDate;
@property(nonatomic,retain)NSDate *createDate;
@property(nonatomic,retain)NSDate *finishDate;
@property(nonatomic,copy)NSString *visibility;
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,copy)NSString *groupName;
@property(nonatomic,retain)KDUser *creator;
@property(nonatomic,retain)KDUser *finishUser;
@property(nonatomic,retain)NSString *statusId; //对应的weibo id
@property(nonatomic,retain)NSString *threadId; //原短邮id
@property(nonatomic, assign)BOOL hasViewDetailPermission ; //是否有查看原信息的权限
@property(nonatomic,retain)NSString *microblogId;//原微博id
@property(nonatomic,retain)NSString *commentId;//原评论id
@property(nonatomic,retain)NSString *messageId;//原短邮id
@property(nonatomic,assign)BOOL isCurrentUserFinish;
@property(nonatomic,assign)NSInteger state;
@property(nonatomic,assign)BOOL isOver;
//@property(nonatomic,retain)
- (BOOL)canCheckOrigin;
@end
