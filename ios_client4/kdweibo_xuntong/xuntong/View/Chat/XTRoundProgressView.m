//
//  XTRoundProgressView.m
//  XT
//
//  Created by Gil on 13-12-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTRoundProgressView.h"
#import "XTDeleteService.h"

#define XTRoundProgressInterval 0.1

@interface XTRoundProgressView ()
@property (weak, nonatomic) NSTimer *timer;
@property (nonatomic) int remainingTime;
@end

@implementation XTRoundProgressView

#pragma mark - Lifecycle

- (id)init {
	return [self initWithFrame:CGRectMake(0.f, 0.f, 51.f, 51.f)];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		_progress = 0.f;
		_progressTintColor = BOSCOLORWITHRGBA(0x47EF26, 1.f);
		_backgroundTintColor = BOSCOLORWITHRGBA(0x34323D, 1.f);
        _effectiveDuration = 60;
		[self registerForKVO];
	}
	return self;
}

- (void)dealloc {
	[self unregisterFromKVO];
    
    [self cancelTimer];
    _delegate = nil;
    
}

- (void)addProgress
{
    if (self.progress < 1.0)
    {
        self.progress += XTRoundProgressInterval/self.effectiveDuration;
    }
    else
    {
        [self cancelTimer];
    }
}

- (void)startTimer
{
    if (self.effectiveDuration == 0)
    {
        return;
    }
    if (!self.progressStartTime)
    {
        return;
    }
    if (self.remainingTime == 0)
    {
        return;
    }
    
    if (self.timer)
    {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:XTRoundProgressInterval target:self selector:@selector(addProgress) userInfo:nil repeats:YES];
}

- (void)cancelTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Draw background
    CGFloat lineWidth = 5.f;
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = lineWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapRound;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - lineWidth)/2;
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [_backgroundTintColor set];
    [processBackgroundPath stroke];
    
    // Draw progress
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapRound;
    processPath.lineWidth = lineWidth;
    endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [_progressTintColor set];
    [processPath stroke];
    
    //Draw remainingTime
    NSString *label = [self remainTimeLabel];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [label sizeWithFont:font forWidth:rect.size.width lineBreakMode:NSLineBreakByWordWrapping];
    // determine correct rect for this label
    CGRect labelRect = CGRectMake((rect.size.width - size.width)/2, (rect.size.height - size.height)/2, size.width, size.height);
    // set text color in context
    CGContextSetFillColorWithColor(context, BOSCOLORWITHRGBA(0x4B4B4B, 1.0).CGColor);
    // draw text
    [label drawInRect:labelRect
             withFont:font
        lineBreakMode:NSLineBreakByWordWrapping
            alignment:NSTextAlignmentCenter];
    // restore context state
    CGContextRestoreGState(context);
}

#pragma mark - get or set

- (void)setProgress:(float)progress
{
    _progress = progress;
    
    if (progress > 0.833)
    {
        self.progressTintColor = BOSCOLORWITHRGBADIVIDE255(240.0, 131.0, 0, 1.0);
    }
    else
    {
        self.progressTintColor = BOSCOLORWITHRGBA(0x47EF26, 1.f);
    }
    
    int tempRemainingTime = ceil(self.effectiveDuration * (1 - self.progress));
    if (self.remainingTime > tempRemainingTime)
    {
        self.remainingTime = tempRemainingTime;
    }
}

- (void)setProgressStartTime:(NSDate *)progressStartTime
{
    if (_progressStartTime != progressStartTime)
    {
        _progressStartTime = progressStartTime;
    }
    
    float hasBeenTime = [[NSDate date] timeIntervalSinceDate:progressStartTime];
    if (self.effectiveDuration - hasBeenTime > 0)
    {
        self.progress = hasBeenTime/self.effectiveDuration;
        self.remainingTime = floor(self.effectiveDuration - hasBeenTime);
    }
    else
    {
        self.progress = 1.0;
        self.remainingTime = 0;
    }
}

- (void)setRemainingTime:(int)remainingTime
{
    _remainingTime = remainingTime;
    
    if (remainingTime == 0)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(progressFinished:)])
		{
            [_delegate progressFinished:self];
        }
        else if ([[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:self.msgId]) {
            
            if (self.personPublicId != nil) {
                [[XTDeleteService shareService] deleteMessageWithPublicId:self.personPublicId groupId:self.groupId msgId:self.msgId];
            }
            else {
                [[XTDeleteService shareService] deleteMessageWithGroupId:self.groupId msgId:self.msgId];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPubTimeLineGroupTable" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTimeLineGroupTable" object:nil userInfo:nil];
        }
    }
}

- (NSString *)remainTimeLabel
{
    int minute = self.remainingTime / 60;
    int second = self.remainingTime - 60 * minute;
    
    return [NSString stringWithFormat:@"%@:%@",[self fomartTimeToString:minute],[self fomartTimeToString:second]];
}

- (NSString *)fomartTimeToString:(int)time
{
    NSString *result = @"00";
    if (time >= 10)
    {
        result = [NSString stringWithFormat:@"%d",time];
    }
    else if (time > 0)
    {
        result = [NSString stringWithFormat:@"0%d",time];
    }
    return result;
}

#pragma mark - KVO

- (void)registerForKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths
{
	return [NSArray arrayWithObjects:@"progressTintColor", @"backgroundTintColor", @"progress", @"remainingTime", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self setNeedsDisplay];
}

@end
