//
//  KDSignInFeedbackHintView.h
//  kdweibo
//
//  Created by 张培增 on 2016/11/1.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSignInRecord.h"

typedef void(^KDSignInFeedbackHintViewButtonDidClickBlock)(NSInteger index);
typedef NS_ENUM(NSInteger, KDSignInFeedbackHintType) {
    KDSignInFeedbackHint_signInSuccess,
    KDSignInFeedbackHint_cannotFeedback,
    KDSignInFeedbackHint_exception
};

@interface KDSignInFeedbackHintView : UIView

@property (nonatomic, strong) KDSignInRecord *record;
@property (nonatomic, assign) KDSignInFeedbackHintType signInFeedbackHintType;
@property (nonatomic, strong) KDSignInFeedbackHintViewButtonDidClickBlock buttonDidClickBlock;


- (instancetype)initWithSignInRecord:(KDSignInRecord *)record hintViewType:(KDSignInFeedbackHintType)type;

- (void)showHintView;

@end
