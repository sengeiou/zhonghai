//
//  KDPhotoOriginView.m
//  kdweibo
//
//  Created by shen kuikui on 13-4-17.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPhotoOriginView.h"

@implementation KDPhotoOriginView

@synthesize imageSource = imageSource_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)dealloc
{
     [[[KDWeiboServicesContext defaultContext] getImageLoaderAdapter] removeImageSourceLoader:self cancelRequest:YES];
//    [imageSource_ release];
//    [scrollView_ release];
//    [imageView_ release];
//    [progressIndicatorView_ release];
    
    //[super dealloc];
}

- (void)setupView {
    scrollView_ = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView_.delegate = self;
    scrollView_.maximumZoomScale = 10.0f;
    scrollView_.minimumZoomScale = 0.05f;
    scrollView_.scrollEnabled = YES;
    
    doubleTaps_ = YES;
    isFit_ = YES;
    fitScale_ = 0.0f;
    
    [self addSubview:scrollView_];
    
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [scrollView_ addSubview:imageView_];
    
    self.backgroundColor = [UIColor blackColor];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInOriginView:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
//    [doubleTap release];
    
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInOriginView:)];
    gest.numberOfTapsRequired = 1;
    [gest requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:gest];
//    [gest release];
}

- (void)didTapInOriginView:(UITapGestureRecognizer *)rec {
    if(rec.numberOfTapsRequired == 2 && doubleTaps_) {
        CGPoint p = [rec locationInView:scrollView_];
        
        if(isFit_) {
            isFit_ = NO;
            [scrollView_ zoomToRect:CGRectMake(p.x, p.y, 1, 1) animated:YES];
        }else {
            isFit_ = YES;
            [scrollView_ setZoomScale:fitScale_ animated:YES];
        }
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(photoOriginView:didTapWithCount:)]) {
        [_delegate photoOriginView:self didTapWithCount:rec.numberOfTapsRequired];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setProgressViewWithVisible:(BOOL)visible {
    if (visible) {
        if(progressIndicatorView_ == nil) {
            progressIndicatorView_ = [[KDProgressIndicatorView alloc] initWithFrame:CGRectMake(20.0f, (self.bounds.size.height - 72.0f) * 0.5, self.bounds.size.width - 40.0f, 72.0f)];
            progressIndicatorView_.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            progressIndicatorView_.progressLabel.textColor = [UIColor whiteColor];
            [progressIndicatorView_ setAvtivityIndicatorStartAnimation:YES];
            [progressIndicatorView_ setProgressPercent:0.0 info:ASLocalizedString(@"RecommendViewController_Load")];
            
            [self addSubview:progressIndicatorView_];
        }
        
    } else {
        if (progressIndicatorView_ != nil) {
            if (progressIndicatorView_.superview != nil) {
                [progressIndicatorView_ removeFromSuperview];
            }
            
            //KD_RELEASE_SAFELY(progressIndicatorView_);
        }
    }
}

- (void)loadImageWithURL:(NSString *)url {
    KDImageLoaderAdapter *loadAdapter = [[KDWeiboServicesContext defaultContext] getImageLoaderAdapter];
    
    [self setProgressViewWithVisible:YES];
    
    UIImage *bigImage = [loadAdapter imageWithLoader:self forURL:url
                                           cacheType:KDCacheImageTypeOrigin fromNetwork:YES];
    
    [self updateIamgeView:bigImage];
}

- (void)updateIamgeView:(UIImage *)image {
    if(image) {
        [self setProgressViewWithVisible:NO];
    }
    doubleTaps_ = YES;
    imageView_.image = image;
    [imageView_ sizeToFit];
    
    float maxZoom = MAX(scrollView_.frame.size.width / image.size.width, scrollView_.frame.size.height / image.size.height);
    isFit_ =  maxZoom>1.0;
    if (maxZoom > 1.0)
    {
        doubleTaps_ = NO;
        imageView_.center = scrollView_.center;
    }
    
    
    fitScale_ = scrollView_.frame.size.height / image.size.height;
    
    scrollView_.maximumZoomScale = MAX(image.size.width / scrollView_.frame.size.width, image.size.height / scrollView_.frame.size.height);
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    scrollView_.zoomScale = scrollView_.maximumZoomScale;
    
    scrollView_.scrollEnabled = YES;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    CGSize boundsSize = self.bounds.size;
    
    CGFloat minScale = 0.25;
    
    CGFloat maxScale = 1.0;
    
    if (imageView_.bounds.size.width > 0.0 && imageView_.bounds.size.height > 0.0) {
        // calculate min/max zoomscale
        CGFloat xScale = boundsSize.width  / imageView_.bounds.size.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageView_.bounds.size.height;   // the scale needed to perfectly fit the image height-wise
        
        minScale = MIN(xScale, yScale);
        
        maxScale = MAX(1.0 / xScale, 1.0 / yScale);
        maxScale = MAX(maxScale, 1.0f);
    }
    
    scrollView_.maximumZoomScale = maxScale;
    scrollView_.minimumZoomScale = minScale;
}

- (void)freeImage {
    imageView_.image = nil;
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView_;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.contentSize.width < scrollView.frame.size.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5f : 0.0f;
    CGFloat offsetY = (scrollView.contentSize.height < scrollView.frame.size.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5f : 0.0f;
    imageView_.center = CGPointMake(scrollView.contentSize.width * 0.5f + offsetX, scrollView.contentSize.height * 0.5f + offsetY);
}

#pragma mark - KDImageSourceLoader methods

- (id<KDImageDataSource>)getImageDataSource {
    return imageSource_;
}

- (UIImage *)defaultPlaceholderImage {
    return [UIImage imageNamed:@"default_image_plachloder.png"];
}

- (KDImageSize *)optimalImageSize {
    return [KDImageSize imageSizeWithWidth:MAXFLOAT height:MAXFLOAT];
}

- (void)imageSourceLoaderDidFinishLoad:(UIImage *)image cacheKey:(NSString *)cacheKey succeed:(BOOL)succeed {
    if(succeed && image) {
        [self updateIamgeView:image];
    }
}

- (void)imageSourceLoaderWithCacheKey:(NSString *)cacheKey progressMonitor:(KDRequestProgressMonitor *)progressMonitor {
    float percent = [progressMonitor finishedPercent];
    
    NSString *info = nil;
    if(percent + 0.001 > 1.0) {
        info = NSLocalizedString(@"OPTIMIZING...", @"");
        
    }else {
        info = [NSString stringWithFormat:NSLocalizedString(@"LOAD_PROGESS_%@_%@", @""), [progressMonitor finishedPercentAsString], [progressMonitor finishedBytesAsString]];
    }
    
    [progressIndicatorView_ setProgressPercent:percent info:info];
}


@end
