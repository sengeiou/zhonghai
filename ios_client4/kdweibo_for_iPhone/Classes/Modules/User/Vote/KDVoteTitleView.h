//
//  KDVoteTitleView.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/30/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "KDUsersURLView.h"
#import "KDVote.h"
#import "KDTimeLineDetailURLViewHandle.h"
#define MAX_VOTE_DETAIL_LAB_HEIGHT 40
#define MAX_VOTE_DETAIL_LAB_WIDTH  ScreenFullWidth-85-12
#define MAX_VOTE_DETAIL_LAB_FONT   15
#define MAX_VOTE_DETAIL_LAB_LINE    2

#define VOTE_COUNT_BG_WIDTH  63.0f

#define VOTE_DETAIL_LEFT 95.0f
#define VOTE_DETAIL_TOP  18.0f
#define DEAD_TIME_TOP_GAP 5.0f

@interface KDVoteTitleView : UIView<DSURLViewDelegate>

@property(nonatomic, retain) KDVote *vote;

@end
