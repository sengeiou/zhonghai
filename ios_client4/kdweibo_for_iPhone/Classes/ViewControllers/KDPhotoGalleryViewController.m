//
//  KDPhotoGalleryViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDPhotoGalleryViewController.h"

#import "KDTileViewCell.h"
#import "KDNotificationView.h"

#import "KDCache.h"
#import "KDImageSize.h"

#import "KDWeiboServicesContext.h"
#import "KDImageLoaderAdapter.h"
#import "UIButton+Additions.h"
#import "KDGifTileViewCell.h"
#import "UIImage+Additions.h"
#import "KDErrorDisplayView.h"

#define KD_PHOTO_GALLERY_TAP_TIMER_INTERVAL                 8.0
#define KD_PHOTO_GALLERY_REFRESH_TIMER_INTERVAL             0.5
#define KD_PHOTO_GALLERY_TILE_VIEW_PADDING_WIDTH            20.0

#define  KD_PHOTO_GALLERY_TITLE_VIEW_TAG                     (int)1000001
#define  KD_PHOTO_GALLERY_SAVE_BUTTON_TAG                   (int)1000002
#define  KD_PHOTO_GALLERY_ZOOM_BUTTON_TAG                   (int)1000003


@interface KDPhotoGalleryViewController ()<KDGifTileViewCellDelegate>

@property (nonatomic, retain) UIView *headerBar;
@property (nonatomic, retain) KDTileView *tileView;
@property (nonatomic, retain) KDPhotoOriginView *originView;

@end

@implementation KDPhotoGalleryViewController

@synthesize dataSource=dataSource_;
@synthesize imageDataSource=imageDataSource_;
@synthesize photoSourceURLs=photoSourceURLs_;

@synthesize headerBar=headerBar_;
@synthesize tileView=tileView_;
@synthesize originView = originView_;
@synthesize currentIndex = currentIndex_;


- (void) setupPhotoGallery {
    dataSource_ = nil;
    imageDataSource_ = nil;
    
    headerBar_ = nil;
    tileView_ = nil;
    
    photoSourceURLs_ = nil;
    currentIndex_ = 0;
    
    tapTimer_ = nil;
    refreshTimer_ = nil;
    
    optimalPreviewSize_ = [KDImageSize defaultPreviewImageSize].size;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupPhotoGallery];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    return self;
}

- (void)setupHeaderBar {
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40.0);
    
    UIView *headerBar = [[UIView alloc] initWithFrame:frame];
    headerBar.backgroundColor = [UIColor clearColor];
    self.headerBar = headerBar;
//    [headerBar release];
    
    // title label
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((headerBar_.frame.size.width - 240.0f) / 2, 0.0, 240.0, 40.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];;
    titleLabel.tag = KD_PHOTO_GALLERY_TITLE_VIEW_TAG;
    
    // action
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.enabled = NO;
    saveBtn.tag = KD_PHOTO_GALLERY_SAVE_BUTTON_TAG;
    [saveBtn addImageWithName:@"segment_black_button_bg.png" forState:UIControlStateNormal isBackground:YES];
    [saveBtn addImageWithName:@"gallery_save_icon.png" forState:UIControlStateNormal isBackground:NO];
    [saveBtn addImageWithName:@"gallery_save_icon_highlighted.png" forState:UIControlStateHighlighted isBackground:NO];
    [saveBtn addImageWithName:@"gallery_save_icon_disable.png" forState:UIControlStateDisabled isBackground:NO];
    
    saveBtn.frame = CGRectMake(headerBar_.frame.size.width - 40.0f, 5.0f, 30.0f, 30.0f);
    
    [saveBtn addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleBg = [[UIView alloc] initWithFrame:CGRectMake(0.0, 5.0, 50.0, 20.0)];
    titleBg.center = titleLabel.center;
    titleBg.layer.masksToBounds = YES;
    titleBg.layer.cornerRadius = 1.0f;
    titleBg.backgroundColor = [UIColor blackColor];
    titleBg.alpha = 0.6;
    [headerBar_ addSubview:titleBg];
    //KD_RELEASE_SAFELY(titleBg);
    
    [headerBar_ addSubview:titleLabel];
//    [titleLabel release];
    [headerBar addSubview:saveBtn];
    
    headerBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:headerBar_];
    
    UIButton *zoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomBtn.enabled = NO;
    zoomBtn.tag = KD_PHOTO_GALLERY_ZOOM_BUTTON_TAG;
    [zoomBtn addImageWithName:@"segment_black_button_bg.png" forState:UIControlStateNormal isBackground:YES];
    [zoomBtn addImageWithName:@"segment_black_button_highlighted_bg.png" forState:UIControlStateHighlighted isBackground:YES];
    [zoomBtn addImageWithName:@"preview_zoomin_icon.png" forState:UIControlStateNormal isBackground:NO];
    [zoomBtn addTarget:self action:@selector(showOrDismissOriginalView:) forControlEvents:UIControlEventTouchUpInside];
    zoomBtn.frame = CGRectMake(headerBar_.frame.size.width - 80.0f, 5.0f, 30.0f, 30.0f);
    
    [self.view addSubview:zoomBtn];
    
    self.originView = [[KDPhotoOriginView alloc] initWithFrame:self.view.bounds];// autorelease];
    originView_.delegate = self;
}

- (void)photoOriginView:(KDPhotoOriginView *)originView didTapWithCount:(NSUInteger)tapCount
{
    if(tapCount == 1) {
        [self dismissPhotoGalleryViewController:nil];
    }
}

- (void)loadView {
    [super loadView];
    
    self.wantsFullScreenLayout = YES;
	
	CGSize size = [UIScreen mainScreen].bounds.size;
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
		CGFloat temp = size.width;
		size.width = size.height;
		size.height = temp;
	}
	
	CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
	self.view.frame = frame;
	
	self.view.backgroundColor = [UIColor blackColor];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // retrieve display items
	if(dataSource_ != nil){
        self.imageDataSource = [dataSource_ imageSourceForPhotoGalleryViewController:self];
        // self.photoSourceURLs = [imageDataSource_ bigImageURLs];
	}
	
    CGSize size = self.view.bounds.size;
    
	// tile view
	CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
	tileView_ = [[KDTileView alloc] initWithFrame:frame style:KDTileViewStyleFullPage cellWidth:size.width paddingWidth:KD_PHOTO_GALLERY_TILE_VIEW_PADDING_WIDTH];
	tileView_.backgroundColor = [UIColor clearColor];
	
	tileView_.delegate = self;
	tileView_.dataSource = self;
    
	if(currentIndex_ != 0 && [photoSourceURLs_ count] !=1){
		tileView_.contentOffset = CGPointMake(currentIndex_ * (size.width + 2 * KD_PHOTO_GALLERY_TILE_VIEW_PADDING_WIDTH), 0.0);
	}
    if ([photoSourceURLs_ count] < 2)
        self.currentIndex = 0;
        
        
	
	[self.view addSubview:tileView_];
    
    // header bar
    [self setupHeaderBar];
    
    //	[self updateTitle];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    [self.tileView scrollToColumn:self.currentIndex];
    
    [self updateTitle];
	
    statusBarVisible_ = [UIApplication sharedApplication].statusBarHidden;
    normalBarStyle_ = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDModalViewShowNotification object:nil userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
    [self delaysChangeActionButtonState];
    
	// start timer
	[self startTapTimer];
	[self startRefreshTimer];
    
    [self loadImageSourcesIfNeed:YES];
}

- (void)showInfo:(NSString *)info visible:(BOOL)visible {
    [[KDNotificationView defaultMessageNotificationView] showInView:self.view
                                                            message:info
                                                               type:KDNotificationViewTypeNormal];
}

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark GATileView delegate and data source methods

- (NSUInteger)numberOfColumnsAtTileView:(KDTileView *)tileView {
	return (photoSourceURLs_ != nil) ? [photoSourceURLs_ count] : 0;
}

- (KDTileViewCell *)tileView:(KDTileView *)tileView cellForColumn:(NSInteger)column {
    
    BOOL isGif = [[imageDataSource_ getTimeLineImageSourceAtIndex:column] isGifImage];
    
    static NSString *GifCellIdentifier = @"GifCell";
    static NSString *DefCellIdentifier = @"DefCell";
    
    if (!isGif) {
        
        KDPhotoPreviewTileViewCell *cell = (KDPhotoPreviewTileViewCell *)[tileView dequeueReuseableCellWithIndentifier:DefCellIdentifier];
        if(cell == nil){
            cell = [[KDPhotoPreviewTileViewCell alloc] initWithIdentifier:DefCellIdentifier];// autorelease];
            cell.delegate = self;
            cell.showProgress = YES;
        }
        cell.tag = column;
        NSString *url = [photoSourceURLs_ objectAtIndex:column];
        
        BOOL isRaw = NO;
        UIImage *image = [self blurPreviewImageForURL:url isRawImage:&isRaw];
        KDTileViewCellImageType imageType = isRaw ? KDTileViewCellImageTypePreview : KDTileViewCellImageTypeBlurPreview;
        
        if(image == nil){
            imageType = KDTileViewCellImageTypeThumbnail;
            image = [self middleImageForURL:[[imageDataSource_ middleImageURLs] objectAtIndex:column]];
            if (!image)
            {
                image = [self thumbnailImageForURL:[[imageDataSource_ thumbnailImageURLs] objectAtIndex:column]];
                image = [image imageAtRect:CGRectMake(15.f, 15.f, 70.f, 70.f)];
            }
            if (!image) {
                imageType = KDTileViewCellImageTypeDefault;
                image = [self defaultPlaceholderImage];
            }
        }
        
        cell.userInfo = [NSNumber numberWithInteger:column];
        [cell displayImage:image imageType:imageType];
        
        //        if(!tileView.dragging && !tileView.decelerating && (KDTileViewCellImageTypeDefault == cell.imageType || KDTileViewCellImageTypeThumbnail == cell.imageType)){
        //            [self loadImageSourceForURL:url];
        //        }
        
        return cell;
    }
    else
    {
        KDGifTileViewCell *cell = (KDGifTileViewCell *)[tileView dequeueReuseableCellWithIndentifier:GifCellIdentifier];
        
        if (cell == nil) {
            cell = [[KDGifTileViewCell alloc] initWithIdentifier:GifCellIdentifier];// autorelease];
            cell.delegate = self;
            cell.showProgress = YES;
        }
        
//        NSString *url = [[imageDataSource_ middleImageURLs] objectAtIndex:column];
        cell.userInfo = [NSNumber numberWithInteger:column];
        
        NSData *data = [self middleImageDataForURL:[[imageDataSource_ bigImageURLs] objectAtIndex:column]];
        KDGifViewCellImageType imageType = KDGifViewCellImageTypeThumbnail;
        if (!data)
            data = [self thumbnailImageDataForURL:[[imageDataSource_ thumbnailImageURLs] objectAtIndex:column]];
        if (data)
            [cell loadImageData:data imageType:imageType];
        
        return cell;
    }
    
}

#pragma mark -
#pragma mark UIScrollView delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self willScrollTileView];
	[self invalidRefreshTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(!decelerate){
		[self loadImageSourcesIfNeed:NO];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self loadImageSourcesIfNeed:NO];
    [self didScrollTileView];
    [self startRefreshTimer];
}
- (void)willScrollTileView
{
    KDTileViewCell *centerCell = [tileView_ centerTileViewCell];
    
    if ([centerCell isKindOfClass:[KDGifTileViewCell class]]) {
        [(KDGifTileViewCell  *)centerCell stopGif];
    }
}
- (void)didScrollTileView {
	KDTileViewCell *centerCell = [tileView_ centerTileViewCell];
	if(centerCell != nil){
		NSInteger index = [[tileView_ visibleCells] indexOfObject:centerCell];
		NSInteger column = [[[tileView_ visibleColumns] objectAtIndex:index] integerValue];
		
		if(currentIndex_ != column){
			currentIndex_ = column;
			
			[self updateTitle];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(delaysChangeActionButtonState) withObject:nil afterDelay:0.5];
        }
	}
}

- (void)delaysChangeActionButtonState {
    KDTileViewCell *centerCell = [tileView_ centerTileViewCell];
    BOOL enabled = NO;
	if (centerCell != nil) {
        if ([centerCell isKindOfClass:[KDPhotoPreviewTileViewCell class]])
        {
            enabled = [(KDPhotoPreviewTileViewCell *)centerCell isDisplayRealImage];
            [self setActionButtonEnable:enabled];
            [self setZoomButtonHiden:NO];
        }
        if ([centerCell isKindOfClass:[KDGifTileViewCell class]])
        {
            enabled = [(KDGifTileViewCell *)centerCell isDisplayGifImage];
            [self setActionButtonEnable:enabled];
            [self setZoomButtonHiden:YES];
        }
    }
}

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark load image source

- (void)loadImageSourcesIfNeed:(BOOL)isFirst {
    
    KDTileViewCell *centerCell = [tileView_ centerTileViewCell];
    
    if([centerCell isKindOfClass:[KDGifTileViewCell class]])
    {
        KDGifViewCellImageType imageType = ((KDGifTileViewCell *)centerCell).imageType;
        if(KDGifViewCellImageTypeBlurPreview == imageType){
            [(KDGifTileViewCell *)centerCell startGif];
        }
    }
    
	if(centerCell != nil){
		NSInteger index = [[tileView_ visibleCells] indexOfObject:centerCell];
		NSInteger column = [[[tileView_ visibleColumns] objectAtIndex:index] integerValue];
        
        if(currentIndex_ == column && !isFirst)
            return;
    }
    
	NSArray *visibleCells = [tileView_ visibleCells];
	for(KDTileViewCell *cell in visibleCells){
        
        if ([cell isKindOfClass:[KDPhotoTileViewCell class]]) {
            KDTileViewCellImageType imageType = ((KDPhotoTileViewCell *)cell).imageType;
            if(KDTileViewCellImageTypeDefault == imageType || KDTileViewCellImageTypeThumbnail == imageType){
                
                [self loadImageSourceForURL:[photoSourceURLs_ objectAtIndex:[cell.userInfo integerValue]]];
            }
        }
	}
    
    if([centerCell isKindOfClass:[KDGifTileViewCell class]])
    {
        KDGifViewCellImageType imageType = ((KDGifTileViewCell *)centerCell).imageType;
        if(KDGifViewCellImageTypeDefault == imageType || KDGifViewCellImageTypeThumbnail == imageType){
            
            NSString *url = [[imageDataSource_ middleImageURLs] objectAtIndex:[centerCell.userInfo integerValue]];
            NSInteger index = [[tileView_ visibleCells] indexOfObject:centerCell];
            NSInteger column = [[[tileView_ visibleColumns] objectAtIndex:index] integerValue];
            
            NSData *data = [self middleImageDataForURL:[[imageDataSource_ bigImageURLs] objectAtIndex:column]];
            KDGifViewCellImageType imageType = KDGifViewCellImageTypeThumbnail;
            if (!data)
                data = [self thumbnailImageDataForURL:[[imageDataSource_ thumbnailImageURLs] objectAtIndex:column]];
            if (data)
                [(KDGifTileViewCell *)centerCell loadImageData:data imageType:imageType];
            
            imageType = KDGifViewCellImageTypePreview;
            data = [self previewImageDataForURL:url];
            if (data)
                [(KDGifTileViewCell *)centerCell loadImageData:data imageType:imageType];
            else
                [self loadImageSourceForURL:url isGif:YES];
        }
    }
    
    NSInteger olderIndex = self.currentIndex;
    KDTileViewCell *olderCell = [tileView_ cellForColumn:olderIndex];
    if ([olderCell isKindOfClass:[KDGifTileViewCell class]]) {
        NSString *url = [[imageDataSource_ middleImageURLs] objectAtIndex:olderIndex];
        [[[KDWeiboServicesContext defaultContext] getImageLoaderAdapter] cancelRequestForLoader:self url:url];
        
    }
}

- (NSString *)cacheKeyForURL:(NSString *)URL {
    return [imageDataSource_ cacheKeyForImageSourceURL:URL];
}

- (UIImage *)imageForURL:(NSString *)URL cacheType:(KDCacheImageType)imageType {
    return [[KDCache sharedCache] imageForCacheKey:[self cacheKeyForURL:URL] imageType:imageType];
}
- (NSData *)imageDataForURL:(NSString *)URL cacheType:(KDCacheImageType)imageType {
    return [[KDCache sharedCache] imageDataForCacheKey:[self cacheKeyForURL:URL] imageType:imageType];
}
- (UIImage *)previewImageForURL:(NSString *)URL {
    return [self imageForURL:URL cacheType:KDCacheImageTypePreview];
}
- (UIImage *)middleImageForURL:(NSString *)URL
{
    return [self imageForURL:URL cacheType:KDCacheImageTypeMiddle];
}
- (UIImage *)thumbnailImageForURL:(NSString *)URL
{
    return [self imageForURL:URL cacheType:KDCacheImageTypeThumbnail];
}
- (NSData *)previewImageDataForURL:(NSString *)URL {
    return [self imageDataForURL:URL cacheType:KDCacheImageTypePreview];
}
- (NSData *)middleImageDataForURL:(NSString *)URL
{
    return [self imageDataForURL:URL cacheType:KDCacheImageTypeMiddle];
}
- (NSData *)thumbnailImageDataForURL:(NSString *)URL
{
    return [self imageDataForURL:URL cacheType:KDCacheImageTypeThumbnail];
}
- (UIImage *)blurPreviewImageForURL:(NSString *)URL isRawImage:(BOOL *)isRaw {
    UIImage *image = [self imageForURL:URL cacheType:KDCacheImageTypePreviewBlur];
    if (image == nil) {
        image = [self imageForURL:URL cacheType:KDCacheImageTypePreview];
        if (image != nil && isRaw != NULL) {
            *isRaw = YES;
        }
    }
    
    return image;
}
- (void)loadImageSourceForURL:(NSString *)URL isGif:(BOOL)gif
{
    NSString *cacheKey = [self cacheKeyForURL:URL];
    BOOL exists = [[KDCache sharedCache] hasImageForCacheKey:cacheKey imageType:KDCacheImageTypePreview];
    
    if(!exists){
        if(URL == nil || [URL length] < 1){
            // Invalid request path, just show the default image and disappear activity indicator view
            NSArray *cells = [tileView_ visibleCells];
            for(KDTileViewCell *cell in cells){
                
                if ([cell isKindOfClass:[KDGifTileViewCell class]])
                {
                    NSString *url = [[imageDataSource_ middleImageURLs] objectAtIndex:[cell.userInfo integerValue]];
                    if (url == URL)
                    {
                        [(KDGifTileViewCell *)cell loadImageData:[self defaultPlaceholderImageData] imageType:KDGifViewCellImageTypeError];
                        break;
                    }
                    
                }
                else if([cell isKindOfClass:[KDPhotoTileViewCell class]])
                {
                    NSString *url = [photoSourceURLs_ objectAtIndex:[cell.userInfo integerValue]];
                    if (URL == url)
                    {
                        [(KDPhotoTileViewCell *)cell displayImage:[self defaultPlaceholderImage] imageType:KDTileViewCellImageTypeError];
                        break;
                    }
                    
                }
            }
            
            return;
        }
        KDImageLoaderAdapter *imageLoaderAdapter = [[KDWeiboServicesContext defaultContext] getImageLoaderAdapter];
        [imageLoaderAdapter asyncLoadImageWithLoader:self
                                              forURL:URL
                                           cacheType:KDCacheImageTypePreview
                                           imageType:gif?KDLoadImageTypeGif:KDLoadImageTypeDefault
                                         fromNetwork:YES completedBlock:nil];
    }
}
- (void)loadImageSourceForURL:(NSString *)URL {
    [self loadImageSourceForURL:URL isGif:NO];
}
- (void)updateImageDataSourceForURL:(NSString *)URL imageDataSource:(NSData *)imageSource succeed:(BOOL)succeed
{
    NSArray *cells = [tileView_ visibleCells];
	
	KDGifTileViewCell *target = nil;
	for(KDGifTileViewCell *cell in cells){
        
        NSString *url = [[imageDataSource_ middleImageURLs] objectAtIndex:[cell.userInfo integerValue]];
		if(url == URL){
			target = cell;
			break;
		}
	}
    
    if(target != nil){
		KDGifViewCellImageType imageType;
		NSData *placeholderImageData = nil;
		if(succeed){
			if(!tileView_.dragging && !tileView_.decelerating && refreshTimer_ == nil){
                KDGifTileViewCell *centerCell = (KDGifTileViewCell *)[tileView_ centerTileViewCell];
                if(centerCell == target && imageSource != nil){
                    imageType = KDGifViewCellImageTypePreview;
                    [centerCell loadImageData:imageSource imageType:imageType];
                    return;
                }
            }
            
            placeholderImageData = [self previewImageDataForURL:URL];
            imageType = KDGifViewCellImageTypePreview ;
		}
        
		if(placeholderImageData == nil){
            imageType = KDGifViewCellImageTypeError;
            placeholderImageData = [self thumbnailImageDataForURL:[[imageDataSource_ thumbnailImageURLs] objectAtIndex:[target.userInfo integerValue]]];
            if (placeholderImageData == nil)
                placeholderImageData = [self defaultPlaceholderImageData];
		}
		
		// if still can not load the image, we will show the default image again,
		// but we will disappear the activity indicator view
		[target loadImageData:placeholderImageData imageType:imageType];
	}
    
    
}
- (void)updateImageSourceForURL:(NSString *)URL imageSource:(UIImage *)imageSource succeed:(BOOL)succeed {
	NSArray *cells = [tileView_ visibleCells];
	
	KDPhotoTileViewCell *target = nil;
	for(KDPhotoTileViewCell *cell in cells){
        NSString *url = [photoSourceURLs_ objectAtIndex:[cell.userInfo integerValue]];
		if(url == URL){
			target = cell;
			break;
		}
	}
	
	if(target != nil){
		KDTileViewCellImageType imageType;
		UIImage *placeholderImage = nil;
		if(succeed){
			if(!tileView_.dragging && !tileView_.decelerating && refreshTimer_ == nil){
                KDPhotoPreviewTileViewCell *centerCell = (KDPhotoPreviewTileViewCell *)[tileView_ centerTileViewCell];
                if(centerCell == target && imageSource != nil){
                    imageType = KDTileViewCellImageTypePreview;
                    [centerCell displayWithClearImage:imageSource imageType:imageType];
                    return;
                }
            }
            
            BOOL isRaw = NO;
            placeholderImage = [self blurPreviewImageForURL:URL isRawImage:&isRaw];
            imageType = isRaw ? KDTileViewCellImageTypePreview : KDTileViewCellImageTypeBlurPreview;
		}
        
		if(placeholderImage == nil){
            
            imageType = KDTileViewCellImageTypeError;//KDTileViewCellImageTypeThumbnail;
            placeholderImage = [self middleImageForURL:[[imageDataSource_ thumbnailImageURLs] objectAtIndex:[target.userInfo integerValue]]];
            
            if (!placeholderImage)
            {
                placeholderImage = [self thumbnailImageForURL:[[imageDataSource_ thumbnailImageURLs] objectAtIndex:[target.userInfo integerValue]]];
                placeholderImage = [placeholderImage imageAtRect:CGRectMake(15.f, 15.f, 70.f, 70.f)];
            }
            if (!placeholderImage) {
//                imageType = KDTileViewCellImageTypeError;
                placeholderImage = [self defaultPlaceholderImage];

            }
		}
		
		// if still can not load the image, we will show the default image again,
		// but we will disappear the activity indicator view
		[target displayImage:placeholderImage imageType:imageType];
	}
}

////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Custom methods

- (void)updateTitle {
    UIView *titleItem = [headerBar_ viewWithTag:KD_PHOTO_GALLERY_TITLE_VIEW_TAG];
    NSString *titleText = [NSString stringWithFormat:@"%u/%lu", (unsigned int)currentIndex_ + 1, (unsigned long)[photoSourceURLs_ count]];
    ((UILabel *)titleItem).text = titleText;
}

- (void)setActionButtonEnable:(BOOL)enable {
    UIView *actionItem = [headerBar_ viewWithTag:KD_PHOTO_GALLERY_SAVE_BUTTON_TAG];
    ((UIButton *)actionItem).enabled = enable;
    UIView *zoomBtn = [self.view viewWithTag:KD_PHOTO_GALLERY_ZOOM_BUTTON_TAG];
    ((UIButton *)zoomBtn).enabled = enable;
    
}
- (void)setZoomButtonHiden:(BOOL)hiden
{
    UIView *zoomBtn = [self.view viewWithTag:KD_PHOTO_GALLERY_ZOOM_BUTTON_TAG];
    zoomBtn.hidden = hiden;
    
}
- (void)dismissPhotoGalleryViewController:(UIButton *)btn {
    // cancel the requests before exist photo gallery
    [[[KDWeiboServicesContext defaultContext] getImageLoaderAdapter] removeImageSourceLoader:self cancelRequest:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showOrDismissOriginalView:(UIButton *)btn {
    
    KDTileViewCell *cell = (KDTileViewCell *) [tileView_ centerTileViewCell];
    if ([cell isKindOfClass:[KDGifTileViewCell class]])     return;
    if(originView_.superview == nil) {
        [btn setImage:[UIImage imageNamed:@"preview_zoomout_icon.png"] forState:UIControlStateNormal];
        
        if(originView_.imageSource == nil)
            originView_.imageSource = imageDataSource_;
        UIView *zoomBtn = [self.view viewWithTag:KD_PHOTO_GALLERY_ZOOM_BUTTON_TAG];
        [self.view insertSubview:originView_ belowSubview:zoomBtn];
        [originView_ loadImageWithURL:[[imageDataSource_ bigImageURLs] objectAtIndex:currentIndex_]];
    }else {
        [btn setImage:[UIImage imageNamed:@"preview_zoomin_icon.png"] forState:UIControlStateNormal];
        [originView_ freeImage];
        [originView_ removeFromSuperview];
        
        [self makeActionBarWithVisible:YES animated:YES];
    }
}

- (void)makeActionBarWithVisible:(BOOL)visible animated:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:visible];
	
    [UIView animateWithDuration:0.25
                     animations:^{
                         headerBar_.hidden = !visible;
                     }];
}

- (void)startTapTimer {
    [self invalidTapTimer];
    tapTimer_ = [NSTimer scheduledTimerWithTimeInterval:KD_PHOTO_GALLERY_TAP_TIMER_INTERVAL target:self
                                               selector:@selector(tapTimerFire:) userInfo:nil repeats:NO];
}

- (void)startRefreshTimer {
    [self invalidRefreshTimer];
	refreshTimer_ = [NSTimer scheduledTimerWithTimeInterval:KD_PHOTO_GALLERY_REFRESH_TIMER_INTERVAL target:self
                                                   selector:@selector(refreshTimerFire:) userInfo:nil repeats:NO];
}

- (void)tapTimerFire:(NSTimer *)timer {
    [self invalidTapTimer];
	
    //	[self makeActionBarWithVisible:NO animated:YES];
	photoGalleryFags_.disappearedBars = 1;
}

- (void)refreshTimerFire:(NSTimer *)timer {
    [self invalidRefreshTimer];
	
	if(!tileView_.dragging && !tileView_.decelerating){
        KDTileViewCell *cell = [tileView_ centerTileViewCell];
        if ([cell isKindOfClass:[KDPhotoPreviewTileViewCell class]])
        {
            if(cell && KDTileViewCellImageTypeBlurPreview == ((KDPhotoPreviewTileViewCell *)cell).imageType){
                NSString *url = [photoSourceURLs_ objectAtIndex:[cell.userInfo integerValue]];
                UIImage *image = [self previewImageForURL:url];
                if(image != nil){
                    [((KDPhotoPreviewTileViewCell *)cell) displayWithClearImage:image imageType:KDTileViewCellImageTypePreview];
                }
            }
        }
        
	}
}

- (void)invalidTapTimer {
    if(tapTimer_ != nil) {
        [tapTimer_ invalidate];
        tapTimer_ = nil;
    }
}

- (void)invalidRefreshTimer {
    if(refreshTimer_ != nil) {
        [refreshTimer_ invalidate];
        refreshTimer_ = nil;
    }
}

- (void)savePhoto{
    NSString *imageURL = [[imageDataSource_ bigImageURLs] objectAtIndex:currentIndex_];
    KDImageLoaderAdapter *loadAdapter = [[KDWeiboServicesContext defaultContext] getImageLoaderAdapter];
    
    UIImage *bigImage = [loadAdapter imageWithLoader:self forURL:imageURL
                                           cacheType:KDCacheImageTypeOrigin fromNetwork:YES];
    
    [self savePhotoToPhotoLibrary:bigImage];
}


- (void)savePhotoToPhotoLibrary:(UIImage *)photo {
    UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// the callback method about save image to photo library
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[self showInfo:NSLocalizedString(@"SAVE_PHOTO_DID_DONE", @"") visible:YES];
}


////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageSourceLoader delegate methods

- (id<KDImageDataSource>)getImageDataSource {
    return imageDataSource_;
}

- (UIImage *)defaultPlaceholderImage {
    return [UIImage imageNamed:@"default_image_plachloder.png"];
}
- (NSData *)defaultPlaceholderImageData
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default_image_plachloder" ofType:@"png"]];
}
- (KDImageSize *)optimalImageSize {
    return [KDImageSize defaultPreviewImageSize];
}

- (void)imageSourceLoaderDidFinishLoad:(UIImage *)image cacheKey:(NSString *)cacheKey succeed:(BOOL)succeed {
    
    if (!succeed)
        [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDPhotoGalleryViewController_fail")inView:self.view.window];
    
    NSString *URL = nil;
    for(NSString *item in photoSourceURLs_){
        if([cacheKey isEqualToString:[self cacheKeyForURL:item]]){
            URL = item;
            break;
        }
    }
    
    [self updateImageSourceForURL:URL imageSource:image succeed:succeed];
}

- (void)imageSourceLoaderWithCacheKey:(NSString *)cacheKey progressMonitor:(KDRequestProgressMonitor *)progressMonitor {
    KDPhotoPreviewTileViewCell *cell = (KDPhotoPreviewTileViewCell *) [tileView_ centerTileViewCell];
    if (![cell isKindOfClass:[KDPhotoPreviewTileViewCell class]]) return;
    NSString *url = [photoSourceURLs_ objectAtIndex:[cell.userInfo integerValue]];
    NSString *cellCackeKey = [self cacheKeyForURL:url];
    if ([cacheKey isEqualToString:cellCackeKey]) {
        if(cell.progressView == nil){
            [cell setProgressViewWithVisible:YES];
        }
        
        float percent = [progressMonitor finishedPercent];
        [cell.progressView setProgress:percent];
    }
}

- (void) imageDataSourceLoaderDidFinishLoad:(NSData *)data cacheKey:(NSString *)cacheKey succeed:(BOOL)succeed
{
    if (!succeed)
        [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDPhotoGalleryViewController_fail")inView:self.view.window];
    
    NSString *URL = nil;
    for(NSString *item in [imageDataSource_ middleImageURLs]){
        if([cacheKey isEqualToString:[self cacheKeyForURL:item]]){
            URL = item;
            break;
        }
    }
    [self updateImageDataSourceForURL:URL imageDataSource:data succeed:succeed];
}
- (void) imageDataSourceLoaderWithCacheKey:(NSString *)cacheKey progressMonitor:(KDRequestProgressMonitor *)progressMonitor
{
    KDGifTileViewCell *cell = (KDGifTileViewCell *) [tileView_ centerTileViewCell];
    if (![cell isKindOfClass:[KDGifTileViewCell class]]) return;
    
    NSString *url = [[imageDataSource_ middleImageURLs] objectAtIndex:[cell.userInfo integerValue]];
    NSString *cellCackeKey = [self cacheKeyForURL:url];
    if ([cacheKey isEqualToString:cellCackeKey]) {
        if(cell.progressView == nil){
            [cell setProgressViewWithVisible:YES];
        }
        
        float percent = [progressMonitor finishedPercent];
        
        [cell.progressView setProgress:percent];
    }
}
////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDPhotoTileViewCell delegate methods

- (void)displayRealImageInPhotoTileViewCell:(KDPhotoTileViewCell *)cell {
    KDTileViewCell *centerCell = [tileView_ centerTileViewCell];
    if(cell == centerCell){
        // TODO xxx enable action button
        [self setActionButtonEnable:YES];
        [self setZoomButtonHiden:NO];
    }
}

- (void)didTapInPhotoTileViewCell:(KDPhotoTileViewCell *)cell {
    [self dismissPhotoGalleryViewController:nil];
}
#pragma mark -
#pragma mark KDGifTileViewCell delegate methods

- (void)didDisplayGifImageInGifTileViewCell:(KDGifTileViewCell *)cell
{
    KDTileViewCell *centerCell = [tileView_ centerTileViewCell];
    if(cell == centerCell){
        // TODO xxx enable action button
        [self setZoomButtonHiden:YES];
        [self setActionButtonEnable:YES];
    }
}
- (void)didTapInGifTileViewCell:(KDGifTileViewCell *)cell
{
    [self dismissPhotoGalleryViewController:nil];
}


#pragma mark -
#pragma mark MFMailComposeViewController delegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark interface orientation methods

// for iOS 5 and earlier
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationPortrait == toInterfaceOrientation
    || UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation
    || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
}

// for iOS 6
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
    [tileView_ shouldChangeToInterfaceOrientation:toInterfaceOrientation];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(headerBar_);
    //KD_RELEASE_SAFELY(tileView_);
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    [self invalidTapTimer];
    [self invalidRefreshTimer];
    
	[[UIApplication sharedApplication] setStatusBarHidden:statusBarVisible_];
	[[UIApplication sharedApplication] setStatusBarStyle:normalBarStyle_];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDModalViewHideNotification object:nil];
}

- (void) dealloc {
    [self invalidTapTimer];
    [self invalidRefreshTimer];
    
    dataSource_ = nil;
    //imageDataSource_ = nil;
    //KD_RELEASE_SAFELY(imageDataSource_);
    //KD_RELEASE_SAFELY(photoSourceURLs_);
    
    //KD_RELEASE_SAFELY(headerBar_);
    //KD_RELEASE_SAFELY(tileView_);
    //KD_RELEASE_SAFELY(originView_);
    
    //[super dealloc];
}

@end
