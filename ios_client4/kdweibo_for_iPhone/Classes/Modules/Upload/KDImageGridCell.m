//
//  KDImageGridCell.m
//  kdweibo
//
//  Created by Tan yingqi on 13-5-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDImageGridCell.h"
#import <QuartzCore/QuartzCore.h> 
#import "KDCache.h"

@implementation KDImageGridCell
@synthesize imageView = imageView_;
@synthesize imageSource = imageSource_;
@synthesize checkImageView = checkImageView_;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
       imageView_ = [[UIImageView alloc] initWithFrame:self.bounds];

        [self addSubview:imageView_];
        
        self.layer.borderWidth = 0.3;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        CGRect frame = self.bounds;
        
        frame.origin.x =CGRectGetWidth(frame)-24-5;
        frame.origin.y =CGRectGetHeight(frame)-24-5;
        frame.size = CGSizeMake(24, 24);
        checkImageView_ = [[UIImageView alloc] initWithFrame:frame];
        checkImageView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:checkImageView_];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
     imageView_.frame = CGRectInset(self.bounds, 5, 5);
    
}

//- (void)setImageItem:(KDImageItem *)imageItem {
//    if (imageItem_ == imageItem) {
//        return;
//    }
//    [imageItem_ release];
//    imageItem_ = [imageItem retain];
//    imageItem_.delegate = self;
//    if (imageItem.image) {
//        self.imageView.image = imageItem.image;
//    }else {
//        [imageItem startLoad];
//    }
//    
//}
-(void)setImageSource:(KDImageSource *)imageSource {
    if (imageSource_ == imageSource) {
        return;
    }
   [imageSource_ removeObserver:self forKeyPath:@"thumbnail"];
//   [imageSource_ release];
    imageSource_ = imageSource;// retain];
    if(imageSource_.thumbnail) {
       self.imageView.image = [UIImage imageWithContentsOfFile:imageSource_.thumbnail];
    }else {
        [imageSource_ addObserver:self forKeyPath:@"thumbnail" options:NSKeyValueObservingOptionNew context:NULL];
        [imageSource_ fetchThumbImage];
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"thumbnail"]) {
        KDImageSource *imageSource = (KDImageSource *)object;
        //self.imageView.image = [UIImage imageWithContentsOfFile:imageSource.thumbnail];
        self.imageView.image = [[KDCache sharedCache] imageForURL:imageSource.thumbnail imageType:KDCacheImageTypeThumbnail];
    }
}
- (void)thumbImageDidLoad:(UIImage *)image {
    self.imageView.image = image;
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(imageSource_);
    //KD_RELEASE_SAFELY(imageView_);
    //KD_RELEASE_SAFELY(checkImageView_);
    //[super dealloc];
}

@end
