//
//  PPLockView.m
//  GestureLock
//
//  Created by 王鹏 on 12-9-28.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPLockView.h"

#define startY 0
#define startX 20
#define PaddingX 12.5
#define PaddingY 12.5
#define p_Lock_Width 85
#define p_Lock_Height 85
static CGPoint lockPos[9] = {{startX, startY},{startX + p_Lock_Width + PaddingX, startY},{startX + p_Lock_Width*2 + PaddingX*2, startY},{startX, startY+p_Lock_Height+PaddingY},{startX + p_Lock_Width + PaddingX, startY+p_Lock_Height+PaddingY},{startX + p_Lock_Width*2 + PaddingX*2, startY+p_Lock_Height+PaddingY},{startX, startY+p_Lock_Height*2+PaddingY*2},{startX + p_Lock_Width + PaddingX, startY+p_Lock_Height*2+PaddingY*2},{startX + p_Lock_Width*2 + PaddingX*2, startY+p_Lock_Height*2+PaddingY*2}};

#define kColor_success [UIColor colorWithRed:252./255. green:190./255. blue:45./255. alpha:1.00f]
#define kColor_error [UIColor colorWithRed:233./255. green:103./255. blue:112./255. alpha:1.00f]

@implementation PPLockView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
		
		_selectedPointArray = [[NSMutableArray alloc]init];
		_passwd = [[NSMutableString alloc]init];
        
        _isFail = NO;
    }
    return self;
}


- (CGPathRef)linePathStartAt:(CGPoint)startPoint End:(CGPoint)endPoint With:(CGFloat)lineWidth
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y);
	CGPathAddLineToPoint(path, nil, endPoint.x, endPoint.y);
	CGPathCloseSubpath(path);
	return path ;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	currentPoint = [touch locationInView:self];
	
	for (int i = 0; i < 9; i++) {
		CGPoint p = lockPos[i];
		CGRect rect = CGRectMake(p.x, p.y, p_Lock_Width, p_Lock_Height);
		if(CGRectContainsPoint(rect, currentPoint))
		{
			CGPoint ap = CGPointMake(p.x+p_Lock_Width/2, p.y+p_Lock_Height/2);
			NSString *curstr = NSStringFromCGPoint(ap);
			if(![_selectedPointArray containsObject:curstr])
			{
				[_selectedPointArray addObject:curstr];
				[_passwd appendFormat:@"%d", i];
                
                if ([_delegate respondsToSelector:@selector(lockViewDidCheck:isFinished:)]) {
                    [_delegate lockViewDidCheck:_passwd isFinished:NO];
                }
			}
		}
	}
	
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([_passwd length] > 0 && [_delegate respondsToSelector:@selector(lockViewUnlockWithPasswd:)])
	{
		[_delegate lockViewUnlockWithPasswd:_passwd];
		
	}
	BOSDEBUG(@"Lock pw:%@", _passwd);
    if ([_delegate respondsToSelector:@selector(lockViewDidCheck:isFinished:)]) {
        [_delegate lockViewDidCheck:_passwd isFinished:YES];
    }
	[_passwd setString:@""];

}

- (void)fail
{
    _isFail = YES;
    [self setNeedsDisplay];
    
    int64_t delayInSeconds = 1.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_selectedPointArray removeAllObjects];
        [self setNeedsDisplay];
        _isFail = NO;
    });
}

- (void)success
{
    [_selectedPointArray removeAllObjects];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

	CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw points
    for (int i = 0; i < 9; i++) {
        CGPoint p = lockPos[i];
        
        CGPoint ap = CGPointMake(p.x+p_Lock_Width/2, p.y+p_Lock_Height/2);
        NSString *curstr = NSStringFromCGPoint(ap);
        if(![_selectedPointArray containsObject:curstr])
        {
            UIImage *img = [UIImage imageNamed:@"login_btn_unlok_normal"];
            [img drawAtPoint:CGPointMake(p.x+10, p.y+10)];
        }
        else if (!_isFail)
        {
            UIImage *img = [UIImage imageNamed:@"login_btn_unlok_normal"];
            [img drawAtPoint:CGPointMake(p.x+10, p.y+10)];
            
        } else {
            UIImage *img = [UIImage imageNamed:@"login_btn_wronglock_normal"];
            [img drawAtPoint:CGPointMake(p.x+10, p.y+10)];
            
        }
        
    }
    
    // draw line
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextSetStrokeColorWithColor(context, [_isFail?FC4:FC5 CGColor]);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    if ([_selectedPointArray count] > 0)
    {
        int i = 0;
        for (NSString *posstr in _selectedPointArray)
        {
            CGPoint p = CGPointFromString(posstr);
            if (i == 0)
            {
                CGContextMoveToPoint(context, p.x + 1, p.y + 1);
            }
            else
            {
                CGContextAddLineToPoint(context, p.x + 1, p.y + 1);
            }
            
            i++;
        }
        CGContextAddLineToPoint(context, currentPoint.x + 1, currentPoint.y + 1);
        CGContextStrokePath(context);
    }
    //盖上小圆点
    for (int i = 0; i < 9; i++) {
        CGPoint p = lockPos[i];
        
        CGPoint ap = CGPointMake(p.x+p_Lock_Width/2, p.y+p_Lock_Height/2);
        NSString *curstr = NSStringFromCGPoint(ap);
        if([_selectedPointArray containsObject:curstr])
        {
            if (!_isFail) {
                UIImage *img = [UIImage imageNamed:@"login_btn_unlock_press"];
                [img drawAtPoint:CGPointMake(p.x+33, p.y+33)];
            }
            else{
                UIImage *img = [UIImage imageNamed:@"login_btn_wronglock_press"];
                [img drawAtPoint:CGPointMake(p.x+33, p.y+33)];
            }
            
        }
    }
}


@end
