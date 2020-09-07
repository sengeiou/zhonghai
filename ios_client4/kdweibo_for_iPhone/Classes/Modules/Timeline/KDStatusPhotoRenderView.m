//
//  KDStatusPhotoRenderView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusPhotoRenderView.h"

#import "KDWeiboServicesContext.h"
#import "KDAttachment.h"
#import "NSData+GIF.h"


@interface KDStatusPhotoRenderView ()

@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) CALayer *playImageLayer;
@property (nonatomic, strong) UILabel *sizeLabel;

@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, strong) KDProgressIndicatorView *progressView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) id<SDWebImageOperation> loadOperation;

@end


@implementation KDStatusPhotoRenderView

@synthesize delegate = delegate_;
@synthesize imageSource = imageSource_;

@synthesize maskLayer = maskLayer_;

@synthesize progressView=progressView_;
@synthesize infoLabel=infoLabel;
@synthesize photoImageView = photoImageView_;

- (void) setupStatusPhotoRenderActionView {
    downloading_ = NO;
    downloadsFinishedPercent_ = 0.0;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    // mask layer
    maskLayer_ = [CALayer layer];
    maskLayer_.masksToBounds = YES;
    maskLayer_.contentsScale = scale;
    
    // photo content layer

    
    self.photoImageView = [[UIImageView alloc]init];
    photoImageView_.layer.contentsScale = scale;
    
    self.playImageLayer = [CALayer layer];
    _playImageLayer.contentsScale = scale;
    
    [photoLayer_ addSublayer:_playImageLayer];
    [photoImageView_.layer addSublayer:_playImageLayer];
    
    [maskLayer_ addSublayer:photoImageView_.layer];
    [self.layer insertSublayer:maskLayer_ atIndex:0x00];
    
}

+ (id) photoRenderView {
    KDStatusPhotoRenderView *renderActionView = [super buttonWithType:UIButtonTypeCustom];
    if(renderActionView != nil){
        [renderActionView setupStatusPhotoRenderActionView];
    }
    
    return renderActionView;
}

+ (id) photoRenderViewWithStatus:(KDStatus *)newStatus
{
    KDStatusPhotoRenderView *renderActionView = [super buttonWithType:UIButtonTypeCustom];
    if(renderActionView != nil){
        renderActionView.status = newStatus;
        [renderActionView setupStatusPhotoRenderActionView];
    }
    
    return renderActionView;
}

- (BOOL)hasVideo
{
    return [_status hasVideo];
}

- (CGRect) frameForProgressView {
    return CGRectMake(20.0, (self.bounds.size.height - 72.0) * 0.5, self.bounds.size.width-40, 72.0);
}

- (void) setProgressViewWithVisible:(BOOL)visible { 
    if (visible) {
        if(progressView_ == nil) {
            progressView_ = [[KDProgressIndicatorView alloc] initWithFrame:CGRectZero];
            [progressView_ setAvtivityIndicatorStartAnimation:YES];
            [progressView_ setProgressPercent:0.0 info:ASLocalizedString(@"RecommendViewController_Load")];
            
            [self addSubview:progressView_];
        }
        progressView_.frame = [self frameForProgressView]; 
        
    } else {
        if (progressView_ != nil) {
            if (progressView_.superview != nil) {
                [progressView_ removeFromSuperview];
            }
        }
    }
}

- (void)setupSizeLabel
{
    if ([_status hasVideo] && [_status.attachments count] > 0) {
        if (_sizeLabel == nil) {
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _sizeLabel.layer.cornerRadius = 10.f;
            _sizeLabel.layer.masksToBounds = YES;
            _sizeLabel.textAlignment = NSTextAlignmentCenter;
            _sizeLabel.textColor = [UIColor whiteColor];
            _sizeLabel.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.5];
            _sizeLabel.font = [UIFont boldSystemFontOfSize:12.f];
            [self addSubview:_sizeLabel];
        }
        _sizeLabel.hidden = NO;
        _sizeLabel.text = [self videoSize];
        _sizeLabel.frame = CGRectMake(photoImageView_.layer.frame.size.width + photoImageView_.layer.frame.origin.x - 53.f, photoImageView_.layer.frame.size.height - 38.f, 60.f, 20.f);
    }else {
        _sizeLabel.hidden = YES;
    }
}

- (NSString *)videoSize
{
    KDAttachment *temp = (KDAttachment *)[_status.attachments objectAtIndex:0];
    NSString *result = @"";
    if (temp.fileSize / 1024 >= 1024) {
        result = [NSString stringWithFormat:@"%.2fMB", (float)temp.fileSize / 1024.f / 1024.f];
    }else {
        result = [NSString stringWithFormat:@"%dKB", (int)temp.fileSize / 1024];
    }
    return result;
}

- (CGRect) frameForInfoLabel {
    CGFloat width = self.bounds.size.width - 40.0;
    return CGRectMake((self.bounds.size.width - width) * 0.5, (self.bounds.size.height - 30.0) * 0.5, width, 30.0);
}

- (void) setInfoLabelVisible:(BOOL)visible info:(NSString *)info {
    if(visible){
        if(infoLabel_ == nil) {
            infoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
            infoLabel_.backgroundColor = [UIColor clearColor];
            infoLabel_.textColor = [UIColor grayColor];
            infoLabel_.font = [UIFont systemFontOfSize:13.0];
            infoLabel_.textAlignment = NSTextAlignmentCenter;
            
            infoLabel_.userInteractionEnabled = NO;
            [self addSubview:infoLabel_];
        }
        
        infoLabel_.frame = [self frameForInfoLabel];
        infoLabel_.text = info;
        
    }else {
        if(infoLabel_ != nil){
            if(infoLabel_.superview != nil) {
                [infoLabel_ removeFromSuperview];
            }
        }
    }
}

- (CGRect) photoLayerFrame:(CGSize)size {
    return CGRectMake((maskLayer_.bounds.size.width - size.width) * 0.5,
                      (maskLayer_.bounds.size.height - size.height) * 0.5,
                      size.width, size.height);
}

- (void) layoutContentLayers {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGRect rect = CGRectInset(self.bounds, 0, 0);
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        self.frame = CGRectMake(0.0f, 0.0f, 280.f, 80.f);
        rect = CGRectInset(self.bounds, 0, 0);
    }
//    rect.size.height -= 12.0;
    maskLayer_.frame = rect;
    
    if(photoImageView_.layer.contents != nil) {
        CGImageRef imageRef = (__bridge CGImageRef)photoImageView_.layer.contents;
        CGSize size = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        if(photoImageView_.layer.contentsScale + 0.001 > 2.0){
            size.width *= 0.5;
            size.height *= 0.5;
        }
        
        photoImageView_.layer.frame = [self photoLayerFrame:size];

    }
    
    [CATransaction commit];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self layoutContentLayers];
    
    if(progressView_ != nil){
        progressView_.frame = [self frameForProgressView];
    }
    
    if(infoLabel_ != nil) {
        infoLabel_.frame = [self frameForInfoLabel];
    }
}

- (UIImage *) getBackgroungImage:(BOOL)manyImageSource {
//    if ([_status hasVideo]) {
//        return nil;
//    }else {
//        NSString *imageName = manyImageSource ? @"photoframes.png" : @"photoframe.png";
//        return [[KDCache sharedCache] bundleImageWithName:imageName leftCapAnchor:0.5 topCapAnchor:0.5 cache:YES];
//    }
    return nil;
}

- (void)updateWithStatusPhoto:(UIImage *)photo {
    if(photo == nil){
        photo = [self defaultPlaceholderImage];
    }
    
    if(photo != nil) {
        
        downloading_ = NO;
        [self setProgressViewWithVisible:NO];
        
        if(!photo){
            [self setInfoLabelVisible:YES info:NSLocalizedString(@"LOAD_IMAGE_SOURCE_DID_FAIL", @"")];
        }
        
        CGSize size = photo.size;
        
        if(photoImageView_.layer.contentsScale + 0.01 > 2.0) {
            size.width *= 0.5;
            size.height *= 0.5;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        photoImageView_.frame = [self photoLayerFrame:size];
        UIImage *photo1 = [photo fastCropToSize:size];
//              photoLayer_.frame = [self photoLayerFrame:size];
//                photoImageView_.frame = CGRectInset(photoImageView_.frame, 30, 30);
        [photoImageView_ setImage:photo1];
//        photoLayer_.contents = (id)photo.CGImage;
        
        if ([self hasVideo]) {
            CGImageRef playImageRef = [UIImage imageNamed:@"videoplay_s.png"].CGImage;
            [_playImageLayer setContents:(__bridge id)playImageRef];
            _playImageLayer.frame = CGRectMake((photoImageView_.frame.size.width - 40.0f) / 2., (photoImageView_.frame.size.height - 40.0f) / 2., 40.0f, 40.0f);
            [self setupSizeLabel];
        }
        
        [CATransaction commit];
        
        if(delegate_ && [delegate_ respondsToSelector:@selector(statusPhotoRenderView:didFinishLoadImage:)])
            [delegate_ statusPhotoRenderView:self didFinishLoadImage:photo];
    }
}

- (void)update {
    BOOL manyImageSource = [imageSource_ hasManyImageSource];
    UIImage *bgImage = [self getBackgroungImage:manyImageSource];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    NSString *url = [[self getImageDataSource] bigImageURL];
    
    NSURL *imgUrl = [NSURL URLWithString:url];
    downloading_ = YES;
    [self setProgressViewWithVisible:YES];
    
    __weak id weakSelf = self;
    self.loadOperation =
    [[SDWebImageManager sharedManager] downloadWithURL:imgUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:SDWebImageScaleMiddle progress:^(NSInteger receivedSize, NSInteger expectedSize){

        downloadsFinishedPercent_ =fabs((float)receivedSize/expectedSize);
        
        NSString *info = nil;
        if(downloadsFinishedPercent_ + 0.001 > 1.0) {
            info = NSLocalizedString(@"OPTIMIZING...", @"");
            
        }else {
            info = [NSString stringWithFormat:NSLocalizedString(@"LOAD_PROGESS_%@_%@", @""), [NSString stringWithFormat:@"%0.0f%%", downloadsFinishedPercent_ * 100], [NSString formatContentLengthWithBytes:receivedSize]];
        }
        
        [progressView_ setProgressPercent:downloadsFinishedPercent_ info:info];
        
    } completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
        
        if ([imgUrl isEqual:url]) {
            [weakSelf updateWithStatusPhoto:image];
        }
    }];
}

- (void)setImageSource:(id<KDImageDataSource>)imageSource {
    if (imageSource_ != imageSource) {
        imageSource_ = imageSource;
        [self update];
    }
}

- (id<KDImageDataSource>) imageSource {
     return imageSource_;
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageSourceLoader protocol methods

- (id<KDImageDataSource>) getImageDataSource {
    return imageSource_;
}

- (UIImage *) defaultPlaceholderImage {
    return nil;
}

- (KDImageSize *) optimalImageSize {
    return [KDImageSize defaultMiddleImageSize];
}

- (void) dealloc {
    if (_loadOperation)
        [_loadOperation cancel];
   
}

@end
