//
//  KDDMConversationViewController.m
//  kdweibo
//
//

#import "KDCommon.h"
#import "KDErrorDisplayView.h"

#import "KDWeiboAppDelegate.h"
#import "KDDMConversationViewController.h"
#import "KDDMThreadMembersViewController.h"
#import "KDDMLocationSelectViewController.h"

#import "ChatBubbleCell.h"
#import "KDNotificationView.h"

#import "KDDMThread.h"
#import "KDDMMessage.h"
#import "KDCache.h"

#import "KDRequestDispatcher.h"
#import "KDDefaultViewControllerContext.h"
#import "KDAttachmentViewController.h"
#import "MBProgressHUD.h"
#import "KDDatabaseHelper.h"
#import "UIImage+Additions.h"
#import "KDAudioController.h"
#import "KDAudioRecordView.h"
#import "KDAttachment.h"
#import "KDManagerContext.h"
#import "KDUtility.h"
#import "NSString+Additions.h"
#import "KDImageUploadTask.h"
#import "KDMessageUploadTask.h"
#import "KDUploadTaskHelper.h"
#import "KDPicturePickedPreviewViewController.h"
#import "KDErrorDisplayView.h"

#import "UIView+Blur.h"

#import "KDRefreshTableViewSideViewTopForiPhone.h"

#import "KDImagePickerController.h"


#define KD_DM_MAX_MESSAGES_COUNT_PER_PAGE  20
#define KD_DM_THREAD_LOAD_MORE_BTN_TAG  0x64

@interface KDDMConversationViewController ()<KDPicturePickedPreviewViewControllerDelegate, KDImagePickerControllerDelegate>

typedef enum{
    KDDMSendType_Text,
    KDDMSendType_Photo,
    KDDMSendType_Location,
    KDDMSendType_Audio
}KDDMSendType;

@property(nonatomic, retain) NSMutableArray *messages;
@property(nonatomic, copy)   NSString * audioFilePath;
@property(nonatomic, retain) KDRefreshTableView *messagesTableView;
@property(nonatomic, retain) KDDMChatInputView *chatInputView;
@property(nonatomic, retain) KDAudioRecordView *recordView;
@property(nonatomic, retain) UIView            *maskView;

@property(nonatomic, retain) id<KDImageDataSource> tappedOnImageDataSource;
@property(nonatomic, retain) UIAlertView *backOnSendingAlertView;
@property(nonatomic, retain) NSMutableArray *messageIdToTag;
@property(nonatomic, retain)NSArray *selectedImageItems;
@property(nonatomic, retain)NSMutableArray *taskArray;
@property(nonatomic, copy) NSString *nextSinceDMId;


- (void)toggleMoreMessageButtonVisible;
- (void)toggleMoreButtonEnabledWithLoading:(BOOL)loading;
- (void)setupJoinedUserBarButtonItem;

- (BOOL)hasMessages;
- (void)loadLatestMessages;
- (void)loadOlderMessages;

- (void)sortMessages;

@end


@implementation KDDMConversationViewController

//@synthesize messageViewController=messageViewController_;
@synthesize delegate = delegate_;
@synthesize dmThread=dmThread_;
@synthesize dmThreadID = dmThreadID_;
@synthesize messages=messages_;
@synthesize audioFilePath = audioFilePath_;
@synthesize messagesTableView=messagesTableView_;
@synthesize chatInputView=chatInputView_;
@synthesize recordView = recordView_;
@synthesize maskView = maskView_;
@synthesize nextSinceDMId = nextSinceDMId_;

@synthesize tappedOnImageDataSource=tappedOnImageDataSource_;
@synthesize addedParicipants = addedParicipants_;

@synthesize backOnSendingAlertView = backOnSendingAlertView_;
@synthesize messageIdToTag = messageIdToTag_;
@synthesize selectedImageItems = selectedImageItems_;
@synthesize taskArray = taskArray_;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        tappedOnImageDataSource_ = nil;
        
        contentOffset_ = CGPointZero;
        
        dmViewControllerFlags_.initialized = 0;
        dmViewControllerFlags_.initialWithID = 0;
        dmViewControllerFlags_.hasDMPostRequest = 0;
        dmViewControllerFlags_.didReceiveMemoryWarning = 0;
        dmViewControllerFlags_.navigateToPrevious = 0;
        dmViewControllerFlags_.showingImagePicker = 0;
        dmViewControllerFlags_.showFromGallary = 0;
        dmViewControllerFlags_.shouldLoadMessage = 0;
        messageIdToTag_ = [[NSMutableArray alloc] initWithCapacity:5];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlay:) name:KDAudioControllerAudioStartPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlay:) name:KDAudioControllerAudioStopPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordInterrupt:) name:KDAudioControllerRecordInterruptionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageTaskFinished:) name:@"messageTaskFinished" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dmThreadSubjectChanged:) name:KDDMThreadSubjectDidChangeNofication object:nil];
    }
    
    return self;
}

- (id)initWithDMThread:(KDDMThread *)dmThread {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        dmThread_ = dmThread;// retain];
        
        //        if([dmThread_.threadId hasPrefix:@"tempThreadId"]) {
        dmThreadID_ = [dmThread_.threadId copy];
        //        }
    }
    
    return self;
}

- (id)initWithDMThreadID:(NSString *)dmThreadId {
    self = [self initWithNibName:nil bundle:nil];
    
    if(self) {
        dmThreadID_ = [dmThreadId copy];
        dmViewControllerFlags_.initialWithID = 1;
    }
    
    return self;
}

- (id)initWithParticipants:(NSArray *)participants {
    NSMutableArray *pars = [NSMutableArray arrayWithArray:participants];
    
    __block NSString *threadId = nil;
    if(participants.count == 2) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *db){
            id<KDDMThreadDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
            return [dao queryDMThreadsWithLimit:-1 database:db];
        }completionBlock:^(id results){
            NSArray *threads = (NSArray *)results;
            KDUser *theOtherUser = [participants objectAtIndex:0];
            if([theOtherUser.userId isEqualToString:[KDManagerContext globalManagerContext].userManager.currentUserId]) {
                theOtherUser = [participants objectAtIndex:1];
            }
            
            if(threads && threads.count) {
                for(KDDMThread *thread in threads) {
                    if(thread.participantsCount <= 2 && [thread.subject isEqualToString:theOtherUser.screenName]) {
                        threadId = thread.threadId;
                        break;
                    }
                }
            }
        }];
    }
    
    if(threadId == nil) {
        NSMutableString *tempID = [NSMutableString string];
        [tempID appendString:@"tempThreadId"];
        
        //sort pickedUsersArray_
        [pars sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            KDUser *user1 = (KDUser *)obj1;
            KDUser *user2 = (KDUser *)obj2;
            
            NSString *userId1 = user1.userId;
            NSString *userId2 = user2.userId;
            
            return [userId1 compare:userId2];
        }];
        
        for(KDUser *user in pars) {
            [tempID appendString:[NSString stringWithFormat:@"+%@", user.userId]];
        }
        
        threadId = tempID;
    }
    
    dmViewControllerFlags_.couldNotAddParticipant = 1;
    
    return [self initWithDMThreadID:threadId];
}

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
//    [aView release];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view.clipsToBounds = YES;
    
    // right bar button item
    if(dmViewControllerFlags_.couldNotAddParticipant == 0)
        [self setupJoinedUserBarButtonItem];
    
    /**
     *  修改背景颜色
     */
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
	KDRefreshTableView *tableView = [[KDRefreshTableView alloc] initWithFrame:frame kdRefreshTableViewType:KDRefreshTableViewType_Header style:UITableViewStylePlain];
    tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, KD_DM_CHAT_INPUT_VIEW_HEIGHT, 0.0f);
    self.messagesTableView = tableView;
//    [tableView release];
    
	messagesTableView_.delegate = self;
	messagesTableView_.dataSource = self;
    tableView.clipsToBounds = NO;
    
	messagesTableView_.backgroundColor = MESSAGE_BG_COLOR;
	messagesTableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
	
    messagesTableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    ((KDRefreshTableViewSideViewTopForiPhone *)messagesTableView_.topView).normalText = ASLocalizedString(@"KDDMConversationViewController_load_more");
    ((KDRefreshTableViewSideViewTopForiPhone *)messagesTableView_.topView).pullingText = ASLocalizedString(@"KDDMConversationViewController_release_load");
    messagesTableView_.showUpdataTime = NO;
    //    messagesTableView_.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 15.0f, 0.0f);
    
	[self.view addSubview:messagesTableView_];
    
    // toggle load more messages button visible state
    [self toggleMoreMessageButtonVisible];
    
    frame = CGRectMake(0, self.view.bounds.size.height - KD_DM_CHAT_INPUT_VIEW_HEIGHT, self.view.bounds.size.width, KD_DM_CHAT_INPUT_VIEW_HEIGHT);
    
    // Why to check the input view is not nil? If try to pick image from photo library and receive memory warning at that time.
    // Generally speaking, the views in current self view will be release. But the input view can not release if it has content.
    if(chatInputView_ == nil){
        KDDMChatInputView *chatInputView = [[KDDMChatInputView alloc] initWithFrame:CGRectZero delegate:self hostViewController:self];
        self.chatInputView = chatInputView;
//        [chatInputView release];
        chatInputView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    chatInputView_.frame = frame;
    [chatInputView_ renderLayerWithView:self.view withBorder:KDBorderPositionTop | KDBorderPositionBottom];
    [self.view addSubview:chatInputView_];
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [chatInputView_ resetReturnKeyStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [chatInputView_ addKeyboardNotification];
    
    NSArray *recogs = [self.view gestureRecognizers];
    
    for(UIGestureRecognizer *recog in recogs) {
        if([recog isKindOfClass:[UIPanGestureRecognizer class]]) {
            recog.delegate = self;
            [recog addTarget:self action:@selector(panGestureRecognizer:)];
            panrecognizer_ = (UIPanGestureRecognizer *)recog;
        }
    }
    
    
    dispatch_block_t block = ^{
        if(dmViewControllerFlags_.initialized == 0){
            dmViewControllerFlags_.initialized = 1;
            
            // delete status from database
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDDMMessageDAO> dmMessageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
                
                NSString *latestMessageId = [dmMessageDAO queryLatestDMMessageIdWithThreadId:dmThread_.threadId database:fmdb];
                dmThread_.nextSinceDMId = latestMessageId; // not thread safety, it's okay at here
                
                NSArray *messages = [dmMessageDAO queryDMMessagesWithThreadId:dmThread_.threadId limit:20 database:fmdb];
                
                
                NSMutableArray *unsendMessages = [NSMutableArray array];
                NSArray *unsendMessagesTemp = [dmMessageDAO queryUnsendDMMessagesWithThreadId:dmThread_.threadId database:fmdb];
                
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                KDUser *curUser = [userDAO queryUserWithId:[KDManagerContext globalManagerContext].userManager.currentUserId database:fmdb];
                id obj = nil;
                for(KDDMMessage *msg in unsendMessagesTemp) {
                    
                    //                    if ([[KDUploadTaskHelper shareUploadTaskHelper] isTaskOnRunning:msg.messageId])) {
                    //                        msg.messageState = KDDMMessageStateSending;
                    //                    }
                    obj = [[KDUploadTaskHelper shareUploadTaskHelper] entityById:msg.messageId];
                    if(obj) {
                        [unsendMessages addObject:obj];
                    }else {
                        msg.sender = curUser;
                        [unsendMessages addObject:msg];
                    }
                }
                
                NSMutableArray *result = [NSMutableArray arrayWithArray:unsendMessages];
                [result addObjectsFromArray:messages];
                
                return result;
            } completionBlock:^(id results) {
                self.messages = [NSMutableArray arrayWithArray:[[(NSArray *)results reverseObjectEnumerator] allObjects]];
                
                [messagesTableView_ reloadData];
                [self toggleMoreButtonEnabledWithLoading:NO];
                [self toggleMoreMessageButtonVisible];
                
                CGFloat diff = messagesTableView_.contentSize.height - messagesTableView_.bounds.size.height;
                contentOffset_.y = (diff > 0) ? diff : 0.0;
                
                messagesTableView_.contentOffset = contentOffset_;
                [self scrollToBottom];
                [self loadLatestMessages];
            }];
        }else {
            if(dmViewControllerFlags_.showFromGallary == 1) {
                dmViewControllerFlags_.showFromGallary = 0;
            }else {
                [self scrollToBottom];
            }
        }
        
        if(dmViewControllerFlags_.didReceiveMemoryWarning == 1){
            dmViewControllerFlags_.didReceiveMemoryWarning = 0;
        }
        
        if (dmViewControllerFlags_.doAddingParticipiant == 1) {
            dmViewControllerFlags_.doAddingParticipiant = 0;
            if (addedParicipants_ && [addedParicipants_ count] >0) {
                [self addParticipant];
            }
        }
    };
    
    
    if((dmViewControllerFlags_.initialWithID == 1 || [dmThread_.threadId hasPrefix:@"tempThreadId"])&& dmViewControllerFlags_.initialized == 0) {
        dmViewControllerFlags_.initialWithID = 0;
        
        if([dmThreadID_ hasPrefix:@"tempThreadId"] || [dmThread_.threadId hasPrefix:@"tempThreadId"]) {
            dmViewControllerFlags_.initialized = 1;
            [KDDatabaseHelper asyncInDatabase:^id(FMDatabase *fmdb){
                id<KDDMMessageDAO> dmMessageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
                NSArray *unsendMessages = [dmMessageDAO queryUnsendDMMessagesWithThreadId:dmThreadID_ database:fmdb];
                
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                KDUser *curUser = [userDAO queryUserWithId:[KDManagerContext globalManagerContext].userManager.currentUserId database:fmdb];
                
                for(KDDMMessage *msg in unsendMessages) {
                    msg.sender = curUser;
                }
                
                return unsendMessages;
            }completionBlock:^(id results){
                self.messages = [NSMutableArray arrayWithArray:[[(NSArray *)results reverseObjectEnumerator] allObjects]];
                
                [messagesTableView_ reloadData];
                [self toggleMoreButtonEnabledWithLoading:NO];
                [self toggleMoreMessageButtonVisible];
                
                CGFloat diff = messagesTableView_.contentSize.height - messagesTableView_.bounds.size.height;
                contentOffset_.y = (diff > 0) ? diff : 0.0;
                
                messagesTableView_.contentOffset = contentOffset_;
            }];
            
            NSArray *userIds = [dmThreadID_ componentsSeparatedByString:@"+"];
            if(userIds.count == 3) {
                [KDDatabaseHelper asyncInDatabase:^id(FMDatabase *fmdb){
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    
                    NSString *anotherId = [userIds objectAtIndex:1];
                    KDUser *user = nil;
                    //找到不是自己的
                    if([anotherId isEqualToString:[KDManagerContext globalManagerContext].userManager.currentUserId]) {
                        anotherId = [userIds objectAtIndex:2];
                    }
                    
                    if([anotherId isEqualToString:[KDManagerContext globalManagerContext].userManager.currentUserId]) {
                        user = [KDManagerContext globalManagerContext].userManager.currentUser;
                    }else {
                        user = [userDAO queryUserWithId:anotherId database:fmdb];
                    }
                    
                    return user;
                }completionBlock:^(id result) {
                    KDUser *user = (KDUser *)result;
                    self.navigationItem.title = user.screenName;
                }];
            }else {
                self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"DM_THREAD_TITLE_%@_%d_PERSONS", nil), NSLocalizedString(@"DM_MULTIPLE_SHORT_MAIL", @""), userIds.count - 1];
            }
        } else {
            KDQuery *query = [KDQuery queryWithName:@"threadId" value:dmThreadID_];
            
            __block KDDMConversationViewController *dmc = self;// retain];
            [MBProgressHUD showHUDAddedTo:dmc.view.window animated:YES];
            KDServiceActionDidCompleteBlock completeBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
                [MBProgressHUD hideHUDForView:dmc.view.window animated:YES];
                if([response isValidResponse]) {
                    KDDMThread *thread = (KDDMThread *)results;
                    dmc.dmThread = thread;
                    
                    block();
                }else if(![response isCancelled]) {
                    [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDDMConversationViewController_sms_null")inView:self.view.window];
                    
                    [dmc.navigationController popViewControllerAnimated:YES];
                }
                
//                [dmc release];
            };
            
            [KDServiceActionInvoker invokeWithSender:self actionPath:@"/dm/:threadById" query:query configBlock:nil completionBlock:completeBlock];
        }
    }else {
        block();
    }
    
    if(!updateTimer_ ) {
        updateTimer_ = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateAction) userInfo:nil repeats:YES];
    }
    
    if(dmViewControllerFlags_.shouldLoadMessage == 1) {
        dmViewControllerFlags_.shouldLoadMessage = 0;
        [self updateAction];
    }
    
}

- (void)updateAction {
    if(!(self.dmThreadID  && [self.dmThreadID hasPrefix:@"tempThreadId"])) {
        [self loadLatestMessages];
    }
}

- (void)saveMessageState {
    if(!dmThreadID_ || ![dmThreadID_ hasPrefix:@"tempThreadId"]) {
        NSMutableArray *messagesNeedToUpdate = [NSMutableArray arrayWithCapacity:2];
        NSString *curUserId = [KDManagerContext globalManagerContext].userManager.currentUserId;
        for(KDDMMessage *msg in self.messages) {
            if(![msg.sender.userId isEqualToString:curUserId]) {
                [messagesNeedToUpdate addObject:msg];
            }
        }
        
        [KDDatabaseHelper inTransaction:(id)^(FMDatabase *db, BOOL *rollback) {
            id<KDDMMessageDAO> msgDAO = [KDWeiboDAOManager globalWeiboDAOManager].dmMessageDAO;
            NSString *threadId = dmThread_.threadId;
            if(threadId == nil) threadId = dmThreadID_;
            
            [msgDAO saveDMMessages:messagesNeedToUpdate threadId:threadId database:db rollback:rollback];
            
            if(dmThread_ && threadId && ![threadId hasPrefix:@"tempThreadId"]) {
                id<KDDMThreadDAO> threadDAO = [KDWeiboDAOManager globalWeiboDAOManager].dmThreadDAO;
                [threadDAO saveDMThreads:@[dmThread_] database:db rollback:rollback];
            }
            
            return nil;
        } completionBlock:NULL];
    }
}

////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

// 需要获取老信息，当删除某个会话参与人成功后调用
- (void)shouldLoadMessages {
    dmViewControllerFlags_.shouldLoadMessage = 1;
}

- (void)setDmThread:(KDDMThread *)dmThread {
    if(dmThread_ !=dmThread) {
//        [dmThread_ release];
        dmThread_ = dmThread;// retain];
    }
    
    self.navigationItem.title = dmThread_.subject;
}

- (void)addParticipant {
    NSMutableString *IDs = [NSMutableString string];
    
    NSUInteger count = [addedParicipants_ count];
    NSUInteger idx = 0;
    for (KDUser *user in addedParicipants_) {
        [IDs appendString:user.userId];
        
        if(idx++ != count - 0x01){
            [IDs appendString:@","];
        }
    }
    
    NSString *threadID = self.dmThread.threadId;
    if(!threadID) threadID = self.dmThreadID;
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"id" stringValue:threadID]
     setParameter:@"participants" stringValue:IDs];
    [query setProperty:threadID forKey:@"threadId"];
    
    __block KDDMConversationViewController *dmvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if ([response isValidResponse]) {
            if (results != nil) {
                dmvc.dmThread = results;
                
                //重新添加成员后，根据返回id判断是否应清除原有数据（新id与原有id不同时清除） song.wang 2013-12-30
                if (![dmvc.dmThreadID isEqual:dmvc.dmThread.threadId]) {
                    dmvc.dmThreadID = dmvc.dmThread.threadId;
                    [dmvc.messages removeAllObjects];
                }
                
                //重新添加成员后，不应清除原有数据 song.wang 2013-12-27
                //                [dmvc.messages removeAllObjects];
                
                [dmvc.messagesTableView reloadData];
                [dmvc loadLatestMessages];
                
                // save the latest dm thread into database
                [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                    id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
                    [threadDAO saveDMThreads:@[results] database:fmdb rollback:rollback];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
            
        } else {
            if (![response isCancelled]) {
                [[KDNotificationView defaultMessageNotificationView] showInView:dmvc.view.window
                                                                        message:ASLocalizedString(@"KDDMConversationViewController_add_fail")type:KDNotificationViewTypeNormal];
            }
        }
        
        dmvc.addedParicipants = nil;
        
        // release current view controller
//        [dmvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:addParticipant" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)moreMessagesButtonVisible:(BOOL)visible {
    if(messagesTableView_.tableHeaderView == nil){
        CGRect rect = CGRectMake(0.0, 0.0, messagesTableView_.bounds.size.width, 48.0);
        UIView *containerView = [[UIView alloc] initWithFrame:rect];
        
        // more button
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake((rect.size.width - 240.0) * 0.5, (rect.size.height - 32.0) * 0.5, 240.0, 32.0);
        moreBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        moreBtn.tag = KD_DM_THREAD_LOAD_MORE_BTN_TAG;
        
        [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [moreBtn setTitle:NSLocalizedString(@"DM_THREAD_LOAD_MORE", @"") forState:UIControlStateNormal];
        
        UIImage *bgImage = [UIImage imageNamed:@"dm_thread_more_btn_bg.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:0.5*bgImage.size.width topCapHeight:0.5*bgImage.size.height];
        [moreBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
        
        [moreBtn addTarget:self action:@selector(loadOlderMessages) forControlEvents:UIControlEventTouchUpInside];
        
        [containerView addSubview:moreBtn];
        
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //        messagesTableView_.tableHeaderView = containerView;
//        [containerView release];
    }
    //    messagesTableView_.tableHeaderView.hidden = !visible;
    
}

- (void)toggleMoreMessageButtonVisible {
    BOOL visible = NO;
    
    // if messages are not nil and count reached to minimal count of page,
    // show the load older messages button.
    NSUInteger count = (messages_ != nil) ? [messages_ count] : 0;
    if(count > 0 && (count >= KD_DM_MAX_MESSAGES_COUNT_PER_PAGE)){
        visible = YES;
    }
    
    [self moreMessagesButtonVisible:visible];
}

- (void)toggleMoreButtonEnabledWithLoading:(BOOL)loading {
    // if more messages button not exists now, return directly.
    if(messagesTableView_.tableHeaderView == nil) return;
    
    BOOL enabled = NO;
    NSString *btnTitle = nil;
    if(loading){
        btnTitle = ASLocalizedString(@"RecommendViewController_Load");
        
    }else {
        enabled = ([self hasMessages] && ([messages_ count] >= KD_DM_MAX_MESSAGES_COUNT_PER_PAGE)) ? YES : NO;
        btnTitle = NSLocalizedString(@"DM_THREAD_LOAD_MORE", @"");
    }
    
    UIButton *moreBtn = (UIButton *)[messagesTableView_.tableHeaderView viewWithTag:KD_DM_THREAD_LOAD_MORE_BTN_TAG];
    [moreBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    moreBtn.enabled = enabled;
}

- (void) setupJoinedUserBarButtonItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"dm_joined_users_v3.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"dm_joined_users_hl_v3.png"] forState:UIControlStateHighlighted];
    [btn sizeToFit];
    
    [btn addTarget:self action:@selector(showParticipants) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    
    float width = kRightNegativeSpacerWidth;
    negativeSpacer.width = (width - 5.f);
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightBarItem, nil];
//    [rightBarItem release];
}

- (void) scrollToBottom {
    if (messages_ != nil && [messages_ count] > 1) {
        NSUInteger index = [messages_ count] - 1;
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0x00];
        [messagesTableView_ scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (BOOL) hasMessages {
    return messages_ != nil && [self.messages count] > 0x00;
}

- (void)loadLatestMessages {
    NSString *threadId = dmThreadID_;
    if(!threadId) {
        threadId = dmThread_.threadId;
    }
    
    if(!threadId || [threadId hasPrefix:@"tempThreadId"]) return;
    
    [self toggleMoreButtonEnabledWithLoading:YES];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"threadId" stringValue:threadId]
     setParameter:@"count" stringValue:@"20"];
    [query setProperty:threadId forKey:@"threadId"];
    
    if(!nextSinceDMId_ && dmThread_.nextSinceDMId) {
        self.nextSinceDMId = dmThread_.nextSinceDMId;
    }
    
    if (nextSinceDMId_) {
        [query setParameter:@"since_id" stringValue:nextSinceDMId_];
    }
    
    __block KDDMConversationViewController *dmvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        if ([response isValidResponse]) {
            NSArray *messages = nil;
            if (results != nil) {
                messages = (NSArray *)results;
                
                if([messages count] > 0){
                    // update next since id
                    KDDMMessage *message = [messages objectAtIndex:0];
                    dmvc.nextSinceDMId = message.messageId;
                    
                    // mark read
                    NSUInteger changedUnreadCount = dmvc.dmThread.unreadCount;
                    dmvc.dmThread.unreadCount = 0;
                    
                    //remove multi
                    NSMutableArray *shouldAddMessages = [NSMutableArray arrayWithCapacity:messages.count];
                    
                    KDDMMessage *msg = nil;
                    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
                    while (msg = [reverseEnumerator nextObject]) {
                        BOOL found = NO;
                        
                        for(KDDMMessage *m in dmvc.messages) {
                            if([m.messageId isEqualToString:msg.messageId]) {
                                found = YES;
                                break;
                            }
                        }
                        
                        if(!found) {
                            [shouldAddMessages addObject:msg];
                        }
                    }
                    
                    if(shouldAddMessages.count > 0)
                        [dmvc.messages addObjectsFromArray:shouldAddMessages];
                    
                    [dmvc sortMessages];
                    
                    // truncate the direct messages to make sure don't miss any direct messages in thread.
                    // eg. There are 100 direct messages in a thread, And current 50 messages (range[0, 49]) exists at local database now.
                    // So try to load latest 20 messages with range[80, 99] from network. If append them to database directly.
                    // Then the direct messages in range [50, 79] will be missed.
                    // If to do truncate direct messages, to make sure do load older direct messages can
                    // retrieve messages in range [50, 79]
                    
                    NSUInteger count = [dmvc.messages count];
                    if(count > KD_DM_MAX_MESSAGES_COUNT_PER_PAGE){
                        [dmvc.messages removeObjectsInRange:NSMakeRange(0, count - KD_DM_MAX_MESSAGES_COUNT_PER_PAGE)];
                    }
                    //不敢count值，每次调用delegate，修正thread列表未读数置空问题 song.wang 2014-01-13
                    // should change unread badge value
                    if(dmvc.delegate != nil
                       && [dmvc.delegate respondsToSelector:@selector(dmThread:didChangeUnreadCount:)]){
                        [dmvc.delegate dmThread:dmvc.dmThread didChangeUnreadCount:changedUnreadCount];
                    }
                    [dmvc.messagesTableView reloadData];
                    [dmvc scrollToBottom];
                }
                
            }else {
                //不敢count值，每次调用delegate，修正thread列表未读数置空问题 song.wang 2014-01-13
                if(dmvc.delegate != nil
                   && [dmvc.delegate respondsToSelector:@selector(dmThread:didChangeUnreadCount:)]){
                    [dmvc.delegate dmThread:dmvc.dmThread didChangeUnreadCount:0];
                }
            }
            
            //@modify-time:2013/10/16
            //@modify-reason:unused!
            //            if(dmvc.delegate != nil && [dmvc.delegate respondsToSelector:@selector(inboxPrivateMessageReset:)]){
            //                [dmvc.delegate inboxPrivateMessageReset:dmvc.dmThread];
            //            }
            
            
            // save direct message into database
            if (messages != nil) {
//                [dmvc retain]; // retain the view controller before async update database
                
                [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                    id<KDDMMessageDAO> messageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
                    [messageDAO saveDMMessages:messages threadId:dmvc.dmThread.threadId database:fmdb rollback:rollback];
                    
                    //                    BOOL fakeRollback = NO; // just ignore it's value
                    //                    id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
                    //                    if(dmvc.dmThread)
                    //                        [threadDAO saveDMThreads:@[dmvc.dmThread] database:fmdb rollback:&fakeRollback];
                    
                    return nil;
                    
                } completionBlock:^(id val){
//                    [dmvc release];
                }];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:dmvc.view.window];
                
            }
        }
        // release current view controller
//        [dmvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadMessages" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

// get more messages
- (void)loadOlderMessages {
    //    [self toggleMoreButtonEnabledWithLoading:YES];
    if (self.messages.count <= 0) {
        return;
    }
    
    NSString *threadId = dmThreadID_;
    if(!threadId) {
        threadId = dmThread_.threadId;
    }
    
    if(!threadId || [threadId hasPrefix:@"tempThreadId"]) return;
    
    KDDMMessage *dm = [self.messages objectAtIndex:0];
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"threadId" stringValue:threadId]
      setParameter:@"count" stringValue:@"20"]
     setParameter:@"max_id" stringValue:dm.messageId];
    
    [query setProperty:dmThread_.threadId forKey:@"threadId"];
    
    __block KDDMConversationViewController *dmvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                NSArray *messages = [[results reverseObjectEnumerator] allObjects];
                NSUInteger count = [messages count];
                if (count > 0) {
                    //修正闪退 更新界面在主线程 王松 2013-11-22
//                    [dmvc retain];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [dmvc.messagesTableView finishedRefresh:YES];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];
                        [dmvc.messages insertObjects:messages atIndexes:indexSet];
                        
                        CGPoint offset = CGPointMake(0.0, dmvc.messagesTableView.contentSize.height);
                        [dmvc.messagesTableView reloadData];
                        
                        offset.y = dmvc.messagesTableView.contentSize.height - offset.y;
                        [dmvc.messagesTableView setContentOffset:offset];
//                        [dmvc release];
                    });
                }
            }else {
//                dmvc retain];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dmvc.messagesTableView finishedRefresh:NO];
//                    [dmvc release];
                });
            }
            
        } else {
            if (![response isCancelled]) {
                //修正闪退 更新界面在主线程 王松 2013-11-22
//                [dmvc retain];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dmvc.messagesTableView finishedRefresh:NO];
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:dmvc.view.window];
//                    [dmvc release];
                });
            }
        }
        
        //        [dmvc toggleMoreButtonEnabledWithLoading:NO];
        //        [dmvc toggleMoreMessageButtonVisible];
        
        // release current view controller
//        [dmvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadMessages" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
- (void)sortMessages {
    //@modify-time:2013年10月31日09:51:38
    //@modify-reason:短邮不能正确排序
    //@modify-by:shenkuikui
    [self.messages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        
        KDDMMessage *msg1 = (KDDMMessage *)obj1;
        KDDMMessage *msg2 = (KDDMMessage *)obj2;
        
        if(msg1.createdAt > msg2.createdAt) {
            result = NSOrderedDescending;
        }else if(msg1.createdAt < msg2.createdAt) {
            result = NSOrderedAscending;
        }
        
        return result;
    }];
    
    if(self.messages && self.messages.count > 0) {
        NSUInteger index = 0;
        NSUInteger count = self.messages.count;
        while (index < count) {
            KDDMMessage *msg = [self.messages objectAtIndex:index];
            if(msg.messageState & KDDMMessageStateUnsend) {
//                [msg retain];
                [self.messages removeObjectAtIndex:index];
                [self.messages addObject:msg];
//                [msg release];
                count--;
            }else {
                index++;
            }
        }
    }
}

- (void) showParticipants {
    KDDMThreadMembersViewController *tmvc = [[KDDMThreadMembersViewController alloc] init];
    if(self.dmThread && self.dmThread.threadId) {
        tmvc.dmThread = self.dmThread;
    }
    else {
        tmvc.dmThreadId = self.dmThreadID;
    }
    
    tmvc.conversationViewController = self;
    
    [self.navigationController pushViewController:tmvc animated:YES];
//    [tmvc release];
}

- (void) didTapOnThumbnailView:(KDThumbnailView *)thumbnailView {
    self.tappedOnImageDataSource = thumbnailView.imageDataSource;
    
    // show photo gallery
    KDPhotoGalleryViewController *pgvc = [[KDPhotoGalleryViewController alloc] initWithNibName:nil bundle:nil];
    pgvc.dataSource = self;
    pgvc.photoSourceURLs = [tappedOnImageDataSource_ bigImageURLs];
    dmViewControllerFlags_.showFromGallary = 1;
    
    [self presentViewController:pgvc animated:YES completion:nil];
//    [pgvc release];
}

- (void)didTapOnAttachmentView:(UIButton *)btn {
    CGPoint point = [btn convertPoint:btn.frame.origin toView:messagesTableView_];
    NSIndexPath *indexPath = [messagesTableView_ indexPathForRowAtPoint:point];
    if(indexPath != nil){
        KDDMMessage *dm = [messages_ objectAtIndex:indexPath.row];
        
        if([dm hasAudio]) {
            [[KDAudioController sharedInstance] playAudioForMessage:dm];
            return;
        }
        
        KDAttachmentViewController *attachmentViewController = [[KDAttachmentViewController alloc] initWithSource:dm];
        [self.navigationController pushViewController:attachmentViewController animated:YES];
//        [attachmentViewController release];
    }
}

- (void)showRecordView {
    if(self.recordView == nil) {
        self.recordView = [KDAudioRecordView audioRecordView];
        recordView_.center = CGPointMake(self.view.bounds.size.width * 0.5f, self.view.bounds.size.height * 0.5f);
    }
    
    if(self.recordView.superview != self.view) {
        [self.view addSubview:self.recordView];
    }
    
    self.recordView.hidden = NO;
    self.view.userInteractionEnabled = YES;
    [recordView_ startRecord];
}

- (void)dismissRecordView {
    if(![[KDAudioController sharedInstance] isRecording]) {
        if(self.recordView) {
            self.recordView.hidden = YES;
        }
        
        if(self.maskView) {
            self.maskView.hidden = YES;
        }
    }
}

//this gesture recognizer for record audio only.
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:self.view];
    
    if(pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed) {
        if(isRecording_) {
            isRecording_ = NO;
            
            if(fabs(panStartPoint_.y - location.y) > 50.0f) {
                [self terminateRecord:YES];
            } else {
                [self terminateRecord:NO];
            }
            
            [chatInputView_.recordBtn setSelected:NO];
            [panrecognizer_ addTarget:self.navigationController action:@selector(panned:)];
        }
    }else if(pan.state == UIGestureRecognizerStateChanged) {
        if(isRecording_) {
            if (fabs(panStartPoint_.y - location.y) > 50.0f) {
                [recordView_ showOrHiddeCancelMessage:YES];
            }else {
                [recordView_ showOrHiddeCancelMessage:NO];
            }
        }
    }else if(pan.state == UIGestureRecognizerStateBegan) {
        if([chatInputView_ isFirstResponder]) {
            [chatInputView_ resignFirstResponderIfNeed];
        }
        
        if(isRecording_)
            panStartPoint_ = location;
    }
}

- (void)audioDurationChanged:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    CGFloat duration = [[userInfo objectForKey:KDAudioControllerAudioDurationUserInfoKey] floatValue];
    
    [self.recordView setDuration:MAX(duration - 1, 0)];
    
    if(duration == 61) {
        [self dmChatInputViewEndRecord:self.chatInputView];
    }
}

- (void)audioVolumeChanged:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    
    CGFloat currentVolume = [[userInfo objectForKey:KDAudioControllerAudioMeteringUserInfoKey] floatValue];
    CGFloat interval = [[userInfo objectForKey:KDAudioControllerAudioMeteringChangedIntervalUserInfoKey] floatValue];
    
    [self.recordView setVolume:currentVolume andInterval:interval];
}

- (void)presentController:(UIViewController *)viewController {
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:viewController animated:YES completion:nil];
    }else {
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
}

- (NSMutableArray *)taskArray {
    if(taskArray_ == nil) {
        taskArray_ = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return taskArray_;
}

- (void)sensorStateChanged:(NSNotification *)noti {
    if(![[UIDevice currentDevice] proximityState]) {
        [self showTipView];
    }
}

- (void)showTipView {
    if(!tipView_) {
        tipView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 30.0f)];
        tipView_.alpha = 0.9f;
        tipView_.backgroundColor = [UIColor darkGrayColor];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"×" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(hiddeTipView) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(tipView_.bounds.size.width - 10.0f - 20.0f, 5.0f, 20.0f, 20.0f);
        [tipView_ addSubview:btn];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.text = ASLocalizedString(@"KDDMConversationViewController_tips1");
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel sizeToFit];
        
        titleLabel.frame = CGRectMake((tipView_.bounds.size.width - titleLabel.bounds.size.width) * 0.5f, (tipView_.bounds.size.height - titleLabel.bounds.size.height) * 0.5f, titleLabel.bounds.size.width, titleLabel.bounds.size.height);
        
        [tipView_ addSubview:titleLabel];
//        [titleLabel release];
    }
    
    tipView_.alpha = 0.0f;
    [self.view addSubview:tipView_];
    
    [UIView animateWithDuration:0.5f animations:^(void){
        tipView_.alpha = 1.0f;
    }completion:^(BOOL finished) {
        if(finished)
            [self performSelector:@selector(hiddeTipView) withObject:nil afterDelay:2.0f];
    }];
}

- (void)hiddeTipView {
    if(tipView_ && tipView_.superview) {
        [UIView animateWithDuration:0.5f animations:^(void){
            tipView_.alpha = 0.0f;
        }completion:^(BOOL finished){
            [tipView_ removeFromSuperview];
//            [tipView_ release];
            tipView_ = nil;
        }];
    }
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark KDMultipleImagePickerDelegate methods

- (void)didSelectedImageItems:(NSArray *)array {
    self.selectedImageItems = array;
}

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (messages_ != nil) ? [messages_ count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    KDDMMessage<ChatBubbleCellDataSource>  *current = [messages_ objectAtIndex:index];
    
    NSTimeInterval interval = -1;
    if (index >= 1) {
        KDDMMessage *previous = nil;
        
        for(NSInteger i = index - 1; i >= 0 ; i--) {
            KDDMMessage *msg = [messages_ objectAtIndex:i];
            if([[msg propertyForKey:@"kddmmessage_is_need_stamp"] boolValue]) {
                previous = msg;
                break;
            }
        }
        
        if(previous)
            interval = current.createdAt - previous.createdAt;
    }
    
    if([current hasAudio])
        return [KDAudioBubbleCell heightForAudioInMessage:current interval:interval];
    
    return [ChatBubbleCell directMessageHeightInCell:current interval:interval];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KDDMMessage<ChatBubbleCellDataSource> *msg = [messages_ objectAtIndex:indexPath.row];
    
    if([msg hasAudio]) {
        static NSString *audioCellIdentifier = @"AudioBubbleCell";
        KDAudioBubbleCell *cell = nil;
        if(cell == nil) {
            cell = [[KDAudioBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioCellIdentifier];// autorelease];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        cell.message = msg;
        cell.delegate = self;
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"ChatBubbleCell";
        //    ChatBubbleCell *cell = (ChatBubbleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        ChatBubbleCell *cell = nil;
        if (cell == nil) {
            cell = [[ChatBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
            cell.delegate = self;
            
            cell.detailsView.thumbnailView.delegate = self;
            [cell.detailsView.thumbnailView addTarget:self action:@selector(didTapOnThumbnailView:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.detailsView.attachmentIndicatorView.indicatorButton addTarget:self action:@selector(didTapOnAttachmentView:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.message = msg;
        
        if(!tableView.dragging && !tableView.decelerating){
            [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
            
            if(!cell.detailsView.thumbnailView.hasThumbnail && !cell.detailsView.thumbnailView.loadThumbnail){
                [cell.detailsView.thumbnailView setLoadThumbnail:YES];
            }
        }
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if(menuController.isMenuVisible){
        [menuController setMenuVisible:NO];
    }
}

- (void)loadImageSourceIfNeed {
    [KDAvatarView loadImageSourceForTableView:messagesTableView_];
    
    NSArray *cells = [messagesTableView_ visibleCells];
	if(cells != nil){
        for(ChatBubbleCell *cell in cells){
            if([cell isKindOfClass:[KDAudioBubbleCell class]]) {
                //todo
                continue;
            }
            if(!cell.detailsView.thumbnailView.hasThumbnail && !cell.detailsView.thumbnailView.loadThumbnail){
                [cell.detailsView.thumbnailView setLoadThumbnail:YES];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(KDRefreshTableView *)scrollView kdRefreshTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self loadImageSourceIfNeed];
	}
    [(KDRefreshTableView *)scrollView kdRefreshTableviewDidEndDraging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImageSourceIfNeed];
}

#pragma mark - KDRefreshTableViewDelegate methods
- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableVie{
    [self loadOlderMessages];
}

- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView {
    
}

#pragma mark - KDRefreshTableViewDataSource method
KDREFRESHTABLEVIEW_REFRESHDATE

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDMChatInputView delegate methods

- (void) presentImagePickerForDMChatInputView:(KDDMChatInputView *)dmChatInputView takePhoto:(BOOL)takePhoto {
    dmViewControllerFlags_.showingImagePicker = 1;
    
    if (takePhoto) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
//        [picker release];
    }else {
        KDImagePickerController *picker = [[KDImagePickerController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];// autorelease];
        picker.allowsMultipleSelection = NO;
        picker.delegate = self;
        [self presentViewController:nav animated:YES completion:nil];
//        [picker release];
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication  sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication  sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

- (void)presentLocationSelectView:(KDDMChatInputView *)dmChatInputView {
    KDDMLocationSelectViewController *locationView = [[KDDMLocationSelectViewController alloc] initWithNibName:nil bundle:nil];
    locationView.hostViewController = self;
    //locationView.mapView = [[KDWeiboAppDelegate getAppDelegate]mapView];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:locationView];
//    [locationView release];
    
    if([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:nav animated:YES completion:NULL];
    }else {
        [self presentViewController:nav animated:YES completion:nil];
    }
    
//    [nav release];
}



- (KDDMMessage *)localMessageWithType:(KDDMSendType)type locationDataIfHas:(KDLocationData *)location needMail:(BOOL *)mailChecked{
    KDDMMessage *msg = [[KDDMMessage alloc] init];
    BOOL needClearText = NO;
    
    //只有发送文本时，才同时发送邮件 王松 2013-12-28
    if(mailChecked) {
        *mailChecked = chatInputView_.checkedMail && type == KDDMSendType_Text;
    }
    
    msg.threadId = self.dmThread ? self.dmThread.threadId : self.dmThreadID;
    
    msg.createdAt = [[NSDate date] timeIntervalSince1970];
    msg.messageId = [NSString stringWithFormat:@"%lf", msg.createdAt];
    msg.messageState = KDDMMessageStateUnsend | KDDMMessageStateSending;
    msg.unread = NO;
    
    msg.sender = [KDManagerContext globalManagerContext].userManager.currentUser;
    msg.message = chatInputView_.text;
    switch (type) {
        case KDDMSendType_Text:
            needClearText = YES;
            break;
        case KDDMSendType_Photo:
            msg.message = ASLocalizedString(@"KDDMMessageDAOImpl_share_picture");
            
            NSString *fileNewPath = [[[KDUtility defaultUtility] searchDirectory:KDPicturesUnsendDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES] stringByAppendingPathComponent:[msg.messageId MD5DigestKey]];
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:chatInputView_.pickedImage.cachePath]];
            
            NSData *data = [image asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
            [[KDCache sharedCache] storeImageData:data forURL:fileNewPath imageType:KDCacheImageTypePreview];
            [[KDCache sharedCache] storeImageData:data forURL:fileNewPath imageType:KDCacheImageTypeOrigin];
            
            data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
            [[KDCache sharedCache] storeImageData:data forURL:fileNewPath imageType:KDCacheImageTypePreviewBlur];
            
            data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
            [[KDCache sharedCache] storeImageData:data forURL:fileNewPath imageType:KDCacheImageTypeMiddle];
            [[KDCache sharedCache] storeImageData:data forURL:fileNewPath imageType:KDCacheImageTypeThumbnail];
            
            [[NSFileManager defaultManager] moveItemAtPath:chatInputView_.pickedImage.cachePath toPath:fileNewPath error:NULL];
            
            KDImageSource *imagesource = [[KDImageSource alloc] init];
            imagesource.thumbnail = fileNewPath;
            imagesource.middle = fileNewPath;
            imagesource.original = fileNewPath;
            imagesource.rawFileUrl = fileNewPath;
            KDCompositeImageSource *cis = [[KDCompositeImageSource alloc] initWithImageSources:@[imagesource]];
            cis.entity = msg;
            msg.compositeImageSource = cis;
//            [cis release];
//            [imagesource release];
            break;
//        case KDDMSendType_Audio:
//            msg.message = ASLocalizedString(@"KDDMConversationViewController_share_voice");
//            KDAttachment *att = [[KDAttachment alloc] init];
//            att.url = self.audioFilePath;
//            msg.attachments = [NSArray arrayWithObject:att];
////            [att release];
//            self.audioFilePath = nil;
//            break;
//        case KDDMSendType_Location:
//            msg.message = ASLocalizedString(@"KDDMConversationViewController_share_location");
//            msg.latitude = location.coordinate.latitude;
//            msg.longitude = location.coordinate.longitude;
//            msg.address = location.name;
//            break;
//        default:
//            break;
    }
    
    [chatInputView_ reset:needClearText];
    
    return msg;// autorelease];
}

- (NSInteger)availableTag {
    NSInteger tag = -1;
    NSUInteger count = messageIdToTag_.count;
    for(NSUInteger index = 0; index < count; index++) {
        id messageId = [messageIdToTag_ objectAtIndex:index];
        if([messageId isKindOfClass:[NSNull class]]) {
            tag = index;
            break;
        }
    }
    
    if(tag == -1)
        tag = count;
    
    return tag;
}

- (void)sendLocation:(KDLocationData *)locationData {
    [self sendContentsInDMChatInputView:chatInputView_ WithType:KDDMSendType_Location locationDataIfHas:locationData];
}

//需要发送的短邮内容类型:1.文字  2图片  3.位置（见上一个方法） 4.语音
- (void)sendContentsInDMChatInputView:(KDDMChatInputView *)dmChatInputView {
    if(self.audioFilePath) {
        [self sendContentsInDMChatInputView:dmChatInputView WithType:KDDMSendType_Audio locationDataIfHas:nil ];
    }else if(dmChatInputView.pickedImage.cachePath) {
        [self sendContentsInDMChatInputView:dmChatInputView WithType:KDDMSendType_Photo locationDataIfHas:nil ];
    }else {
        [self sendContentsInDMChatInputView:dmChatInputView WithType:KDDMSendType_Text locationDataIfHas:nil ];
    }
}

- (void)sendContentsInDMChatInputView:(KDDMChatInputView *)dmChatInputView WithType:(KDDMSendType)type locationDataIfHas:(KDLocationData *)location {
    BOOL needMail = NO;
    KDDMMessage* message = [self localMessageWithType:type locationDataIfHas:location needMail:&needMail];
    [KDDatabaseHelper asyncInDatabase:^id(FMDatabase *fmdb){
        id<KDDMMessageDAO> msgDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
        [msgDAO saveUnsendDMMessage:message database:fmdb rollback:NULL];
        return nil;
    }completionBlock:NULL];
    
    KDMessageUploadTask *task = [KDMessageUploadTask taskWithMessage:message sendEmail:needMail];
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:message.messageId];
    [self.messages addObject:message];
    
    [self.messagesTableView beginUpdates];
    [self.messagesTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messages count] -1  inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [self.messagesTableView endUpdates];
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self changeTableViewHeightToFitDMChatInputView:chatInputView_ animated:NO];
        [self performSelector:@selector(showBottomOfTableView:) withObject:self.messagesTableView afterDelay:0.1];
    });
    
    
    //    [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count] -1  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    //    [self scrollToBottom];
}

- (void)showBottomOfTableView:(UITableView *)view {
    if(view.dataSource) {
        NSInteger sections = 1;
        if([view.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
            sections = [view.dataSource numberOfSectionsInTableView:view];
        
        if(sections > 0) {
            NSInteger rowOfLastSection = [view.dataSource tableView:view numberOfRowsInSection:sections - 1];
            
            if(rowOfLastSection > 0)
                [view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowOfLastSection - 1 inSection:sections - 1] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
}

- (void)startRecord {
    BOOL success = NO;
    [[KDAudioController sharedInstance] startRecordWithTempID:dmThread_.threadId success:&success];
    if (success) {
        [self showRecordView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDurationChanged:) name:KDAudioControllerAudioDurationChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioVolumeChanged:) name:KDAudioControllerAudioMeteringChangedNotification object:nil];
    }else {
        [KDErrorDisplayView showErrorMessage:ASLocalizedString(@"KDDMConversationViewController_un_support_record1")inView:self.view.window];
    }
    
}

- (void)terminateRecord:(BOOL)isCancel {
    if([[KDAudioController sharedInstance] isRecording]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAudioControllerAudioDurationChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAudioControllerAudioMeteringChangedNotification object:nil];
        
        [[KDAudioController sharedInstance] stopRecordWithTempID:dmThread_.threadId];
        
        [self.recordView endRecord];
        [chatInputView_.recordBtn setSelected:NO];
        if(isCancel) {
            self.audioFilePath = nil;
            [self dismissRecordView];
        } else {
            self.audioFilePath = [[KDAudioController sharedInstance] curFilePath];
            
            if([KDAudioController sharedInstance].duration <= 1.0f) {
                [self performSelector:@selector(dismissRecordView) withObject:nil afterDelay:1.5f];
            }else {
                [self sendContentsInDMChatInputView:self.chatInputView];
                [self dismissRecordView];
            }
        }
    }
}

- (void)didChangeDMChatInputViewVisibleHeight:(KDDMChatInputView *)dmChatInputView {
    [self changeTableViewHeightToFitDMChatInputView:dmChatInputView animated:YES];
}

/**
 *  键盘弹出调整高度
 *
 *  @param dmChatInputView
 *  @param animated
 *
 * modified 王松 2013-11-19
 * 设置了tableview contentInset，顾需在原来高度上 + KD_DM_CHAT_INPUT_VIEW_HEIGHT
 */
- (void)changeTableViewHeightToFitDMChatInputView:(KDDMChatInputView *)dmChatInputView animated:(BOOL)animated {
    
    panrecognizer_.enabled = !dmChatInputView.isFirstResponder;
    
    CGFloat visibleHeight = dmChatInputView.frame.origin.y - [dmChatInputView extendViewHeight];
    CGSize contentSize = messagesTableView_.contentSize;
    CGFloat originY = messagesTableView_.frame.origin.y;
    CGFloat nY = 0.0f;
    
//    if(contentSize.height < messagesTableView_.frame.size.height && messages_.count <= 3) {
//        nY = visibleHeight - contentSize.height + KD_DM_CHAT_INPUT_VIEW_HEIGHT;
//    }else {
//        nY = visibleHeight - messagesTableView_.frame.size.height + KD_DM_CHAT_INPUT_VIEW_HEIGHT;
//    }
    if(contentSize.height < visibleHeight) {
        nY = 0.0f;
    }else if(contentSize.height < messagesTableView_.frame.size.height) {
        nY = visibleHeight - contentSize.height;
    }else {
        nY = visibleHeight - messagesTableView_.frame.size.height + KD_DM_CHAT_INPUT_VIEW_HEIGHT;
    }

    
    nY = MIN(nY, 0.0f);
    
    if(originY != nY) {
        //        [UIView animateWithDuration:0.25f animations:^(void) {
        CGRect f = messagesTableView_.frame;
        
        f.origin.y = nY;
        
        messagesTableView_.frame = f;
        //        }];
    }
}

- (void)dmChatInputViewBeginRecord:(KDDMChatInputView *)dmChatInputView {
    DLog(@"start record...");
    if([[KDAudioController sharedInstance] recordPermissionGranted]) {
        [dmChatInputView.recordBtn setSelected:YES];
        [self startRecord];
        isRecording_ = YES;
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDDMConversationViewController_un_support_record2")message:ASLocalizedString(@"KDDMConversationViewController_tips_mic")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alert show];
//        [alert release];
    }
}

- (void)dmChatInputViewEndRecord:(KDDMChatInputView *)dmChatInputView {
    if([[KDAudioController sharedInstance] recordPermissionGranted]) {
        [dmChatInputView.recordBtn setSelected:NO];
        [self terminateRecord:NO];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDRequestWrapper delegate methods

- (void) requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request progressMonitor:(KDRequestProgressMonitor *)progressMonitor {
    if([chatInputView_ hasAttachments]){
        float percent = [progressMonitor finishedPercent];
        
        NSString *info = nil;
        if(percent + 0.000001 > 1.0) {
            info = NSLocalizedString(@"REQUEST_ON_PROCESSING...", @"");
            
        }else {
            info = [NSString stringWithFormat:NSLocalizedString(@"UPLOAD_PROGESS_%@_%@", @""), [progressMonitor finishedPercentAsString], [progressMonitor finishedBytesAsString]];
        }
        
        [chatInputView_ setProgress:percent info:info];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDPhotoGalleryViewController data source methods

- (id<KDImageDataSource>)imageSourceForPhotoGalleryViewController:(KDPhotoGalleryViewController *)photoGalleryViewController {
    return tappedOnImageDataSource_;
}

#pragma mark -
#pragma mark KDPicturePickedPreviewViewControllerDelegate  method
- (void)confirmSeleted:(UIImage*)image {
    
    // remove previous picked images
    
    // [self willSavePickedImage:image isImagePicker:YES];
    [chatInputView_ setPickedPhoto:image];
    dmViewControllerFlags_.showingImagePicker = 0;
    
}

- (void)cancleSelected {
    dmViewControllerFlags_.showingImagePicker = 0;
}
////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
        if(UTTypeConformsTo(mediaType, kUTTypeImage)){
            
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                [self confirmSeleted:image];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }else {
                //self.pictrurePreViewVC.image = image;
                //[picker pushViewController:self.pictrurePreViewVC animated:YES];
                KDPicturePickedPreviewViewController *pvc = [[KDPicturePickedPreviewViewController alloc] init];
                pvc.image = image;
                pvc.delegate = self;
                
                [picker pushViewController:pvc animated:YES];
//                [pvc release];
                
            }
        }
    }else {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [self confirmSeleted:image];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    dmViewControllerFlags_.showingImagePicker = 0;
}


//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDThumbnailView delegate method

- (void)thumbnailView:(KDThumbnailView *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail {
    KDCompositeImageSource *compositeImageSource = thumbnailView.imageDataSource;
    KDDMMessage *message = compositeImageSource.entity;
    if (message != nil) {
        NSUInteger index = [messages_ indexOfObject:message];
        if(NSNotFound != index){
            NSArray *visibleRows = [messagesTableView_ indexPathsForVisibleRows];
            NSIndexPath *target = [NSIndexPath indexPathForRow:index inSection:0x00];
            
            BOOL found = NO;
            for(NSIndexPath *indexPath in visibleRows){
                if([indexPath compare:target] == NSOrderedSame){
                    found = YES;
                    break;
                }
            }
            
            if(found){
                [messagesTableView_ reloadRowsAtIndexPaths:[NSArray arrayWithObject:target] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIViewController navigation category method

- (BOOL)viewControllerShouldDismiss {
    //    if (dmViewControllerFlags_.hasDMPostRequest == 0 && [chatInputView_ hasContent]) {
    //        UIAlertView * alterView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"DM_ASK_SAVE_CONTENTS", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"YES", @"") otherButtonTitles:NSLocalizedString(@"NO", @""), nil];
    //        [alterView show];
    //
    //        [alterView release];
    //
    //        return NO;
    //
    //    }else if(dmViewControllerFlags_.hasDMPostRequest == 1) {
    //        if (backOnSendingAlertView_ == nil) {
    //            UIAlertView * alterView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"DM_ASK_BACK_ON_SENDING", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"YES", @"") otherButtonTitles:NSLocalizedString(@"NO", @""), nil];
    //            self.backOnSendingAlertView = alterView;
    //            [alterView release];
    //        }
    //        [self.backOnSendingAlertView show];
    //        return NO;
    //    }else {
    //        dmViewControllerFlags_.navigateToPrevious = 1;
    //    }
    
    return YES;
}

- (void)viewControllerWillDismiss {
    // if navigate to previous view controller, If input view is first responder now,
    // Then the keyboard will hide notification will sending from notification center.
    // Make current object ignore the delegate methods from input view after it was dealloced
    chatInputView_.delegate = nil;
    
    // cancel the requests
    [[KDRequestDispatcher globalRequestDispatcher] cancelRequestsWithDelegate:self force:YES];
}

//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        dmViewControllerFlags_.navigateToPrevious = 1;
        
        // make the text view to resign first responder
        chatInputView_.delegate = nil;
        [chatInputView_ resignFirstResponderIfNeed];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == backOnSendingAlertView_) {
        
        //KD_RELEASE_SAFELY(backOnSendingAlertView_);
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    [self saveMessageState];
    contentOffset_ = messagesTableView_.contentOffset;
}

- (void)viewDidDisappear:(BOOL)animated {
    if(updateTimer_) {
        if([updateTimer_ isValid])
            [updateTimer_ invalidate];
        
        updateTimer_ = nil;
    }
    
    [chatInputView_ removeKeyboardNotification];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    dmViewControllerFlags_.didReceiveMemoryWarning = 1;
    contentOffset_ = messagesTableView_.contentOffset;
    
    messagesTableView_.delegate = nil;
    messagesTableView_.dataSource = nil;
    //KD_RELEASE_SAFELY(messagesTableView_);
    
    // If there are any content in input view or showing image picker now,
    // don't release the input view now.
    if (dmViewControllerFlags_.showingImagePicker == 0 && ![chatInputView_ hasContent]) {
        //KD_RELEASE_SAFELY(chatInputView_);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KDDMThreadSubjectDidChangeNofication
                                                  object:nil];
}


//当前会话为临时会话，并且删除人的时候调用
- (void)deleParticipiant:(NSArray *)users {
    NSMutableArray *userIds = [NSMutableArray array];
    
    [userIds addObjectsFromArray:[users valueForKeyPath:@"userId"]];
    [userIds sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSString *str1 = (NSString *)obj1;
        NSString *str2 = (NSString *)obj2;
        
        return [str1 compare:str2];
    }];
    
    NSMutableString *threadId = [NSMutableString string];
    [threadId appendString:@"tempThreadId"];
    for(NSString *userId in userIds) {
        [threadId appendString:@"+"];
        [threadId appendString:userId];
    }
    self.dmThreadID = threadId;
    
    NSMutableArray *ids = [NSMutableArray arrayWithArray:[self.dmThreadID componentsSeparatedByString:@"+"]];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"DM_THREAD_TITLE_%@_%d_PERSONS", nil), NSLocalizedString(@"DM_MULTIPLE_SHORT_MAIL", @""), ids.count - 1];
    
    if(self.dmThread) {
        //
        self.dmThread.threadId = self.dmThreadID;
        self.dmThread.participantsCount = ids.count -1;
        [ids removeObjectAtIndex:0];
        self.dmThread.participantIDs = [self.dmThreadID stringByReplacingOccurrencesOfString:@"+" withString:@","];
        self.dmThread.subject = self.navigationItem.title;
    }
    
}

#pragma mark - KDFrequentContactsPickViewControllerDelegate
- (void)frequentContactsPickViewController:(KDFrequentContactsPickViewController *)fcpvc pickedUsers:(NSArray *)users {
    if((dmThreadID_ && [dmThreadID_ hasPrefix:@"tempThreadId"])||([self.dmThread.threadId hasPrefix:@"tempThreadId"])) {
        NSArray *curUserIds = [dmThreadID_ componentsSeparatedByString:@"+"];
        NSMutableArray *userIds = [NSMutableArray arrayWithArray:curUserIds];
        [userIds removeObjectAtIndex:0];
        
        [userIds addObjectsFromArray:[users valueForKeyPath:@"userId"]];
        
        [userIds sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSString *str1 = (NSString *)obj1;
            NSString *str2 = (NSString *)obj2;
            
            return [str1 compare:str2];
        }];
        
        NSMutableString *threadId = [NSMutableString string];
        [threadId appendString:@"tempThreadId"];
        for(NSString *userId in userIds) {
            [threadId appendString:@"+"];
            [threadId appendString:userId];
        }
        
        self.dmThreadID = threadId;
        
        NSMutableArray *ids = [NSMutableArray arrayWithArray:[self.dmThreadID componentsSeparatedByString:@"+"]];
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"DM_THREAD_TITLE_%@_%d_PERSONS", nil), NSLocalizedString(@"DM_MULTIPLE_SHORT_MAIL", @""), ids.count - 1];
        
        if(self.dmThread) {
            //
            self.dmThread.threadId = self.dmThreadID;
            self.dmThread.participantsCount = ids.count -1;
            [ids removeObjectAtIndex:0];
            self.dmThread.participantIDs = [self.dmThreadID stringByReplacingOccurrencesOfString:@"+" withString:@","];
            self.dmThread.subject = self.navigationItem.title;
        }
        
    } else if((self.dmThread && ![self.dmThread.threadId hasPrefix:@"tempThreadId"])||(![self.dmThreadID hasPrefix:@"tempThreadId"])) {
        self.addedParicipants = users;
        dmViewControllerFlags_.doAddingParticipiant = 1;
    }
}

#pragma mark - KDAudioBubbleCellDelegate Methods
- (void)audioBubbleCellTapInSpeaker:(KDAudioBubbleCell *)audioBubbleCell {
    
}

- (void)audioBubbleCellTapInWarning:(KDAudioBubbleCell *)audioBubbleCell {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"DM_AUDIO_RESEND"), ASLocalizedString(@"KDAttachmentMenuCell_del"), nil];
    sheet.destructiveButtonIndex = 0x01;
    curBubbleCell_ = audioBubbleCell;
    [sheet showInView:self.view];
//    [sheet release];
}

#pragma mark - CahtBubbleCellDelegate Methods
- (void)didTapWarnningImageInChatBubbleCell:(ChatBubbleCell *)cell {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"DM_AUDIO_RESEND"),ASLocalizedString(@"KDAttachmentMenuCell_del"), nil];
    sheet.destructiveButtonIndex = 0x01;
    curBubbleCell_ = cell;
    [sheet showInView:self.view];
//    [sheet release];
}

- (void)resendMessage:(KDDMMessage*)message {
    if(message) {
        KDUploadTask *task = [KDMessageUploadTask taskWithMessage:message sendEmail:NO];
        [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:message.messageId];
        
        [messagesTableView_ reloadData];
    }
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(curBubbleCell_) {
        KDDMMessage *msg = nil;
        if([curBubbleCell_ isKindOfClass:[ChatBubbleCell class]]) {
            msg = [(ChatBubbleCell *)curBubbleCell_ message];
        }else if([curBubbleCell_ isKindOfClass:[KDAudioBubbleCell class]]) {
            msg = [(KDAudioBubbleCell *)curBubbleCell_ message];
        }
        
        if(msg) {
            if(0x00 == buttonIndex) {
                //重新发送
                [self resendMessage:msg];
                
            }else if(0x01 == buttonIndex) {
                //delete
                [KDDatabaseHelper asyncInDatabase:^id(FMDatabase *fmdb){
                    id<KDDMMessageDAO> messageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
                    [messageDAO removeUnsendDMMessageWithId:msg.messageId database:fmdb];
                    
                    if([msg hasPicture]) {
                        KDImageSource *is = [[[msg compositeImageSource] imageSources] lastObject];
                        if (is.thumbnail) {
                            [[NSFileManager defaultManager] removeItemAtPath:is.thumbnail error:NULL];
                        }
                    }else if([msg hasAudio]) {
                        KDAttachment *att = [msg.attachments lastObject];
                        [[KDAudioController sharedInstance] deleteAudioAtPath:att.url];
                    }
                    
                    return msg;
                }completionBlock:^(id result){
                    [self.messages removeObject:result];
                    [self.messagesTableView reloadData];
                    
                    curBubbleCell_ = nil;
                }];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    curBubbleCell_ = nil;
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
#pragma mark - Notification Handler
- (void)dmThreadSubjectChanged:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *subject = [userInfo objectForKey:@"subject"];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"DM_THREAD_TITLE_%@_%d_PERSONS", @""),
                                 subject, dmThread_.participantsCount];
}

- (void)startPlay:(NSNotification *)noti {
    NSString *playingMessageId = [noti.userInfo objectForKey:KDAudioControllerAudioMessageIDUserInfoKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    NSArray *temp = [NSArray arrayWithArray:self.messages];
    
    for(KDDMMessage *msg in temp) {
        if([msg.messageId isEqualToString:playingMessageId]) {
            msg.messageState |= KDDMMessageStatePlaying;
            break;
        }
    }
}

- (void)stopPlay:(NSNotification *)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    NSUInteger index = 0;
    
    NSArray *temp = [NSArray arrayWithArray:self.messages];
    NSUInteger count = temp.count;
    NSString *currentPlayingMessageId = [noti.userInfo objectForKey:KDAudioControllerAudioMessageIDUserInfoKey];
    NSString *curUserId = [KDManagerContext globalManagerContext].userManager.currentUserId;
    for(; index < count; index++) {
        KDDMMessage *msg = [temp objectAtIndex:index];
        
        if(!msg.hasAudio) continue;
        
        if([msg.messageId isEqualToString:currentPlayingMessageId]) {
            msg.messageState &= ~KDDMMessageStatePlaying;
            
            if([msg.sender.userId isEqualToString:curUserId])
                return;
            
            break;
        }
    }
    
    BOOL isInterrupt = [[noti.userInfo objectForKey:KDAudioControllerAudioStopInterruptUserInfoKey] boolValue];
    
    if(!isInterrupt) {
        KDDMMessage *nextPlayMsg = nil;
        
        for(index++; index < count; index++) {
            KDDMMessage *msg = [temp objectAtIndex:index];
            
            if(!msg.hasAudio) continue;
            
            if(![msg.sender.userId isEqualToString:curUserId] && msg.unread) {
                nextPlayMsg = msg;
                break;
            }
        }
        
        if(nextPlayMsg) {
            [[KDAudioController sharedInstance] playAudioForMessage:nextPlayMsg];
        }
    }
}

- (void)recordInterrupt:(NSNotification *)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAudioControllerAudioDurationChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAudioControllerAudioMeteringChangedNotification object:nil];
    
    [[KDAudioController sharedInstance] stopRecordWithTempID:dmThread_.threadId];
    
    [self.recordView endRecord];
    [chatInputView_.recordBtn setSelected:NO];
    
    self.audioFilePath = [[KDAudioController sharedInstance] curFilePath];
    
    if([KDAudioController sharedInstance].duration <= 1.0f) {
        [self performSelector:@selector(dismissRecordView) withObject:nil afterDelay:1.5f];
    }else {
        [self sendContentsInDMChatInputView:self.chatInputView];
        [self dismissRecordView];
    }
}

//更新当前的threadId 仅当创建临时会话时有效

- (void)messageTaskFinished:(NSNotification *)noti {
    NSLog(@"receive noti in %@", NSStringFromSelector(_cmd));
    BOOL isSuccess = [[[noti userInfo] objectForKey:@"isSuccess"] boolValue];
    KDDMMessage *message = [noti.userInfo objectForKey:@"message"];
    if (isSuccess) {
        DLog(@"messageSended success....");
        //        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        //            id<KDDMMessageDAO> dmDAO = [KDWeiboDAOManager globalWeiboDAOManager].dmMessageDAO;
        //            [dmDAO updateUnsendDMMessagesWithThreadId:self.dmThreadID toNewThread:message.threadId database:fmdb];
        //            return nil;
        //        }completionBlock:NULL];
        self.dmThreadID = message.threadId;
        
        
    }else {
        NSString *errorMessage = [[noti userInfo] objectForKey:@"errorMsg"];
        
        //        [[KDNotificationView defaultMessageNotificationView]
        //         showInView:self.view.window
        //         message:errorMessage
        //         type:KDNotificationViewTypeNormal];
        [KDErrorDisplayView showErrorMessage:errorMessage  inView:self.view.window];
        
    }
    [messagesTableView_ reloadData];
}

#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint p = [touch locationInView:self.view];
    
    CGRect recordBtnFrameInSelfView = [self.view convertRect:chatInputView_.recordBtn.frame fromView:chatInputView_];
    
    if(CGRectContainsPoint(recordBtnFrameInSelfView, p) && chatInputView_.recordBtn.hidden == NO) {
        [gestureRecognizer removeTarget:self.navigationController action:@selector(panned:)];
        [gestureRecognizer addTarget:self action:@selector(panGestureRecognizer:)];
    }
    
    return YES;
}

#pragma mark - dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    delegate_ = nil;
    
    if(updateTimer_ && [updateTimer_ isValid]) {
        [updateTimer_ invalidate];
        updateTimer_ = nil;
    }
    
    //KD_RELEASE_SAFELY(nextSinceDMId_);
    
    [[KDAudioController sharedInstance] setShouldPlay:NO];
    [[KDAudioController sharedInstance] stopPlay];
    //KD_RELEASE_SAFELY(dmThread_);
    //KD_RELEASE_SAFELY(dmThreadID_);
    //KD_RELEASE_SAFELY(messages_);
    //KD_RELEASE_SAFELY(audioFilePath_);
    //KD_RELEASE_SAFELY(tappedOnImageDataSource_);
    //KD_RELEASE_SAFELY(messageIdToTag_);
    
    //KD_RELEASE_SAFELY(recordView_);
    //KD_RELEASE_SAFELY(maskView_);
    // for ios 6, If there are some text in input view and these text with new line.
    // and then back to previous view controller, The app will be crashed.
    // it's happened on:  UIScrollView(UIScrollViewInternal) _delegateScrollViewAnimationEnded
    // it's seems the table view delegate make this problem occurs.
    // So, clear the delegate and data source before release it
    messagesTableView_.delegate = nil;
    messagesTableView_.dataSource = nil;
    //KD_RELEASE_SAFELY(messagesTableView_);
    
    //KD_RELEASE_SAFELY(chatInputView_);
    //KD_RELEASE_SAFELY(addedParicipants_);
    //KD_RELEASE_SAFELY(backOnSendingAlertView_);
    //KD_RELEASE_SAFELY(selectedImageItems_);
    //KD_RELEASE_SAFELY(taskArray_);
    
    //[super dealloc];
}

@end

