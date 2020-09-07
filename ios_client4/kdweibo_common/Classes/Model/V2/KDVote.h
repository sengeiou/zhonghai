//
//  KDVote.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-3.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"
#import "KDVoteOption.h"

typedef enum : NSUInteger {
    KDVoteStateUnknown = 0,
    KDVoteStateActive = 1,
    KDVoteStateClosed,
    KDVoteStateDeleted
}KDVoteState;

@class KDUser;

@interface KDVote : KDObject

@property(nonatomic, retain) NSString *voteId;
@property(nonatomic, retain) NSString *name; // the subject of vote
@property(nonatomic, retain) KDUser *author; // the author of vote

@property(nonatomic, assign) NSInteger maxVoteItemCount; // mark as multiple selection or single selection
@property(nonatomic, assign) NSInteger minVoteItemCount; //
@property(nonatomic, assign) NSInteger participantCount; // the users which them joined this vote

@property(nonatomic, assign) NSTimeInterval createdTime;

// the closing date time of this vote, it's means the user can not vote this vote after this value
@property(nonatomic, assign) NSTimeInterval closedTime;

@property(nonatomic, assign) BOOL isEnded; // the vote was ended or not

@property(nonatomic, assign) KDVoteState state; // the state of current vote
@property(nonatomic, retain) NSArray *voteOptions; // the vote options

// current user selected vote option ids if he selected. format like: 123,456,789 (split by ,)
@property(nonatomic, retain) NSArray *selectedOptionIDs;

//@property(nonatomic,copy) NSString *initStatusId;

@property(nonatomic, assign)BOOL canRevote;


- (BOOL)isMultipleSelections; // check this vote is support multiple selection
- (BOOL)votedVote; // check current user has been voted this vote

- (BOOL)isDeleted;
- (BOOL)isClosed;
- (BOOL)isOpen;
+ (NSString *)selectedOptionIDsAsString:(NSArray *)ids; // convert selected vote option ids as string
+ (NSArray *)selectedOptionIDsStringAsArray:(NSString *)string; // convert selected vote option ids from string to array

+ (NSString *)voteOptionIDsAsString:(NSArray *)options; // convert all options ids in this vote as string
+ (NSArray *)voteOptionIDsAsArray:(NSString *)optionIDs; // convert vote options ids from string to array
- (BOOL)isCurUserParticipant;
@end
