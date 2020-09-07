//
//  DailViewController.h
//  ContactsLite
//
//  Created by kingdee eas on 12-11-6.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "XTTimelineCell.h"
#import "XTChatViewController.h"
#import "XTChooseContentViewController.h"
#import "XTQRScanViewController.h"

#import "LeveyTabBarController.h"


@class XTShareDataModel;
@interface XTTimelineViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,XTGroupHeaderImageViewDelegate,XTQRScanViewControllerDelegate,XTChooseContentViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) UITableView *groupTableView;
@property (nonatomic,retain)MBProgressHUD *hud;
@property(nonatomic, assign) BOOL stillHideTabBar;
@property (nonatomic, assign) BOOL bGoMultiVoiceAfterCreateGroup;
@property (nonatomic, strong) GroupDataModel *pushGroup; // 推送过来，要进去的多人组
// 转发编辑后的图片
@property (nonatomic, strong)UIImage *editImage;


/**
 *	@brief	进入代办界面
 *
 *	@param 	group 	会话组
 */
- (void)toToDoViewControllerWithGroup:(GroupDataModel *)group;

//进入待办
//- (void)gotoToDoNewController;

/**
 *	@brief	进入聊天界面
 *
 *	@param 	group 	会话组
 *  @param 	msgId 	具体消息ID 是为了短信进来跳转到对应消息添加，之前没有 0316 没有则传空
 */
- (void)toChatViewControllerWithGroup:(GroupDataModel *)group withMsgId:(NSString *)msgId;

/**
 *	@brief	进入聊天界面
 *
 *	@param 	person 	人员信息
 */
- (void)toChatViewControllerWithPerson:(PersonSimpleDataModel *)person;

/**
 *	@brief	进入选人（创建组）界面
 *
 *	@param
 */
- (void)toChooseViewControllerWithShareData:(XTShareDataModel *)shareData;


-(void)toStatusDetailViewControllerWithID:(NSString *)sthID andType:(NSString *)type;

- (void)showMultiCallViewWithGroupDataModel:(GroupDataModel *)groupDataModel;
/**
 *	@brief	进入选人（创建组）界面
 *
 *	@param
 */
- (void)toChooseViewControllerWithForwardData:(XTForwardDataModel *)forwardData;


- (void)getGroupList;
@end
