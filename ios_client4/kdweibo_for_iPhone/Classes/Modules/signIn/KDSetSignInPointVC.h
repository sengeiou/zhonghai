//
//  KDSetSignInPointVC.h
//  kdweibo
//
//  Created by shifking on 15/9/18.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRootViewController.h"
#import "KDAddOrUpdateSignInPointController.h"

@class KDLocationData;

typedef enum{
    SetSignInPointSource_signinPointVC,              //管理签到点页面点击进入
    SetSignInPointSource_addOrupdateSignInPointVC    //增加或更新签到点页面进入
}SetSignInPointSource;
typedef void(^DeterMineChooseLocationBlock)(KDLocationData * locationData , id controller);
typedef void(^AddOrUpdateSignInPointSuccessBlock)(KDSignInPoint *signInPointInfo, KDAddOrUpdateSignInPointType type);

@interface KDSetSignInPointVC : KDSignInRootViewController

@property (nonatomic, strong) DeterMineChooseLocationBlock determineBlock;
@property (nonatomic, strong) AddOrUpdateSignInPointSuccessBlock addOrUpdateSignInPointSuccessBlock;
@property (assign , nonatomic) SetSignInPointSource sourceType;
@property (nonatomic, assign) CGFloat kdistance;//范围
@property (nonatomic, strong) NSString *sourceAttSetsStr;//签到组已有签到点的数据,用于在签到组中新增签到点判断重复问题
@property (nonatomic, strong) KDLocationData *tempLocationData;
@end
