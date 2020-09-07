//
//  KDVoteDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-3.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDVoteDAOImpl.h"

#import "KDUser.h"
#import "KDVote.h"
#import "KDVoteOption.h"
#import "KDWeiboDAOManager.h"

@implementation KDVoteDAOImpl

- (void)saveVote:(KDVote *)vote database:(FMDatabase *)fmdb {
    if (vote == nil) return;
    
    BOOL rollback = NO; // ignore it
    [self saveVotes:@[vote] database:fmdb rollback:&rollback];
}

- (void)saveVotes:(NSArray *)votes database:(FMDatabase *)fmdb rollback:(BOOL *)rollback {
    if (votes == nil || [votes count] == 0) return;
    
    NSString *sql = @"REPLACE INTO votes(vote_id, name, author_id, max_vote_item_count,"
                     " participant_count, created_time, closed_time, is_ended, selected_option_ids,"
                     " state,min_vote_item_count,canRevote) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDVote *v in votes) {
        idx = 1;
        [stmt bindString:v.voteId atIndex:idx++];
        [stmt bindString:v.name  atIndex:idx++];
        [stmt bindString:v.author.userId atIndex:idx++];
        
        [stmt bindInt:(int)v.maxVoteItemCount atIndex:idx++];
        [stmt bindInt:(int)v.participantCount atIndex:idx++];
        
        [stmt bindDouble:v.createdTime atIndex:idx++];
        [stmt bindDouble:v.closedTime atIndex:idx++];
        [stmt bindBool:v.isEnded atIndex:idx++];
        
        [stmt bindString:[KDVote selectedOptionIDsAsString:v.selectedOptionIDs] atIndex:idx++];
        [stmt bindInt:v.state atIndex:idx++];
        
        
        [stmt bindInt:(int)v.minVoteItemCount atIndex:idx++];
        [stmt bindBool:v.canRevote atIndex:idx++];
        // step
        if ([stmt step]) {
            KDWeiboDAOManager *manager = [KDWeiboDAOManager globalWeiboDAOManager];
            
            // save sender
            [[manager userDAO] saveUser:v.author database:fmdb];
            
            [self saveVoteOptions:v.voteOptions withVoteId:v.voteId database:fmdb];
            
        } else {
            *rollback = YES;
            
            DLog(@"Can not save vote with id=%@", v.voteId);
            
            break;
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (void)saveVoteOptions:(NSArray *)voteOptions withVoteId:(NSString *)voteId database:(FMDatabase *)fmdb {
    if (voteOptions == nil || [voteOptions count] == 0 || voteId == nil) return;
    
    NSString *sql = @"REPLACE INTO vote_options(option_id, vote_id, name, count) VALUES(?, ?, ?, ?)";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx;
    for (KDVoteOption *opt in voteOptions) {
        idx = 1;
        [stmt bindString:opt.optionId atIndex:idx++];
        [stmt bindString:voteId atIndex:idx++];
        [stmt bindString:opt.name atIndex:idx++];
        
        [stmt bindInt:(int)opt.count atIndex:idx++];
        
        // step
        if (![stmt step]) {
            DLog(@"Can not save vote option with id=%@ and vote id=%@", opt.optionId, voteId);
        }
        
        // reset parameters
        [stmt reset];
    }
    
    // finalize prepared statement
    [stmt close];
}

- (KDVote *)queryVoteWithId:(NSString *)voteId database:(FMDatabase *)fmdb {
    if (voteId == nil) return nil;
    
    NSString *sql = @"SELECT vote_id, name, author_id, max_vote_item_count, participant_count,"
                     " created_time, closed_time, is_ended, selected_option_ids, state,min_vote_item_count,canRevote"
                     " FROM votes WHERE vote_id = ?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, voteId];
    
    KDVote *vote = nil;
    if ([rs next]) {
        vote = [[KDVote alloc] init];// autorelease];
        
        int idx = 0;
        vote.voteId = [rs stringForColumnIndex:idx++];
        vote.name = [rs stringForColumnIndex:idx++];
        NSString *userId = [rs stringForColumnIndex:idx++];
        
        vote.maxVoteItemCount = [rs intForColumnIndex:idx++];
        vote.participantCount = [rs intForColumnIndex:idx++];
        
        vote.createdTime = [rs doubleForColumnIndex:idx++];
        vote.closedTime = [rs doubleForColumnIndex:idx++];
        
        vote.isEnded = [rs doubleForColumnIndex:idx++];
        vote.selectedOptionIDs =  [KDVote selectedOptionIDsStringAsArray:[rs stringForColumnIndex:idx++]];
        vote.state = [rs intForColumnIndex:idx++];
        
        vote.minVoteItemCount = [rs intForColumnIndex:idx++];
        vote.canRevote = [rs intForColumnIndex:idx++];
         
        vote.author = [KDUser userWithId:userId database:fmdb];
        
        vote.voteOptions = [self queryVoteOptionsWithVoteId:vote.voteId database:fmdb];
    }
    
    [rs close];
    
    return vote;
}

- (NSArray *)queryVoteOptionsWithVoteId:(NSString *)voteId database:(FMDatabase *)fmdb {
    if (voteId == nil) return nil;
    
    NSString *sql = @"SELECT option_id, name, count FROM vote_options WHERE vote_id = ?;";
    FMResultSet *rs = [fmdb executeQuery:sql, voteId];
    
    KDVoteOption *opt = nil;
    NSMutableArray *options = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        opt = [[KDVoteOption alloc] init];
        
        idx = 0;
        opt.optionId = [rs stringForColumnIndex:idx++];
        opt.name = [rs stringForColumnIndex:idx++];
        opt.count = [rs intForColumnIndex:idx++];
        
        [options addObject:opt];
//        [opt release];
    }
    
    [rs close];
    
    return options;
}

- (BOOL)removeVoteWithId:(NSString *)voteId database:(FMDatabase *)fmdb {
    if (voteId == nil) return NO;
    
    BOOL flag = NO;
    flag = [fmdb executeUpdate:@"DELETE FROM votes WHERE vote_id=?;", voteId];
    if (flag) {
        [self removeVoteOptionsWithId:voteId database:fmdb];
    }
    
    return flag;
}

- (BOOL)removeVoteOptionsWithId:(NSString *)voteId database:(FMDatabase *)fmdb {
    if (voteId == nil) return NO;
    
    return [fmdb executeUpdate:@"DELETE FROM vote_options WHERE vote_id=?;", voteId];
}

- (BOOL)removeAllVotesInDatabase:(FMDatabase *)fmdb {
    // remove all vote options
    [fmdb executeUpdate:@"DELETE FROM vote_options;"];
    
    return [fmdb executeUpdate:@"DELETE FROM votes;"];
}

@end
