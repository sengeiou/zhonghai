//
//  KDDiscoveryTopicItem.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDiscoveryTopicItem.h"

@implementation KDDiscoveryTopicItem
@synthesize titleLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin ;
        titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = UIColorFromRGB(0x3e3e3e);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat titleLength = 120;
    CGRect titleRect = CGRectMake((self.bounds.size.width - titleLength)/2, 0, titleLength, self.bounds.size.height);
    titleLabel.frame = titleRect;
}

- (void)dealloc{
    //KD_RELEASE_SAFELY(titleLabel);
    //[super dealloc];
}

@end
