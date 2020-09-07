//
//  KDImagePickerAssetCell.h
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDImagePickerAssetView.h"

@protocol KDImagePickerAssetCellDelegate;

@interface KDImagePickerAssetCell : UITableViewCell <KDImagePickerAssetViewDelegate>

@property (nonatomic, assign) id<KDImagePickerAssetCellDelegate> delegate;
@property (nonatomic, copy)  NSArray *assets;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSUInteger numberOfAssets;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL showTakeButton;
@property (nonatomic, assign) NSIndexPath* indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfAssets margin:(CGFloat)margin;

- (void)selectAssetAtIndex:(NSUInteger)index;
- (KDImagePickerAssetView *)assetAtIndex:(NSUInteger)index;
- (void)deselectAssetAtIndex:(NSUInteger)index;
- (void)selectAllAssets;
- (void)deselectAllAssets;

@end

@protocol KDImagePickerAssetCellDelegate <NSObject>

@required
- (BOOL)assetCell:(KDImagePickerAssetCell *)assetCell canSelectAssetAtIndex:(NSUInteger)index;
- (void)assetCell:(KDImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index;
- (void)takePhotoBtnClicked:(id)sender;
- (void)assetCell:(KDImagePickerAssetCell *)assetCel didTouchPreviewWithTag:(NSInteger)tag;
@end
