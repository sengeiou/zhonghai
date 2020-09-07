//
//  KDSignInViewController+Medal.h
//  kdweibo
//
//  Created by shifking on 16/3/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController.h"
#define KDSigninMedalAlertTag 800002

@class KDSigninMedalModel;
@interface KDSignInViewController (Medal)
/**
 *  勋章榜弹窗
 *
 *  @param medalModel 勋章数据类型
 *
 *  @return 返回是否弹出了该弹窗
 */
- (BOOL)showMedalListAlertWithModel:(KDSigninMedalModel *)medalModel;

/**
 *  点击alert按钮，index:0、1
 */
- (void)clickAlertButtonWithIndex:(NSInteger)index;
@end
