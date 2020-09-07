//
//  KDWorkDayPickerViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 13-8-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRootViewController.h"


typedef void(^WorkDayPickerBlock)(NSInteger repeatType);
@interface KDWorkDayPickerViewController : KDSignInRootViewController
@property (nonatomic, copy) WorkDayPickerBlock workDayPickerBlock;
@property (nonatomic,assign) NSInteger repeatType;
@end
