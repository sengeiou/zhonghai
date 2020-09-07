//
//  UITableViewCell+Check.h
//  kdweibo
//
//  Created by fang.jiaxin on 16/12/15.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Check)

//不允许在外部设置
@property (nonatomic, assign) BOOL showCheck;

//可以在外部设置normal跟selected两种状态的图片
@property (nonatomic, strong) UIButton *checkBtn;

//可以在外部设置
@property (nonatomic, assign) BOOL isCheck;

//以下需要在cellForIndexPath里重新赋值
@property (nonatomic, assign) BOOL allowCheck;
@property (nonatomic, weak) UITableView *parentTableView;
@property (nonatomic, strong) id<NSCopying> cellTag;//标识唯一行key
@end
