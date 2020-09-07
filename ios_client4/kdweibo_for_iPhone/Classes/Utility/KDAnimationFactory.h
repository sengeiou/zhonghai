//
//  KDAnimationFactory.h
//  kdweibo
//
//  Created by shen kuikui on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDAnimationFactory : NSObject

+ (CAAnimation *)alertShowAnimationWithDuration:(NSTimeInterval)duration;

+ (CAAnimation *)alertDismissAnimationWithDuration:(NSTimeInterval)duration;

+ (CAAnimation *)windowFadeInAnimationWithDuration:(NSTimeInterval)duration;
+ (CAAnimation *)windowFadeOutAnimationWithDuration:(NSTimeInterval)duration;

@end
