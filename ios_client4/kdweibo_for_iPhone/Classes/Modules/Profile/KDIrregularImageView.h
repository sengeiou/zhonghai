//
//  KDIrregularImageView.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-27.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDIrregularImageView : UIView{
    UIImage *image_;
    CGImageRef maskImage_;
    
    CGRect maskImageFrame_;
}

@property (nonatomic, retain) UIImage *image;

- (void)setMaskImage:(UIImage *)maskImage;

@end
