//
//  KDAlertView.h
//  kdweibo
//
//  Created by 王 松 on 13-12-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDAlertView2Delegate;

@interface KDAlertView2 : UIView

@property (nonatomic, assign) id<KDAlertView2Delegate> delegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<KDAlertView2Delegate>)delegate buttons:(NSArray *)buttons;

- (void)showInwindow:(UIWindow *)window;

@end

@protocol KDAlertView2Delegate <NSObject>

- (void)alertView:(KDAlertView2 *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)alertViewCancel:(KDAlertView2 *)alertView;

@end
