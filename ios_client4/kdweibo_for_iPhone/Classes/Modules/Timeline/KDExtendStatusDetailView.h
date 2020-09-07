//
//  KDExtendStatusDetailView.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDExtendStatus.h"
#import "KDStatusPhotoRenderView.h"

@protocol KDExtendStatusDetailViewDelegate;


@interface KDExtendStatusDetailView : UIView<KDStatusPhotoRenderViewDelegate>

@property (nonatomic, retain) KDExtendStatus *status;
@property (nonatomic, retain) id<KDExtendStatusDetailViewDelegate> delegate;

//no need
- (CGFloat)adaptionHeight;

@end

@protocol KDExtendStatusDetailViewDelegate <NSObject>

- (void)extendStautsDetailView:(KDExtendStatusDetailView *)detailView showImageGallery:(id<KDImageDataSource>)imageSource;

@end