//
//  KWIFullPicVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIFullImgVCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "iToast.h"

#import "KWIRootVCtrl.h"

@interface KWIFullImgVCtrl () <UIScrollViewDelegate, SDWebImageManagerDelegate>

@property (retain, nonatomic) UIScrollView *scrollV;
@property (assign, nonatomic) UIView *container;

@property (retain, nonatomic) NSArray *imgs;
@property (retain, nonatomic) NSMutableDictionary *tag2imgV;
@property (retain, nonatomic) NSMutableDictionary *idx2imgV;

@end

@implementation KWIFullImgVCtrl
{
    NSUInteger _curTag;
    NSUInteger _curIdx;
    unsigned int _configThumbCountdown;
    UIImageView *_curThumbV;
    CGRect _srcRect;
    NSMutableDictionary *_url2imgInfWaiting4config;
    NSMutableDictionary *_url2thumbInfWaiting4config;
    NSMutableDictionary *_idx2thumbV;
    NSMutableDictionary *_idx2ingV;
    UIView *_toolbarV;
    UIPageControl *_pgctrl;
    UIButton *_saveToLocalBtn;
}

@synthesize scrollV = _scrollV;
@synthesize container = _container;
@synthesize imgs = _imgs;
@synthesize tag2imgV = _tag2imgV;
@synthesize idx2imgV = _idx2imgV;

+ (KWIFullImgVCtrl *)vctrlWithImgs:(NSArray *)imgs
{
    return [[[self alloc] initWithImgs:imgs] autorelease];
}

- (KWIFullImgVCtrl *)initWithImgs:(NSArray *)imgs
{
    self = [super init];
    if (self) {
        self.container = KWIRootVCtrl.curInst.view;
        CGSize containerSize = self.container.bounds.size;
        self.imgs = imgs;
        self.tag2imgV = [NSMutableDictionary dictionaryWithCapacity:imgs.count];
        self.idx2imgV = [NSMutableDictionary dictionaryWithCapacity:imgs.count];
        _url2imgInfWaiting4config = [[NSMutableDictionary dictionaryWithCapacity:imgs.count] retain];
        _url2thumbInfWaiting4config = [[NSMutableDictionary dictionaryWithCapacity:imgs.count] retain];
        _idx2thumbV = [[NSMutableDictionary dictionaryWithCapacity:imgs.count] retain];
        _idx2ingV = [[NSMutableDictionary dictionaryWithCapacity:imgs.count] retain];
        
        self.view = [[[UIView alloc] initWithFrame:self.container.bounds] autorelease];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.view.opaque = YES;
        self.view.backgroundColor = [UIColor blackColor];
        
        self.scrollV = [[[UIScrollView alloc] initWithFrame:self.container.bounds] autorelease];
        self.scrollV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.scrollV.delegate = self;
        self.scrollV.directionalLockEnabled = YES;
        self.scrollV.bounces = NO;
        self.scrollV.pagingEnabled = YES;
        self.scrollV.opaque = YES;
        self.scrollV.userInteractionEnabled = YES;
        CGSize contentSize = containerSize;
        contentSize.width *= [self.imgs count];
        self.scrollV.contentSize = contentSize; 
        [self.scrollV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onScrollVTapped:)] autorelease]];
        [self.view addSubview:self.scrollV];
        
        SDWebImageManager *imgMgr = [SDWebImageManager sharedManager];
        unsigned int idx = 0;        
        for (NSMutableDictionary *imgInf in self.imgs) {
            [imgInf setObject:[NSNumber numberWithInt:idx] forKey:@"idx"];
            
            NSURL *thumbUrl = [NSURL URLWithString:[imgInf objectForKey:@"thumbnail_pic"]];
            [_url2thumbInfWaiting4config setObject:imgInf forKey:thumbUrl];
            [imgMgr downloadWithURL:thumbUrl
                           delegate:self 
                            options:SDWebImageRetryFailed];
            
            NSURL *imgUrl = [NSURL URLWithString:[imgInf objectForKey:@"original_pic"]];
            [_url2imgInfWaiting4config setObject:imgInf forKey:imgUrl];
            [imgMgr downloadWithURL:imgUrl
                           delegate:self 
                            options:SDWebImageLowPriority | SDWebImageRetryFailed];
            idx++;
        }
        
        CGRect tbFrm = CGRectMake(0, containerSize.height - 60, containerSize.width, 60);
        _toolbarV = [[[UIView alloc] initWithFrame:tbFrm] autorelease];
        _toolbarV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _toolbarV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
        if (1 < self.imgs.count) {
            CGRect pgctrlFrm = CGRectZero;
            pgctrlFrm.size = CGSizeMake(400, 30);
            pgctrlFrm.origin.x = (containerSize.width - 400) / 2.0;
            pgctrlFrm.origin.y = (tbFrm.size.height - 30) / 2.0;
            _pgctrl = [[[UIPageControl alloc] initWithFrame:pgctrlFrm] autorelease];
            _pgctrl.numberOfPages = self.imgs.count;
            _pgctrl.userInteractionEnabled = NO;
        
            [_toolbarV addSubview:_pgctrl];
        }
    
        UIImage *btnImg = [UIImage imageNamed:@"save2localBtn.png"];
        CGRect btnFrm = CGRectZero;
        btnFrm.size = btnImg.size;
        btnFrm.origin.x = tbFrm.size.width - btnFrm.size.width - 30;
        btnFrm.origin.y = (CGRectGetHeight(tbFrm) - CGRectGetHeight(btnFrm)) / 2.0;
        _saveToLocalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveToLocalBtn.frame = btnFrm;
        _saveToLocalBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_saveToLocalBtn setImage:btnImg forState:UIControlStateNormal];
        [_saveToLocalBtn addTarget:self action:@selector(_onSave2LocalBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarV addSubview:_saveToLocalBtn];
    
        [self.view addSubview:_toolbarV];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [_imgs release];
    [_tag2imgV release];
    [_idx2imgV release];
    [_idx2thumbV release];
    [_idx2ingV release];
    [_scrollV release];
    [_url2imgInfWaiting4config release];
    [_url2thumbInfWaiting4config release];
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -

- (void)showImgFromThumbV:(UIImageView *)thumbV
{   
    self.view.frame = self.container.bounds;
    _curIdx = [self _getIdxForTag:thumbV.tag];
    [self _reconfigureFrames];
    //[self.scrollV setContentOffset:CGPointMake([self _calcOffsetForTag:thumbV.tag], 0) animated:NO];
    [self.container addSubview:self.view];
    
    UIImageView *imgv = [self.tag2imgV objectForKey:[NSNumber numberWithInt:thumbV.tag]];    
    if (imgv) {
        _srcRect = [self.container convertRect:thumbV.frame fromView:thumbV.superview];
        self.view.backgroundColor = [UIColor clearColor];
        CGRect toRect = imgv.frame;    
        CGRect fromRect = _srcRect;
        fromRect.origin.x += [self _calcOffsetForTag:thumbV.tag];
        imgv.frame = fromRect;
        _toolbarV.hidden = YES;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             imgv.frame = toRect;
                             //self.view.backgroundColor = [UIColor blackColor];
                         } 
                         completion:^(BOOL finished) {
                             //self.view.backgroundColor = [UIColor blackColor];
                             //_curIdx = [self _getIdxForTag:thumbV.tag];
                             _toolbarV.hidden = NO;
                             if (_pgctrl) {
                                 _pgctrl.currentPage = _curIdx;
                             }
                         }];
        
        [UIView animateWithDuration:0.6
                         animations:^{
                             self.view.backgroundColor = [UIColor blackColor];
                         } 
                         completion:nil];
    }
}

- (void)showFromView:(UIView *)view
{
    [self.container addSubview:self.view];
    
    UIImageView *imgv = [self.tag2imgV objectForKey:[NSNumber numberWithInt:0]];    
    if (imgv) {
        _srcRect = [self.container convertRect:view.frame fromView:view.superview];
        self.view.backgroundColor = [UIColor clearColor];
        CGRect toRect = imgv.frame;    
        CGRect fromRect = _srcRect;
        imgv.frame = fromRect;
        _toolbarV.hidden = YES;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             imgv.frame = toRect;
                         } 
                         completion:^(BOOL finished) {
                             self.view.backgroundColor = [UIColor blackColor];
                             _curIdx = 0;
                             _toolbarV.hidden = NO;
                         }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _curIdx = (NSUInteger)floor(self.scrollV.contentOffset.x / self.scrollV.frame.size.width);
    if (_pgctrl) {
        _pgctrl.currentPage = _curIdx;
    }
}

#pragma mark -
- (NSUInteger)_calcOffsetForIdx:(NSUInteger)idx
{
    return self.container.bounds.size.width * idx;
}

- (NSUInteger)_calcOffsetForTag:(NSUInteger)tag
{
    return [self _calcOffsetForIdx:[self _getIdxForTag:tag]];
}

- (NSUInteger)_getIdxForTag:(NSUInteger)tag
{
    NSUInteger idx = 0;
    for (NSDictionary *imginf in self.imgs) {
        NSNumber *t = [imginf objectForKey:@"tag"];
        if ([t isEqualToNumber:[NSNumber numberWithInt:tag]]) {
            break;
        }
        
        idx++;
    }
    
    return idx;
}

- (void)_onScrollVTapped:(UITapGestureRecognizer *)tgr
{
    UIImageView *imgv = [self.idx2imgV objectForKey:[NSNumber numberWithInt:_curIdx]];
    if (imgv && _srcRect.size.width) {
        CGRect defFrm = imgv.frame;    
        CGRect toRect = _srcRect;
        toRect.origin.x += [self _calcOffsetForIdx:_curIdx];
        self.view.backgroundColor = [UIColor clearColor];
        _toolbarV.hidden = YES;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             imgv.frame = toRect;
                         } 
                         completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                             imgv.frame = defFrm;
                         }];
    } else {
        [self.view removeFromSuperview];
    }
}

#pragma mark
- (UIActivityIndicatorView *)_makeIngVAtIdx:(NSUInteger)idx
{
    UIActivityIndicatorView *ingV = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    ingV.hidesWhenStopped = YES;
    [ingV startAnimating];
    
    CGRect ingFrm = ingV.frame;
    ingFrm.origin.x = CGRectGetMidX(self.container.bounds) + [self _calcOffsetForIdx:idx] - CGRectGetMidX(ingFrm);
    ingFrm.origin.y = CGRectGetMidY(self.container.bounds) - CGRectGetMidY(ingFrm);
    ingV.frame = ingFrm;
    
    return ingV;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url
{
    NSDictionary *imgInf = [_url2imgInfWaiting4config objectForKey:url];
    if (imgInf) {
        [_url2imgInfWaiting4config removeObjectForKey:url];
        [_url2thumbInfWaiting4config removeObjectForKey:[NSURL URLWithString:[imgInf objectForKey:@"thumbnail_pic"]]];
        
        NSNumber *idxnum = [imgInf objectForKey:@"idx"];
        NSUInteger idx = idxnum.intValue;
        CGSize imgDisplaySize = image.size;
        CGSize containerSize = self.container.bounds.size;
        
        if (imgDisplaySize.width > containerSize.width) {
            CGFloat scale = containerSize.width / imgDisplaySize.width;
            imgDisplaySize.width = containerSize.width;
            imgDisplaySize.height *= scale;
        }
        
        if (imgDisplaySize.height > containerSize.height) {
            CGFloat scale = containerSize.height / imgDisplaySize.height;
            imgDisplaySize.height = containerSize.height;
            imgDisplaySize.width *= scale;        
        }
        
        CGRect imgFrame = CGRectZero;
        imgFrame.size = imgDisplaySize;
        imgFrame.origin.x = (containerSize.width - imgDisplaySize.width) / 2 + [self _calcOffsetForIdx:idx];
        imgFrame.origin.y = (containerSize.height - imgDisplaySize.height) / 2;
        
        UIImageView *imgV = [[[UIImageView alloc] initWithFrame:imgFrame] autorelease];
        imgV.image = image;
        [self.scrollV addSubview:imgV];
        
        NSNumber *tagnum = [imgInf objectForKey:@"tag"];
        if (tagnum) {
            [self.tag2imgV setObject:imgV forKey:tagnum];
        }                              
        [self.idx2imgV setObject:imgV forKey:idxnum];
        
        UIImageView *thumbV = [_idx2thumbV objectForKey:idxnum];
        if (thumbV) {   
            [thumbV removeFromSuperview];
            [_idx2thumbV removeObjectForKey:idxnum];
        }
        
        UIView *ingCtnV = [_idx2ingV objectForKey:idxnum];
        if (ingCtnV) {
            [ingCtnV removeFromSuperview];
            [_idx2ingV removeObjectForKey:idxnum];
        }
        
    } else {
        imgInf = [_url2thumbInfWaiting4config objectForKey:url];
        
        if (imgInf) {
            [_url2thumbInfWaiting4config removeObjectForKey:url];
            
            NSNumber *idxnum = [imgInf objectForKey:@"idx"];
            NSUInteger idx = idxnum.intValue;
            
            CGRect imgFrm = CGRectZero;
            imgFrm.size = image.size;
            imgFrm.origin.x = CGRectGetMidX(self.container.bounds) - image.size.width / 2.0 + [self _calcOffsetForIdx:idx];
            imgFrm.origin.y = CGRectGetMidY(self.container.bounds) - image.size.height / 2.0;
            
            UIImageView *thumbV = [[[UIImageView alloc] initWithFrame:imgFrm] autorelease];
            thumbV.image = image;
            
            [self.scrollV addSubview:thumbV];
            [_idx2thumbV setObject:thumbV forKey:idxnum];
            
            
            UIActivityIndicatorView *ingV = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
            CGRect ingFrm = ingV.frame;            
            CGRect ingCtnFrm = ingFrm;
            ingCtnFrm.size.width += 10;
            ingCtnFrm.size.height += 10;
            ingCtnFrm.origin.x = CGRectGetMidX(self.container.bounds) - CGRectGetMidX(ingCtnFrm) + [self _calcOffsetForIdx:idx];
            ingCtnFrm.origin.y = CGRectGetMidY(self.container.bounds) - CGRectGetMidY(ingCtnFrm);
            
            UIView *ingCtnV = [[[UIView alloc] initWithFrame:ingCtnFrm] autorelease];
            ingCtnV.backgroundColor = [UIColor blackColor];
            ingCtnV.layer.cornerRadius = 4;
            ingCtnV.clipsToBounds = YES;
            ingCtnV.alpha = 0.5;
             
            ingFrm.origin.x = 5;
            ingFrm.origin.y = 5;
            ingV.frame = ingFrm;
            [ingV startAnimating];
            
            [ingCtnV addSubview:ingV];
            [self.scrollV addSubview:ingCtnV];
            [_idx2ingV setObject:ingCtnV forKey:idxnum];
        }
    }
}

- (void)_onSave2LocalBtnTapped:(id)sender
{
    UIImageView *curImgV = [self.idx2imgV objectForKey:[NSNumber numberWithInt:_curIdx]];
    if (curImgV) {
        _saveToLocalBtn.enabled = NO;
        UIImageWriteToSavedPhotosAlbum(curImgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [[iToast makeText:@"已保存到相册"] show];
    _saveToLocalBtn.enabled = YES;
}

- (void)_onOrientationChanged:(NSNotification *)note
{
    [self _reconfigureFrames];
}

- (void)_reconfigureFrames
{
    CGSize containerSize = self.container.bounds.size;
    CGSize contentSize = containerSize;
    contentSize.width *= [self.imgs count];
    self.scrollV.contentSize = contentSize;
    
    for (NSNumber *idxnum in _idx2imgV) {
        unsigned int idx = idxnum.intValue;
        UIImageView *imgV = [_idx2imgV objectForKey:idxnum];
        CGSize imgDisplaySize = imgV.image.size;
        
        if (imgDisplaySize.width > containerSize.width) {
            CGFloat scale = containerSize.width / imgDisplaySize.width;
            imgDisplaySize.width = containerSize.width;
            imgDisplaySize.height *= scale;
        }
        
        if (imgDisplaySize.height > containerSize.height) {
            CGFloat scale = containerSize.height / imgDisplaySize.height;
            imgDisplaySize.height = containerSize.height;
            imgDisplaySize.width *= scale;        
        }
        
        CGRect imgFrame = CGRectZero;
        imgFrame.size = imgDisplaySize;
        imgFrame.origin.x = (containerSize.width - imgDisplaySize.width) / 2 + [self _calcOffsetForIdx:idx];
        imgFrame.origin.y = (containerSize.height - imgDisplaySize.height) / 2;
        
        imgV.frame = imgFrame;
    }
    
    [self.scrollV setContentOffset:CGPointMake([self _calcOffsetForIdx:_curIdx], 0) animated:NO];
    
    for (NSNumber *idxnum in _idx2thumbV) {
        NSUInteger idx = idxnum.intValue;
        UIImageView *imgV = [_idx2thumbV objectForKey:idxnum];
        
        CGRect imgFrm = imgV.frame;
        imgFrm.origin.x = CGRectGetMidX(self.container.bounds) - imgV.image.size.width / 2.0 + [self _calcOffsetForIdx:idx];
        imgFrm.origin.y = CGRectGetMidY(self.container.bounds) - imgV.image.size.height / 2.0;
        
        imgV.frame = imgFrm;
    }
    
    for (NSNumber *idxnum in _idx2ingV) {
        NSUInteger idx = idxnum.intValue;
        UIView *ingCtnV = [_idx2ingV objectForKey:idxnum];
        
        CGRect ingCtnFrm = ingCtnV.frame;
        ingCtnFrm.origin.x = CGRectGetMidX(self.container.bounds) - CGRectGetMidX(ingCtnV.bounds) + [self _calcOffsetForIdx:idx];
        ingCtnFrm.origin.y = CGRectGetMidY(self.container.bounds) - CGRectGetMidY(ingCtnV.bounds);
        ingCtnV.frame = ingCtnFrm;
    }
}

@end
