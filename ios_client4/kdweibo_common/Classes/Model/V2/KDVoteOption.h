//
//  KDVoteOption.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-3.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KDVote;
@interface KDVoteOption : NSObject

@property(nonatomic, retain) NSString *optionId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, assign) KDVote *vote;
@property(nonatomic, assign,readonly) float percent;
@end
