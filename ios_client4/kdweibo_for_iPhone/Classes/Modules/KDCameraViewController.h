//
//  KDCameraViewController.h
//  HHCamera_OC
//
//  Created by kingdee on 2017/10/9.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KDCameraViewController;
@protocol KDCameraViewControllerDelegate <NSObject>
@optional
- (void)cameraViewController:(KDCameraViewController *)camera WithImage:(UIImage*)image;

@end

@interface KDCameraViewController : UIViewController
@property (nonatomic, weak) id <KDCameraViewControllerDelegate> delegate;

@end
