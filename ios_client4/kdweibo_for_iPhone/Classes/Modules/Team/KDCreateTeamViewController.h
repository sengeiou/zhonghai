//
//  KDCreateTeamViewController.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTeamNameInputViewController.h"

UIKIT_EXTERN NSString * const KDCreateTeamFinishedNotification;

typedef NS_ENUM(NSInteger, KDCreateTeamFromType) {
    KDCreateTeamFromTypeUndefine = 0,
    KDCreateTeamFromTypeUnLogin,
    KDCreateTeamFromTypeDidLogin
};

@interface KDCreateTeamViewController : UIViewController

@property (nonatomic, assign) BOOL didSignIn;
@property (nonatomic, assign) KDCreateTeamFromType fromType;

@property (nonatomic, assign) id<XTCompanyDelegate> delegate;

@property (nonatomic, assign) BOOL bHideBackButton;

@end
