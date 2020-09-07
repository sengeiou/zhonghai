//
//  KDExpressionPageBGView.m
//  kdweibo
//
//  Created by Darren Zheng on 7/8/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//
#import "KDExpressionPageBGView.h"

@interface KDExpressionPageBGView ()
@property (nonatomic, strong) NSTimer *tapTimer;
@end

@implementation KDExpressionPageBGView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(fireLongPress:)
               withObject:event
               afterDelay:0.5];
    NSTimer *tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 invocation:[NSInvocation new] repeats:NO];
    self.tapTimer = tapTimer;
    UITouch *touch = [event.allTouches anyObject];
    if (self.onTouchesBegan) {
        self.onTouchesBegan([touch locationInView:self]);
    }
}

- (void)fireLongPress:(UIEvent *)event {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.superview).scrollEnabled = NO;
    }
    UITouch *touch = [event.allTouches anyObject];
    //    NSLog(@"%f, %f", [touch locationInView:self].x, [touch locationInView:self].y);
    if (self.onTouchesLongPress) {
        self.onTouchesLongPress([touch locationInView:self]);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.superview).scrollEnabled = YES;
    }
    UITouch *touch = [event.allTouches anyObject];
    if ([self.tapTimer isValid]) {
        if (self.onTouchUpInside) {
            self.onTouchUpInside([touch locationInView:self]);
        }
    } else {
        if (self.onTouchesEnded) {
            self.onTouchesEnded([touch locationInView:self]);
        }
    }
    [self.tapTimer invalidate];
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.superview).scrollEnabled = YES;
    }
    UITouch *touch = [event.allTouches anyObject];
    //    if ([self.tapTimer isValid]) {
    //        if (self.onTouchUpInside) {
    //            self.onTouchUpInside([touch locationInView:self]);
    //        }
    //    } else {
    if (self.onTouchesEnded) {
        self.onTouchesEnded([touch locationInView:self]);
    }
    //    }
    [self.tapTimer invalidate];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if ([self.superview isKindOfClass:[UIScrollView class]]) {
//        if (!((UIScrollView *)self.superview).scrollEnabled) {
            //        NSLog(@"%f", event.timestamp);
            UITouch *touch = [event.allTouches anyObject];
            //        NSLog(@"%f, %f", [touch locationInView:self].x, [touch locationInView:self].y);
            if (self.onTouchesMoved) {
                self.onTouchesMoved([touch locationInView:self]);
            }
//        }
//        return;
//    }
}
@end
