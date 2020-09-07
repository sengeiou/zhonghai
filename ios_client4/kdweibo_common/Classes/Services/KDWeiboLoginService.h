//
//  KDWeiboLoginService.h
//  kdweibo
//
//  Created by bird on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KDWeiboLoginFinishedBlock) (BOOL success, NSString *errorMessage);

@class KDAuthToken;

@interface KDWeiboLoginService : NSObject

+ (void)signInUser:(NSString *)username password:(NSString *)password finishBlock:(KDWeiboLoginFinishedBlock)block;

+ (void)signInToken:(KDAuthToken *)authToken finishBlock:(KDWeiboLoginFinishedBlock)block;

+ (void)thirdPartAuthorize_finishBlock:(KDWeiboLoginFinishedBlock)block;

@end
