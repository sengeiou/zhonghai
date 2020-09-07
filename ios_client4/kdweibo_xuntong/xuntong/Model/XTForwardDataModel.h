//
//  XTForwardDataModel.h
//  XT
//
//  Created by kingdee eas on 13-11-13.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactLoginDataModel.h"

typedef enum _ForwardMessageType{
    ForwardMessageFile = 1,
    ForwardMessageText,
    ForwardMessagePicture,
    ForwardMessageNew,
    ForwardMessageLocation,
    ForwardMessageShortVideo,
    ForwardMessageCombine,
    ForwardMessageShareNews
}ForwardMessageType;

@class BubbleDataInternal;
@interface XTForwardDataModel : NSObject

@property (nonatomic, assign) ForwardMessageType forwardType;
@property (nonatomic, strong) NSString *message; //文本消息内容
@property (nonatomic, strong) id paramObject; //传递转发参数

//转发文字需要用到
@property (nonatomic, strong) NSString * contentString;
//转发图片需要用到
@property (nonatomic, strong) NSURL * thumbnailUrl;
@property (nonatomic, strong) NSURL * originalUrl;
@property (nonatomic, assign) BOOL bCanEditImage;
@property (nonatomic, strong) UIImage *editImage; //转发图片过程，图片经过了编辑后的图片(暂存)
//转发新闻需要用到
@property (nonatomic, copy) NSString * appName;
@property (nonatomic, copy) NSString * imageUrl;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * webUrl;
@property (nonatomic, copy) NSString * appId;

// 转发地理位置
@property (nonatomic, copy) NSString *file_id;//图片id
@property (nonatomic, copy) NSString *address;//地址
@property (nonatomic, assign) float latitude;//经度
@property (nonatomic, assign) float longitude;//纬度

// 转发小视频用
//@property (nonatomic, copy) NSString *file_id;//视频id，与地理位置共用
@property (nonatomic, copy) NSString *ext;//后缀
@property (nonatomic, copy) NSString *videoThumbnail;//短视频缩略图
@property (nonatomic, copy) NSString *size;//大小
@property (nonatomic, copy) NSString *mtime;//时间
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, copy) NSString *videoTimeLength;//视频长度
@property (nonatomic, copy) NSString *videoUrl;//名字

//合并转发
@property (nonatomic, copy) NSString *mergeId;
@property (nonatomic, strong) NSMutableArray *mergeRecords;
@property (nonatomic, strong) GroupDataModel *sourceGroup;
@property (nonatomic, strong) PubAccountDataModel *pubAccount;


@property (nonatomic, strong)BubbleDataInternal  *dataInternal;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
