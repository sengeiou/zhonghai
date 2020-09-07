//
//  KDAnimationFactory.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAnimationFactory.h"

@implementation KDAnimationFactory

+ (CAAnimation *)alertShowAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation1.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.26, 1.26, 1)];
    animation1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)];
    animation1.duration = duration;
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.fromValue = @(0.0f);
    animation2.toValue = @(1.0f);
    animation2.duration = duration;
    animation2.fillMode = kCAFillModeBoth;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation1, animation2];
    group.fillMode = kCAFillModeBoth;
    group.duration = duration;
    group.removedOnCompletion = NO;
    
    return group;
}

+ (CAAnimation *)alertDismissAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation1.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)];
    animation1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.74, 0.74, 1)];
    animation1.duration = duration;
    animation1.fillMode = kCAFillModeBoth;
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.fromValue = @(1.0f);
    animation2.toValue = @(0.0f);
    animation2.duration = duration;
    animation2.fillMode = kCAFillModeBoth;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation1, animation2];
    group.fillMode = kCAFillModeBoth;
    group.removedOnCompletion = NO;

    return group;
}

+ (CAAnimation *)windowFadeInAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.0f);
    animation.toValue = @(0.6f);
    animation.duration = duration;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    animation.removedOnCompletion = NO;
    
    return animation;
}

+ (CAAnimation *)windowFadeOutAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.6f);
    animation.toValue = @(0.0f);
    animation.duration = duration;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    animation.removedOnCompletion = NO;
    
    return animation;
}

@end
