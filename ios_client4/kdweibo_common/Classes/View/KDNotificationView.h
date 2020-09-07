//
//  KDNotificationView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-03.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDCommon.h"

@class KDNotificationRenderView;

typedef enum {
    KDNotificationViewTypeNormal = 0x00,
    KDNotificationViewTypeInfo,
    KDNotificationViewTypeWarning,
    KDNotificationViewTypeError
}KDNotificationViewType;


@interface KDNotificationView : UIView {
@private
    KDNotificationRenderView *renderView_;
    KDNotificationViewType type_;
    
    UIEdgeInsets marginEdgeInsets_;
    CGSize contentSize_;
    
    NSTimeInterval visibleTimeInterval_;
    NSTimer *visibleTimer_;
    
    BOOL dismissing_;
}

@property(nonatomic, copy) NSString *message;
@property(nonatomic, retain, readonly) UILabel *messageLabel;

@property(nonatomic, assign) KDNotificationViewType type;
@property(nonatomic, assign) UIEdgeInsets marginEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic, assign) NSTimeInterval visibleTimeInterval;

- (id) initWithFrame:(CGRect)frame type:(KDNotificationViewType)type visibleTimeInterval:(NSTimeInterval)visibleTimeInterval;
+ (id) defaultMessageNotificationView;

- (void)setBackgroundImage:(UIImage *)backgroundImage;

- (void) showInView:(UIView *)inView message:(NSString *)message type:(KDNotificationViewType)type;
- (void) showInView:(UIView *)inView;

// The notification view frame is set base invoker.
- (void)showAsStaticInView:(UIView *)inView;

// generally speaking, don't call this method manually
- (void)dismiss;

@end



