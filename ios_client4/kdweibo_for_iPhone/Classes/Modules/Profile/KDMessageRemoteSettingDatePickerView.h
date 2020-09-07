//
//  KDMessageRemoteSettingDatePickerView.h
//  kdweibo
//
//  Created by liwenbo on 15/12/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^completeSetupBlock)(NSDate *aDate);
typedef void(^cancelSetupBlock)(NSDate *aDate);
@interface KDMessageRemoteSettingDatePickerView : UIView


@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, copy) completeSetupBlock completeSetup;
@property (nonatomic, copy) cancelSetupBlock cancelSetup;



@end
