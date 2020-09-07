//
//  CustomAlertView.h
//  medicalCom
//
//  Created by bird on 14-3-23.
//  Copyright (c) 2014年 小熊. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAlertView;

typedef enum CustomAlertViewType{
    CustomAlertViewTypeTitleAlert = 0,
    CustomAlertViewTypeInputAlert
}CustomAlertViewType;

@protocol CustomAlertViewDelegate <NSObject>
- (void)buttonClick:(CustomAlertView *)alertView atIndex:(NSInteger)index;
@end

@interface CustomAlertView : UIView
@property (nonatomic, assign) id<CustomAlertViewDelegate> delegate;
@property (nonatomic, retain, readonly) UITextField *textField;
@property (nonatomic, retain, readonly) UILabel *titleName;

//展示界面
- (void)show;
- (id)initWithDelegate:(id<CustomAlertViewDelegate>)delegate alertType:(CustomAlertViewType)type meesage:(NSString *)msg title:(NSString *)title subTitle:(NSString *)subTitle cancelButtonTitle:(NSString *)firstTitle doneButtonTitle:(NSString *)secondTitle;
@end
