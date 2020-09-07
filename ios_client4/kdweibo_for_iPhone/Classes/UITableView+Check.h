//
//  UITableView+Check.h
//  kdweibo
//
//  Created by fang.jiaxin on 16/12/15.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Check.h"

typedef void(^UITableViewCheckBlock)(UITableViewCell *cell);


@interface UITableView (Check)

//需要在外部设置
@property (nonatomic, assign) BOOL showCheck;
//可根据需求决定是否设置
@property (nonatomic, strong) UITableViewCheckBlock checkBlock;


@property (nonatomic, strong) NSMutableDictionary *checkStateDic;//选中状态

//被勾选的celltag数组
-(NSArray *)getCheckArray;
@end
