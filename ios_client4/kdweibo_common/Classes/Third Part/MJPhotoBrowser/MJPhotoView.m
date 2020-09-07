#import "MJPhotoView.h"
#import "MJPhoto.h"
#import "MJPhotoLoadingView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface MJPhotoView ()<UIActionSheetDelegate>
{
    BOOL _isZoomed;
    UIImageView *_imageView;
    MJPhotoLoadingView *_photoLoadingView;
    
    NSTimer *_tapTimer;
    UIButton *_originalPicBtn;
}
@property (nonatomic, strong) id<SDWebImageOperation> operation;
@end

@implementation MJPhotoView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        // 图片
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
        
        // 进度条
        _photoLoadingView = [[MJPhotoLoadingView alloc] init];
        
        _originalPicBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height - 40, 100, 30)];
        _originalPicBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _originalPicBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _originalPicBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _originalPicBtn.layer.borderWidth = 0.5;
        _originalPicBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _originalPicBtn.layer.cornerRadius = 3;
        _originalPicBtn.layer.masksToBounds = YES;
        [_originalPicBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _originalPicBtn.hidden = YES;
        [_originalPicBtn addTarget:self action:@selector(showOriginalPic:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_originalPicBtn];
        
        // 属性
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}

#pragma mark - photoSetter
- (void)setPhoto:(MJPhoto *)photo {
    
    if (photo != nil) {
        
        _photo = photo;
        [_originalPicBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@" 查看原图(%@)  "),_photo.photoLength] forState:UIControlStateNormal];
        [_originalPicBtn sizeToFit];

        
        if (_mode == MJPhotoViewModeOriginal) {
            self.backgroundColor = [UIColor blackColor];
        }
        [self showImage];
    }
    
}

#pragma mark 显示图片
//- (void)showImage
//{
//    if (_photo.firstShow) { // 首次显示
//        if (_photo.isOriginPic) {
//            _originalPicBtn.hidden = NO;
//        }
//        else
//        {
//            _originalPicBtn.hidden = YES;
//        }
//        _imageView.image = _photo.placeholder; // 占位图片
////        _photo.srcImageView.image = nil;
//
//        NSURL   *imageUrl = nil;
//        UIImage *placeholderImage = nil;
//        SDWebImageScaleOptions option = SDWebImageScaleNone;
//
//        if (_mode == MJPhotoViewModeOriginal) {
//            imageUrl = _photo.originUrl;
//            if (imageUrl == nil)
//                imageUrl = _photo.url;
//
//            placeholderImage = _photo.placeholder;
//            option = SDWebImageScaleNone;
//        }
//        else
//        {
//            imageUrl = _photo.url;
//            placeholderImage = _photo.srcImageView.image;
//            if (placeholderImage == nil)
//                placeholderImage = _photo.placeholder;
//            if (placeholderImage == nil)
//                placeholderImage = [UIImage imageNamed:@"default_image_plachloder.png"];
//            option = SDWebImageScalePreView;
//        }
//
//        _imageView.image = placeholderImage;
//
//        // 不是gif，就马上开始下载
//        if (!_photo.isGif) {
//            __strong MJPhotoView *photoView = self;
////            __unsafe_unretained MJPhoto *photo = _photo;
//
//            self.operation = [[SDWebImageManager sharedManager] downloadWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:option progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
//
////                photoView.photo.image = image;
////
////                // 调整frame参数
////                [photoView adjustFrame];
//
//                if ([_photo.url isEqual:url] || [url isEqual:_photo.originUrl]) {
//                    [photoView photoDidFinishLoadWithImage:image];
//                }
//            }];
//        }
//    } else {
//        [self photoStartLoad];
//    }
//
//    // 调整frame参数
//    [self adjustFrame];
//}
- (void)showImage
{
    if (_photo.firstShow) { // 首次显示
        if ([_photo.isOriginalPic isEqualToString:@"1"] && _photo.direction == 0) {
            _originalPicBtn.hidden = NO;
        }
        else
        {
            _originalPicBtn.hidden = YES;
        }
        _imageView.image = _photo.placeholder; // 占位图片
        //        _photo.srcImageView.image = nil;
        
        NSURL   *imageUrl = nil;
        UIImage *placeholderImage = nil;
        SDWebImageScaleOptions option = SDWebImageScaleNone;
        
        if (_mode == MJPhotoViewModeOriginal) {
            imageUrl = _photo.originUrl;
            if (imageUrl == nil)
                imageUrl = _photo.originUrl;
            
            placeholderImage = _photo.placeholder;
            option = SDWebImageScaleNone;
        }
        else if ([_photo.isOriginalPic isEqualToString:@"1"] && _photo.direction == 0) {
            imageUrl = _photo.midPictureUrl;
            if (imageUrl == nil)
                imageUrl = _photo.midPictureUrl;
            
            placeholderImage = _photo.placeholder;
            option = SDWebImageScaleNone;
        }
        else
        {
            //为了标记里面的照片显示 add by lee 0901
            if ([_photo.url absoluteString].length <=0 && [_photo.originUrl absoluteString].length > 0 ) {
                imageUrl = _photo.originUrl;
            }else
            {
                imageUrl = _photo.url;

            }
            placeholderImage = _photo.srcImageView.image;
            if (placeholderImage == nil)
                placeholderImage = _photo.placeholder;
            if (placeholderImage == nil)
                placeholderImage = [UIImage imageNamed:@"default_image_plachloder.png"];
            option = SDWebImageScaleNone;
        }
        
        _imageView.image = placeholderImage;
        
        // 不是gif，就马上开始下载
        if (!_photo.isGif) {
            __strong MJPhotoView *photoView = self;
            //            __unsafe_unretained MJPhoto *photo = _photo;
            
            self.operation = [[SDWebImageManager sharedManager] downloadWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:option progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                
                //                photoView.photo.image = image;
                //
                //                // 调整frame参数
                //                [photoView adjustFrame];
                
                if ([_photo.thumbnailPictureUrl isEqual:url] || [url isEqual:_photo.originUrl]|| [url isEqual:_photo.midPictureUrl])
                {
                    [photoView photoDidFinishLoadWithImage:image];
                }
            }];
        }
    } else { 
        [self photoStartLoad];
    }
    
    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad
{
    if ([_photo.isOriginalPic isEqualToString:@"1"] && _photo.direction == 0) {
        _photo.image = [[SDWebImageManager sharedManager] diskImageForURL:_photo.originUrl];
        if (_photo.image) {
            self.scrollEnabled = YES;
            _originalPicBtn.hidden = YES;
            _imageView.image = _photo.image;
        } else {
            self.scrollEnabled = NO;
            _originalPicBtn.hidden = NO;
            // 直接显示进度条
            //            [_photoLoadingView showLoading];
            //            [self addSubview:_photoLoadingView];
            
            __strong MJPhotoView *photoView = self;
            __strong MJPhotoLoadingView *loading = _photoLoadingView;
            
            NSURL   *imageUrl = nil;
            UIImage *placeholderImage = nil;
            SDWebImageScaleOptions option = SDWebImageScaleNone;
            
            
            if (_mode == MJPhotoViewModeOriginal) {
                imageUrl = _photo.originUrl;
                if (imageUrl == nil)
                    imageUrl = _photo.url;
                
                placeholderImage = _photo.placeholder;
                option = SDWebImageScaleNone;
            }
            else
            {
                imageUrl = _photo.midPictureUrl;
                placeholderImage = _photo.srcImageView.image;
                if (placeholderImage == nil)
                {
#pragma mark modified by Darren in 2014.6.12
                    _photo.placeholder = [[SDWebImageManager sharedManager] diskImageForURL:_photo.midPictureUrl];
                    placeholderImage = _photo.placeholder;
                }
                if (placeholderImage == nil)
                    placeholderImage = [UIImage imageNamed:@"default_image_plachloder.png"];
                option = SDWebImageScaleNone;
            }
            
            
            _imageView.image = placeholderImage;
            
            self.operation = [[SDWebImageManager sharedManager] downloadWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:option progress:^(NSInteger receivedSize, NSInteger expectedSize){
                
                NSLog(@"####################%ld############",(long)expectedSize);
                //            if (expectedSize > 0 ) {
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicSize" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",expectedSize],@"size", nil]];
                //            }
                //
                if (receivedSize > kMinProgress && expectedSize > kMinProgress) {
                    loading.progress = (float)receivedSize/expectedSize;
                }
            } completed:^(UIImage *image, NSError *error, NSURL *url,SDImageCacheType cacheType, BOOL finished) {
                
                if ([_photo.url isEqual:url] || [url isEqual:_photo.originUrl]|| [url isEqual:_photo.midPictureUrl]) {
                    [photoView photoDidFinishLoadWithImage:image];
                }
                
            }];
        }
        
    }
    else
    {
        _originalPicBtn.hidden = YES;
        if (_photo.image) {
            self.scrollEnabled = YES;
            _imageView.image = _photo.image;
        } else {
            self.scrollEnabled = NO;
            // 直接显示进度条
            [_photoLoadingView showLoading];
            [self addSubview:_photoLoadingView];
            
            __strong MJPhotoView *photoView = self;
            __strong MJPhotoLoadingView *loading = _photoLoadingView;
            
            NSURL   *imageUrl = nil;
            UIImage *placeholderImage = nil;
            SDWebImageScaleOptions option = SDWebImageScaleNone;
            
            
            if (_mode == MJPhotoViewModeOriginal) {
                imageUrl = _photo.originUrl;
                if (imageUrl == nil)
                    imageUrl = _photo.url;
                
                placeholderImage = _photo.placeholder;
                option = SDWebImageScaleNone;
            }
            else
            {
                
                imageUrl = _photo.url;
                placeholderImage = _photo.srcImageView.image;
                if (placeholderImage == nil)
                {
#pragma mark modified by Darren in 2014.6.12
                    _photo.placeholder = [[SDWebImageManager sharedManager] diskImageForURL:_photo.thumbnailPictureUrl];
                    placeholderImage = _photo.placeholder;
                }
                if (placeholderImage == nil)
                    placeholderImage = [UIImage imageNamed:@"default_image_plachloder.png"];
                option = SDWebImageScaleNone;
            }
            
            if (_photo.isGif) {
                imageUrl = _photo.originUrl;
                option = SDWebImageScaleNone;
            }
            
            _imageView.image = placeholderImage;
            
            self.operation = [[SDWebImageManager sharedManager] downloadWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:option progress:^(NSInteger receivedSize, NSInteger expectedSize){
                NSLog(@"####################%ld############",(long)expectedSize);
                //            if (expectedSize > 0 ) {
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicSize" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",expectedSize],@"size", nil]];
                //            }
                //
                if (receivedSize > kMinProgress && expectedSize > kMinProgress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loading.progress = (float)receivedSize/expectedSize;
                    });
                }
            } completed:^(UIImage *image, NSError *error, NSURL *url,SDImageCacheType cacheType, BOOL finished) {
                
                if ([_photo.url isEqual:url] || [url isEqual:_photo.originUrl]) {
                    [photoView photoDidFinishLoadWithImage:image];
                }
                
            }];
        }
    }
    
    
    
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        _imageView.image = image;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
        _originalPicBtn.hidden = YES;
    }
    
    // 设置缩放比例
    [self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame
{
    if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1) {
        minScale = 1.0;
    }
    
    //gordon_wu 修改内存泄露 2014.08.04
    //	CGFloat maxScale = 2.0;
    //	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
    //		maxScale = maxScale / [[UIScreen mainScreen] scale];
    //	}
    self.maximumZoomScale = 3;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    
    if (_photo.firstShow) { // 第一次显示的图片
        _photo.firstShow = NO; // 已经显示过了
        
        if (_photo.srcImageView) {
            
            _imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
            
            [UIView animateWithDuration:0.3 animations:^{
                _imageView.frame = imageFrame;
            } completion:^(BOOL finished) {
                // 设置底部的小图片
                //            _photo.srcImageView.image = _photo.placeholder;
                [self photoStartLoad];
            }];
        }
        else
        {
            _imageView.frame = imageFrame;
            [self photoStartLoad];
        }
        
        
    } else {
        _imageView.frame = imageFrame;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.scrollEnabled)
        return _imageView;
    return nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //gordon_wu 修改，内存泄露 2014.08.04
    //	CGFloat pX = 0.0;
    //    if(scrollView.contentSize.width < scrollView.frame.size.width){
    //        pX = (scrollView.frame.size.width-scrollView.contentSize.width)/2.0;
    //    }
    
    CGFloat pY = 0.0;
    if(scrollView.contentSize.height < scrollView.frame.size.height){
        pY = (scrollView.frame.size.height-scrollView.contentSize.height)/2.0;
    }
    
    //    scrollView.contentInset = UIEdgeInsetsMake(pY, pX, pY, pX);
    
    CGRect frame = _imageView.frame;
    frame.origin.y = pY;
    _imageView.frame = frame;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if( self.zoomScale == self.minimumZoomScale ) _isZoomed = NO;
    else _isZoomed = YES;
}
#pragma mark - 手势处理
- (void)hide
{
    if (_operation)
        [_operation cancel];
    self.operation = nil;
    
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    self.contentOffset = CGPointZero;
    
    // 清空底部的小图
    //    _photo.srcImageView.image = nil;
    
    if (_photo.srcImageView == nil) {
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
            [self.photoViewDelegate photoViewDidEndZoom:self];
        }
        return;
    }
    
    CGFloat duration = 0.15;
    if (_photo.srcImageView.clipsToBounds) {
        [self performSelector:@selector(reset)];
    }
    
    [UIView animateWithDuration:duration + 0.1 animations:^{
        _imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
        
        // gif图片仅显示第0张
        if (_imageView.image.images) {
            _imageView.image = _imageView.image.images[0];
        }
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
    } completion:^(BOOL finished) {
        // 设置底部的小图片
        //        _photo.srcImageView.image = _photo.placeholder;
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
            [self.photoViewDelegate photoViewDidEndZoom:self];
        }
    }];
}

- (void)reset
{
    //    _imageView.image = _photo.capture;
    _imageView.image = _photo.srcImageView.image;
    _imageView.contentMode = UIViewContentModeScaleToFill;
    
    [self resetZoom];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if (touch.tapCount == 2) {
        [self stopTapTimer];
        
        if( _isZoomed )
        {
            _isZoomed = NO;
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
        else {
            
            if (!self.scrollEnabled)
                return;
            
            _isZoomed = YES;
            
            // define a rect to zoom to.
            CGPoint touchCenter = [touch locationInView:self];
            CGSize zoomRectSize = CGSizeMake(self.frame.size.width / self.maximumZoomScale, self.frame.size.height / self.maximumZoomScale );
            CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
            
            // correct too far left
            if( zoomRect.origin.x < 0 )
                zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
            
            // correct too far up
            if( zoomRect.origin.y < 0 )
                zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
            
            // correct too far right
            if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
                zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
            
            // correct too far down
            if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
                zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
            
            // zoom to it.
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] == 1 ) {
        UITouch *touch = [[event allTouches] anyObject];
        if( touch.tapCount == 1 ) {
            
            if(_tapTimer ) [self stopTapTimer];
            [self startTapTimer];
        }
    }
}

- (void)startTapTimer
{
    _tapTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:.5] interval:.5 target:self selector:@selector(handleTap) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_tapTimer forMode:NSDefaultRunLoopMode];
    
}
- (void)stopTapTimer
{
    if([_tapTimer isValid])
        [_tapTimer invalidate];
    
    _tapTimer = nil;
}

- (void)handleTap
{
    // tell the controller
    [self hide];
}

- (void)resetZoom
{
    _isZoomed = NO;
    [self stopTapTimer];
    [self setZoomScale:self.minimumZoomScale animated:NO];
    //	[self zoomToRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height ) animated:NO];
    //	self.contentSize = CGSizeMake(self.frame.size.width * self.zoomScale, self.frame.size.height * self.zoomScale );
}

- (void)dealloc
{
    // 取消请求
    if (_operation)
        [_operation cancel];
    self.operation = nil;
    
    [self stopTapTimer];
}

- (void)prepareForReuse
{
    [self resetZoom];
    [_imageView setImage:nil];
    _photo = nil;
    [_photoLoadingView removeFromSuperview];
}
-(void)showOriginalPic:(id)sender
{
    //    [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:_photo.msgId];
    _originalPicBtn.hidden = YES;
    // 直接显示进度条
    [_photoLoadingView showLoading];
    [self addSubview:_photoLoadingView];
    SDWebImageScaleOptions option = SDWebImageScaleNone;
    __strong MJPhotoView *photoView = self;
    __strong MJPhotoLoadingView *loading = _photoLoadingView;
    self.operation = [[SDWebImageManager sharedManager] downloadWithURL:_photo.originUrl options:SDWebImageRetryFailed|SDWebImageLowPriority imageScale:option progress:^(NSInteger receivedSize, NSInteger expectedSize){
        if (receivedSize > kMinProgress && expectedSize > kMinProgress) {
            loading.progress = (float)receivedSize/expectedSize;
        }
    } completed:^(UIImage *image, NSError *error, NSURL *url,SDImageCacheType cacheType, BOOL finished) {
        
        if ([_photo.url isEqual:url] || [url isEqual:_photo.originUrl]) {
            [photoView photoDidFinishLoadWithImage:image];
        }
        
    }];
    
}

-(void)updatePicSize:(NSNotification *)notifiction
{
    //    NSDictionary *dic = (NSDictionary *)[notifiction valueForKey:@"object"];
    //    [_showOriginalPicBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"查看原图:(%@)"),[dic valueForKey:@"size"]] forState:UIControlStateNormal];
}

@end