//
//  KDAlertView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-07-01.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDCommon.h"

@protocol KDAlertViewDelegate;

typedef enum {
	KDAlertViewAnimationTypeBounce = 0x01,
	KDAlertViewAnimationTypeFadeInOut
}KDAlertViewAnimationType;


@interface KDAlertView : UIView <UIGestureRecognizerDelegate> {
@private
//	id<KDAlertViewDelegate> delegate_;
	KDAlertViewAnimationType animationType_;
	
	UIView *contentView_;
	UITapGestureRecognizer *tapGestureRecognizer_;
    
    UIDeviceOrientation orientation_;
	BOOL orientationEnabled_;
    
    id userInfo_;
}

@property (nonatomic, assign) id<KDAlertViewDelegate> delegate;
@property (nonatomic, assign) KDAlertViewAnimationType animationType;

@property (nonatomic, retain, readonly) UIView *contentView;
@property (nonatomic, assign) BOOL orientationEnabled;

@property (nonatomic, retain) id userInfo;


- (void) show:(BOOL)animated;
- (void) dismiss:(BOOL)animated;


// do nothing, just supply for sub class to override if need
- (void) didPresentAlterView;
- (void) didDismissAlterView;


- (void) tapGestureRecognizerEnable:(BOOL)enable;

@end


@protocol KDAlertViewDelegate <NSObject>

@optional

- (void) willPresentAlterView:(KDAlertView *)alertView;
- (void) didPresentAlterView:(KDAlertView *)alterView;
- (void) willDismissAlterView:(KDAlertView *)alterView;
- (void) didDismissAlterView:(KDAlertView *)alterView;

- (void) didTapOnAlterView:(KDAlertView *)alterView atPoint:(CGPoint)point;
- (void) didChangeOrientationForAlterView:(KDAlertView *)alterView;

@end

