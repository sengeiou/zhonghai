//
//  KDThumbnailView2.m
//  kdweibo
//
//  Created by 王 松 on 13-7-2.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDThumbnailView2.h"

#import "KDCommon.h"

#import "UIImage+Additions.h"

#import "KDAttachment.h"

#import <QuartzCore/QuartzCore.h>


#define kKDImageThumbnailSize CGSizeMake(70.0f, 70.0f)
#define kKDVideoThumbnailSize CGSizeMake(100.0f, 100.0f)
#define kImageInset (float)6.0f

@interface KDThumbnailView2  ()

@property (nonatomic, retain) KDThumbnailGridView *thumbnailView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end

@interface KDThumbnailImageView : UIImageView

@property(nonatomic, retain) NSString *imageURL;

@property(nonatomic, retain) KDCompositeImageSource *imageDataSource;
@property(nonatomic, retain) KDImageSource          *imageSource;
@property(nonatomic, assign) SDWebImageScaleOptions cacheType;
@property(nonatomic, assign) BOOL           isLoaded;

@property(nonatomic, assign, getter = isShowVideoButton) BOOL showVideoButton;

- (void)setImageURL:(NSString *)imageURL type:(SDWebImageScaleOptions)cacheType;

@property (nonatomic, retain) NSArray *attachments;

@property(nonatomic, retain) UILabel *sizeLabel;

@end

@interface KDThumbnailGridView : UIView

@property(nonatomic, retain) KDCompositeImageSource *imageDataSource;

@property(nonatomic, retain) NSMutableArray *imageViews;

@property(nonatomic, assign) SDWebImageScaleOptions cacheType;

@property (nonatomic, retain) KDStatus *status;

- (CGSize)thumbnailSize;

@end


@implementation KDThumbnailView2

@synthesize delegate=delegate_;
@synthesize imageDataSource=imageDataSource_;
@synthesize thumbnailSize=thumbnailSize_;

@dynamic hasThumbnail;
@dynamic loadThumbnail;

@synthesize thumbnailView=thumbnailView_;
@synthesize infoLabel=infoLabel_;
@synthesize activityView=activityView_;

- (void)setupThumbnailView {
    self.clipsToBounds = YES;
    
    // thumbnail image view
    thumbnailView_ = [[KDThumbnailGridView alloc] initWithFrame:CGRectZero];
    thumbnailView_.contentMode = UIViewContentModeScaleAspectFit;
    thumbnailView_.status = self.status;
    [self addSubview:thumbnailView_];
    
    // info label
    infoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    infoLabel_.backgroundColor = [UIColor clearColor];
    infoLabel_.font = [UIFont systemFontOfSize:14.0];
    infoLabel_.adjustsFontSizeToFitWidth = YES;
    infoLabel_.minimumScaleFactor = 11.0;
    infoLabel_.textColor = [UIColor blackColor];
    infoLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:infoLabel_];
    
    // activity view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityView_];
}

+ (id)thumbnailViewWithSize:(KDImageSize *)size {
    KDThumbnailView2 *thumbnailView = [super buttonWithType:UIButtonTypeCustom];
    if(thumbnailView != nil){
        thumbnailView.thumbnailSize = size;
        
        [thumbnailView setupThumbnailView];
    }
    
    return thumbnailView;
}

+ (id) thumbnailViewWithStatus:(KDStatus *)status
{
    KDThumbnailView2 *thumbnailView = [super buttonWithType:UIButtonTypeCustom];
    if(thumbnailView != nil){
        thumbnailView.thumbnailSize = nil;
        thumbnailView.status = status;
        [thumbnailView setupThumbnailView];
    }
    
    return thumbnailView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    thumbnailView_.frame = self.bounds;
    //thumbnailView_ clipsToBounds];
    
    CGFloat height = self.bounds.size.height * 0.5;
    
    CGRect rect = activityView_.frame;
    rect.origin = CGPointMake((self.bounds.size.width - rect.size.width) * 0.5, height - rect.size.height);
    activityView_.frame = rect;
    
    rect = CGRectMake(0.0, height, self.bounds.size.width, 24.0);
    infoLabel_.frame = rect;
}

- (KDCacheImageType)cacheImageType {
    return KDCacheImageTypeThumbnail;
}

- (UIImage *)defaultThumbnail {
    return [UIImage imageNamed:@"default_cell_thumbnail_bg.png"];
}

- (void)loadThumbnailFromDisk {
    [self.thumbnailView setImageDataSource:self.imageDataSource];
}

- (void)setStatus:(KDStatus *)status
{
    if (_status != status) {
        //KD_RELEASE_SAFELY(_status);
        _status = status;// retain];
    }
    [thumbnailView_ setStatus:_status];
}

- (BOOL)hasVideo
{
    return [self.status hasVideo];
}

+(CGSize)thumbnailDefaultSize {

    return kKDImageThumbnailSize;
}

+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource {
    // make the image size use
    CGSize size = kKDImageThumbnailSize;
    
    // return size;
    
    if ([imageDataSource hasImageSource]) {
        UIImage *image = [[SDWebImageManager sharedManager] diskImageForURL:[NSURL URLWithString:[imageDataSource thumbnailImageURL]] options:SDWebImageScaleThumbnail];
        
        if (image != nil) {
            size = image.size;
            
            CGFloat aspectRatio = size.height / size.width;
            if(size.height > size.width) {
                size.height = kKDImageThumbnailSize.height;
                size.width = size.height / aspectRatio;
            }else {
                size.width = kKDImageThumbnailSize.width;
                size.height = size.width * aspectRatio;
            }
            
        }
    }
    
    return size;
}

+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource showAll:(BOOL) showAll{
    // make the image size use
    CGSize size = kKDImageThumbnailSize;
    
    //视频
    if ([imageDataSource hasImageSource] && [[(KDCompositeImageSource *)imageDataSource imageSources] count] == 1) {
        return kKDVideoThumbnailSize;
    }
    
    if ([imageDataSource hasImageSource] && !showAll) {
        size = [KDImageSize defaultMiddleImageSize].size;
    } else if ([imageDataSource hasImageSource] && showAll) {
        int count = (int)[[(KDCompositeImageSource *)imageDataSource imageSources] count];
        count = count > 9 ? 9 : count;
        
        size.width = count > 3 ? kKDImageThumbnailSize.width * 3 + kImageInset * 4 : kKDImageThumbnailSize.width * count + kImageInset * (count + 1);
        size.height = kKDImageThumbnailSize.height * ((count + 2) / 3) + kImageInset * (count / 3);
    }
    
    return size;
}

+ (CGSize)defaultMinimalThumbnailSize {
    return kKDImageThumbnailSize;
}

- (void)setImageDataSourceWithNoLoading:(id<KDImageDataSource>)imageDataSource {
    
    if(imageDataSource_ != imageDataSource) {
//        [imageDataSource_ release];
        imageDataSource_ = imageDataSource;// retain];
    }
}

- (void)setImageDataSource:(id<KDImageDataSource>)imageDataSource {
    
    if(imageDataSource_ != imageDataSource){
//        [imageDataSource_ release];
        imageDataSource_ = imageDataSource;// retain];
        
        hasThumbnail_ = NO;
        loadThumbnail_ = NO;
    }
    
    if(imageDataSource_ != nil){
        [self setLoadThumbnail:YES];
        
    }
}

- (void)setImageDataSource:(id<KDImageDataSource>)imageDataSource withType:(SDWebImageScaleOptions)type
{

    if(imageDataSource_ != imageDataSource){
//        [imageDataSource_ release];
        imageDataSource_ = imageDataSource ;//retain];
        
        hasThumbnail_ = NO;
        loadThumbnail_ = NO;
        self.thumbnailView.cacheType = type;
    }
    
    if(imageDataSource_ != nil){
        [self setLoadThumbnail:YES];
    }
}

- (id<KDImageDataSource>)imageDataSource {
    return imageDataSource_;
}

- (BOOL)hasThumbnail {
    return hasThumbnail_;
}

- (void)setLoadThumbnail:(BOOL)loadThumbnail {

    if(!!loadThumbnail_ != !!loadThumbnail){
        loadThumbnail_ = loadThumbnail;
        
        if(loadThumbnail_ && !hasThumbnail_){
            self.thumbnailView.imageDataSource = self.imageDataSource;
        }
    }
   
}

- (BOOL)loadThumbnail {
    return loadThumbnail_;
}

- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(imageDataSource_);
    //KD_RELEASE_SAFELY(thumbnailSize_);
    
    //KD_RELEASE_SAFELY(thumbnailView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(_status);
    
    //[super dealloc];
}

@end


@implementation KDThumbnailGridView

- (void)setImageDataSource:(KDCompositeImageSource *)imageDataSource
{
    if (_imageDataSource != imageDataSource) {
        //KD_RELEASE_SAFELY(_imageDataSource);
        _imageDataSource = imageDataSource;// retain];
    }
    
    [self resetView];
}

- (void)setStatus:(KDStatus *)status
{
    if (_status != status) {
        //KD_RELEASE_SAFELY(_status);
        _status = status;// retain];
    }
    [self resetView];
}

- (void)resetView
{
    CGRect frame = self.frame;
    frame.size = [self thumbnailSize];
    self.frame = frame;
    
    int count = (int)[[_imageDataSource imageSources] count];
    
    for (UIView *temp in self.subviews) {
        if ([temp isKindOfClass:[KDThumbnailImageView class]]) {
            [temp removeFromSuperview];
        }
    }
    
    if (_imageViews == nil) {
        _imageViews = [NSMutableArray array];// retain];
    }
    [_imageViews removeAllObjects];
    
    NSArray *thumbnailImageURLs = [_imageDataSource thumbnailImageURLs];
    SDWebImageScaleOptions cacheType = self.cacheType;
    count = count > 9 ? 9 : count;
    for(int i = 0; i < count; i++) {
        
        CGRect rect = CGRectZero;
        rect.origin.x = (i % 3 + 1) * kImageInset + kKDImageThumbnailSize.width * (i % 3);
        rect.origin.y = (i / 3) * (kKDImageThumbnailSize.height + kImageInset);
        if ([_status hasVideo] || count == 1) {
            rect.size = kKDVideoThumbnailSize;
        }else {
            rect.size = kKDImageThumbnailSize;
        }
        
        KDThumbnailImageView *imageView = [[KDThumbnailImageView alloc] initWithFrame:rect] ;//autorelease];
        imageView.imageSource = [self.imageDataSource.imageSources objectAtIndex:i];
        imageView.imageDataSource = self.imageDataSource;
        imageView.showVideoButton = [_status hasVideo];
        imageView.attachments = _status.attachments;
        imageView.cacheType = _cacheType;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnThumbnailView:)];
        [imageView addGestureRecognizer:tapGesture];
        
        //KD_RELEASE_SAFELY(tapGesture);
        
        NSString *imageURL = thumbnailImageURLs.count > i ? [thumbnailImageURLs objectAtIndex:i] : nil;
        
        [imageView setImageURL:imageURL type:cacheType];
        
        [self addSubview:imageView];
        imageView.tag = i + 1;
        
        [_imageViews addObject:imageView];
    }
}

- (void)didTapOnThumbnailView:(UITapGestureRecognizer *)gesture
{
    KDThumbnailImageView *view = (KDThumbnailImageView *)gesture.view;
     NSArray *userInfo =[NSArray arrayWithObjects:[NSNumber numberWithInt:(int)view.tag - 1],_imageViews,nil] ;
    KDThumbnailView2 *thumbnailView = ((KDThumbnailView2 *)self.superview);
    
    [thumbnailView.delegate didTapOnThumbnailView:thumbnailView userInfo:userInfo];
}


- (CGSize)thumbnailSize
{
    CGSize size = kKDImageThumbnailSize;

    if ([_imageDataSource hasImageSource]) {
        int count = (int)[[_imageDataSource imageSources] count];
        size.width = count > 3 ? kKDImageThumbnailSize.width * 3 : kKDImageThumbnailSize.width * count;
        size.height = kKDImageThumbnailSize.height * ((count + 2) / 3);
    }
    
    return size;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_imageViews);
    //KD_RELEASE_SAFELY(_imageDataSource);
    //KD_RELEASE_SAFELY(_status);
    //[super dealloc];
}

@end

@implementation KDThumbnailImageView
@synthesize imageSource = _imageSource;
@synthesize isLoaded    = _isLoaded;
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:239.f / 255.f green:239.f / 255.f blue:239.f / 255.f alpha:1.0f];
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        UIImageView *playImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoplay_s.png"]];
        playImage.tag = 10001;
        playImage.frame = CGRectMake((frame.size.width - 33.0f) / 2., (frame.size.height - 33.0f) / 2., 33.0f, 33.0f);
        playImage.hidden = YES;
        [self addSubview:playImage];
//        [playImage release];
        
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 67.f, self.frame.size.height - 22.f, 60.f, 20.f)];
        _sizeLabel.layer.cornerRadius = 10.f;
        _sizeLabel.layer.masksToBounds = YES;
        _sizeLabel.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.5];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.font = [UIFont boldSystemFontOfSize:12.f];
        [self addSubview:_sizeLabel];

        self.clipsToBounds = YES;
        _showVideoButton = NO;
        _isLoaded = NO;
    }
    return self;
}

- (void)_loadThumbnail:(BOOL)fromNetwork {
    
    [self showVideoHint:self.isShowVideoButton];
    

    [self setImageWithURL:[NSURL URLWithString:_imageURL] placeholderImage:[self defaultPlaceholderImage] scale:[self cacheImageType] options:SDWebImageRetryFailed|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType){
        
        if ([url isEqual:[NSURL URLWithString:_imageURL]]) {
            [self updateThumbnail:image];
        }
        
    }];
    
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL != imageURL) {
        //KD_RELEASE_SAFELY(_imageURL);
        _imageURL = imageURL;// retain];
    }
    _cacheType = KDCacheImageTypeThumbnail;
    [self loadThumbnailFromNetwork];
}

- (void)setImageURL:(NSString *)imageURL type:(SDWebImageScaleOptions)cacheType
{
    if (_imageURL != imageURL) {
        //KD_RELEASE_SAFELY(_imageURL);
        _imageURL = imageURL;// retain];
    }
    _cacheType = cacheType;
    [self loadThumbnailFromNetwork];
}

- (void)loadThumbnailFromNetwork {
    [self _loadThumbnail:YES];
}

- (void)loadThumbnailFromDisk {
    [self _loadThumbnail:NO];
}

- (SDWebImageScaleOptions)cacheImageType {
    return _cacheType;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIImageView *gifMarkView = (UIImageView *)[self viewWithTag:0x99];
    if ([_imageSource.fileType hasSuffix:@"image/gif"]) {
        if (!gifMarkView) {
            
            UIImage *markImage = [UIImage imageNamed:@"preview_gif.png"];
            CGRect rect = self.bounds;
            rect.origin.y  = CGRectGetHeight(rect) - markImage.size.height;
            rect.origin.x  = CGRectGetWidth(rect) - markImage.size.width-5;
            rect.size = markImage.size;
            UIImageView *gifMarkView = [[UIImageView alloc] initWithFrame:rect];
            gifMarkView.image = markImage;
            gifMarkView.tag = 0x99;
            [self addSubview:gifMarkView];
//            [gifMarkView release];
        }
        gifMarkView.hidden = NO;
    }
    else
    {
        if (gifMarkView)
            gifMarkView.hidden = YES;
    }
}

- (void)updateThumbnail:(UIImage *)thumbnail{

    if(thumbnail != nil){
        self.backgroundColor = [UIColor clearColor];
        ////多图和视频时切成方形 王松 2013-10-22
        if ((thumbnail.size.height == 100 && thumbnail.size.width == 100 && !CGSizeEqualToSize(CGSizeMake(100, 100), self.bounds.size)) || self.isShowVideoButton) {
            thumbnail = [thumbnail imageAtRect:CGRectMake(15.f, 15.f, 70.f, 70.f)];
        }
//        self.image = thumbnail;
    }else {
        self.image = [self defaultThumbnail];
    }
    _isLoaded = thumbnail;
//    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
}

- (void)showVideoHint:(BOOL)show
{
    UIView *videoHint = [self viewWithTag:10001];
    videoHint.hidden = !show;
    _sizeLabel.hidden = !show;
    if (show && _attachments.count > 0) {
        _sizeLabel.text = [self videoSize];
    }
}

- (NSString *)videoSize
{
    KDAttachment *temp = (KDAttachment *)[_attachments objectAtIndex:0];
    NSString *result = @"";
    if (temp.fileSize / 1024 >= 1024) {
        result = [NSString stringWithFormat:@"%.2fMB", (float)temp.fileSize / 1024. / 1024.];
    }else {
        result = [NSString stringWithFormat:@"%dKB", (int)temp.fileSize / 1024];
    }
    return result;
}

- (UIImage *)defaultThumbnail {
    return nil; //[UIImage imageNamed:@"default_cell_thumbnail_bg.png"];
}

#pragma mark -
#pragma mark KDImageDataSource methods

- (id<KDImageDataSource>)getImageDataSource {
    return _imageDataSource;
}

- (UIImage *)defaultPlaceholderImage {
    return nil;
}

- (KDImageSize *)optimalImageSize {
    return [KDImageSize defaultThumbnailImageSize];
}

- (void)dealloc
{

    [self cancelCurrentImageLoad];
    
    //KD_RELEASE_SAFELY(_imageSource);
    //KD_RELEASE_SAFELY(_imageDataSource);
    //KD_RELEASE_SAFELY(_imageURL);
    //KD_RELEASE_SAFELY(_attachments);
    //KD_RELEASE_SAFELY(_sizeLabel);
    //[super dealloc];
}

@end
