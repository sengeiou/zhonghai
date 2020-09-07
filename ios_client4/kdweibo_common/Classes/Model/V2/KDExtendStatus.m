//
//  KDExtendStatus.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDExtendStatus.h"

@implementation KDExtendStatus

@synthesize statusId=statusId_;
@synthesize site=site_;
@synthesize content=content_;
@synthesize senderName=senderName_;

@synthesize forwardedSenderName=forwardedSenderName_;
@synthesize forwardedContent=forwardedContent_;

@synthesize createdAt=createdAt_;
@synthesize forwardedAt=forwardedAt_;

@synthesize compositeImageSource=compositeImageSource_;
@synthesize extraSourceMask=extraSourceMask_;

- (id)init {
    self = [super init];
    if (self) {
        extraSourceMask_ = KDExtraSourceMaskNone;
    }
    
    return self;
}

- (BOOL)hasForwarded {
    return forwardedAt_ > 0;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(statusId_);
    //KD_RELEASE_SAFELY(site_);
    //KD_RELEASE_SAFELY(content_);
    //KD_RELEASE_SAFELY(senderName_);
    
    //KD_RELEASE_SAFELY(forwardedContent_);
    //KD_RELEASE_SAFELY(forwardedSenderName_);
    
    //KD_RELEASE_SAFELY(compositeImageSource_);
    
    //[super dealloc];
}

@end
