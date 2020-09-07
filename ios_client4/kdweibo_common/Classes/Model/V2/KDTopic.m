//
//  KDTopic.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-17.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDTopic.h"
#import "KDStatus.h"

@implementation KDTopic

@synthesize topicId=topicId_;
@synthesize name=name_;
@synthesize internalAd=internalAd_;
@synthesize truncatedName = truncatedName_;
@synthesize isHot=isHot_;
@synthesize isNew=isNew_;

@synthesize latestStatus=latestStatus_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(topicId_);
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(internalAd_);
    
    //KD_RELEASE_SAFELY(latestStatus_);
    //KD_RELEASE_SAFELY(truncatedName_);
    //[super dealloc];
}

@end
