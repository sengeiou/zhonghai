//
//  KDAssetCollectionViewController.m
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDAssetCollectionViewController.h"

#import "KDAssetImageView.h"

#import "MBProgressHUD.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "KDErrorDisplayView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "MWCommon.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIColor+KDV6.h"
#import "UIFont+KDV6.h"
#import "KDStyleSyntaxSugar.h"
#import "UIButton+KDV6.h"
#import "kDTableViewCell.h"
#import "NSNumber+KDV6.h"

#define kQBASSET_DONE_BUTTON_TITLE @"KDAssetCollectionViewController_confirm"
@interface KDAssetCollectionViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate,MWPhotoBrowserDelegate>
{
    BOOL shouldReloadSelected;
    UIButton *buttonPreview;
    BOOL bPreviewMode;
    BOOL bGoBack;
    BOOL bPhotoStream;
    BOOL bPhotoStreamCheckDone;
}

@property (nonatomic, retain) NSMutableArray *assets;
@property (nonatomic, retain) __block NSMutableArray *selectedAssets;
@property (nonatomic, copy)  NSMutableArray *oldSelectedAssets;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIScrollView *previewView;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, strong) UIButton *editorImageBtn;
@property (nonatomic, strong) UIButton *originalImageBtn;

@property (nonatomic, retain) NSMutableArray *addedPreviews;
@property (nonatomic, retain) NSMutableArray *removedPreviews;
@property (nonatomic, assign) BOOL showTakeButton;
@property (nonatomic, retain) UILabel *hintLabel;

@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) MWPhotoBrowser *browser;

@end

@implementation KDAssetCollectionViewController
#define kNumberOfAssetsInRow 4
#define kPictureMargin 4
#define kPictureWidth (ScreenFullWidth - 5 * kPictureMargin)/4.0

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        /* Initialization */
        self.assets = [NSMutableArray array];
        self.selectedAssets = [NSMutableArray array];
        self.oldSelectedAssets = [NSMutableArray array];
        self.imageSize = CGSizeMake(73, 73);
        
        self.addedPreviews = [NSMutableArray array];
        self.removedPreviews = [NSMutableArray array];
        [self initShowTakeButton];
        
        shouldReloadSelected = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}


- (void)setupView
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat menuBarHeight = 40;
    CGFloat previewHeight = 60;
    //Menu bar
    UIView *menuBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, screenHeight-previewHeight-menuBarHeight, self.view.frame.size.width, menuBarHeight)];
    menuBar.backgroundColor = [UIColor kdBackgroundColor2];
    menuBar.tag = 10112;
    [self.view addSubview:menuBar];
    
    //button
    self.doneButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDAssetCollectionViewController_send")];
    self.doneButton.frame = CGRectMake(menuBar.frame.size.width - [NSNumber kdDistance1] - 65, (menuBar.frame.size.height - 30.0f) / 2.0f, 65, 30.0f);
    [self.doneButton setCircle];
    self.doneButton.enabled = NO;
    [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.titleLabel.font = FS6;
    [menuBar addSubview:self.doneButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(menuBar.frame)-0.5, CGRectGetWidth(menuBar.frame), 0.5)];
    lineView.backgroundColor = [UIColor kdDividingLineColor];
    [menuBar addSubview:lineView];
    
    buttonPreview = [[UIButton alloc]initWithFrame:CGRectMake(10, (menuBar.frame.size.height - 30.0f) / 2.0f, 50, 30)];
    [buttonPreview setTitleColor:FC1 forState:UIControlStateNormal];
    [buttonPreview setTitle:ASLocalizedString(@"KDAssetCollectionViewController_look")forState:UIControlStateNormal];
    [buttonPreview.titleLabel setFont:FS6];
    [buttonPreview addTarget:self action:@selector(buttonPreviewPressed) forControlEvents:UIControlEventTouchUpInside];
    [menuBar addSubview:buttonPreview];
    
    _editorImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editorImageBtn.frame = CGRectMake(CGRectGetMaxX(buttonPreview.frame)+10, CGRectGetMinY(buttonPreview.frame), 65,20);
    _editorImageBtn.center = CGPointMake(_editorImageBtn.center.x, buttonPreview.center.y);
    _editorImageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_editorImageBtn setImage:[UIImage imageNamed:@"icon_edit_picture"] forState:UIControlStateDisabled];
    [_editorImageBtn setImage:[UIImage imageNamed:@"icon_edit_picture_click"] forState:UIControlStateNormal];
    [_editorImageBtn setTitleColor:FC1 forState:UIControlStateDisabled];
    [_editorImageBtn setTitleColor:FC5 forState:UIControlStateNormal];
    [_editorImageBtn setTitle:ASLocalizedString(@"KDOrganiztionCell_Edit") forState:UIControlStateNormal];
    [_editorImageBtn.titleLabel setFont:FS6];
    [_editorImageBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    _editorImageBtn.enabled = NO;
    _editorImageBtn.hidden = YES;
    [_editorImageBtn addTarget:self action:@selector(editorImageClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuBar addSubview:_editorImageBtn];
    
    _originalImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalImageBtn.frame = CGRectMake(CGRectGetMaxX(buttonPreview.frame)+10+75, CGRectGetMinY(buttonPreview.frame), 120,20);
    _originalImageBtn.center = CGPointMake(_originalImageBtn.center.x, buttonPreview.center.y);
    _originalImageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_originalImageBtn setImage:[UIImage imageNamed:@"select_photo_origin"] forState:UIControlStateNormal];
    [_originalImageBtn setImage:[UIImage imageNamed:@"select_photo_origin_selected"] forState:UIControlStateSelected];
    [_originalImageBtn setTitleColor:FC1 forState:UIControlStateNormal];
    [_originalImageBtn setTitleColor:FC1 forState:UIControlStateSelected];
    [_originalImageBtn setTitle:ASLocalizedString(@"Check_for_original") forState:UIControlStateNormal];
    [_originalImageBtn.titleLabel setFont:FS6];
    [_originalImageBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [_originalImageBtn addTarget:self action:@selector(originalImageClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuBar addSubview:_originalImageBtn];
    
    // PreView View
    UIScrollView *previewView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, screenHeight - previewHeight, self.view.frame.size.width, previewHeight)];
    previewView.contentSize = previewView.frame.size;
    [self.view addSubview:previewView];
    previewView.backgroundColor = [UIColor kdBackgroundColor2];
    self.previewView = previewView;
    
    // left item
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"KDAssetCollectionViewController_return")inNav:YES];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    // Table View
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = YES;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, previewHeight + menuBarHeight, 0);
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, previewHeight + menuBarHeight, 0);
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    tableView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.previewView];
    self.view.backgroundColor = FC6;
    [self.view bringSubviewToFront:menuBar];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    // Reload
    [self translateToSelectedAssets];
    [self reloadData];
    [self updateButtonSendSum];
    
    if (self.assets.count > 0) {
        [self.assetsLibrary assetForURL:[self assetURL:self.assets[0]] resultBlock:^(ALAsset *asset) {
            
            if ( asset ) {
                bPhotoStream = NO;
            } else {
                
                DLog(@"in photo stream");
                
                bPhotoStream = YES;
            }
            bPhotoStreamCheckDone = YES;
            
        } failureBlock:^( NSError *error ) {
            
            bPhotoStreamCheckDone = YES;
            
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(bGoBack)
    {
        for (ALAsset *asset in self.selectedAssets) {
            [self removePreviewView:[self assetURL:asset]];
        }
        [self.selectedAssets removeAllObjects];
        [self.selectedAssetUrls removeAllObjects];
        self.selections = nil;
        self.bSendOriginal = NO;
        self.originalImageBtn.selected = self.bSendOriginal;
        [self updateOriginImagesSize];
    }
}

- (void)setIsFromXTChat:(BOOL)isFromXTChat {
    _isFromXTChat = isFromXTChat;
    self.editorImageBtn.hidden = !isFromXTChat;
}

- (void)editorImageClick:(UIButton *)sender {
    ALAsset *asset = [self.selectedAssets firstObject];
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetCollectionViewController:didSelectedEditImage:)]) {
        [self.delegate assetCollectionViewController:self didSelectedEditImage:image];
    }
}

-(void)originalImageClick:(UIButton *)sender
{
    _originalImageBtn.selected = !_originalImageBtn.selected;
    self.bSendOriginal = self.originalImageBtn.selected;
    [self updateOriginImagesSize];
}


-(void)updateOriginImagesSize
{
    if(_originalImageBtn.selected)
    {
        double totalSize = 0;
        for(int i = 0;i < self.selectedAssets.count;i++)
        {
            ALAsset *asset = self.selectedAssets[i];
            if(self.selections.count == self.selectedAssets.count && [self.selections[i] boolValue] == NO )
                continue;
            CGImageRef origionRef = [[asset  defaultRepresentation]fullResolutionImage];
            UIImage *origionImg = [[UIImage alloc]initWithCGImage:origionRef];
            NSData *imageData = UIImageJPEGRepresentation(origionImg, 1.f);
            totalSize += imageData.length;
        }
        
        if(totalSize != 0)
        {
            [_originalImageBtn setTitle:[NSString stringWithFormat:@"%@(%@)",ASLocalizedString(@"Check_for_original"),[self transformedValue:totalSize]] forState:UIControlStateNormal];
            return;
        }
    }
    
    [_originalImageBtn setTitle:ASLocalizedString(@"Check_for_original") forState:UIControlStateNormal];
}

- (id)transformedValue:(double)value
{
    double convertedValue = value;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%.f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    [self updateRightBarButtonItem];
}

- (void)initShowTakeButton
{
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    if ([iosVersion floatValue] >= 6.0) {
        _showTakeButton = YES;
    }else {
        _showTakeButton = NO;
    }
    
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    [self.view viewWithTag:10112].hidden = !allowsMultipleSelection;
    self.previewView.hidden = !allowsMultipleSelection;
    
    [self updateRightBarButtonItem];
}


#pragma mark - Instance Methods

- (void)reloadData
{
    [self.assets removeAllObjects];
    // Reload assets
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [self.assets addObject:result];
        }
    }];
    //reverse data
    self.assets = [NSMutableArray arrayWithArray:[[self.assets reverseObjectEnumerator] allObjects]];
    [self.tableView reloadData];
    [self reloadSelectedAsset];
}

- (void)updateRightBarButtonItem
{
    if(self.showsCancelButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDAssetCollectionViewController_cancel")style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC5, NSFontAttributeName : FS3} forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : FC7, NSFontAttributeName : FS3} forState:UIControlStateHighlighted];
    }
}

- (void)goBack:(id)sender
{
    bGoBack = YES;
    shouldReloadSelected = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateDoneButton
{
    if(self.limitsMinimumNumberOfSelection) {
        self.doneButton.enabled = (self.selectedAssets.count >= self.minimumNumberOfSelection);
    } else {
        self.doneButton.enabled = (self.selectedAssets.count > 0);
    }
    
    self.hintLabel.text = [NSString stringWithFormat:@"%lu/9", (unsigned long)self.selectedAssets.count];
    
    [self scrollViewToLast];
    
    self.editorImageBtn.enabled = self.selectedAssets.count==1 ? YES : NO;
}

- (void)scrollViewToLast
{
    CGSize size = self.previewView.contentSize;
    [self.previewView scrollRectToVisible:CGRectMake(size.width - 60.f, 0.0, size.width, size.height) animated:YES];
}

- (void)setSelectedAssetUrls:(NSMutableArray *)selectedAssetUrls
{
    if (_selectedAssetUrls != selectedAssetUrls) {
        if(_selectedAssetUrls) _selectedAssetUrls = nil;
    }
    _selectedAssetUrls = [selectedAssetUrls mutableCopy];
    shouldReloadSelected = YES;
    [self reloadSelectedAsset];
    
    self.oldSelectedAssets = [self.selectedAssets mutableCopy];
}

- (void)reloadSelectedAsset
{
    if (!shouldReloadSelected) {
        return;
    }
    [self.selectedAssets removeAllObjects];
    //
    for (UIView *view in self.previewView.subviews) {
        if ([view isKindOfClass:[KDAssetImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self updateDoneButton];
    
    if (self.assets.count <= 0 || self.selectedAssetUrls.count <= 0) {
        return;
    }
    self.previewView.contentSize = self.previewView.frame.size;
    for (NSString *url in _selectedAssetUrls) {
        int tag = 0;
        
        for (ALAsset *asset in self.assets) {
            
            NSString *assetURL = [NSString stringWithFormat:@"%@", [self assetURL:asset]];
            if ([url isEqualToString:assetURL]) {
                
                [self.selectedAssets addObject:asset];
                [self addToPreviewView:asset atIndexPath:[NSIndexPath indexPathForRow:tag / 4 inSection:0] withTag:tag + 1];
                
                break;
            }
            tag++;
        }
    }
    [self updateDoneButton];
    
}

#define kPadding 5.f
#define kImageSize 50.0f

- (void)addToPreviewView:(ALAsset *)asset atIndexPath:(NSIndexPath *)indexPath withTag:(NSUInteger)tag
{
    int count = (int)self.selectedAssets.count;
    
    CGRect rect = CGRectMake(kPadding * count + kImageSize * (count - 1), (self.previewView.frame.size.height - kImageSize) / 2.0f , kImageSize, kImageSize);
    KDAssetImageView *imageView = [[KDAssetImageView alloc] initWithFrame:rect];
    imageView.cellIndexPath = indexPath;
    imageView.tag = tag;
    imageView.assetURL = [self assetURL:asset];
    imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    [self.previewView addSubview:imageView];
    
    if (![self isInOldSelectedAssets:imageView.assetURL]) {
        [_addedPreviews addObject:imageView];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deselectTapped:)];
    tap.numberOfTapsRequired = 1;
    DLog(@"%ld",(long) imageView.tag);
    
    [imageView addGestureRecognizer:tap];
    imageView.userInteractionEnabled = YES;
    
    CGSize size = CGSizeMake(kPadding * count + kImageSize * count, 60.0f);
    self.previewView.contentSize = size;
}

- (void)removePreviewView:(NSURL *)assetURL
{
    KDAssetImageView *toRemove = nil;
    
    for (UIView *view in self.previewView.subviews) {
        if ([view isKindOfClass:[KDAssetImageView class]]) {
            if ([((KDAssetImageView *)view).assetURL isEqual:assetURL]) {
                toRemove = (KDAssetImageView*)view;
                break;
            }
        }
    }
    
    for (UIView *view in self.previewView.subviews) {
        if ([view isKindOfClass:[KDAssetImageView class]]) {
            if (view.frame.origin.x > toRemove.frame.origin.x) {
                CGRect frame = view.frame;
                frame.origin.x = view.frame.origin.x - kPadding - kImageSize;
                view.frame = frame;
            }
        }
    }
    
    if ([self isInOldSelectedAssets:toRemove.assetURL] && toRemove) {
        [_removedPreviews addObject:toRemove];
    }
    
    [toRemove removeFromSuperview];
    int count = (int)self.selectedAssets.count - 1;
    CGSize size = CGSizeMake(kPadding * count + kImageSize * count, 60.0f);
    self.previewView.contentSize = size;
}

- (void)deselectTapped:(UIGestureRecognizer *)gesture
{
    KDAssetImageView *imageView = (KDAssetImageView *)gesture.view;
    
    if ([self isInOldSelectedAssets:imageView.assetURL]) {
        [_removedPreviews addObject:imageView];
    }
    
    KDImagePickerAssetCell *cell = (KDImagePickerAssetCell *)[self.tableView cellForRowAtIndexPath:imageView.cellIndexPath];
    NSInteger numberOfAssetsInRow = kNumberOfAssetsInRow;
    
    NSInteger assetIndex = -1;
    if (self.showTakeButton)
    {
        DLog(@"%ld",(long)imageView.tag);
        
        assetIndex = imageView.tag % numberOfAssetsInRow ;
    }
    else
    {
        assetIndex =(imageView.tag - 1)% numberOfAssetsInRow;
    }
    [cell deselectAssetAtIndex:assetIndex];
    [self removePreviewView:imageView.assetURL];
    [self removeSelectedAssetWithURL:imageView.assetURL];
    [self updateDoneButton];
    
    [self updateButtonSendSum];
    
}

- (void)updatePreviewTag:(NSUInteger)tag asset:(ALAsset *)asset indexPath:(NSIndexPath *)indexPath
{
    for (UIView *view in self.previewView.subviews) {
        if ([view isKindOfClass:[KDAssetImageView class]]) {
            if ([((KDAssetImageView *)view).assetURL isEqual:[self assetURL:asset]]) {
                view.tag = tag;
                ((KDAssetImageView *)view).cellIndexPath = indexPath;
            }
        }
    }
}

- (BOOL)isSelectedAsset:(NSURL *)assetURL
{
    BOOL flag = NO;
    for (ALAsset *temp in self.selectedAssets) {
        if ([[self assetURL:temp] isEqual:assetURL]) {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (BOOL)isInOldSelectedAssets:(NSURL *)assetURL
{
    BOOL flag = NO;
    for (ALAsset *temp in self.oldSelectedAssets) {
        if ([[self assetURL:temp] isEqual:assetURL]) {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (void)removeSelectedAssetWithURL:(id)assetURL
{
    for (ALAsset *temp in self.selectedAssets) {
        NSURL *url = [self assetURL:temp];
        if ([url isEqual:assetURL]) {
            [self.selectedAssets removeObject:temp];
            break;
        }
    }
}

- (void)done
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        NSMutableArray *newArray = [NSMutableArray array];
//        [newArray addObjectsFromArray:self.oldSelectedAssets];
//        [newArray addObjectsFromArray:self.selectedAssets];
//        self.oldSelectedAssets = newArray;
        
        [self.delegate assetCollectionViewController:self didFinishPickingAssets:self.selectedAssets];
        [_addedPreviews removeAllObjects];
        [_removedPreviews removeAllObjects];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        });
    });
    
}

- (void)cancel
{
    [self.selectedAssets removeObjectsInArray:self.oldSelectedAssets];
    for (ALAsset *asset in self.selectedAssets) {
        [self removePreviewView:[self assetURL:asset]];
    }
    [self.selectedAssets removeAllObjects];
    [self.selectedAssets addObjectsFromArray:self.oldSelectedAssets];
    [self resetPreview];
    [self.delegate assetCollectionViewControllerDidCancel:self];
    
    [_addedPreviews removeAllObjects];
    [_removedPreviews removeAllObjects];
}

- (void)resetPreview
{
    for (KDAssetImageView *view in _addedPreviews) {
        [view removeFromSuperview];
    }
    
    for (KDAssetImageView *view in _removedPreviews) {
        [self.previewView addSubview:view];
    }
    
    int count = (int)self.oldSelectedAssets.count;
    CGSize size = CGSizeMake(kPadding * count + kImageSize * count, 60.0f);
    _previewView.contentSize = size;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    NSInteger numberOfAssetsInRow = kNumberOfAssetsInRow;
    if (self.showTakeButton) {
        numberOfRowsInSection = (self.assets.count + numberOfAssetsInRow) / numberOfAssetsInRow;
    }else {
        numberOfRowsInSection = (self.assets.count + numberOfAssetsInRow - 1) / numberOfAssetsInRow;
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"AssetCell";
    
    KDImagePickerAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        
        cell = [[KDImagePickerAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageSize:CGSizeMake(kPictureWidth, kPictureWidth) numberOfAssets:kNumberOfAssetsInRow margin:kPictureMargin];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDelegate:self];
        [cell setAllowsMultipleSelection:self.allowsMultipleSelection];
    }
    cell.showTakeButton = NO;
    // Set assets
    NSInteger numberOfAssetsInRow = kNumberOfAssetsInRow;
    NSInteger offset = numberOfAssetsInRow * indexPath.row;
    if (indexPath.row != 0 && self.showTakeButton) {
        offset = offset - 1;
    }
    NSInteger numberOfAssetsToSet = (offset + numberOfAssetsInRow > self.assets.count) ? (self.assets.count - offset) : numberOfAssetsInRow;
    
    NSMutableArray *assets = [NSMutableArray array];
    
    if (indexPath.row == 0 && self.showTakeButton) {
        cell.showTakeButton = YES;
    }
    
    DLog(@"%ld %ld",(long)indexPath.section, (long)indexPath.row);
    
    
    for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
        [assets addObject:asset];
        NSInteger tag = (i + 1 + indexPath.row * numberOfAssetsInRow);
        tag = indexPath.row > 0 && self.showTakeButton ? tag - 1 : tag;
        [self updatePreviewTag:tag asset:asset indexPath:indexPath];
    }
    cell.indexPath = indexPath;
    [cell setAssets:assets];
    
    // Set selection states
    for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
        int index = indexPath.row == 0 && self.showTakeButton ? (int)i + 1 : (int)i;
        if([self isSelectedAsset:[self assetURL:asset]]
           || [self isInOldSelectedAssets:[self assetURL:asset]])
        {
            [cell selectAssetAtIndex:index];
        }
        else
        {
            [cell deselectAssetAtIndex:index];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 0;
    
    //    NSInteger numberOfAssetsInRow = kNumberOfAssetsInRow;
    //    CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
    heightForRow = kPictureMargin + kPictureWidth;
    
    
    return heightForRow;
}

#pragma mark - KDImagePickerAssetCellDelegate

- (BOOL)assetCell:(KDImagePickerAssetCell *)assetCell canSelectAssetAtIndex:(NSUInteger)index
{
    BOOL canSelect = YES;
    
    if(self.allowsMultipleSelection && self.limitsMaximumNumberOfSelection) {
        canSelect = (self.selectedAssets.count < self.maximumNumberOfSelection);
    }
    
    if (!canSelect && ![assetCell assetAtIndex:index].selected) {
        [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDAssetCollectionViewController_alter")inView:self.view];
    };
    
    return canSelect;
}

- (void)assetCell:(KDImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:assetCell];
    
    NSInteger numberOfAssetsInRow = kNumberOfAssetsInRow;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    
    if (self.showTakeButton) {
        assetIndex -= 1;
    }
    
    ALAsset *asset = [self.assets objectAtIndex:assetIndex];
    
    if(self.allowsMultipleSelection) {
        
        if(selected) {
            [self.selectedAssets addObject:asset];
            [self addToPreviewView:asset atIndexPath:indexPath withTag:assetIndex + 1];
        } else {
            if ([self isSelectedAsset:[self assetURL:asset]]) {
                [self removePreviewView:[self assetURL:asset]];
            }
            [self removeSelectedAssetWithURL:[self assetURL:asset]];
        }
        
        // Set done button state
        [self updateOriginImagesSize];
        [self updateDoneButton];
    } else {
        [self.delegate assetCollectionViewController:self didFinishPickingAsset:asset];
    }
    
    [self updateButtonSendSum];
}

- (void)takePhotoBtnClicked:(id)sender
{
    if (self.selectedAssets.count < self.maximumNumberOfSelection) {
        shouldReloadSelected = NO;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        picker.cameraDevice= UIImagePickerControllerCameraDeviceRear;
        self.bCameraSource = YES;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

- (void)assetCell:(KDImagePickerAssetCell *)assetCel didTouchPreviewWithTag:(NSInteger)tag
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:assetCel];
    
    NSInteger numberOfAssetsInRow = kNumberOfAssetsInRow;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + tag;
    
    if (self.showTakeButton) {
        assetIndex -= 1;
    }
    
    [self showMWPhotoBrowserWithIndex:assetIndex];
    
    //    ALAsset *asset = [self.assets objectAtIndex:assetIndex];
    //
    ////    KDAssetImageView *imageView = [[KDAssetImageView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    ////    imageView.assetURL = [self assetURL:asset];
    //    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    //
    //    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    //    [assetsLibrary assetForURL:[self assetURL:asset] resultBlock: ^(ALAsset *asset){
    //        ALAssetRepresentation *representation = [asset defaultRepresentation];
    //        CGImageRef imageRef = [representation fullResolutionImage];
    //        if (imageRef)
    //        {
    //            MJPhoto *photo = [[MJPhoto alloc] init];
    //            photo.image = [UIImage imageWithCGImage:imageRef scale:2 orientation:UIImageOrientationUp];
    //            photo.bFullScrean = YES;
    //            browser.photos = @[photo];
    //            browser.bHideToolBar = YES;
    //            [browser show];
    //        }
    //    } failureBlock: nil];
    //
    //
    
}

- (NSURL *)assetURL:(ALAsset *)asset
{
    return asset.defaultRepresentation.url;
}

#pragma mark imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    if(UTTypeConformsTo(mediaType, kUTTypeImage)){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation  completionBlock:^(NSURL *assetURL, NSError *error) {
                [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        [self.assetsGroup addAsset:asset];
                        [self.selectedAssets addObject:asset];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.allowsMultipleSelection) {
                            [self done];
                        }else {
                            [self.delegate assetCollectionViewController:self didFinishPickingAsset:asset];
                        }
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    });
                    
                } failureBlock:^(NSError *error){
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }];
            }];
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}


#pragma mark - darren hack -

// 点击某个图片，跳转到MWPhotoBrowser
- (void)showMWPhotoBrowserWithIndex:(NSInteger)index
{
    if (!bPhotoStreamCheckDone) {
        return;
    }
    if (bPhotoStream) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"KDAssetCollectionViewController_tips")message:ASLocalizedString(@"KDAssetCollectionViewController_NoSuport")delegate:self cancelButtonTitle:ASLocalizedString(@"KDAssetCollectionViewController_sure")otherButtonTitles:nil, nil]; [alert show];
        return;
    }
    
    bPreviewMode = NO;
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    //        MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        for (ALAsset *asset in copy) {
            ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
            [photos addObject:[MWPhoto photoWithURL:assetRepresentation.url]];
            [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
        }
    }
    
    
    startOnGrid = NO;
    displayNavArrows = NO;
    displaySelectionButtons = YES;
    displayActionButton = NO;
    enableGrid = NO;
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    self.browser.displayActionButton = displayActionButton;
    self.browser.displayNavArrows = displayNavArrows;
    self.browser.displaySelectionButtons = displaySelectionButtons;
    self.browser.alwaysShowControls = displaySelectionButtons;
    self.browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    self.browser.wantsFullScreenLayout = YES;
#endif
    self.browser.enableGrid = enableGrid;
    self.browser.startOnGrid = startOnGrid;
    self.browser.enableSwipeToDismiss = YES;
    [self.browser setCurrentPhotoIndex:index];
    self.browser.bOriginal = self.bSendOriginal;
    
    
    // Reset selections
    //    if (displaySelectionButtons) {
    //        _selections = [NSMutableArray new];
    //        for (int i = 0; i < photos.count; i++) {
    //            [_selections addObject:[NSNumber numberWithBool:NO]];
    //        }
    //    }
    
    [self translateToMWPhotoBrowserSelections];
    self.browser.selections = self.selections;
    
    // Show
    //
    //
    //    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    [self.navigationController pushViewController:self.browser animated:YES];
    self.browser = nil;
    shouldReloadSelected = YES;
    
    bGoBack = NO;
}

// 点击“预览”跳转到MWPhotoBrowser
- (void)buttonPreviewPressed
{
    if (!bPhotoStreamCheckDone) {
        return;
    }
    if (self.selectedAssets.count == 0) {
        return;
    }
    if (bPhotoStream) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"KDAssetCollectionViewController_tips")message:ASLocalizedString(@"KDAssetCollectionViewController_NoSuport")delegate:self cancelButtonTitle:ASLocalizedString(@"KDAssetCollectionViewController_sure")otherButtonTitles:nil, nil]; [alert show];
        return;
    }
    
    bPreviewMode = YES;
    
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    //        MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    
    @synchronized(_selectedAssets) {
        NSMutableArray *copy = [_selectedAssets copy];
        for (ALAsset *asset in copy) {
            ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
            [photos addObject:[MWPhoto photoWithURL:assetRepresentation.url]];
            [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
        }
    }
    startOnGrid = NO;
    displayNavArrows = NO;
    displaySelectionButtons = YES;
    displayActionButton = NO;
    enableGrid = NO;
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    self.browser.displayActionButton = displayActionButton;
    self.browser.displayNavArrows = displayNavArrows;
    self.browser.displaySelectionButtons = displaySelectionButtons;
    self.browser.alwaysShowControls = displaySelectionButtons;
    self.browser.zoomPhotosToFill = YES;
    self.browser.enableGrid = enableGrid;
    self.browser.startOnGrid = startOnGrid;
    self.browser.enableSwipeToDismiss = YES;
    self.browser.bOriginal = self.bSendOriginal;
    [self.browser setCurrentPhotoIndex:0];
    
    [self translateToMWPhotoBrowserSelections];
    
    
    self.browser.selections = self.selections;
    
    [self.navigationController pushViewController:self.browser animated:YES];
    self.browser = nil;
    bGoBack = NO;
    shouldReloadSelected = YES;
}

- (void)translateToMWPhotoBrowserSelections
{
    if (!self.selections)
    {
        self.selections = [NSMutableArray new];
    }
    [self.selections removeAllObjects];
    
    
    if (bPreviewMode)
    {
        
        for (int i = 0; i < self.assets.count; i++)
        {
            if (@([self.selectedAssets containsObject:self.assets[i]]).boolValue)
            {
                [self.selections addObject:@([self.selectedAssets containsObject:self.assets[i]])];
            }
        }
    }
    else
    {
        for (int i = 0; i < self.assets.count; i++)
        {
            [self.selections addObject:@([self.selectedAssets containsObject:self.assets[i]])];
        }
    }
}

- (void)translateToSelectedAssets
{
    if (!self.selectedAssets) {
        self.selectedAssets = [NSMutableArray new];
    }
    
    
    if (!_selectedAssetUrls) {
        _selectedAssetUrls = [NSMutableArray new];
    }
    
    //[_selectedAssetUrls removeAllObjects];
    
    if (bPreviewMode)
    {
        int sum = (int)self.selectedAssets.count;
        
        for (int i = 0; i < sum; i++)
        {
            if ([self.selections[i]boolValue])
            {
                NSString *assetURL = [self assetURL:self.selectedAssets[i]].description;
                if(![self.selectedAssetUrls containsObject:assetURL]) {
                    [self.selectedAssetUrls addObject:assetURL];
                }
            } else {
                NSString *assetURL = [self assetURL:self.selectedAssets[i]].description;
                if([self.selectedAssetUrls containsObject:assetURL]) {
                    [self.selectedAssetUrls removeObject:assetURL];
                }
            }
        }
    }
    
    
    else
    {
//        if (self.selectedAssets.count > 0) {
//            [self.selectedAssets removeAllObjects];
//        }
//        
        for (int i = 0; i < self.assets.count; i++)
        {
            
            if ([self.selections[i]intValue] == 1)
            {
                NSString *assetURL = [self assetURL:self.selectedAssets[i]].description;
                if(![self.selectedAssetUrls containsObject:assetURL])
                {
                    [self.selectedAssets addObject:self.assets[i]];
                    [self.selectedAssetUrls addObject:assetURL];
                }
            }
        }
        
    }
    
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index
{
    DLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index
{
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected
{
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    DLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
    [self updateOriginImagesSize];
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser
{
    // If we subscribe to this method we must dismiss the view controller ourselves
    DLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)photoBrowserDidPressSendButton:(MWPhotoBrowser *)photoBrowser
{
    [self translateToSelectedAssets];
    
    [self done];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didChangeOriginalStates:(BOOL)bOrigial
{
    self.bSendOriginal = bOrigial;
    self.originalImageBtn.selected = self.bSendOriginal;
    [self updateOriginImagesSize];
}

- (MWPhotoBrowser *)browser
{
    if (!_browser)
    {
        _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    }
    return _browser;
}


- (UIColor *)colorWithRGB:(int)rgbValue
{
    return [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0
                           green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0
                            blue:((float)((rgbValue) & 0x0000FF))/255.0
                           alpha:1];
}

- (void)updateButtonSendSum
{
    if (self.selectedAssets.count == 0)
    {
        [self.doneButton setTitle:ASLocalizedString(@"KDAssetCollectionViewController_Done")forState:UIControlStateNormal];
    }
    else
    {
        [self.doneButton setTitle:[NSString stringWithFormat:ASLocalizedString(@"KDAssetCollectionViewController_Done_percent"),(unsigned long)self.selectedAssets.count] forState:UIControlStateNormal];
    }
}

@end
