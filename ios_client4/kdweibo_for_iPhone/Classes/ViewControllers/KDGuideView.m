//
//  KDGuideView.m
//  kdweibo
//
//  Created by Gil on 15/7/29.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDGuideView.h"

static CGFloat kGuideWidth = 320.0;
static CGFloat kGuideHeight = 320.0;

#pragma mark - KDGuideFirstView -

@interface KDGuideFirstView : KDGuideView
@property (strong, nonatomic) NSArray *imageViews;
@end

@implementation KDGuideFirstView

static NSArray *points = nil;

- (id)initWithIndex:(NSInteger)index {
	self = [super initWithIndex:index];

	if (self) {
		CGRect frame = self.frame;
		if (!points) {
			points = @[[NSValue valueWithCGPoint:CGPointMake(240.0, 48.0)], [NSValue valueWithCGPoint:CGPointMake(97.0, 92.0)], [NSValue valueWithCGPoint:CGPointMake(96.0, 206.0)], [NSValue valueWithCGPoint:CGPointMake(214.0, 225.0)], [NSValue valueWithCGPoint:CGPointMake(201.0, 99.0)], [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2)]];
		}
		NSArray *images = @[@"guide1_element_1", @"guide1_element_2", @"guide1_element_3", @"guide1_element_4", @"guide1_element_5", @"guide1_element_6"];
		NSMutableArray *imageViews = [NSMutableArray array];

		for (int i = 0; i < [images count]; i++) {
			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[i]]];
			imageView.center = [points[i] CGPointValue];
			imageView.hidden = YES;
			[imageViews addObject:imageView];
			[self addSubview:imageView];
		}

		self.imageViews = imageViews;
	}
	return self;
}

- (void)autoAnimation {
	[self.imageViews enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	    ((UIView *)obj).hidden = YES;
	}];
    
    NSValue *center = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];

	[self performSelector:@selector(guideViewAnimation:) withObject:@[@(5), center, points[5]] afterDelay:0.0];
	[self performSelector:@selector(guideViewAnimation:) withObject:@[@(4), center, points[4]] afterDelay:0.25];
	[self performSelector:@selector(guideViewAnimation:) withObject:@[@(3), center, points[3]] afterDelay:0.50];
	[self performSelector:@selector(guideViewAnimation:) withObject:@[@(2), center, points[2]] afterDelay:0.75];
	[self performSelector:@selector(guideViewAnimation:) withObject:@[@(1), center, points[1]] afterDelay:1.0];
	[self performSelector:@selector(guideViewAnimation:) withObject:@[@(0), center, points[0]] afterDelay:1.25];
}

- (void)reversedAutoAnimation {
    
    NSValue *center = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
    
    [self performSelector:@selector(guideViewReversedAnimation:) withObject:@[@(0), points[0], center] afterDelay:0.0];
    [self performSelector:@selector(guideViewReversedAnimation:) withObject:@[@(1), points[1], center] afterDelay:0.25];
    [self performSelector:@selector(guideViewReversedAnimation:) withObject:@[@(2), points[2], center] afterDelay:0.50];
    [self performSelector:@selector(guideViewReversedAnimation:) withObject:@[@(3), points[3], center] afterDelay:0.75];
    [self performSelector:@selector(guideViewReversedAnimation:) withObject:@[@(4), points[4], center] afterDelay:1.0];
    [self performSelector:@selector(guideViewReversedAnimation:) withObject:@[@(5), points[5], center] afterDelay:1.25];
}

- (void)guideViewAnimation:(NSArray *)array {
	[self guideViewAnimationWith:[((NSNumber *)array[0]) intValue] startPoint:[((NSValue *)array[1]) CGPointValue] endPoint:[((NSValue *)array[2]) CGPointValue] reversed:NO];
}

- (void)guideViewReversedAnimation:(NSArray *)array {
	[self guideViewAnimationWith:[((NSNumber *)array[0]) intValue] startPoint:[((NSValue *)array[1]) CGPointValue] endPoint:[((NSValue *)array[2]) CGPointValue] reversed:YES];
}

- (void)guideViewAnimationWith:(int)index
                    startPoint:(CGPoint)startPoint
                      endPoint:(CGPoint)endPoint
                      reversed:(BOOL)reversed {
	if (index > [self.imageViews count]) {
		return;
	}

	UIImageView *guideView = self.imageViews[index];
	guideView.hidden = NO;

	CAKeyframeAnimation *posAnim = nil;
	if (!CGPointEqualToPoint(endPoint, CGPointZero)) {
		//关键帧动画（位置）
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
		CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);

		posAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		posAnim.path = path;
		posAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	}

	//缩放动画
	CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    if (reversed) {
        scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)];
    }
    else {
        scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)];
        scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    }
	scaleAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

	//透明动画
	CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"alpha"];
    if (reversed) {
        opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
        opacityAnim.toValue = [NSNumber numberWithFloat:0.0];
    }
    else {
        opacityAnim.fromValue = [NSNumber numberWithFloat:0.0];
        opacityAnim.toValue = [NSNumber numberWithFloat:1.0];
    }
	opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

	//动画组
	CAAnimationGroup *animGroup = [CAAnimationGroup animation];
	if (posAnim) {
		animGroup.animations = @[posAnim, scaleAnim, opacityAnim];
	}
	else {
		animGroup.animations = @[scaleAnim, opacityAnim];
	}
	animGroup.duration = 0.75;
	[guideView.layer addAnimation:animGroup forKey:nil];
    
    if (reversed) {
        [self performSelector:@selector(guideViewHidden:) withObject:guideView afterDelay:0.75];
    }
}

- (void)guideViewHidden:(UIView *)guideView {
    guideView.hidden = YES;
}

@end

#pragma mark - KDGuideOtherView -

@interface KDGuideOtherView : KDGuideView
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *centerPoints;
@property (strong, nonatomic) NSArray *imageViews;
@property (strong, nonatomic) NSArray *animationIndexs;
@end

@implementation KDGuideOtherView

- (id)initWithIndex:(NSInteger)index {
	self = [super initWithIndex:index];

	if (self) {
		switch (index) {
			case 2:
			{
				self.images = @[@"guide3_element_1", @"guide3_element_2", @"guide3_element_4", @"guide3_element_5", @"guide3_element_6", @"guide3_element_7", @"guide3_element_8", @"guide3_element_3"];

				CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
				self.centerPoints = @[[NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:CGPointMake(250.0, 252.0)], [NSValue valueWithCGPoint:CGPointMake(240.0, 84.5)], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:CGPointMake(104.5, 93.0)], [NSValue valueWithCGPoint:CGPointMake(87.0, 212.0)], [NSValue valueWithCGPoint:center]];

				self.animationIndexs = @[@(7), @(1), @(0), @(2), @(3), @(4), @(5), @(6)];
			}
			break;

			case 3:
			{
				self.images = @[@"guide4_element_1", @"guide4_element_2", @"guide4_element_4", @"guide4_element_5", @"guide4_element_6", @"guide4_element_7", @"guide4_element_8", @"guide4_element_3"];

				CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
				self.centerPoints = @[[NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:CGPointMake(244.0, 69.0)], [NSValue valueWithCGPoint:CGPointMake(258.0, 252.5)], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:CGPointMake(100.0, 96.0)], [NSValue valueWithCGPoint:CGPointMake(64.0, 238.0)], [NSValue valueWithCGPoint:center]];

				self.animationIndexs = @[@(7), @(1), @(0), @(2), @(3), @(4), @(5), @(6)];
			}
			break;

			default:
			{
				self.images = @[@"guide2_element_1", @"guide2_element_2", @"guide2_element_3", @"guide2_element_4", @"guide2_element_5", @"guide2_element_6", @"guide2_element_7", @"guide2_element_8"];

				CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
				self.centerPoints = @[[NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:center], [NSValue valueWithCGPoint:CGPointMake(273.0, 106.5)], [NSValue valueWithCGPoint:CGPointMake(251.25, 259.5)], [NSValue valueWithCGPoint:CGPointMake(61.0, 220.5)], [NSValue valueWithCGPoint:CGPointMake(90.5, 76.5)]];

				self.animationIndexs = @[@(3), @(2), @(1), @(0), @(4), @(7), @(6), @(5)];
			}
			break;
		}

		NSMutableArray *imageViews = [NSMutableArray array];
		for (int i = 0; i < [self.images count]; i++) {
			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.images[i]]];
			imageView.center = [self.centerPoints[i] CGPointValue];
			imageView.alpha = .0;
			[imageViews addObject:imageView];
			[self addSubview:imageView];
		}
		self.imageViews = imageViews;
	}
	return self;
}

- (void)  animation:(CGFloat)fractional
    startFractional:(CGFloat)startFractional
      endFractional:(CGFloat)endFractional {
	if (fractional < startFractional || fractional > endFractional) {
		return;
	}

	//80帧占30帧
	CGFloat imageEndFractional = startFractional + (endFractional - startFractional) * (30.0 / 80.0);

	//电话图标先动
	UIImageView *phone = self.imageViews[[self.animationIndexs[0] intValue]];
	[self animationWithView:phone fractional:fractional startFractional:startFractional endFractional:imageEndFractional];

	//第一个小圈
	CGFloat increase = (endFractional - startFractional) * (5.0 / 80.0);
	UIImageView *circle1 = self.imageViews[[self.animationIndexs[1] intValue]];
	[self animationWithView:circle1 fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];

	//第二个小圈
	increase = (endFractional - startFractional) * (15.0 / 80.0);
	UIImageView *circle2 = self.imageViews[[self.animationIndexs[2] intValue]];
	[self animationWithView:circle2 fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];

	//第三个小圈
	increase = (endFractional - startFractional) * (25.0 / 80.0);
	UIImageView *circle3 = self.imageViews[[self.animationIndexs[3] intValue]];
	[self animationWithView:circle3 fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];

	//人物图标
	increase = (endFractional - startFractional) * (20.0 / 80.0);
	UIImageView *yellowPerson = self.imageViews[[self.animationIndexs[4] intValue]];
	[self animationWithView:yellowPerson fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];

	increase = (endFractional - startFractional) * (30.0 / 80.0);
	UIImageView *bluePerson = self.imageViews[[self.animationIndexs[5] intValue]];
	[self animationWithView:bluePerson fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];

	increase = (endFractional - startFractional) * (40.0 / 80.0);
	UIImageView *redPerson = self.imageViews[[self.animationIndexs[6] intValue]];
	[self animationWithView:redPerson fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];

	increase = (endFractional - startFractional) * (50.0 / 80.0);
	UIImageView *greenPerson = self.imageViews[[self.animationIndexs[7] intValue]];
	[self animationWithView:greenPerson fractional:fractional startFractional:(startFractional + increase) endFractional:(imageEndFractional + increase)];
}

- (void)animationWithView:(UIImageView *)imageView
               fractional:(CGFloat)fractional
          startFractional:(CGFloat)startFractional
            endFractional:(CGFloat)endFractional {
	CGFloat realFractional = fractional - startFractional;
	if (realFractional < 0) {
		return;
	}

	CGFloat totalFractional = endFractional - startFractional;

	CGFloat proportion1 = realFractional / totalFractional;
	if (proportion1 > 1) {
		proportion1 = 1;
	}
	imageView.transform = CGAffineTransformMakeScale(proportion1, proportion1);
	imageView.alpha = proportion1;
}

@end

#pragma mark - KDGuideView -

@interface KDGuideView ()
@property (assign, nonatomic) NSInteger index;
@end

@implementation KDGuideView

+ (instancetype)guideViewWithIndex:(NSInteger)index {
	switch (index) {
		case 1:
		case 2:
		case 3:
			return [[KDGuideOtherView alloc] initWithIndex:index];
			break;

		default:
			return [[KDGuideFirstView alloc] initWithIndex:index];
			break;
	}
}

- (instancetype)initWithIndex:(NSInteger)index {
	self = [super initWithFrame:CGRectMake(.0, .0, kGuideWidth, kGuideHeight)];
	if (self) {
		self.userInteractionEnabled = NO;
		self.index = index;
	}
	return self;
}

@end
