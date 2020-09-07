//
//  KDAppCollectionViewLayout.m
//  kdweibo
//
//  Created by Joyingx on 16/9/8.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDAppCollectionViewLayout.h"
#import "KDApplicationCommon.h"

@interface KDAppCollectionViewLayout ()

//@property (nonatomic, assign) NSInteger itemCount;
//@property (nonatomic, assign) NSInteger rows;
//@property (nonatomic, assign) CGFloat marginH;
//@property (nonatomic, assign) CGFloat marginV;
//
///// 缓存计算过的区域布局
//@property (nonatomic, assign) CGRect cachedRect;
///// 缓存布局时的数据数量
//@property (nonatomic, assign) NSInteger cachedDataCount;
///// 缓存布局数组
//@property (nonatomic, strong) NSArray *cachedAttributesArray;

@end

@implementation KDAppCollectionViewLayout

//- (void)prepareLayout {
//    [super prepareLayout];
//    
//    self.itemCount = [self.collectionView numberOfItemsInSection:0];
//    CGSize viewSize = self.collectionView.bounds.size;
//    self.rows = ceil((double)self.itemCount / MAX_COUNT_INLINE);
//    self.marginH = (viewSize.width - self.itemSize.width * MAX_COUNT_INLINE - 24) / (MAX_COUNT_INLINE + 1);
//    self.marginV = kTopMargin;
//}
//
- (CGSize)collectionViewContentSize {
    CGSize size = [super collectionViewContentSize];
    if (size.height <= self.collectionView.bounds.size.height) {
        size.height = self.collectionView.bounds.size.height + 1;
    }
    
    return size;
}
//
//- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//    if (self.cachedDataCount == [self.collectionView numberOfItemsInSection:0]
//        && self.cachedAttributesArray && CGRectEqualToRect(self.cachedRect, rect)) {
//        return self.cachedAttributesArray;
//    }
//    
//    NSMutableArray<UICollectionViewLayoutAttributes *> *attributesArray =
//        [NSMutableArray<UICollectionViewLayoutAttributes *> array];
//    
//    // 遍历可见区域包含的Cell
//    NSInteger startRow = floor((rect.origin.y - self.marginV) / (self.itemSize.height + self.marginV)) > 0 ? : 0;
//    NSInteger endRow = floor((rect.origin.y + rect.size.height - self.marginV)) / (self.itemSize.height + self.marginV);
//    NSInteger startIndex = MAX(startRow * MAX_COUNT_INLINE, 0);
//    NSInteger endIndex = MIN((endRow + 1) * MAX_COUNT_INLINE, self.itemCount - 1);
//    
//    for (NSInteger i = startIndex; i <= endIndex; i++) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
//        [attributesArray addObject:attributes];
//    }
//    
//    // 将计算结果缓存起来
//    self.cachedRect = rect;
//    self.cachedDataCount = [self.collectionView numberOfItemsInSection:0];
//    self.cachedAttributesArray = attributesArray;
//
//    return attributesArray;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UICollectionViewLayoutAttributes *attributes =
//        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    NSInteger index = indexPath.item;
//    NSInteger row = index / MAX_COUNT_INLINE;
//    NSInteger column = index % MAX_COUNT_INLINE;
//    attributes.frame = CGRectMake(self.marginH * (column + 1) + self.itemSize.width * column + 12,
//                                  self.marginV * (row + 1) + self.itemSize.height * row,
//                                  self.itemSize.width, self.itemSize.height);
//    
//    return attributes;
//}

@end
