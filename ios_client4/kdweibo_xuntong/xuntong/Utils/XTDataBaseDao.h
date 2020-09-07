//
//  XTDataBaseDao.h
//  XT
//
//  Created by Gil on 13-7-31.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GroupDataModel.h"
#import "GroupListDataModel.h"
#import "RecordDataModel.h"
#import "PersonDataModel.h"
#import "RecordDataModel.h"
#import "ContactConfig.h"
#import "FileModel.h"
#import "T9SearchResult.h"
#import "FoldPublicDataModel.h"
#import "KDAppDataModel.h"
typedef NS_ENUM(NSUInteger, MessagePagingDirection)
{
    MessagePagingDirectionOld = 0,
    MessagePagingDirectionNew,
    MessagePagingDirectionCurrent,//取现有数据，包含自己，方向为New
};
@class FMDatabaseQueue;
@interface XTDataBaseDao : NSObject

@property (strong, nonatomic, readonly) NSString *openId;
@property (strong, nonatomic, readonly) NSString *eId;

//获取单例对象
+ (XTDataBaseDao *)sharedDatabaseDaoInstance;

//设置，如不设，运行会报错
//切换登录账户时需要重新设置
- (void)setOpenId:(NSString *)openId eId:(NSString *)eId;

//清空数据
- (BOOL)deleteAllData;
//清空数据除了人员表
- (BOOL)deleteAllDataExpectPersonTabale;

/**
 *  分页查询PrivateGroupList
 *
 *  @param limit       每页查询数量
 *  @param offset      偏移量
 *
 *  @return  个人组列表数据
 */
- (NSArray *)queryPrivateGroupListWithLimit:(int)limit offset:(int)offset;
/**
 *  分页查询fold的公共号数据
 *
 *  @param limit       limit
 *  @param offset      offset
 *
 *  @return fold的公共号数据
 */
- (NSArray *)queryFoldPublicGroupListWithLimit:(int)limit offset:(int)offset;
/**
 *  timeline页面fold的公共号展示所需model
 *
 *  @return FoldPublicDataModel对象
 */
- (FoldPublicDataModel *)queryFoldPublicModel;

/**
 *  删除所有折叠的公共号Group数据
 *
 *  @return 成功YES，失败 NO
 */
- (BOOL)deleteAllFoldPublicGroup;

/**
 *  查询xttimeline页签未读数
 *
 *  @return 查询xttimeline页签未读数
 */
- (NSUInteger)queryXTTimelineUnreadCount;

#pragma mark - private group
- (NSArray *)queryPrivateGroupList:(NSString **)unreadCount;
- (NSArray *)queryFavoriteGroupList:(NSString **)unreadCount;
- (GroupDataModel *)queryPrivateGroupWithPerson:(PersonSimpleDataModel *)person;
- (GroupDataModel *)queryPrivateGroupWithPersonForPublic:(PersonSimpleDataModel *)person;//填坑
- (GroupDataModel *)queryPrivateGroupWithGroupId:(NSString *)groupId;
- (GroupDataModel *)queryPrivateGroupWithGroupName:(NSString *)groupName;
- (NSArray *)queryPrivateTypeManyGroupList;

- (NSArray *)queryPrivateGroupsWithLikeGroupName:(NSString *)groupName;
- (NSArray *)queryPrivateGroupsWithIds:(NSString *)ids isPersonId:(BOOL)isPersonId;
//  without lastMessage
- (GroupDataModel *)queryPublicGroupWithPublicPersonId:(NSString *)personId;
// (personid) -> (GroupDataModel) with lastMessage
//- (GroupDataModel *)queryFullPublicGroupWithPersonId:(NSString *)personId;
- (BOOL)insertUpdatePrivateGroupList:(GroupListDataModel *)groupList;// needinsertUpdateScore:(BOOL)updateScore;
- (BOOL)updatePrivateGroupListWithUpdateTime:(NSString *)updateTime withGroupId:(NSString *)groupId;
- (BOOL)updatePrivateGroupListWithStatus:(int)status withGroupId:(NSString *)groupId;
- (BOOL)setPrivateGroupListToDeleteWithGroupId:(NSString *)groupId;
- (NSString *)queryLastContentExcludeEventMessageWithGroupId:(NSString *)groupId;
// 草稿
- (NSString *)queryDraftWithGroupId:(NSString *)groupId;
- (BOOL)updateDraft:(NSString *)strDraft withGroupId:(NSString *)groupId;
- (BOOL)removeDraftWithGroupId:(NSString *)groupId;

- (BOOL)updateNotifyType:(int)iNotifyType notifyDesc:(NSString *)strNotifyDesc withGroupId:(NSString *)groupId;
// 尝试清空private group的notifyType和notifyDesc, 依据是本group内是否还有@提及的message存在, 供ui一进聊天页面时调用.
// 另一处调用是在设置message已读时.(updateNotifyRecordStatusWithMsgId:grouId:)
- (void)updateNotifyToEmptyWithGroupId:(NSString *)groupId;

#pragma mark - public group
- (NSArray *)queryPublicGroupListWithPublicId:(NSString *)publicId;
- (BOOL)insertUpdatePublicGroupList:(GroupListDataModel *)groupList withPublicId:(NSString *)publicId;
- (BOOL)updatePublicGroupListWithUpdateTime:(NSString *)updateTime withGroupId:(NSString *)groupId withPublicId:(NSString *)publicId;
- (BOOL)setPublicGroupListToDeleteWithGroupId:(NSString *)groupId withPublicId:(NSString *)publicId;

#pragma mark - message

// 分页查询消息
- (NSArray *)queryRecordWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId count:(int)count msgId:(NSString *)strMsgId direction:(MessagePagingDirection)direction;
- (NSArray *)queryRecordsWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId fromMsgId:(NSString *)strMsgId;

//old
-(NSArray *)queryRecordWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId sendTime:(NSString *)sendTime count:(int)count;
- (NSArray *)queryRecordWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId page:(int)page count:(int)count;
- (NSArray *)queryRecordsWithGroupId:(NSString *)groupId toUserId:(NSString *)toUserId publicId:(NSString *)publicId fromMsgId:(NSString *)strMsgId;
- (NSArray *)queryAllPicturesWithGroupId:(NSString *)groupId
                                toUserId:(NSString *)toUserId
                                   msgId:(NSString *)msgId
                                sendTime:(NSString *)sendTime
                                   index:(NSString **)index;


// 检索提及信息集合
- (NSArray *)queryNotifyRecordsWithGroupId:(NSString *)groupId;

- (NSArray *)queryAllDocumentsWithGroupId:(NSString *)groupId
                                 toUserId:(NSString *)toUserId
                                pageIndex:(NSInteger)pageIndex
                                 isAtEnd : (BOOL *)isAtEnd;

- (NSArray *)queryAllContentWithGroupId:(NSString *)groupId
                               toUserId:(NSString *)toUserId
                                content:(NSString *)content
                              pageIndex:(NSInteger)pageIndex
                               isAtEnd : (BOOL *)isAtEnd;

- (NSArray *)queryAllPicturesWithGroupId:(NSString *)groupId
                                toUserId:(NSString *)toUserId
                               pageIndex:(NSInteger)pageIndex
                                isAtEnd : (BOOL *)isAtEnd;

- (BOOL)insertRecord:(RecordDataModel *)record toUserId:(NSString *)toUserId needUpdateGroup:(BOOL)needUpdateGroup publicId:(NSString *)publicId;
- (void)insertRecords:(NSArray *)records publicId:(NSString *)publicId;
- (BOOL)deleteRecordWithMsgId:(NSString *)msgId;
- (BOOL)deleteGroupAndRecordsWithGroupId:(NSString *)groupId publicId:(NSString *)publicId realDel:(BOOL)realDel;
- (BOOL)deleteRecordsWithGroupId:(NSString *)groupId;
- (BOOL)updateAllRecordsToReadWithGroup:(GroupDataModel *)group;
- (BOOL)updateGroupListWithGroup:(GroupDataModel *)group withPublicId:(NSString *)publicId;
-(NSDictionary *)queryMsgDicWithMsgId:(NSString *)msgId;
// 更新提及信息已读状态
- (BOOL)updateNotifyRecordStatusWithMsgId:(NSString *)msgId groupId:(NSString *)groupId;
- (NSArray *)queryFilesWithLikeName:(NSString *)name;
#pragma mark - Particpant
- (NSString *)queryGroupIdWithPublicPersonId:(NSString *)personId;
- (NSString *)queryPersonIdWithGroupId:(NSString *)groupId;
- (BOOL)deleteParticpantWithPersonIdArray:(NSArray *)personIdArray groupId:(NSString *)groupId;
- (BOOL)addParticpantWithPersonIdArray:(NSArray *)personIdArray groupId:(NSString *)groupId;

#pragma mark - person
- (int)initializeWithDataFilePath:(NSString *)filePath updateTime:(NSString **)updateTime;
//查询用户
- (PersonSimpleDataModel *)queryPersonWithPersonId:(NSString *)personId;
- (NSArray *)queryValidPersonWithPersonIds:(NSArray *)personIds;
- (PersonSimpleDataModel *)queryPersonDetailWithWebPersonId:(NSString *)webUserId;
- (NSArray *)queryPersonWithWbPersonIds:(NSArray *)wbPersonIds;
- (NSArray *)queryPersonWithPersonIds:(NSArray *)personIds;
- (NSArray *)queryPersonIdsWithPersonIds:(NSArray *)personIds;

- (NSArray *)queryAllContactPersonsContainPublic:(BOOL)isContain;//PersonSimpleDataModel

- (NSArray *)queryRecentPersonsWithLimitNumber:(int)limit isContainPublic:(BOOL)isContain;
- (BOOL)deleteRecentlyContact:(NSArray *)personIds;
//收藏的联系人
- (NSArray *)queryFavPersons;


//搜索栏查询
- (NSArray *)searchPersonsWithSearchText:(NSString *)searchText;
- (NSArray *)searchPersonsWithPhoneNumber:(NSString *)phoneNumber;
- (NSArray *)searchPersonsWithHanzi:(NSString *)hanzi;


//公共帐号
- (BOOL)deletePublicPersonSimpleSetall;//公共帐号的列表只保存24小时，就删除。
- (BOOL)updatePublicPersonSimpleSetsubscribe:(PersonSimpleDataModel *)person;
- (BOOL)insertPublicPersonSimple:(PersonSimpleDataModel *)person;
- (PersonDataModel*)queryPublicPersonSimple:(NSString *)personId;
- (PersonSimpleDataModel *)queryPublicAccountWithId:(NSString *)personId;
- (NSArray *)queryAllPublicPersonSimple;
- (NSArray *)queryPublicAccounts;
- (BOOL)insertPublicAccounts:(NSArray *)pubAccts;

- (BOOL)deleteAllPublicAccounts;
- (NSArray *)queryPublicAccountsWithLikeName:(NSString *)name;

- (NSArray *)queryPublicAccountsWithLikeName:(NSString *)name;
- (BOOL)updatePublicPersonSimpleSetShareStatus:(int)share withPersonId:(NSString *)personId; // 更新公共号的分享状态

//查询用户详情
- (PersonDataModel *)queryPersonDetailWithPersonId:(NSString *)personId;

- (PersonDataModel *)queryPersonDetailWithPerson:(PersonSimpleDataModel *)person;


- (PersonDataModel *)privateQueryPersonDetailWithPersonId:(NSString *)personId;

//插入用户详情
- (BOOL)insertPersonContacts:(PersonDataModel *)person;
- (BOOL)updatePersonStatus:(PersonSimpleDataModel *)person;

//个人应用
//- (BOOL)insertPersonalApp:(id)appDM withAppType:(int)appType;
//- (BOOL)insertPersonalApp2:(id)appDM withAppType:(int)appType;
- (BOOL)deletePersonalApp:(NSString *)appId;
- (NSArray *)queryPersonalAppsID;
- (NSArray *)queryPersonalApps;
-(BOOL)deleteAllPersonApps; //删除所有的app

- (BOOL)insertPersonalAppDataModel:(KDAppDataModel * )appDM;
- (NSArray *)queryPersonalAppList;  //KDAppDataModel

//- (BOOL)deletePersonalAppById:(NSString *)appId;




- (BOOL)insertPersonSimple:(PersonSimpleDataModel *)person;

- (NSArray *)queryAllUsers;
- (NSArray *)queryUsersWithPhoneNumber:(NSString *)phoneNumber;
- (NSArray *)queryUsersWithName:(NSString *)name;
- (PersonSimpleDataModel *)queryPersonWithResult:(T9SearchResult *)searchResult;
- (BOOL)updatePublicPersonSimpleSetPhotoUrl:(NSString *)personID PhotoUrl:(NSString *)photoUrl;


//个人详情页面插入职位表 add by lee
- (BOOL)insertPersonJob:(PersonSimpleDataModel *)person;

- (NSArray *)queryPersonWithOids:(NSArray *)oids;

//消息已读未读
- (void)insertMessageUnreadStateWithGroupId:(NSString *)groupId MsgId:(NSString *)msgId UnreadCount:(NSNumber *)unreadCount;
- (NSMutableDictionary *)queryMsgUnreadStateWithGroupId:(NSString *)groupId;
- (NSDictionary *)queryMsgUnreadStateWithMsgId:(NSString *)msgId;
- (BOOL)deleteMsgUnreadStateWithGroupId:(NSString *)groupId;
- (BOOL)deleteMsgUnreadStateWithMsgId:(NSString *)msgId;
- (BOOL)updateMsgUnreadStateWithMsgId:(NSString *)msgId
                      UnreadUserCount:(NSInteger)unreadUserCount;
- (BOOL)updateMsgPressStateWithMsgId:(NSString *)msgId
                          PressState:(NSString *)pressState;
- (BOOL)updateUnreadCountWithGroupId:(NSString *)groupId UnreadCount:(NSUInteger)unreadCount;



//代办
- (NSMutableArray *)queryAllToDo;
- (NSMutableArray *)queryAllUndoDoMsg;
- (NSMutableArray *)queryAllDoneMsg;
- (BOOL)deleteAllToDo;
- (void)updateToDoWhenHasMsgIdWithStatus:(NSString *)readState MsgId:(NSString *)msgId;
- (void)updateToDoWhenHasMsgIdWithDoneState:(NSString *)doneState MsgId:(NSString *)msgId;
- (void)updateToDoWhenHasSourceMsgIdWithReadState:(NSString *)readState SourceMsgId:(NSString *)sourceMsgId;
- (void)updateToDoWhenHasSourceMsgIdWithDoneState:(NSString *)doneState SourceMsgId:(NSString *)sourceMsgId;
- (void)insertToDoRecords:(NSArray *)records;
- (NSMutableArray *)queryToDomessageKind;
- (NSMutableArray *)queryPageOfToDoRecordWithSql:(NSString *)sql;

//代办状态
- (BOOL)insertToDoStateWithSourceMsgId:(NSString *)sourceMsgId ReadState:(NSString *)readState DoneState:(NSString *)doneState;
- (void)insertToDoStateWithArray:(NSMutableArray *)array;
- (void)updateToDoWithSourceMsgId:(NSString *)sourceMsgId ReadState:(NSString *)readState;

- (NSMutableArray *)queryAllToDoMsgId;
- (BOOL)deleteToDoDataWithMsgId:(NSString *)msgId;

- (void)updateToDoWithSourceMsgId:(NSString *)msgId doneState:(NSString *)doneState;
- (NSMutableArray *)queryUndoDoMsg;

//代办
- (BOOL)queryUnreadUndoMsg;
- (BOOL)queryUnreadNotificationMsg;


- (BOOL)queryUnreadUndoMsgWithTitle:(NSString *)title;
- (BOOL)queryUnreadNotificationMsgWithTitle:(NSString *)title;
- (GroupDataModel *)queryTodoMsgInXT;

//////插入用户详情
//- (BOOL)insertPersonContactWithPersons:(NSArray *)persons;//新人员联系方式表

// --------------------标记相关-----------------------
// 插入标记
- (BOOL)insertMarks:(NSArray *)marks;

// 删除标记
- (BOOL)deleteMarkWithMarkId:(NSString *)markId;

// 清空标记表
- (BOOL)clearMarkTable;

// 查询标记分页
- (NSArray *)queryMarksFromUpdateTime:(NSString *)lastUpdateTime pageCount:(int)page;

// 标记和日历事件关联表
- (BOOL)insertMarkEventWithMarkId:(NSString *)markId eventId:(NSString *)eventId;


- (NSArray *)searchTodoMsgWithSearchText:(NSString *)searchText type:(NSUInteger)todoType lastMsgId:(NSString *)lastMsgId;

// 处理代办更新界面问题
- (GroupDataModel *)queryTodoMsgInXT;

- (BOOL)updateUndoMsgWithId:(NSString *)msgId;

- (NSMutableArray *)queryUnreadNotificationMsgNum;
- (BOOL)deleteAllNotifyMsg;
- (BOOL)deleteAllUndoMsg;

- (BOOL)updateUndoMsgWithLastIgnoreNotifyScore:(NSString *)lastIgnoreNotifyScore;

//签到提醒
- (NSArray *)querySignInRemind;
- (BOOL)updateSignInRemindWithRemindId:(NSString *)remindId isRemind:(BOOL)isRemind remindTime:(NSString *)remindTime repeatType:(NSInteger)repeatType;
- (BOOL)addSignInRemindWithRemindId:(NSString *)remindId isRemind:(BOOL)isRemind remindTime:(NSString *)remindTime repeatType:(NSInteger)repeatType;
- (BOOL)addSignInRemindList:(NSArray *)remindList;
- (BOOL)deleteSignInRemindWithRemindId:(NSString *)remindId;
- (BOOL)deleteAllSignInRemind;

- (NSInteger)queryGroupLastUpdateScoreWithGroupId:(NSString *)groupId;
//查询本地已有score
- (NSInteger)queryGroupLocalUpdateScoreWithGroupId:(NSString *)groupId;
- (void)updateGroupLocalUpdateScoreWithGroupId:(NSString *)groupId updateScore:(NSString*) updateScore;

- (NSMutableArray *)queryGroupParticipateWithGroupId:(NSString *)groupId;
- (NSMutableArray *)queryGroupParticipatePersonsWithIds:(NSArray *)participantIds;
- (void)updateGroupParticipantWithGroupId:(NSString *)groupId participantIdArray:(NSArray *)participantIds;
@end

