//
//  KWIStatusContentThumbV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/22/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIStatusContentThumbV.h"

@implementation KWIStatusContentThumbV

- (void)setImage:(UIImage *)image
{
    if (image) {
        CGRect frame = self.frame;
        CGFloat originSize = frame.size.width;
        frame.size.width = image.size.width * frame.size.height / image.size.height;
        frame.origin.x = (originSize - frame.size.width) / 2;
        self.frame = frame;
    }
    
    [super setImage:image];
}

@end
