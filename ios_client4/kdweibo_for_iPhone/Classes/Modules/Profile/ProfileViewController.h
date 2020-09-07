//
//  UserDetailViewController.h
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KDUser.h"
#import "KDUserBasicProfileView.h"

#import "RefreshTableFootView.h"
#import "NetworkUserController.h"
#import "BlogViewController.h"
#import "KDTrendsViewController.h"
#import "KDRequestWrapper.h"
#import "MBProgressHUD.h"
#import "KDABPersonDetailsViewController.h"
#import "KDAnimationAvatarView.h"
#import "KDMenuView.h"

@interface ProfileViewController : UIViewController<KDMenuViewDelegate, KDRequestWrapperDelegate>
{
    KDUser*           user;
    
    KDAnimationAvatarView *avatarView_;
    UILabel          *userNameLabel_;
    UILabel          *departmentLabel_;
    UILabel          *jobLabel_;
    
    
    BOOL            detailLoaded;
    BOOL            followingLoaded;   	  
	BOOL            following;
    
    NetworkUserController *friendController;
    NetworkUserController *fanController;
    BlogViewController   *blogController;
    KDTrendsViewController *trendsController;
    KDABPersonDetailsViewController *detailController;
    
    
	BOOL			ownInfo;
	int             heightDesciption;
	UIButton        *friendButton;
    UIButton        *dmButton;
	
	UIActivityIndicatorView *loadView;
    UIView *  headerView;
    
    NSMutableArray *tabItems_;
    UILabel *currentTabItemInfoLabel_;
    int _segmentIndex;
    
    RefreshTableFootView *refreshFootView_friend;
    BOOL _reloading_friend;
    
    MBProgressHUD *activityView_;
    
    struct {
        unsigned int initWithUserName:1;
        unsigned int initWithUserId:1;
    }_viewFlags;
}

@property(nonatomic,retain)KDUser *user;

@property(nonatomic,retain)NetworkUserController *friendController;
@property(nonatomic,retain)NetworkUserController *fanController;
@property(nonatomic,retain)BlogViewController   *blogController;
@property(nonatomic,retain)KDTrendsViewController *trendsController;
@property(nonatomic, retain)KDABPersonDetailsViewController *detailController;


-(void)freshFollowButton;
-(id)initWithUser:(KDUser*)user;
- (id)initWithUser:(KDUser *)user andSelectedIndex:(NSUInteger)index;

- (id)initWithUserId:(NSString *)userId;
- (id)initWithUserId:(NSString *)userId andSelectedIndex:(NSUInteger)index;
- (id)initWithUserName:(NSString *)userName;
- (id)initWithUserName:(NSString *)userName andSelectedIndex:(NSUInteger)index;

-(NSString *)getUserNumber:(int)segmentIndex;
-(void)applyAttributes;
@end
