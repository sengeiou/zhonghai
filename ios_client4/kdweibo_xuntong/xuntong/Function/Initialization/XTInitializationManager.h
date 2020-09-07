//
//  XTInitializationManager.h
//  kdweibo
//
//  Created by Gil on 14-5-12.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^XTInitializationCompletionBlock) (int count);
typedef void (^XTInitializationFailedBlock) (NSString *error);

//初次初始化完成，userInfo = {"count":xxx}
extern NSString* const kInitializationFirstCompletionNotification;

//每次初始化完成（不管是第一次还是第N次），userInfo = {"count":xxx}
extern const NSString* kInitializationCompletionNotification;
//每次初始化失败（不管是第一次还是第N次），userInfo = {"error":xxx}
extern const NSString* kInitializationFailedNotification;

@interface XTInitializationManager : NSObject

+ (instancetype)sharedInitializationManager;

//开始初始化
- (void)startInitializeCompletionBlock:(XTInitializationCompletionBlock)completionBlock
                           failedBlock:(XTInitializationFailedBlock)failedBlock;

//是否正在进行初始化
- (BOOL)isInitializing;
//是否正在进行首次初始化
- (BOOL)isFirstInitializing;

//是否允许使用T9搜索
//  约束：如果通讯录没做成功过一次初始化，则不允许使用T9搜索
//  可以通过 kInitializationFirstCompletionNotification 通知来得到完成的通知
- (BOOL)canUseT9Search;

//清除初始化标识
- (void)clearInitializationFlag;

@end
