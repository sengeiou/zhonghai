//
//  KDCheckBoxAlertView.h
//  kdweibo
//
//  Created by 王 松 on 13-9-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	kKDAlertAnimationDefault = 0,
	kKDAlertAnimationFade,
	kKDAlertAnimationFlipHorizontal,
	kKDAlertAnimationFlipVertical,
	kKDAlertAnimationTumble,
	kKDAlertAnimationSlideLeft,
	kKDAlertAnimationSlideRight
};
typedef NSInteger kKDAlertAnimation;

@interface KDCheckBoxAlertView2 : UIView

@property (nonatomic, assign) UIView *parentView;

@property (nonatomic, copy) NSString *errorMsg;

@property (nonatomic, assign) BOOL boxChecked;

typedef void (^kKDAlertViewBlock)(NSInteger buttonIndex, KDCheckBoxAlertView2 *alertView);

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) BOOL darkenBackground;
@property (nonatomic, assign) BOOL blkKDackground;

+ (KDCheckBoxAlertView2 *)dialogWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (void)setHandlerBlock:(kKDAlertViewBlock)block;

- (void)show;
- (void)showWithCompletionBlock:(void(^)())completion;
- (void)showWithAnimation:(kKDAlertAnimation)animation;
- (void)showWithAnimation:(kKDAlertAnimation)animation completionBlock:(void(^)())completion;

- (void)hide;
- (void)hideWithCompletionBlock:(void(^)())completion;
- (void)hideWithAnimation:(kKDAlertAnimation)animation;
- (void)hideWithAnimation:(kKDAlertAnimation)animation completionBlock:(void(^)())completion;

@end
