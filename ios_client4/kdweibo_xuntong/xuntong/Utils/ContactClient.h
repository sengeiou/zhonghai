//
//  ContactClient.h
//  ContactsLite
//
//  Created by kingdee eas on 12-11-20.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "EMPServerClient.h"

#define EMPSERVERURL_LITESEARCH @"/ecLite/search.action"//人员搜索
//A.wang 新增搜索接口
#define EMPSERVERURL_searchPage @"/ecLite/searchPage.action"//新增人员搜索

#define EMPSERVERURL_FAVOR      @"/ecLite/favorite.action"//收藏
#define EMPSERVERURL_FAVORLIST  @"/ecLite/favoriteList.action"//收藏列表
#define EMPSERVERURL_UPDATE @"/ecLite/update.action"
#define EMPSERVERURL_UPDATE2 @"/ecLite/update2.action"

#define EMPSERVERURL_EXITGROUPLIST           @"xuntong/ecLite/convers/getExitGroups.action"     //退出的群组


#define EMPSERVERURL_UNREADTOTAL @"/ecLite/convers/unreadTotal.action"//未读总数
#define EMPSERVERURL_NEEDUPDATE @"/ecLite/convers/needUpdate.action"//会话是否需要更新
#define EMPSERVERURL_UNREADCOUNT @"/ecLite/convers/unreadCount.action"//未读数

//#define EMPSERVERURL_GROUPLIST @"/ecLite/convers/groupList.action"//会话列表
#define EMPSERVERURL_GROUPLIST @"/ecLite/convers/v2/groupList.action"//会话列表
#define EMPSERVERURL_RECORDTIMELINE @"/ecLite/convers/recordTimeline.action"//会话时间线
#define EMPSERVERURL_MESSAGESEND @"/ecLite/convers/send.action"//会话发送
#define EMPSERVERURL_GETCONTENT @"/ecLite/convers/getContent.action"//获取消息内容
#define EMPSERVERURL_PERSONINFO @"/ecLite/personInfo.action"//人员信息
#define EMPSERVERURL_INVITE @"/ecLite/invite.action"//邀请
#define EMPSERVERURL_SENDFILE @"/ecLite/convers/sendFile.action"//发送文件消息
#define EMPSERVERURL_TRANSENDFILE @"/ecLite/convers/forwardingMsg.action"//转发图片文件消息
#define EMPSERVERURL_GETFILE @"/ecLite/convers/getFile.action"//获取文件消息

#define EMPSERVERURL_PUBLIC_GROUPLIST @"/ecLite/convers/public/groupList.action"//公众号模式会话列表
#define EMPSERVERURL_PUBLIC_RECORDTIMELINE @"/ecLite/convers/public/recordTimeline.action"//公众号模式会话记录时间线
#define EMPSERVERURL_PUBLIC_HISTORY @"/ecLite/convers/recordHistoryTimeline.action"//公众号历史消息
#define EMPSERVERURL_PUBLIC_SEND @"/ecLite/convers/public/send.action"//公众号模式发送消息
#define EMPSERVERURL_PUBLIC_GETCONTENT @"/ecLite/convers/public/getContent.action"//公众号模式获取消息内容
#define EMPSERVERURL_PUBLIC_SENDFILE @"/ecLite/convers/public/sendFile.action"//发送文件消息
#define EMPSERVERURL_PUBLIC_GETFILE @"/ecLite/convers/public/getFile.action"//获取文件消息

#define EMPSERVERURL_CREATGROUP @"/ecLite/convers/createGroup.action"//创建群组
#define EMPSERVERURL_ADDGROUPUSER @"/ecLite/convers/addGroupUser.action"//添加成员
#define EMPSERVERURL_DELGROUPUSER @"/ecLite/convers/delGroupUser.action"//删除成员
#define EMPSERVERURL_UPDATEGROUPNAME @"/ecLite/convers/updateGroupName.action"//更改组名
#define EMPSERVERURL_DELHISTORYRECORD @"/ecLite/convers/delGroupRecord.action"//清空会话记录
#define EMPSERVERURL_MARKALLREAD @"/ecLite/convers/updateState.action"//标记已读
#define EMPSERVERURL_TOGGLEGROUPTOP @"xuntong/ecLite/convers/toggleGroupTop.action"//会话组置顶

#define EMPSERVERURL_GETIMAGE @"/ecLite/convers/getImage.action"//获取图片
#define EMPSERVERURL_HTTPGETIMAGE @"/ecLite/convers/httpGetImage.action"//获取图片(get方式)
#define EMPSERVERURL_PUBLIC_GETIMAGE @"/ecLite/convers/public/getImage.action"//公众号模式获取图片
#define EMPSERVERURL_TOGGLEPUSH @"/ecLite/convers/togglePush.action"//切换推送功能
#define EMPSERVERURL_TOGGLEFAVORITE @"/ecLite/convers/toggleGroupFavorite.action"//收藏或者取消收藏
#define EMPSERVERURL_TOGGLEQRCODE @"/ecLite/convers/toggleQrCode.action"//群组二维码开关

//#define EMPSERVERURL_ORGTREEINFO @"/ecLite/convers/orgTreeInfo.action"//获取组织树信息
#define EMPSERVERURL_ORGTREEINFO @"/ecLite/convers/networkOrgTreeInfo.action"//获取组织树信息

#define EMPSERVERURL_TRANSFERMANAGER @"/ecLite/convers/transferManager" //转让管理员

#define EMPSERVERURL_DELGROUP @"/ecLite/convers/delGroup.action"//删除会话
#define EMPSERVERURL_DELMESSAGE @"/ecLite/convers/delMessage.action"//删除消息
#define EMPSERVERURL_PUBLIC__DELMESSAGE @"/ecLite/convers/public/delMessage.action"//公共号删除消息

#define EMPSERVERURL_SHARE @"/ecLite/share.action"//新版分享
#define EMPSERVERURL_APPS @"/portal/apps.action"//应用信息

#define CREATE_JOIN_COMPANY_URL  @"/invite/rest/inviteRest/createUrl"  //获取加入工作圈邀请url
#define EMPSERVERURL_CANCELMSG   @"/ecLite/convers/cancelMessage.action" //撤回消息的接口
#define EMPSERVERURL_PUBLIC_CANCELMSG   @"/ecLite/convers/public/cancelMessage.action" //撤回公共号消息的接口
#define EMPSERVERURL_MSGREADSTATE  @"/ecLite/convers/changeMsgReadStatus.action" //待办状态

#define EMPSERVERURL_SEARCHTEXTRECORDLIST @"xuntong/ecLite/convers/text/search.action"//会话组的文本消息搜索
#define EMPSERVERURL_SEARCHFILERECORDLIST @"xuntong/ecLite/convers/file/search.action"//会话组的文件消息搜索

#define EMPSERVERURL_MYCALL @"xuntong/ecLite/convers/mCall.action"//多方通话的状态变更通知接口
#define EMPSERVERURL_GROUPINFO @"xuntong/ecLite/convers/groupInfo.action"//获取指定会话组的详情
#define EMPSERVERURL_MCALLRECORD @"xuntong/ecLite/convers/mCallRecord.action"//多方通话录音

#define EMPSERVERURL_MSGREADLIST @"xuntong/ecLite/convers/messageReadList.action"//消息未读列表
#define EMPSERVERURL_MSGREADDETAIL @"xuntong/ecLite/convers/messageReadDetail.action"//消息未读详情
#define EMPSERVERURL_NOTIFYUNREADUSERS @"xuntong/ecLite/convers/notifyUnreadUsers.action"//消息未读发送短信通知

#define EMPSERVERURL_GETEXITGROUPS @"/ecLite/convers/getExitGroups.action"//获取已推出的会话组
#define EMPSERVERURL_GETPERSONAUTHORITY @"/ecLite/convers/getPersonAuthority.action"

#define SNSAPI_CLOUDPASSPORT @"/snsapi/passport/cloudPassport.json"

#define EMPSERVERURL_GETDONORDISTURB         @"xuntong/ecLite/convers/getDoNotDisturb"          //获取勿扰状态
#define EMPSERVERURL_UPDATEDONORDISTURB      @"xuntong/ecLite/convers/updateDoNotDisturb"       //设置勿扰时间
#define EMPSERVERURL_SETGROUPSTATUS          @"xuntong/ecLite/convers/setGroupStatus"           //修改组状态

#define EMPSERVERURL_SEARCHTODOMSG      @"/ecLite/convers/todo/search.action"       //代办搜索
#define EMPSERVERURL_GETPERSONSBYWBUSERIDS      @"/ecLite/getPersonsByWbUserIds.action"       //根据wbUserId数组获取个人详情数组

@interface ContactClient : BOSConnect

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, weak) id record;
@property (strong, nonatomic) NSString *clientKey;

-(void)personSearchWithWord:(NSString *)word begin:(int)iBegin count:(int)iCount isFilter:(BOOL)isFilter;

-(void)personNewSearchWithWord:(NSString *)word begin:(int)iBegin count:(int)iCount isFilter:(BOOL)isFilter;

-(void)getPersonsWithWBUserIds:(NSArray *)ids;

-(void)getFavoriteListWithID:(NSString *)ID begin:(int)iBegin count:(int)iCount;

-(void)toFavorWithID:(NSString *)ID flag:(int)flag;

- (void)getTotalUnreadNum;//未读总数
- (void)checkNeedUpdateWithUpdatetime:(NSString *)updateTime
                        pubUpdateTime:(NSString *)pubUpdateTime
                           pubAccount:(NSDictionary *)pubAccount;//会话是否需要更新

// 以下为测试接口
-(void)sendLogFileWithPhone:(NSString *)phone upload:(NSData *)file fileName:(NSString *)fileName contentType:(NSString *)contentType logType:(NSString *)logType;

//未读数
- (void)unreadCountWithUserIds:(NSArray *)userIds
                    updatetime:(NSString *)updateTime
             pubAcctUpdateTime:(NSString *)pubAcctUpdateTime
         msgLastReadUpdateTime:(NSString *)msgLastReadUpdateTime
          msgLastDelUpdateTime:(NSString *)msgLastDelUpdateTime
       lastCleanDataUpdateTime:(NSString *)lastCleanDataUpdateTime;  //待办删除


- (void)getGroupListWithUpdateTime:(NSString *)lastUpdateTime;//会话列表
//分页请请求取会话列表
- (void)getGroupListWithUpdateTime:(NSString *)lastUpdateTime offset:(NSInteger)offset count:(NSInteger)count;//会话列表


- (void)getRecordTimeLineWithGroupID:(NSString *)groupID userId:(NSString *)userId updateTime:(NSString *)lastUpdateTime;//会话时间线
- (void)toSendMsgWithGroupID:(NSString *)groupID
                    toUserID:(NSString *)toUserID
                     msgType:(int)msgType
                     content:(NSString *)content
                     msgLent:(int)msgLen
                       param:(NSString *)param
                 clientMsgId:(NSString *)clientMsgId;//会话发送
- (void)getContentWithMsgID:(NSString *)msgID;
- (void)getPersonInfoWithPersonID:(NSString *)personID type:(NSString *)type;//人员信息
- (void)inviteUser:(NSString *)userId sms:(int)sms;
- (void)sendFileWithGroupId:(NSString *)groupId
                   toUserId:(NSString *)toUserId
                    msgType:(int)msgType
                     msgLen:(int)msgLen
                     upload:(NSData *)file
                    fileExt:(NSString *)fileExt
                      param:(NSString *)param
                clientMsgId:(NSString *)clientMsgId;
-(void)getFileWithMsgId:(NSString *)msgId groupId:(NSString *)groupId;

- (void)publicGroupList:(NSString *)publicId updateTime:(NSString *)lastUpdateTime;
- (void)publicRecordTimeline:(NSString *)publicId groupId:(NSString *)groupId updateTime:(NSString *)lastUpdateTime;
- (void)publicRecordHistory:(NSString *)publicId andLastDate:(NSString *)lastDate;
- (void)publicSendWithGroupId:(NSString *)groupId
                     publicId:(NSString *)publicId
                      msgType:(int)msgType
                      content:(NSString *)content
                      msgLent:(int)msgLen
                  clientMsgId:(NSString *)clientMsgId;//会话发送
- (void)publicGetContent:(NSString *)publicId msgId:(NSString *)msgId;
- (void)publicSendFileWithPublicId:(NSString *)publicId
                           groupId:(NSString *)groupId
                          toUserId:(NSString *)toUserId
                           msgType:(int)msgType
                            msgLen:(int)msgLen
                            upload:(NSData *)file
                           fileExt:(NSString *)fileExt
                       clientMsgId:(NSString *)clientMsgId;
-(void)publicGetFileWithPublicId:(NSString *)publicId msgId:(NSString *)msgId;

-(void)update:(NSString *)lastUpdateTime;
-(void)update2:(NSString *)lastUpdateTime;


//********/群组/********//

- (void)creatGroupWithUserIds:(NSArray *)ids groupName:(NSString *)groupName;//创建群组
- (void)addGroupUserWithGroupId:(NSString *)groupId userIds:(NSArray *)ids;//添加成员
- (void)delGroupUserWithGroupId:(NSString *)groupId userId:(NSArray *)idstr;//删除成员
- (void)updateGroupNameWithGroupID:(NSString *)groupID groupName:(NSString *)groupName;//更新组名
- (void)delHistoryRecordWithGoupID:(NSString *)groupID;//删除记录
- (void)markAllReadWithGroupID:(NSString *)groupID;//标记已读
- (void)getInnerQRUrlWithGroupId:(NSString *)groupId;//内部组二维码

//********/图片/********//
//- (void)getSmallImageWithMsgId:(NSString *)msgId;
//- (void)getBigImageWithMsgId:(NSString *)msgId imageWith:(NSString*)weith imageHeight:(NSString*)height;
//- (void)publicGetSmallImageWithPublicId:(NSString *)publicId msgId:(NSString *)msgId;
//- (void)publicGetBigImageWithPublicId:(NSString *)publicId msgId:(NSString *)msgId;

- (void)togglePushWithGroupId:(NSString *)groupId status:(int)status;
//1 代表收藏，0 代表取消收藏
- (void)toggleFavoriteWithGroupId:(NSString *)groupId status:(int)status;

-(void)toggleQRCodeWithGroupId:(NSString *)groupId status:(int)status;

//组织树

//- (void)orgTreeInfoWithOrgId:(NSString *)orgId eid:(NSString *)eid;
- (void)orgTreeInfoWithOrgId:(NSString *)orgId andPartnerType:(NSInteger)partnerType isFilter:(BOOL)isFilter;

//新版分享
- (void)share:(NSString *)version;

//删除组或者消息
- (void)delGroupWithGroupId:(NSString *)groupId;
- (void)delMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId;
- (void)delMessageWithPublicId:(NSString *)publicId groupId:(NSString *)groupId msgId:(NSString *)msgId;

//消息撤回
- (void)cancelMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId;

// 会话组置顶
- (void)toggleGroupTopWithGroupId:(NSString *)groupID status:(NSInteger)status;

//搜索
//搜索会话文本信息
- (void)searchTextRecordListWithWord:(NSString *)textWord Page:(int)page Count:(int)count;

//搜索会话文件信息
- (void)searchFileRecordListWithWord:(NSString *)textWord Page:(int)page Count:(int)count;


//多方通话的状态变更通知接口
- (void)startOrStopMyCallWithGroupId:(NSString *)groupId status:(NSInteger)status channelId:(NSString *)channelId;
//获取指定会话组的详情
- (void)queryGroupInfoWithGroupId:(NSString *)groupId;

- (void)stopMuteMyCallWithGroupId:(NSString *)groupId
                           status:(NSInteger)status
                        channelId:(NSString *)channelId
                       micDisable:(NSInteger)micDisable;

- (void)mCallRecordStateChangedWithGroundId:(NSString *)groupId
                                     status:(NSInteger)status
                                  channelId:(NSString *)channelId;
- (void)stopMuteMyCallWithGroupId:(NSString *)groupId status:(NSInteger)status channelId:(NSString *)channelId  micDisable:(NSInteger)micDisable;


//消息已读未读列表
- (void)getMessageUreadListWithLastUpdateTime:(NSString *)lastUpdateTime;
- (void)getMessageUreadDetailWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId;
- (void)notifyUnreadUsersWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId;


//获取已退出的会话组
- (void)getExitGroupsWithLastUpdateTime:(NSString *)lastUpdateTime;
// 转让管理员
- (void)transferManagerWithGroupId:(NSString *)groupId managerId:(NSString *)managerId;
//获取有权限可见人员
- (void)getPerSonAuthorityWithGroupId:(NSString *)groupId;
- (void)getPerSonAuthorityWithPersonIds:(NSArray *)personIds;

// 消息分页
#define EMPSERVERURL_MSGLIST @"xuntong/ecLite/convers/msgList.action"
- (void)getMsgListWithGroupId:(NSString *)groupId
                       userId:(NSString *)userId
                        msgId:(NSString *)msgId
                         type:(NSString *)type
                        count:(NSString *)count;

// 公共号发言人消息分页
#define EMPSERVERURL_PUBLIC_SPEAKER_MSGLIST @"xuntong/ecLite/convers/public/msgList.action"
- (void)getPublicSpeakerMsgListWithGroupId:(NSString *)groupId
                                    userId:(NSString *)userId
                                     msgId:(NSString *)msgId
                                      type:(NSString *)type
                                     count:(NSString *)count
                                  publicId:(NSString *)publicId;
//js调用
- (void)getCloudPassportWithUserId:(NSString *)userId;

//获取勿扰状态
- (void)getDoNorDisturb;

//设置勿扰时间
- (void)updateDoNotDisturbWithEnable:(BOOL)enable from:(NSString *)fromTime to:(NSString *)toTime;

// 获取真实消息内容
#define EMPSERVERURL_MSGINFO @"xuntong/ecLite/convers/notrace/msgInfo"
- (void)getNotraceMsgInfoWithGroupId:(NSString *)groupId msgId:(NSString *)msgId;

// 删除真实消息内容
#define EMPSERVERURL_DELMSG  @"xuntong/ecLite/convers/notrace/delMsg"
- (void)deleteNotraceMsgInfoWithGroupId:(NSString *)groupId msgId:(NSString *)msgId;


//已经退出的群组
- (void)getExitGroupListWithlLastUpdateTime:(NSString *)lastUpdateTime;//内部

//代办新接口
#define EMPSERVERURL_TODOMSGLIST @"/ecLite/convers/todoMsgList.action"//代办新接口
- (void)getTodoMsgListWithGroupId:(NSString *)groupId
                           userId:(NSString *)userId
                            msgId:(NSString *)msgId   //最后一条消息ID
                             type:(NSString *)type
                            score:(NSString *)score
                         todoType:(NSString *)todoType//todoType 参数：已办页签传done，未办页签传undo，通知页签传notify
                            count:(NSString *)count;

#define EMPSERVERURL_HASMSGDEL @"/ecLite/convers/messageDelList.action"
- (void)hasDelMsgWithLastUpdateTime:(NSString *)lastUpdateTime;//删除

#define EMPSERVERURL_DISSOLVEGROUP @"xuntong/ecLite/convers/dissolveGroup"
- (void)dissolveGroupWithGroupId:(NSString *)groupId; //解散群组

- (void)setGroupStatusWithGroupId:(NSString *)groupId
                              key:(NSString *)key
                            value:(int)value;//设置群组状态
//代办搜索
- (void)searchTodoMsgWithGroupId:(NSString *)groupId
                           msgId:(NSString *)msgId
                           count:(NSInteger)count
                        todoType:(NSString*)type
                        criteria:(NSString*)keyWord;

#define verifyMsgStatus @"/ecLite/convers/verifyMsgStatus.action"
- (void)verifyMsgStatusWithGroupId:(NSString *)groupId userId:(NSString *)userId msgId:(NSString *)msgId todoStatus:(NSString *)todoStatus;
//忽略未办消息
#define IGNOREUNDOMSG @"/ecLite/convers/ignoreUndoMessage.action"
- (void)ignoreUndoMessageWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId;

//一键忽略所有未读
#define MARKEDNOTIFYMSG @"/ecLite/convers/markedNotifyMsgRead.action"
- (void)markedNotifyMsgReadWithGroupId:(NSString *)groupId;


//重装后的第一次登录成功后，先拉取与当前用户相关的人员信息列表
#define GETRELATEDPERSONS @"/ecLite/convers/getRelatedPersons.action"
- (void)getRelatePersonsWithLastPersonScore:(NSString*)lastPersonScore;

 //拉取成员列表，增量拉取
#define EMPSERVERURL_GETGROUPUSERS  @"/ecLite/convers/getGroupUsers.action"
- (void)getGroupUsersWithGroupId:(NSString *)groupId LastPersonScore:(NSString*)lastPersonScore;
@end


