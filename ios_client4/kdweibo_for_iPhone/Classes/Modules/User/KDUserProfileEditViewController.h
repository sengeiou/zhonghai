//
//  KDUserProfileEditViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ProfileViewController2.h"

#import "KDImageOptimizationTask.h"

@class KDUser;
@class KDAvatarView;

@interface KDUserProfileEditViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, KDImageOptimizationTaskDelegate> {
@private
    KDUser *user_;
    NSString *username_;
    NSString *avatarPath_;
    
    UITableView *tableView_;
    KDAvatarView *avatarView_;
    
    NSUInteger requestsCount_;
    NSUInteger finishedCount_;
    NSUInteger validResponsesCount_;
    
    BOOL hasAvatarCompressionTask_;
    BOOL hasUnsaveChanges_;
    
    BOOL didDismiss_;
}

@property (nonatomic, retain) KDUser *user;

- (void) updateUsername:(NSString *)username;

@end

