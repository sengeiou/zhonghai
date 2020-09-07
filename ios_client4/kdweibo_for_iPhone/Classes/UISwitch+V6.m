//
//  UISwitch+V6.m
//  kdweibo
//
//  Created by lichao_liu on 7/16/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "UISwitch+V6.h"
#import "objc/runtime.h"
@implementation UISwitch (V6)
static char changeHandlerChar;

- (void)valueChanged:(id)sender
{
    changeHandler handler = [self changeHandler];
    if(handler)
    {
        handler(self.isOn);
    }
}

- (void)setChangeHandler:(changeHandler)changeHandler
{
     objc_setAssociatedObject(self, &changeHandlerChar, changeHandler, OBJC_ASSOCIATION_COPY);
     [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (changeHandler)changeHandler
{
     return objc_getAssociatedObject(self, &changeHandlerChar);
}
@end
