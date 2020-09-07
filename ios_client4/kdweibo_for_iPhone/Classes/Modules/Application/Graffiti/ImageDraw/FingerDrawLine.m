//
//  FingerDrawLine.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "FingerDrawLine.h"

@implementation FingerDrawLine

#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _allMyDrawPaletteLineInfos = [[NSMutableArray alloc] initWithCapacity:10];
        self.currentPaintBrushColor = [UIColor redColor];
        self.backgroundColor = [UIColor clearColor];
        self.currentPaintBrushWidth =  4.f;
        self.userInteractionEnabled = YES;
    }
    return self;
    
}

#pragma  mark - draw event
//根据现有的线条 绘制相应的图画
- (void)drawLine {
    self.image = nil;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, self.currentPaintBrushWidth);
    CGContextSetStrokeColorWithColor(context, self.currentPaintBrushColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    [self.image drawAtPoint:CGPointZero];
    if (_allMyDrawPaletteLineInfos.count>0) {
        for (int i=0; i<[self.allMyDrawPaletteLineInfos count]; i++) {
            FingerDrawLineInfo *info = self.allMyDrawPaletteLineInfos[i];
            
            CGContextBeginPath(context);
            CGPoint myStartPoint=[[info.linePoints objectAtIndex:0] CGPointValue];
            CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
            
            if (info.linePoints.count>1) {
                for (int j=0; j<[info.linePoints count]-1; j++) {
                    CGPoint myEndPoint=[[info.linePoints objectAtIndex:j+1] CGPointValue];
                    CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
                }
            }else {
                CGContextAddLineToPoint(context, myStartPoint.x,myStartPoint.y);
            }
            CGContextSetStrokeColorWithColor(context, info.lineColor.CGColor);
            CGContextSetLineWidth(context, info.lineWidth+1);
            CGContextStrokePath(context);
        }
    }
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}


#pragma mark - touch event
//触摸开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch=[touches anyObject];
    
    [self drawPaletteTouchesBeganWithWidth:self.currentPaintBrushWidth andColor:self.currentPaintBrushColor andBeginPoint:[touch locationInView:self ]];
    [self drawLine];
}
//触摸移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray* MovePointArray=[touches allObjects];
    [self drawPaletteTouchesMovedWithPonit:[[MovePointArray objectAtIndex:0] locationInView:self]];
    [self drawLine];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}


#pragma mark draw info edite event
//在触摸开始的时候 添加一条新的线条 并初始化
- (void)drawPaletteTouchesBeganWithWidth:(float)width andColor:(UIColor *)color andBeginPoint:(CGPoint)bPoint {
    FingerDrawLineInfo *info = [FingerDrawLineInfo new];
    info.lineColor = color;
    info.lineWidth = width;
    [info.linePoints addObject:[NSValue valueWithCGPoint:bPoint]];
    
    [self.allMyDrawPaletteLineInfos addObject:info];
}

//在触摸移动的时候 将现有的线条的最后一条的 point增加相应的触摸过的坐标
- (void)drawPaletteTouchesMovedWithPonit:(CGPoint)mPoint {
    FingerDrawLineInfo *lastInfo = [self.allMyDrawPaletteLineInfos lastObject];
    [lastInfo.linePoints addObject:[NSValue valueWithCGPoint:mPoint]];
}

- (void)cleanAllDrawBySelf {
    if ([self.allMyDrawPaletteLineInfos count]>0)  {
        [self.allMyDrawPaletteLineInfos removeAllObjects];
        [self drawLine];
    }
}

- (void)cleanFinallyDraw {
    if ([self.allMyDrawPaletteLineInfos count]>0) {
        [self.allMyDrawPaletteLineInfos  removeLastObject];
    }
    [self drawLine];
}
@end
