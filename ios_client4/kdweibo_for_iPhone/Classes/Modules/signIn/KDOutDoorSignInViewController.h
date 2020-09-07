//
//  KDOutDoorSignInViewController.h
//  kdweibo
//
//  Created by lichao_liu on 9/22/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDLocationData.h"
#import "KDSignInRootViewController.h"
typedef enum{
    OutDoor_Type_None,
    OutDoor_Type_CUSTOMER_VISIT,
    OutDoor_Type_LOOK_STORE
}OutDoor_Type;


typedef void (^KDSignInOutDoorViewControllerBlock)(NSString *content, NSString *photoIds, NSString *cacheStr , OutDoor_Type type);

@interface KDOutDoorSignInViewController : KDSignInRootViewController
@property (nonatomic, copy) KDSignInOutDoorViewControllerBlock completeBlock;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) KDLocationData *locationData;
@end
