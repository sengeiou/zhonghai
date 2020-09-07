//
//  KDGetCellHeight.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/9/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDGetCellHeight.h"
#import "UIViewAdditions.h"

#define  VOTE_CELL_DETAIL_BOTTOM_PADDING 30
static KDVoteCell *voteCell = nil;

@implementation KDGetCellHeight

//get vote detail cell height
+(CGFloat)getVoteCellHeightWithText:(NSString *)text isIncludProcessView:(BOOL)isIncludProcessView
{
    if (voteCell == nil) {
        voteCell = [[KDVoteCell alloc]init];
    }
    UILabel *detailLab = voteCell.voteDetail;
    [detailLab setText:text];
    CGFloat cellDetailLabHeight =[CommenMethod getHeightByLableWithMaxHeight:VOTE_DETAIL_MAX_HEIGHT lable:detailLab];
    if (isIncludProcessView) {
        return cellDetailLabHeight+detailLab.top+voteCell.voteProcessView.frame.size.height;
    }
    return MAX(cellDetailLabHeight+VOTE_CELL_DETAIL_BOTTOM_PADDING, 50.0f);
}

@end
