//
//  CircleProgressView.m
//
//  Created by lee on 17/10/30.
//  Copyright © 2016年 kingdee. All rights reserved.
//


#import "CircleProgressView.h"

#define kDuration 2.0
#define kDefaultLineWidth 2

@interface CircleProgressView()

@property (nonatomic,strong) CAShapeLayer *backgroundLayer;
@property (nonatomic,strong) CAShapeLayer *progressLayer;
@property (nonatomic,strong) UILabel *progressLabel;

@property (nonatomic,assign) CGFloat sumSteps;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation CircleProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self createSubViews];
        //init default variable
        self.backgroundLineWidth = kDefaultLineWidth;
        self.progressLineWidth = kDefaultLineWidth;
        self.percentage = 0;
        self.offset = 0;
        self.sumSteps = 0;
        self.step = 0.1;
    }
    return self;
}

- (void)createSubViews
{
    self.progressLabel.text = @"0%";
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.font = [UIFont systemFontOfSize:15 weight:0.4];
    [self addSubview:self.progressLabel];
    
    self.tipLabel.text = @"正在同步人员信息";
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = [UIFont systemFontOfSize:16 weight:0.4];
    [self addSubview:self.tipLabel];
    
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.frame = self.bounds;
    _backgroundLayer.fillColor = nil;
    _backgroundLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = nil;
    _progressLayer.strokeColor = [UIColor redColor].CGColor;
    
    [self.layer addSublayer:_backgroundLayer];
    [self.layer addSublayer:_progressLayer];
}

#pragma mark - draw circleLine
- (void)setBackgroundCircleLine
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y - 10)
                                          radius:(self.frame.size.width * 0.6- _backgroundLineWidth)/2 - _offset
                                      startAngle:0
                                        endAngle:M_PI*2
                                       clockwise:YES];
    
    _backgroundLayer.path = path.CGPath;
}

- (void)setProgressCircleLine
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y - 10)
                                          radius:(self.frame.size.width * 0.6- _progressLineWidth)/2 - _offset
                                      startAngle:-M_PI_2
                                        endAngle:-M_PI_2 + M_PI *2
                                       clockwise:YES];
    
    _progressLayer.path = path.CGPath;
}

#pragma mark -setter and get method
- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.bounds.size.width -100)/2, (self.bounds.size.height - 100)/2 - 5, 100, 100)];
    }
    return _progressLabel;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width, 50)];
        _tipLabel.textColor = [UIColor whiteColor];
    }
    return _tipLabel;
}

- (void)setDigitTintColor:(UIColor *)digitTintColor
{
    _digitTintColor = digitTintColor;
    _progressLabel.textColor = _digitTintColor;
}

- (void)setBackgroundLineWidth:(CGFloat)backgroundLineWidth
{
    _backgroundLineWidth = backgroundLineWidth;
    _backgroundLayer.lineWidth = _backgroundLineWidth;
    [self setBackgroundCircleLine];
}

- (void)setProgressLineWidth:(CGFloat)progressLineWidth
{
    _progressLineWidth = progressLineWidth;
    _progressLayer.lineWidth = _progressLineWidth;
    [self setProgressCircleLine];
}

- (void)setPercentage:(CGFloat)percentage
{
    _percentage = percentage;
}

- (void)setBackgroundStrokeColor:(UIColor *)backgroundStrokeColor
{
    _backgroundStrokeColor = backgroundStrokeColor;
    _backgroundLayer.strokeColor = _backgroundStrokeColor.CGColor;
}

- (void)setProgressStrokeColor:(UIColor *)progressStrokeColor
{
    _progressStrokeColor = progressStrokeColor;
    _progressLayer.strokeColor = _progressStrokeColor.CGColor;
}

#pragma mark - progress animated YES or NO
- (void)setProgress:(CGFloat)percentage animated:(BOOL)animated
{
    self.percentage = percentage;
    CGFloat showPercentage = (_percentage > 1.0f?1.0f:_percentage);
    _progressLayer.strokeEnd = showPercentage;
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:0.0];
        animation.toValue = [NSNumber numberWithFloat:showPercentage];
        animation.duration = kDuration;
        //start timer
        _timer = [NSTimer scheduledTimerWithTimeInterval:_step
                                                  target:self
                                                selector:@selector(numberAnimation)
                                                userInfo:nil
                                                 repeats:YES];
        
        
        [_progressLayer addAnimation:animation forKey:@"strokeEndAnimation"];
    }else{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",showPercentage*100];
        [CATransaction commit];
    }
}

- (void)numberAnimation
{
    _sumSteps += _step;
    float sumSteps = (_percentage/kDuration)*_sumSteps;
    _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",sumSteps*100];
    if (_sumSteps >= kDuration) {
        //close timer
        [_timer invalidate];
        _timer = nil;
        return;
    }
}
@end
