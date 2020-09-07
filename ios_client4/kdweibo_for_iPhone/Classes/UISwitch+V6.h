//
//  UISwitch+V6.h
//  kdweibo
//
//  Created by lichao_liu on 7/16/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^changeHandler)(BOOL isOn);
@interface UISwitch (V6)
- (void)setChangeHandler:(changeHandler)changeHandler;

- (changeHandler)changeHandler;
@end
