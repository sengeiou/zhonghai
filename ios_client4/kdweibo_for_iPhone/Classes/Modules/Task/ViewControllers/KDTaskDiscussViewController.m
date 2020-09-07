//
//  KDTaskDiscussViewController.m
//  kdweibo
//
//  Created by bird on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskDiscussViewController.h"
#import "KDAttachmentViewController.h"
#import "MBProgressHUD.h"
#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "UIView+Blur.h"
#import "KDPicturePickedPreviewViewController.h"
#import "KDCommentStatus.h"
#import "KDManagerContext.h"
#import "KDUtility.h"
#import "NSString+Additions.h"
#import "KDDraft.h"
#import "UIImage+Additions.h"
#import "KDTaskEditorViewController.h"
#import "TwitterText.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "NSDictionary+Additions.h"

#define KD_DM_CHAT_INPUT_VIEW_HEIGHT   46.0
#define KD_TODOLIST_STATE_NOTIFICATION         @"kd_todolist_state_notification"

@interface KDTaskDiscussViewController () <KDDMChatInputViewDelegate, KDPicturePickedPreviewViewControllerDelegate, KDTaskEditorViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KDTaskHeaderViewDelegate,MJPhotoBrowserDelegate>
@property(nonatomic, retain) id<KDImageDataSource> tappedOnImageDataSource;
@property(nonatomic, retain) KDTask *task;
@property(nonatomic, retain) KDStatus *status;
@end

@implementation KDTaskDiscussViewController
@synthesize tappedOnImageDataSource = tappedOnImageDataSource_;
@synthesize task = task_;
@synthesize delegate = delegate_;
- (id)initWithTaskId:(NSString *)taskId
{
    self = [super init];
    if (self) {
        // Custom initialization
        taskId_ = taskId ;//retain];
        
        flags_.current_cursor = 0;
        flags_.has_more_cursor = 1;
        flags_.page_count = 20;
        flags_.isFirstload = YES;
        
        messages_ = [NSMutableArray array] ;//retain];
        
    }
    return self;
}
- (void)dealloc
{
    [chatInputView_ removeKeyboardNotification];
    
    //KD_RELEASE_SAFELY(task_);
    //KD_RELEASE_SAFELY(_status);
    //KD_RELEASE_SAFELY(taskHeadView_);
    //KD_RELEASE_SAFELY(tappedOnImageDataSource_);
    //KD_RELEASE_SAFELY(taskId_);
    //KD_RELEASE_SAFELY(taskView_);
    //KD_RELEASE_SAFELY(messages_);
    //KD_RELEASE_SAFELY(chatInputView_);
    //[super dealloc];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [chatInputView_ addKeyboardNotification];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [chatInputView_ removeKeyboardNotification];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [KDWeiboAppDelegate setExtendedLayout:self];
    
    self.title = ASLocalizedString(@"KDTaskDiscussViewController_title");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    CGRect rect = self.view.bounds;
    rect.origin.y = kd_StatusBarAndNaviHeight;
    rect.size.height -= kd_BottomSafeAreaHeight + kd_BottomSafeAreaHeight;
    taskView_ = [[KDTaskDiscussView alloc] initWithFrame:rect delegate:self];
    [self.view addSubview:taskView_];
    
    
    CGRect frame = CGRectMake(0, self.view.bounds.size.height - KD_DM_CHAT_INPUT_VIEW_HEIGHT, self.view.bounds.size.width, KD_DM_CHAT_INPUT_VIEW_HEIGHT);

    if(chatInputView_ == nil){
        KDDMChatInputView *chatInputView = [[KDDMChatInputView alloc] initWithFrame:CGRectZero delegate:self hostViewController:self inputType:KDInputViewTypeTK];
        chatInputView_ = chatInputView ;//retain];
//        [chatInputView release];
        chatInputView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }

    chatInputView_.frame = frame;
    [chatInputView_ renderLayerWithView:self.view withBorder:KDBorderPositionTop | KDBorderPositionBottom];
    [self.view addSubview:chatInputView_];
    
    [chatInputView_ addKeyboardNotification];
    
    [self getTaskFromNetWork:YES];

    
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDTaskDiscussViewController_rightItem_title")style:UIBarButtonItemStylePlain target:self action:@selector(detailTaskAction:)];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];

//    [rightItem release];
    
    label_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, CGRectGetHeight(frame))];
    label_.backgroundColor = [UIColor clearColor];
    [chatInputView_ addSubview:label_];
//    [label_ release];
    label_.textColor = MESSAGE_DATE_COLOR;
    label_.font = [UIFont systemFontOfSize:14.f];
    label_.text = ASLocalizedString(@"KDTaskDiscussViewController_label_text");
}
- (void)detailTaskAction:(id)sender
{
    if ([chatInputView_ isFirstResponder])
        [chatInputView_ resignFirstResponderIfNeed];
    
    KDTaskEditorViewController *controller = [[KDTaskEditorViewController alloc] initWithTask:task_];
    controller.status = _status;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
//    [controller release];
}

- (void)initTaskInfoView
{
    if (!taskHeadView_) {
        taskHeadView_  = [[KDTaskHeaderView alloc] initWithFrame:CGRectMake(0, kd_StatusBarAndNaviHeight, ScreenFullWidth, 44)];
        taskHeadView_.delegate = self;
        [self.view addSubview:taskHeadView_];
        
        UITapGestureRecognizer *tapGesureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnMaskView:)];
        [taskHeadView_ addGestureRecognizer:tapGesureRecognizer];
//        [tapGesureRecognizer release];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnMaskView:)];
        [taskHeadView_ addGestureRecognizer:panGestureRecognizer];
//        [panGestureRecognizer release];
        
    }
    [self.view bringSubviewToFront:taskHeadView_];
    taskHeadView_.task = task_;
    
    [taskView_ setTableOffset:CGPointMake(0, [KDTaskHeaderView getHeightOfHeaderView:task_])];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 
#pragma mark - UIGestureRecognizer method
- (void)didTapOnMaskView:(UIGestureRecognizer *)tapGestureRecognizer {
    
    if ([chatInputView_ isFirstResponder])
        [chatInputView_ resignFirstResponderIfNeed];
}

#pragma mark - 
#pragma mark - KDTaskHeaderViewDelegate method
- (void)taskCancelFinished {


    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:ASLocalizedString(@"KDTaskDiscussViewController_HUD_text")];
    KDQuery *query = [KDQuery query];
    [query setProperty:task_.taskNewId forKey:@"id"];
    [query setParameter:@"status" stringValue:@"true"];
    __block KDTaskDiscussViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL success = NO;
        if([response isValidResponse]) {
            if (results) {
                success = [(NSDictionary *)results boolForKey:@"success"];
                if (success) {
    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KD_TODOLIST_STATE_NOTIFICATION object:[NSDictionary dictionaryWithObjectsAndKeys:@"undo",@"state", nil]];
                    [[KDNotificationView defaultMessageNotificationView] showInView:sdvc.view.window message: ASLocalizedString(@"KDTaskDiscussViewController_success_flag")type:KDNotificationViewTypeNormal];
                    
                    /*
                     sdvc.task.isCurrentUserFinish = NO;
                     [taskHeadView_ setTask:sdvc.task];
                     */
                    [self getTaskFromNetWork:NO];
                }
                
            }
            
        } else {
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
            
        }
        if (!success) {
            [[KDNotificationView defaultMessageNotificationView] showInView:sdvc.view.window message: ASLocalizedString(@"KDTaskDiscussViewController_fail_flag")type:KDNotificationViewTypeNormal];
        }
        [hud hide:YES];
        // release current view controller
//        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/task/:cancelfinishtasknew" query:query
                                 configBlock:nil completionBlock:completionBlock];

}

- (void)taskFinished
{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:ASLocalizedString(@"KDTaskDiscussViewController_submit")];
    
    
    KDQuery *query = [KDQuery query];
    [query setProperty:task_.taskNewId forKey:@"id"];
    __block KDTaskDiscussViewController *sdvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [hud hide:YES];
        BOOL success = NO;
        if([response isValidResponse]) {
            
            if (results) {
                success = [(NSDictionary *)results boolForKey:@"success"];
                if (success) {
                    
                    /*
                     sdvc.task.isCurrentUserFinish = YES;
                     [taskHeadView_ setTask:sdvc.task];
                     
                     [self back];
                     */
                    [self getTaskFromNetWork:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KD_TODOLIST_STATE_NOTIFICATION object:[NSDictionary dictionaryWithObjectsAndKeys:@"done",@"state", nil]];
                    [[KDNotificationView defaultMessageNotificationView] showInView:sdvc.view.window message: ASLocalizedString(@"KDTaskDiscussViewController_success_task")type:KDNotificationViewTypeNormal];
                    
                }
            }
            
        } else {
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
            
        }
        if (!success)
            [[KDNotificationView defaultMessageNotificationView] showInView:sdvc.view.window message: ASLocalizedString(@"KDTaskDiscussViewController_fail_task")type:KDNotificationViewTypeNormal];
        
//        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/task/:finish" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}
#pragma mark -
#pragma mark KDPicturePickedPreviewViewControllerDelegate  method
- (void)confirmSeleted:(UIImage*)image {
    [chatInputView_ setPickedPhoto:image];
}

- (void)cancleSelected {
}
#pragma mark -
#pragma mark UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
	if(UTTypeConformsTo(mediaType, kUTTypeImage)){
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            [self confirmSeleted:image];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            KDPicturePickedPreviewViewController *pvc = [[KDPicturePickedPreviewViewController alloc] init];
            pvc.image = image;
            pvc.delegate = self;
            
            [picker pushViewController:pvc animated:YES];
//            [pvc release];
            
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark KDDMChatInputView delegate methods
- (void)didChangeDMChatInputViewVisibleHeight:(KDDMChatInputView *)dmChatInputView {

    [label_ setHidden:[dmChatInputView isActive]];
    if ([dmChatInputView hasContent])
        [label_ setHidden:YES];

    [taskView_ changeTableViewHeightToFitDMChatInputView:dmChatInputView headerView:taskHeadView_ animated:YES];
}

- (void)presentImagePickerForDMChatInputView:(KDDMChatInputView *)dmChatInputView takePhoto:(BOOL)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    if (takePhoto) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
//    [picker release];

}
- (void)sendContentsInDMChatInputView:(KDDMChatInputView *)chatInputView
{
    
    int length = [TwitterText tweetLength:chatInputView.text];
    if (length > 140) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDTaskDiscussViewController_alert_msg")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:nil, nil];
        [alertView show];
//        [alertView release];
        
        return;
    }
    
    
    KDCommentStatus *status = [[KDCommentStatus alloc] init];
    status.text = chatInputView_.text;
    status.author = [KDManagerContext globalManagerContext].userManager.currentUser;
    status.createdAt = [NSDate date];
    status.messageState = KDCommentStateUnsend | KDCommentStateSending;
    status.statusId = [NSString stringWithFormat:@"%lf",[status.createdAt timeIntervalSince1970]];
    status.replyStatusId = taskId_;
    
    if (chatInputView.pickedImage.cachePath) {
        NSString *fileNewPath = [[[KDUtility defaultUtility] searchDirectory:KDPicturesUnsendDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:[status.statusId MD5DigestKey]];
        

        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:chatInputView_.pickedImage.cachePath]];
        [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL fileURLWithPath:fileNewPath] imageScale:SDWebImageScaleNone]];
        
        image = [image fastCropToSize:[KDImageSize defaultPreviewImageSize].size];
        [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL fileURLWithPath:fileNewPath] imageScale:SDWebImageScalePreView]];
        
        image = [image fastCropToSize:[KDImageSize defaultThumbnailImageSize].size];
        [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL fileURLWithPath:fileNewPath] imageScale:SDWebImageScaleThumbnail]];
        
        [[NSFileManager defaultManager] moveItemAtPath:chatInputView.pickedImage.cachePath toPath:fileNewPath error:NULL];
        
        KDImageSource *imagesource = [[KDImageSource alloc] init];
        imagesource.thumbnail = fileNewPath;
        imagesource.middle = fileNewPath;
        imagesource.original = fileNewPath;
        imagesource.rawFileUrl = fileNewPath;
        KDCompositeImageSource *cis = [[KDCompositeImageSource alloc] initWithImageSources:@[imagesource]];
        cis.entity = status;
        status.compositeImageSource = cis;
//        [cis release];
//        [imagesource release];

    }
    [chatInputView_ reset:YES];
    
    [messages_ addObject:status];
//    [status release];
    
    [taskView_ newMessageInsertedAtIndexPaths:@[[NSIndexPath indexPathForRow:[messages_ count] -1  inSection:0]]];
    
    [taskView_ changeTableViewHeightToFitDMChatInputView:chatInputView_ headerView:taskHeadView_ animated:YES];

    [self postCommentToNetWork:status];
}
#pragma mark -
#pragma mark - KDTaskDiscussViewDelegate methods
- (void)setImageDataSource:(id<KDImageDataSource>)source
{
    self.tappedOnImageDataSource = source;
}
- (void)thumbnailViewDidTaped:(NSArray *)srcs
{
    NSMutableArray *photos = [NSMutableArray array];
    NSArray *bigUrls    = [tappedOnImageDataSource_ bigImageURLs];
    NSArray *noRawUrls  = [tappedOnImageDataSource_ noRawURLs];
    for (int i = 0; i<bigUrls.count; i++) {
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];
        NSURL *url = [NSURL URLWithString:[bigUrls objectAtIndex:i]];
        if (url == nil && [[bigUrls objectAtIndex:i] length] >0) {
            url = [NSURL fileURLWithPath:[bigUrls objectAtIndex:i]];
        }
        photo.url = url; // 图片地址
        if (bigUrls.count == noRawUrls.count) {
            url = [NSURL URLWithString:[noRawUrls objectAtIndex:i]];
            if (url == nil && [[noRawUrls objectAtIndex:i] length] >0) {
                url = [NSURL fileURLWithPath:[noRawUrls objectAtIndex:i]];
            }
            photo.originUrl = url;//原图地址
        }
        
        if (srcs.count > i ) {
            photo.srcImageView = [srcs objectAtIndex:i]; // 来源于哪个UIImageView
        }
        
        [photos addObject:photo];
//        [photo release];
    }
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];// autorelease];
    browser.delegate = self;
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
    
}

//识别二维码
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser scanWithresult:(NSString *)result
{
    __weak __typeof(self) weakSelf = self;
    [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
        
        [photoBrowser hide];
        [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:weakSelf withQRResult:qrResult andQRCode:qrCode];
        
    }];
}

- (void)attachmentViewWithSource:(id)source
{
    KDAttachmentViewController *attachmentViewController = [[KDAttachmentViewController alloc] initWithSource:source];
    [self.navigationController pushViewController:attachmentViewController animated:YES];
//    [attachmentViewController release];
}
- (NSMutableArray *)getMessages
{
    return messages_;
}
- (KDTask *)getTask
{
    return task_;
}

#pragma mark - 
#pragma mark NetWork 
- (void)postCommentToNetWork:(KDCommentStatus *)status
{
//    [status retain];
    
    [taskView_ hideNoTips];
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeCommentForStatus];
    draft.commentForStatusId = task_.statusId;
    draft.content = status.text;
    draft.assetURLs = [status.compositeImageSource thumbnailURLs];
    [draft setProperty:draft.assetURLs forKey:kKDDraftImageAttachmentPathPropertyKey];
    
    KDQuery *query = [KDQuery query];
    [query setProperty:draft forKey:@"draft"];

    __block KDTaskDiscussViewController *pvc = self;// retain];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        BOOL isSucced = [response isValidResponse];
        if (isSucced) {

            [self getFetchReplyAndForwardCountFromNetWork];
            
            KDStatus *r = nil;
            
            if ([results isKindOfClass:[KDCommentStatus class]])
                r = results;
            else if([results isKindOfClass:[NSArray class]])
            {
                if ([((NSArray *)results) count]>0)
                    r = [results lastObject];
            }
            
            if (r) {
                
                [messages_ replaceObjectAtIndex:[messages_ indexOfObject:status] withObject:r];
                
                KDCompositeImageSource *imageSource = status.compositeImageSource;
                if ([imageSource hasImageSource]) {
                    
                    
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageSource.firstThumbnailURL]];
                    
                    //移除之前存进去的
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    [[SDImageCache sharedImageCache] removeImageForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL fileURLWithPath:imageSource.firstThumbnailURL] imageScale:SDWebImageScaleNone]];

                    [[SDImageCache sharedImageCache] removeImageForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL fileURLWithPath:imageSource.firstThumbnailURL] imageScale:SDWebImageScalePreView]];
                    
                    [[SDImageCache sharedImageCache] removeImageForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL fileURLWithPath:imageSource.firstThumbnailURL] imageScale:SDWebImageScaleThumbnail]];
                    
                    
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:r.compositeImageSource.bigImageURL] imageScale:SDWebImageScaleNone]];
                    
                    image = [image fastCropToSize:[KDImageSize defaultPreviewImageSize].size];
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:r.compositeImageSource.bigImageURL] imageScale:SDWebImageScalePreView]];
                    
                    image = [image fastCropToSize:[KDImageSize defaultThumbnailImageSize].size];
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:r.compositeImageSource.thumbnailImageURL] imageScale:SDWebImageScaleThumbnail]];

                    [fileManager removeItemAtPath:imageSource.firstThumbnailURL error:NULL];

                }
                
            }
            else
            {
                KDCommentState state = status.messageState;
                state|= KDCommentStateSended;
                state = state&~KDCommentStateSending;
                status.messageState = state;

            }
            
            
            KDCompositeImageSource *source = status.compositeImageSource;
            if ([source hasImageSource]) {
                //移除之前存进去的
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *cacheKey = [KDCache cacheKeyForURL:[source thumbnailImageURL]];
                [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypePreview] error:NULL];
                [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypeOrigin] error:NULL];
                [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypePreviewBlur] error:NULL];
                [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypeMiddle] error:NULL];
                [fileManager removeItemAtPath:[KDCacheUtlities imageFullPathForCacheKey:cacheKey imageType:KDCacheImageTypeThumbnail] error:NULL];
            }
            
        } else {
            // show error message
            NSString *errorMessage = ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27");
            NSDictionary *info = [response responseAsJSONObject];
            if (info != nil) {
                NSString *message = [info stringForKey:@"message"];
                NSInteger code = [info integerForKey:@"code"];
                if (message != nil && [message rangeOfString:ASLocalizedString(@"KDTaskDiscussViewController_weibo_delete")].location != NSNotFound) {
                    errorMessage = NSLocalizedString(@"ORIGIN_STATUS_DELETED_WHEN_REPOSE", @"");
                    
                } else if (code == 40005) {
                    errorMessage = NSLocalizedString(@"NO_IDENTICAL_STATUS_IN_TRHEE_MIN", @"");
                }
            }
            
            [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window
                                                                    message:errorMessage
                                                                       type:KDNotificationViewTypeNormal];
            
            KDCommentState state = status.messageState;
            state|=KDCommentStateUnsend;
            state = state&~KDCommentStateSending;
            status.messageState = state;
        }
        
        [taskView_ reloadData];
//        [pvc release];
        
//        [status release];
    };
    
    [KDServiceActionInvoker invokeWithSender:pvc actionPath:@"/statuses/:uploadComment" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}
- (void)getTaskFromNetWork:(BOOL)isFirstLoad {
    [MBProgressHUD showHUDAddedTo:taskView_ animated:YES];
    
    NSString *actionPath = @"/task/:taskById";
    KDQuery *query = [KDQuery query];
    [query setProperty:taskId_ forKey:@"id"];
    KDTaskDiscussViewController *tdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        NSString *message = nil;
        BOOL success = NO;
        if ([response isValidResponse]) {
            NSDictionary *resultDic = results;
            success = [resultDic boolForKey:@"success"];
            if (!success) {
                message = [resultDic stringForKey:@"errormsg"];
                
            }else {
                KDTask *task = [resultDic objectForKey:@"task"];
                tdvc.task = task;
                
                if(delegate_&&[delegate_ respondsToSelector:@selector(statusChangeWithTaskId:status:)])
                    [delegate_ statusChangeWithTaskId:task.taskNewId status:(int)task.state];
                
                if (isFirstLoad) {
                    [self fetchStatusById];
                    [self initTaskInfoView];
                    [self getFetchReplyAndForwardCountFromNetWork];
                    [self getCommentsFromNetWork];
                }
                else
                    taskHeadView_.task = task_;
            }
        }else {
            if (![response isCancelled]) {
                message = [response.responseDiagnosis networkErrorMessage];
            }
            
        }
        if (!success) {
            if(!message) {
                message = ASLocalizedString(@"KDTaskDiscussViewController_NoTaskDetail");
            }
            [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window
                                                                    message:message
                                                                       type:KDNotificationViewTypeNormal];
        }
        
        [MBProgressHUD hideAllHUDsForView:taskView_ animated:YES];
        
//        [tdvc release];
    };
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}
- (void)fetchStatusById {
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.task.statusId];
    [query setProperty:self.task.statusId forKey:@"statusId"];
    
    __block KDTaskDiscussViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if(results) {
                NSDictionary *info = results;
                
                BOOL isExist = [info boolForKey:@"isExist"];
                if (isExist) {
                    KDStatus *status = [info objectForKey:@"status"];
                    sdvc.status = status;
                }
            }
        }
//            [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:showById" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)getFetchReplyAndForwardCountFromNetWork {
    KDQuery *query = [KDQuery queryWithName:@"ids" value:task_.statusId];
    
    __block KDTaskDiscussViewController *sdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if(results != nil) {
                NSArray *countList = results;
                if ([countList count] > 0) {
                    KDStatusCounts *statusCount = countList[0];
                    [taskHeadView_ setCount:statusCount];
                    
                    if (delegate_ && [delegate_ respondsToSelector:@selector(commentCountIncreaseWithTaskId:count:)]) {
                        [delegate_ commentCountIncreaseWithTaskId:taskId_ count:statusCount.commentsCount];
                    }
                }
            }
            
        } else {
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:sdvc.view.window];
            }
            
        }
//        [sdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:counts" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)getCommentsFromNetWork {
    
    [MBProgressHUD showHUDAddedTo:taskView_ animated:YES];
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"id" stringValue:self.task.statusId]
      setParameter:@"count" integerValue:flags_.page_count]
     setParameter:@"cursor" integerValue:flags_.current_cursor];
    
    __block KDTaskDiscussViewController *tdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if(results != nil) {
                NSDictionary *info = (NSDictionary *)results;
                
                NSArray *comments = [info objectForKey:@"comments"];
                NSInteger nextCursor = [info integerForKey:@"nextCursor"];
                
                if ([comments count] < flags_.page_count || nextCursor < flags_.current_cursor) {
                    flags_.has_more_cursor = 0;
                }
                
                flags_.current_cursor = (unsigned int)nextCursor;
                 
                NSEnumerator *enumerator = [comments reverseObjectEnumerator];
                
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [comments count])];
                [messages_ insertObjects:[enumerator allObjects] atIndexes:indexSet];
                
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:tdvc.view.window];
            }
        }
        
        [self getCommentsFinished];
        
        if(flags_.isFirstload)
            [taskView_ scrollToBottom];
        flags_.isFirstload = NO;
        
        [MBProgressHUD hideAllHUDsForView:taskView_ animated:YES];
        // release current view controller
//        [tdvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:commentsByCursor" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)getCommentsFinished
{
    [taskView_ olderMessageLoaded];
    
    [taskView_ moreMessagesButtonVisible:flags_.has_more_cursor];
}
#pragma mark - KDTaskEditorViewControllerDelegate

- (void)taskHasUpdated:(KDTask *)newTask
{
    if (task_) {
//        [task_ release];
        task_ = nil;
    }
    task_ = newTask;// retain];

    float heightDiff = [KDTaskHeaderView getHeightOfHeaderView:newTask] - taskHeadView_.frame.size.height;
    [taskHeadView_ setTask:newTask];
    [taskView_ setTableOffset:CGPointMake(0, heightDiff)];
    
    
}
#pragma mark -
#pragma mark UIGestureRecognizer delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    return YES;
}
@end
