//
//  UIView+WaterMark.m
//  kdweibo
//
//  Created by 张培增 on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UIView+WaterMark.h"

#define waterMarkFontSize 13
#define waterMarkColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06].CGColor
#define vSpacing 50
#define angle (M_PI*8/180)

@implementation UIView (WaterMark)

+ (UIView *)waterMarkView:(NSString *)waterMark withFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = NO;
    [view addWaterMark:waterMark withFrame:frame];
    return view;
}

/*
 * waterMark 水印的文字
 * frame 需要加水印的frame
 */
- (void)addWaterMark:(NSString *)waterMark withFrame:(CGRect)frame {
    //计算水印画布的实际frame
    float width = CGRectGetWidth(frame);
    float height = CGRectGetHeight(frame);
    CGRect waterMarkFrame = frame;
    waterMarkFrame.origin.x = -height*sin(angle)*cos(angle);
    waterMarkFrame.origin.y = height*sin(angle)*sin(angle);
    waterMarkFrame.size.width = height*sin(angle)+width*cos(angle);
    waterMarkFrame.size.height = height*cos(angle)+width*sin(angle);
    width = CGRectGetWidth(waterMarkFrame);
    height = CGRectGetHeight(waterMarkFrame);
    
    float row = ceilf(height/vSpacing);
    float textWidth = width/3/cosf(angle);
    
    //计算文字的size
    CGSize waterMarkSize = [waterMark boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:waterMarkFontSize]} context:nil].size;
    
    //绘制水印
    CALayer *waterMarkLayer = [[CALayer alloc] init];
    [waterMarkLayer setFrame:waterMarkFrame];
    for (NSInteger i = 0; i < 3*row; i++) {
        float xOffset = (i/3)%2?0:(textWidth/2);
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        [textLayer setFontSize:waterMarkFontSize];
        [textLayer setFrame:CGRectMake(i%4*width/3+xOffset , i/3*vSpacing, textWidth, waterMarkSize.height)];
        if ((i/3==0?1:(i/3-1)/2%2) != i%2) {
            [textLayer setString:KD_APPNAME];
        }
        else {
            [textLayer setString:waterMark];
        }
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        [textLayer setForegroundColor:waterMarkColor];
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        [waterMarkLayer addSublayer:textLayer];
    }
    
    //水印画布旋转angle角度
    waterMarkLayer.transform = CATransform3DMakeRotation(-angle, 0, 0, 1);
    [self.layer addSublayer:waterMarkLayer];
    self.layer.masksToBounds = YES;
}

@end
