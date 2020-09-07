//
//  KDGifView.m
//  kdweibo
//
//  Created by bird on 13-9-2.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#import "KDGifView.h"
#import "KDWeiboServicesContext.h"
#import "KDImageLoaderAdapter.h"
#import "NSData+GIF.h"
#import "SDWebImageManager.h"

@interface KDGifView() <UIWebViewDelegate>
@property (nonatomic, retain) KDProgressIndicatorView *progressView;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) id<SDWebImageOperation> operation;
@end

@implementation KDGifView
@dynamic imageSource;
@synthesize control = control_;
@synthesize progressView = progressView_;
@synthesize demoDelegate = demoDelegate_;
@synthesize data = data_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isReload_ = NO;
        downloading_ = NO;
        downloadsFinishedPercent_ = 0.0;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        [self setOpaque:NO];
        self.delegate = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scalesPageToFit = YES;
        self.scrollView.scrollEnabled = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        
        control_ = [[UIControl alloc] initWithFrame:self.bounds];
        [self addSubview:control_];
//        [control_ release];
        
    }
    return self;
}
- (void)dealloc
{
    if(downloading_) {
        // For network bandwidth issue, if current downloads progress more then 0.7
        // the downloads will not be cancelled. otherwise, the downloads will be cancelled.
        BOOL cancel = (downloadsFinishedPercent_ < 0.7) ? YES : NO;
        
        if (cancel) {
            
            if (_operation) {
                [_operation cancel];
            }
        }
    }
    self.operation = nil;
    //KD_RELEASE_SAFELY(data_);
    //KD_RELEASE_SAFELY(progressView_);
    //KD_RELEASE_SAFELY(imageSource_);
    //[super dealloc];
}
- (void) layoutSubviews {
    [super layoutSubviews];
    
    if(progressView_ != nil){
        progressView_.frame = [self frameForProgressView];
    }
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
            //KD_RELEASE_SAFELY(progressView_);
        }
    }
}
- (void)setImageSource:(id<KDImageDataSource>)imageSource {
    if (imageSource_ != imageSource) {
//        [imageSource_ release];
        imageSource_ = imageSource;// retain];
        
        [self update];
    }
}
- (void)update {
    
    BOOL isGif = [[imageSource_ getTimeLineImageSourceAtIndex:0] isGifImage];
    if (isGif)
    {

        [self loadDataFromNetwork];
    }

}
- (void)loadDataFromNetwork
{
    NSString *url = [[self getImageDataSource] bigImageURL];
    
    downloading_ = YES;
    [self setProgressViewWithVisible:YES];
    
    
    KDGifView *gifView = self;// retain];
    
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    self.operation =
    [imageManager downloadWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderProgressiveDownload imageScale:SDWebImageScaleNone progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        downloadsFinishedPercent_ = receivedSize/(float)expectedSize;
        
        NSString *info = nil;
        if(downloadsFinishedPercent_ + 0.001 > 1.0) {
            info = NSLocalizedString(@"OPTIMIZING...", @"");
            
        }else {
            info = [NSString stringWithFormat:NSLocalizedString(@"LOAD_PROGESS_%@_%@", @""), [NSString stringWithFormat:@"%0.0f%%", downloadsFinishedPercent_ * 100], [NSString formatContentLengthWithBytes:receivedSize]];

        }
        
        [progressView_ setProgressPercent:downloadsFinishedPercent_ info:info];
    } completedWithNSData:^(UIImage *image, NSData *data, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
        downloading_ = NO;
        isReload_ = NO;
        [self setProgressViewWithVisible:NO];
        
        if(finished)
            [self loadImageData:data];
        
//        [gifView release];
    }];

    
}
- (void)loadImageData:(NSData *)data
{
    if (!data)  return;
    self.data = data;
    
    
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    [self setDelegate:nil];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [super setDelegate:self];
    if ([data isGIF])
        [self loadData:data MIMEType:@"image/gif" textEncodingName:NULL baseURL:NULL];
    else
        [self loadData:data MIMEType:@"image/jpeg" textEncodingName:NULL baseURL:NULL];

    
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!isReload_) {
        isReload_  = YES;
        
        NSString *height = [webView stringByEvaluatingJavaScriptFromString:@"document.images[0].height"];
        NSString *width  = [webView stringByEvaluatingJavaScriptFromString:@"document.images[0].width"];
        
        float iWidth = [width floatValue];
        float iHeight = [height floatValue];
        float bHeight = 180.0f;
        float bWidth  = CGRectGetWidth(webView.frame);
        
        float hFactor = bHeight/iHeight;
        float wFactor = bWidth/iWidth;
        
        if (hFactor>1.0 && wFactor>1.0) {
            hFactor = 1.0;
            wFactor =1.0;
        }
        float factor = MIN(hFactor, wFactor);
        iWidth = iWidth *factor;
        iHeight = iHeight *factor;
        
        CGRect frame =  webView.frame;
        frame.size.height = iHeight;
        
        self.frame = frame;
        control_.frame = self.bounds;
        if (demoDelegate_ && [demoDelegate_ respondsToSelector:@selector(gifViewLayOut)]) {
            [demoDelegate_ gifViewLayOut];
        }
        
        [self loadImageData:self.data];
    }
    else {
        
        [webView stringByEvaluatingJavaScriptFromString:@"var images = document.images;"
         "var image = images[0];"
         "var bHeight= window.innerHeight;"
         "var bWidth = window.innerWidth;"
         "var width = image.width;"
         "var height  = image.height;"
         "var wFactor = bHeight/height;"
         "var hFactor = bWidth/width;"
         "if(wFactor>1.0 && hFactor>1.0)"
         "{"
         "wFactor=1.0;hFactor=1.0;"
         "}"
         "var factor = Math.min(wFactor,hFactor);"
         "height = factor*height;"
         "width  = factor*width;"
         "image.style.width=width+'px';"
         "image.style.height=height+'px';"
         "image.style.marginLeft=(window.innerWidth-width)/2+'px';"
         "image.style.marginTop=0+'px';"
         ];
        
        if (downloading_)
            [self loadDataFromNetwork];
    }
}
@end
