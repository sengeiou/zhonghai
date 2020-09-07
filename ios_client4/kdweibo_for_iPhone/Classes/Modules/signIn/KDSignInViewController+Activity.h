//
//  KDSignInViewController+Activity.h
//  kdweibo
//
//  Created by shifking on 15/10/30.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController.h"

@class KDSignInRecord;

@interface KDSignInViewController (Activity)

@property (assign , nonatomic) BOOL cancelActivity;

/*
 *显示活动
 */
- (BOOL)showActivityWithRecord:(KDSignInRecord *)record;

@end
