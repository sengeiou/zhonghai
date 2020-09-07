//
//  KDPhotoSignInPhotoCollectionView.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KDPhotoSignInCollectionViewCellWidth 45
@protocol KDPhotoSignInPhotoCollectionViewDelegate;

@interface KDPhotoSignInPhotoCollectionView : UICollectionView
@property (nonatomic, assign) id<KDPhotoSignInPhotoCollectionViewDelegate> photoSignInCollectionViewDelegate;
- (void)setPhotoIdsArray:(NSArray *)photoIdArray;

- (void)setCacheImagesArray:(NSArray *)cachesArray;

@end


@protocol KDPhotoSignInPhotoCollectionViewDelegate <NSObject>

- (void)whenPhotoClickedAtIndex:(NSInteger)index sourceArray:(NSMutableArray *)sourceArray isCache:(BOOL)isCache;

@end