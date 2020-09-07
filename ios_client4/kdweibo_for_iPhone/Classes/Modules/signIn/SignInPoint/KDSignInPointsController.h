//
//  KDSignInPointsController.h
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KDSignInPoint;

typedef NS_ENUM(NSInteger, KDSignInPointsSouceType) {
    KDSignInPointsSouceType_settingController,
    KDSignInPointsSouceType_photoController
};

@protocol KDSignInPointsControllerDelegate <NSObject>
- (void)didSelectSignInPoint:(KDSignInPoint *)signInPoint;
@end

@interface KDSignInPointsController : UIViewController
@property (nonatomic, assign) KDSignInPointsSouceType sourceType;
@property (nonatomic, assign) id<KDSignInPointsControllerDelegate> delegate;
@end
