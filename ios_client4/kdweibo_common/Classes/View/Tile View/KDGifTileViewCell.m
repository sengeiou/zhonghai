//
//  KDGifTileViewCell.m
//  kdweibo_common
//
//  Created by bird on 13-8-27.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDGifTileViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface KDGifTileViewCell() <UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, retain) DACircularProgressView *progressView;
@property (nonatomic, retain) UIWebView               *webView;
@property (nonatomic, retain) NSData *                 thumbGifData;
@property (nonatomic, retain) NSString * jsIntervalID;
@end
@implementation KDGifTileViewCell
@synthesize progressView = progressView_;
@synthesize webView = webView_;
@synthesize showProgress = showProgress_;
@synthesize delegate=delegate_;
@synthesize imageType=imageType_;
@synthesize userInfo=userInfo_;
@synthesize thumbGifData = thumbGifData_;
@synthesize jsIntervalID = jsIntervalID_;

- (id)initWithIdentifier:(NSString *)identifier {
    if(self = [super initWithIdentifier:identifier]) {
		showProgress_ = NO;
        imageType_ = KDGifViewCellImageTypeDefault;
    }
    return self;
}
- (void)dealloc
{
    if (webView_) {
        [webView_ loadHTMLString:@"" baseURL:nil];
        [webView_ stopLoading];
        [webView_ setDelegate:nil];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [webView_ removeFromSuperview];
//        [webView_ release];
        webView_ = nil;
    }
	
    //KD_RELEASE_SAFELY(jsIntervalID_);
    //KD_RELEASE_SAFELY(thumbGifData_);
    //KD_RELEASE_SAFELY(progressView_);
    //KD_RELEASE_SAFELY(userInfo_);
    //[super dealloc];
}

// Override
- (void)prepareForReuse {
	imageType_ = KDGifViewCellImageTypeDefault;
    
    if (webView_) {
        [webView_ loadHTMLString:@"" baseURL:nil];
        [webView_ stopLoading];
        [webView_ setDelegate:nil];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [webView_ removeFromSuperview];
//        [webView_ release];
        webView_ = nil;
    }
    self.jsIntervalID = nil;
	if (thumbGifData_)
        //KD_RELEASE_SAFELY(thumbGifData_);
	[self setProgressViewWithVisible:NO];
}

// Override
- (void)shouldCacheCell {
    imageType_ = KDGifViewCellImageTypeThumbnail;
    if (webView_) {
        [webView_ loadData:thumbGifData_ MIMEType:@"image/gif" textEncodingName:NULL baseURL:NULL];
    }
    self.jsIntervalID = nil;
	[self setProgressViewWithVisible:NO];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if(progressView_ != nil){
        progressView_.frame = [self frameForProgressView];
    }
	webView_.frame = CGRectMake(0.0, 0.0, super.contentView.bounds.size.width, super.contentView.bounds.size.height);
}
- (CGRect)frameForProgressView {
    return CGRectMake(140.0f, (self.bounds.size.height - 40)/2.0, 40.0f, 40.0f);
}

- (void)setProgressViewWithVisible:(BOOL)visible {
    if (visible) {
        if(progressView_ == nil) {
            progressView_ = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
            [self addSubview:progressView_];
            [progressView_ setProgress:0.01];
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
- (void)didDisplayGifImage {
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didDisplayGifImageInGifTileViewCell:)]){
        [delegate_ didDisplayGifImageInGifTileViewCell:self];
    }
}
- (void)loadImageData:(NSData *)data imageType:(KDGifViewCellImageType)imageType {
	imageType_ = imageType;
    if (!webView_) {
        webView_ = [[UIWebView alloc] initWithFrame:CGRectZero];
        webView_.backgroundColor = [UIColor clearColor];
        webView_.dataDetectorTypes = UIDataDetectorTypeNone;
        [webView_ setOpaque:NO];
        webView_.delegate = self;
        webView_.scrollView.backgroundColor = [UIColor clearColor];
        webView_.scrollView.showsVerticalScrollIndicator = NO;
        webView_.scrollView.showsHorizontalScrollIndicator = NO;
        [super.contentView addSubview:webView_];
        
        // single tap gesture
        UITapGestureRecognizer *tapGestireRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnScrollView:)];
        tapGestireRecognizer.delegate = self;
        tapGestireRecognizer.numberOfTapsRequired = 1;
        [webView_ addGestureRecognizer:tapGestireRecognizer];
//        [tapGestireRecognizer release];
    }
    webView_.scalesPageToFit = imageType==KDGifViewCellImageTypePreview;
    webView_.scrollView.scrollEnabled = imageType==KDGifViewCellImageTypePreview;
    
    [webView_ loadData:data MIMEType:@"image/gif" textEncodingName:NULL baseURL:NULL];
	
	if(KDGifViewCellImageTypeDefault == imageType_ || KDGifViewCellImageTypeThumbnail == imageType_){
        self.thumbGifData = data;
		if(showProgress_){
			[self setProgressViewWithVisible:YES];
		}
		
	}else {
        if(KDGifViewCellImageTypePreview == imageType){
            [self didDisplayGifImage];
        }
        
		[self setProgressViewWithVisible:NO];
	}
	
	[self setNeedsLayout];
}
- (void)handleTapGesture:(NSValue *)value {
	if(tapCount_ == 1){
        // single tap
        if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didTapInGifTileViewCell:)]){
            [delegate_ didTapInGifTileViewCell:self];
        }
        
    } else if(tapCount_ == 2) {
        // double tap
    }
    
    tapCount_ = 0;
}
- (BOOL)isDisplayGifImage {
    return KDGifViewCellImageTypePreview == imageType_;
}
- (void)didTapOnScrollView:(UITapGestureRecognizer *)tapGestureRecognizer {
    tapCount_++;
    
    [self performSelector:@selector(handleTapGesture:) withObject:nil afterDelay:0.3];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (void)startGif
{
    if (imageType_ !=KDGifViewCellImageTypeBlurPreview) return;
    
    [webView_ stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.clearInterval(%@);",jsIntervalID_]];
    self.jsIntervalID = nil;
    imageType_ = KDGifViewCellImageTypePreview;
}
- (void)stopGif
{
    if (imageType_ != KDGifViewCellImageTypePreview) return;
    
    NSString *ID = [webView_ stringByEvaluatingJavaScriptFromString:@"var images = document.images;"
     "var image = images[0];"
     "setInterval(function() { image.src = image.src; }, 1);"];
    self.jsIntervalID = ID;
    imageType_ = KDGifViewCellImageTypeBlurPreview;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView_ stringByEvaluatingJavaScriptFromString:@"var images = document.images;"
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
     "image.style.marginLeft=(bWidth-width)/2+'px';"
     "image.style.marginTop=(bHeight-height)/2+'px';"
     ];
}
@end
