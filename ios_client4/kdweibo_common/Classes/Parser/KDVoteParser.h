//
//  KDVoteParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDVote;

@interface KDVoteParser : KDBaseParser

// parse the JSON body as vote
- (KDVote *)parse:(NSDictionary *)body;

@end
