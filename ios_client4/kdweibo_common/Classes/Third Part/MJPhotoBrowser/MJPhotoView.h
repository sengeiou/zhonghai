//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@protocol MJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;
@end

typedef NS_ENUM(NSInteger, MJPhotoViewMode) {
    MJPhotoViewModeDefault,
    MJPhotoViewModeOriginal
};

@interface MJPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) MJPhoto *photo;
// 代理
@property (nonatomic, weak) id<MJPhotoViewDelegate> photoViewDelegate;
// 模式
@property (nonatomic, assign) MJPhotoViewMode mode;

@property (nonatomic, assign) BOOL bHideMenuBar; // 隐藏所有菜单

- (void)prepareForReuse;
- (void)hide;
@end