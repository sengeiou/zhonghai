//
//  KDToDoMessageDataModel.h
//  kdweibo
//
//  Created by janon on 15/4/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KDToDoCellType) {
    KDToDoCellType_NotOperateAble = 0,
    KDToDoCellType_Operate_Show = 1,
    KDToDoCellType_Operate_Hide = 2
};


@interface KDToDoMessageDataModel : NSObject
@property (nonatomic, copy)   NSString *fromUserId;                     //发送者ID
@property (nonatomic, copy)   NSString *sendTime;                       //发送时间
@property (nonatomic, copy)   NSString *msgId;                          //消息ID
@property (nonatomic, assign) MessageType msgType;                      //消息类型
@property (nonatomic, assign) MessageStatus status;                     //消息状态
@property (nonatomic, assign) int msgLen;                               //消息时长,当消息类型为语音时有效
@property (nonatomic, copy)   NSString *content;                        //消息内容,当消息类型为文本和通话时有效。如果消息为语音或者图片,需调用单独接口获取
@property (nonatomic, assign) MessageDirection msgDirection;
@property (nonatomic, copy)   NSString *nickname;

@property (nonatomic, strong) MessageParamDataModel *param;

@property (nonatomic, assign) MessagePlayType msgPlayType;              //额外字段
@property (nonatomic, assign) MessageRequestState msgRequestState;
@property (nonatomic, copy)   NSString *groupId;                        //组ID

@property (nonatomic, assign) int iNotifyType;                          //提醒类型, 1: @提及
@property (nonatomic, copy)   NSString *strNotifyDesc;                  //提醒描述
@property (nonatomic, copy)   NSString *strEmojiType;                   //表情字段 "emojiType"："original" 则是大图表情

@property (nonatomic, assign) BOOL bImportant;                          //重要消息
@property (nonatomic, strong) NSString *sourceMsgId;
@property (nonatomic, strong) NSString *readState;                      //代办的已读未读状态
@property (nonatomic, strong) NSString *todoStatus;                     //代办的已读未读状态

@property (nonatomic, assign) BOOL bIsTheFisrtTodoInToday;              //是否是今天的第一条代办, 为了代办的cell显示"今天"的标题.

@property (nonatomic, strong) NSString *appid;
@property (nonatomic ,strong) NSString *row;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *date;

@property (nonatomic, strong) NSString *model;                          //param里面的类型
@property (nonatomic, strong) NSArray *list;                            //param里面的list数组

@property (nonatomic, assign) CGFloat caculateHeight;
@property (nonatomic, assign) BOOL shouldChangeToCellTypeShow;          //KDTodoOperateCell改变高度

@property (nonatomic, strong) NSString *XTMsgId;                        //代办消息的假ID,带XT头

@property (nonatomic, assign) KDToDoCellType cellType;

//@property (nonatomic, strong) NSString *XTMsgId;                        //代办消息的假ID,带XT头

@property (nonatomic, assign) CGFloat normalCellHeight;                 //用于存放普通的cell的高度
//@property (nonatomic, assign) BOOL status;                              //用于存放普通的cell的高度
@property(nonatomic,strong) NSString *isOriginalPic;

//为了不闪退先
@property(nonatomic,strong) NSString *fromClientId;
@property (nonatomic, strong) NSString *clientMsgId; // msgList回调网络接口获得，用于防止msgList早于send回调，与本地的msgId做关联，不一定存在

@property(nonatomic,strong) NSString *score;

//优化消息拉取 fromUserPhoto,fromUserName
@property(nonatomic,strong) NSString *fromUserPhoto;//消息发送者头像
@property(nonatomic,strong) NSString *fromUserName;//消息发送者姓名
//@property(nonatomic,strong) NSString *fromUserOrgId;//消息发送者部门id
//@property(nonatomic,strong) NSString *fromUserOrgName;//消息发送者部门名

-(void)adjustModelForCellTypeShow:(NSString *)string;
-(void)adjustModelForCellTypeHide;

-(CGFloat)caculateCellHeightForNormalCellWithString:(NSString *)string; //普通cell计算高度

- (id)initWithDictionary:(NSDictionary *)dict;
-(void)setParam:(MessageParamDataModel *)param;

- (NSString *)description;
@end



//代办删除消息
@interface HasMsgDelDateModel : BOSBaseDataModel

@property (nonatomic, strong) NSString *msgLastDelUpdateTime;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableArray *needDelUndoMsgIds;

- (id)initWithDictionary:(NSDictionary *)dict;
@end


@interface DeleteMsgDateModel : BOSBaseDataModel

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *msgId;

- (id)initWithDictionary:(NSDictionary *)dict;
@end

@interface DeleteUndoMsgDateModel : BOSBaseDataModel

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *msgId;

- (id)initWithDictionary:(NSDictionary *)dict;
@end