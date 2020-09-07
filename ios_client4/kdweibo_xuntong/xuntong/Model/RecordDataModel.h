//
//  RecordDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

#define XTFileExt @".xt"

//消息类型, 0-系统,1—通话,2—文本,3—语音,4—图片
typedef enum _MessageType{
    MessageTypeSystem = 0,//系统消息
    MessageTypeCall = 1,//通话消息（已废弃）
    MessageTypeText = 2,//文本消息
    MessageTypeSpeech = 3,//语音消息
    MessageTypePicture = 4,//图片消息（已废弃，转为文件消息）
    MessageTypeAttach = 5,//操作类消息
    MessageTypeNews = 6,//新闻消息
    MessageTypeShareNews = 7,//分享消息
    MessageTypeFile = 8,//文件消息
    MessageTypeEvent = 9,//事件消息（界面不展现）
    MessageTypeLocation = 11,//位置
    MessageTypeCancel = 13,//撤回消息
    MessageTypeNotrace = 14,//无痕消息
    MessageTypeCombineForward = 16,// 合并转发
    MessageTypeShortVideo = 20, //小视频
}MessageType;

//消息状态,0—未读,1—已读
typedef enum _MessageStatus{
    MessageStatusUnread = 0,
    MessageStatusRead = 1
}MessageStatus;

////消息状态,0—未办,1—已办
//typedef enum _MessageStatusDoneState{
//    undo = 0,
//    done = 1
//}MessageStatusDoneState;

//消息方向 0—左边, 1—右边
typedef enum _MessageDirection{
    MessageDirectionLeft = 0,
    MessageDirectionRight = 1
}MessageDirection;

//额外的数据类型

//消息发送、接收状态
typedef enum _MessageRequestState{
    MessageRequestStateSuccess,//请求成功
    MessageRequestStateRequesting,//请求中
    MessageRequestStateFailue//请求失败
}MessageRequestState;

//播放状态
typedef enum _MessagePlayType{
    MessagePlayTypeSuccess,//服务器返回的数据
    MessagePlayTypeFailue//本地临时数据
}MessagePlayType;

@class MessageParamDataModel;
@interface RecordDataModel : BOSBaseDataModel

@property (nonatomic, copy) NSString *fromUserId;//发送者ID
@property (nonatomic, copy) NSString *sendTime;//发送时间
@property (nonatomic, copy) NSString *msgId;//消息ID
@property (nonatomic, assign) MessageType msgType;//消息类型
@property (nonatomic, assign) MessageStatus status;//消息状态
@property (nonatomic, assign) int msgLen;//消息时长,当消息类型为语音时有效
//消息内容,当消息类型为文本和通话时有效。如果消息为语音或者图片,需调用单独接口获取
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) MessageDirection msgDirection;
@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, strong) MessageParamDataModel *param;
@property (nonatomic, copy) NSString *translateMsgId;//其它消息转发过来的msgid

//额外字段
@property (nonatomic, assign) MessagePlayType msgPlayType;
@property (nonatomic, assign) MessageRequestState msgRequestState;
@property (nonatomic, copy) NSString *groupId;//组ID

@property (nonatomic, assign) int iNotifyType;          // 提醒类型, 1: @提及
@property (nonatomic, copy) NSString *strNotifyDesc;    // 提醒描述
@property (nonatomic, copy) NSString *strEmojiType;     // 表情字段 "emojiType"："original" 则是大图表情

@property (nonatomic, assign) BOOL bIsTheFisrtTodoInToday; // 是否是今天的第一条代办, 为了代办的cell显示"今天"的标题.
@property (nonatomic, strong) NSString * sourceMsgId;     //撤回消息的ID

//add by lee
@property (nonatomic, assign) BOOL bImportant; //重要消息
@property (nonatomic, copy) NSString *isOriginalPic; //是否有原图

@property (nonatomic, assign) NSInteger msgUnreadCount; //消息的已读未读
@property (nonatomic, strong) NSString *fromClientId;   //来自于桌面端
@property (nonatomic, strong) NSString *press;          //消息已读未读是否又被点击

@property (nonatomic, strong) NSString *clientMsgId; // msgList回调网络接口获得，用于防止msgList早于send回调，与本地的msgId做关联，不一定存在
@property (nonatomic, strong) NSString *localClientMsgId; // 和clientMsgId类似，但是是本地记录的，用于关联本地record和网络record

@property (nonatomic, strong) NSString *todoStatus; //针对代办的信息类型

//优化消息拉取 fromUserPhoto,fromUserName  这两个字段在数据库中复制而已
@property(nonatomic,strong) NSString *fromUserPhoto;//消息发送者头像
@property(nonatomic,strong) NSString *fromUserName;//消息发送者姓名

//本地语音文件路径，如果不存在，则返回nil
//仅对MessageTypeSpeech有效
-(NSString *)xtFilePath;

- (NSURL *)thumbnailPictureUrl;
- (NSURL *)originalPictureUrl;
- (NSURL *)bigPictureUrl;
- (NSString *)username;

- (NSURL *)midPictureUrl;
//可以转发的图片url
- (NSURL *)canTransmitUrl;
@end

//MessageTypeAttach
@interface MessageAttachEachDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *appId;
@end
@interface MessageAttachDataModel : BOSBaseDataModel
@property (nonatomic, strong) NSArray *attach;
@property (nonatomic, assign) int attachCount;
@property (nonatomic, copy) NSString *billId;
@property (nonatomic, copy) NSString *appId;
@end

//MessageTypeNews buttons
@interface MessageTypeNewsEventsModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *appid;
@end

//MessageTypeNews
@interface MessageNewsEachDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *name; //新闻内容图片的url，坑爹的后台，居然用name来返回，坑爹坑爹坑爹坑爹啊
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *row;
@property (nonatomic, strong) NSMutableArray *buttons;
- (BOOL)hasHeaderPicture;
- (BOOL)isSubNews; //判断是不是输入多图新闻里的单条新闻
@end
@interface MessageNewsDataModel : BOSBaseDataModel
@property (nonatomic, strong) NSMutableArray *newslist;
@property (nonatomic, assign) BOOL todoNotify;
@property (nonatomic, assign) int model;
@end

//MessageTypeShareNews
@interface MessageShareNewsDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *appId;//来源应用的AppId
@property (nonatomic, copy) NSString *appName;//来源应用的名称
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, copy) NSString *content;//内容
@property (nonatomic, copy) NSString *thumbUrl;//缩略图url
@property (nonatomic, copy) NSString *webpageUrl;//新闻地址
@property (nonatomic, copy) NSString *lightAppId;//轻应用ID
@end
//MessageTypeText or MessageTypePicture
@interface MessageShareTextOrImageDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *appId;//来源应用的AppId
@property (nonatomic, copy) NSString *appName;//来源应用的名称

@property (nonatomic) int effectiveDuration;//有效时长
@property (nonatomic, strong) NSDate *clientTime;//客户端时间

//add by fang
@property (nonatomic, copy) NSString *fileId;//发送的图片id
@property (nonatomic, copy) NSString *name;//发送的图片名称
@property (nonatomic, copy) NSString *ext;//发送的图片格式

//回复消息使用
@property (nonatomic, strong) NSString *replyMsgId;
@property (nonatomic, strong) NSString *replyPersonName;
@property (nonatomic, strong) NSString *replySummary;
@end


//MessageTypeFile
@interface MessageFileDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *appId;//来源应用的AppId
@property (nonatomic, copy) NSString *appName;//来源应用的名称
@property (nonatomic,copy) NSString *file_id;//文件ID
@property (nonatomic,copy) NSString *name;//文件名
@property (nonatomic,copy) NSString *uploadDate;//创建时间
@property (nonatomic,copy) NSString *size;//文件大小
@property (nonatomic,copy) NSString *ext;//文件扩展名
@property (nonatomic, copy) NSString *emojiType; // 表情类型 original
@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *wbUserId;
- (NSDictionary *)dictionaryFromMessageFileDataModel;
@property (nonatomic,strong) NSString *highlightName;//高亮显示的文件,不存储
@property (nonatomic,strong) NSString *fileSendTime;//文件消息的发送时间,不存储
@property (nonatomic,strong) NSString *fileSendPersonName;//文件消息的发送人,不存储

@end

//MessageTypeLocation
@interface MessageTypeLocationDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *file_id;//图片id
@property (nonatomic, copy) NSString *address;//地址
@property (nonatomic, assign) float latitude;//经度
@property (nonatomic, assign) float longitude;//纬度
@end

//MessageTypeVideo
@interface MessageTypeShortVideoDataModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *file_id;//图片id
@property (nonatomic, copy) NSString *ext;//后缀
@property (nonatomic, copy) NSString *videoThumbnail;//短视频缩略图
@property (nonatomic, copy) NSString *size;//大小
@property (nonatomic, copy) NSString *mtime;//时间
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, copy) NSString *videoTimeLength;//视频长度
@property (nonatomic, copy) NSString *videoUrl;//名字
- (NSString *)videoSize;
- (NSString *)videoDuartion;
- (NSString *)thumbImageUrl;
@end

//无痕消息
@interface MessageNotraceDataModel : BOSBaseDataModel

@property (nonatomic, assign) MessageType msgType; //真实消息类型，应该有文本和文件两种
@property (nonatomic, strong) NSString *content; // 如果是文本，则返回真实消息的文本内容
@property (nonatomic) int effectiveDuration; // 有效时间长度，单位秒
//如果是图片，则返回文件格式
@property (nonatomic, strong) NSString *file_id;//文件ID
@property (nonatomic, strong) NSString *name;//文件名
@property (nonatomic, strong) NSString *uploadDate;//创建时间
@property (nonatomic, strong) NSString *size;//文件大小
@property (nonatomic, strong) NSString *ext;//文件扩展名

@end

@interface MessageCombineForwardDataModel : BOSBaseDataModel

@property (nonatomic, strong) NSString *content;    //内容，合并消息的前4条
@property (nonatomic, strong) NSString *mergeId;    //消息合并后的业务ID
@property (nonatomic, strong) NSString *title;      //标题，【xxx的聊天记录】

@end


@interface MessageParamDataModel : BOSBaseDataModel

@property (nonatomic, assign) MessageType type;
//can be MessageAttachDataModel、MessageNewsDataModel、MessageShareNewsDataModel、MessageShareTextOrImageDataModel
@property (nonatomic, strong) id paramObject;
@property (nonatomic, copy) NSString *paramString;


- (id)initWithDictionary:(NSDictionary *)dict type:(MessageType)type;
- (id)initWithJSONString:(NSString *)jsonString type:(MessageType)type;

@end
