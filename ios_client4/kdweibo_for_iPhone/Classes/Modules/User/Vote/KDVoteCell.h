//
//  KDVoteCell.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "KDVoteProcessView.h"
#import "KDVoteCellData.h"

#define VOTE_DETAIL_MAX_HEIGHT 200

#define TEST_TEXT @"SDJGFLSDJGLSJDGLKhjdjhfdhgfjhfhfhfjhfjhgfjhgfjhgfhjgfhjgfhjgfhjfhSJDFLWOEIJUOWIEOSKJDLFKJSLDJ"


@interface KDVoteCell : UITableViewCell

@property(retain,nonatomic)  UIImageView * selectStatus;
@property(retain,nonatomic)  UILabel *voteDetail;
@property(retain,nonatomic)  UIImageView  *bottomSeparator;
@property(retain,nonatomic) KDVoteProcessView *voteProcessView;
@property(retain,nonatomic) KDVoteCellData *voteCellData;


@end
