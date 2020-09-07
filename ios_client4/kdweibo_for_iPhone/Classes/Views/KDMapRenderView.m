//
//  KDMapRenderView.m
//  kdweibo
//
//  Created by Tan yingqi on 13-3-11.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDMapRenderView.h"

@implementation KDMapRenderView
@synthesize delegate = delegate_;
@synthesize imageDataSource = imageDataSource_;
@synthesize mapRenderViewSize = mapRenderViewSize_;
@synthesize imageView = imageView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        imageView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView_.contentMode = UIViewContentModeScaleAspectFit;
        imageView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView_];
    }
    return self;
}

- (SDWebImageScaleOptions)cacheImageType {
    return SDWebImageScaleThumbnail;
}

- (UIImage *)defaultThumbnail {
    return [UIImage imageNamed:@"location_holder"];
}

- (void)loadMapImage {
    
    NSURL *imgUrl = [NSURL URLWithString:[imageDataSource_ thumbnailImageURL]];
    __block KDMapRenderView *renderView = self;// retain];
    
    [[SDWebImageManager sharedManager] downloadWithURL:imgUrl options:SDWebImageLowPriority | SDWebImageRetryFailed imageScale:SDWebImageScaleThumbnail progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished){
    
        if ([url isEqual:imgUrl]) {
            
            [self updateImage:image];
            
            if (finished && image) {
                
                if(delegate_ && [delegate_ respondsToSelector:@selector(mapRenderView:didLoadImage:)]) {
                    [delegate_ mapRenderView:self didLoadImage:image];
                }
            }
        }
        
//        [renderView release];
    }];
    
}
- (void)setImageDataSource:(id<KDImageDataSource>)imageDataSource {
    if(imageDataSource_ != imageDataSource){
//        [imageDataSource_ release];
        imageDataSource_ = imageDataSource;// retain];
    }
    if(imageDataSource_ != nil){
        [self loadMapImage];
    }else {
    // clear the image
        imageView_.image = nil;
    }
}

- (void)updateImage:(UIImage *)image {
    if (image != nil) {
      //  hasImage_ = YES;
        
    }else {
        image = [self defaultThumbnail];
    }
    if(image != nil){
        imageView_.image = image;
    }
}


- (void)dealloc {
    //@add-time:2013年10月17日14:42:52 by skk
    //@add-reason:bug
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(imageDataSource_);
    //KD_RELEASE_SAFELY(mapRenderViewSize_);
    //KD_RELEASE_SAFELY(imageView_);
    //[super dealloc];
}

@end
