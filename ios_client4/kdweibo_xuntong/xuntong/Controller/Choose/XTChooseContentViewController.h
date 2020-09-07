//
//  XTChooseContentViewController.h
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContentViewController.h"
#import "XTSelectPersonsView.h"
#import "XTShareDataModel.h"
#import "MBProgressHUD.h"
#import "XTGroupTimelineViewController.h"
#import "XTShareView.h"
#import "XTForwardDataModel.h"

typedef enum _XTChooseContentType{
    XTChooseContentCreate,
    XTChooseContentAdd,
    XTChooseContentShare,
    XTChooseContentForward,    //转发
    XTChooseContentShareStatus,
    XTChooseContentJSBridgeSelectPerson,//给KDWebViewController提供选人功能，用JS桥调用
    XTChooseContentJSBridgeSelectPersons,
    XTChooseContentForwardMulti //多选转发
}XTChooseContentType;
//XTChooseContentJSChoose

@protocol XTChooseContentViewControllerDelegate;
@interface XTChooseContentViewController : XTContentViewController <XTSelectPersonsViewDataSource,XTSelectPersonsViewDelegate,MBProgressHUDDelegate,XTGroupTimelineViewControllerDelegate,XTShareViewDelegate,UITextFieldDelegate>

@property (nonatomic, assign, readonly) XTChooseContentType type;
@property (nonatomic, assign) XTChooseContentType createByType;
@property (nonatomic, strong, readonly) XTSelectPersonsView *selectPersonsView;
@property (nonatomic,assign) BOOL isMult; //增加新属性，用来判断是否多选，默认为多选

@property (nonatomic, strong) NSArray  *selectedPersons; //已经选择了的人
@property (nonatomic, strong) NSMutableArray *blackList;
@property (nonatomic, strong) NSMutableArray *whiteList;
@property (nonatomic, strong) NSMutableArray *recentGroups;


// 下面两个属性用于js桥，两个属性只会有一个有值
@property (nonatomic, strong) NSArray *selectedMobiles;
@property (nonatomic, strong) NSArray *selectedOids;

@property (nonatomic, strong) XTShareDataModel *shareData;
@property (nonatomic, strong) id forwardData;
@property (nonatomic, weak) id<XTChooseContentViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL bSetAdmin;// 标题改为@“设置管理员”， 退出工作圈用

@property (nonatomic, assign) BOOL bGoMultiVoiceAfterCreateGroup;

/**
 *  可选人员类型（默认是1）>> 1、所有类型人员 2、内部人员 3、商务伙伴
 */
@property (nonatomic, assign) NSInteger pType;

//语音会议为了添加那个提示
@property (nonatomic, assign) BOOL inviteFromAgora;
@property (nonatomic, strong) NSArray  *selectedAgoraPersons; //已经选择了的参会人员
@property (nonatomic, strong) GroupDataModel *exitedGroup;
@property (nonatomic, assign) BOOL blockCurrentUser;

- (id)initWithType:(XTChooseContentType)type;
- (id)initWithType:(XTChooseContentType)type isMult:(BOOL)isMult;


@end

@protocol XTChooseContentViewControllerDelegate <NSObject>

@optional
//选择了一个组
- (void)chooseContentView:(XTChooseContentViewController *)controller group:(GroupDataModel *)group;
//选择了一个人（未找到与此人存在任何组）
- (void)chooseContentView:(XTChooseContentViewController *)controller person:(PersonSimpleDataModel *)person;
//选择了一个或者多个人（仅用于XTChooseContentAdd 和 XTChooseContentJSChoose）
- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons;
//释放之前的会话
- (void)popViewController;
//取消选择联系人，在点击关闭的时候调用
-(void)cancelChoosePerson;


//JSBridge_selectPerson
- (void)chooseContentView:(XTChooseContentViewController *)controller selectedPerson:(NSArray *)persons;
//JSBridge_selectPersons
- (void)chooseContentView:(XTChooseContentViewController *)controller selectedPersons:(NSArray *)persons;
@end
