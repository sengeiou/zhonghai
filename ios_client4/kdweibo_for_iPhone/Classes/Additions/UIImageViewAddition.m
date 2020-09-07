//
//  UIImageViewAddition.m
//  kdweibo
//
//  Created by Guohuan Xu on 6/27/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "UIImageViewAddition.h"

@implementation UIImageView(Category)

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
{
    if (imageName == nil) {
        return nil;
    }
    
    UIImage * image = [UIImage imageNamed:imageName];
    
    if (image == nil) {
        return nil;
    }
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];// autorelease];
    [imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    return imageView;
}

@end
