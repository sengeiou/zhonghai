//
//  KDCommentStatus.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDStatus.h"

typedef enum {
    KDCommentStateUnsend = 1 << 1,
    KDCommentStateSending = 1 << 2,
    KDCommentStatePlaying = 1 << 3,
    KDCommentStateSended = 1 << 4
}KDCommentState;

// comment status
@interface KDCommentStatus : KDStatus

@property(nonatomic, retain) NSString *replyCommentText; //被回复的评论的原文
@property(nonatomic, retain) KDStatus *status; //属于哪个status
/*
 add for task detail
 */
@property(nonatomic, copy) NSString *timestamp;
@property(nonatomic, assign) KDCommentState messageState;
@end
