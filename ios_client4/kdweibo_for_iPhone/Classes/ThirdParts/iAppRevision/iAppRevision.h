//
//  iAppRevision.h
//  iAppRevision
//
//  Created by A449 on 15/1/9.
//  Copyright (c) 2015年 com.kinggrid. All rights reserved.
//

/** iAppRevision开发包版本更新信息
 *
 * 版本：3.1.0.238
 * 日期：2017-12-20
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class KGAuthorization;

@interface iAppRevision : NSObject

/** 授权是否成功 */
@property (readonly, assign, nonatomic) BOOL isAuthorized;

/** 设置打印模式，默认：NO */
@property (assign, nonatomic, getter=isDebugMode) BOOL debugMode;

/** iAppRevision单例初始化 
 * @return : iAppRevision对象
 */
+ (instancetype)sharedInstance;

/** 注册App
 * @param key 授权码
 */
+ (void)registerApp:(NSString *)key;

/** 获取两个Rect的并集 
 * @param rect1 区域1
 * @param rect2 区域2
 *
 * @return 并集区域
 */
+ (CGRect)rectByUnion:(CGRect)rect1 withRect:(CGRect)rect2;

/** 将十六进制颜色的字符串转为UIColor
 *
 * @param hexadecimal 十六进制颜色的字符串
 * @param alpha 渲染值
 *
 * @return UIColor
 */
+ (UIColor *)colorWithHexadecimal:(NSString *)hexadecimal alpha:(CGFloat)alpha;

/** 获取合成图片
 * @param image 图片1
 * @param imageRect 图片1的合成位置
 * @param otherImage 图片2
 * @param otherImageRect 图片2的合成位置
 * @param inRect 合成区域
 *
 * @return 合成图片
 */
+ (UIImage *)imageByCompound:(UIImage *)image withRect:(CGRect)imageRect otherImage:(UIImage *)otherImage otherRect:(CGRect)otherImageRect inRect:(CGRect)inRect;

/** 将文字转成图片
 * @param string 字符串
 * @param attributes 属性
 * @param inRect 范围
 *
 * @return 文字图片
 */
+ (UIImage *)imageWithString:(NSString *)string attributes:(NSDictionary *)attributes inRect:(CGRect)inRect;

/** 获取视图控制器
 *
 * @return 视图控制器
 */
+ (UIViewController *)viewController;

/** 从视图中获取其控制器
 * @param view 视图
 *
 * @return 视图控制器
 */
+ (UIViewController *)viewControllerWithView:(UIView *)view;

/** 获取授权信息 
 * @return : 授权信息词典
 */
- (NSDictionary *)authorizedInfo;

@end
