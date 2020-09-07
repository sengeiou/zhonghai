//
//  KDVote.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-3.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDVote.h"
#import "KDManagerContext.h"
#import "KDUserManager.h"

@implementation KDVote

@synthesize voteId=voteId_;
@synthesize name=name_;
@synthesize author=author_;

@synthesize maxVoteItemCount=maxVoteItemCount_;
@synthesize participantCount=participantCount_;

@synthesize createdTime=createdTime_;
@synthesize closedTime=closedTime_;

@synthesize isEnded=isEnded_;

@synthesize state=state_;
@synthesize voteOptions=voteOptions_;
@synthesize selectedOptionIDs=selectedOptionIDs_;
//@synthesize initStatusId = initStatusId_;


@synthesize minVoteItemCount=minVoteItemCount_;
@synthesize canRevote = canRevote_;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (BOOL)isMultipleSelections {
    return maxVoteItemCount_ > 1;
}

- (BOOL)votedVote {
    return selectedOptionIDs_ != nil && [selectedOptionIDs_ count] > 0;
}

- (BOOL)isDeleted {
    return state_ == KDVoteStateDeleted;
}

- (BOOL)isClosed {
    return state_ == KDVoteStateClosed;
}
- (BOOL)isOpen {
    return !self.isEnded && !self.votedVote;
}
#define KD_VOTE_OPTION_ID_DEVIDER   @"__kdv__"

+ (NSString *)selectedOptionIDsAsString:(NSArray *)ids {
    return (ids != nil) ? [ids componentsJoinedByString:KD_VOTE_OPTION_ID_DEVIDER] : nil;
}

+ (NSArray *)selectedOptionIDsStringAsArray:(NSString *)string {
    return (string != nil) ? [string componentsSeparatedByString:KD_VOTE_OPTION_ID_DEVIDER] : nil;
}

+ (NSString *)voteOptionIDsAsString:(NSArray *)options {
    NSMutableString *buf = nil;
    NSUInteger count = 0;
    if (options != nil && (count = [options count]) > 0) {
        buf = [NSMutableString string];
        
        int idx = 0;
        for (KDVoteOption *vp in options) {
            [buf appendString:vp.optionId];
            
            if (idx < count - 1) {
                [buf appendString:KD_VOTE_OPTION_ID_DEVIDER];
            }
            
            idx++;
        }
    }
    
    return (buf != nil) ? [NSString stringWithString:buf] : nil;
}

+ (NSArray *)voteOptionIDsAsArray:(NSString *)optionIDs {
    return (optionIDs != nil) ? [optionIDs componentsSeparatedByString:KD_VOTE_OPTION_ID_DEVIDER] : nil;
}

//是否参与了投票
- (BOOL)isCurUserParticipant {
    //KWEngine *api = [KWEngine sharedEngine];
    //return [self.creator.id_ isEqualToString:api.user.id_] || self.myOptions.count;
    KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
    return [self.author.userId isEqualToString:userManager.currentUserId] || [self.selectedOptionIDs count]>0;
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(voteId_);
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(author_);
    
    //KD_RELEASE_SAFELY(voteOptions_);
    //KD_RELEASE_SAFELY(selectedOptionIDs_);
    //KD_RELEASE_SAFELY(initStatusId_);

    //[super dealloc];
}

@end
