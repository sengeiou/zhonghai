//
//  KDAgoraSDKManager.m
//  kdweibo
//
//  Created by lichao_liu on 8/4/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDAgoraSDKManager.h"
#import "BOSConfig.h"
#import "ContactClient.h"
#import <objc/runtime.h>
#import "KDMultiVoiceViewController.h"
#import "KDWPSFileShareManager.h"
#import "KDAppOpen.h"
#import "NSJSONSerialization+KDCategory.h"
#import  "KDPersonFetch.h"

//NSString * const CLOUDHUB_VENDORID = @"ED3F967F95964C6BB79C239D550104D5";
//NSString * const CLOUDHUB_SIGNKEY = @"4df0fdb232e145cd89e015ddd1b0a7df";

@interface KDAgoraSDKManager()<UIAlertViewDelegate
#if !(TARGET_IPHONE_SIMULATOR)
,AgoraRtcEngineDelegate
#endif
>
{
    UIViewController *_currentViewController;
}
@property (nonatomic, strong) ContactClient *mCallClient;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ContactClient *stopCallClient;
@property (nonatomic, strong) ContactClient *stopCallClient2;
@property (nonatomic, assign) BOOL isNeedReJoinChannel;
@property (nonatomic, assign) BOOL isShowJoinFileShareAlert;
@property (nonatomic, strong) UIAlertView *joinFileShareAlertView;
@property (nonatomic, assign) NSInteger myUid;

////
@property (nonatomic, strong) dispatch_queue_t updateDataQueue;
@end

@implementation KDAgoraSDKManager

- (void)dealloc {
    [_stopCallClient cancelRequest];
    [_stopCallClient2 cancelRequest];
    [_mCallClient cancelRequest];
}

+ (KDAgoraSDKManager *)sharedAgoraSDKManager
{
    static dispatch_once_t pred;
    static KDAgoraSDKManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[KDAgoraSDKManager alloc] init];
        instance.heartbeatTimeout = 1;
        instance.speakerEnable = NO;
        instance.modeEnable = NO;
    });
    return instance;
}
- (dispatch_queue_t)updateDataQueue {
    if (!_updateDataQueue) {
        _updateDataQueue = dispatch_queue_create("com.voiceMeeting.updateData", NULL);
    }
    return _updateDataQueue;
}
- (instancetype)init
{
    if(self = [super init])
    {
        [self addAsynBlock];
    }
    return self;
}

- (void)startTimer
{
    self.isNeedReJoinChannel = YES;
    if(!self.timer || ![self.timer isValid])
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(heartbeatFunction) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopTimer
{
    self.isNeedReJoinChannel = YES;
    if(self.timer)
    {
        self.heartbeatTimeout = 1;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (NSMutableArray *)agoraModelArray
{
    if(!_agoraModelArray)
    {
        _agoraModelArray = [NSMutableArray new];
    }
    return _agoraModelArray;
}

- (NSMutableArray *)muteArray
{
    if (!_muteArray) {
        _muteArray = [NSMutableArray new];
    }
    return _muteArray;
}

- (NSMutableArray *)handsUpArray
{
    if (!_handsUpArray) {
        _handsUpArray = [NSMutableArray new];
    }
    return _handsUpArray;
}

- (void)addAsynBlock
{
#if !(TARGET_IPHONE_SIMULATOR)
      if (CLOUDHUB_VENDORID== nil || [CLOUDHUB_VENDORID isEqualToString:@""]) {
             return ;
        }
    self.engineKit = [AgoraRtcEngineKit sharedEngineWithAppId:CLOUDHUB_VENDORID delegate:self];
    [self.engineKit enableAudioVolumeIndication:350 smooth:3];
    
    self.inst = [AgoraAPI getInstanceWithoutMedia:CLOUDHUB_VENDORID];
    __weak KDAgoraSDKManager *weakSelf = self;
    weakSelf.isNeedReJoinChannel = YES;
    self.inst.onLoginSuccess = ^(uint32_t uid,int fd){
        NSLog(@"\n----------onLoginSuccess----------");
        weakSelf.myUid = uid;
        weakSelf.isUserLogin = YES;
        if(weakSelf.agoraPersonsChangeBlock)
        {
            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_loginSuccess,nil,nil,nil);
        }
    };
    
    self.inst.onLoginFailed = ^(AgoraEcode ecode) {
        NSLog(@"\n----------onLoginFailed----------");
        weakSelf.isUserLogin = NO;
        weakSelf.currentGroupDataModel = nil;
        
        [weakSelf stopTimer];
        if(weakSelf.agoraPersonsChangeBlock)
        {
            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_loginFailured,nil,nil,nil);
        }
    };
    
    self.inst.onLogout = ^(AgoraEcode ecode){
        NSLog(@"\n----------onLogout----------");
        if(weakSelf.currentGroupDataModel && weakSelf.isUserLogin && (ecode == AgoraEcode_LOGOUT_E_KICKED || ecode == AgoraEcode_LOGOUT_E_OTHER))
        {
            if(weakSelf.agoraPersonsChangeBlock)
            {
                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_logoutOccure,nil,nil,nil);
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你的帐号已在另一台设备登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] ;
                    [alertView show];
                });
            }
            
            if(weakSelf.currentGroupDataModel && [weakSelf.currentGroupDataModel getChannelId])
            {
                [weakSelf.inst channelLeave:[weakSelf.currentGroupDataModel getChannelId]];
                [weakSelf.engineKit leaveChannel:nil];
            }
            weakSelf.currentGroupDataModel = nil;
            weakSelf.isNeedReJoinChannel = YES;
            [weakSelf stopTimer];
            weakSelf.isUserLogin = NO;
            
            dispatch_async(weakSelf.updateDataQueue, ^{
                if (weakSelf.agoraModelArray.count > 0) {
                    [weakSelf.agoraModelArray removeAllObjects];
                }
            });
            
        }else if(weakSelf.currentGroupDataModel && weakSelf.isUserLogin && ecode == AgoraEcode_LOGOUT_E_NET)
        {
            //网络异常
            
            [weakSelf stopTimer];
            if(weakSelf.currentGroupDataModel && [weakSelf.currentGroupDataModel getChannelId])
            {
                [weakSelf.inst channelLeave:[weakSelf.currentGroupDataModel getChannelId]];
                [weakSelf.engineKit leaveChannel:nil];
            }
            weakSelf.isUserLogin = NO;
            weakSelf.currentGroupDataModel = nil;
            if(weakSelf.agoraModelArray.count>0)
            {
                [weakSelf.agoraModelArray removeAllObjects];
            }
            weakSelf.isNeedReJoinChannel = YES;
            if(weakSelf.agoraPersonsChangeBlock)
            {
                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraRejoinedFailed,nil,nil,nil);
            }
            dispatch_async(weakSelf.updateDataQueue, ^{
                if (weakSelf.agoraModelArray.count > 0) {
                    [weakSelf.agoraModelArray removeAllObjects];
                }
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"当前网络不可用，你已退出会议" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            });
            
        }
    };
    
    self.inst.onReconnecting = ^(uint32_t nretry){
        if(weakSelf.agoraPersonsChangeBlock)
        {
            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_reConnecting,nil,nil,nil);
        }
    };
    
    self.inst.onReconnected = ^(int fd){
        if(weakSelf.agoraPersonsChangeBlock)
        {
            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_reConnected,nil,nil,nil);
        }
        if(weakSelf.isUserLogin && weakSelf.currentGroupDataModel && !weakSelf.isNeedReJoinChannel)
        {
            weakSelf.isNeedReJoinChannel = YES;
            [weakSelf.inst channelJoin:[weakSelf.currentGroupDataModel getChannelId]];
        }
    };
    
    self.inst.onChannelJoined = ^(NSString* name){
        NSLog(@"\n----------onChannelJoined----------");
        if(weakSelf.currentGroupDataModel && weakSelf.currentGroupDataModel.micDisable == 1)
        {
            weakSelf.modeEnable = YES;
        }
        else{
            weakSelf.modeEnable = NO;
        }
        weakSelf.speakerEnable = NO;
        [weakSelf.engineKit setEnableSpeakerphone:weakSelf.speakerEnable];
        
        dispatch_async(weakSelf.updateDataQueue, ^{
            NSString *commonPersonId = [weakSelf commonPersonId];
            if(![weakSelf findAgoraModelByAccount:commonPersonId]){
                [weakSelf.agoraModelArray addObject:[[KDAgoraModel alloc] initWithAccount:commonPersonId uid:0 volumeType:0 mute:0]];
            }
            
            [weakSelf sortAgoraModelArray];
            
            if (weakSelf.agoraPersonsChangeBlock) {
                weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_channelJoinSuccess,nil,weakSelf.agoraModelArray,nil);
            }
        });
//        NSString *commonPersonId =[weakSelf commonPersonId];
//        if(![weakSelf findAgoraModelByAccount:commonPersonId]){
//            [weakSelf.agoraModelArray addObject:[[KDAgoraModel alloc] initWithAccount:commonPersonId uid:0 volumeType:0 mute:0]];
//        }
        
        //置初始个人频道属性
        if (![[weakSelf commonPersonId] isEqualToString:weakSelf.currentGroupDataModel.mCallCreator]) {
            [weakSelf sendPersonStatusMessage:3 personId:[weakSelf commonPersonId]];
        }
        
        if(weakSelf.agoraPersonsChangeBlock)
        {
            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_channelJoinSuccess,nil,weakSelf.agoraModelArray,nil);
        }
    };
    
    //成功加入后, 因某种错误离开
    self.inst.onChannelLeaved = ^(NSString* channelID,AgoraEcode ecode){
        NSLog(@"\n----------onChannelLeaved %lu----------", (unsigned long)ecode);
        
        //        if(weakSelf.currentGroupDataModel && ecode !=AgoraEcode_LEAVECHANNEL_E_DISCONN)
        //        {
        //            //异常情况下离开会议
        //            if(weakSelf.agoraModelArray && weakSelf.agoraModelArray.count == 1)
        //            {
        //                [weakSelf stopMyCallWithGroupId:weakSelf.currentGroupDataModel.groupId mstatus:0];
        //            }
        //
        //            if(weakSelf.agoraModelArray && weakSelf.agoraModelArray.count>0)
        //            {
        //                [weakSelf.agoraModelArray removeAllObjects];
        //            }else{
        //                [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:weakSelf userInfo:@{@"status":@(NO),@"groupId":(weakSelf.currentGroupDataModel && weakSelf.currentGroupDataModel.groupId) ? weakSelf.currentGroupDataModel.groupId : @""}];
        //            }
        //            weakSelf.currentGroupDataModel = nil;
        //            if(weakSelf.agoraPersonsChangeBlock)
        //            {
        //                weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_channelLeave,nil,nil,nil);
        //            }
        //            [weakSelf agoraLogout];
        //        }
    };
    
    self.inst.onChannelJoinFailed = ^(NSString* channelID,AgoraEcode ecode){
        NSLog(@"\n----------onChannelJoinFailed----------");
        [weakSelf stopTimer];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:weakSelf userInfo:@{@"status":@(NO),@"groupId":(weakSelf.currentGroupDataModel && weakSelf.currentGroupDataModel.groupId) ? weakSelf.currentGroupDataModel.groupId: @""}];
        weakSelf.currentGroupDataModel = nil;
//        if(weakSelf.agoraModelArray.count>0)
//        {
//            [weakSelf.agoraModelArray removeAllObjects];
//        }
        if(weakSelf.agoraPersonsChangeBlock)
        {
            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_joinFailed,nil,nil,nil);
        }
        dispatch_async(weakSelf.updateDataQueue, ^{
            if (weakSelf.agoraModelArray.count > 0) {
                [weakSelf.agoraModelArray removeAllObjects];
            }
        });
    };
    
    //加入channel后  待加 updateDataQueue
    self.inst.onChannelUserJoined = ^(NSString* account,uint32_t uid){
      dispatch_async(weakSelf.updateDataQueue, ^{
        if(![weakSelf findAgoraModelByAccount:account])
        {
            KDAgoraModel *agoraModel = [weakSelf agoraModelWithAccount:account uid:uid];
            
            if(weakSelf.currentGroupDataModel && weakSelf.currentGroupDataModel.mCallCreator && [weakSelf.currentGroupDataModel.mCallCreator isEqualToString:account])
            {
                if(weakSelf.agoraModelArray.count == 0)
                {
                    [weakSelf.agoraModelArray addObject:agoraModel];
                }else{
                    [weakSelf.agoraModelArray insertObject:agoraModel atIndex:0];
                }
            }else
            {
                [weakSelf.agoraModelArray addObject:agoraModel];
            }
            [weakSelf checkPersonMessageIsCompleteWithArray:@[agoraModel] Finished:^{
                dispatch_async(weakSelf.updateDataQueue, ^{
                    
                    [weakSelf sortAgoraModelArray];
                    
                    if (weakSelf.agoraPersonsChangeBlock) {
                        weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_join,account,weakSelf.agoraModelArray,nil);
                    }
                });
            }];

        }
        KDWPSFileShareManager *fileShareManager = [KDWPSFileShareManager sharedInstance];
        //文件共享发起人
        if(fileShareManager.originatorPersonId && fileShareManager.originatorPersonId.length>0 && fileShareManager.accessCode && fileShareManager.accessCode.length>0 && [[weakSelf commonPersonId] isEqualToString:fileShareManager.originatorPersonId]){
            [weakSelf sendShareFileChannelMessageWithAccessCode:fileShareManager.accessCode serverHost:fileShareManager.serverHost?fileShareManager.serverHost:@""];
        }
        
//        if(weakSelf.agoraPersonsChangeBlock)
//        {
//            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_join,account,weakSelf.agoraModelArray,nil);
//        }
      });
    };
    
    self.inst.onChannelUserList = ^(NSMutableArray* accounts, NSMutableArray* uids){
        NSLog(@"\n----------UserList----------\n");
      dispatch_async(weakSelf.updateDataQueue, ^{
        if(weakSelf.agoraModelArray.count>0)
        {
            [weakSelf.agoraModelArray removeAllObjects];
        }
        if(accounts>0)
        {
            if(accounts.count<=uids.count){
                for (NSInteger index = 0; index<accounts.count; index++) {
                    NSUInteger uid = [uids[index] unsignedIntegerValue];
                    NSString *account = accounts[index];
                    if([account isEqualToString:[weakSelf commonPersonId]]){
                        uid = 0;
                    }
                    KDAgoraModel *agoraModel = [weakSelf agoraModelWithAccount:account uid:uid];
                    [weakSelf.agoraModelArray addObject:agoraModel];
                }
            }
        }
        NSString *commonPersonId = [weakSelf commonPersonId];
        if(![weakSelf findAgoraModelByAccount:commonPersonId]){
            [weakSelf.agoraModelArray addObject:[[KDAgoraModel alloc] initWithAccount:commonPersonId uid:0 volumeType:0 mute:0]];
        }
        
        //检查人员信息是否完整
        [weakSelf checkPersonMessageIsCompleteWithArray:weakSelf.agoraModelArray Finished:^{
            dispatch_async(weakSelf.updateDataQueue, ^{
                
                [weakSelf sortAgoraModelArray];
                
                if (weakSelf.agoraPersonsChangeBlock) {
                    //首次加入时刷新列表
                    weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_personList,nil,weakSelf.agoraModelArray,nil);
                }
                
            });
        }];
    });
//        if(weakSelf.agoraPersonsChangeBlock)
//        {
//            //首次加入时刷新列表
//            weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_personList,nil,weakSelf.agoraModelArray,nil);
//        }
    };
    
    self.inst.onChannelUserLeaved = ^(NSString* account,uint32_t uid){
     dispatch_async(weakSelf.updateDataQueue, ^{
        KDAgoraModel *agoraModel = [weakSelf findAgoraModelByAccount:account];
        if(agoraModel){
            [weakSelf.agoraModelArray removeObject:agoraModel];
            if(weakSelf.agoraModelArray.count == 0)
            {
                //异常处理 此时可能未正常登录
                BOOL isLoginNormal = YES;
                if(!weakSelf.currentGroupDataModel || !weakSelf.currentGroupDataModel.groupId || weakSelf.currentGroupDataModel.groupId.length==0)
                {
                    isLoginNormal = NO;
                }
                [weakSelf stopMyCallWithGroupId:isLoginNormal?weakSelf.currentGroupDataModel.groupId:nil mstatus:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:weakSelf userInfo:@{@"status":@(NO),@"groupId": (weakSelf.currentGroupDataModel && weakSelf.currentGroupDataModel.groupId)? weakSelf.currentGroupDataModel.groupId:@""}];
                weakSelf.currentGroupDataModel = nil;
            }
            if(weakSelf.agoraPersonsChangeBlock)
            {
                weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChange_leave,account,weakSelf.agoraModelArray,nil);
            }
        }
     });
    };
    
    self.inst.onMessageChannelReceive = ^(NSString* channelID,NSString* account,uint32_t uid,NSString* msg){
        //        NSLog(@"\n----------MessageReceive----------\n%@", msg);
        if([account isEqualToString:[weakSelf commonPersonId]])
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithString:msg];
            if (dict) {
                NSString *content = dict[@"content"];
                
                KDAgoraModel *model = [weakSelf findAgoraModelByAccount:account];
//                NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
                
                if ([content isEqualToString:@"muteself"]) {
                    [weakSelf updateAgoraModelWithAccount:account status:2 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
                        if (weakSelf.agoraPersonsChangeBlock) {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraMuteSelf,nil,nil,nil);
                        }
                    }];
                }
                else if ([content isEqualToString:@"unmuteself"]) {
                    [weakSelf updateAgoraModelWithAccount:account status:0 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
                        if (weakSelf.agoraPersonsChangeBlock) {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraUnMuteSelf,nil,nil,nil);
                        }
                    }];
                }
            }
            return;
        }
        if(weakSelf.isUserLogin && weakSelf.currentGroupDataModel && [channelID isEqualToString:[weakSelf.currentGroupDataModel getChannelId]])
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithString:msg];
            if(dict)
            {
                NSString *createBy = dict[@"createby"];
                NSString *content = dict[@"content"];
                
                if([content isEqualToString:@"quit"])
                {
                    if(!(createBy && [createBy isEqualToString:weakSelf.currentGroupDataModel.mCallCreator]))
                    {
                        return;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:weakSelf userInfo:@{@"status":@(NO),@"groupId":(weakSelf.currentGroupDataModel && weakSelf.currentGroupDataModel.groupId) ? weakSelf.currentGroupDataModel.groupId: @""}];
                    if(weakSelf.agoraPersonsChangeBlock)
                    {
                        weakSelf.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_receiveMessageQuitChannel,createBy,nil,nil);
                    }else{
                        NSString *message = @"";
                        PersonSimpleDataModel *person = [KDCacheHelper personForKey:account];
                        if(person && person.personName)
                        {
                            message = [NSString stringWithFormat:@"发起人%@已经结束本次会议",person.personName];
                        }else{
                            message = [NSString stringWithFormat:@"发起人已经结束本次会议"];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                        });
                        
                    }
                    [weakSelf leaveChannel];
                    [weakSelf agoraLogout];
                }else if ([content isEqualToString:@"muteself"]) {
                    [weakSelf updateAgoraModelWithAccount:createBy status:2 hasOldStatus:YES oldStatus:0 shouldSaveWhenNil:YES finished:^{
                        if (weakSelf.agoraPersonsChangeBlock) {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraMuteOther, createBy, nil, nil);
                        }
                    }];
//                    KDAgoraModel *model = [weakSelf findAgoraModelByAccount:createBy];
//                    if (!model) {
//                        //找不到model的时候先将uid保存起来
//                        if (![weakSelf.muteArray containsObject:[NSNumber numberWithInteger:createBy.integerValue]]) {
//                            [weakSelf.muteArray addObject:[NSNumber numberWithInteger:createBy.integerValue]];
//                        }
//                    }
//                    else {
//                        NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
//                        if (model.mute == 0) {
//                            model.mute = 2;
//                        }
//                        [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
//                        if (weakSelf.agoraPersonsChangeBlock) {
//                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraMuteOther, createBy, nil, nil);
//                        }
//                    }
                }else if ([content isEqualToString:@"unmuteself"]) {
                    [weakSelf updateAgoraModelWithAccount:createBy status:0 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
                        if (weakSelf.agoraPersonsChangeBlock) {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraUnMuteOther, createBy, nil, nil);
                        }
                    }];
//                    KDAgoraModel *model = [weakSelf findAgoraModelByAccount:createBy];
//                    if (model) {
//                        NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
//                        model.mute = 0;
//                        [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
//                        if (weakSelf.agoraPersonsChangeBlock) {
//                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraUnMuteOther, createBy, nil, nil);
//                        }
//                    }
                }else if([content isEqualToString:@"disablemic"])
                {
                    if(!(createBy && [createBy isEqualToString:weakSelf.currentGroupDataModel.mCallCreator]))
                    {
                        return;
                    }
                    //静音
                    if(weakSelf.modeEnable == NO)
                    {
                        
                        weakSelf.modeEnable = YES;
                        [weakSelf.engineKit muteLocalAudioStream:YES];
                        
                        if(weakSelf.agoraPersonsChangeBlock)
                        {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraStopMute,createBy,nil,nil);
                        }
                        
                    }
                }else if([content isEqualToString:@"fileShare"])
                {
                    if(![BOSSetting sharedSetting].fileShareEnable)
                    {
                        return;
                    }
                    NSString *accessCode = dict[@"accessCode"];
                    NSString *serverHost = dict[@"serverHost"];
                    if(accessCode)
                    {
                        KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
                        
                        if(shareManager.accessCode && shareManager.accessCode.length>0)
                        {
                            if([shareManager.accessCode isEqualToString:accessCode])
                            {
                                return;
                            }
                        }
                        
                        shareManager.accessCode = accessCode;
                        shareManager.serverHost = serverHost;
                        shareManager.originatorPersonId = account;
                        PersonSimpleDataModel *person = nil;
                        
                        person = [KDCacheHelper personForKey:account];
                        
                        if(weakSelf.agoraPersonsChangeBlock)
                        {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_sharePlayFile,createBy,nil,nil);
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *shareFileMessage = [NSString stringWithFormat:@"%@正在共享文件,你确定加入?",(person && person.personName) ? person.personName:@""];
                            if(weakSelf.isShowJoinFileShareAlert){
                                if(weakSelf.joinFileShareAlertView){
                                    weakSelf.joinFileShareAlertView.message = shareFileMessage;
                                }
                            }else{
                                weakSelf.isShowJoinFileShareAlert = YES;
                                weakSelf.joinFileShareAlertView = [[UIAlertView alloc] initWithTitle:nil message:shareFileMessage delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"加入", nil];
                                weakSelf.joinFileShareAlertView.tag = 60004;
                                [weakSelf.joinFileShareAlertView show];
                            }
                        });
                    }
                }else if([content isEqualToString:@"startrecord"])
                {
                    //开始录音
                    if(weakSelf.agoraPersonsChangeBlock)
                    {
                        weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_startRecord,nil,nil,nil);
                    }
                }else if([content isEqualToString:@"finishrecord"])
                {
                    if(weakSelf.agoraPersonsChangeBlock)
                    {
                        weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_finishedRecord,nil,nil,nil);
                    }
                    //结束录音
                    
                }else if([content isEqualToString:@"fileShareFinished"])
                {
                    NSString *accessCode = dict[@"accessCode"];
                    if(accessCode && ![accessCode isKindOfClass:[NSNull class]])
                    {
                        if([[KDWPSFileShareManager sharedInstance] isExitFileShareWithAccessCode:accessCode serverHost:nil])
                        {
                            if(weakSelf.agoraPersonsChangeBlock)
                            {
                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_fileShareFinished,nil,nil,nil);
                            }
                        }
                        
                        if(weakSelf.isShowJoinFileShareAlert){
                            weakSelf.isShowJoinFileShareAlert = NO;
                            if(weakSelf.joinFileShareAlertView){
                                [weakSelf.joinFileShareAlertView dismissWithClickedButtonIndex:0 animated:YES];
                            }
                        }
                    }
                    
                }
            }
        }
    };
    
    self.inst.onChannelAttrUpdated = ^(NSString* channelID,NSString* name,NSString* value,NSString* type) {
        if ([type isEqualToString:@"del"]) {
            return;
        }
        
        //        NSLog(@"\n----------personMessage----------\nname:%@,value:%@", name, value);
        if(weakSelf.isUserLogin && weakSelf.currentGroupDataModel && [channelID isEqualToString:[weakSelf.currentGroupDataModel getChannelId]])
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithString:value];
            //个人消息
            if([name hasPrefix:@"person"] && weakSelf.isHostMode)
            {
                NSString *account = [name substringFromIndex:7];
                NSNumber *personStatus = (NSNumber *)dict[@"personStatus"];
                NSString *sendBy = dict[@"sendBy"];
                //自己的状态变更
                if ([account isEqualToString:[weakSelf commonPersonId]]) {
                    //发起者发的消息
                    if ([personStatus intValue] == 0 && [sendBy isEqualToString:weakSelf.currentGroupDataModel.mCallCreator]) {
                        if ([weakSelf checkMicrophonePermission:nil]) {
                         weakSelf.modeEnable = NO;
                         [weakSelf.engineKit muteLocalAudioStream:NO];
                         [weakSelf sendUnMuteSelfMessage];
                        }
                    }
                    else if ([personStatus intValue] == 1 && [sendBy isEqualToString:weakSelf.currentGroupDataModel.mCallCreator]) {
                        weakSelf.modeEnable = YES;
                        [weakSelf.engineKit muteLocalAudioStream:YES];
                        [weakSelf sendMuteselfMessage];
                        if (weakSelf.agoraPersonsChangeBlock) {
                            weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_createrMuteMe, nil, nil, nil);
                        }
                    }
                    //举手申请发言
                    else if ([personStatus intValue] == 2) {
//                        KDAgoraModel *model = [weakSelf findAgoraModelByAccount:account];
//                        if (model) {
//                            NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
//                            model.mute = 1;
//                            [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
//                            if (weakSelf.agoraPersonsChangeBlock) {
//                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsUpSelf, nil, nil, nil);
//                            }
//                        }
                        [weakSelf updateAgoraModelWithAccount:account status:1 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
                            if (weakSelf.agoraPersonsChangeBlock) {
                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsUpSelf, nil, nil, nil);
                            }
                        }];
                    }
                    //媒体静音(旧版本：取消举手发言)
                    if ([personStatus intValue] == 3) {
                        [weakSelf updateAgoraModelWithAccount:account status:2 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
                            if (weakSelf.agoraPersonsChangeBlock) {
                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_newAttributeUnMute, account, nil, nil);
                            }
                        }];
                    }
//                    //取消举手发言
//                    else if ([personStatus intValue] == 3) {
//                        KDAgoraModel *model = [weakSelf findAgoraModelByAccount:account];
//                        if (model && model.mute == 1) {
//                            NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
//                            model.mute = 2;
//                            [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
//                            if (weakSelf.agoraPersonsChangeBlock) {
//                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsDownSelf, account, nil, nil);
//                            }
//                        }
//                    }
                    if ([personStatus intValue] == 4) {
                        if ([weakSelf checkMicrophonePermission:nil]) {
                            weakSelf.modeEnable = NO;
                            [weakSelf.engineKit muteLocalAudioStream:NO];
                            //                                [weakSelf sendUnMuteSelfMessage];
                            [weakSelf updateAgoraModelWithAccount:account status:0 hasOldStatus:NO oldStatus:1 shouldSaveWhenNil:YES finished:^{
                                if (weakSelf.agoraPersonsChangeBlock) {
                                    weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraUnMuteSelf, account, nil, nil);
                                }
                            }];
                        }
                    }

                }
                //会议中的其他人的状态变更
                else {
                    if ([personStatus intValue] == 2) {
                        [weakSelf updateAgoraModelWithAccount:account status:1 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
                            if (weakSelf.agoraPersonsChangeBlock) {
                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsUpOther, account, nil, nil);
                            }
                        }];
                    }
                    else if ([personStatus intValue] == 3) {
                        [weakSelf updateAgoraModelWithAccount:account status:2 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:YES finished:^{
                            if (weakSelf.agoraPersonsChangeBlock) {
                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_newAttributeUnMute, account, nil, nil);
                            }
                        }];
                    }
                    else if ([personStatus intValue] == 4) {
                        [weakSelf updateAgoraModelWithAccount:account status:0 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:YES finished:^{
                            if(weakSelf.agoraPersonsChangeBlock)
                            {
                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraUnMuteOther,nil,nil,nil);
                            }
                        }];
                        
                    }
                }

//                else {
//                    if ([personStatus intValue] == 2) {
//                        [weakSelf updateAgoraModelWithAccount:account status:1 hasOldStatus:NO oldStatus:0 shouldSaveWhenNil:NO finished:^{
//                            if (weakSelf.agoraPersonsChangeBlock) {
//                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsUpOther, account, nil, nil);
//                            }
//                        }];
////                        KDAgoraModel *model = [weakSelf findAgoraModelByAccount:account];
////                        if (model) {
////                            NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
////                            model.mute = 1;
////                            [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
////                            if (weakSelf.agoraPersonsChangeBlock) {
////                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsUpOther, account, nil, nil);
////                            }
////                        }
////                        else {
////                            if (![weakSelf.handsUpArray containsObject:[NSNumber numberWithInteger:account]]) {
////                                [weakSelf.muteArray addObject:[NSNumber numberWithInteger:account]];
////                            }
////                        }
//                    }
//                    else if ([personStatus intValue] == 3) {
//                        KDAgoraModel *model = [weakSelf findAgoraModelByAccount:account];
//                        if (model && model.mute == 1) {
//                            NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
//                            model.mute = 2;
//                            [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
//                            if (weakSelf.agoraPersonsChangeBlock) {
//                                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraHandsDownOther, account, nil, nil);
//                            }
//                        }
//                    }
//                }
            }
            //会议消息
            else if ([name hasPrefix:@"meeting"]) {
                NSNumber *meetingType = (NSNumber *)dict[@"meetingType"];
                //自由模式
                if ([meetingType intValue] == 0) {
                    weakSelf.isHostMode = NO;
                    
                    if(weakSelf.agoraPersonsChangeBlock)
                    {
                        weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_FreeMeetingMode,nil,nil,nil);
                    }
                }
                //主持人模式
                else if ([meetingType intValue] == 2) {
                    weakSelf.isHostMode = YES;
                    
                    if(weakSelf.agoraPersonsChangeBlock)
                    {
                        weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_HostMeetingMode,nil,nil,nil);
                    }
                }
            }
        }
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:KDReachabilityDidChangeNotification object:nil];
#endif
}
- (BOOL)checkMicrophonePermission:(void (^)(BOOL permission))grantedBlock {
    __block BOOL microphonePermission = NO;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            microphonePermission = YES;
        }
        
        if (grantedBlock) {
            grantedBlock(microphonePermission);
        }
    }];
    return microphonePermission;
}
- (void)checkPersonMessageIsCompleteWithArray:(NSArray *)array Finished:(void (^)(void))block {
    NSMutableArray *inCompletePerson = [NSMutableArray array];
    
    for (KDAgoraModel *personModel in array) {
        if (personModel) {
            PersonSimpleDataModel *person = personModel.person;
            if(!person || !person.personName || [person.personName isKindOfClass:[NSNull class]] || person.photoUrl == nil)
            {
                [inCompletePerson addObject:personModel.account];
            }
        }
    }
    
    if (inCompletePerson.count > 0) {
        __weak KDAgoraSDKManager *weakSelf = self;
        
        [KDPersonFetch fetchWithPersonIds:inCompletePerson
                          completionBlock:^(BOOL success, NSArray *persons, BOOL isAdminRight) {
                              if (success && [persons count] > 0) {
                                  for (PersonDataModel *personDataModel in persons) {
                                      NSString *personId = personDataModel.personId;
                                      KDAgoraModel *personModel = [weakSelf findAgoraModelByAccount:personId];
                                      PersonSimpleDataModel *newPerson = [KDCacheHelper personForKey:personId];
                                      NSUInteger modelIndex = [weakSelf.agoraModelArray indexOfObject:personModel];
                                      personModel.person = newPerson;
                                      [weakSelf.agoraModelArray replaceObjectAtIndex:modelIndex withObject:personModel];
                                  }
                              }
                              
                              if (block) {
                                  block();
                              }
                          }];
    }
    else {
        if (block) {
            block();
        }
    }
}
- (void)updateAgoraModelWithAccount:(NSString *)account status:(NSInteger)status hasOldStatus:(BOOL)hasOldStatus oldStatus:(NSInteger)oldStatus shouldSaveWhenNil:(BOOL)shouldSaveWhenNil finished:(void (^)(void))block {
    
    __weak KDAgoraSDKManager *weakSelf = self;
    
    //在updateDataQueue修改AgoraModelArray的Model
    dispatch_async(weakSelf.updateDataQueue, ^{
        
        KDAgoraModel *model = [weakSelf findAgoraModelByAccount:account];
        
        if (!model) {
            if (shouldSaveWhenNil) {
                //找不到model的时候先将uid保存起来
                if (![weakSelf.muteArray containsObject:account]) {
                    [weakSelf.muteArray addObject:account];
                }
            }
        }
        else {
            NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
            
            if (!hasOldStatus || (hasOldStatus && model.mute == oldStatus)) {
                model.mute = status;
                [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
                [weakSelf sortAgoraModelArray];
                
                if (block) {
                    block();
                }
            }
        }
    });
}
//排序 发言->举手->静音
- (void)sortAgoraModelArray {
    [self.agoraModelArray sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger diff = ((KDAgoraModel *)obj1).mute - ((KDAgoraModel *)obj2).mute;
        if (diff == 0) {
            return NSOrderedSame;
        }
        else {
            return (diff < 0) ? NSOrderedAscending : NSOrderedDescending;
        }
    }];
}
//判断是否在静音数组或者举手数组里面
- (KDAgoraModel *)agoraModelWithAccount:(NSString *)account uid:(NSUInteger)uid {
    KDAgoraModel *agoraModel = nil;
    NSNumber *uidNumber = [NSNumber numberWithInteger:uid];
    NSNumber *accountNumber = [NSNumber numberWithInteger:account.integerValue];
    if ([self.handsUpArray containsObject:accountNumber]) {
        agoraModel = [[KDAgoraModel alloc] initWithAccount:account uid:uid volumeType:0 mute:1];
        [self.handsUpArray removeObject:accountNumber];
    }
    else if ([self.muteArray containsObject:uidNumber]) {
        agoraModel = [[KDAgoraModel alloc] initWithAccount:account uid:uid volumeType:0 mute:2];
        [self.muteArray removeObject:uidNumber];
        if ([self.muteArray containsObject:accountNumber]) {
            [self.muteArray removeObject:accountNumber];
        }
    }
    else if ([self.muteArray containsObject:accountNumber]) {
        agoraModel = [[KDAgoraModel alloc] initWithAccount:account uid:uid volumeType:0 mute:2];
        [self.muteArray removeObject:accountNumber];
    }
    else {
        agoraModel = [[KDAgoraModel alloc] initWithAccount:account uid:uid volumeType:0 mute:0];
    }
    return agoraModel;
}

- (NSString *)commonPersonId
{
    return (self.currentGroupDataModel.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId);
}

- (void)agoraLoginWithGroupType:(BOOL)bExt
{
    self.isNeedReJoinChannel = NO;
#if !(TARGET_IPHONE_SIMULATOR)
    if(self.isUserLogin)
    {
        return;
    }
    self.heartbeatTimeout = 1;
    [self startTimer];
    self.currentGroupDataModel = nil;
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.updateDataQueue, ^{
        if (weakSelf.agoraModelArray.count > 0) {
            [weakSelf.agoraModelArray removeAllObjects];
        }
    });
//    if(self.agoraModelArray.count>0)
//    {
//        [self.agoraModelArray removeAllObjects];
//    }
    if ([CLOUDHUB_SIGNKEY isEqualToString:@"_no_need_token"]) {
        [self.inst login:CLOUDHUB_VENDORID account: bExt ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId token:CLOUDHUB_SIGNKEY uid:0 deviceID:@""];
    }else
    {
        //改为鉴权模式
        unsigned expiredTime =  (unsigned)[[NSDate date] timeIntervalSince1970] + 3600;
        [self.inst login2:CLOUDHUB_VENDORID
                  account:[BOSConfig sharedConfig].user.userId
                    token:[self calcToken:CLOUDHUB_VENDORID certificate:CLOUDHUB_SIGNKEY account:[BOSConfig sharedConfig].user.userId expiredTime:expiredTime]
                      uid:0
                 deviceID:@""
          retry_time_in_s:60
              retry_count:5
         
         ];
    }
    
    
#endif
}
- (NSString*)MD5:(NSString*)s
{
    // Create pointer to the string as UTF8
    const char *ptr = [s UTF8String];
    
    // Create byte array of unsigned charsasd f
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}
- (NSString *) calcToken:(NSString *)_appID certificate:(NSString *)certificate account:(NSString*)account expiredTime:(unsigned)expiredTime {
    // Token = 1:appID:expiredTime:sign
    // Token = 1:appID:expiredTime:md5(account + vendorID + certificate + expiredTime)
    //    expiredTime = 1544544000;
    //    account = @"20000685";
    
    NSString * sign = [self MD5:[NSString stringWithFormat:@"%@%@%@%d", account, _appID, certificate, expiredTime]];
    return [NSString stringWithFormat:@"1:%@:%d:%@", _appID, expiredTime, sign];
}
- (void)agoraLogout
{
#if !(TARGET_IPHONE_SIMULATOR)
    if(self.isUserLogin)
    {
        [self stopTimer];
        self.agoraPersonsChangeBlock = nil;
        self.isUserLogin = NO;
        self.currentGroupDataModel = nil;
        
        __weak __typeof(self) weakSelf = self;
        dispatch_async(self.updateDataQueue, ^{
            if (weakSelf.agoraModelArray.count > 0) {
                [weakSelf.agoraModelArray removeAllObjects];
            }
        });

//        if(self.agoraModelArray.count>0)
//        {
//            [self.agoraModelArray removeAllObjects];
//        }
        [self.inst logout];
    }
#endif
}

- (void)joinChannelWithGroupDataModel:(GroupDataModel *)group isSelfStartCall:(BOOL)isSelfStartCall
{
    self.speakerEnable = NO;
    self.modeEnable = NO;
    [self startTimer];
#if !(TARGET_IPHONE_SIMULATOR)
    self.currentGroupDataModel = group;
    NSLog(@"\n----------currentGroupDataModel = group----------");
    [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraMessageQuitChannelNotification object:self userInfo:@{@"status":@(YES)}];
    [self.inst channelJoin:[group getChannelId]];
    __weak KDAgoraSDKManager *weakSelf = self;
    [self.engineKit joinChannelByKey:CLOUDHUB_VENDORID channelName:[group getChannelId] info:nil uid:self.myUid joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        [weakSelf.engineKit disableVideo];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTableView" object:nil];
    }];
#endif
}

- (void)leaveChannel
{
    [self stopTimer];
#if !(TARGET_IPHONE_SIMULATOR)
    if(self.agoraModelArray && self.agoraModelArray.count==1 && self.currentGroupDataModel)
    {
        //判断是否是发起人
        if(self.currentGroupDataModel.mCallCreator && [self.currentGroupDataModel.mCallCreator isEqualToString:[self commonPersonId]])
        {
            [self stopMyCallWithGroupId:self.currentGroupDataModel.groupId mstatus:0];
        }
    }
    if(self.agoraModelArray.count>0)
    {
        [self.agoraModelArray removeAllObjects];
    }
    self.speakerEnable = NO;
    self.modeEnable = NO;
    self.agoraPersonsChangeBlock = nil;
    
    self.isHostMode = NO;
    [self deletePersonStatusMessage];
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(self.updateDataQueue, ^{
        if (weakSelf.agoraModelArray.count > 0) {
            [weakSelf.agoraModelArray removeAllObjects];
        }
    });
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[KDVoiceSuspendingViewManager shareInstance] removeFromWindow];
    });

    
    NSString *channelId =self.currentGroupDataModel ? [self.currentGroupDataModel getChannelId]:nil;
    [self.inst channelLeave:channelId];
    [self.engineKit leaveChannel:nil];
    self.currentGroupDataModel = nil;
    
    if([BOSSetting sharedSetting].fileShareEnable){
        KDWPSFileShareManager *fileShareManager = [KDWPSFileShareManager sharedInstance];
        fileShareManager.accessCode = nil;
        fileShareManager.serverHost = nil;
        fileShareManager.originatorPersonId = nil;
    }
#endif
}

- (void)leaveChannelSimple
{
#if !(TARGET_IPHONE_SIMULATOR)
    [self stopTimer];
    
    self.isHostMode = NO;
    [self deletePersonStatusMessage];
    
    if(self.currentGroupDataModel && self.currentGroupDataModel.groupId && [self.currentGroupDataModel getChannelId])
    {
        [self.inst channelLeave:[self.currentGroupDataModel getChannelId]];
        [self.engineKit leaveChannel:nil];
    }
    [self agoraLogout];
    if(self.agoraModelArray.count>0)
    {
        [self.agoraModelArray removeAllObjects];
    }
#endif
}

- (void)leaveChannelAndCloseChannel
{
    [self stopTimer];
#if !(TARGET_IPHONE_SIMULATOR)
    [self stopMyCallWithGroupId:self.currentGroupDataModel.groupId mstatus:0];
    if(self.agoraModelArray.count>0)
    {
        [self.agoraModelArray removeAllObjects];
    }
    self.speakerEnable = NO;
    self.modeEnable = NO;
    self.agoraPersonsChangeBlock = nil;
    
    self.isHostMode = NO;
    [self deletePersonStatusMessage];
    
    dispatch_async(self.updateDataQueue, ^{
        if (self.agoraModelArray.count>0) {
            [self.agoraModelArray removeAllObjects];
        }
    });
    
    NSString *channelId =self.currentGroupDataModel ? [self.currentGroupDataModel getChannelId]:nil;
    [self.inst channelLeave:channelId];
    [self.engineKit leaveChannel:nil];
    self.currentGroupDataModel = nil;
#endif
}

static const char stopCallClientResultkey;
- (void)stopExitedGroupTalkWithGroupId:(NSString *)groupId mstatus:(NSInteger)mstatus channelId:(NSString *)channelId mcallCreator:(NSString *)creator callStartTime:(long long)callStartTime newGroupId:(NSString *)newgroupID
{
#if !(TARGET_IPHONE_SIMULATOR)
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getQuitChannelJsonMessageWithCreator:creator creatTime:callStartTime] msgID:[ContactUtils uuid]];
    }
    //发送结束的请求
    if(!self.stopCallClient)
    {
        self.stopCallClient = [[ContactClient alloc] initWithTarget:self action:@selector(queryGroupstartOrStopMyCallWithGroupIdDidReceived:result:)];
    }
    objc_setAssociatedObject(self.stopCallClient, &stopCallClientResultkey, newgroupID, OBJC_ASSOCIATION_RETAIN);
    [self.stopCallClient startOrStopMyCallWithGroupId:groupId status:mstatus channelId:channelId];
#endif
}

static const char startOrStopMyCallKey;
- (void)stopMyCallWithGroupId:(NSString *)groupId mstatus:(NSInteger)mstatus
{
    if(mstatus == 0)
    {
        if(!self.stopCallClient2)
        {
            self.stopCallClient2 = [[ContactClient alloc] initWithTarget:self action:@selector(groupStopStartOrStopMyCallWithGroupIdDidReceived:result:)];
        }
        if(self.agoraModelArray.count>0)
        {
            [self.agoraModelArray removeAllObjects];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraStopMyCallNotification object:self userInfo:@{@"status":@(NO),@"groupId":groupId&&groupId.length>0? groupId:@""}];
        [self.stopCallClient2 startOrStopMyCallWithGroupId:groupId status:0 channelId: [self.currentGroupDataModel getChannelId]];
    }
    else
    {
        if (self.mCallClient == nil) {
            self.mCallClient = [[ContactClient alloc]initWithTarget:self action:@selector(startOrStopMyCallWithGroupIdDidReceived:result:)];
        }
        objc_setAssociatedObject(self.mCallClient, &startOrStopMyCallKey,nil, OBJC_ASSOCIATION_RETAIN);
        [self.mCallClient startOrStopMyCallWithGroupId:groupId status:mstatus channelId:mstatus == 0 ? [self.currentGroupDataModel getChannelId]:nil];
        if(groupId)
        {
            objc_setAssociatedObject(self.mCallClient, &startOrStopMyCallKey, @{@"status": @(mstatus),@"groupId":groupId}, OBJC_ASSOCIATION_RETAIN);
        }else{
            objc_setAssociatedObject(self.mCallClient, &startOrStopMyCallKey, @{@"status": @(mstatus)}, OBJC_ASSOCIATION_RETAIN);
            
        }
    }
}

- (void)startOrStopMyCallWithGroupIdDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    //开启
    if(!result.success)
    {
        [self createMcallTalkFailured:result.error errorCode:result.errorCode data:result.data];
    }else if(result.success)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraCreateMyCallNotification object:self userInfo:@{@"result":@(YES),@"param":result.data}];
    }
}

static const char startOrStopGroupResultKey;
- (void)createMcallTalkFailured:(NSString *)error errorCode:(NSInteger)errorCode data:(id)data
{
    if(errorCode == 101)
    {
        if(data && ![data isKindOfClass:[NSNull class]])
        {
            NSDictionary *dataDict = (NSDictionary *)data;
            NSString *groupId = dataDict[@"groupId"];
            NSString *channelId = dataDict[@"channelId"];
            if(groupId && channelId)
            {
                NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dataDict];
                NSDictionary *dict =  objc_getAssociatedObject(self.mCallClient, &startOrStopMyCallKey);
                NSString *newGroupId = nil;
                [mutableDict setObject:@(1) forKey:@"mCallStatus"];
                if(dict && dict[@"groupId"] && ![dict[@"groupId"] isKindOfClass:[NSNull class]])
                {
                    newGroupId = dict[@"groupId"];
                    [mutableDict setObject:newGroupId forKey:@"newGroupId"];
                }
                GroupDataModel *groupDataModel = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupId];
                if(groupDataModel)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否结束%@的会议并且参加或发起当前会议",groupDataModel.groupName] delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                    alert.tag = 60003;
                    objc_setAssociatedObject(alert, &startOrStopGroupResultKey, mutableDict, OBJC_ASSOCIATION_RETAIN);
                    [alert show];
                    return;
                }
            }
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error?error:@"创建会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraCreateMyCallNotification object:self userInfo:@{@"result":@(NO)}];
}

static const char associatedkey;
- (void)showAlreadyHaveMultiVoiceAlertWithGroup:(GroupDataModel *)group controller:(UIViewController *)controller{
    _currentViewController = controller;
    NSString *message = @"";
    NSInteger alertTag = 60001;
    if(self.isUserLogin && self.currentGroupDataModel && [self.currentGroupDataModel.mCallCreator isEqualToString:[self commonPersonId]])
    {
        //未结束会议的发起人
        alertTag = 60001;
        message = [NSString stringWithFormat:@"是否结束%@的会议并参加或发起当前的语音会议", self.currentGroupDataModel.groupName];
    }
    else
    {
        //未结束会议的参与人
        message = [NSString stringWithFormat:@"是否退出%@的会议并参加或发起当前的语音会议", self.currentGroupDataModel.groupName];
        alertTag = 60002;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.tag = alertTag;
    objc_setAssociatedObject(alertView, &associatedkey, group, OBJC_ASSOCIATION_RETAIN);
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 60002)
    {
        if (buttonIndex == 1)
        {
            //结束当前会议，开启一个新的语音会议
            [self leaveChannel];
            [self agoraLogout];
            [NSThread sleepForTimeInterval:1];
            GroupDataModel *group =  objc_getAssociatedObject(alertView, &associatedkey);
            
            if(_currentViewController)
            {
                KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
                multiVoceController.groupDataModel = group;
                if(group.mCallStatus == 0)
                {
                    multiVoceController.isCreatMyCall = YES;
                    
                }else{
                    //加入已存在的会议
                    multiVoceController.isJoinToChannel = YES;
                }
                
                if([_currentViewController isKindOfClass:[KDMultiVoiceViewController class]])
                {
                    UIViewController *desController = ((KDMultiVoiceViewController *)_currentViewController).desController;
                    multiVoceController.desController = desController;
                    RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
                    [_currentViewController dismissViewControllerAnimated:NO  completion:^{
                        [desController presentViewController:navi animated:YES completion:nil];
                    }];
                }else
                {
                    multiVoceController.desController = _currentViewController;
                    RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
                    [_currentViewController presentViewController:navi animated:YES completion:nil];
                }
                if(group.mCallStatus == 0)
                {
                    //开启会议
                    [self stopMyCallWithGroupId:group.groupId mstatus:1];
                }
            }
            
        }else{
            objc_setAssociatedObject(alertView, &associatedkey, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }else if(alertView.tag == 60001)
    {
        if(buttonIndex == 1)
        {
            //结束当前会议 进入新会议
            [self sendQuitChannelMessageWithChannelId:[self.currentGroupDataModel getChannelId]];
            [NSThread sleepForTimeInterval:1];
            GroupDataModel *group =  objc_getAssociatedObject(alertView, &associatedkey);
            
            if(_currentViewController)
            {
                KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
                multiVoceController.groupDataModel = group;
                if(group.mCallStatus == 0)
                {
                    multiVoceController.isCreatMyCall = YES;
                    
                }else{
                    //加入已存在的会议
                    multiVoceController.isJoinToChannel = YES;
                }
                
                if([_currentViewController isKindOfClass:[KDMultiVoiceViewController class]])
                {
                    UIViewController *desController = ((KDMultiVoiceViewController *)_currentViewController).desController;
                    multiVoceController.desController = desController;
                    RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
                    [_currentViewController dismissViewControllerAnimated:NO  completion:^{
                        [desController presentViewController:navi animated:YES completion:nil];
                    }];
                }else
                {
                    multiVoceController.desController = _currentViewController;
                    RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
                    [_currentViewController presentViewController:navi animated:YES completion:nil];
                }
                if(group.mCallStatus == 0)
                {
                    //开启会议
                    [self stopMyCallWithGroupId:group.groupId mstatus:1];
                }
            }
        }else{
            objc_setAssociatedObject(alertView, &associatedkey, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }else if(alertView.tag == 60003)
    {
        NSDictionary *dataDict = objc_getAssociatedObject(alertView, startOrStopGroupResultKey);
        if(dataDict)
        {
            NSString *groupId = dataDict[@"groupId"];
            NSString *channlId = dataDict[@"channelId"];
            NSString *mcallCreator = dataDict[@"mCallCreator"];
            id mCallStartTime = dataDict[@"mCallStartTime"];
            long long startTime = 0;
            NSString *newGroupId = dataDict[@"groupId"];
            if(mCallStartTime && ![mCallStartTime isKindOfClass:[NSNull class]])
            {
                startTime = [mCallStartTime longLongValue];
            }
            
            [self stopExitedGroupTalkWithGroupId:groupId mstatus:0 channelId:channlId mcallCreator:mcallCreator callStartTime:startTime newGroupId:newGroupId ?newGroupId : self.currentGroupDataModel.groupId];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraCreateMyCallNotification object:self userInfo:@{@"result":@(YES),@"param":dataDict}];
        }
    }else if(alertView.tag == 60004)
    {
        if(buttonIndex == 1)
        {
            if (![KDAppOpen isWPSInstalled]) {
                [KDAppOpen openWPSIntro:nil];
                return;
            }
//            [KDEventAnalysis event:event_fileshare_messagebox_join];
            KDWPSFileShareManager *shareManager = [KDWPSFileShareManager sharedInstance];
            [shareManager joinWpsSharePlay];
        }else{
//            [KDEventAnalysis event:event_fileshare_messagebox_cancel];
        }
        self.isShowJoinFileShareAlert = NO;
    }
}


//语音会议跳转
- (void)goToMultiVoiceWithGroup:(GroupDataModel *)group viewController:(UIViewController *)viewController
{
    BOOL hasGroupFlag = group ? YES : NO;
    
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    BOOL hasCallIng = agoraSDKManager.isUserLogin && agoraSDKManager.currentGroupDataModel;
    BOOL isSameGroup = NO;
    
    if(!hasGroupFlag)
    {
        if(hasCallIng)
        {
            if(![viewController isKindOfClass:[KDMultiVoiceViewController class]])
            {
                KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
                multiVoceController.groupDataModel = agoraSDKManager.currentGroupDataModel;
                multiVoceController.desController = viewController;
                RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
                [viewController presentViewController:navi animated:YES completion:nil];
            }
        }
        return;
    }
    
    if(hasCallIng && [group.groupId isEqualToString:agoraSDKManager.currentGroupDataModel.groupId])
    {
        isSameGroup = YES;
    }
    
    if(hasCallIng && !isSameGroup)
    {//不同的已存在的会议
        [self showAlreadyHaveMultiVoiceAlertWithGroup:group controller:viewController];
    }else if(hasCallIng && isSameGroup)
    {//同一会议
        if(![viewController isKindOfClass:[KDMultiVoiceViewController class]])
        {
            KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
            multiVoceController.groupDataModel = group;
            multiVoceController.desController = viewController;
            RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
            [viewController presentViewController:navi animated:YES completion:nil];
        }
    }else{
        UIViewController *parentViewController;
        
        if([viewController isKindOfClass:[KDMultiVoiceViewController class]])
        {
            parentViewController = ((KDMultiVoiceViewController *)viewController).desController;
            [viewController dismissViewControllerAnimated:NO completion:^{
                
            }];
            
        }else
        {
            parentViewController = viewController;
        }
        KDMultiVoiceViewController *multiVoceController = [[KDMultiVoiceViewController alloc] init];
        multiVoceController.desController = parentViewController;
        multiVoceController.groupDataModel = group;
        //判断当前组是否已开始多人会话
        if(group.mCallStatus == 1)
        {
            //已开通会议  则直接加入会议
            multiVoceController.isJoinToChannel = YES;
        }else{
            //开启一个会议
            agoraSDKManager.currentGroupDataModel = nil;
            if(agoraSDKManager.agoraModelArray)
            {
                [agoraSDKManager.agoraModelArray removeAllObjects];
            }
            multiVoceController.isCreatMyCall = YES;
            [self stopMyCallWithGroupId:group.groupId mstatus:1];
        }
        RTRootNavigationController *navi = [[RTRootNavigationController alloc]initWithRootViewController:multiVoceController];
        [parentViewController presentViewController:navi animated:YES completion:nil];
    }
}

- (void)sendQuitChannelMessageWithChannelId:(NSString *)channelId
{
#if !(TARGET_IPHONE_SIMULATOR)
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getQuitChannelJsonMessage] msgID:[ContactUtils uuid]];
    }
    if(self.agoraModelArray && self.agoraModelArray.count>0)
    {
        [self.agoraModelArray removeAllObjects];
    }
    if(channelId)
    {
        [self stopMyCallWithGroupId:self.currentGroupDataModel.groupId mstatus:0];
    }
    [self leaveChannel];
    [self agoraLogout];
    
#endif
}

- (void)sendStopMuteChannelMessageWithChannelId:(id)channelId
{
#if !(TARGET_IPHONE_SIMULATOR)
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getStopSpeakerChannelJsonMessage] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendShareFileChannelMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getShareFileChannelJsonMessageWithAccessCode:accessCode serverHost:serverHost] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendStopShareFileChannelMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getStopShareFileChannelJsonMessageWithAccessCode:accessCode serverHost:serverHost] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendStartRecordMessage
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getStartRecordMessage] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendFinishRecordMessage
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getFinishedRecordMessage] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendShareFileChannelMessageToAccount:(NSString *)account AccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageInstantSend:account uid:0 msg:[self getShareFileChannelJsonMessageWithAccessCode:accessCode serverHost:serverHost] msgID:[ContactUtils uuid]];
    }
#endif
}

- (NSString *)getQuitChannelJsonMessage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"quit" forKey:@"content"];
    [param setObject:[NSNumber numberWithDouble:self.currentGroupDataModel.lastMCallStartTimeInterval] forKey:@"createtime"];
    [param setObject:self.currentGroupDataModel.mCallCreator forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getStopSpeakerChannelJsonMessage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"disablemic" forKey:@"content"];
    [param setObject:[NSNumber numberWithDouble:self.currentGroupDataModel.lastMCallStartTimeInterval] forKey:@"createtime"];
    [param setObject:self.currentGroupDataModel.mCallCreator forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getQuitChannelJsonMessageWithCreator:(NSString *)creator creatTime:(long long)createTime
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"quit" forKey:@"content"];
    [param setObject:[NSNumber numberWithDouble:createTime] forKey:@"createtime"];
    [param setObject:creator forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getShareFileChannelJsonMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"fileShare" forKey:@"content"];
    [param setObject:accessCode forKey:@"accessCode"];
    [param setObject:serverHost forKey:@"serverHost"];
    [param setObject:[self commonPersonId] forKey:@"createby"];
    return [self getJsonDictWithDict:param];
}

- (NSString *)getStopShareFileChannelJsonMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"fileShareFinished" forKey:@"content"];
    [param setObject:accessCode forKey:@"accessCode"];
    [param setObject:serverHost forKey:@"serverHost"];
    [param setObject:[self commonPersonId] forKey:@"createby"];
    return [self getJsonDictWithDict:param];
}


- (NSString *)getStartRecordMessage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"startrecord" forKey:@"content"];
    [param setObject:[self commonPersonId] forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getFinishedRecordMessage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"finishrecord" forKey:@"content"];
    [param setObject:[self commonPersonId] forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (void)heartbeatFunction
{
    self.heartbeatTimeout += 1;
    if(self.agoraTalkHeartBeatBlock)
    {
        self.agoraTalkHeartBeatBlock(self.heartbeatTimeout);
    }
    
    if(self.heartbeatTimeout == KDAgoraTalkTimeout * 60)
    {
        //3小时后
        if(self.agoraPersonsChangeBlock)
        {
            self.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_timeout,nil,nil,nil);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"开了三小时的会，也该歇歇啦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        });
        [self leaveChannel];
        [self agoraLogout];
    }
    //调用login之后无onLoginSuccess也无onLoginFailed回调的时候，超过10秒当onLoginFailed处理
    else if(!self.currentGroupDataModel && self.heartbeatTimeout > 10)
    {
        self.isUserLogin = NO;
        self.currentGroupDataModel = nil;
        
        [self stopTimer];
        if(self.agoraPersonsChangeBlock)
        {
            self.agoraPersonsChangeBlock(KDAgoraPersonsChangeType_loginFailured,nil,nil,nil);
        }
    }
}

//- 创建会议成功，发起人加入agora失败
- (void)closeAgoraGroupTalkWithChannelId:(NSString *)channelId groupId:(NSString *)groupId
{
    if(channelId && groupId)
    {
        if (self.stopCallClient2 == nil) {
            self.stopCallClient2 = [[ContactClient alloc]initWithTarget:self action:@selector(groupStopStartOrStopMyCallWithGroupIdDidReceived:result:)];
        }
        [self.stopCallClient2 startOrStopMyCallWithGroupId:groupId status:0 channelId:channelId];
        self.currentGroupDataModel = nil;
        __weak __typeof(self) weakSelf = self;
        dispatch_async(self.updateDataQueue, ^{
            if (weakSelf.agoraModelArray.count > 0) {
                [weakSelf.agoraModelArray removeAllObjects];
            }
        });

        [[NSNotificationCenter defaultCenter] postNotificationName:KDAgoraStopMyCallNotification object:self userInfo:@{@"status":@(NO),@"groupId":groupId}];
    }
}


- (void)queryGroupstartOrStopMyCallWithGroupIdDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    NSString *groupId = objc_getAssociatedObject(self.stopCallClient, &stopCallClientResultkey);
    objc_setAssociatedObject(self.stopCallClient, &stopCallClientResultkey, nil, OBJC_ASSOCIATION_RETAIN);
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if(result.success)
    {
        if (self.mCallClient == nil) {
            self.mCallClient = [[ContactClient alloc]initWithTarget:self action:@selector(startOrStopMyCallWithGroupIdDidReceived:result:)];
        }
        objc_setAssociatedObject(self.mCallClient, &startOrStopMyCallKey, @{@"status": @(1)}, OBJC_ASSOCIATION_RETAIN);
        [self.mCallClient startOrStopMyCallWithGroupId:groupId status:1 channelId:nil];
    }
}

- (void)groupStopStartOrStopMyCallWithGroupIdDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result == nil) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
}

- (BOOL)isAgoraTalkIng
{
    if(self.isUserLogin && self.currentGroupDataModel)
    {
        return YES;
    }
    return NO;
}

- (void)sendMuteselfMessage
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getMuteSelfMessage] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendUnMuteSelfMessage
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ?[self.currentGroupDataModel getChannelId]:nil;
    if(channelId)
    {
        [self.inst messageChannelSend:channelId msg:[self getUnMuteSelfMessage] msgID:[ContactUtils uuid]];
    }
#endif
}

- (void)sendPersonStatusMessage:(int)personStatus personId:(NSString *)personId
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ? [self.currentGroupDataModel getChannelId] : nil;
    if (channelId) {
        NSString *name = [NSString stringWithFormat:@"person_%@", personId ? personId : [self commonPersonId]];
        [self.inst channelSetAttr:channelId name:name value:[self getPersonStatusMessage:personStatus]];
    }
#endif
}

- (void)deletePersonStatusMessage
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ? [self.currentGroupDataModel getChannelId] : nil;
    if (channelId) {
        NSString *name = [NSString stringWithFormat:@"person_%@", [self commonPersonId]];
        [self.inst channelDelAttr:channelId name:name];
    }
#endif
}

- (void)sendMeetingTypeMessage:(int)meetingType
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *channelId = self.currentGroupDataModel ? [self.currentGroupDataModel getChannelId] : nil;
    if (channelId) {
        NSString *name = [NSString stringWithFormat:@"meeting_%@", channelId];
        [self.inst channelSetAttr:channelId name:name value:[self getMeetingTypeMessage:meetingType]];
    }
#endif
}

- (NSString *)getMeetingTypeMessage:(int)meetingType
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[NSNumber numberWithInt:meetingType] forKey:@"meetingType"];
    [param setObject:[self commonPersonId] forKey:@"sendBy"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getPersonStatusMessage:(int)personStatus
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[NSNumber numberWithInt:personStatus] forKey:@"personStatus"];
    [param setObject:[self commonPersonId] forKey:@"sendBy"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getUnMuteSelfMessage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"unmuteself" forKey:@"content"];
    [param setObject:[self commonPersonId] forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getMuteSelfMessage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"muteself" forKey:@"content"];
    [param setObject:[self commonPersonId] forKey:@"createby"];
    
    return [self getJsonDictWithDict:param];
}

- (NSString *)getJsonDictWithDict:(NSDictionary *)param{
    NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    
    if (paramJsonData) {
        return [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)reachabilityChanged:(NSNotification *)notification
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSDictionary* dict = notification.userInfo;
    KDReachabilityStatus status = [dict[KDReachabilityStatusKey] integerValue];
    __weak KDAgoraSDKManager *weakSelf = self;
    
    if(status == KDReachabilityStatusNotReachable || status == KDReachabilityStatusUnknown)
    {
        if(weakSelf.isUserLogin && weakSelf.currentGroupDataModel)
        {
            if(weakSelf.isNeedReJoinChannel)
            {
                weakSelf.isNeedReJoinChannel = NO;
                [self.inst setNetworkStatus:0];
            }
        }
    }else{
        if(weakSelf.isUserLogin && weakSelf.currentGroupDataModel && !weakSelf.isNeedReJoinChannel)
        {
            weakSelf.isNeedReJoinChannel = YES;
            [self.inst setNetworkStatus:1];
        }
    }
#endif
}

- (KDAgoraModel *)findAgoraModelByAccount:(NSString *)account{
    __block KDAgoraModel *agoraModel = nil;
    [self.agoraModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDAgoraModel *model = obj;
        if([model.account isEqualToString:account]){
            agoraModel = model;
            *stop = YES;
        }
    }];
    return agoraModel;
}

- (KDAgoraModel *)findAgoraModelByUid:(NSInteger)uid {
    __block KDAgoraModel *agoraModel = nil;
    [self.agoraModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDAgoraModel *model = obj;
        if(model.uid == uid){
            agoraModel = model;
            *stop = YES;
        }
    }];
    return agoraModel;
}

#pragma mark AgoraRtcEngineDelegate
#if !(TARGET_IPHONE_SIMULATOR)
- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportAudioVolumeIndicationOfSpeakers:(NSArray*)speakers totalVolume:(NSInteger)totalVolume{
    if(self.isUserLogin && self.currentGroupDataModel){
        if(self.agoraPersonsChangeBlock){
            self.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_speakerVolumeChanged,nil,nil,speakers);
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraRtcQuality)txQuality rxQuality:(AgoraRtcQuality)rxQuality {
    if (self.agoraNetworkQualityBlock && uid == 0) {
        self.agoraNetworkQualityBlock(txQuality);
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.updateDataQueue, ^{
    KDAgoraModel *model = [weakSelf findAgoraModelByUid:uid];
    if (!model) {
        //找不到model的时候先将uid保存起来
        if (muted && ![weakSelf.muteArray containsObject:[NSNumber numberWithInteger:uid]]) {
            [weakSelf.muteArray addObject:[NSNumber numberWithInteger:uid]];
        }
    }
    else {
        NSUInteger index = [weakSelf.agoraModelArray indexOfObject:model];
        if (muted) {
            if (model.mute == 0) {
                model.mute = 2;
            }
        }
        else {
            model.mute = 0;
        }
        [weakSelf.agoraModelArray replaceObjectAtIndex:index withObject:model];
        if (weakSelf.agoraPersonsChangeBlock) {
            if (muted) {
                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraMuteOther, model.person.personId, nil, nil);
            }
            else {
                weakSelf.agoraPersonsChangeBlock(KDAgoraMultiCallGroupType_agoraUnMuteOther, model.person.personId, nil, nil);
            }
        }
    }
 });
}

#endif

@end
