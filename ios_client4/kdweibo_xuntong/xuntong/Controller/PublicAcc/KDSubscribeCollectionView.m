//
//  KDSubscribeCollectionView.m
//  kdweibo
//
//  Created by wenbin_su on 15/9/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSubscribeCollectionView.h"
#import "KDSubscribeCell.h"

@implementation KDSubscribeCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if(self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        [self registerClass:[KDSubscribeCell class] forCellWithReuseIdentifier:NSStringFromClass([KDSubscribeCell class])];
        [self registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"view"];
        self.subscribeDataArray = [NSMutableArray new];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.subscribeDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDSubscribeCell *cell = [collectionView  dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KDSubscribeCell class]) forIndexPath:indexPath];
    cell.data = self.subscribeDataArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.frame.size.width, [NSNumber kdDistance2]);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"view" forIndexPath:indexPath];
        view.frame = CGRectMake(0,view.frame.origin.y, self.frame.size.width,[NSNumber kdDistance2]);
        view.backgroundColor = [UIColor kdSubtitleColor];
        return view;
    }
    return nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectItemAtIndexPath:indexPath animated:YES];
    
    if(self.subscribeCellDelegate)
    {
        self.subscribeCellDelegate(self.subscribeDataArray[indexPath.row]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 100);
}

@end

