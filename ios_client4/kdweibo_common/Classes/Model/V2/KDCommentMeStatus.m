//
//  KDCommentMeStatus.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDCommentMeStatus.h"

@implementation KDCommentMeStatus


@synthesize replyStatusText=replyStatusText_;
@synthesize replyCommentText=replyCommentText_;
@synthesize status = status_;
- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(replyStatusText_);
    //KD_RELEASE_SAFELY(replyCommentText_);
    //KD_RELEASE_SAFELY(status_);
    //[super dealloc];
}

@end
