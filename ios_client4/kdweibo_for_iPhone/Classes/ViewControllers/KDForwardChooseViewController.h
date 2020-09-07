//
//  KDForwardChooseViewController.h
//  kdweibo
//
//  Created by kyle on 16/8/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "XTContentViewController.h"
#import "XTChooseContentViewController.h"

@protocol KDForwardChooseViewControllerDelegate;
@interface KDForwardChooseViewController : XTContentViewController

@property (nonatomic, assign) XTChooseContentType type;
@property (nonatomic, strong) NSMutableArray *blackList;
@property (nonatomic, strong) NSMutableArray *whiteList;
//@property (nonatomic, strong) NSMutableArray *selectPersons;

@property (nonatomic, strong) ContactClient *createExtenalChatClient;//外部联系人
@property (nonatomic, strong) ContactClient *createChatClient;
@property (nonatomic, strong) NSArray *wantCreateChatPersons;

@property (nonatomic, strong) XTShareDataModel *shareData;
@property (nonatomic, strong) NSArray *forwardData;
@property (nonatomic, assign) BOOL isFromFileDetailViewController;
@property (nonatomic, assign) BOOL bCreateExtenalGroup;//是否发起商务群聊
@property (nonatomic, weak) id <XTChooseContentViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isMulti;

@property (nonatomic, strong) NSDictionary *fileDetailDictionary;   //文件详情界面右上角分享按钮点击时用于储存文件信息

- (id)initWithCreateExtenalGroup:(BOOL)isExternalGroup;

@end
//@protocol KDForwardChooseViewControllerDelegate <NSObject>
////释放之前的会话
//- (void)popViewController;
//
//@end
