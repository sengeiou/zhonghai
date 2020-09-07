//
//  XTLoginService.h
//  kdweibo
//
//  Created by bird on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^XTLoginFinishedBlock) (BOOL success);

@interface XTLoginService : NSObject
// 通过eid切换工作圈
+ (void)xtLoginInEId:(NSString *)eid finishBlock:(XTLoginFinishedBlock)block;
// 通过token切换团队账号
+ (void)xtLoginInToken:(NSString *)token finishBlock:(XTLoginFinishedBlock)block;
@end
