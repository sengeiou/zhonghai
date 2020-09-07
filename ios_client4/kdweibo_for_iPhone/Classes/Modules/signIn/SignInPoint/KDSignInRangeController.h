//
//  KDSignInRangeController.h
//  kdweibo
//
//  Created by lichao_liu on 15/4/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, KDSignInRangeType) {
    KDSignInRangeType_100 = 100,
    KDSignInRangeType_150 = 150,
    KDSignInRangeType_200 = 200,//默认
    KDSignInRangeType_250 = 250,
    KDSignInRangeType_300 = 300
};

typedef void (^KDSignInRangeChangeBlock)(KDSignInRangeType rangeType);
@interface KDSignInRangeController : UIViewController

@property (nonatomic, assign) KDSignInRangeType signInRangeType;
@property (nonatomic, copy) KDSignInRangeChangeBlock signInRangeChangeBlock;

@end
