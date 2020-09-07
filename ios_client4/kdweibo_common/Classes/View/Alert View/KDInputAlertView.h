//
//  KDInputAlertView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "KDAlertView.h"

#import "HPGrowingTextView.h"


////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDefaultInputCenterView class


@interface KDDefaultInputCenterView : UIView {
@private
    UIImageView *backgroundImageView_;
    HPGrowingTextView *textView_;
}

@property (nonatomic, retain, readonly) HPGrowingTextView *textView;

@end


////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDInputAlertView class

@interface KDInputAlertView : KDAlertView {
@private
    UIView *topView_;
    UIView *leftView_;
    UIView *centerView_;
    UIView *rightView_;
    
    UIImageView *backgroundView_;
}

@property(nonatomic, retain) UIView *topView;
@property(nonatomic, retain) UIView *leftView;
@property(nonatomic, retain, readonly) UIView *centerView;
@property(nonatomic, retain) UIView *rightView;

@property(nonatomic, retain) UIImageView *backgroundView;

@end



