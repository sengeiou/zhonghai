//
//  KDGestureEnterViewController.h
//  DynamicCode
//
//  Created by 曾昭英 on 13-11-29.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPLockView.h"
#import "KDLockControl.h"
#import "UIImageView+WebCache.h"
//#import "KDAnimationAvatarView.h"
@interface KDGestureEnterViewController : UIViewController <PPLockViewDelegate, UIAlertViewDelegate> {
    PPLockView *_lockView;
}
@property (nonatomic, strong) UIImageView *portraitIV;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UIButton *forgetPwL;
@property (nonatomic, strong) UIView *lockViewContainer;

@end
