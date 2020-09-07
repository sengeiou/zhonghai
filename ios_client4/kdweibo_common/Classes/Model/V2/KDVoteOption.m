//
//  KDVoteOption.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-3.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDVoteOption.h"
#import "KDVote.h"

@implementation KDVoteOption

@synthesize optionId=optionId_;
@synthesize name=name_;
@synthesize count=count_;
@synthesize vote = vote_;
@synthesize percent;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(optionId_);
    //KD_RELEASE_SAFELY(name_);
    //[super dealloc];
}

- (float)percent {
    float result = .0f;
    if (self.vote) {
        NSInteger sum = 0;
        for (KDVoteOption *option in self.vote.voteOptions) {
            sum +=option.count;
        }
        if (sum >0) {
            result = (float)self.count/sum;
        }
    }
    return result;
}

@end
