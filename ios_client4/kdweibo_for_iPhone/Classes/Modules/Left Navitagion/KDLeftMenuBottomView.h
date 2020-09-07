//
//  KDLeftMenuBottomView.h
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDLeftMenuBottomView : UIView

+ (instancetype)bottomView;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
