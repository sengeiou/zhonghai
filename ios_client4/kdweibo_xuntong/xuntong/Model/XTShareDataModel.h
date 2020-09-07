//
//  XTShareDataModel.h
//  XT
//
//  Created by Gil on 13-9-26.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _ShareMessageType{
    ShareMessageText = 1,
    ShareMessageImage = 2,
    ShareMessageNews = 3,
    ShareMessageApplication = 4,
    ShareMessageRedPacket = 5,
    ShareMessageCombineForward = 6,
}ShareMessageType;

@interface XTShareDataModel : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appName;

@property (nonatomic, assign) ShareMessageType shareType;
@property (nonatomic, assign) int unreadMonitor;

@property (nonatomic, copy) NSString *theme;
@property (nonatomic, strong) NSArray *participantIds;
@property (nonatomic, copy) NSString *system;

/** 多媒体数据对象，可以为XTShareTextDataModel，XTShareImageDataModel，XTShareNewsDataModel等。 */
@property (nonatomic, strong) id mediaObject;

// 轻应用扩展参数, 会议通知扩展形式 {"groupId":"xxxxxxxxxxxx"}
@property (nonatomic, strong) NSMutableDictionary *params;
//V5.0之后，分享可能有默认的人选，所以增加这个栏目
@property (nonatomic, strong) NSMutableArray *personIds;
// 专属红包params
@property (nonatomic, strong) NSMutableDictionary *redpacketParams;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface XTShareTextDataModel : NSObject

/** 向讯通终端提供的文本内容
 @note 文本长度必须大于0且小于10K
 */
@property (nonatomic, copy) NSString *text;

@end

@interface XTShareImageDataModel : NSObject

/** 图片真实数据内容
 * @note 大小不能超过300K
 */
@property (nonatomic, copy) NSString *imageData;

@end

@interface XTShareNewsDataModel : NSObject

/** 标题
 * @note 长度不能超过512字节
 */
@property (nonatomic, copy) NSString *title;
/** 描述内容
 * @note 长度不能超过1K
 */
@property (nonatomic, copy) NSString *content;
/** 缩略图数据
 * @note 大小不能超过32K
 */
@property (nonatomic, copy) NSString *thumbData;

/**
 *缩略图的URL
 */
@property (nonatomic, copy) NSString *thumbURL;

/** 网页的url地址
 * @note 不能为空且长度不能超过10K
 */
@property (nonatomic, copy) NSString *webpageUrl;

@end

@interface XTShareApplicationDataModel : XTShareNewsDataModel

/**
 *  在聊天界面显示的内容
 */
@property (nonatomic, copy) NSString *cellContent;
/**
 *  分享的对象：all（所有），group（组），person（人）
 */
@property (strong, nonatomic) NSString *sharedObject;
/**
 *  回调url（传入参数groupId或者personId），返回一串String，接到webpageUrl后面
 */
@property (strong, nonatomic) NSString *callbackUrl;

//轻应用ID
@property (strong, nonatomic) NSString *lightAppId;

- (BOOL)sharedToGroup;
- (BOOL)sharedToPerson;

@end

@interface XTShareCombineForwardDataModel : NSObject

@property (nonatomic, strong) NSString *content;    //内容，合并消息的前4条
@property (nonatomic, strong) NSString *mergeId;    //消息合并后的业务ID
@property (nonatomic, strong) NSString *title;      //标题，【xxx的聊天记录】;

@end



