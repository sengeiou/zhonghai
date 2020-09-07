//
//  UIActionSheet+ButtonEnabled.h
//  kdweibo
//
//  Created by shen kuikui on 14-5-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (ButtonEnabled)

- (void)setButtonAtIndex:(NSInteger)buttonIndex toEnabled:(BOOL)enabled;

@end
