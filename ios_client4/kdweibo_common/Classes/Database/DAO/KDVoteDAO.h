//
//  KDVoteDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-3.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDVote;
@class KDVoteOption;

@protocol KDVoteDAO <NSObject>
@required

- (void)saveVote:(KDVote *)vote database:(FMDatabase *)fmdb;
- (void)saveVotes:(NSArray *)votes database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;

- (KDVote *)queryVoteWithId:(NSString *)voteId database:(FMDatabase *)fmdb;

- (BOOL)removeVoteWithId:(NSString *)voteId database:(FMDatabase *)fmdb;
- (BOOL)removeAllVotesInDatabase:(FMDatabase *)fmdb;

@end
