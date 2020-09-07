//
//  XTInitializationManager.m
//  kdweibo
//
//  Created by Gil on 14-5-12.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTInitializationManager.h"
#import "KDThreadRequst.h"
#import "ContactClient.h"
#import "BOSSetting.h"
#import "XTSetting.h"
#import "BOSConfig.h"
#import "BOSFileManager.h"
#import "XTDataBaseDao.h"
#import "T9.h"

NSString* const kInitializationFirstCompletionNotification = @"InitializationFirstCompletionNotification";
NSString* kInitializationCompletionNotification = @"InitializationCompletionNotification";
NSString* kInitializationFailedNotification = @"InitializationFailedNotification";

@interface XTInitializationManager ()

@property (strong, nonatomic) NSString *initializationDataFilePath;

@property (strong, nonatomic) NSString *openId;
@property (strong, nonatomic) NSString *eId;
@property (strong, nonatomic) XTInitializationCompletionBlock completionBlock;
@property (strong, nonatomic) XTInitializationFailedBlock failedBlock;

@property (assign, nonatomic) BOOL initializing;
@property (assign, nonatomic) BOOL firstInitializing;

@property (strong, nonatomic) KDThreadRequst *updateRequest;

@end

@implementation XTInitializationManager

+ (instancetype)sharedInitializationManager
{
    static dispatch_once_t pred;
    static XTInitializationManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[XTInitializationManager alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.initializationDataFilePath = [BOSFileManager fileFullPathAtDocumentsDirectory:@"data.dat"];
    }
    return self;
}

- (void)startInitializeCompletionBlock:(XTInitializationCompletionBlock)completionBlock
                           failedBlock:(XTInitializationFailedBlock)failedBlock
{
    //从网络加载通讯录,取消本地初始化逻辑
//    if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
//        return ;
//    }
    //如果已经在初始化，则不再重新初始化
    if (self.initializing) {
        return;
    }
    
    self.completionBlock = completionBlock;
    self.failedBlock = failedBlock;
    
    [self update];
}

- (BOOL)isInitializing
{
    return self.initializing;
}

- (BOOL)isFirstInitializing
{
    return self.firstInitializing;
}

- (BOOL)canUseT9Search
{
    return [XTSetting sharedSetting].t9UpdateTime.length != 0;
}

- (void)clearInitializationFlag
{
    if ([XTSetting sharedSetting].t9UpdateTime.length > 0) {
        [XTSetting sharedSetting].t9UpdateTime = @"";
        [[XTSetting sharedSetting] saveSetting];
    }
}

#pragma mark - update

- (void)update
{
    self.initializing = YES;
    self.firstInitializing = [XTSetting sharedSetting].t9UpdateTime.length == 0;
    
    NSString *url = [[BOSSetting sharedSetting].url stringByAppendingFormat:@"%@",EMPSERVERURL_UPDATE2];
    KDThreadRequst *request = [KDThreadRequst requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    
    [request setPostValue:[BOSConnect userAgent] forKey:@"ua"];
    if ([XTSetting sharedSetting].t9UpdateTime.length > 0) {
        [request setPostValue:[XTSetting sharedSetting].t9UpdateTime forKey:@"lastUpdateTime"];
    }
    
    request.openId = [XTSetting sharedSetting].openId;
    request.eId = [XTSetting sharedSetting].eId;
    
    NSString *openToken = [BOSConfig sharedConfig].user.token;
    if (openToken) {
        [request addRequestHeader:@"openToken" value:openToken];
    }
    [request setTimeOutSeconds:300];
    [request setDownloadDestinationPath:self.initializationDataFilePath];
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:YES];
    [request startAsynchronous];
    
    self.updateRequest = request;
    
    NSLog(@"initialization net start");
}

- (void)requestFinished:(KDThreadRequst *)theRequest
{
    NSLog(@"initialization net end");
    
    //检测是否切换了账号或者企业
    if (![theRequest.openId isEqualToString:[XTSetting sharedSetting].openId]
        || ![theRequest.eId isEqualToString:[XTSetting sharedSetting].eId]) {
        return;
    }
    
    NSLog(@"initialization database start");
    
    NSString *updateTime = nil;
    int count = [[XTDataBaseDao sharedDatabaseDaoInstance] initializeWithDataFilePath:self.initializationDataFilePath updateTime:&updateTime];
    NSLog(@"initialization data count:%d",count);
    
    if( count > 0 )
    {
        //通讯录的数据发生了变化，重新加载
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //在子线程中重载搜索树
            [[T9 sharedInstance] reloadData];
        });
    }
    
    //检测是否切换了账号或者企业
    if (![theRequest.openId isEqualToString:[XTSetting sharedSetting].openId]
        || ![theRequest.eId isEqualToString:[XTSetting sharedSetting].eId]) {
        return;
    }
    
    if (updateTime) {
        [XTSetting sharedSetting].t9UpdateTime = updateTime;
        [[XTSetting sharedSetting] saveSetting];
    }
    [[NSFileManager defaultManager] removeItemAtPath:self.initializationDataFilePath error:nil];
    
    NSLog(@"initialization database end");
    
    if (self.completionBlock) {
        self.completionBlock(count);
    }
    
    self.initializing = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kInitializationCompletionNotification object:nil userInfo:@{@"count": @(count)}];
    });
    
    if (self.firstInitializing) {
        self.firstInitializing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kInitializationFirstCompletionNotification object:nil userInfo:@{@"count": @(count)}];
        });
    }
}

- (void)requestFailed:(KDThreadRequst *)theRequest
{
    NSLog(@"initialization net end");
    
    //检测是否切换了账号或者企业
    if (![theRequest.openId isEqualToString:[XTSetting sharedSetting].openId]
        || ![theRequest.eId isEqualToString:[XTSetting sharedSetting].eId]) {
        return;
    }
    
    if (self.failedBlock) {
        self.failedBlock([[theRequest error] localizedDescription]);
    }
    self.initializing = NO;
    if (self.firstInitializing) {
        self.firstInitializing = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kInitializationFailedNotification object:nil userInfo:@{@"error": [[theRequest error] localizedDescription]}];
}

@end
