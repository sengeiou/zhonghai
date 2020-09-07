//
//  KDQRScanView.m
//  kdweibo
//
//  Created by Gil on 15/1/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDQRScanView.h"

@interface KDQRScanView()

@property (nonatomic, assign) CGFloat rectSize;
@property (nonatomic, assign) CGFloat kPadding1;

@end

@implementation KDQRScanView

- (id) initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if( self ) {
        self.backgroundColor = [UIColor clearColor];
        self.rectSize = CGRectGetWidth(self.frame)  > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame)*11/16 : CGRectGetWidth(self.frame)*11/16;
        self.kPadding1 = (self.frame.size.width - self.rectSize) / 2;
        self.cropRect = CGRectMake((self.frame.size.width - self.rectSize) / 2, (self.frame.size.height - self.rectSize) / 2, self.rectSize, self.rectSize);
        self.startLight = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60)/2, MaxY(self.cropRect)+60, 60, 60)];
        [self.startLight setBackgroundImage:[UIImage imageNamed:@"close_light"] forState:UIControlStateNormal];
        [self.startLight addTarget:self action:@selector(changeStatue:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.startLight];
        
        self.lightLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 100)/2, MaxY(self.startLight.frame)+12, 100, 20)];
        self.lightLabel.text = ASLocalizedString(@"close_light");
        self.lightLabel.textAlignment = NSTextAlignmentCenter;
        self.lightLabel.textColor = FC6;
        self.lightLabel.font = FS5;
        [self addSubview:self.lightLabel];
        
        UIImage *image = [UIImage imageNamed:@"scan_wave"];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - image.size.width)/2, (self.frame.size.height - self.rectSize)/2, image.size.width, image.size.height)];
        self.imageView.image = image;
        [self addSubview:self.imageView];
        
        [self addRectBorder];
        [self startImgaeAnimation];
    }
    return self;
}

- (UILabel *)newLabelWith:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.layer.cornerRadius = 2.5f;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor colorWithRGB:0x33AAFE];
    
    return label;
}

- (void)addRectBorder {
    UILabel *label1 = [self newLabelWith:CGRectMake(self.kPadding1-5, self.cropRect.origin.y-5, 25, 5)];
    [self addSubview:label1];
    
    UILabel *label2 = [self newLabelWith:CGRectMake(CGRectGetMaxX(self.cropRect)-20, self.cropRect.origin.y-5, 25, 5)];
    [self addSubview:label2];
    
    UILabel *label3 = [self newLabelWith:CGRectMake(CGRectGetMaxX(self.cropRect), self.cropRect.origin.y-5, 5, 25)];
    [self addSubview:label3];
    
    UILabel *label4 = [self newLabelWith:CGRectMake(CGRectGetMaxX(self.cropRect), CGRectGetMaxY(self.cropRect)-20, 5, 25)];
    [self addSubview:label4];
    
    UILabel *label5 = [self newLabelWith:CGRectMake(CGRectGetMaxX(self.cropRect)-20, CGRectGetMaxY(self.cropRect), 25, 5)];
    [self addSubview:label5];
    
    UILabel *label6 = [self newLabelWith:CGRectMake(self.kPadding1-5, CGRectGetMaxY(self.cropRect), 25, 5)];
    [self addSubview:label6];
    
    UILabel *label7 = [self newLabelWith:CGRectMake(self.kPadding1-5, CGRectGetMaxY(self.cropRect)-20, 5, 25)];
    [self addSubview:label7];
    
    UILabel *label8 = [self newLabelWith:CGRectMake(self.kPadding1-5, self.cropRect.origin.y-5, 5, 25)];
    [self addSubview:label8];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow) {
        [self startImgaeAnimation];
    }
}

- (void)startImgaeAnimation{
    [self.imageView.layer addAnimation:[self moveY:2.f Y:[NSNumber numberWithFloat:200.0f]] forKey:@"animation"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.rectSize = CGRectGetWidth(self.frame)  > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame)*11/16 : CGRectGetWidth(self.frame)*11/16;
    self.kPadding1 = (self.frame.size.width - self.rectSize) / 2;
    self.cropRect = CGRectMake((self.frame.size.width - self.rectSize) / 2, (self.frame.size.height - self.rectSize) / 2, self.rectSize, self.rectSize);
    self.startLight.frame = CGRectMake((self.frame.size.width - 60)/2, MaxY(self.cropRect)+60, 60, 60);
    self.lightLabel.frame = CGRectMake((self.frame.size.width - 100)/2, MaxY(self.startLight.frame)+12, 100, 20);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.displayedMessage == nil) {
        self.displayedMessage = NSLocalizedStringWithDefaultValue(@"OverlayView displayed message", nil, [NSBundle mainBundle], @"Place a barcode inside the viewfinder rectangle to scan it.", @"Place a barcode inside the viewfinder rectangle to scan it.");
    }
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    CGContextSetStrokeColor(c, white);
    CGContextSetFillColor(c, white);
    [self drawRect:self.cropRect inContext:c];
    CGContextSaveGState(c);
    
    CGContextSetFillColorWithColor(c, [UIColor clearColor].CGColor);
    CGContextFillRect(c, self.cropRect);
    CGContextSaveGState(c);
    
    CGContextSetFillColorWithColor(c, [UIColor kdPopupBackgroundColor].CGColor);
    CGContextFillRect(c, CGRectMake(0.0, 0.0, CGRectGetWidth(rect), CGRectGetMinY(self.cropRect)));
    CGContextFillRect(c, CGRectMake(0.0, CGRectGetMaxY(self.cropRect), CGRectGetWidth(rect), CGRectGetHeight(rect) - CGRectGetMaxY(self.cropRect)));
    CGContextFillRect(c, CGRectMake(0.0, CGRectGetMinY(self.cropRect), CGRectGetMinX(self.cropRect), CGRectGetHeight(self.cropRect)));
    CGContextFillRect(c, CGRectMake(CGRectGetMaxX(self.cropRect), CGRectGetMinY(self.cropRect), CGRectGetWidth(rect) - CGRectGetMaxX(self.cropRect), CGRectGetHeight(self.cropRect)));
    CGContextSaveGState(c);
    
    UIFont *font = FS4;
    CGSize constraint = CGSizeMake(rect.size.width  - 2 * self.kPadding1, self.cropRect.origin.y);
    CGRect messageRect = [self.displayedMessage boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    CGRect displayRect = CGRectMake((rect.size.width - messageRect.size.width) / 2 , self.cropRect.origin.y + self.cropRect.size.height + 10, messageRect.size.width, messageRect.size.height);
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : FC6,
                                 NSParagraphStyleAttributeName : style};
    [self.displayedMessage drawInRect:displayRect withAttributes:attributes];
    
    CGContextRestoreGState(c);
}

- (void)changeStatue:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLightStatue:)]) {
        [self.delegate changeLightStatue:sender];
    }
}

-(CABasicAnimation *)moveY:(float)time Y:(NSNumber *)y{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"]; ///.y 的话就向下移动。
    animation.fromValue = @((self.frame.size.height - self.rectSize)/2);
    animation.toValue = @((self.frame.size.height + self.rectSize)/2);
    animation.duration = time;
    animation.removedOnCompletion = YES; //yes 的话，又返回原位置了。
    animation.repeatCount = MAXFLOAT;
    animation.fillMode = kCAFillModeForwards;
    //    animation.timingFunction =
    //    [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

/* 移动 */
-(CABasicAnimation *)positionAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 动画选项的设定
    animation.duration = 2.5;
    animation.removedOnCompletion = YES; //yes 的话，又返回原位置了。
    animation.repeatCount = MAXFLOAT;
    animation.fillMode = kCAFillModeForwards;
    // 起始帧和终了帧的设定
    animation.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position]; // 起始帧
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(320, 480)]; // 终了帧
    
    // 添加动画
    return animation;
}

@end
