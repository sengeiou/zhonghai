//
//  UIActionSheet+ButtonEnabled.m
//  kdweibo
//
//  Created by shen kuikui on 14-5-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "UIActionSheet+ButtonEnabled.h"

@implementation UIActionSheet (ButtonEnabled)

- (void)setButtonAtIndex:(NSInteger)buttonIndex toEnabled:(BOOL)enabled
{
    for (UIView* view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (buttonIndex == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)])
                {
                    UIButton* button = (UIButton*)view;
                    button.enabled = enabled;
                }
            }
            
            buttonIndex--;
        }
    }
}

@end
