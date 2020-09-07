//
//  KDImagePickerAssetView.h
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol KDImagePickerAssetViewDelegate;

@interface KDImagePickerAssetView : UIView

@property (nonatomic, assign) id<KDImagePickerAssetViewDelegate> delegate;
@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL bIsCameraView;// 是否是第一个拍照按钮

@end

@protocol KDImagePickerAssetViewDelegate <NSObject>

@required
- (BOOL)assetViewCanBeSelected:(KDImagePickerAssetView *)assetView;
- (void)assetView:(KDImagePickerAssetView *)assetView didChangeSelectionState:(BOOL)selected;

@end
