//
//  KDStatusCounts.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-17.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusCounts.h"

@implementation KDStatusCounts

@synthesize statusId=statusId_;
@synthesize forwardsCount=forwardsCount_;
@synthesize commentsCount=commentsCount_;
@synthesize likedCount = likedCount_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(statusId_);
    
    //[super dealloc];
}

@end
