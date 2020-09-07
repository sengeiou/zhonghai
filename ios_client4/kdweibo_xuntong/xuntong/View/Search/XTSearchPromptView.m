//
//  XTContactSearchPromptView.m
//  XT
//
//  Created by Gil on 13-7-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSearchPromptView.h"
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

@interface XTSearchPromptView ()
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation XTSearchPromptView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        self.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_search"]];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.backgroundView sizeToFit];
        [self addSubview:_backgroundView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    if (_title != title) {
        _title = [title copy];
    }
    
    [self setNeedsLayout];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    self.titleLabel.backgroundColor = backgroundColor;
}

- (void)layoutSubviews
{
    CGRect rect =  CGRectMake(10, 0, CGRectGetWidth(self.backgroundView.frame), self.backgroundView.frame.size.height);
    self.backgroundView.frame = rect;
    [super layoutSubviews];
}

@end
