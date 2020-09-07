//
//  XTBaseLogic.h
//  kdweibo
//
//  Created by bird on 14-4-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XTBaseLogicDelegate <NSObject>

- (BOOL)shouldShowAppTutorialsViewController;

//- (void)showGuideViewController;

- (void)showMainViewController;
@end

@class GroupDataModel;
@class PersonSimpleDataModel;
@class XTShareDataModel;
@interface XTBaseLogic : NSObject
{}
@property (nonatomic, retain) NSDictionary *remoteNotificationInfo;
@property (nonatomic, retain) NSDictionary *remoteNotificationInfoCall;
@property (nonatomic, assign) id<XTBaseLogicDelegate> delegate;

//- (void)launched;
- (void)command;
- (void)registerPushToken:(NSData *)token;
- (BOOL)applicationHandleOpenURL:(NSURL *)url;

- (void)xtLogout;

- (void)receiveRemoteNotification:(NSDictionary *)userInfo;

- (void)handleEventAfterLogin;

- (void)openLoginViewController;
- (void)openStarLoginViewController;

//从沟通列表界面到聊天界面
- (void)setupTabBeforetimelineToChat;
- (void)timelineToChatWithGroup:(GroupDataModel *)group withMsgId:(NSString *)msgId;
- (void)timelineToChatWithPerson:(PersonSimpleDataModel *)person;
- (void)timelineToChooseWithShareData:(XTShareDataModel *)shareData;
//从通讯录界面到组织架构界面
- (void)contactToOrganizationWithOrgId:(NSString *)orgId;
- (void)receiveRemoteNotificationWithInActiveWithUserInfo:(NSDictionary *)userInfo;

@end
