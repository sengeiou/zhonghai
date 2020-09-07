//
//  KDDatePickerViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 13-7-22.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^buttonTappedEventhandler)(void);


@interface KDDatePickerViewController : UIViewController
@property(nonatomic, copy) buttonTappedEventhandler leftbtnTappedEventHander;
@property(nonatomic, copy) buttonTappedEventhandler rightTappedEventHander;
@property(nonatomic, assign) UIDatePickerMode datePickerMode;
@property(nonatomic, strong) NSDate *date;

- (void)showInView:(UIView *)view;

- (void)hide;
@end
