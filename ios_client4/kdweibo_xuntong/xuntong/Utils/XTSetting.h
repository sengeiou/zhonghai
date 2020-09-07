//
//  XTSetting.h
//  XunTong
//
//  Created by Gil on 13-4-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _XTSearchKeyboardType
{
    XTSearchKeyboardT9 = 0,
    XTSearchKeyboardSystem
}XTSearchKeyboardType;

typedef enum _XTChatKeyboardType
{
    XTChatKeyboardSpeech = 0,
    XTChatKeyboardText
}XTChatKeyboardType;

@interface XTSetting : NSObject

//会话列表时间线的最后更新时间
@property (nonatomic, copy) NSString *updateTime;
//公共号模式下pubAccounts的更新时间
@property (nonatomic, strong) NSMutableDictionary *pubAccountsUpdateTimeDict;
//T9搜索的索引更新时间
@property (nonatomic, copy) NSString *t9UpdateTime;
//语音搜索ID
@property (nonatomic, copy) NSString *grammarId;
//是否具有查看组织架构的权限
@property (nonatomic, assign) BOOL orgTree;

//默认的搜索键盘类型
@property (nonatomic, assign) XTSearchKeyboardType defaultSearchKeyboardType;
//默认的聊天键盘类型
@property (nonatomic, assign) XTChatKeyboardType defaultChatKeyboardType;

@property (nonatomic, assign) BOOL isCreate;

//mCloud参数获取的更新时间
@property (nonatomic, strong) NSString *paramFetchUpdateTime;
//公共号更新时间
@property (nonatomic, strong) NSString *pubAcctUpdateTime;
//轻应用列表更新时间
@property (nonatomic, copy) NSString *appListUpdateTime;

@property (strong, nonatomic, readonly) NSString *openId;
@property (strong, nonatomic, readonly) NSString *eId;

@property (nonatomic, assign) BOOL foldPublicAccountPressed;

@property (nonatomic, strong) NSString *msgLastReadUpdateTime;

@property (nonatomic, strong) NSString *msgLastDelUpdateTime;

@property (nonatomic, assign) BOOL pressMsgUnreadTipsOrNot;

//需要删除的会话组最后更新时间
@property (nonatomic, copy) NSString *groupExitUpdateTime;

//云通行证
@property (nonatomic,copy) NSString *cloudpassport;

//勿扰模式
@property (nonatomic, assign) BOOL isDoNotDisturbMode;

//清除指令
@property (nonatomic,copy) NSString *lastClearDataUpdateTime;

+(XTSetting *)sharedSetting;

//设置，如不设，运行会报错
//切换登录账户时需要重新设置
- (void)setOpenId:(NSString *)openId eId:(NSString *)eId;
- (BOOL)saveSetting;
- (void)cleanSetting;
@end
