//
//  KDImageView.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-12-18.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDImageView.h"
#import "SDWebImageManager.h"

@interface KDImageView ()
@end


@implementation KDImageView

@synthesize imageURL = _imageURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_imageURL);
    
    //[super dealloc];
}

- (void)setImageURL:(NSString *)imageURL
{
    if(imageURL != _imageURL) {
//        [_imageURL release];
        _imageURL = [imageURL copy];
        
        NSURL *imgUrl = [NSURL URLWithString:imageURL];
        
        __block KDImageView *imageView = self;// retain];
        
        [[SDWebImageManager sharedManager] downloadWithURL:imgUrl options:SDWebImageRetryFailed | SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished){
        
            if ([url isEqual:imgUrl]) {
                self.image = image;
            }
            
            
//            [imageView release];
        }];
    }
}

@end
