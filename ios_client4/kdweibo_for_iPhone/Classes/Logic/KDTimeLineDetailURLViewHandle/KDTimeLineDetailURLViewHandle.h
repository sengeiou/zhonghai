//
//  KDTimeLineDetailURLViewHandle.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSURLView.h"
#import "KDUsersURLView.h"
#import "KDWeiboAppDelegate.h"
#import "TrendStatusViewController.h"
#import "KDUser.h"
#import "ProfileViewController.h"
@protocol KDTimeLineDetailURLViewHandleDelegate;
@interface KDTimeLineDetailURLViewHandle : NSObject<DSURLViewDelegate>
@property(assign,nonatomic)id<KDTimeLineDetailURLViewHandleDelegate>delegate;

@end
@protocol KDTimeLineDetailURLViewHandleDelegate
@optional
- (void)kDTimeLineDetailURLViewHandle:(KDTimeLineDetailURLViewHandle *)KDTimeLineDetailURLViewHandle viewTouchesBegan:(DSURLView*)view;

- (void)kDTimeLineDetailURLViewHandle:(KDTimeLineDetailURLViewHandle *)KDTimeLineDetailURLViewHandle 
                     viewTouchesEnded:(DSURLView*)view;

- (void)kDTimeLineDetailURLViewHandle:(KDTimeLineDetailURLViewHandle *)KDTimeLineDetailURLViewHandle viewTouchesMove:(DSURLView*)view;

- (void)kDTimeLineDetailURLViewHandle:(KDTimeLineDetailURLViewHandle *)KDTimeLineDetailURLViewHandle 
                     viewTouchesCancle:(DSURLView*)view;
@end