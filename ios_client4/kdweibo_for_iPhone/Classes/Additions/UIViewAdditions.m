//
//  UIViewAdditions.m
//  Weibo
//
//  Created by junmin liu on 10-9-29.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "UIViewAdditions.h"


@implementation UIView (Addtions)



///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
	return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
	return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
	return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
	self.center = CGPointMake(centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
	return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
	self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
	return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
	return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
//	CGRect frame = self.frame;
//	frame.size.height = height;
//	self.frame = frame;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenX {
	CGFloat x = 0;
	for (UIView* view = self; view; view = view.superview) {
		x += view.left;
	}
	return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenY {
	CGFloat y = 0;
	for (UIView* view = self; view; view = view.superview) {
		y += view.top;
	}
	return y;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewX {
	CGFloat x = 0;
	for (UIView* view = self; view; view = view.superview) {
		x += view.left;
		
		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView* scrollView = (UIScrollView*)view;
			x -= scrollView.contentOffset.x;
		}
	}
	
	return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewY {
	CGFloat y = 0;
	for (UIView* view = self; view; view = view.superview) {
		y += view.top;
		
		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView* scrollView = (UIScrollView*)view;
			y -= scrollView.contentOffset.y;
		}
	}
	return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)screenFrame {
	return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
	return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
	return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)descendantOrSelfWithClass:(Class)cls {
	if ([self isKindOfClass:cls])
		return self;
	
	for (UIView* child in self.subviews) {
		UIView* it = [child descendantOrSelfWithClass:cls];
		if (it)
			return it;
	}
	
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)ancestorOrSelfWithClass:(Class)cls {
	if ([self isKindOfClass:cls]) {
		return self;
	} else if (self.superview) {
		return [self.superview ancestorOrSelfWithClass:cls];
	} else {
		return nil;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
	while (self.subviews.count) {
		UIView* child = self.subviews.lastObject;
		[child removeFromSuperview];
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIView *)strokeRectangleBgView
{
    UIView *backgroundView_ = [[UIView alloc] init];
//    backgroundView_.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [backgroundView_ sizeToFit];
    
    backgroundView_.backgroundColor = MESSAGE_CT_COLOR;
    
    UILabel *top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backgroundView_.frame.size.width, 0.5)];
    top.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    top.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:top];

    
    
    UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(backgroundView_.frame)-1, backgroundView_.frame.size.width, 1)];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    bottom.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:bottom];

    
    
    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, CGRectGetHeight(backgroundView_.frame))];
    left.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    left.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:left];
//    [left release];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundView_.frame)-1.0, 0, 1.0, CGRectGetHeight(backgroundView_.frame))];
    right.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    right.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:right];
//    [right release];
    
    return backgroundView_ ;//autorelease];
}

+ (UIView *)strokeCellSeparatorBgView
{
    UIView *backgroundView_ = [[UIView alloc] init];
    //    backgroundView_.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [backgroundView_ sizeToFit];
    
    backgroundView_.backgroundColor = MESSAGE_CT_COLOR;
    
    UILabel *top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backgroundView_.frame.size.width, 0.5)];
    top.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    top.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:top];
//    [top release];
    
    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, CGRectGetHeight(backgroundView_.frame))];
    left.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    left.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:left];
//    [left release];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundView_.frame)-1, 0, 1, CGRectGetHeight(backgroundView_.frame))];
    right.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    right.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:right];
//    [right release];
    
    return backgroundView_;// autorelease];
    
}

+ (UIView *)strokeTypeSeparatorBgView
{
    UIView *backgroundView_ = [[UIView alloc] init];
    //    backgroundView_.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [backgroundView_ sizeToFit];
    
    backgroundView_.backgroundColor = MESSAGE_CT_COLOR;
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(backgroundView_.frame)-1.0f, backgroundView_.frame.size.width, 1.0f)];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    bottom.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:bottom];
//    [bottom release];
    
    
    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, CGRectGetHeight(backgroundView_.frame))];
    left.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    left.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:left];
//    [left release];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundView_.frame)-1.0, 0, 1.0, CGRectGetHeight(backgroundView_.frame))];
    right.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    right.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:right];
//    [right release];
    
    return backgroundView_ ;//autorelease];
}

+ (UIView *)noTopAndBottomView {
    UIView *backgroundView_ = [[UIView alloc] init];
    //    backgroundView_.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [backgroundView_ sizeToFit];
    
    backgroundView_.backgroundColor = MESSAGE_CT_COLOR;
    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, CGRectGetHeight(backgroundView_.frame))];
    left.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    left.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:left];
//    [left release];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundView_.frame)-1.0, 0, 1.0, CGRectGetHeight(backgroundView_.frame))];
    right.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    right.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:right];
//    [right release];
    
    return backgroundView_;// autorelease];
}

//宽度  顶:0.5 左:0.5  底:1 右:0.5
+ (UIView *)borderView {
    UIView *backgroundView_ = [[UIView alloc] init];
    //    backgroundView_.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [backgroundView_ sizeToFit];
    
    backgroundView_.backgroundColor = MESSAGE_CT_COLOR;
    
    UILabel *top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backgroundView_.frame.size.width, 0.5)];
    top.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    top.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:top];
//    [top release];
    
    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, CGRectGetHeight(backgroundView_.frame))];
    left.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    left.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:left];
//    [left release];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundView_.frame)-1.0, 0, 1.0, CGRectGetHeight(backgroundView_.frame))];
    right.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    right.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:right];
//    [right release];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(backgroundView_.frame)-1.0f, backgroundView_.frame.size.width, 1.0f)];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    bottom.backgroundColor = MESSAGE_LINE_COLOR;
    [backgroundView_ addSubview:bottom];
//    [bottom release];
    
    return backgroundView_ ;//autorelease];
}


-(CAGradientLayer *)gradientLayer
{
    return  objc_getAssociatedObject(self, @"gradientLayer");
}

-(void)setGradientLayer:(CAGradientLayer *)gradientLayer
{
    objc_setAssociatedObject(self, @"gradientLayer", gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setGradientFromColor:(UIColor *)colorStart toColor:(UIColor *)colorEnd
{
    if(self.gradientLayer)
        [self.gradientLayer removeFromSuperlayer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)colorStart.CGColor, (__bridge id)colorEnd.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    self.gradientLayer = gradientLayer;
}
@end
