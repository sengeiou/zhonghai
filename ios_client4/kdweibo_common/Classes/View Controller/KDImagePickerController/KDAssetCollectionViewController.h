//
//  KDAssetCollectionViewController.h
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "KDImagePickerAssetCell.h"

typedef enum {
    KDImagePickerFilterTypeAllAssets,
    KDImagePickerFilterTypeAllPhotos
} KDImagePickerFilterType;

@protocol KDAssetCollectionViewControllerDelegate;

@interface KDAssetCollectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KDImagePickerAssetCellDelegate>

@property (nonatomic, assign) id<KDAssetCollectionViewControllerDelegate> delegate;
@property (nonatomic, retain) ALAssetsGroup *assetsGroup;
@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) KDImagePickerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL showsHeaderButton;
@property (nonatomic, assign) BOOL showsFooterDescription;
@property (nonatomic, copy) NSMutableArray *selectedAssetUrls;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL limitsMinimumNumberOfSelection;
@property (nonatomic, assign) BOOL limitsMaximumNumberOfSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;
@property (nonatomic, assign) BOOL bSendOriginal;
@property (nonatomic, assign) BOOL bCameraSource;
@property (nonatomic, assign) BOOL isFromXTChat;
@end

@protocol KDAssetCollectionViewControllerDelegate <NSObject>

@required
- (void)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController didFinishPickingAsset:(ALAsset *)asset;
- (void)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController didFinishPickingAssets:(NSArray *)assets;
- (void)assetCollectionViewControllerDidCancel:(KDAssetCollectionViewController *)assetCollectionViewController;
- (NSString *)descriptionForSelectingAllAssets:(KDAssetCollectionViewController *)assetCollectionViewController;
- (NSString *)descriptionForDeselectingAllAssets:(KDAssetCollectionViewController *)assetCollectionViewController;
- (NSString *)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos;
- (void)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController didSelectedEditImage:(UIImage *)image;
@end
