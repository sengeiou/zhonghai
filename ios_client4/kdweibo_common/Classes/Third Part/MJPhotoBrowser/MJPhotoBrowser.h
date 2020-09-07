//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>

@class MJPhoto;

@protocol MJPhotoBrowserDelegate;
@protocol MJOriginalViewDelegate;

@interface MJPhotoBrowser : UIViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)show;
- (void)show:(UIWindow *) window;
- (void)hide;
- (void)hideToolBar;
- (void)showToolBar;
@property (nonatomic, assign) BOOL bHideToolBar; // 隐藏所有按钮
@property (nonatomic, assign) BOOL bHideMenuBar; // 隐藏所有菜单
@property (nonatomic, assign) BOOL bHideSavePhotoBtn; // 隐藏保存图片按钮
@property (nonatomic, assign) BOOL bCanTransmit;
@property (nonatomic, assign) BOOL bCanCollect;
@property (nonatomic, assign) BOOL bCanEdit;
@property (nonatomic, strong) UIButton *buttonMore;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;
@end

@protocol MJPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

//识别二维码
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser scanWithresult:(NSString *)result;

//转发图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser transmitWithPhoto:(MJPhoto *)photo;
//收藏
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser collectWithPhoto:(MJPhoto *)photo;
// 编辑后的图片发送到当前会话组
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser sendAgainWithPhoto:(MJPhoto *)photo;

@end