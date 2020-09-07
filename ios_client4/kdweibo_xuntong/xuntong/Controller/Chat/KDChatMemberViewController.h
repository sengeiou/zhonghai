//
//  KDChatMemberViewController.h
//  kdweibo
//
//  Created by liwenbo on 16/2/16.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTChatDetailViewController.h"

typedef enum : NSUInteger{
    
    KDChatMemberViewControllerTypeNormal = 1,
    KDChatMemberViewControllerTypeDelete,
    KDChatMemberViewControllerTypeManager
    
} KDChatMemberViewControllerType;


@interface KDChatMemberViewController : UIViewController

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) KDChatMemberViewControllerType type;



@property (nonatomic, weak)XTChatDetailViewController *chooseContentDelegate;
@end
