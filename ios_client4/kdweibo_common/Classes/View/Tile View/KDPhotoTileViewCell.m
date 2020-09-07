//
//  KDPhotoTileViewCell.h
//  kdweibo
//
//  Created by laijiandong on 12-5-27.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import <objc/runtime.h>
#import "KDCommon.h"
#import "KDPhotoTileViewCell.h"

@implementation KDPhotoTileViewCell

@synthesize delegate=delegate_;

@synthesize userInfo=userInfo_;
@synthesize imageType=imageType_;
@synthesize showProgress=showProgress_;

- (id)initWithIdentifier:(NSString *)identifier {
    if(self = [super initWithIdentifier:identifier]) {
		self.clipsToBounds = YES;
		
		delegate_ = nil;
		
		imageType_ = KDTileViewCellImageTypeDefault;
		userInfo_ = nil;
		showProgress_ = NO;
	}
	
    return self;
}

- (void)displayImage:(UIImage *)image imageType:(KDTileViewCellImageType)imageType {
	
}

- (void)dealloc {
    delegate_ = nil;
	//KD_RELEASE_SAFELY(userInfo_);
	
    //[super dealloc];
}


@end


#pragma mark -
#pragma mark KDPhotoPreviewTileViewCell class


#define KD_IMAGE_MAX_ZOOM_FACTOR	3.0


@interface KDPhotoPreviewTileViewCell ()

@property(nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) DACircularProgressView *progressView;

@end


@implementation KDPhotoPreviewTileViewCell

@synthesize scrollView=scrollView_;
@synthesize imageView=imageView_;
@synthesize progressView=progressView_;

- (id)initWithIdentifier:(NSString *)identifier {
    if(self = [super initWithIdentifier:identifier]) {
		showProgress_ = NO;
        
        scrollView_ = [[UIScrollView alloc] initWithFrame:CGRectZero];
        
		scrollView_.backgroundColor = [UIColor blackColor];
		scrollView_.delegate = self;
		
		scrollView_.scrollEnabled = YES;
		scrollView_.showsVerticalScrollIndicator = NO;
		scrollView_.showsHorizontalScrollIndicator = NO;
		
		[super.contentView addSubview:scrollView_];
		
        // image view
        
        // single tap gesture
        UITapGestureRecognizer *tapGestireRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnScrollView:)];
        tapGestireRecognizer.numberOfTapsRequired = 1;
        [scrollView_ addGestureRecognizer:tapGestireRecognizer];
//        [tapGestireRecognizer release];
    }
	
    return self;
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

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if(progressView_ != nil){
        progressView_.frame = [self frameForProgressView];
    }
	
	scrollView_.frame = CGRectMake(0.0, 0.0, super.contentView.bounds.size.width, super.contentView.bounds.size.height);
	[self adjustScalesForZoomingStageView];
}

- (void)adjustScalesForZoomingStageView {
    if(imageView_.image != nil){
		CGSize size = imageView_.image.size;
		CGFloat width, height;
		CGFloat minZoom, maxZoom;
		CGFloat zoomFactor = 1.0;
		
        CGSize stageSize = scrollView_.bounds.size;
        
        CGFloat wFactor = stageSize.width / size.width;
        CGFloat hFactor = stageSize.height / size.height;
        
        
        NSInteger mask = 0x00;
        if (wFactor < 1.0 || hFactor < 1.0) {
            mask |= 0xf0;
            
        }
        else {
            mask |= 0x0f;
        }
        
        if(0xf0 == mask) { // use the width as
            zoomFactor = minZoom = MIN(wFactor, hFactor);
            maxZoom = MAX(minZoom * KD_IMAGE_MAX_ZOOM_FACTOR, KD_IMAGE_MAX_ZOOM_FACTOR);
            
            width = zoomFactor*size.width;
            height = zoomFactor * size.height;
            
        } else {
            zoomFactor = MIN(wFactor, hFactor);
            minZoom = 1;
            maxZoom = zoomFactor;
            
            height = zoomFactor*size.height;
            width = zoomFactor * size.width;
        }
        
		// we just allow the clear preview image to zoom
		scrollView_.minimumZoomScale = minZoom;
		scrollView_.maximumZoomScale = (KDTileViewCellImageTypePreview == imageType_ || KDTileViewCellImageTypeThumbnail == imageType_) ? maxZoom : minZoom;
		scrollView_.zoomScale = zoomFactor;
		
		imageView_.frame = CGRectMake(0.0, 0.0, width, height);
		scrollView_.contentSize = CGSizeMake(width, height);
		
        size = scrollView_.bounds.size;
		CGFloat pX = (width < size.width) ? (size.width-width) / 2.0 : 0.0;
		CGFloat pY = (height < size.height) ? (size.height-height) / 2.0 : 0.0;
		scrollView_.contentOffset = CGPointMake(0.0 - pX, 0.0 - pY);
		
		scrollView_.contentInset = UIEdgeInsetsMake(pY, pX, pY, pX);
	}
}

- (void)willDisplayRealImage {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(displayRealImageInPhotoTileViewCell:)]){
        [self.delegate displayRealImageInPhotoTileViewCell:self];
    }
}

- (void)displayImage:(UIImage *)image imageType:(KDTileViewCellImageType)imageType {
	imageType_ = imageType;
	
	[imageView_ removeFromSuperview];
//	[imageView_ release];
	imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    
	imageView_.image = image;
	[scrollView_ addSubview:imageView_];
	
	if(KDTileViewCellImageTypeDefault == imageType_ || KDTileViewCellImageTypeThumbnail == imageType_ ){
		if(showProgress_){
			[self setProgressViewWithVisible:YES];
		}
		
	}else {
        if(KDTileViewCellImageTypePreview == imageType){
            [self willDisplayRealImage];
        }
        
		[self setProgressViewWithVisible:NO];
	}
	
	[self setNeedsLayout];
}

- (void)displayWithClearImage:(UIImage *)image imageType:(KDTileViewCellImageType)imageType {
	[self setProgressViewWithVisible:NO];
	
	imageType_ = imageType;
	
    if(KDTileViewCellImageTypePreview == imageType_){
        [self willDisplayRealImage];
    }
    
	[imageView_ removeFromSuperview];
//	[imageView_ release];
	imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    
	imageView_.image = image;
	[scrollView_ addSubview:imageView_];
	
	[self setNeedsLayout];
}

- (BOOL)isDisplayRealImage {
    return KDTileViewCellImageTypePreview == imageType_;
}

- (UIImage *)previewImage {
	return (KDTileViewCellImageTypePreview == imageType_) ? imageView_.image : nil;
}

- (BOOL)canScrollImage {
	BOOL scrollEnable = NO;
	if((imageType_ == KDTileViewCellImageTypePreview || imageType_ == KDTileViewCellImageTypeThumbnail) && imageView_.image != nil && scrollView_.zoomScale > scrollView_.minimumZoomScale){
		CGSize size = scrollView_.contentSize;
		
		if(size.width > scrollView_.bounds.size.width || size.height > scrollView_.bounds.size.height){
			scrollEnable = YES;
		}
	}
	
	return scrollEnable;
}

- (void)handleTapGesture:(NSValue *)value {
	if(tapCount_ == 1){
        // single tap
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didTapInPhotoTileViewCell:)]){
            [self.delegate didTapInPhotoTileViewCell:self];
        }
        
    } else if(tapCount_ == 2) {
        // double tap
        if(KDTileViewCellImageTypePreview == imageType_ ||KDTileViewCellImageTypeThumbnail == imageType_){
            // Zoom
            CGPoint touchPoint = [value CGPointValue];
            if (scrollView_.zoomScale + 0.01 > scrollView_.maximumZoomScale) {
                // For some reason, If the clicked point in first quadrant of scroll view.
                // The the image view may position at top, I don't have a clear idea now.
                // So if the point in first quadrant, It's will call adjust frames when did finished zoom
                
                touchPoint = [scrollView_ convertPoint:touchPoint fromView:imageView_];
                CGRect rect = CGRectMake(0.0, 0.0, scrollView_.bounds.size.width * 0.5, scrollView_.bounds.size.height * 0.5);
                if(CGRectContainsPoint(rect, touchPoint)){
                    [UIView animateWithDuration:0.3
                                     animations:^{
                                         [self adjustScalesForZoomingStageView];
                                     }];
                }else {
                    [scrollView_ setZoomScale:scrollView_.minimumZoomScale animated:YES];
                }
                
            } else {
                [scrollView_ zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
            }
        }
    }
    
    tapCount_ = 0;
}

- (void)didTapOnScrollView:(UITapGestureRecognizer *)tapGestureRecognizer {
    tapCount_++;
    
    CGPoint touchPoint = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
    touchPoint = [imageView_ convertPoint:touchPoint fromView:scrollView_];
    
    [self performSelector:@selector(handleTapGesture:) withObject:[NSValue valueWithCGPoint:touchPoint] afterDelay:0.3];
}


// Override
- (void)prepareForReuse {
	imageType_ = KDTileViewCellImageTypeDefault;
	
	[imageView_ removeFromSuperview];
//	[imageView_ release];
	imageView_ = nil;
	
	[self setProgressViewWithVisible:NO];
	
	scrollView_.contentSize = CGSizeZero;
	scrollView_.contentOffset = CGPointZero;
	scrollView_.contentInset = UIEdgeInsetsZero;
}

// Override
- (void)shouldCacheCell {
	scrollView_.scrollEnabled = YES;
	
	if((KDTileViewCellImageTypePreview == imageType_ || KDTileViewCellImageTypeThumbnail == imageType_) && (scrollView_.zoomScale < scrollView_.minimumZoomScale-0.01
														|| scrollView_.zoomScale > scrollView_.minimumZoomScale+0.01)){
		scrollView_.zoomScale = scrollView_.minimumZoomScale;
		
		[self setNeedsLayout];
	}
}

#pragma mark -
#pragma mark UIScrollView delegate mehtods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat pX = 0.0;
    if(scrollView.contentSize.width < scrollView.frame.size.width){
        pX = (scrollView.frame.size.width-scrollView.contentSize.width)/2.0;
    }
    
    CGFloat pY = 0.0;
    if(scrollView.contentSize.height < scrollView.frame.size.height){
        pY = (scrollView.frame.size.height-scrollView.contentSize.height)/2.0;
    }
    scrollView_.contentInset = UIEdgeInsetsMake(pY, pX, pY, pX);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	scrollView_.scrollEnabled = [self canScrollImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView_;
}

- (void)dealloc {
	//KD_RELEASE_SAFELY(progressView_);
    //KD_RELEASE_SAFELY(imageView_);
	//KD_RELEASE_SAFELY(scrollView_);
	
	//[super dealloc];
}


@end
