//
//  KDVoteViewLayoutInfo.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/13/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteViewLayoutInfo.h"

@implementation KDVoteViewLayoutInfo
@synthesize tableViewHeadTitle = tableViewHeadTitle_;
@synthesize isShowVotePercent = isShowVotePercent_;
@synthesize isEditing = isEdit_;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(tableViewHeadTitle_);
    //[super dealloc];
}

@end
