//
//  KDAnimateGuidViewController.h
//  kdweibo
//
//  Created by gordon_wu on 13-12-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTTTJazzHands.h"

@protocol KDAnimateGuidViewDelegate;

@interface KDAnimateGuidViewController : IFTTTAnimatedScrollViewController <UIScrollViewDelegate>

@property (nonatomic, retain) id<KDAnimateGuidViewDelegate> delegate;

+ (BOOL)shouldShowGuideView;

- (id)initWithInApp:(BOOL)isInApp;

@end

@protocol KDAnimateGuidViewDelegate <NSObject>

- (void)animateGuidView:(KDAnimateGuidViewController *)animateGuidView scrollToLast:(BOOL)flag;

@end
