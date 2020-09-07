//
//  KDActivityIndicatorView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-17.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDActivityIndicatorView : UIView

- (void)show:(BOOL)animated info:(NSString *)info;
- (void)hide:(BOOL)animated;

@end
