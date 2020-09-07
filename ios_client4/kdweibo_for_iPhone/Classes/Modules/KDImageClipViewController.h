//
//  KDImageClipViewController.h
//  kdweibo
//
//  Created by kingdee on 2017/11/17.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDImageClipViewController;

@protocol KDImageClipDelegate <NSObject>

- (void)imageCropper:(KDImageClipViewController *)clipViewController didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(KDImageClipViewController *)clipViewController;

@end

@interface KDImageClipViewController : UIViewController

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, weak) id<KDImageClipDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;
@end
