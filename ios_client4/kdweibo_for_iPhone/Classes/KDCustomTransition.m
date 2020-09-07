//
//  KDCustomTransition.m
//  kdweibo
//
//  Created by liwenbo on 16/5/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDCustomTransition.h"

@interface KDCustomTransition()
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) KDCustomTransitionType type;

@end


@implementation KDCustomTransition

+ (KDCustomTransition *)transitionWithType:(KDCustomTransitionType)type duration:(NSTimeInterval)duration {
    KDCustomTransition *transition = [[KDCustomTransition alloc] init];
    transition.duration = duration;
    transition.type = type;
    return transition;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    // 目前解决二维码 dismiss问题
    switch (self.type) {
        case KDCustomTransitionType_Dismiss_Transparent:
        {
            UIView *containerView = [transitionContext containerView];
            containerView.alpha = 0.f;
            [transitionContext completeTransition:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
