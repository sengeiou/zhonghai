//
//  XTPubAccHistoryViewController.h
//  kdweibo
//
//  Created by fang.jiaxin on 16/5/17.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTChatViewController.h"

@interface XTPubAccHistoryViewController : UIViewController

@property (nonatomic, strong) PersonSimpleDataModel *pubAcc;
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) ChatMode chatMode;
@property (nonatomic, assign) BOOL ispublic;
@property (nonatomic, assign) BOOL isFirstLoad;
@end
