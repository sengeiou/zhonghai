//
//  KDSignInViewController+Feedback.m
//  kdweibo
//
//  Created by 张培增 on 2016/11/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController+Feedback.h"
#import <objc/runtime.h>
#import "KDSignInRecord.h"
#import "KDSignInFeedbackHintView.h"
#import "KDSignInFeedbackViewController.h"
static NSString *feedbackViewKey;
static NSString *canShowHintViewKey;

@interface KDSignInViewController ()

@property (nonatomic, strong) KDSignInFeedbackHintView          *feedbackView;

@end

@implementation KDSignInViewController (Feedback)

#pragma mark - setter & getter -
- (void)setFeedbackView:(KDSignInFeedbackHintView *)feedbackView {
    objc_setAssociatedObject(self, &feedbackViewKey, feedbackView, OBJC_ASSOCIATION_RETAIN);
}

- (KDSignInFeedbackHintView *)feedbackView {
    return objc_getAssociatedObject(self, &feedbackViewKey);
}

- (void)setCanShowHintView:(BOOL)canShowHintView {
    objc_setAssociatedObject(self, &canShowHintViewKey, @(canShowHintView), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)canShowHintView {
    NSNumber *number = objc_getAssociatedObject(self, &canShowHintViewKey);
    if (!number) return NO;
    return [number boolValue];
}

#pragma mark - method -
- (BOOL)showFeedbackWithRecord:(KDSignInRecord *)record {
    
    if (record.exceptionType && ([record.exceptionType isEqualToString:@"LATE"] || [record.exceptionType isEqualToString:@"EARLYLEAVE"])) {
        
        __weak KDSignInViewController *weakSelf = self;
        
        if (!self.feedbackView) {
            self.feedbackView = [[KDSignInFeedbackHintView alloc] initWithSignInRecord:record hintViewType:KDSignInFeedbackHint_signInSuccess];
        }
        else {
            self.feedbackView.record = record;
        }
        
        self.feedbackView.buttonDidClickBlock = ^(NSInteger index) {
            if (index == 1) {
                if (record.hasLeader == 0) {
                    KDSignInFeedbackViewController *feedbackViewController = [[KDSignInFeedbackViewController alloc] init];
                    feedbackViewController.signInRecord = record;
                    [weakSelf.navigationController pushViewController:feedbackViewController animated:YES];
                }
                else if (record.hasLeader == 1) {
                    KDSignInFeedbackHintView *hintView = [[KDSignInFeedbackHintView alloc] initWithSignInRecord:nil hintViewType:KDSignInFeedbackHint_cannotFeedback];
                    [hintView showHintView];
                }
                else if (record.hasLeader == 2) {
                    KDSignInFeedbackHintView *hintView = [[KDSignInFeedbackHintView alloc] initWithSignInRecord:nil hintViewType:KDSignInFeedbackHint_exception];
                    [hintView showHintView];
                }
            }
        };
        
        if (self.canShowHintView) {
            [self.feedbackView showHintView];
        }
        
        return YES;
    }
    
    return NO;
}

@end
