//
//  KDInviteColleaguesViewController.h
//  kdweibo
//
//  Created by 王 松 on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KDInviteIndex) {
    KDInviteIndexNoDefined,
    KDInviteIndexWeXin,
    KDInviteIndexQQ,
    KDInviteIndexContact,
    KDInviteIndexPhoneNum,
    KDInviteIndexLink,
    KDInviteIndexQRCode
};

typedef NS_ENUM(NSUInteger, KDInviteSource) {
    KDInviteSourceSidebar,//侧边栏
    KDInviteSourceShortcut,//加号
    KDInviteSourceContact//通讯录
};

@interface KDInviteColleaguesViewController : UIViewController

@property (nonatomic,assign) BOOL *hasBackBtn;
@property (assign, nonatomic) KDInviteSource inviteSource;
@property (nonatomic, assign) BOOL isFromFirstToDo;   //从首条代办跳转过来
@property (nonatomic, assign) BOOL bShouldDismissOneLayer; //只dismiss一层
@property (nonatomic, assign) BOOL showRightBtn; //是否显示右上角取消按钮，为了跟消息界面进来进行区分
@end
