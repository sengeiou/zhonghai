//
//  NJKWebViewProgressView+YZJ.m
//  kdweibo
//
//  Created by Gil on 15/11/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "NJKWebViewProgressView+YZJ.h"

@implementation NJKWebViewProgressView (YZJ)

- (void)setProgress:(float)progress animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    
    BOOL isGrowing = progress > 0.0;
    [UIView animateWithDuration:(isGrowing && animated) ? self.barAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.progressBarView.frame;
        frame.size.width = progress * self.bounds.size.width;
        self.progressBarView.frame = frame;
    } completion:completion];
    
    if (progress >= 1.0) {
        [UIView animateWithDuration:animated ? self.fadeAnimationDuration : 0.0 delay:self.fadeOutDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressBarView.alpha = 0.0;
        } completion:^(BOOL completed){
            CGRect frame = self.progressBarView.frame;
            frame.size.width = 0;
            self.progressBarView.frame = frame;
        }];
    }
    else {
        [UIView animateWithDuration:animated ? self.fadeAnimationDuration : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressBarView.alpha = 1.0;
        } completion:nil];
    }
}

@end
