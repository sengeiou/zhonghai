//
//  KDWebViewController+LongPress.h
//  kdweibo
//
//  Created by shifking on 15/10/29.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
// 

#import "KDWebViewController.h"

@interface KDWebViewController (LongPress)
- (void)setupLongPressEvent;
- (BOOL)longPressShareActionWithTitle:(NSString *)title actionSheet:(UIActionSheet *)actionSheet;
@end
