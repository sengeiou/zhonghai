//
//  KKCutConer.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KKCutConer.h"

@interface KKCutConer()
@property (nonatomic, assign)KDConerLocation orientation;
@end

@implementation KKCutConer

- (id)initWithFrame:(CGRect)frame location:(KDConerLocation)location
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.orientation = location;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    {
        switch (self.orientation) {
            case RightTop:
                CGContextTranslateCTM(context, CGRectGetWidth(rect), 0);
                CGContextScaleCTM(context, -1.0f, 1.0f);
                break;
                
            case LeftBottom:
                CGContextTranslateCTM(context, 0, CGRectGetHeight(rect));
                CGContextScaleCTM(context, 1.0f, -1.0f);
                break;
                
                
            case RightBottom:
                CGContextTranslateCTM(context, CGRectGetWidth(rect), CGRectGetHeight(rect));
                CGContextScaleCTM(context, -1.0f, -1.0f);
                break;
            default:
                break;
        }
        drawCornerPath(context, rect);
    }
    CGContextRestoreGState(context);
    
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGRect rct = self.bounds;
//    rct.origin.x = rct.size.width/2-rct.size.width/6;
//    rct.origin.y = rct.size.height/2-rct.size.height/6;
//    rct.size.width /= 3;
//    rct.size.height /= 3;
//    
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillEllipseInRect(context, rct);
}

void drawCornerPath(CGContextRef context, CGRect rect) {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGPathMoveToPoint(path, NULL, center.x, center.y + 20);
    CGPathAddLineToPoint(path, NULL, center.x, center.y);
    CGPathAddLineToPoint(path, NULL, center.x + 20, center.y);
    
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGPathRelease(path);
}


@end
