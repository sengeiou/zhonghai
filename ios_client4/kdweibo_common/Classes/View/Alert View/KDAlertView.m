//
//  KDAlertView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-07-01.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import "KDAlertView.h"

#define KD_ALERT_VIEW_ANIMATION_DURATION	0.3

@implementation KDAlertView

@synthesize delegate=delegate_;
@synthesize animationType=animationType_;

@synthesize contentView=contentView_;
@synthesize orientationEnabled=orientationEnabled_;

@synthesize userInfo=userInfo_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		delegate_ = nil;
		animationType_ = KDAlertViewAnimationTypeFadeInOut;
		userInfo_ = nil;
        
		orientation_ = UIDeviceOrientationUnknown;
        orientationEnabled_ = YES;
		
		self.autoresizesSubviews = YES;
		self.backgroundColor = [UIColor clearColor];
	//	self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		
		contentView_ = [[UIView alloc] initWithFrame:CGRectZero];
		contentView_.backgroundColor = [UIColor clearColor];
        
        contentView_.clipsToBounds = NO;
	//	contentView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self addSubview:contentView_];
		
		// register device orientation change notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    contentView_.frame = self.bounds;
}

- (BOOL) shouldRotateToOrientation:(UIDeviceOrientation)orientation {
    if (orientation == orientation_) {
        return NO;
    } else {
        return orientation == UIDeviceOrientationLandscapeLeft
        || orientation == UIDeviceOrientationLandscapeRight
        || orientation == UIDeviceOrientationPortrait
        || orientation == UIDeviceOrientationPortraitUpsideDown;
    }
}

- (CGAffineTransform) transformForOrientation {
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	CGAffineTransform tranform;
	if(UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation){
		tranform = CGAffineTransformMakeRotation(-M_PI);
		
	}else if(UIInterfaceOrientationLandscapeLeft == interfaceOrientation){
		tranform = CGAffineTransformMakeRotation(M_PI*1.5);
		
	}else if(UIInterfaceOrientationLandscapeRight == interfaceOrientation){
		tranform = CGAffineTransformMakeRotation(M_PI/2);
		
	}else {
		tranform = CGAffineTransformIdentity;	
	}
    
	return tranform;
}

- (void) sizeToFitOrientation:(BOOL)needTransform {
	if(needTransform){
		self.transform = CGAffineTransformIdentity;
	}
    
	CGRect rect = [UIScreen mainScreen].applicationFrame;
	CGFloat width = rect.size.width;
	CGFloat height = rect.size.height;
    
    CGPoint center = CGPointMake(rect.origin.x + width*0.5, rect.origin.y + height*0.5);
	
	orientation_ = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
	if(UIInterfaceOrientationIsLandscape(orientation_)){
		CGFloat temp = width;
		width = height;
		height = temp;
	}
	
	self.frame = CGRectMake(0.0, 0.0, width, height);
	self.center = center;
	
	if(needTransform){
		self.transform = [self transformForOrientation];
	}
}

- (void) deviceOrientationDidChange:(NSNotification *)notification {
    if(orientationEnabled_){
        UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
        if([self shouldRotateToOrientation:orientation]){
            [UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION 
                             animations:^{
                                 [self sizeToFitOrientation:YES];
                             }];
            
            if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didChangeOrientationForAlterView:)]){
                [delegate_ didChangeOrientationForAlterView:self];
            }
        }
    }
}

// do nothing, just supply for sub class to override if need
- (void) didPresentAlterView {
}

- (void) didDismissAlterView {
}


- (void) didPutAlterViewOnStage {
	if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didPresentAlterView:)]){
		[delegate_ didPresentAlterView:self];
	}
    
    [self didPresentAlterView];
}

- (void) removeAlterViewFromStage {
    if(self.superview != nil)
        [self removeFromSuperview];
	
	if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didDismissAlterView:)]){
		[delegate_ didDismissAlterView:self];
	}
    
    [self didDismissAlterView];
}

- (void) bounceShowAnimation {
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
	
	[UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION 
					 animations:^{
						 self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
					 } 
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION/2.0 
										  animations:^{
											  self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
										  } 
										  completion:^(BOOL finished){
											  [UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION/2.0 
															   animations:^{
																   self.transform = [self transformForOrientation];
															   } 
															   completion:^(BOOL finished){
																   [self didPutAlterViewOnStage];
															   }];
										  }];
						 
					 }];
}

- (void) bounceDismissAnimation {
	[UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION 
					 animations:^{
						 self.alpha = 0.0;
						 self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
					 } 
					 completion:^(BOOL finished){
						 [self removeAlterViewFromStage];
					 }];
}

- (void) fadeInOutShowAnimation {
	self.alpha = 0.0;
	[UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION 
					 animations:^{
						 self.alpha = 1.0;
                     } 
					 completion:^(BOOL finished){
						 [self didPutAlterViewOnStage];
					 }];
}

- (void) fadeInOutDismissAnimation {
	[UIView animateWithDuration:KD_ALERT_VIEW_ANIMATION_DURATION 
					 animations:^{
						 self.alpha = 0.0;
					 } 
					 completion:^(BOOL finished){
						 [self removeAlterViewFromStage];
					 }];
}

- (void) show:(BOOL)animated {
	[self sizeToFitOrientation:NO];
	if(delegate_ != nil && [delegate_ respondsToSelector:@selector(willPresentAlterView:)]){
		[delegate_ willPresentAlterView:self];
	}
	
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if(window == nil){
		window = [[UIApplication sharedApplication].windows objectAtIndex:0x00];
	}
	
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //   [[window.subviews objectAtIndex:0x00] addSubview:self];
	[window addSubview:self];
	
    self.transform = [self transformForOrientation];
    
	if(animated){
		if(KDAlertViewAnimationTypeFadeInOut == animationType_){
			[self fadeInOutShowAnimation];
			
		}else {
			[self bounceShowAnimation];	
		}
		
	}else {
		[self didPutAlterViewOnStage];
	}
    
}

- (void) dismiss:(BOOL)animated {
	if(delegate_ != nil && [delegate_ respondsToSelector:@selector(willDismissAlterView:)]){
		[delegate_ willDismissAlterView:self];
	}
	
	if(animated){
		if(KDAlertViewAnimationTypeFadeInOut == animationType_){
			[self fadeInOutDismissAnimation];
			
		}else {
			[self bounceDismissAnimation];
		}
		
	}else {
		[self removeAlterViewFromStage];
	}
}

- (void) tapGestureRecognizerEnable:(BOOL)enable {
	if(enable){
		if(tapGestureRecognizer_ == nil){
			tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
			tapGestureRecognizer_.delegate = self;
			tapGestureRecognizer_.numberOfTapsRequired = 1;
			
			[self addGestureRecognizer:tapGestureRecognizer_];
		}
		
	}else {
		if(tapGestureRecognizer_ != nil){
			[self removeGestureRecognizer:tapGestureRecognizer_];
//			[tapGestureRecognizer_ release];
			tapGestureRecognizer_ = nil;
		}	
	}
}

- (void) didTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateRecognized){
        if(delegate_ != nil && [delegate_ respondsToSelector:@selector(didTapOnAlterView:atPoint:)]){
            CGPoint point = [tapGestureRecognizer locationInView:self];
            [delegate_ didTapOnAlterView:self atPoint:point];
        }
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	
	delegate_ = nil;
    
    //KD_RELEASE_SAFELY(userInfo_);
    
    //KD_RELEASE_SAFELY(tapGestureRecognizer_);
    //KD_RELEASE_SAFELY(contentView_);
    
    //[super dealloc];
}


@end
