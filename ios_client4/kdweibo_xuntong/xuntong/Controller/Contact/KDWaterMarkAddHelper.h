//
//  KDWaterMarkAddHelper.h
//  kdweibo
//
//  Created by 张培增 on 16/1/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDWaterMarkAddHelper : NSObject

//在tableView背景加水印
+ (void)addToBackgroundViewOfTableView:(UITableView *)tableView;

//删除tableView背景水印
+ (void)removeWaterMarkFromTableView:(UITableView *)tableView;

//水印盖在View上面
+ (void)coverOnView:(UIView *)view withFrame:(CGRect)frame;

//删除盖在View上的水印
+ (void)removeWaterMarkFromView:(UIView *)view;

@end
