//
//  KDCommentMeStatus.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDStatus.h"

@interface KDCommentMeStatus : KDStatus

@property(nonatomic, retain) NSString *replyStatusText;
@property(nonatomic, retain) NSString *replyCommentText;
@property(nonatomic, retain) KDStatus *status;
@end
