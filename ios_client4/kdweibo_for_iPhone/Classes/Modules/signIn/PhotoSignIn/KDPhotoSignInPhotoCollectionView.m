//
//  KDPhotoSignInPhotoCollectionView.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInPhotoCollectionView.h"
#import "KDPhotoSignInCollectionViewCell.h"
#import "KDConfigurationContext.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface KDPhotoSignInPhotoCollectionView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PhotoSignInCollectionViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *photoIdArray;
@property (nonatomic, strong) NSMutableArray *imageSoureArray;

@property (nonatomic,strong) NSMutableArray *cachesImageArray;
@property (nonatomic, strong) UILabel *imagesLabel;

@end

@implementation KDPhotoSignInPhotoCollectionView

- (void)setUpImagesLabel
{
    //不能使用autolayout，否则iOS7上会崩溃
    self.imagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDPhotoSignInCollectionViewCellWidth-12-2, KDPhotoSignInCollectionViewCellWidth-12-2, 12, 12)];
    self.imagesLabel.backgroundColor = [UIColor colorWithRGB:0x04142a alpha:0.7];
    self.imagesLabel.textColor = FC6;
    self.imagesLabel.textAlignment = NSTextAlignmentCenter;
    self.imagesLabel.font = FS9;
    self.imagesLabel.layer.cornerRadius = 6;
    self.imagesLabel.layer.masksToBounds = YES;
    self.imagesLabel.hidden = YES;
    [self addSubview:self.imagesLabel];
}

- (void)setPhotoIdsArray:(NSArray *)photoIdArray
{
    if(self.photoIdArray && self.photoIdArray.count>0)
    {
        [self.photoIdArray removeAllObjects];
    }
    
    if(photoIdArray && photoIdArray.count>0)
    {
        [self.photoIdArray addObjectsFromArray:photoIdArray];
        [self compositeImageSouce];
        
        self.imagesLabel.hidden = NO;
        self.imagesLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)photoIdArray.count];
    }else{
        self.imagesLabel.hidden = YES;
        self.imagesLabel.text = @"";
    }
    [self reloadData];
}

- (void)setCacheImagesArray:(NSArray *)cachesArray
{
    if(self.cachesImageArray && self.cachesImageArray.count>0)
    {
        [self.cachesImageArray removeAllObjects];
    }
    
    if(cachesArray && cachesArray.count>0)
    {
        [self.cachesImageArray addObjectsFromArray:cachesArray];
        
        self.imagesLabel.hidden = NO;
        self.imagesLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.cachesImageArray.count];
    }else{
        self.imagesLabel.hidden = YES;
        self.imagesLabel.text = @"";
    }
    [self reloadData];
}

- (void)compositeImageSouce
{
  
    self.imageSoureArray = [NSMutableArray new];
    
    for (NSString *fileId in self.photoIdArray)
    {
          KDImageSource *imageSource = [[KDImageSource alloc] init];
        
        KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
        NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
        
        // bug 8344 tt环境
//        NSURL *url = [NSURL URLWithString:baseURL];
//        
//        baseURL = [NSString stringWithFormat:@"http://%@",[url host]];
        
        baseURL = [baseURL stringByAppendingString:@"/microblog/filesvr/"];
        
        imageSource.thumbnail = [baseURL stringByAppendingFormat:@"%@?thumbnail",fileId];
        imageSource.middle = [baseURL stringByAppendingString:fileId];
        imageSource.original = [baseURL stringByAppendingFormat:@"%@?big",fileId];
        
//        image = [UIImage imageWithContentsOfFile:path];
        
//        [[KDCache sharedCache] storeImage:image forURL:imageSource.original imageType:KDCacheImageTypeOrigin finishedBlock:^(BOOL finish) {
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreview];
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreviewBlur];
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.middle type:KDCacheImageTypeMiddle];
//            [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.thumbnail type:KDCacheImageTypeThumbnail];
//            
//        }];
        [self.imageSoureArray addObject:imageSource];
    }
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if(self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        self.photoIdArray = [NSMutableArray new];
        self.cachesImageArray = [NSMutableArray new];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[KDPhotoSignInCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([KDPhotoSignInCollectionViewCell class])];
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.allowsMultipleSelection = NO;
        
        [self setUpImagesLabel];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDPhotoSignInCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KDPhotoSignInCollectionViewCell class]) forIndexPath:indexPath];
    if(self.imageSoureArray && self.imageSoureArray.count>0)
    {
        cell.cacheIndex = indexPath.row;
    cell.imageSouce = self.imageSoureArray[indexPath.row];
    cell.cellDelegate = self;
    }else if(self.cachesImageArray && self.cachesImageArray.count>0)
    {
        cell.cellDelegate = self;
        cell.cacheIndex = indexPath.row;
        cell.cacheImageUrl = self.cachesImageArray[indexPath.row];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.photoIdArray && self.photoIdArray.count>0)
    {
        return self.photoIdArray.count;
    }
    else if(self.cachesImageArray && self.cachesImageArray.count>0)
    {
        return self.cachesImageArray.count;
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(KDPhotoSignInCollectionViewCellWidth, KDPhotoSignInCollectionViewCellWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.photoIdArray && self.photoIdArray.count>0)
    {
    if(self.photoSignInCollectionViewDelegate && [self.photoSignInCollectionViewDelegate respondsToSelector:@selector(whenPhotoClickedAtIndex:sourceArray:isCache:)])
    {
        [self.photoSignInCollectionViewDelegate whenPhotoClickedAtIndex:indexPath.row sourceArray:self.photoIdArray isCache:NO];
    }
    }else if(self.cachesImageArray && self.cachesImageArray.count>0)
    {
        if(self.photoSignInCollectionViewDelegate && [self.photoSignInCollectionViewDelegate respondsToSelector:@selector(whenPhotoClickedAtIndex:sourceArray:isCache:)])
        {
            [self.photoSignInCollectionViewDelegate whenPhotoClickedAtIndex:indexPath.row sourceArray:self.cachesImageArray isCache:YES];
        }
    }
}

#pragma mark - PhotoSignInCollectionViewCellDelegate
- (void)whenImageViewClickedWithSource:(KDImageSource *)imageSource atIndex:(NSInteger)index
{
    if(self.photoIdArray && self.photoIdArray.count>0)
    {
        if(self.photoSignInCollectionViewDelegate && [self.photoSignInCollectionViewDelegate respondsToSelector:@selector(whenPhotoClickedAtIndex:sourceArray:isCache:)])
        {
            [self.photoSignInCollectionViewDelegate whenPhotoClickedAtIndex:index sourceArray:self.imageSoureArray isCache:NO];
        }
    }else{
        if(self.photoSignInCollectionViewDelegate && [self.photoSignInCollectionViewDelegate respondsToSelector:@selector(whenPhotoClickedAtIndex:sourceArray:isCache:)])
        {
            [self.photoSignInCollectionViewDelegate whenPhotoClickedAtIndex:index sourceArray:self.cachesImageArray isCache:YES];
        }
    }
}
@end
