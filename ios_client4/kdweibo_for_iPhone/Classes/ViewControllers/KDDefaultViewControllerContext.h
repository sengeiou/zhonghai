//
//  KDDefaultViewControllerContext.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "KDDefaultViewControllerFactory.h"
#import "PostViewController.h"
#import "KDAppVersionUpdates.h"
#import "KDFrequentContactsPickViewController.h"
#import "KDStatusDetailViewController.h"
#import "KDCreateTaskViewController.h"
#import  "KDCompositeImageSource.h"
#import "KDCreateTaskViewController.h"

@class KDUser;
@class KDAttachment;

@interface KDDefaultViewControllerContext : NSObject {
@private
    KDDefaultViewControllerFactory *defaultViewControllerFactory_;
}

@property (nonatomic, retain, readonly) KDDefaultViewControllerFactory *defaultViewControllerFactory;
@property (nonatomic,retain)KDStatus *status;

+ (KDDefaultViewControllerContext *)defaultViewControllerContext;
+ (void)setDefaultViewControllerContext:(KDDefaultViewControllerContext *)viewControllerContext;

// PostViewController
- (void)showPostViewController:(PostViewController *)postViewController;


// participant
- (void)showDMParticipantPickerViewController:(KDFrequentContactsPickViewController *)pickerViewController;

// KDCreateTaskViewController
- (void)showCreateTaskViewControllerController:(KDCreateTaskViewController *)taskViewController;

- (void)showBidaTaskViewController:(KDWebViewController *)bidaTaskViewController;

// User profile view controller
- (void)showUserProfileViewController:(KDUser *)user;

- (void)showUserProfileViewController:(KDUser *)user sender:(UIView *)sender;

- (void)showUserProfileViewControllerByUserId:(NSString *)userId sender:(UIView *)sender;

- (void)showUserProfileViewControllerByName:(NSString *)userName sender:(UIView *)sender;

- (void)showTopicViewControllerByName:(NSString *)topicName andStatue:(KDStatus *)status sender:(UIView *)sender;

- (void)showWebViewControllerByUrl:(NSString *)urlString sender:(UIView *)sender;

- (void)showVoteControllerWithVoteId:(NSString *)voteId sender:(UIView *)view;

- (void)showMapViewController:(id)status sender:(UIView *)view;

- (void)showCreateTaskViewController:(id)refreObj type:(KDCreateTaskReferType) type sender:(UIView *)view;

- (UIViewController *)topViewController;

- (void)showUpgradeAlterView:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag withVersion:(KDAppVersionUpdates *)versionUpdates;

- (void)showProgressModalViewController:(KDAttachment *)att inStatus:(KDStatus *)st sender:(UIView *)sender;

- (void)showAttachmentViewController:(id)source sender:(UIView *)sender;

- (void)showImagesOrVideos:(KDCompositeImageSource *)imageDataSource startIndex:(NSUInteger)index  sender:(UIView *)sender;
- (void)showImages:(KDCompositeImageSource *)imageDataSource startIndex:(NSUInteger)index srcImageViews:(NSArray *)srcs;
- (void)showImages:(KDCompositeImageSource *)imageDataSource startIndex:(NSUInteger)index srcImageViews:(NSArray *)srcs window:(UIWindow *)window;
- (void)showForwardViewController:(KDStatus *)status sender:(UIView *)sender;

//去到评论编辑页面
- (void)showCommentViewController:(KDStatus *)status sender:(UIView *)sender;

//去评论编辑页面，delegate 接受返回的数据
- (void)showCommentViewController:(KDStatus *)status commentedSatatus:(KDStatus *)commentedStatus delegate:(id)delegate sender:(UIView *)sender;

- (void)showCommentViewController:(KDStatus *)status commentedSatatus:(KDStatus *)commentedStatus delegate:(id)delegate sender:(UIView *)sender showOriginalStatus:(BOOL)show;

//去到草稿列表
- (void)showDraftListViewController:(UIView *)sender;

//删除 directly 为YES 表示直接草稿，用于删除发送失败的status
- (void)deleteStatus:(KDStatus *)status;

// 赞操作
- (void)toggleLike:(KDStatus *)status;

//收藏操作
- (void)toggleFavorite:(KDStatus *)status;

//举报
- (void)report:(KDStatus *)status;

//去到微博详情的评论列表或者转发列表
- (void)showDetailViewControllerOfStatus:(KDStatus *)status fromCommentOrForward:(BOOL)isComment sender:(UIView *)sender;

//- (void)showCreateTaskViewControllerOfStatus:(KDStatus *)status sender:(UIView *)sender;
- (void)showActionSheetByStatus:(KDStatus *)status actionSheetItems:(NSArray *)items;

@end

