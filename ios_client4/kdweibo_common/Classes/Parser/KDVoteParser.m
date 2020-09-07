//
//  KDVoteParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDVoteParser.h"
#import "KDVote.h"
#import "KDVoteOption.h"

#import "KDUserParser.h"

@implementation KDVoteParser

- (KDVote *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDVote *vote = [[KDVote alloc] init];// autorelease];
    vote.voteId = [body stringForKey:@"id"];
    vote.name = [body stringForKey:@"name"];
    
    NSDictionary *author = [body objectNotNSNullForKey:@"creater"];
    KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
    vote.author = [parser parseAsSimple:author];
    
    vote.maxVoteItemCount = [body intForKey:@"maxVoteItemCount"];
    vote.participantCount = [body intForKey:@"participantCount"];
    
    vote.createdTime = KD_PARSER_MILLISECOND_TO_SECONDS([body uint64ForKey:@"createTime"]);
    vote.closedTime = KD_PARSER_MILLISECOND_TO_SECONDS([body uint64ForKey:@"deadline"]);
    
    vote.isEnded = [body boolForKey:@"end" defaultValue:YES];
    
//    vote.initStatusId = [body stringForKey:@"initStatusId"];
    //add by lee
    vote.minVoteItemCount =[body intForKey:@"minVoteItemCount"];
    vote.canRevote = [body boolForKey:@"canRevote" defaultValue:YES];
    // vote options
    NSArray *options = [body objectNotNSNullForKey:@"items"];
    vote.voteOptions = [self parseAsVoteOptions:options];
    
    // selected vote options of current user
    NSArray *votedOptionsInfo = [body objectNotNSNullForKey:@"myVote"];
    if (votedOptionsInfo != nil) {
        NSMutableArray *votedOptions = [NSMutableArray arrayWithCapacity:[votedOptionsInfo count]];
        
        for (NSDictionary *item in votedOptionsInfo) {
            NSString *optionId = [item stringForKey:@"id"];
            if (optionId) {
                [votedOptions addObject:optionId];
            }
        }
        
        vote.selectedOptionIDs = votedOptions;
    }
    
    return vote;
}

- (NSArray *)parseAsVoteOptions:(NSArray *)body {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    KDVoteOption *option = nil;
    NSMutableArray *vos = [NSMutableArray arrayWithCapacity:count];
    
    for (NSDictionary *item in body) {
        option = [[KDVoteOption alloc] init];
        
        option.optionId = [item stringForKey:@"id"];
        option.name = [item stringForKey:@"name"];
        option.count = [item intForKey:@"count"];
        
        [vos addObject:option];
//        [option release];
    }
    
    return vos;
}

@end
