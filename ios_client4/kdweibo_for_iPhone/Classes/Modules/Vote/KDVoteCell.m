//
//  KDVoteCell.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteCell.h"

@implementation KDVoteCell
@synthesize selectStatue = _selectStatue;
@synthesize voteDetail = _voteDetail; 
@synthesize voteBarBg = _voteBarBg;
@synthesize voteBar = _voteBar;
@synthesize voteCountPesent = _voteCountPesent;
@synthesize voteCountPesentBg = _voteCountPesentBg;

-(void)dealloc
{
    [_selectStatue release];
    [_voteDetail release];
    [_voteBarBg release];
    [_voteBar release];
    [_voteCountPesent release];
    [_voteCountPesentBg release];
    
    [super  dealloc];
}

-(void)drawRect:(CGRect)rect
{
    UIImage * voteCountPesentBgImage  = [[UIImage imageNamed:@"votePesentBg.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.voteCountPesentBg setImage:voteCountPesentBgImage];
    
    UIImage * voteBarBgImage  = [[UIImage imageNamed:@"BarBg.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    [self.voteBarBg setImage:voteBarBgImage];
    
    UIImage * voteBarImage  = [[UIImage imageNamed:@"Bar.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    [self.voteBar setImage:voteBarImage];
    [self.voteBar setWidth:80];

}

@end
