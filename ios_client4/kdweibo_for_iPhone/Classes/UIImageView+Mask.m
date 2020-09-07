//
//  UIImageView+Mask.m
//  kdweibo
//
//  Created by fang.jiaxin on 16/11/28.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UIImageView+Mask.h"

@implementation UIImageView (Mask)
-(void)roundMask
{
    // 使用一个蒙版对图片进行裁切
    if (isAboveiOS8) {
        UIImageView *maskImageView = [[UIImageView alloc] init];
        maskImageView.image = [UIImage imageNamed:@"app_icon_mask"];
        maskImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        maskImageView.contentMode = UIViewContentModeScaleToFill;
        self.maskView = maskImageView;
    } else {
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        maskLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"app_icon_mask"].CGImage);
        self.layer.mask = maskLayer;
    }
}
@end
