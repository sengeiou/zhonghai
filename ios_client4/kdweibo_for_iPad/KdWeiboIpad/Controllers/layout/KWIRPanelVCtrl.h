//
//  KWIRPanelVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/20/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
@protocol KWICardlikeVCtrl

- (void)shadowOn;
- (void)shadowOff;

@end

#pragma mark -

@interface KWIRPanelVCtrl : UIViewController

//+ (KWIRPanelVCtrl *)rpanelWithVCtrl:(UIViewController *)vctrl;
+ (KWIRPanelVCtrl *)rpanelWithFrame:(CGRect)frame rootVCtrl:(UIViewController *)vctrl animated:(BOOL)animated;

//+ (void)setFrame:(CGRect)frame;

- (void)pushViewControllerToRPanelVCtrol:(UIViewController *)vctrl animated:(BOOL)animated;
//- (void)back;
//- (void)forward;
/// enclose exit animation and memory management codes
- (void)remove;

- (BOOL)isAnimating;

- (UIViewController *)rootCardVCtrl;
- (UIViewController *)topCardVCtrl;
- (BOOL)containsViewController:(UIViewController *)vc;
- (void)removePage:(UIViewController *)toRemove animation:(BOOL)animaition;
@end
