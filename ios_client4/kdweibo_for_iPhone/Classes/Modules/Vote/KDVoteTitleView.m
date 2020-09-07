//
//  KDVoteTitleView.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/30/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteTitleView.h"

@implementation KDVoteTitleView
@synthesize voteCount = _voteCount;
@synthesize deadline = _deadline;
@synthesize voteTpye = _voteTpye;
@synthesize voteDetail = _voteDetail;

-(void)dealloc
{
    KD_RELEASE_SAFELY(_voteCount);
    KD_RELEASE_SAFELY(_deadline);
    KD_RELEASE_SAFELY(_voteTpye);
    KD_RELEASE_SAFELY(_voteDetail);

    [super dealloc];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.voteDetail = [[[KDUsersURLView alloc]
                            initWithFontSize:14
                            width:209 
                            delegate:self] autorelease];
        [self addSubview:self.voteDetail];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.voteDetail layoutUsersUrlViewWith:@"mmmm#asdkgjasd#mmmmj" userName:@"guohuan" userId:@"skk"];
    [self.voteDetail setFrame:CGRectMake(95, 15, 209, 40)];

    
}

@end
