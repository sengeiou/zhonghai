//
//  KDTask.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-3.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTask.h"

@implementation KDTask
@synthesize taskNewId = taskNewId_;
@synthesize content = content_;
@synthesize executors = executors_;
@synthesize needFinishDate = needFinishDate_;
@synthesize finishDate = finishDate_;
@synthesize createDate = createDate_;
@synthesize visibility = visibility_;

@synthesize groupId = groupId_;
@synthesize groupName = groupName_;
@synthesize creator = creator_;
@synthesize finishUser = finishUser_;
@synthesize statusId = statusId_;
@synthesize threadId = threadId_;
@synthesize microblogId = microblogId_;
@synthesize commentId = commentId_;
@synthesize messageId = messageId_;
@synthesize isCurrentUserFinish = isCurrentUserFinish_;
@synthesize hasViewDetailPermission = hasViewDetailPermission_;
@synthesize isOver = isOver;
@synthesize state = state_;

-(void)dealloc {
    //KD_RELEASE_SAFELY(taskNewId_);
    //KD_RELEASE_SAFELY(content_);
    //KD_RELEASE_SAFELY(executors_);
    //KD_RELEASE_SAFELY(needFinishDate_);
    //KD_RELEASE_SAFELY(createDate_);
    //KD_RELEASE_SAFELY(finishDate_);
    //KD_RELEASE_SAFELY(visibility_);
    //KD_RELEASE_SAFELY(groupId_);
    //KD_RELEASE_SAFELY(groupName_);
    //KD_RELEASE_SAFELY(creator_);
    //KD_RELEASE_SAFELY(finishUser_);
    //KD_RELEASE_SAFELY(statusId_);
    //KD_RELEASE_SAFELY(microblogId_);
    //KD_RELEASE_SAFELY(commentId_);
    //KD_RELEASE_SAFELY(messageId_);
    //KD_RELEASE_SAFELY(threadId_);
    //[super dealloc];
}

- (BOOL)canCheckOrigin {
    return hasViewDetailPermission_ && (microblogId_ ||commentId_  || messageId_);
}
@end