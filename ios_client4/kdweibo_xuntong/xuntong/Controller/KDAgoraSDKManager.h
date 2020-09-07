//
//  KDAgoraSDKManager.h
//  kdweibo
//
//  Created by lichao_liu on 8/4/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !(TARGET_IPHONE_SIMULATOR)
#import "agorasdk.h"
#import "AgoraAudioKit/AgoraRtcEngineKit.h"
#endif
#import "GroupDataModel.h"
//extern NSString * const CLOUDHUB_VENDORID;
//extern NSString * const CLOUDHUB_SIGNKEY;
#define  CLOUDHUB_VENDORID [[BOSSetting sharedSetting] vendorID]
#define  CLOUDHUB_SIGNKEY [[BOSSetting sharedSetting] signKey]
typedef NS_ENUM(NSInteger, KDAgoraPersonsChangeType) {
    // 离开channel
    KDAgoraPersonsChange_leave,
    // 加入channel
    KDAgoraPersonsChangeType_join,
    // 获取channel参与人列表
    KDAgoraPersonsChangeType_personList,
    //成功加入后, 因某种错误离开
    KDAgoraPersonsChangeType_channelLeave,
    // 登出
    KDAgoraPersonsChangeType_logout,
    // 登录成功
    KDAgoraPersonsChangeType_loginSuccess,
    // channel加入成功
    KDAgoraPersonsChangeType_channelJoinSuccess,
    // 重连
    KDAgoraPersonsChangeType_reConnecting,
    // 重连成功
    KDAgoraPersonsChangeType_reConnected,
    // 加入失败
    KDAgoraPersonsChangeType_joinFailed,
    // 被移除group
    KDAgoraPersonsChangeType_channelOver,
    // 非发起人收到发起人关闭channel的消息
    KDAgoraPersonsChangeType_receiveMessageQuitChannel,
    // 登陆失败
    KDAgoraPersonsChangeType_loginFailured,
    // 每个人满3小时自动离开会议
    KDAgoraPersonsChangeType_timeout,
    //一个账号同时进入，则会踢人
    KDAgoraMultiCallGroupType_logoutOccure,
    // 非发起人加入已经关闭的会议的提示
    KDAgoraMultiCallGroupType_creatorClose,
    // 网络异常登出
    KDAgoraMultiCallGroupType_logout4NetFailued,
    // 创建channel失败
    KDAgoraMultiCallGroupType_createChannelFailued,
    // 已加入过某channel，换新channel时，提示是否关闭之前的channel
    KDAgoraPersonsChangeType_needExitChannel,
    // 轮询到发起人结束会议
    KDAgoraMultiCallGroupType_agoraCreatorCloseChannel,
    // 长连接断了，重连失败，通知ui从组内退出
    KDAgoraMultiCallGroupType_agoraRejoinedFailed,
    // 触发全员静音
    KDAgoraMultiCallGroupType_agoraStopMute,
    //自身静音
    KDAgoraMultiCallGroupType_agoraMuteSelf,
    //自身取消静音
    KDAgoraMultiCallGroupType_agoraUnMuteSelf,
    //其他人静音
    KDAgoraMultiCallGroupType_agoraMuteOther,
    //其他人取消静音
    KDAgoraMultiCallGroupType_agoraUnMuteOther,
    //刷新列表
    KDAgoraMultiCallGroupType_reloadCollectionView,
    //文件分享获取accesscode serverhost
    KDAgoraMultiCallGroupType_sharePlayFile,
    //文件分享结束
    KDAgoraMultiCallGroupType_sharePlayOver,
    KDAgoraMultiCallGroupType_startRecord,
    KDAgoraMultiCallGroupType_finishedRecord,
    //文件共享播放结束
    KDAgoraMultiCallGroupType_fileShareFinished,
    //音量改变
    KDAgoraMultiCallGroupType_speakerVolumeChanged,
    //会议类型切换成主持人模式
    KDAgoraMultiCallGroupType_HostMeetingMode,
    //会议类型切换成自由模式
    KDAgoraMultiCallGroupType_FreeMeetingMode,
    //自己举手
    KDAgoraMultiCallGroupType_agoraHandsUpSelf,
    //自己取消举手
    KDAgoraMultiCallGroupType_agoraHandsDownSelf,
    //其他人举手
    KDAgoraMultiCallGroupType_agoraHandsUpOther,
    //其他人取消举手
    KDAgoraMultiCallGroupType_agoraHandsDownOther,
    //主持人模式发起人关闭我的话筒
    KDAgoraMultiCallGroupType_createrMuteMe,
    //////
    //新媒体属性取消静音
    KDAgoraMultiCallGroupType_newAttributeUnMute
};

static NSString * const KDAgoraCreateMyCallNotification = @"KDAgoraCreateMyCallNotification";
static NSString * const KDAgoraStopMyCallNotification = @"KDAgoraStopMyCallNotification";
static NSString * const KDAgoraMessageQuitChannelNotification = @"KDAgoraMessageQuitChannelNotification";
/////
static NSString * const KDAgoraHideVoiceMeetingNotification = @"KDAgoraHideVoiceMeetingNotification";

static NSInteger const  KDAgoraTalkTimeout  = 3*60;

typedef void(^agoraPersonsChangeBlock)(KDAgoraPersonsChangeType,NSString *personId,NSMutableArray *personIdArray,NSArray *speakers);
typedef void(^agoraTalkHeartBeatBlock)(long long timeout);
#if !(TARGET_IPHONE_SIMULATOR)
typedef void(^agoraNetworkQualityBlock)(AgoraRtcQuality quality);
#endif
@interface KDAgoraSDKManager : NSObject
#if !(TARGET_IPHONE_SIMULATOR)
<AgoraRtcEngineDelegate>
#endif
@property (nonatomic, assign) BOOL isUserLogin;
@property (nonatomic, assign) BOOL isHostMode;
@property (nonatomic, strong) GroupDataModel *currentGroupDataModel;
@property (nonatomic, strong) NSMutableArray *agoraModelArray;
@property (nonatomic, strong) NSMutableArray *handsUpArray;
@property (nonatomic, strong) NSMutableArray *muteArray;
@property (nonatomic, copy) agoraPersonsChangeBlock agoraPersonsChangeBlock;
@property (nonatomic, copy) agoraTalkHeartBeatBlock agoraTalkHeartBeatBlock;
@property (nonatomic, assign) long long heartbeatTimeout;
@property (nonatomic, assign) BOOL speakerEnable;
@property (nonatomic, assign) BOOL modeEnable;
//////
@property (nonatomic, assign) BOOL isJoinedMeeting;//是否正在会议中
#if !(TARGET_IPHONE_SIMULATOR)
@property (nonatomic, strong) AgoraAPI *inst;
@property (nonatomic, strong) AgoraRtcEngineKit *engineKit;
@property (nonatomic, copy) agoraNetworkQualityBlock agoraNetworkQualityBlock;
#endif

+ (KDAgoraSDKManager *)sharedAgoraSDKManager;
- (void)agoraLoginWithGroupType:(BOOL)bExt;
- (void)agoraLogout;
- (void)joinChannelWithGroupDataModel:(GroupDataModel *)group isSelfStartCall:(BOOL)isSelfStartCall;
- (void)leaveChannel;
- (void)stopMyCallWithGroupId:(NSString *)groupId mstatus:(NSInteger)mstatus;

- (void)showAlreadyHaveMultiVoiceAlertWithGroup:(GroupDataModel *)group controller:(UIViewController *)controller;

//语音会议跳转
- (void)goToMultiVoiceWithGroup:(GroupDataModel *)group viewController:(UIViewController *)viewController;

- (void)sendQuitChannelMessageWithChannelId:(id)channelId;

- (void)closeAgoraGroupTalkWithChannelId:(NSString *)channelId groupId:(NSString *)groupId;

- (void)leaveChannelAndCloseChannel;

- (void)stopExitedGroupTalkWithGroupId:(NSString *)groupId mstatus:(NSInteger)mstatus channelId:(NSString *)channelId mcallCreator:(NSString *)creator callStartTime:(long long)callStartTime newGroupId:(NSString *)groupId;

- (void)stopTimer;

- (void)leaveChannelSimple;

- (void)sendStopMuteChannelMessageWithChannelId:(id)channelId;

- (void)sendShareFileChannelMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost;

- (void)sendStopShareFileChannelMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost;

- (BOOL)isAgoraTalkIng;

- (void)sendStartRecordMessage;

- (void)sendFinishRecordMessage;

- (void)sendMuteselfMessage;//静音消息

- (void)sendUnMuteSelfMessage;//取消静音消息

- (void)sendPersonStatusMessage:(int)personStatus personId:(NSString *)personId;//个人消息,personStatus:0发言、1静音、2举手申请发言、3取消申请发言

- (void)sendMeetingTypeMessage:(int)meetingType;//会议消息,meetingType:0自由模式、1全员禁言模式（老版本）、2主持人模式

- (void)sendStopShareFileChannelMessageWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost;

- (KDAgoraModel *)findAgoraModelByAccount:(NSString *)account;

/////
- (BOOL)checkMicrophonePermission:(void (^)(BOOL permission))grantedBlock;//判断是否有麦克风权限

- (void)answerCall:(NSString *)groupId;
@end
