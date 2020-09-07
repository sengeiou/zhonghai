//
//  KDDropDownView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDDropDownViewDelegate;

@interface KDDropDownView : UIView <UIGestureRecognizerDelegate> {
 @private
//    id<KDDropDownViewDelegate> delegate_; 
    
    UIImageView *backgroundImageView_;
    UIView *contentView_;
    
    UIView *maskView_;
    BOOL dismissingMaskView_;
    
    BOOL showInKeyWindow_; // show in key window
}

@property(nonatomic, assign) id<KDDropDownViewDelegate> delegate;

@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain, readonly) UIView *contentView;

@property(nonatomic, assign, readonly) BOOL showInKeyWindow;

- (void)setBackgroundImage:(UIImage *)backgroundImage;

// show drop down view in key window view, 
// Set hasMaskView is YES to make drop down view exclusive event in current window
- (void)showInWindow:(UIWindow *)window atPoint:(CGPoint)anchorPoint hasMaskView:(BOOL)hasMaskView animated:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

// The sub-classes can override it
- (void)dropDownViewWillPresent;
- (void)dropDownViewWillDismiss;

@end


@protocol KDDropDownViewDelegate <NSObject>
@optional

// These methods only works on call showInWindow:atPoint:hasMaskView:animated: and dismiss: method
// If present and dismisss current drop down view then the didPresentDropDownView: / didDismissDropDownView:
// will send to delegate
- (void)willPresentDropDownView:(KDDropDownView *)dropDownView;
- (void)didPresentDropDownView:(KDDropDownView *)dropDownView;
- (void)willDismissDropDownView:(KDDropDownView *)dropDownView;
- (void)didDismissDropDownView:(KDDropDownView *)dropDownView;

@end


