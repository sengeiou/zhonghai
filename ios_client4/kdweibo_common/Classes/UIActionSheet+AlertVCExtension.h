//
//  UIActionSheet+AlertVCExtension.h
//  kdweibo_common
//
//  Created by fang.jiaxin on 2017/9/21.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (AlertVCExtension)

@property(nonatomic,strong)UIAlertController *alertVC;
-(void)showInVC:(UIViewController *)vc;

@end
