//
//  KDImageEditorViewController.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKImageEditorDelegate <NSObject>
@optional
- (void)imageDidFinishEdittingWithImage:(UIImage*)image;

@end

@interface KDImageEditorViewController : UIViewController<UIScrollViewDelegate>{

    __weak UIScrollView *_scrollView; //readonly
}

@property (nonatomic, strong) UIImageView *imageView;   //显示的图片

@property (nonatomic, readonly) UIScrollView *scrollView; //图片的父视图，裁剪后大小会变化
@property (nonatomic, strong)  UIView *menuView;        //底部工具
@property (nonatomic,weak) id<KKImageEditorDelegate> delegate;

- (instancetype)initWithImage:(UIImage*)image delegate:(id<KKImageEditorDelegate>)delegate;

- (void)refreshImageView;
- (void)refreshImageViewWith:(UIImage *)rotateImage;

- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

- (void)pushedDoneBtn:(id)sender;
- (void)clearBoard;
@end
