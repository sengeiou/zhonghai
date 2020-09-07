//
//  iAppRevisionView.h
//  iAppRevision
//
//  Created by A449 on 15/12/9.
//  Copyright © 2015年 com.kinggrid. All rights reserved.
//

/*
 * 更新于：2017-03-06
 */

#import <UIKit/UIKit.h>

#import "KGTypeDefines.h"

@class iAppRevision;
@class KGBrushCanvas, KGBrushColor;

/** 保存签名的闭包 */
typedef void(^iAppRevisionViewSaveSignatureBlock)(UIImage *iAppRevisionViewImage, UIImage *signatureImage, CGRect signatureRect);

#pragma mark - iAppRevisionView
/* 2017-03-01 */
@interface iAppRevisionView : UIView

/** 签名类型 */
@property (assign, nonatomic) KGSignatureType signatureType;
/** 是否开启水印 */
@property (assign, nonatomic, getter=isWatermark) BOOL watermark;

//手写签名类型的设置选项
/** 手写签名的笔锋类型 */
@property (assign, nonatomic) KGHandwritingType handwritingType;
/** 手写签名的笔锋宽度（0 ~ 1] */
@property (assign, nonatomic) CGFloat handwritingWidth;
/** 手写签名的笔锋颜色 */
@property (copy, nonatomic) UIColor *handwritingColor;
/** 手写路径的集合 */
@property (nonatomic, copy, readonly) NSArray *brushPaths;

//文本签批类型的设置选项
/** 文本字体 */
@property (copy, nonatomic) UIFont *textFont;
/** 文本颜色 */
@property (copy, nonatomic) UIColor *textColor;
/** 文本 */
@property (nonatomic, copy) NSString *text;
/** 最大字符长度，为0则不限制 */
@property (nonatomic, assign) NSUInteger maxNumberOfText;

/** 创建水印图片
 * @param baseSize : 画布大小
 * @param baseImage : 目标图片(批注信息图片)
 * @param image : 需要添加的水印图片（个人签名）
 * @param imageRect : 水印图片（个人签名）相对于目标图片的位置的尺寸
 * @param text : 需要添加的水印文字（时间戳）
 * @param textRect : 水印文字（时间戳）相对于目标图片的位置的尺寸
 * @param textAttributes : 水印文字（时间戳）的属性 默认:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
 *                                                    NSForegroundColorAttributeName: [UIColor blackColor]}
 * @return : 水印完成的图片
 */
+ (UIImage *)createImageWithBaseSize:(CGSize)baseSize baseImage:(UIImage *)baseImage addImage:(UIImage *)image imageRect:(CGRect)imageRect andText:(NSString *)text textRect:(CGRect)textRect textAttributes:(NSDictionary *)textAttributes;

/** 水印图片 (即将弃用)
 * 即将弃用，使用“+createImageWithBaseSize:baseImage:addImage:imageRect:andText:textRect:textAttributes:”代替
 * @param image : 需要添加的水印图片（个人签名）
 * @param text : 需要添加的水印文字（时间戳）
 * @param annotationImage : 目标图片（手写批注信息图片）
 * @param textColor : 水印文字的颜色（默认为黑色）
 * @return : 水印完成的图片
 */
+ (UIImage *)setImage:(UIImage *)image andText:(NSString *)text inSignatureImage:(UIImage *)annotationImage textColor:(UIColor *)textColor;

/** 水印图片
 * @param originImage : 原图
 * @param content : 水印内容，不可为空
 * @param color 颜色，默认黑色
 * @param position : 水印位置，默认右下角
 * @param scaleFactor : 缩放因子，(0, 1]，默认0.5
 * @return : 水印图片
 */
+ (UIImage *)watermarkImage:(UIImage *)originImage content:(NSString *)content color:(UIColor *)color position:(KGWatermarkPosition)position scaleFactor:(CGFloat)scaleFactor;

/** 水印图片
 * @param originImage : 原图
 * @param content : 水印内容，不可为空
 * @param textAttributes 水印文字属性
 * @param position : 水印位置，默认右下角
 * @param gapPoint : 水印偏移量
 * @return : 水印图片
 */
+ (UIImage *)watermarkImage:(UIImage *)originImage content:(NSString *)content textAttributes:(NSDictionary *)textAttributes position:(KGWatermarkPosition)position gapPoint:(CGPoint)gapPoint;

/** 将路径集合转成路径字符串
 * @param brushPaths 路径集合
 *
 * @return 路径字符串
 */
+ (NSString *)brushPathWithPaths:(NSArray *)brushPaths;

/** 将路径字符串还原成路径集合
 * @param brushPath 路径字符串
 *
 * @return 路径集合
 */
+ (NSArray *)brushPathsFromPath:(NSString *)brushPath;

/** 盖章
 * note 盖章签名类型的设置选项
 * @param image : 盖章图片
 */
- (void)stampWithImage:(UIImage *)image;

/** 设置水印内容
 * @param content : 水印内容，不可为空
 * @param color 颜色，默认黑色
 * @param position : 水印位置，默认右下角
 * @param scaleFactor : 缩放因子，(0, 1]，默认0.5
 */
- (void)setWatermarkWithContent:(NSString *)content color:(UIColor *)color position:(KGWatermarkPosition)position scaleFactor:(CGFloat)scaleFactor;

/** 撤销操作 */
- (void)undo;

/** 恢复操作 */
- (void)redo;

/** 清屏操作 */
- (void)clean;

/** 渲染画板
 * @param paths 路径集合
 */
- (void)renderViewWithPaths:(NSArray *)paths;

/** 保存签名
 * @param completion : 完成回调
 */
- (void)saveSignatureWithCompletion:(iAppRevisionViewSaveSignatureBlock)completion;
@end

#pragma mark - Class - KGHandwritingView
/* 2017-03-01 */
@interface KGHandwritingView : UIView

/** 是否开启水印 */
@property (assign, nonatomic, getter=isWatermark) BOOL watermark;
/** 手写签名的笔锋类型 */
@property (assign, nonatomic) KGHandwritingType handwritingType;
/** 手写签名的笔锋宽度（0 ~ 1] */
@property (assign, nonatomic) CGFloat handwritingWidth;
/** 手写签名的笔锋颜色 */
@property (copy, nonatomic) UIColor *handwritingColor;
/** 手写路径的集合 */
@property (nonatomic, copy, readonly) NSArray *brushPaths;

/** 撤销操作 */
- (void)undo;

/** 恢复操作 */
- (void)redo;

/** 清屏操作 */
- (void)clean;

/** 设置水印内容
 * @param content : 水印内容，不可为空
 * @param color 颜色，默认黑色
 * @param position : 水印位置，默认右下角
 * @param scaleFactor : 缩放因子，(0, 1]，默认0.5
 */
- (void)setWatermarkWithContent:(NSString *)content color:(UIColor *)color position:(KGWatermarkPosition)position scaleFactor:(CGFloat)scaleFactor;

- (void)renderViewWithPaths:(NSArray *)paths;

/** 保存签名
 * @param completion : 完成回调
 */
- (void)saveHandwritingSignatureWithCompletion:(iAppRevisionViewSaveSignatureBlock)completion;

@end

#pragma mark - Class - KGTextView

@interface KGTextView : UIView

/** 显示输入辅助视图，默认：NO */
@property (assign, nonatomic, getter=isShowInputAccessoryView) BOOL showInputAccessoryView;
/** 是否开启水印 */
@property (assign, nonatomic, getter=isWatermark) BOOL watermark;
/** 文字字体 */
@property (copy, nonatomic) UIFont *textFont;
/** 文字颜色 */
@property (copy, nonatomic) UIColor *textColor;
/** 文本 */
@property (nonatomic, copy) NSString *text;
/** 最大字符长度，为0则不限制 */
@property (nonatomic, assign) NSUInteger maxNumberOfText;

/** 设置水印内容
 * @param content : 水印内容，不可为空
 * @param color 颜色，默认黑色
 * @param position : 水印位置，默认右下角
 * @param scaleFactor : 缩放因子，(0, 1]，默认0.5
 */
- (void)setWatermarkWithContent:(NSString *)content color:(UIColor *)color position:(KGWatermarkPosition)position scaleFactor:(CGFloat)scaleFactor;

/** 清屏操作 */
- (void)clean;

/** 保存签名
 * @param completion : 完成回调
 */
- (void)saveTextSignatureWithCompletion:(iAppRevisionViewSaveSignatureBlock)completion;

@end

#pragma mark - Class - KGSealView
@interface KGSealView : UIView

/** 是否开启水印 */
@property (assign, nonatomic, getter=isWatermark) BOOL watermark;

/** 盖章
 * @param image : 盖章图片
 */
- (void)stampWithImage:(UIImage *)image;

/** 清屏操作 */
- (void)clean;

/** 设置水印内容
 * @param content : 水印内容，不可为空
 * @param color 颜色，默认黑色
 * @param position : 水印位置，默认右下角
 * @param scaleFactor : 缩放因子，(0, 1]，默认0.5
 */
- (void)setWatermarkWithContent:(NSString *)content color:(UIColor *)color position:(KGWatermarkPosition)position scaleFactor:(CGFloat)scaleFactor;

/** 保存盖章
 * @param completion : 完成回调
 */
- (void)saveSealSignatureWithCompletion:(iAppRevisionViewSaveSignatureBlock)completion;

@end
