//
//  KDImagePickerController.m
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDImagePickerController.h"

#import "KDImagePickerGroupCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIColor+KDV6.h"
#import "UIFont+KDV6.h"
#import "KDStyleSyntaxSugar.h"
#import "UIButton+KDV6.h"
#import "kDTableViewCell.h"
#import "NSNumber+KDV6.h"

@interface KDImagePickerController ()

@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, retain) NSMutableArray *assetsGroups;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, assign) UIBarStyle previousBarStyle;
@property (nonatomic, assign) BOOL previousBarTranslucent;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, retain) KDAssetCollectionViewController *assetCollectionViewController;

- (void)cancel;
- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset;

@end

@implementation KDImagePickerController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        
        /* Initialization */
        self.title = ASLocalizedString(@"KDImagePickerController_Photo");
        self.filterType = KDImagePickerFilterTypeAllPhotos;
        self.showsCancelButton = YES;
        
        self.allowsMultipleSelection = NO;
        self.limitsMinimumNumberOfSelection = NO;
        self.limitsMaximumNumberOfSelection = NO;
        self.minimumNumberOfSelection = 0;
        self.maximumNumberOfSelection = 1;
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        self.assetsLibrary = assetsLibrary;
        
        self.assetsGroups = [NSMutableArray array];
        
        // Table View
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor kdBackgroundColor1];
        self.view.backgroundColor = [UIColor kdBackgroundColor1];
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        _showAssetView = YES;
        _isFromXTChat = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if(assetsGroup) {
            switch(self.filterType) {
                case KDImagePickerFilterTypeAllAssets:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    break;
                case KDImagePickerFilterTypeAllPhotos:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    break;
            }
            
            if(assetsGroup.numberOfAssets > 0) {
                [self removeNoPermissionView];
                [self.assetsGroups addObject:assetsGroup];
                [self.tableView reloadData];
            }
        }
    };
    
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        DLog(@"Error: %@", [error localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNoPermissionView];
        });
    };
    
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Photo Stream
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Album
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Event
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupEvent usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Faces
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupFaces usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
}

- (void)showNoPermissionView
{
    UIView *view = [self.view viewWithTag:10001];
    if (!view || view.superview != self.view) {
        view= [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64)];
        view.tag = 10001;
        view.backgroundColor = [UIColor kdBackgroundColor2];
        
        //UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collegue_tip_address_normal"]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40.f, CGRectGetWidth(self.view.frame)-20, 40.f)];
        titleLabel.font = [UIFont kdFont1];
        titleLabel.textColor = [UIColor kdTextColor2];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDImagePickerController_NoPermission"),KD_APPNAME];
        [view addSubview:titleLabel];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80.f, CGRectGetWidth(self.view.frame)-20, 60.f)];
        detailLabel.font = [UIFont kdFont2];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.numberOfLines = 2;
        detailLabel.textColor = [UIColor kdTextColor2];
        detailLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDImagePickerController_Tips"),KD_APPNAME];
        [view addSubview:detailLabel];
        
//        imageview.frame = CGRectMake((CGRectGetWidth(view.frame) - CGRectGetWidth(imageview.frame)) * .5, 160.f, CGRectGetWidth(imageview.frame), CGRectGetHeight(imageview.frame));
//        [view addSubview:imageview];
        [self.view addSubview:view];
        
//        self.title = @"";
        UIButton *cancelBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")inNav:YES];
        [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    }
    
}

- (void)removeNoPermissionView
{
    if ([self.view viewWithTag:10001]) {
        [[self.view viewWithTag:10001] removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Cancel table view selection
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    [self.tableView reloadData];
}

- (void)showCollectionViewController
{
    if (_showAssetView && self.assetsGroups.count > 0) {
        ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:0];
        self.assetCollectionViewController.assetsGroup = assetsGroup;
        self.assetCollectionViewController.assetsLibrary = self.assetsLibrary;
        self.assetCollectionViewController.selectedAssetUrls = self.selectedAssetUrls;
        self.assetCollectionViewController.isFromXTChat = self.isFromXTChat;
        [self.navigationController pushViewController:self.assetCollectionViewController animated:NO];
        _showAssetView = NO;
    }
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    if(self.showsCancelButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel")style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    }
    
}

#pragma mark - Instance Methods

- (void)cancel
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    [mediaInfo setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    
    UIImageOrientation orientation = UIImageOrientationUp;
    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
    if (orientationValue != nil) {
        orientation = [orientationValue intValue];
    }
    UIImage* image = [UIImage imageWithCGImage:iref scale:rep.scale orientation:orientation];
    
    [mediaInfo setObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [mediaInfo setObject:[self assetURL:asset] forKey:@"UIImagePickerControllerReferenceURL"];
    
    return mediaInfo;
}

- (NSURL *)assetURL:(ALAsset *)asset
{
    return [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
}

- (KDAssetCollectionViewController *)assetCollectionViewController
{
    if (!_assetCollectionViewController) {
        _assetCollectionViewController = [[KDAssetCollectionViewController alloc] init];
        _assetCollectionViewController.title = ASLocalizedString(@"KDImagePickerController_Photo");
        _assetCollectionViewController.delegate = self;
        _assetCollectionViewController.filterType = self.filterType;
        _assetCollectionViewController.showsCancelButton = YES;
        _assetCollectionViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        _assetCollectionViewController.limitsMinimumNumberOfSelection = self.limitsMinimumNumberOfSelection;
        _assetCollectionViewController.limitsMaximumNumberOfSelection = self.limitsMaximumNumberOfSelection;
        _assetCollectionViewController.minimumNumberOfSelection = self.minimumNumberOfSelection;
        _assetCollectionViewController.maximumNumberOfSelection = self.maximumNumberOfSelection;
    }
    return _assetCollectionViewController;
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [NSNumber kdDistance2];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithCGImage:assetsGroup.posterImage];
    
    NSString *name = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    NSString *countStr = [NSString stringWithFormat:@"%@ (%ld)",name,(long)assetsGroup.numberOfAssets];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:countStr];
    [attributedString addAttributes:@{NSForegroundColorAttributeName:FC2,NSFontAttributeName :FS5} range:NSMakeRange(0, countStr.length)];
    [attributedString addAttributes:@{NSForegroundColorAttributeName:FC1,NSFontAttributeName :FS3} range:NSMakeRange(0, name.length)];
    cell.textLabel.attributedText = attributedString;
    [self showCollectionViewController];
    cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
    if(indexPath.row+1 != self.assetsGroups.count)
    {
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    
    self.assetCollectionViewController.title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    // Show assets collection view
    self.assetCollectionViewController.assetsGroup = assetsGroup;
    [self.navigationController pushViewController:self.assetCollectionViewController animated:YES];
}


#pragma mark - KDAssetCollectionViewControllerDelegate

- (void)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController didFinishPickingAsset:(ALAsset *)asset
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerWillFinishPickingMedia:)]) {
        [self.delegate imagePickerControllerWillFinishPickingMedia:self];
    }
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:[self mediaInfoFromAsset:asset]];
    }
}

- (void)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController didFinishPickingAssets:(NSArray *)assets
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerWillFinishPickingMedia:)]) {
        [self.delegate imagePickerControllerWillFinishPickingMedia:self];
    }
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        NSMutableArray *info = [NSMutableArray array];
        
        for(ALAsset *asset in assets) {
            [info addObject:[self mediaInfoFromAsset:asset]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        
            self.bSendOriginal = assetCollectionViewController.bSendOriginal;
            self.bCameraSource = assetCollectionViewController.bCameraSource;
            [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
        });
    }
}

- (void)assetCollectionViewControllerDidCancel:(KDAssetCollectionViewController *)assetCollectionViewController
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

- (NSString *)descriptionForSelectingAllAssets:(KDAssetCollectionViewController *)assetCollectionViewController
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(descriptionForSelectingAllAssets:)]) {
        description = [self.delegate descriptionForSelectingAllAssets:self];
    }
    
    return description;
}

- (NSString *)descriptionForDeselectingAllAssets:(KDAssetCollectionViewController *)assetCollectionViewController
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(descriptionForDeselectingAllAssets:)]) {
        description = [self.delegate descriptionForDeselectingAllAssets:self];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfPhotos:numberOfPhotos];
    }
    
    return description;
}

- (void)assetCollectionViewController:(KDAssetCollectionViewController *)assetCollectionViewController didSelectedEditImage:(UIImage *)image {
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:didSeletedEditImage:)]) {
        [self.delegate imagePickerController:self didSeletedEditImage:image];
    }
}

@end
