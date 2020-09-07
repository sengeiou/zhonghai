//
//  XTRoundSelectStateView.m
//  kdweibo
//
//  Created by Ad on 14-5-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTRoundSelectStateView.h"

@interface XTRoundSelectStateView ()
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIImageView *selectStateImageView;
@property (nonatomic, strong) UIImageView *dotImageView;

@end

@implementation XTRoundSelectStateView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _selected = NO;
        
        UIImageView *selectStateImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSelectStateImageForFileWithState:self.selected]];
        selectStateImageView.bounds = CGRectMake(0, 0, 20, 20);
        selectStateImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.selectStateImageView = selectStateImageView;
        [self addSubview:selectStateImageView];
        [self sizeToFit];
        
        
        UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSelectDotImage]];
        CGAffineTransform newTransform = CGAffineTransformScale(dotImageView.transform, 0.1, 0.1);
        dotImageView.transform = newTransform;
        dotImageView.clipsToBounds = YES;
        dotImageView.alpha = 0.0;
        dotImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.dotImageView = dotImageView;
        [self addSubview:dotImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = self.frame;
    self.selectStateImageView.center = CGPointMake(f.size.width * 0.5f, f.size.height * 0.5f);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _selected = selected;
    
    if (animated) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (selected) {
                CGAffineTransform newTransform = CGAffineTransformConcat(self.dotImageView.transform,  CGAffineTransformInvert(self.dotImageView.transform));
                self.dotImageView.transform = newTransform;
                self.dotImageView.alpha = 1.0;
            } else {
                
                self.selectStateImageView.image = [XTImageUtil cellSelectStateImageForFileWithState:selected];
                
                CGAffineTransform newTransform = CGAffineTransformScale(self.dotImageView.transform, 0.1, 0.1);
                self.dotImageView.transform = newTransform;
                self.dotImageView.alpha = 0.0;
                
            }
            self.dotImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
        } completion:^(BOOL finished) {
            
            if (selected) {
                self.selectStateImageView.image = [XTImageUtil cellSelectStateImageForFileWithState:selected];
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
        self.selectStateImageView.image = [XTImageUtil cellSelectStateImageForFileWithState:selected];
        
    }
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

@end
