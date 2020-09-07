//
//  KGMattsView.h
//  iAppRevision
//
//  Created by A449 on 15/11/24.
//  Copyright © 2015年 com.kinggrid. All rights reserved.
//

/*
 * 更新于：2017-01-16
 */

#import <UIKit/UIKit.h>

@class KGBrushCanvas, KGBrushColor;
@class KGAuthorization, KGBrushSettingView;

/** 移除视图的风格 */
typedef NS_ENUM(NSInteger, KGMattsViewDismissStyle) {
    
    KGMattsViewDismissStyleCancel = 0,
    KGMattsViewDismissStyleSave
};

/** 需要显示的操作按钮 */
/** mark - 该枚举由A732添加于2017.03.17 */
typedef NS_OPTIONS(NSUInteger, KGDisplayActionButton) {// 取消和保存按钮不可选（一直会显示）
    KGDisplayActionButtonAll        = 0,//默认为全部显示
    KGDisplayActionButtonDefault    = 1 << 0,//只显示取消和保存按钮
    KGDisplayActionButtonClear      = 1 << 1,//清空按钮
    KGDisplayActionButtonBackspace  = 1 << 2,//回退按钮
    KGDisplayActionButtonSpace      = 1 << 3,//空格按钮
    KGDisplayActionButtonLineFeed   = 1 << 4,//换行按钮
    KGDisplayActionButtonSetting    = 1 << 5,//设置按钮
};


typedef void(^KGMattsViewDismissStyleBlock)(KGMattsViewDismissStyle dismissStyle, UIImage *mattsImage);


@interface KGMattsView : UIView

/** 图片字体尺寸 */
@property (assign, nonatomic) CGSize wordSize DEPRECATED_MSG_ATTRIBUTE("已废弃，使用“-setPreviewSize:”代替"); //默认，{80, 80}

/** 初始化
 * @param size : 视图尺寸
 * @return : 视图实例
 */
- (instancetype)initWithSize:(CGSize)size;

/** 设置抄录文字
 *
 * @param text 抄录文字
 */
- (void)setTranscriptText:(NSString *)text;

/** 设置结束手写的间隔时间 
 * interval 间隔时间，单位为秒，最小为0.7
 */
- (void)setEndTimeInterval:(NSTimeInterval)interval;

/** 设置预览大小
 *
 * @param previewSize 预览大小，默认为80
 */
- (void)setPreviewSize:(CGFloat)previewSize;

/** 设置预览展示列数
 *
 * @param numberOfColumns 展示列数，默认为5
 */
- (void)setPreviewNumberOfColumns:(NSUInteger)numberOfColumns;

/** 设置预览的边界颜色
 *
 * @param color 颜色，默认为黑色
 */
- (void)setPreviewBorderColor:(UIColor *)color;

/** 设置预览之间的间隔距离
 *
 * @param space 间隔距离，默认为previewSize的五分之一
 */
- (void)setPreviewSpace:(CGFloat)space;

/** 设置是否完整预览（是否裁剪田字格中的空白部分）默认为NO
 *
 * @param full 是否预览完整田字格图片
 */
- (void)setPreviewFull:(BOOL)full;

/** 获取自定义每行展示数量的合成图片
 * @note 需要在"-dismissWithStyle:"后使用，且为“KGMattsViewDismissStyleSave”
 */
- (UIImage *)mattsImageWithRowWordNumber:(NSInteger)wordNumber DEPRECATED_MSG_ATTRIBUTE("已废弃，使用“-setPreviewNumberOfColumns:”代替");

/** 展示田字格视图 */
- (void)show;

/** 在指定视图上展示田字格
 *
 * @param view 指定的视图
 */
- (void)showInView:(UIView *)view;

/** 移除视图
 *
 * @param dismissStyleBlock 移除类型回调
 */
- (void)dismissWithStyle:(KGMattsViewDismissStyleBlock)dismissStyleBlock;


#pragma mark - Action按钮设置
/** 需要显示的Action按钮（取消和保存按钮不可选） */
/** mark - 该属性由A732添加于2017.03.17 */
@property (nonatomic, assign) KGDisplayActionButton displayActionButtons;

/** 设置功能的取消按钮标题
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionCancelButtonTitle:(NSString *)title forState:(UIControlState)state;

/** 设置功能的清空按钮标题
 *
 * @description 必须设置该按钮显示才能设置
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionClearButtonTitle:(NSString *)title forState:(UIControlState)state;

/** 设置功能的回退按钮标题
 *
 * @description 必须设置该按钮显示才能设置
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionBackspaceButtonTitle:(NSString *)title forState:(UIControlState)state;

/** 设置功能的空格按钮标题
 *
 * @description 必须设置该按钮显示才能设置
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionSpaceButtonTitle:(NSString *)title forState:(UIControlState)state;

/** 设置功能的换行按钮标题
 *
 * @description 必须设置该按钮显示才能设置
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionLineFeedButtonTitle:(NSString *)title forState:(UIControlState)state;

/** 设置功能的设置按钮标题
 *
 * @description 必须设置该按钮显示才能设置
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionSettingButtonTitle:(NSString *)title forState:(UIControlState)state;

/** 设置功能的保存按钮标题
 *
 * @param title 标题
 * @param state 状态
 */
- (void)setActionSaveButtonTitle:(NSString *)title forState:(UIControlState)state;

@end

#pragma mark - Class - KGMattsImageView
@interface KGMattsImageView : UIImageView

@end
