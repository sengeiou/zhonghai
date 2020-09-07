//
//  KDVoteView.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "KDVoteTitleView.h"
#import "KDVoteCell.h"
#import "KDGetCellHeight.h"
#import "KDVoteCellHeadView.h"
//#import "KDVoteHasBeenDelectView.h"
#import "KDVote.h"
#import "KDVoteCellData.h"
#import "KDVoteViewLayoutInfo.h"

#define VOTE_HAS_ENDED ASLocalizedString(@"KDVoteView_Vote_Ending")
#define RESULT_CAN_BE_SEE_ONLY_VOTE_BY_MYSELF ASLocalizedString(@"KDVoteView_Vote_Result")

@protocol KDVoteViewDelegate;
@interface KDVoteView : UIView<UITableViewDelegate,UITableViewDataSource>
@property(assign,nonatomic)id<KDVoteViewDelegate>delegate;
//use this method to reload data to refresh the view
- (void)reloadData;
- (void)disableButtons;

- (void)enableButtons;

@end

@protocol KDVoteViewDelegate <NSObject>

- (KDVote *)kDVoteViewGetVoteData:(KDVoteView *)voteView;
- (void)KDVoteViewRefreshActionWith:(KDVoteView *)voteView;
- (void)KDVoteViewRefreshVoteActionWith:(KDVoteView*)voteView
                        voteItmeIdList:(NSArray *)voteItmeIdList;
@end