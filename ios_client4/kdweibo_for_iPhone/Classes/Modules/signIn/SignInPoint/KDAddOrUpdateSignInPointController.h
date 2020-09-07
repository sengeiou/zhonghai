//
//  KDAddSignInPointController.h
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInPoint.h"
#import "KDSignInRootViewController.h"


typedef NS_ENUM(NSInteger, KDAddOrUpdateSignInPointType) {
    KDAddOrUpdateSignInPointType_add,
    KDAddOrUpdateSignInPointType_update,
    KDAddOrUpdateSignInPointType_delete
};

@protocol KDAddOrUpdateSignInPointControllerDelegate<NSObject>
- (void)addOrUpdateSignInPointSuccess:(KDSignInPoint *)signInPoint signInPointType:(KDAddOrUpdateSignInPointType)signInPointType rowIndex:(NSInteger)index;
@end

@interface KDAddOrUpdateSignInPointController : KDSignInRootViewController

@property (nonatomic, assign) id<KDAddOrUpdateSignInPointControllerDelegate> delegate;

@property (nonatomic, assign) KDAddOrUpdateSignInPointType addOrUpdateSignInPointType;

@property (nonatomic, copy) KDSignInPoint *signInPoint;
@property (nonatomic, strong) NSString *sourceAttSetsStr;   //签到组已有签到点的数据,用于在签到组中新增签到点判断重复问题
@property (nonatomic, strong) NSString *signInPointId;      //签到点id,用于查询签到点详情
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) BOOL isFromSetSignInPointVC;

@end
