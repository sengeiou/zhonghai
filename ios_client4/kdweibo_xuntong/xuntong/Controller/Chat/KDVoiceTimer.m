//
//  KDVoiceTimer.m
//  kdweibo
//
//  Created by wenbin_su on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDVoiceTimer.h"
#import "XTOpenSystemClient.h"
#import "BOSConfig.h"

@interface KDVoiceTimer ()
@property (nonatomic, strong) UIWindow *multiVoiceWindow;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) XTOpenSystemClient *client;
@property (nonatomic, strong) XTOpenSystemClient *joinClient;
@property (nonatomic, strong) XTOpenSystemClient *cancelClient;
@property (nonatomic, strong) XTOpenSystemClient *uidClient;
@property (nonatomic, strong) XTOpenSystemClient *personidClient;
@end

@implementation KDVoiceTimer

-(NSUInteger)agoraUid
{
    if (!_agoraUid) {
        _agoraUid = 0;
    }
    return _agoraUid;
}

#pragma mark - Start Cancel
- (void)startTimer
{
    
    [self checkUpdate];
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(checkUpdate)
                                                userInfo:nil
                                                 repeats:YES];
    DLog(@"startTimer!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

- (void)cancelTimer
{
    [self.timer invalidate];
    self.timer = nil;
    DLog(@"cancelTimer!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

#pragma mark - check update
-(XTOpenSystemClient *)client
{
    if (!_client)
    {
        _client = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(checkUpdateDidReceived:result:)];
    }
    return _client;
}

- (void)checkUpdate
{
    if (self.groupId == nil)
    {
        //groupId是空,说明这个groupId是公共号,不开始轮训
    }
    else
    {
        [self.client getSessionPersonsWithGroupId:self.groupId];
    }
}

- (void)checkUpdateDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    //lastUpdateTime 用来获取更新的时间，做好lastUpdateTime的更新
    
    if (result && [result isKindOfClass:[BOSResultDataModel class]] &&result.success == YES)
    {
        NSDictionary *tempDic = nil;
        NSString *tempString = result.data;
        BOOL dataHasOrNot = [tempString isKindOfClass:[NSNull class]] || tempString == nil || [tempString isEqual:@""];
        
        if (!dataHasOrNot)
        {
            tempDic = [NSJSONSerialization JSONObjectWithData:[tempString dataUsingEncoding:NSUTF8StringEncoding]
                                                      options:NSJSONReadingMutableContainers
                                                        error:nil];
            
            //            BOOL lastUpdateTimeIsNull = (self.lastUpdateTime == nil || [self.lastUpdateTime isKindOfClass:[NSNull class]] || [self.lastUpdateTime isEqualToString:@""]);
            //            BOOL lastUpdateTimeIsNew = ([self.lastUpdateTime compare:[tempDic objectForKey:@"lastUpdateTime"]] == NSOrderedAscending);
            
            //            if (lastUpdateTimeIsNull || lastUpdateTimeIsNew)
            //            {
            //解析数据
            self.count = [[tempDic objectForKey:@"onlineCount"] integerValue];
            self.personArray = [tempDic objectForKey:@"personInfo"];
            self.lastUpdateTime = [tempDic objectForKey:@"lastUpdateTime"];
            
            //做到了确实有更改的时候才发出通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"multiVoice" object:nil userInfo:@{@"reload":[NSNumber numberWithBool:YES]}];
            //            }
            //            //这个地方之前为了防止多次刷新做了控制，这个地方暂时放开为了防止重新进入已经有的会话的时候不能获得人员的信息
        }
        else
        {
            self.count = 0;
            self.personArray = nil;
            self.lastUpdateTime = nil;
            
            //发出通知确保图标的出现与否保持同步
            [[NSNotificationCenter defaultCenter] postNotificationName:@"multiVoice" object:nil userInfo:nil];
        }
    }
}

#pragma mark - join
-(XTOpenSystemClient *)joinClient
{
    if (!_joinClient)
    {
        _joinClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(joinClientDidReceived:result:)];
    }
    return _joinClient;
}

-(void)join
{
    [self.joinClient joinSessionWithGroupId:self.groupId PersonId:[BOSConfig sharedConfig].user.userId];
}

- (void)joinClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result && [result isKindOfClass:[BOSResultDataModel class]] &&result.success == YES)
    {
        NSNumber *tempNum = [result.data objectForKey:@"uid"];
        self.agoraUid = [tempNum unsignedIntegerValue];
        
        NSMutableArray *tempArray = [result.data objectForKey:@"ids"];
        if ([tempArray isKindOfClass:[NSNull class]] || tempArray == nil || tempArray.count == 0)
        {
            tempArray = [NSMutableArray array];
            [tempArray insertObject:[BOSConfig sharedConfig].user.userId atIndex:0];
            self.personArray = tempArray;
        }
        else
        {
            __block BOOL hasOrNot = NO;
            __block NSInteger location = 0;
            [tempArray enumerateObjectsUsingBlock:^(NSString *personid, NSUInteger i, BOOL *stop)
             {
                 if ([personid isEqualToString:[BOSConfig sharedConfig].user.userId])
                 {
                     hasOrNot = YES;
                     location = i;
                     stop = YES;
                 }
             }];
            if (hasOrNot == NO)
            {
                [tempArray insertObject:[BOSConfig sharedConfig].user.userId atIndex:0];
            }
            else
            {
                [tempArray removeObjectAtIndex:location];
                [tempArray insertObject:[BOSConfig sharedConfig].user.userId atIndex:0];
            }
            self.personArray = tempArray;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"agoraUid" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"multiVoice" object:nil userInfo:@{@"reload":[NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - quit
-(XTOpenSystemClient *)cancelClient
{
    if (!_cancelClient)
    {
        _cancelClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(cancelClientDidReceived:result:)];
    }
    return _cancelClient;
}

-(void)quit
{
    [self.cancelClient quitSessionWithGroupId:self.groupId PersonId:[BOSConfig sharedConfig].user.userId];
}

- (void)cancelClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result && [result isKindOfClass:[BOSResultDataModel class]] &&result.success == YES)
    {
        
    }
}

#pragma mark - postWithUids
-(XTOpenSystemClient *)uidClient
{
    if (!_uidClient)
    {
        _uidClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(uidClientDidReceived:result:)];
    }
    return _uidClient;
}

-(void)postWithUids:(NSMutableArray *)uids
{
    NSString *ids = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:uids options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [self.uidClient getUidByPersonIdWithPersonIds:ids];
}

- (void)uidClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result && [result isKindOfClass:[BOSResultDataModel class]] &&result.success == YES)
    {
        
    }
}

#pragma mark - postWithPersonids
-(XTOpenSystemClient *)personidClient
{
    if (!_personidClient)
    {
        _personidClient = [[XTOpenSystemClient alloc]initWithTarget:self action:@selector(personidClientDidReceived:result:)];
    }
    return _personidClient;
}

-(void)postWithPersonids:(NSMutableArray *)personids
{
    NSString *ids = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:personids options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [self.personidClient getPersonIdByUidWithUids:ids];
}

- (void)personidClientDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result && [result isKindOfClass:[BOSResultDataModel class]] &&result.success == YES)
    {
        
    }
}

@end

