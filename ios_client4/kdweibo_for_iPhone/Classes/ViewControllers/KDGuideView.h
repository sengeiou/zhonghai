//
//  KDGuideView.h
//  kdweibo
//
//  Created by Gil on 15/7/29.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDGuideViewAnimation
@optional

- (void)animation:(CGFloat)fractional
  startFractional:(CGFloat)startFractional
    endFractional:(CGFloat)endFractional;

- (void)autoAnimation;
- (void)reversedAutoAnimation;

@end

@interface KDGuideView : UIView <KDGuideViewAnimation>

@property (assign, nonatomic, readonly) NSInteger index;

+ (instancetype)guideViewWithIndex:(NSInteger)index;
- (instancetype)initWithIndex:(NSInteger)index;

@end
