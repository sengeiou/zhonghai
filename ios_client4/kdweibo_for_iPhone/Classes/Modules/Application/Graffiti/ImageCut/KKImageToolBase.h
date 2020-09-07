//
//  KKImageToolBase.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDImageEditorViewController.h"
#import "UIView+Frame.h"

static const CGFloat kImageToolAnimationDuration = 0.3; //工具栏平移动画时间

/**
 图片工具类 基类
 */
@interface KKImageToolBase : NSObject

@property (nonatomic, weak) KDImageEditorViewController *editor; //图片编辑vc

- (id)initWithImageEditor:(KDImageEditorViewController*)editor;

/**
 初始化工具信息
 */
- (void)setup;

/**
 取消修改
 */
- (void)cleanup;

/**
 保存修改
 */
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;
@end
