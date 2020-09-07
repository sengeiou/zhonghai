//
//  KWIFullPicVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWIFullImgVCtrl : UIViewController

+ (KWIFullImgVCtrl *)vctrlWithImgs:(NSArray *)imgs;

- (void)showImgFromThumbV:(UIImageView *)thumbV;
- (void)showFromView:(UIView *)view;

@end