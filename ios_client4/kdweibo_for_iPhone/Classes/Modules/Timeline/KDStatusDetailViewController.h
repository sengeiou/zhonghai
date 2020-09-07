//
//  KDStatusDetailViewController.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-14.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDRefreshTableView.h"
#import "KDStatusDetailView.h"
#import "KDUserBasicProfileView.h"
#import "KDStatusRelativeContentSectionView.h"
#import "KDMenuView.h"
#import "CommenMethod.h"
#import "KDGroupStatus.h"

#import "KDStatus.h"
#import "KDMentionMeStatus.h"
#import "KDCommentMeStatus.h"
#import "PostViewController.h"

extern NSString * const KDNotificationInboxStatusReset;

@interface KDStatusDetailViewController : UIViewController<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, KDStatusDetailViewDelegate, KDMenuViewDelegate, KDStatusRelativeContentSectionViewDelegate, UIAlertViewDelegate, KDThumbnailViewDelegate2> {
    
@private
    
    //@begin weak_reference
    KDAvatarView *avatarView_;
    UIButton *userNameBtn_;
    KDRefreshTableView *tableView_;
    KDMenuView *actionMenuView_;
    //@end
    
    //@begin these two are strong reference, but not create when currrent status is nil
    KDStatusDetailView *statusDetailView_;
    UIView *userProfileView_;
    //@end
    
    KDStatusRelativeContentSectionView *sectionView_;
    
    KDStatus *status_;
    NSString *statusId_;
    KDStatus   *selectedStatus_;
    
    NSMutableArray *comments_;
    NSMutableArray *forwards_;
    
    NSInteger pageCursorForComments_;
    NSInteger pageCursorForForwards_;
    NSInteger pageCursorForLikers_;
    
    UITableViewCell *placeHolderCell_;
    
    UIViewController *preViewController_;
    
    id<KDImageDataSource> imageDataSource_;
    
    NSCache *cellCache_;
    
    NSString *inboxId_;
    
    struct {
        unsigned int initializedWithStatus:1;
        unsigned int initializedWithStatusId:1;
        unsigned int initializedFromFroward:2;//0:正常入口；1：转发中的“回复”；2：转发中的“转发”；3、收件箱；
        unsigned int loadingComments:1;
        unsigned int loadingForwards:1;
        unsigned int loadingLikers:1;
        unsigned int commentsHasMore:1;
        unsigned int forwardsHasMore:1;
        unsigned int likersHasMore:1;
        unsigned int showingComments:2; //0:forwards show; 1:comments show; 2:likers show
        unsigned int isRefreshing:1;
        unsigned int dismissed:1; // current view controller did pop up from navigation controller
    }statusDetailViewControllerFlags_;
}

@property (nonatomic, retain) KDStatus *status;

- (id)initWithStatus:(KDStatus *)status;
- (id)initWithStatusID:(NSString *)statusID;

//辅助从微博正文中的转发到此的跳转
- (id)initWithStatusID:(NSString *)statusID fromInbox:(NSString *)inboxId;
- (id)initWithStatus:(KDStatus *)status fromCommentOrForward:(BOOL)isComment;
- (id)initWithStatusID:(NSString *)statusID fromCommentOrForward:(BOOL)isComment;

@end
