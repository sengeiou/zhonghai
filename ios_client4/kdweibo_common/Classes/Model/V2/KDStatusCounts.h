//
//  KDStatusCounts.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-17.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDStatusCounts : NSObject

@property(nonatomic, retain) NSString *statusId; // the status id
@property(nonatomic, assign) NSInteger forwardsCount; // the forward times about this status
@property(nonatomic, assign) NSInteger commentsCount; // the comment times about this status
@property(nonatomic, assign) NSInteger likedCount;
@property(nonatomic, assign) BOOL liked;

@property(nonatomic, retain) NSArray *microBlogComments;
@property(nonatomic, retain) NSArray *likeUserInfos;

@end

