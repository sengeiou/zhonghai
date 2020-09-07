//
//  KDPersonFooterBar.h
//  kdweibo
//
//  Created by Gil on 15/7/15.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDPersonFooterBarDelegate;
@interface KDPersonFooterBar : UIView
@property (nonatomic, strong, readonly) UIButton *msgButton;
@property (nonatomic, strong, readonly) UIButton *callButton;

@property (nonatomic, assign) id<KDPersonFooterBarDelegate> delegate;

@end

@protocol KDPersonFooterBarDelegate <NSObject>
@optional
- (void)personFooterViewMsgButtonPressed:(UIView *)view;
- (void)personFooterViewPhoneButtonPressed:(UIView *)view;
@end