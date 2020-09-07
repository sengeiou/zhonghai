//
//  BubbleVoiceView.m
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "BubbleVoiceView.h"

@interface BubbleVoiceView ()
@property (nonatomic, strong) UIImageView *voice1ImageView;
@property (nonatomic, strong) UIImageView *voice2ImageView;
@property (nonatomic, strong) UIImageView *voice3ImageView;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, strong) NSTimer *animationTimer;

@end

@implementation BubbleVoiceView

- (void)dealloc
{
    if (self.animationTimer) {
        [self.animationTimer invalidate];
    }
    
}

- (id)init
{
    return [self initWithFrame:CGRectMake(.0, .0, 12.0, 16.0)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.voice1ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.voice1ImageView.tag = 1;
        [self addSubview:self.voice1ImageView];
        self.voice2ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.voice2ImageView.tag = 2;
        [self addSubview:self.voice2ImageView];
        self.voice3ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.voice3ImageView.tag = 3;
        [self addSubview:self.voice3ImageView];
    }
    return self;
}

- (void)setMessageDirection:(MessageDirection)messageDirection
{
    _messageDirection = messageDirection;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    self.voice1ImageView.image = [XTImageUtil chatVoiceImageWithDirection:self.messageDirection tag:(int)self.voice1ImageView.tag];
    self.voice2ImageView.image = [XTImageUtil chatVoiceImageWithDirection:self.messageDirection tag:(int)self.voice2ImageView.tag];
    self.voice3ImageView.image = [XTImageUtil chatVoiceImageWithDirection:self.messageDirection tag:(int)self.voice3ImageView.tag];
    if (self.messageDirection == MessageDirectionLeft) {
        self.voice1ImageView.frame = CGRectMake(0.0, 0.0, 3.0, 7.0);
        self.voice2ImageView.frame = CGRectMake(3.0, 0.0, 4.0, 12.0);
        self.voice3ImageView.frame = CGRectMake(7.0, 0.0, 5.0, 16.0);
    } else {
        self.voice3ImageView.frame = CGRectMake(0.0, 0.0, 5.0, 16.0);
        self.voice2ImageView.frame = CGRectMake(5.0, 0.0, 4.0, 12.0);
        self.voice1ImageView.frame = CGRectMake(9.0, 0.0, 3.0, 7.0);
    }
    self.voice1ImageView.center = CGPointMake(self.voice1ImageView.center.x, self.bounds.size.height/2);
    self.voice2ImageView.center = CGPointMake(self.voice2ImageView.center.x, self.bounds.size.height/2);
    self.voice3ImageView.center = CGPointMake(self.voice3ImageView.center.x, self.bounds.size.height/2);
    
    [super layoutSubviews];
}

#pragma mark - animation

-(void)startAnimations
{
    if (!self.isAnimation) {
        self.isAnimation = YES;
        [self didStartAnimations];
        
        if (self.animationTimer == nil) {
            self.animationTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(didStartAnimations) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSDefaultRunLoopMode];
        }
    }
}

-(void)didStartAnimations
{
    if (self.voice1ImageView.hidden && self.voice2ImageView.hidden && self.voice3ImageView.hidden) {
        self.voice1ImageView.hidden = NO;
    }else if (!self.voice1ImageView.hidden && self.voice2ImageView.hidden && self.voice3ImageView.hidden){
        self.voice2ImageView.hidden = NO;
    }else if (!self.voice1ImageView.hidden && !self.voice2ImageView.hidden && self.voice3ImageView.hidden){
        self.voice3ImageView.hidden = NO;
    }else if (!self.voice1ImageView.hidden && !self.voice2ImageView.hidden && !self.voice3ImageView.hidden){
        self.voice1ImageView.hidden = YES;
        self.voice2ImageView.hidden = YES;
        self.voice3ImageView.hidden = YES;
    }
}

-(void)stopAnimations
{
    if (self.isAnimation) {
        self.isAnimation = NO;
        if (self.animationTimer) {
            [self.animationTimer invalidate];
            self.animationTimer = nil;
        }
        self.voice1ImageView.hidden = NO;
        self.voice2ImageView.hidden = NO;
        self.voice3ImageView.hidden = NO;
    }
}

@end
