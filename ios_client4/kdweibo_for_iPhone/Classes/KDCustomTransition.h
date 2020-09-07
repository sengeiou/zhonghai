//
//  KDCustomTransition.h
//  kdweibo
//
//  Created by liwenbo on 16/5/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//  转场动画

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    KDCustomTransitionType_None,
    KDCustomTransitionType_Dismiss_Transparent,
    KDCustomTransitionType_Other,
} KDCustomTransitionType;


@interface KDCustomTransition : NSObject<UIViewControllerAnimatedTransitioning>

+ (KDCustomTransition *)transitionWithType:(KDCustomTransitionType)type
                                  duration:(NSTimeInterval)duration;


@end
