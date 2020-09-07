//
//  KDVoteCellData.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/11/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteCellData.h"

@implementation KDVoteCellData
@synthesize content = content_;
@synthesize voteStatue = voteStatue_;
@synthesize totalCount = totalCount_;
@synthesize thisItemVoteCount = thisItemVoteCount_;
@synthesize isSelectedByMyself = isSelectedByMyself_;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(content_);
    //[super dealloc];
}

@end
