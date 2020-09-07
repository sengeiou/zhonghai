//
//  KDParamFetchManager.h
//  kdweibo
//
//  Created by Gil on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KDParamFetchCompletionBlock) (BOOL success);

@interface KDParamFetchManager : NSObject

+ (instancetype)sharedParamFetchManager;

//获取参数
- (void)startParamFetchCompletionBlock:(KDParamFetchCompletionBlock)completionBlock;


@end
