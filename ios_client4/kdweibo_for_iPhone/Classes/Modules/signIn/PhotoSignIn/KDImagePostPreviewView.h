//
//  KDImagePostPreviewView.h
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDImagePostPreviewView;

@protocol KDImagePostPreviewViewDelegate <NSObject>

- (void)imagePostPreview:(KDImagePostPreviewView *)imagePostPreview didTapAtIndex:(NSUInteger)index;

- (void)imagePostPreview:(KDImagePostPreviewView *)imagePostPreview didTapAddedButton:(BOOL)tap;

- (void)videoThumbnailDidTapped;

- (void)deleteButtonClicked;

- (void)deleteFileClicked;

@end

@interface KDImagePostPreviewView : UIView

@property (nonatomic, assign) id<KDImagePostPreviewViewDelegate> delegate;

@property (nonatomic, retain) NSArray *assetURLs;
@property (nonatomic, assign) BOOL showAddedButton;
@property (nonatomic, retain) UIImage *videoThumbnail;
@property(nonatomic, retain) MessageFileDataModel *fileDataModel;// 分享文件

- (void)setVideoThumbnail:(UIImage *)videoThumbnail withSize:(NSString *)size;

@end
