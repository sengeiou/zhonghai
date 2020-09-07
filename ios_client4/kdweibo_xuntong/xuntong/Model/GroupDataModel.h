//
//  GroupListDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

//组类型,1—双人组,2—多人组,3-公众号组,4-公众号多人组,5-组文件夹,6-消息通知组（不可回复）,7-无交互的公众号组
typedef enum _GroupType
{
    GroupTypeNone = 0,
    GroupTypeDouble = 1,
    GroupTypeMany = 2,
    GroupTypePublic = 3,
    GroupTypePublicMany = 4,
    GroupTypeSubGroup = 5,
    GroupTypeMessageNotification = 6,
    GroupTypePublicNoInteractive = 7,
    GroupTypeTodo = 8
}GroupType;


typedef NS_ENUM(NSInteger, KDAgoraMultiCallGroupType) {
    KDAgoraMultiCallGroupType_none,
    KDAgoraMultiCallGroupType_joined,
    KDAgoraMultiCallGroupType_noJoined
};
@class PersonSimpleDataModel;
@class RecordDataModel;
@interface GroupDataModel : BOSBaseDataModel

@property (nonatomic, copy) NSString *groupId;//组ID
@property (nonatomic, assign) GroupType groupType;//组类型
@property (nonatomic, copy) NSString *groupName;//组名称
@property (nonatomic, strong) NSMutableArray *participant;//参与人，PersonSimpleDataModel数组
@property (nonatomic, assign) int unreadCount;//未读数
@property (nonatomic, strong) RecordDataModel *lastMsg;//最后会话
//组状态,二进制数值, 0—否,1—是,转化为二进制值后从右边数,第一位值表示本人是否存在于此组,第二位值表示是否开通此组的消息推送，第三位置顶，第四位收藏，第五位不详，第六位群组二维码
@property (nonatomic, assign) int status;

@property (nonatomic, copy) NSString *lastMsgId;
@property (nonatomic, copy) NSString *lastMsgSendTime;
//保存最后一条信息
@property (nonatomic, strong) NSString *lastMsgDesc;

@property (nonatomic,copy) NSString *updateTime;//额外的字段，记录每个会话的更新时间
@property (nonatomic, strong) NSString *menu;//轻应用菜单
@property (nonatomic, assign) BOOL fold;//是否参与文件夹折叠
@property (nonatomic, assign) int manager;    //是否公共号管理员 1:是 0:不是

@property (nonatomic, copy) NSString *draft; // 聊天草稿

@property (nonatomic, assign) int iNotifyType; // 提醒类型, 1:@提及
@property (nonatomic, copy) NSString *strNotifyDesc; // 提醒描述

@property (nonatomic, copy) NSString *headerUrl; //组头像
// extra property
@property (nonatomic, assign) BOOL isNewGroup;  //  是否是新建的组


//用来做搜索高亮
@property (nonatomic, strong) NSString *highlightGroupName;
@property (nonatomic, strong) NSString *highlightMessage;

@property (nonatomic, strong) NSMutableArray *participantIds;//参与人Ids
@property (nonatomic, strong) id param;//组参数
@property (nonatomic, strong) NSArray *managerIds;//管理员Ids


//多人会议字段
@property (nonatomic, assign) NSInteger mCallStatus;//多方通话的最新状态 1 会话存在   0 会话不存在
@property (nonatomic, assign) NSTimeInterval lastMCallStartTimeInterval;//记录最新一次发起通话的时间
@property (nonatomic, strong) NSString *mCallCreator;//发起人
@property (nonatomic, assign) NSInteger micDisable;//1：禁止发言 0：禁止发言解除
@property (nonatomic, assign) NSInteger recordStatus;//录音状态（默认为0)
@property (nonatomic, assign) NSInteger partnerType;//是否外部会话

@property (nonatomic, strong) NSString *todoPriStatus; //仅用于收到到推送消息
@property (nonatomic, assign) BOOL isRemoteMsg; // 仅用于群组收到远程推送消息时

@property (nonatomic, strong) NSString *dissolveDate;

//代办显示
@property (nonatomic,assign) NSInteger undoCount ;//未办总数
@property (nonatomic,assign) NSInteger notifyUnreadCount;//通知未读总数
@property (nonatomic,assign) NSInteger lastIgnoreNotifyScore;//忽略的最后一个score

@property (nonatomic,assign) NSInteger localUpdateScore;   //本地group组人员更新score
@property (nonatomic,assign) NSInteger updateScore;   //服务器group组人员更新score
@property (nonatomic,assign) NSInteger userCount;   //组人员数

- (id)initWithParticipant:(PersonSimpleDataModel *)participant;

- (PersonSimpleDataModel *)firstParticipant;
- (PersonSimpleDataModel *)participantForKey:(NSString *)key;

- (BOOL)chatAvailable;//是否具有聊天的权限
- (BOOL)actionAvailable;//是否具有操作的权限

- (BOOL)pushOpened;//是否打开了Push功能
- (void)togglePush;//切换Push规则

- (BOOL)isTop;//是否置顶
- (void)toggleTop; // 置顶或者取消置顶

- (BOOL)isFavorite;//是否已收藏
- (void)toggleFavorite;//收藏或者取消收藏

- (BOOL)qrCodeOpened;//是否已开启二维码
- (void)toggleQRCode;//开关二维码

- (BOOL)slienceOpened;//全员禁言
- (void)toggleslience;

- (BOOL)abortAddPersonOpened;//仅限管理员添加人员
- (void)toggleAbortAddPerson;

- (BOOL)isPublicGroup;

//是否为外部组
- (BOOL)isExternalGroup;

/**
 *  当前用户是否是管理员
 */
- (BOOL)isManager;

// 是否有@提及
- (BOOL)isNotifyTypeAt;

// 是否有新公告
- (BOOL)isNotifyTypeNotice;

- (KDAgoraMultiCallGroupType)getAgoraMultiCallGroup;

- (NSString *)getChannelId;
- (NSTimeInterval)getMCallStartTimeInterval;
- (NSString *)lastMsgDescWithRecord:(RecordDataModel *)record;
- (PersonSimpleDataModel *)packageToPerson;

//是否允许内部、外部分享
-(BOOL)allowInnerShare;
-(BOOL)allowOuterShare;
@end
