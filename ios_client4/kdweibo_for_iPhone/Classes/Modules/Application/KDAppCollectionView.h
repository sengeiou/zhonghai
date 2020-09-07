//
//  KDAppCollectionView.h
//  kdweibo
//
//  Created by Joyingx on 16/9/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDAppCollectionViewCell;

@protocol KDAppCollectionViewDelegate <UICollectionViewDelegate>

- (void)cellDidLongPressed:(KDAppCollectionViewCell *)cell;

- (BOOL)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;

@end

@interface KDAppCollectionView : UICollectionView

@property (nonatomic, weak) id<KDAppCollectionViewDelegate> kdDelegate;

@property (nonatomic, assign) BOOL enableSorting;
@property (nonatomic, assign) BOOL isSorting;

@property (nonatomic, strong, readonly) NSIndexPath *currentMovingIndexPath;

@end
