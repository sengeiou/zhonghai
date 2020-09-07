//
//  KDThumbnailView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDThumbnailView.h"
#import "KDAttachment.h"

@interface KDThumbnailView  ()

@property (nonatomic, retain) UIImageView *thumbnailView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIImageView *playImage;
@property (nonatomic, retain) UILabel *sizeLabel;
@property (nonatomic, retain)id<SDWebImageOperation> loadOperation;
@end


@implementation KDThumbnailView

@synthesize delegate=delegate_;
@synthesize imageDataSource=imageDataSource_;
@synthesize thumbnailSize=thumbnailSize_;

@dynamic hasThumbnail;
@dynamic loadThumbnail;

@synthesize thumbnailView=thumbnailView_;
@synthesize infoLabel=infoLabel_;
@synthesize activityView=activityView_;
@synthesize status = status_;
@synthesize playImage = playImage_;

- (void)setupThumbnailView {
    self.clipsToBounds = YES;
    
    // thumbnail image view
    thumbnailView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    thumbnailView_.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:thumbnailView_];
    
    playImage_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoplay.png"]];
    playImage_.hidden = YES;
    [self addSubview:playImage_];
    
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sizeLabel.hidden = YES;
    _sizeLabel.backgroundColor = [UIColor clearColor];
    _sizeLabel.textAlignment = NSTextAlignmentRight;
    _sizeLabel.textColor = [UIColor redColor];
     _sizeLabel.font = [UIFont systemFontOfSize:12.f];
    [self addSubview:_sizeLabel];
    
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
    KDThumbnailView *thumbnailView = [super buttonWithType:UIButtonTypeCustom];
    if(thumbnailView != nil){
        thumbnailView.thumbnailSize = size;
        
        [thumbnailView setupThumbnailView];
    }
    
    return thumbnailView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    thumbnailView_.frame = self.bounds;
    //thumbnailView_ clipsToBounds];
    playImage_.frame = CGRectMake((self.frame.size.width - 40.0f) / 2., (self.frame.size.height - 40.0f) / 2., 40.0f, 40.0f);
    playImage_.hidden = ![status_ hasVideo];
    if ([status_ hasVideo] && [status_.attachments count] > 0) {
        _sizeLabel.frame = CGRectMake(self.frame.size.width - 80.f, self.frame.size.height - 30.f, 60.f, 30.f);
        _sizeLabel.hidden = NO;
        KDAttachment *temp = (KDAttachment *)[status_.attachments objectAtIndex:0];
        _sizeLabel.text = [NSString stringWithFormat:@"%dkb", (int)temp.fileSize / 1024];
    }
    
    CGFloat height = self.bounds.size.height * 0.5;
    
    CGRect rect = activityView_.frame;
    rect.origin = CGPointMake((self.bounds.size.width - rect.size.width) * 0.5, height - rect.size.height);
    activityView_.frame = rect;
    
    rect = CGRectMake(0.0, height, self.bounds.size.width, 24.0);
    infoLabel_.frame = rect;
}

- (SDWebImageScaleOptions)cacheImageType {
    return SDWebImageScaleThumbnail;
}

- (UIImage *)defaultThumbnail {
    return [UIImage imageNamed:@"default_cell_thumbnail_bg.png"];
}

+(CGSize)thumbnailDefaultSize {
    CGSize size = CGSizeMake(100.0, 100.0);
    return size;
}

+ (CGSize)thumbnailSizeWithImageDataSource:(id<KDImageDataSource>)imageDataSource {
    // make the image size use
    CGSize size = CGSizeMake(100.0, 100.0);
    
   // return size;
    
    if ([imageDataSource hasImageSource]) {
        UIImage *image = [[SDWebImageManager sharedManager] diskImageForURL:[NSURL URLWithString:[imageDataSource thumbnailImageURL]] options:SDWebImageScaleThumbnail];
        
        if (image != nil) {
            size = image.size;
            
            CGFloat aspectRatio = size.height / size.width;
            if(size.height > size.width) {
                size.height = 100;
                size.width = size.height / aspectRatio;
            }else {
                size.width = 100;
                size.height = size.width * aspectRatio;
            }
            
        }
    }
    
    return size;
}

+ (CGSize)defaultMinimalThumbnailSize {
    return CGSizeMake(30.0, 30.0);
}

- (BOOL)hasVideo
{
    return [status_ hasVideo];
}

- (void)updateThumbnail:(UIImage *)thumbnail {
    if (thumbnail != nil) {
        hasThumbnail_ = YES;
        
        thumbnailView_.image = thumbnail;
    }else {
        thumbnailView_.image  = [self defaultThumbnail];
    }
}

- (void)_loadThumbnail:(BOOL)fromNetwork {
    
    [self updateThumbnail:nil];
    
    NSString *urlString = [imageDataSource_ thumbnailImageURL];
    NSURL *imgUrl = [NSURL URLWithString:[imageDataSource_ thumbnailImageURL]];
    if (imgUrl == nil && [urlString length] >0) {
        imgUrl = [NSURL fileURLWithPath:urlString];
    }
    
    self.loadOperation =
    [[SDWebImageManager sharedManager] downloadWithURL:imgUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:[self cacheImageType] progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {

        if ([imgUrl isEqual:url]) {
            [self updateThumbnail:image];
        }
    }];
}

- (void)loadThumbnailFromNetwork {
    [self _loadThumbnail:YES];
}

- (void)loadThumbnailFromDisk {
    [self _loadThumbnail:NO];
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
        [self loadThumbnailFromDisk];
        
    }else {
        // clear the image
        thumbnailView_.image = nil;
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
            [self loadThumbnailFromNetwork];
        }
    }
}

- (BOOL)loadThumbnail {
    return loadThumbnail_;
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageDataSource methods

- (id<KDImageDataSource>)getImageDataSource {
    return imageDataSource_;
}

- (UIImage *)defaultPlaceholderImage {
    return nil;
}

- (KDImageSize *)optimalImageSize {

    //return [thumbnailSize_ adjustedSize];
    return [KDImageSize defaultThumbnailImageSize];
}


- (void)dealloc {
    delegate_ = nil;
    
    [_loadOperation cancel];
    
    //KD_RELEASE_SAFELY(_loadOperation);
    //KD_RELEASE_SAFELY(imageDataSource_);
    //KD_RELEASE_SAFELY(thumbnailSize_);
    //KD_RELEASE_SAFELY(thumbnailView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(status_);
    //KD_RELEASE_SAFELY(_sizeLabel);
    //KD_RELEASE_SAFELY(playImage_);
    
    //[super dealloc];
}

@end
