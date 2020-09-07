//
//  CKSlideSwitchView.h
//  ScrollviewTabDemo
//
//  Created by vike on 4/2/14.
//  Copyright (c) 2014 longversion. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CKSlideSwitchViewDelegate;

static const CGFloat KFontSizeOfTabButton = 17.0f;


typedef NS_ENUM(NSInteger, KScrollviewRunType)  {
    KScrollviewRunType_nomal,
    KScrollviewRunType_left,
    KScrollviewRunType_right
};

@interface CKSlideSwitchView : UIView
@property (nonatomic, strong) UIColor *tabItemTitleNormalColor;
@property (nonatomic, strong) UIColor *tabItemTitleSelectedColor;
@property (nonatomic, strong) UIImage *tabItemNormalBackgroundImage;
@property (nonatomic, strong) UIImage *tabItemSelectedBackgroundImage;
@property (nonatomic, strong) UIImage *tabItemShadowImage;
@property (nonatomic, strong) UIColor *tabItemShadowColor;
@property (nonatomic, strong) UIImage *topScrollviewBackgroundImage;
@property (nonatomic, strong) UIColor *topScrollViewBackgroundColor;
@property (nonatomic, strong) UIScrollView *rootScrollview;
@property (nonatomic, assign) id<CKSlideSwitchViewDelegate> slideSwitchViewDelegate;

- (void)reloadData;

- (NSInteger)currentSelectedTabItemIndex;

- (UIView *)currentSelectedViewInRootScrollview;
- (UIView *)findContentViewWithIndex:(NSInteger)index;

@end

@protocol CKSlideSwitchViewDelegate <NSObject>

@required
//topscrollview中tabitem的个数
- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView numberOfTabItemForTopScrollview:(UIScrollView *)topScrollview;
//topscrollview中tabitem所对应的title的值
- (NSString *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView titleForTabItemForTopScrollviewAtIndex:(NSInteger)index;
//rootscrollview中的子view
- (UIView *)slideSwitchView:(CKSlideSwitchView *)slideSwitchView viewForRootScrollViewAtIndex:(NSInteger)index;
//设置每个tabitem的高度
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightForTabItemForTopScrollview:(UIScrollView *)topScrollview;
@optional
//设置顶部的栏目的宽度
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView widthForTopScrollview:(UIScrollView *)topScrollview;
//设置偏移量
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView marginForTopScrollview:(UIScrollView *)topscrollview;
//设置每个tabitem的宽度
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView widthForTabItemForTopScrollview:(UIScrollView *)topScrollview;
//设置tabitem中按钮font的大小
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView fontSizeForTabItemForTopScrollview:(UIScrollView *)topScrollview;
/**
 **  首次启动选择tabitem 中的第几个
 */
- (NSInteger)slideSwitchView:(CKSlideSwitchView *)slideSwitchView selectedTabItemIndexForFirstStartForTopScrollview:(UIScrollView *)topScrollview;
//topscrollview上的tabitem 分割线
- (BOOL )slideSwitchView:(CKSlideSwitchView *)slideSwitchView seperatorImageViewShowInTopScrollview:(UIScrollView *)topScrollview;
- (CGFloat)slideSwitchView:(CKSlideSwitchView *)slideSwitchView heightOfShadowImageForTopScrollview:(UIScrollView *)topScrollview;

- (void)slideSwitchView:(CKSlideSwitchView *)slideSwitchView currentIndex:(NSInteger)index;

- (void)slideSwitchViewConfigRootScrollviewSuccess;
@end
