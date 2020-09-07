//
//  KDPhotoOriginView.h
//  kdweibo
//
//  Created by shen kuikui on 13-4-17.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDImageSourceProtocol.h"

#import "KDWeiboServicesContext.h"
#import "KDImageLoaderAdapter.h"
#import "KDProgressIndicatorView.h"

@protocol KDPhotoOriginViewDelegate;

@interface KDPhotoOriginView : UIView <UIScrollViewDelegate, KDImageSourceLoader>
{
    UIScrollView *scrollView_;
    UIImageView  *imageView_;
    KDProgressIndicatorView *progressIndicatorView_;
    
    BOOL isFit_;
    CGFloat fitScale_;
    
    id<KDImageDataSource> imageSource_;
    
    BOOL doubleTaps_;
}

@property (nonatomic, retain) id<KDImageDataSource> imageSource;
@property (nonatomic, assign) id<KDPhotoOriginViewDelegate> delegate;

- (void)loadImageWithURL:(NSString *)url;
- (void)freeImage;

@end

@protocol KDPhotoOriginViewDelegate <NSObject>

- (void)photoOriginView:(KDPhotoOriginView *)originView didTapWithCount:(NSUInteger)tapCount;

@end
