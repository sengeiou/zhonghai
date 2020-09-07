//
//  KDSignInViewController+Feedback.h
//  kdweibo
//
//  Created by 张培增 on 2016/11/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController.h"
@class KDSignInRecord;

@interface KDSignInViewController (Feedback)

@property (nonatomic, assign) BOOL                              canShowHintView;

- (BOOL)showFeedbackWithRecord:(KDSignInRecord *)record;

@end
