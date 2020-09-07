//
//  ProfileViewController2.h
//  TwitterFon
//
//  Created by apple on 11-1-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDUser.h"
#import "KDUserBasicProfileView.h"
#import "PostViewController.h"

#import "KDRequestWrapper.h"
#import "KDManagerContext.h"
#import "MBProgressHUD.h"
#import "KDAnimationAvatarView.h"

extern NSString * const KDUserProfileDidChangeNotification;

@interface ProfileViewController2 : UIViewController<KDUnreadListener, KDRequestWrapperDelegate,UIAlertViewDelegate> {
    
    KDAnimationAvatarView *avatarView_;
    
    UILabel *userNameLabel_;
    UILabel *departmentLabel_;
    UIButton *editButton_;
    UILabel *jobTitleLabel_;
    
    KDUInt64 sizeOfDownloads;
    KDUInt64 sizeOfPictures;
    KDUInt64 sizeOfAudios;
    KDUInt64 sizeOfVideos;
    
    BOOL        didPresentAlertView_;
    MBProgressHUD *activityView_;
    
    struct {
        unsigned int hasRequests:1;
        unsigned int userProfileDidChange:1;
        unsigned int pausedCalculateCacheSize:1;
        unsigned int finishedCalculation:1;
        unsigned int isCheckingDraftCount:1;
    }profileControllerFlags_;
    
    NSUInteger downloadsCount_;
    
    
    NSMutableArray *menuItems_;
}

- (void)updateUserProfileInfo:(BOOL)reloadAvatar;

- (void)shouldUpdateQuickLinkMenuTitle;

@end
