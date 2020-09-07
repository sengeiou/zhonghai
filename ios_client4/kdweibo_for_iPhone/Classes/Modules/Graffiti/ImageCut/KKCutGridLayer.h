//
//  KKCutGridLayer.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 网格视图
 */
@interface KKCutGridLayer : CALayer
@property (nonatomic, assign) CGRect clippingRect; //裁剪范围
@property (nonatomic, strong) UIColor *bgColor;    //背景颜色
@property (nonatomic, strong) UIColor *gridColor;  //线条颜色
@end
