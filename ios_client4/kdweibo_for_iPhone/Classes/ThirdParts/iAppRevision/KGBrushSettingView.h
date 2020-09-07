//
//  BrushSettingView.h
//  iAppRevision
//
//  Created by apple on 15/1/10.
//  Copyright (c) 2015年 com.kinggrid. All rights reserved.
//

/*
 * 更新于 2017-01-13
 */
#import <UIKit/UIKit.h>
#import "KGTypeDefines.h"

/** 笔刷设置信息改动回调闭包 */
typedef void(^KGBrushSettingViewBrushValueDidChangeBlock)(NSDictionary *brushValueInfo);

@interface KGBrushSettingView : UIView

/** 是否本地化 */
@property (assign, nonatomic, getter=isLocalized) BOOL localized;

/** 通过键获取对应的值
 * @param localizedKey : 键
 * @return : 设置信息
 */
+ (NSDictionary *)brushValueInfoWithKey:(NSString *)localizedKey;

/** 初始化
 * @param localizedKey : 键
 * @return : 实例对象
 */
- (instancetype)initWithLocalizedKey:(NSString *)localizedKey;

/** 初始化
 * @param brushType : 笔刷类型
 * @param brushWidth : 笔刷宽度，返回为(0~1]
 * @param brushColor : 笔刷颜色
 * @return : 实例对象
 */
- (instancetype)initWithBrushType:(KGHandwritingType)brushType brushWidth:(CGFloat)brushWidth brushColor:(UIColor *)brushColor;

/** 设置本地化键
 * @param localizedKey : 键
 */
- (void)setLocalizedKey:(NSString *)localizedKey;

/** 展示笔刷设置视图 */
- (void)show;

/** 在指定的视图中展示笔刷设置视图 */
- (void)showInView:(UIView *)view;

/* 点击关闭按钮
 * @param completion : 完成回调
 */
- (void)dismissWithCompletion:(KGBrushSettingViewBrushValueDidChangeBlock)completion;

@end

UIKIT_EXTERN NSString *const KGBrushSettingViewKeyBrushType;
UIKIT_EXTERN NSString *const KGBrushSettingViewKeyBrushWidth;
UIKIT_EXTERN NSString *const KGBrushSettingViewKeyBrushColor;

UIKIT_EXTERN NSString *const KGBrushSettingViewKeySettingsPlist;
