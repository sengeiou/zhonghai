//
//  KDTeamRequestHelper.h
//  kdweibo
//
//  Created by shen kuikui on 13-11-8.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KDTeamRequestFinishedBlock)(id results);

@interface KDTeamRequestHelper : NSObject

+ (id)sharedTeamRequestHelper;

- (void)fetchTeamInvitationWithFinishedBlock:(KDTeamRequestFinishedBlock)block;
- (void)fetchMyApplyingTeamWithFinishedBlock:(KDTeamRequestFinishedBlock)block;
- (void)fetchAllMyTeamsWithFinishedBlock:(KDTeamRequestFinishedBlock)block;


@end
