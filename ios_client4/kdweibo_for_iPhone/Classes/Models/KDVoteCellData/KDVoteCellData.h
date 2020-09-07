//
//  KDVoteCellData.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/11/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommenMethod.h"
enum
{
    VoteCanSelect,
    VoteSelectNow,
    VoteSelected,
    voteCannotSelect
}typedef VoteStatue;

@interface KDVoteCellData : NSObject
@property(nonatomic,retain)NSString * content;
@property(nonatomic,assign)VoteStatue voteStatue;
@property(nonatomic,assign)NSInteger totalCount;
@property(nonatomic,assign)NSInteger thisItemVoteCount;
@property(nonatomic,assign)BOOL isSelectedByMyself;

@end
