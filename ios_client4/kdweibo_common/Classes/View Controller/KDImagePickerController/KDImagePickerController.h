//
//  KDImagePickerController.h
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "KDAssetCollectionViewController.h"

@protocol KDImagePickerControllerDelegate;

@interface KDImagePickerController : UIViewController <UITableViewDataSource, UITableViewDelegate, KDAssetCollectionViewControllerDelegate>


@property (nonatomic, assign) id<KDImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) KDImagePickerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL showAssetView;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL limitsMinimumNumberOfSelection;
@property (nonatomic, assign) BOOL limitsMaximumNumberOfSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;
@property (nonatomic, retain) NSMutableArray *selectedAssetUrls;
@property (nonatomic, assign) BOOL bSendOriginal;
@property (nonatomic, assign) BOOL bCameraSource;
@property (nonatomic, assign) BOOL isFromXTChat;// 控制该界面是否有编辑按钮
@end

@protocol KDImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerControllerWillFinishPickingMedia:(KDImagePickerController *)imagePickerController;
- (void)imagePickerController:(KDImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info;
- (void)imagePickerControllerDidCancel:(KDImagePickerController *)imagePickerController;
- (NSString *)descriptionForSelectingAllAssets:(KDImagePickerController *)imagePickerController;
- (NSString *)descriptionForDeselectingAllAssets:(KDImagePickerController *)imagePickerController;
- (NSString *)imagePickerController:(KDImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos;
- (void)imagePickerController:(KDImagePickerController *)imagePickerController didSeletedEditImage:(UIImage *)image;

@end
