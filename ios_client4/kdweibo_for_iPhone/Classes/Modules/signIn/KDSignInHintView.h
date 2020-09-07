//
//  KDSignInHintView.h
//  kdweibo
//
//  Created by lichao_liu on 7/17/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KDSignInHintType) {
    KDSignInHintType_share,
    KDSignInHintType_signInPoint
};

@interface KDSignInHintView : UIView
@property (nonatomic, assign) KDSignInHintType signInHintType;
- (instancetype)initWithFrame:(CGRect)frame;
@end
