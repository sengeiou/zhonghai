//
//  XTPersonsCollectionView.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTPersonsCollectionView.h"
#import "XTPersonsCollectionViewCell.h"

@interface XTPersonsCollectionView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *personArray;

@end

@implementation XTPersonsCollectionView

- (void)setPersonsArray:(NSArray *)personArray
{
    if(self.personArray && self.personArray.count>0)
    {
        [self.personArray removeAllObjects];
    }
    
    if(personArray && personArray.count>0)
    {
        [self.personArray addObjectsFromArray:personArray];
    }
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if(self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        self.personArray = [NSMutableArray new];
        self.delegate = self;
        self.dataSource = self;
         [self registerClass:[XTPersonsCollectionViewCell class] forCellWithReuseIdentifier:@"XTPersonsCollectionViewCell"];
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
     [self registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"view"];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XTPersonsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XTPersonsCollectionViewCell" forIndexPath:indexPath];
    cell.personSimpleModel = self.personArray[indexPath.row];
    cell.deleteDelegate = self.deleteDelegate;
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.personArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(48, 64);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
@end
