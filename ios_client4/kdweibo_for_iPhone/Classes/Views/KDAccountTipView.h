//
//  KDAccountTipView.h
//  kdweibo
//
//  Created by 王 松 on 13-10-25.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

typedef enum KDAccountTipViewType{
    KDAccountTipViewTypeSuccess = 0,
    KDAccountTipViewTypeFaild,
    KDAccountTipViewTypeAlert
}KDAccountTipViewType;

typedef void (^KDAccountTipViewBlock)(void);


#import <UIKit/UIKit.h>

@interface KDAccountTipView : UIView

@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) NSString *buttonTitle;

@property (nonatomic, retain) NSString *message;

@property (nonatomic, copy) KDAccountTipViewBlock block;


/**
 *  初始化
 *
 *  @param title    标题
 *  @param message  message
 *  @param btntitle 按钮title
 *  @param block
 *
 *  @return KDAccountTipView
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)btntitle completeBlock:(KDAccountTipViewBlock)block;

/**
 *  显示tipView
 *
 *  @param type KDAccountTipViewType
 */
- (void)showWithType:(KDAccountTipViewType)type window:(UIWindow *)window;

@end
