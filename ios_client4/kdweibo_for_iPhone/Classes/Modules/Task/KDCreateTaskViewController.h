//
//  KDCreateTaskViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 13-7-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTask.h"

typedef enum{
    KDCreateTaskReferTypeComment,
    KDCreateTaskReferTypeStatus,
    KDCreateTaskReferTypeDMMessge,
    KDCreateTaskReferTypeChatMessage
}KDCreateTaskReferType;

@interface KDCreateTaskViewController : UIViewController
@property(nonatomic,retain)id referObject;
@property(nonatomic,assign)KDCreateTaskReferType referType;
@end
