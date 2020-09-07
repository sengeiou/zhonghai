//
//  KDApplicationQueryAppsHelper.h
//  kdweibo
//
//  Created by janon on 15/1/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDToDoMessageDataModel.h"

@class AppsClient;
@class GroupDataModel;
@class XTmenuModel;
@class XTMenuEachModel;
@class ContactClient;
@class KDVoiceTimer;

@interface KDApplicationQueryAppsHelper : NSObject
@property(nonatomic, strong) AppsClient *client;
@property (nonatomic, strong) AppsClient *KingdeeLocalAppClient;
@property (nonatomic, strong) KDVoiceTimer *multiVoiceTimer;                //多人语音轮训的计时器

+(KDApplicationQueryAppsHelper *)shareHelper;
-(void)checkAppLastUpdateTime:(NSString *)appLastUpdateTime;
-(void)checkMsgFromSystemWithSystemType:(NSString *)systemType Msg:(NSDictionary *)msg;

-(void)checkMsgFromSystemPubWithArray:(NSArray *)array;                         //检测代办消息状态的回调



-(void)queryAppsList;                                                  //V5.0上传全部本地应用的时候用到
-(void)queryWhenChangeWorkPlaceAndLogin;                               //切换工作圈和登陆时候用到
-(void)queryAppListForKingdeeLocal;                                    //签 任 文 部 扫，参数从网络来，检查跟新，应用页签出现的时候使用



-(void)checkUserDefaultForAppBeingAddWithOutNetWork;
-(void)checkUserDefaultForAppBeenDeletedWithoutNetWork;
-(void)postAllLocalAppsId;



-(void)makeNoteWhenMenuBtnClickedWithGroup:(GroupDataModel *)group
                                 EachModel:(XTMenuEachModel *)each;
-(void)makeNoteWhenMenuBtnClickedWithGroup:(GroupDataModel *)group
                                 MenuModel:(XTmenuModel *)record;
-(void)makeNoteForPubAccountMsgClickedWithPubId:(NSString *)pubId
                                          MsgId:(NSString *)msgId;           //公共号，点击消息埋点
-(void)makeNoteForPubAccountBtnClickedWithPubId:(NSString *)pubId
                                         MenuId:(NSString *)menuId;          //公共号，点击按钮埋点



-(void)todoMsgStateChangeWithSourceMsgId:(NSString *)sourceMsgId
                                PersonId:(NSString *)personId
                               ReadState:(BOOL)readstate         //带sourceId的代办的状态改变
                               DoneState:(BOOL)doneState;        //代办首条消息的埋点也包含在内
-(void)todoMsgStateChangeWithmsgId:(NSString *)sourceMsgId
                          PersonId:(NSString *)personId
                         ReadState:(BOOL)readstate                     //不带sourceId的代办的状态改变
                         DoneState:(BOOL)doneState;



-(NSMutableArray *)checkNativeAppEnsureNotDeleted;                           //检查移动应用是不是金蝶本地的5各移动应用之一



-(void)setFoldPublicAccountPressYes;                                 //消息页签订阅消息红点显示
-(void)setFoldPublicAccountPressNo;                                  //消息页签订阅消息红点不显示
-(BOOL)getFoldPublicAccountPressState;


//- (void)recordTimeLineWithGroupToDo;                                        //进入页面时候下载更新的代办信息
-(void)makeNoteWhenAppClickedWithAppDataModel:(KDAppDataModel *)model;   //点击app埋点



-(void)todoMsgStateChangeWithSourceMsgId:(NSString *)sourceMsgId                //readState doneState有三种状态YES NO 和nil,如果是nil根本不要那个字段
                                PersonId:(NSString *)personId
                               ReadState:(BOOL)readstate                        //带sourceId的代办的状态改变
                               DoneState:(BOOL)doneState;                       //代办首条消息的埋点也包含在内
-(void)todoMsgStateChangeWithMsgId:(NSString *)msgId
                          PersonId:(NSString *)personId
                         ReadState:(BOOL)readstate;                             //不带sourceId的代办的状态改变
-(void)queryToDoStatusTypeOneWithTime:(NSNumber *)time;                         //获取所有状态
-(void)queryToDoStatusTypeTwoWithTime:(NSNumber *)time;                         //持续更新时获取代办状态
- (void)deleteFirstPullAllToDoStatusWhenCheckWorkPlaceOrSignIn;             //更换登录账号或者切换工作圈


//-(void)pullAndStoreAllToDoMsgInDataBase;                                        //重新暗转app时第一次拉取所有代办
-(void)checkLocalPullAndStoreAllToDoMsgInDataBase;                              //覆盖升级app时第一次拉去所有代办
-(void)checkAndAppendToDoMsgWithGroupList:(GroupListDataModel *)list;           //查找轮训是否有代办的消息
-(void)todoMsgStateChangeWithMsgDataModel:(KDToDoMessageDataModel *) model andSourceGroupId:(NSString *)sourceGroupId;
- (void)checkGroupTalkAvailableOrNot;                                       //检测是否开启多人语音会话
- (BOOL)getGroupTalkStatus;                                                 //得到是否开启多人语音的状态
- (void)buildMultiVoiceTimerWithGroupId:(NSString *)groupid
                              GroupName:(NSString *)groupname;
- (NSString *)getMultiVoiceTimerGroupId;
- (void)setMultiVoiceUid:(NSInteger)uid;
- (NSUInteger)getMultiVoiceUid;
- (void)startMultiVoiceTimer;
- (void)cancelMultiVoiceTimer;
- (void)joinMultiVoiceSession;
- (void)quitMultiVoiceSession;
- (void)showAlreadyHaveMultiVoiceAlert;                                     //已经存在多人语音的时候出现的alert;

- (void)getMessageUnreadList;                                               //获取消息已读未读的列表
- (void)getExtMessageUnreadList; // 获取外部已读未读
- (void)getUnreadCountDetailWithGroupId:(NSString *)groupId
                                  MsgId:(NSString *)msgId;                  //消息已读未读获取消息详情

@end
