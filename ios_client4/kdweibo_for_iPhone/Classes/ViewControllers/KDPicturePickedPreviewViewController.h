//
//  KDPicturePickedPreviewViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 13-6-4.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol KDPicturePickedPreviewViewControllerDelegate<NSObject>
- (void)confirmSeleted:(UIImage*)image;
- (void)cancleSelected;
@end
@interface KDPicturePickedPreviewViewController : UIViewController
@property(nonatomic,retain)UIImageView *imageView;
@property(nonatomic,retain)UIToolbar *toobar;
@property(nonatomic,retain)UIImage *image;
@property(nonatomic,assign)id<KDPicturePickedPreviewViewControllerDelegate> delegate;
@end
