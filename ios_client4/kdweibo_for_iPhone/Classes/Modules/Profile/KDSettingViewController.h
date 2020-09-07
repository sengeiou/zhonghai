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
//#import "KDAnimationAvatarView.h"

extern NSString * const KDUserProfileDidChangeNotification;
UIKIT_EXTERN NSString * const KDQuitCompanyFinishedNotification;

@interface KDSettingViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, KDRequestWrapperDelegate> {
    
    UITableView *userTableView_;
    
    KDUInt64 sizeOfDownloads;
    KDUInt64 sizeOfPictures;
    KDUInt64 sizeOfAudios;
    KDUInt64 sizeOfVideos;
    KDUInt64 sizeOfXTAudios;
    KDUInt64 sizeOfSDWebImages;
    KDUInt64 sizeOfDownloadsFile;
    
    UIAlertView *alertView_; // weak reference, alert view for remove cache
    BOOL        didPresentAlertView_;
    MBProgressHUD *activityView_;
    
    struct {
        unsigned int hasRequests:1;
        unsigned int userProfileDidChange:1;
        unsigned int pausedCalculateCacheSize:1;
        unsigned int finishedCalculation:1;
    }profileControllerFlags_;
    
    NSUInteger downloadsCount_;
    
    BOOL hasNewVersion_;   
    
    NSMutableArray *menuItems_;
}

@property (nonatomic, retain) UITableView *userTableView;

@end
