//
//  KDDefaultViewControllerContext.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDDefaultViewControllerContext.h"

#import "KDWeiboAppDelegate.h"
#import "ProfileViewController.h"
#import "KDVoteViewController.h"
#import "KDMapViewController.h"
#import "KDUser.h"
#import "KDAttachmentViewController.h"
#import "KDProgressModalViewController.h"
#import "KDCreateTaskViewController.h"
#import "KDDownload.h"
#import "KDGroupStatus.h"
#import "KDVideoPlayerController.h"
#import "KDUploadTaskHelper.h"
#import "KDLikeTask.h"
#import "KDFavoriteTask.h"
#import "IssuleViewController.h"
#import "KDErrorDisplayView.h"
#import "KDDatabaseHelper.h"
#import "DraftViewController.h"
#import "KDDraftManager.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "XTPersonDetailViewController.h"
#import "XTShareManager.h"
#import "KDManagerContext.h"
#import "KDQRAnalyse.h"




static KDDefaultViewControllerContext *defaultViewControllerContext_ = nil;


@interface KDDefaultViewControllerContext ()<UIActionSheetDelegate,MJPhotoBrowserDelegate>

@property (nonatomic, retain) KDDefaultViewControllerFactory *defaultViewControllerFactory;

@end



@implementation KDDefaultViewControllerContext

@synthesize defaultViewControllerFactory=defaultViewControllerFactory_;
@synthesize status = status_;

- (id)init {
    self = [super init];
    if(self){
        defaultViewControllerFactory_ = [[KDDefaultViewControllerFactory alloc] init];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDefaultViewControllerContext setter/getter class method

+ (KDDefaultViewControllerContext *)defaultViewControllerContext {
    if(defaultViewControllerContext_ == nil){
        defaultViewControllerContext_ = [[KDDefaultViewControllerContext alloc] init];
    }
    
    return defaultViewControllerContext_;
}

+ (void)setDefaultViewControllerContext:(KDDefaultViewControllerContext *)viewControllerContext {
    if(defaultViewControllerContext_ != viewControllerContext){
        //        [defaultViewControllerContext_ release];
        defaultViewControllerContext_ = viewControllerContext ;//retain];
    }
}

- (void)showPostViewControllerOnStage:(UIViewController *)viewController {
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:viewController];
    [[self rootViewController] presentViewController:nvc animated:YES completion:nil];
    //    [nvc release];
}

- (void)_test:(UIViewController *)viewController  {
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPostViewController:(PostViewController *)postViewController {
    [self showPostViewControllerOnStage:postViewController];
}

#pragma mark -
#pragma mark VoteView controller
- (void)showVoteControllerWithVoteId:(NSString *)voteId sender:(UIView *)view {
    
    KDVoteViewController *vvc = [[KDVoteViewController alloc] init];
    //iOS7适配 王松 -- 2013-10-21
    [KDWeiboAppDelegate setExtendedLayout:vvc];
    vvc.voteId = voteId;
    UINavigationController *nav = [self navgationViewController:view];
    [nav pushViewController:vvc animated:YES];
    //    [vvc release];
}

#pragma mark -
#pragma mark CreateTaskViewController
- (void)showCreateTaskViewControllerController:(KDCreateTaskViewController *)taskViewController
{
    [self showPostViewControllerOnStage:taskViewController];
}
- (void)showCreateTaskViewController:(id)refreObj type:(KDCreateTaskReferType) type sender:(UIView *)view {
    KDCreateTaskViewController *ctvc = [[KDCreateTaskViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    ctvc.referObject = refreObj;
    ctvc.referType = type;
    ctvc.title = ASLocalizedString(@"KDDefaultViewControllerContext_create_task");
    UINavigationController *theNav = [[UINavigationController alloc] initWithRootViewController:ctvc];// autorelease];
    // UIViewController *nav = [self navgationViewController:view];
    UIViewController *rootViewController = [self rootViewController];
    [rootViewController presentViewController:theNav animated:YES completion:nil];
}
- (void)showBidaTaskViewController:(KDWebViewController *)bidaTaskViewController
{
    [self showPostViewControllerOnStage:bidaTaskViewController];
}

#pragma mark -
#pragma mark MapViewcontroller
- (void)showMapViewController:(id)status sender:(UIView *)view{
    KDMapViewController *mvc = [[KDMapViewController alloc] initWithNibName:nil bundle:nil];
    mvc.obj = status;
    //mvc.mapView = [[KDWeiboAppDelegate getAppDelegate] mapView];
    UINavigationController *nav = [self navgationViewController:view];
    [nav pushViewController:mvc animated:YES];
    //    [mvc release];
}

- (void)showImages:(KDCompositeImageSource *)imageDataSource startIndex:(NSUInteger)index srcImageViews:(NSArray *)srcs
{
    NSMutableArray *photos = [NSMutableArray array];
    NSArray *imageSources = [imageDataSource imageSources];
    for (int i = 0; i<imageSources.count; i++) {
        // 替换为中等尺寸图片
        KDImageSource *source = [imageSources objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:source.original]; // 图片地址
        photo.originUrl = [NSURL URLWithString:source.noRawUrl];//原图地址
        
        if (source.isGifImage) {
            photo.isGif = YES;
        }
        
        if (srcs.count == imageSources.count) {
            photo.srcImageView = [srcs objectAtIndex:i]; // 来源于哪个UIImageView
        }
        [photos addObject:photo];
        //        [photo release];
    }
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];// autorelease];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

- (void)showImages:(KDCompositeImageSource *)imageDataSource startIndex:(NSUInteger)index srcImageViews:(NSArray *)srcs window:(UIWindow *)window
{
    NSMutableArray *photos = [NSMutableArray array];
    NSArray *imageSources = [imageDataSource imageSources];
    for (int i = 0; i<imageSources.count; i++) {
        // 替换为中等尺寸图片
        KDImageSource *source = [imageSources objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:source.original]; // 图片地址
        photo.originUrl = [NSURL URLWithString:source.noRawUrl];//原图地址
        
        if (source.isGifImage) {
            photo.isGif = YES;
        }
        
        if (srcs.count == imageSources.count) {
            photo.srcImageView = [srcs objectAtIndex:i]; // 来源于哪个UIImageView
        }
        [photos addObject:photo];
        //        [photo release];
    }
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];// autorelease];
    browser.delegate = self;
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show:window];
}


//识别二维码
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser scanWithresult:(NSString *)result
{
    [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
        [photoBrowser hide];
        [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:[KDWeiboAppDelegate getAppDelegate].discoveryViewController withQRResult:qrResult andQRCode:qrCode];
    }];
}

- (void)showImagesOrVideos:(KDCompositeImageSource *)imageDataSource startIndex:(NSUInteger)index  sender:(UIView *)sender {
    
    UIViewController *rootViewController =  [self rootViewController];
    NSArray *attachemtns = [imageDataSource propertyForKey:@"attachments"];
    if (attachemtns) { //播放视频
        KDVideoPlayerController *videoController = [[KDVideoPlayerController alloc] initWithNibName:nil bundle:nil];
        videoController.attachments = attachemtns;
        videoController.dataId = [imageDataSource propertyForKey:@"dataId"];
        
        [rootViewController presentViewController:videoController animated:YES completion:nil];
        //        [videoController release];
        
    }else {
        
        
    }
    
}
////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark direct message view controller

- (void)showDMParticipantPickerViewController:(KDFrequentContactsPickViewController *)pickerViewController {
    [self showPostViewControllerOnStage:pickerViewController];
}

////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark user profile view controller

- (UINavigationController*)navgationViewController:(UIView *)view { //通过view 查找uiviewcontroller
    for (UIView* next = view; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController*)nextResponder;
        }
    }
    return nil;
}

- (UIViewController *)rootViewControllerForView:(UIView *)view {
    for (UIView* next = view; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)showUserProfileViewController:(KDUser *)user sender:(UIView *)sender {
    [self showUserProfileViewControllerByUserId:user.userId sender:sender];
}

- (void)showUserProfileViewControllerByUserId:(NSString *)userId sender:(UIView *)sender {
    if(KD_IS_BLANK_STR(userId)) {
        NSLog(ASLocalizedString(@"userId 空"));
        return;
    }
    UINavigationController *vc = [self navgationViewController:sender];
    XTPersonDetailViewController *pvc = [[XTPersonDetailViewController alloc]initWithUserId:userId];
    [vc  pushViewController:pvc animated:YES];
    //    [pvc release];
}

- (void)showUserProfileViewControllerByName:(NSString *)userName sender:(UIView *)sender {
    UINavigationController *vc = [self navgationViewController:sender];
    XTPersonDetailViewController *pvc = [[XTPersonDetailViewController alloc]initWithScreenName:userName];
    [vc  pushViewController:pvc animated:YES];
    //    [pvc release];
}

- (void)showTopicViewControllerByName:(NSString *)topicName andStatue:(KDStatus *)status sender:(UIView *)sender
{
    KDTopic *topic = [[KDTopic alloc] init] ;//autorelease];
    topic.name = topicName;
    
    UINavigationController *vc = [self navgationViewController:sender];
    TrendStatusViewController *tsvc = [[TrendStatusViewController alloc] initWithTopic:topic];
    tsvc.topicStatus = status;
    [vc pushViewController:tsvc animated:YES];
    //[vc release];
    //    [tsvc release];
}

- (void)showWebViewControllerByUrl:(NSString *)urlString sender:(UIView *)sender
{
    if(![[urlString lowercaseString] hasPrefix:@"http://"])
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    
    UINavigationController *vc = [self navgationViewController:sender];
    KDWebViewController *webView = [[KDWebViewController alloc] initWithUrlString:urlString];
    webView.isOpenWithWB = YES;
    [vc pushViewController:webView animated:YES];
    //    [webView release];
}

- (void)showUserProfileViewController:(KDUser *)user {
    
}


- (void)deleteStatus:(KDStatus *)status{
    self.status = status;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_del_weibo")delegate:self
                                                    cancelButtonTitle:ASLocalizedString(@"Global_Cancel")
                                               destructiveButtonTitle:ASLocalizedString(@"KD_STATUS_DETAIL_VIEW_CONFIRM")
                                                    otherButtonTitles:nil];
    actionSheet.tag = 100;
    [actionSheet showInView:[self rootViewController].view.window];
    //        [actionSheet release];
}


// 赞操作
- (void)toggleLike:(KDStatus *)status {
    KDLikeTask *task = [[KDLikeTask alloc ] init];
    task.status = status;
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:status.statusId];
    //    [task release];
}

//收藏操作
- (void)toggleFavorite:(KDStatus *)status {
    KDFavoriteTask *ft = [[KDFavoriteTask alloc] init];
    ft.status = status;
    
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:ft entityId:status.statusId];
    //    [ft release];
    
}


//举报
- (void)report:(KDStatus *)status {
    IssuleViewController *ivc = [[IssuleViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    ivc.text = [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_reason"), status.text];
    [KDWeiboAppDelegate setExtendedLayout:ivc];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ivc] ;//autorelease];
    [[self rootViewController] presentViewController:nav animated:YES completion:nil];
}
//刷新
- (void)refresh:(KDStatus *)status {
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusDetailShouldFresh object:self userInfo:@{@"status": status}];
}

- (void)shareStatus:(KDStatus *)status
{
    NSDictionary *dic = @{@"shareType" : @(3),
                          @"appName" : ASLocalizedString(@"KDDefaultViewControllerContext_trends"),
                          @"title" : ASLocalizedString(@"KDDefaultViewControllerContext_weibo_share"),
                          @"content" : [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_check_weibo"), status.author.username],
                          @"thumbUrl" : status.author.profileImageUrl.length == 0 ? [NSString stringWithFormat:@"%@/space/c/photo/load",[[KDWeiboServicesContext defaultContext] serverBaseURL]] : status.author.profileImageUrl,
                          @"webpageUrl" : [NSString stringWithFormat:@"cloudhub://status?id=%@", status.statusId]};
    
    if(![XTShareManager shareWithDictionary:dic andChooseContentType:XTChooseContentShareStatus]) {
        
    };
}
///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark main view controllers

- (UIViewController *)topViewController {
    return [[[KDWeiboAppDelegate getAppDelegate] sideMenuViewController] contentViewController];
}

- (UIViewController *)rootViewController {
    
    if([KDWeiboAppDelegate getAppDelegate].currentTopVC)
        return [KDWeiboAppDelegate getAppDelegate].currentTopVC;
    else
        return [[[KDWeiboAppDelegate getAppDelegate] window] rootViewController];
}


// if there is new version for kdweibo, just this alter view to user and ask them to upgrade
- (void)showUpgradeAlterView:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag withVersion:(KDAppVersionUpdates *)versionUpdates {
    // fomrat message
    //    NSString *buildNumber = versionUpdates.buildNumber;
    NSArray  *changes = versionUpdates.changes;
    NSMutableString *message = [[NSMutableString alloc]init];
    
    if(changes != nil){
        for(NSString *feature in changes){
            [message appendFormat:@"%@\n", feature];
        }
    }
    
    //add update tips
    NSString *tip = versionUpdates.desc;
    //    KDWeiboUpdatePolicy policy = versionUpdates.updatePolicy;
    NSInteger forceNo = [[versionUpdates forceUpdateNo]integerValue];
    NSInteger currentForceNo = [[KDCommon readForceUpdateNo]integerValue];
    /*if(forceNo == currentForceNo)
     tip = [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_tips1"), buildNumber];
     //        tip = ASLocalizedString(@"KDDefaultViewControllerContext_tips2");
     else if(forceNo > currentForceNo)
     tip =  [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_tips3"), buildNumber];*/
    
    //        tip = ASLocalizedString(@"必须更新，否则将导致使用异常");
    // show upgrade message
    NSString *source = [NSString stringWithFormat:@"%@\n", message];
    
    //    if(isAboveiOS7) {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:tip message:source delegate:delegate cancelButtonTitle:forceNo > currentForceNo? nil:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"CheckVersionService_Update"), nil];
    alertView.tag = tag;
    
    [alertView show];
    //        [alertView release];
    //    }else {
    //        NSString *placeholderString = @"\n\n\n\n\n\n\n\n\n\n\n";
    //
    //        CGRect frame = CGRectMake(8.0, 40.0, 266.0, 240.0);
    //
    //        UIFont *font = [UIFont systemFontOfSize:16.0];
    //        CGSize sourceSize = [source sizeWithFont:font constrainedToSize:frame.size];
    //        CGSize placeholderSize = [placeholderString sizeWithFont:font constrainedToSize:frame.size];
    //
    //        if(sourceSize.height < placeholderSize.height){
    //            CGFloat ph = placeholderSize.height / [placeholderString length];
    //            NSInteger count = sourceSize.height / ph + 1;
    //            if(count < [placeholderString length]) {
    //                placeholderString = [placeholderString substringToIndex:count];
    //                placeholderSize.height = ph * count;
    //            }
    //        }
    //
    //        frame.size.height = placeholderSize.height;
    //
    //        UIView *maskView = [[UIView alloc] initWithFrame:frame];
    //
    //        frame = CGRectMake(0.0, 0.0, maskView.bounds.size.width, maskView.bounds.size.height+10.0);
    //        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    //        textView.backgroundColor = [UIColor clearColor];
    //        textView.textColor = [UIColor whiteColor];
    //        textView.editable = NO;
    //        textView.text = source;
    //        textView.font = font;
    //
    //        [maskView addSubview:textView];
    //        [textView release];
    //
    //        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:tip message:placeholderString delegate:delegate cancelButtonTitle:forceNo == currentForceNo ? nil:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"升级"), nil];
    //        alertView.tag = tag;
    //
    //
    //        [alertView addSubview:maskView];
    //        [maskView release];
    //
    //        [alertView show];
    //        [alertView release];
    //
    //    }
}

- (void)showProgressModalViewController:(KDAttachment *)att inStatus:(KDStatus *)st sender:(UIView *)sender {
    [KDDownload downloadsWithAttachemnts:@[att] Status:st finishBlock:^(NSArray *result) {
        KDDownload *download = (KDDownload *)[result objectAtIndex:0];
        KDProgressModalViewController *modal = [[KDProgressModalViewController alloc] initWithDownload:download];
        UINavigationController *nav = [self navgationViewController:sender];
        if(nav.navigationBarHidden == YES) {
            nav.navigationBarHidden = NO;
        }
        
        [nav pushViewController:modal animated:YES];
    }];
}

- (void)showAttachmentViewController:(id)source sender:(UIView *)sender {
    KDAttachmentViewController *avc = [[KDAttachmentViewController alloc] initWithSource:source];// autorelease];
    UINavigationController *nav = [self navgationViewController:sender];
    if(nav.navigationBarHidden == YES) {
        nav.navigationBarHidden = NO;
    }
    
    [nav pushViewController:avc animated:YES];
}

- (void)showForwardViewController:(KDStatus *)status sender:(UIView *)sender {
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeForwardStatus];
    draft.forwardedStatusId = status.statusId;
    
    if([status hasForwardedStatus]) {
        draft.forwardedStatusId = status.forwardedStatus.statusId;
        NSString *text = nil;
        NSString *sourceStatusContentText = nil;
        if (status.forwardedStatus.author != nil) {
            text = [NSString stringWithFormat:@"//@%@:%@", status.author.username, status.text];
        }
        else
        {
            text = [NSString stringWithFormat:@"//@%@", status.text];
        }
        draft.content = text;
        
        if (sourceStatusContentText != nil) {
            sourceStatusContentText = [NSString stringWithFormat:@"%@:%@", status.forwardedStatus.author.username, status.forwardedStatus.text];
        }
        else
        {
            sourceStatusContentText = status.forwardedStatus.text;
        }
        draft.originalStatusContent = sourceStatusContentText;
    } else {
        draft.originalStatusContent = [NSString stringWithFormat:@"%@:%@", status.author.screenName, status.text];
    }
    
    //用作转发时，同时回复的人。
    draft.replyScreenName = status.forwardedStatus?status.forwardedStatus.author.screenName:status.author.screenName;
    
    draft.groupId = status.groupId;
    draft.groupName = status.groupName;
    pvc.draft = draft;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc] ;//autorelease];
    [[self rootViewController] presentViewController:nav animated:YES completion:nil];
}


//有commentedStatus 代表针对commentedStatus 下的评论回复。
- (void)showCommentViewController:(KDStatus *)status commentedSatatus:(KDStatus *)commentedStatus delegate:(id)delegate sender:(UIView *)sender {
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeCommentForStatus];
    [draft setType:KDDraftTypeCommentForStatus];
    if (commentedStatus) {
        [draft setType:KDDraftTypeCommentForComment];
    }
    
    draft.commentForStatusId = status.statusId;
    if (commentedStatus) {
        draft.commentForCommentId = commentedStatus.statusId;
        draft.replyScreenName = commentedStatus.author.screenName;
        draft.originalStatusContent = [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_reply"), commentedStatus.author.screenName, commentedStatus.text];
    }else {
        draft.originalStatusContent = [NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text];
        
    }
    
    if(status.groupId && status.groupName) {
        draft.groupId = status.groupId;
        draft.groupName = status.groupName;
    }
    
    pvc.draft = draft;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    UIViewController *root = [self rootViewController];
    
    [root  presentViewController:nav animated:YES completion:nil];
}

- (void)showCommentViewController:(KDStatus *)status commentedSatatus:(KDStatus *)commentedStatus delegate:(id)delegate sender:(UIView *)sender showOriginalStatus:(BOOL)show {
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeCommentForStatus];
    [draft setType:KDDraftTypeCommentForStatus];
    if (commentedStatus) {
        [draft setType:KDDraftTypeCommentForComment];
    }
    
    draft.commentForStatusId = status.statusId;
    if (commentedStatus) {
        draft.commentForCommentId = commentedStatus.statusId;
        draft.replyScreenName = commentedStatus.author.screenName;
        draft.originalStatusContent = [NSString stringWithFormat:ASLocalizedString(@"KDDefaultViewControllerContext_reply"), commentedStatus.author.screenName, commentedStatus.text];
    }else {
        draft.originalStatusContent = [NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text];
        
    }
    
    if(status.groupId && status.groupName) {
        draft.groupId = status.groupId;
        draft.groupName = status.groupName;
    }
    
    pvc.draft = draft;
    
    if(show){
        pvc.originalStatus = status;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    UIViewController *root = [self rootViewController];
    
    [root  presentViewController:nav animated:YES completion:nil];
}

- (void)showCommentViewController:(KDStatus *)status sender:(UIView *)sender {
    
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeCommentForStatus];
    draft.commentForStatusId = status.statusId;
    [draft setProperty:status forKey:@"status"];
    
    draft.originalStatusContent = [NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text];
    
    if(status.groupId && status.groupName) {
        draft.groupId = status.groupId;
        draft.groupName = status.groupName;
    }
    
    pvc.draft = draft;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc] ;//autorelease];
    //[[self navgationViewController:sender] presentModalViewController:nav animated:YES];
    [[self rootViewControllerForView:sender] presentViewController:nav animated:YES completion:nil];
    
}

- (void)showDetailViewControllerOfStatus:(KDStatus *)status fromCommentOrForward:(BOOL)isComment sender:(UIView *)sender{
    KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatus:status fromCommentOrForward:isComment] ;//autorelease];
    [[self navgationViewController:sender] pushViewController:sdvc animated:YES];
}

- (void)showDraftListViewController:(UIView *)sender {
    
    DraftViewController *drfatViewController = [[DraftViewController alloc] init];// autorelease];
    [[self navgationViewController:sender] pushViewController:drfatViewController animated:YES];
    
}
//- (void)showCreateTaskViewControllerOfStatus:(KDStatus *)status sender:(UIView *)sender {
//    KDCreateTaskViewController *vc = [[KDCreateTaskViewController alloc] initWithNibName:nil bundle:nil];
//    vc.referObject = status;
//    [[self navgationViewController:sender] pushViewController:vc animated:YES];
//    [vc release];
//}
- (void)showActionSheetByStatus:(KDStatus *)status actionSheetItems:(NSArray *)items {
    self.status = status;
    UIActionSheet *actitonSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_choice")delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];
    for (NSString *title in items) {
        if (title.length >0) {
            [actitonSheet addButtonWithTitle:title];
        }
        
    }
    [actitonSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
    actitonSheet.cancelButtonIndex = actitonSheet.numberOfButtons - 1;
    actitonSheet.tag = 101;
    [actitonSheet showInView:[self rootViewController].view.window];
    //    [actitonSheet release];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(defaultViewControllerFactory_);
    //KD_RELEASE_SAFELY(status_);
    //[super dealloc];
}

- (void)destroyDraft{
    //    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
    //        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
    //        if ([status_ isGroup]) {
    //            [statusDAO removeGroupStatusWithId:status_.statusId database:fmdb];
    //        }else {
    //            [statusDAO removeStatusWithId:status_.statusId database:fmdb];
    //        }
    //    } completionBlock:nil];
    
    KDDraft *draft = [[KDDraft alloc] init];// autorelease];
    draft.draftId = [status_.statusId integerValue];
    draft.groupId = status_.groupId;
    [[KDDraftManager shareDraftManager] deleteDrafts:@[draft] completionBlock:^(id results) {
        BOOL success = [(NSNumber *)results boolValue];
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusShouldDeleted object:self userInfo:@{@"status": @[status_]}];
        }
    }];
    
}

- (void)destroyCurrentStatusSuccess {
    [KDDatabaseHelper inTransaction:(id)^(FMDatabase *fmdb,BOOL *rollBack) {
        BOOL success = YES;
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        
        //        if ([status_ isKindOfClass:[KDGroupStatus class]]) { //不能用 isGroup判断，因为大厅也可显示小组微博。
        //            success = [statusDAO removeGroupStatusWithId:status_.statusId database:fmdb];
        //        }else {
        //            success = [statusDAO removeStatusWithId:status_.statusId database:fmdb];
        //        }
        if ([status_ isGroup]) { //要在大厅微博和小组微博中删除，因为小组微博也可能存在大厅
            success = ([statusDAO removeGroupStatusWithId:status_.statusId database:fmdb]||
                       [statusDAO removeStatusWithId:status_.statusId database:fmdb]);
            
        }else {
            success = [statusDAO removeStatusWithId:status_.statusId database:fmdb];
        }
        
        *rollBack = !success;
        return @(success);
    } completionBlock:^(id results) {
        BOOL success = [(NSNumber *)results boolValue];
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusShouldDeleted object:self userInfo:@{@"status": @[status_]}];
        }
        
    }];
    
    
}
- (void)destroyCurrentStatus:(KDStatus *)status {
    
    if ([status.statusId hasPrefix:@"-"]) { //是草稿，直接删除
        [self destroyDraft];
        return;
    }
    KDQuery *query = [KDQuery queryWithName:@"id" value:status.statusId];
    [query setProperty:status_.statusId forKey:@"statusId"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if ([(NSNumber *)results boolValue]) {
                [self destroyCurrentStatusSuccess];
            }
        } else {
            if (![response isCancelled]) {
                id result = [response responseAsJSONObject];
                if (result) {
                    NSString *message = [(NSDictionary *)result objectForKey:@"message"];
                    NSRange range = [message rangeOfString:ASLocalizedString(@"KDDefaultViewControllerContext_weibo_null")];
                    if (range.location != NSNotFound) {
                        [self destroyCurrentStatusSuccess];
                        return ;
                    }
                }
                [KDErrorDisplayView showErrorMessage:NSLocalizedString(@"STATUSES_DESTORY_STATUS_DID_FAIL", @"")
                                              inView:[[self rootViewController].view window]];
            }
        }
        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:destoryById" query:query
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet.tag == 101) { //微博的操作
        if ([title isEqualToString:ASLocalizedString(@"KDDefaultViewControllerContext_to_task")]) {
            //
            [self showCreateTaskViewController:status_ type:KDCreateTaskReferTypeStatus sender:nil];
        }else if ([title isEqualToString:ASLocalizedString(@"KDABActionTabBar_tips_1")] || [title isEqualToString:ASLocalizedString(@"KDABPersonDetailsViewController_tips_3")]) {
            [self toggleFavorite:status_];
        }else if ([title isEqualToString:ASLocalizedString(@"KDCommentCell_delete")]) {
            [self deleteStatus:status_];
        }
        //        else if ([title isEqualToString:ASLocalizedString(@"举报")]) {
        //            [self report:status_];
        //        }
        else if ([title isEqualToString:ASLocalizedString(@"KDDefaultViewControllerContext_refresh")]) {
            [self refresh:status_];
        }else if([title isEqualToString:ASLocalizedString(@"KDDefaultViewControllerContext_share_conversation")]) {
            [self shareStatus:status_];
        }
    }else if (actionSheet.tag == 100) { //删除操作
        if ([title isEqualToString:ASLocalizedString(@"KD_STATUS_DETAIL_VIEW_CONFIRM")]) {
            [self destroyCurrentStatus:status_];
        }
        
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
@end

