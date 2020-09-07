//
//  KDPreviewView.h
//  HHCamera_OC
//
//  Created by kingdee on 2017/10/9.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol KDPreviewViewDelegate <NSObject>
@optional
- (void)tappedToFocusAtPoint:(CGPoint)point;//聚焦
- (void)tappedToExposeAtPoint:(CGPoint)point;//曝光
- (void)tappedToResetFocusAndExposure;//点击重置聚焦&曝光

@end

@interface KDPreviewView : UIView
@property (nonatomic, strong) AVCaptureSession *session;
@property (weak, nonatomic) id<KDPreviewViewDelegate> delegate;

@property (nonatomic) BOOL tapToFocusEnabled; //是否聚焦
@property (nonatomic) BOOL tapToExposeEnabled; //是否曝光

@end
