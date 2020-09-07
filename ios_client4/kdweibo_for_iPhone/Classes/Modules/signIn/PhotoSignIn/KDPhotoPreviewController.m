//
//  KDPhotoPreviewController.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPhotoPreviewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define kDoneBtnTag (int)1001
#define kCancelBtnTag (int)1002
#define kanimitionVIewTag (int)1003

@interface KDPhotoPreviewCollectionViewCell:UICollectionViewCell
@property (nonatomic, strong) NSString *assetUrlStr;
@property (nonatomic,strong) UIImageView *assetImageView;
@end

@implementation KDPhotoPreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.assetImageView.contentMode =  UIViewContentModeScaleAspectFit;
        self.assetImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.assetImageView];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAssetUrlStr:(NSString *)assetUrlStr
{
    _assetUrlStr = assetUrlStr;
    NSData *data = [[NSData alloc] initWithContentsOfFile:assetUrlStr];
    self.assetImageView.image =  [UIImage imageWithData:data];
}


@end

@interface KDPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, retain) UIToolbar *bottomView;
 @property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@end

@implementation KDPhotoPreviewController

- (NSMutableArray *)assetArray
{
    if(!_assetArray)
    {
        _assetArray = [NSMutableArray new];
    }
    return _assetArray;
}

- (NSMutableArray *)cacheArray
{
    if(!_cacheArray)
    {
        _cacheArray = [NSMutableArray new];
    }
    return _cacheArray;
}

- (void)loadView
{
    [super loadView];


}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCollectionView];
    [self setViews];
    
    if(self.currentPageIndex+1>self.assetArray.count)
    {
        self.currentPageIndex = 0;
    }else{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }

}

- (void)clickedPreviewImageViewAtIndex:(NSInteger)index assetArray:(NSArray *)assetArray cacheArray:(NSArray *)cacheArray
{
    if(assetArray && assetArray.count>0)
    {
        [self.assetArray addObjectsFromArray:assetArray];
        [self.cacheArray addObjectsFromArray:cacheArray];
        [self.collectionView reloadData];
        self.currentPageIndex = index;
    }
}

- (void)setUpCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView registerClass:[KDPhotoPreviewCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([KDPhotoPreviewCollectionViewCell class])];
    [self.view addSubview:self.collectionView];
}

- (void)setViews
{
    CGRect bottomRect = CGRectMake(0.0f, self.view.frame.size.height - 60.0f, self.view.frame.size.width, 60.f);
    _bottomView = [[UIToolbar alloc] initWithFrame:bottomRect];
    _bottomView.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:_bottomView];

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish:)];
    doneItem.tag = kDoneBtnTag;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(finish:)];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto:)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [_bottomView setItems:@[cancelItem, flex, deleteItem, flex, doneItem] animated:NO];
}

- (void)finish:(UIBarButtonItem *)sender
{
    BOOL isDone = sender.tag == kDoneBtnTag;
    if(self.photoPreviewDelegate && [self.photoPreviewDelegate respondsToSelector:@selector(photoPreviewDone:info:previewController:)])
    {
        NSDictionary *info  = [NSDictionary dictionaryWithObjectsAndKeys:self.assetArray, @"asset", self.cacheArray, @"cache", nil];
        
        [self.photoPreviewDelegate photoPreviewDone:isDone info:info previewController:self];
    }
}

- (void)deletePhoto:(UIBarButtonItem *)sender
{
    if(self.isDeleteCache)
    {
        [self removeLocalCachedPickImage];
    }
    
     if (self.currentPageIndex < [self.assetArray count]) {
        [self.assetArray removeObjectAtIndex:self.currentPageIndex];
         [self.cacheArray removeObjectAtIndex:self.currentPageIndex];
        //删除一个cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPageIndex inSection:0];
         if (indexPath!=nil)
        {
             [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                
            } completion:nil];
        }
    }
    
    if ([self.assetArray count] > 0) {
        [self shouldScrollToIndex];
    }else {
        [self removeLast];
    }

}

- (NSUInteger)shouldScrollToIndex
{
    if (self.currentPageIndex >= [self.assetArray count]) {
        self.currentPageIndex = self.currentPageIndex - 1;
    }
    return self.currentPageIndex;
}


- (void)removeLast
{
    if(self.assetArray && self.assetArray.count>0)
    {
        [self.assetArray removeAllObjects];
    }
    if(self.cacheArray && self.cacheArray.count>0)
    {
        [self.cacheArray removeAllObjects];
    }
    
        if(self.photoPreviewDelegate && [self.photoPreviewDelegate respondsToSelector:@selector(photoPreviewDone:info:previewController:)])
        {
            [self.photoPreviewDelegate photoPreviewDone:YES info:nil previewController:self];
        }
}

#pragma mark - collectionViewDelegate & datasource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDPhotoPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KDPhotoPreviewCollectionViewCell class]) forIndexPath:indexPath];
    cell.assetUrlStr = self.cacheArray[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cacheArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if(self.currentPageIndex != index){
        self.currentPageIndex = index;
    }
}


- (void)removeLocalCachedPickImage {
    
    for (NSString *path in self.cacheArray) {
        
        NSString *thumbnailPath = [self pickedImageLocalThumbnailCachePath:path];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]){
            [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:NULL];
        }
    }
    
}

- (NSString *)pickedImageLocalThumbnailCachePath:(NSString *)imagePath {
    return [imagePath stringByAppendingString:@"_thumb"];
}
@end
