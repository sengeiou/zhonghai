//
//  AppHeaderView.h
//  kdweibo
//
//  Created by 王 松 on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAppHeaderView : UIView

@property (nonatomic, assign) BOOL shouldCycelImages;

- (void)addCloseTarget:(id)target action:(SEL)action;

@end
