//
//  KDPhotoSignInCollectionViewCell.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDImageSource.h"

@protocol PhotoSignInCollectionViewCellDelegate;

@interface KDPhotoSignInCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) KDImageSource *imageSouce;
@property (nonatomic, assign) id<PhotoSignInCollectionViewCellDelegate> cellDelegate;
@property (nonatomic, strong) NSString *cacheImageUrl;
@property (nonatomic, assign) NSInteger cacheIndex;
@end

@protocol PhotoSignInCollectionViewCellDelegate <NSObject>

- (void)whenImageViewClickedWithSource:(KDImageSource *)imageSource atIndex:(NSInteger)index;

@optional
- (void)whenCacheImageViewClickedWithSource:(NSString *)cacheImageUrl atIndex:(NSInteger)index;
@end
