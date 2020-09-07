//
//  KDStatusPhotoRenderView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KDImageSourceProtocol.h"
#import "KDProgressIndicatorView.h"


@protocol KDStatusPhotoRenderViewDelegate;

@interface KDStatusPhotoRenderView : UIButton <KDImageSourceLoader> {
@private
  
    CALayer *maskLayer_;
    CALayer *photoLayer_;
    
    KDProgressIndicatorView *progressView_;
    UILabel *infoLabel_;
    
    BOOL downloading_;
    float downloadsFinishedPercent_;
}

@property (nonatomic, weak) id<KDStatusPhotoRenderViewDelegate> delegate;
@property (nonatomic, strong)id<KDImageDataSource> imageSource;
@property (nonatomic, strong) KDStatus *status;

- (BOOL)hasVideo;
+ (id) photoRenderView;
+ (id) photoRenderViewWithStatus:(KDStatus *)status;

@end



@protocol KDStatusPhotoRenderViewDelegate <NSObject>
@optional

- (void)statusPhotoRenderView:(KDStatusPhotoRenderView *)photoRenderView didFinishLoadImage:(UIImage *)image;

@end

