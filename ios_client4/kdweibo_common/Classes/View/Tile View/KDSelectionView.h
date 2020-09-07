//
//  KDSelectionView.h
//  kdweibo_common
//
//  Created by shen kuikui on 12-9-28.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDSelectionView;

@protocol KDSelectionViewDelegate <NSObject>

@optional

- (void)kdselectionView:(KDSelectionView *)selectionView  didSelectButtonAtIndex:(NSInteger)index;

@end

@protocol KDSelectionViewDataSource <NSObject>

@required
- (NSInteger)numberOfSectionsInKDSelectionView:(KDSelectionView *)selectionView;
- (NSString *)kdSelectionView:(KDSelectionView *)selectionView titleForButtonAtIndex:(NSInteger)index;

@optional
- (UIView *)cursorViewForKDSelectionView:(KDSelectionView *)selectionView;

@end

@interface KDSelectionView : UIView
{
//    id<KDSelectionViewDelegate> delegate_;
//    id<KDSelectionViewDataSource> dataSource_;
}

@property (nonatomic, assign) id<KDSelectionViewDelegate> delegate;
@property (nonatomic, assign) id<KDSelectionViewDataSource> dataSource;

- (void)clickButtonAtIndex:(NSInteger)index;

@end
