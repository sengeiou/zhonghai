//
//  XTSelectStateView.m
//  XT
//
//  Created by Gil on 13-7-22.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSelectStateView.h"
//
//  XTSelectStateView.m
//  XT
//
//  Created by Gil on 13-7-22.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSelectStateView.h"
#import "UIImage+XT.h"

@interface XTSelectStateView ()
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;
//@property (nonatomic, strong) UIImageView *selectStateImageView;
@property (nonatomic, strong) UIImageView *dotImageView;

@end

@implementation XTSelectStateView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _selected = NO;
        _isCanSelect = YES;
        
        UIImageView *selectStateImageView = [[UIImageView alloc] initWithImage:self.isCanSelect ? [XTImageUtil cellSelectStateImageWithState:self.selected] : nil];
        
        selectStateImageView.frame = CGRectMake(0, 0, 25, 25);
        selectStateImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.selectStateImageView = selectStateImageView;
        [self addSubview:selectStateImageView];
        [self sizeToFit];
        
        
        UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSelectDotImage]];
        CGAffineTransform newTransform = CGAffineTransformScale(dotImageView.transform, 0.1, 0.1);
        dotImageView.transform = newTransform;
        dotImageView.clipsToBounds = YES;
        dotImageView.alpha = 0.0;
        dotImageView.center = CGPointMake(frame.size.width/2 - 15, frame.size.height/2);
        self.dotImageView = dotImageView;
        //        [self addSubview:dotImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    self.selectStateImageView.center = CGPointMake(CGRectGetWidth(frame) * 0.5f, CGRectGetHeight(frame) * 0.5f);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _selected = selected;
    
    if (animated) {
        
        [UIView animateWithDuration:3.5 animations:^{
            
            if (selected) {
                CGAffineTransform newTransform = CGAffineTransformConcat(self.dotImageView.transform,  CGAffineTransformInvert(self.dotImageView.transform));
                self.dotImageView.transform = newTransform;
                self.dotImageView.alpha = 1.0;
            } else {
                
                self.selectStateImageView.image = self.isCanSelect ? [XTImageUtil cellSelectStateImageWithState:selected] : nil;
                
                CGAffineTransform newTransform = CGAffineTransformScale(self.dotImageView.transform, 0.1, 0.1);
                self.dotImageView.transform = newTransform;
                self.dotImageView.alpha = 0.0;
                
            }
            self.dotImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
        } completion:^(BOOL finished) {
            
            if (selected) {
                self.selectStateImageView.image = self.isCanSelect ? [XTImageUtil cellSelectStateImageWithState:selected] : nil;
            }
            
        }];
        
    } else {
        
        if (selected) {
            CGAffineTransform newTransform = CGAffineTransformConcat(self.dotImageView.transform,  CGAffineTransformInvert(self.dotImageView.transform));
            self.dotImageView.transform = newTransform;
            self.dotImageView.alpha = 1.0;
        } else {
            CGAffineTransform newTransform = CGAffineTransformScale(self.dotImageView.transform, 0.1, 0.1);
            self.dotImageView.transform = newTransform;
            self.dotImageView.alpha = 0.0;
        }
        self.dotImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.selectStateImageView.image = self.isCanSelect ? [XTImageUtil cellSelectStateImageWithState:selected] : nil;
        
    }
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

@end
