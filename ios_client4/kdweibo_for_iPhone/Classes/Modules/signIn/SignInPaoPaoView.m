//
//  SignInPaoPaoView.m
//  kdweibo
//
//  Created by shifking on 15/9/18.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "SignInPaoPaoView.h"
@interface SignInPaoPaoView()
@property (strong , nonatomic) UIView *mengLayer;
@property (strong , nonatomic) PaoPaoBGView *mengTriangleView;
@end


@implementation SignInPaoPaoView

- (id)init{
    if(self = [super init]){

        CGFloat distance1              = [NSNumber kdDistance1];
        UIImage *rightTriangle         = [UIImage imageNamed:@"sign_tip_triangle"];



        UILabel *titleLab              = [[UILabel alloc] initWithFrame:CGRectMake(distance1, distance1 , 15 , 16)];
        titleLab.text                  = ASLocalizedString(@"添加这里作为签到点");
        [titleLab sizeToFit];
        titleLab.font                  = FS5;
        titleLab.textColor             = FC6;
        titleLab.textAlignment         = NSTextAlignmentCenter;

        UIImageView *rightTriangleView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLab.frame) + 4, (39-9)/2, 7, 9)];
        rightTriangleView.image        = rightTriangle;
        SetCenterY(titleLab.center, rightTriangleView.center.y);

        self.frame                     = CGRectMake(0, 0, CGRectGetMaxX(rightTriangleView.frame) + 10, 47);

        UIView *bgView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 39)];
        bgView.layer.cornerRadius      = 6;
        bgView.backgroundColor         = [UIColor kdPopupColor];
        PaoPaoBGView *paopaoView = [[PaoPaoBGView alloc] initWithFrame:CGRectMake( (CGRectGetWidth(self.frame) - 12)/2.0, CGRectGetMaxY(bgView.frame), 12, 8)];
        paopaoView.bgColor = [UIColor kdPopupColor];
        
        _mengLayer = [[UIView alloc] initWithFrame:bgView.bounds];
        _mengLayer.backgroundColor = UIColorFromRGBA(0x000000, 0.2);
        _mengLayer.hidden = YES;
        _mengLayer.layer.cornerRadius = 6;
        
        _mengTriangleView = [[PaoPaoBGView alloc] initWithFrame:paopaoView.bounds];
        _mengTriangleView.bgColor = UIColorFromRGBA(0x000000,0.2);
        _mengTriangleView.hidden = YES;
        
        [paopaoView addSubview:_mengTriangleView];
        [bgView addSubview:titleLab];
        [bgView addSubview:rightTriangleView];
        [bgView addSubview:_mengLayer];
        [self addSubview:bgView];
        [self addSubview:paopaoView];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    _mengLayer.hidden = NO;
    _mengTriangleView.hidden = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    _mengLayer.hidden = NO;
    _mengTriangleView.hidden = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    _mengLayer.hidden = YES;
    _mengTriangleView.hidden = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    _mengLayer.hidden = YES;
    _mengTriangleView.hidden = YES;
}

@end


@implementation PaoPaoBGView

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 6, 8);
    CGContextAddLineToPoint(context, 12, 0);
    if(_bgColor){
        CGContextSetFillColorWithColor(context, _bgColor.CGColor);
    }else{
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.75);
    }
    CGContextFillPath(context);
}

- (void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    [self setNeedsDisplay];
}


@end
