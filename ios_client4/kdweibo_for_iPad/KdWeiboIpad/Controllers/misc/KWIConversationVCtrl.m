//
//  KWIConversationVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/21/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIConversationVCtrl.h"

#import <QuartzCore/QuartzCore.h>


#import "UIImageView+WebCache.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOPhotoViewController.h"
#import "NSCharacterSet+Emoji.h"

#import "UIDevice+KWIExt.h"
#import "NSError+KWIExt.h"


#import "KWIMessageCell.h"
#import "KWIAvatarV.h"
#import "KDMMessageCell.h"
#import "KDLayouter.h"
#import "KWIRootVCtrl.h"
#import "UIImage+Resize.h"

#import "iToast.h"

#import "KDDMThread.h"
#import "KDCommonHeader.h"
#import "KDDMMessage.h"
#import "KDMMessageCell.h"

#define KD_DM_LAYOUTER_PROPERTY_KEY @"com.kingdee.dm.layouter"

@interface KWIConversationVCtrl () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIPopoverControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, EGORefreshTableHeaderDelegate>

//@property (retain, nonatomic) NSArray *data;
@property (retain, nonatomic) NSMutableArray *messages;
@property (retain, nonatomic) KDDMThread *thread;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UITextView *msgInput;
//@property (retain, nonatomic) IBOutlet UILabel *participantsV;
@property (retain, nonatomic) UIImageView *topShadowV;
//@property (retain, nonatomic) IBOutlet UIButton *addPtcpBtn;
@property (retain, nonatomic) IBOutlet UILabel *textCountV;
@property (retain, nonatomic) IBOutlet UIButton *sendBtn;
@property (retain, nonatomic) IBOutlet UIView *iptWrappV;

@property (retain, nonatomic) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (retain, nonatomic) IBOutlet UIView *inputToolBarView;
@property (retain, nonatomic) IBOutlet UIButton *photoButton;
@property (retain, nonatomic) IBOutlet UIButton *pictureButton;
@property (retain, nonatomic) IBOutlet UIView *thumbnailHolderView;
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (retain, nonatomic) IBOutlet UIButton *removeThumbnailbtn;
@property (retain, nonatomic)UIImage *pickedImage;
@property (retain, nonatomic)UIActivityIndicatorView *activityIndicatorView;



@end

@implementation KWIConversationVCtrl 
{
    unsigned int _defaultTop;
    UIPopoverController *_poper;
    IBOutlet UIActivityIndicatorView *_loadingV;
    BOOL _isLoading;
    BOOL _nomore;
    BOOL _isLoadMore;
    IBOutlet UILabel *_participantsInfV;
    UIActivityIndicatorView *_topIngV;
    IBOutlet UIImageView *_bgV;
    UIImagePickerController *photoPickerController_;
    UIImagePickerController *picturePickerController_;
    UIPopoverController   *pictureVCPopovercontroller_;
    CGRect  msgInputOrignFrame;
    
    struct {
        unsigned int initialized;
        unsigned int initialWithID;
        unsigned int hasDMPostRequest;
        unsigned int didReceiveMemoryWarning;
        unsigned int navigateToPrevious;
        unsigned int showingImagePicker;
        unsigned int doAddingParticipiant;
    }dmViewControllerFlags_;
    NSCache *cellCache_;
    
}

@synthesize messages = _messages;
@synthesize thread = _thread;
@synthesize tableView = _tableView;
@synthesize msgInput = _msgInput;
//@synthesize participantsV = _participantsV;
@synthesize topShadowV = _topShadowV;
//@synthesize addPtcpBtn = _addPtcpBtn;
@synthesize textCountV = _textCountV;
@synthesize sendBtn = _sendBtn;
@synthesize iptWrappV = _iptWrappV;

@synthesize inputToolBarView = inputToolBarView_;
@synthesize pickedImage = pickedImage_;
@synthesize activityIndicatorView = activityIndicatorView_;
@synthesize participants = participants_;

@synthesize   refreshTableHeaderView = refreshTableHeaderView_;

+ (KWIConversationVCtrl *)vctrlForThread:(KDDMThread *)thread
{
    return [[[self alloc] initWithThread:thread] autorelease];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   // [[KDWeiboCore sharedKDWeiboCore] removeEverythingAbout:self];
    
    [_tableView release];
    _tableView.delegate = nil;
    _tableView = nil;
    [_msgInput release];
    
    [_messages release];
    [_thread release];
    
    [_textCountV release];
    [_sendBtn release];
    [_iptWrappV release];
    [_poper release];
    
    [_loadingV release];
    [_participantsInfV release];
    [_topIngV release];
    [_bgV release];
    [inputToolBarView_ release];
    [_photoButton release];
    [_pictureButton release];
    [_thumbnailHolderView release];
    [_thumbnailImageView release];
    [_removeThumbnailbtn release];
    
    KD_RELEASE_SAFELY(pictureVCPopovercontroller_);
    KD_RELEASE_SAFELY(picturePickerController_);
    KD_RELEASE_SAFELY(photoPickerController_);
    KD_RELEASE_SAFELY(pickedImage_);
    KD_RELEASE_SAFELY(activityIndicatorView_);
    KD_RELEASE_SAFELY(participants_);
    KD_RELEASE_SAFELY(cellCache_);
    [super dealloc];
}

#pragma mark - initilization 
- (KWIConversationVCtrl *)initWithThread:(KDDMThread *)thread
{
    self = [super initWithNibName:@"KWIConversationVCtrl" bundle:nil];
    if (self) {
        self.thread = thread;
        //[[KDWeiboCore sharedKDWeiboCore].conversationList removeAllObjects];
        dmViewControllerFlags_.initialized = 0;
        dmViewControllerFlags_.initialWithID = 0;
        dmViewControllerFlags_.hasDMPostRequest = 0;
        dmViewControllerFlags_.didReceiveMemoryWarning = 0;
        dmViewControllerFlags_.navigateToPrevious = 0;
        dmViewControllerFlags_.showingImagePicker = 0;
        dmViewControllerFlags_.doAddingParticipiant = 0;
        
        self.messages  = [NSMutableArray arrayWithCapacity:0];
        
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
        if (isKeyboardChangeKeyAvailable) {
            [dnc addObserver:self selector:@selector(_onKeyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
        }
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
        
    }
    return self;
}

#pragma mark -  View cycle 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.cornerRadius = 4;
    self.tableView.clipsToBounds = YES;
    
    //    self.messages = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].conversationList];
    //    self.messages = [KDWeiboCore sharedKDWeiboCore].conversationList;
    _nomore = NO;
    
    [self _configBgVForCurrentOrientation];
    
    UIImage *shadowImg = [UIImage imageNamed:@"commentsTopShadow.png"];
    self.topShadowV = [[[UIImageView alloc] initWithImage:shadowImg] autorelease];
    CGRect shadowFrame = CGRectMake(0, 0, 0, 0);
    shadowFrame.size = shadowImg.size;
    self.topShadowV.frame = shadowFrame;
    self.topShadowV.alpha = [self _calulateTopShadowAlpha:0];
    [self.view addSubview:self.topShadowV];
    
    self.iptWrappV.layer.cornerRadius = 8; //输入框
    
    //    NSMutableArray *participantNames = [NSMutableArray arrayWithCapacity:self.thread.participants.count];
    //
    //
    //    KWUser *me = [KDWeiboCore sharedKDWeiboCore].currentUser;
    //    for (KWUser *user in self.thread.participants) {
    //        if (![user.id_ isEqualToString:me.id_]) {
    //            [participantNames addObject:user.name];
    //        }
    //    }
    //    _participantsInfV.text = [NSString stringWithFormat:@"发送给: %@", [participantNames componentsJoinedByString:@", "]];
   
    
    self.thumbnailHolderView.hidden = YES;
    UIImage *image = [UIImage imageNamed:@"btnBg.png"];
    image = [image stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    backgroundImageView.frame = self.inputToolBarView.bounds;
    [self.inputToolBarView addSubview:backgroundImageView];
    [backgroundImageView release];
    [self.inputToolBarView sendSubviewToBack:backgroundImageView];
    // self.inputToolBarView.backgroundColor = [UIColor colorWithPatternImage:image];
    UIActivityIndicatorView *aActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.sendBtn addSubview:aActivityIndicatorView];
    CGRect rect = self.sendBtn.bounds;
    rect.size.width = rect.size.height;
    activityIndicatorView_.bounds = rect;
    CGFloat x = CGRectGetMidX(self.sendBtn.bounds);
    CGFloat y = CGRectGetMidY(self.sendBtn.bounds);
    aActivityIndicatorView.center = CGPointMake(x, y);
    aActivityIndicatorView.hidesWhenStopped = YES;
    aActivityIndicatorView.hidden = YES;
    self.activityIndicatorView = aActivityIndicatorView;
    
    [aActivityIndicatorView release];
    msgInputOrignFrame = self.msgInput.frame;
    
    //[self updateParticipantsLabel];
    
    [self fetchParticipants];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _defaultTop = self.view.frame.origin.y;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // dispatch_block_t block = ^{
    if(dmViewControllerFlags_.initialized == 0){
        dmViewControllerFlags_.initialized = 1;
        if ([self isNewThread]) {
            return;
        }
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDDMMessageDAO> dmMessageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
            
            NSString *latestMessageId = [dmMessageDAO queryLatestDMMessageIdWithThreadId:_thread.threadId database:fmdb];
            _thread.nextSinceDMId = latestMessageId; // not thread safety, it's okay at here
            
            NSArray *messages = [dmMessageDAO queryDMMessagesWithThreadId:_thread.threadId limit:20 database:fmdb];
            
            return messages;
            
        } completionBlock:^(id results) {
            [self.messages addObjectsFromArray:[[(NSArray *)results reverseObjectEnumerator] allObjects]];
            [self loadLatestMessages];
        }];
    }
    
    if(dmViewControllerFlags_.didReceiveMemoryWarning == 1){
        dmViewControllerFlags_.didReceiveMemoryWarning = 0;
    }
    
}
- (void)viewDidUnload {
    //[self setParticipantsV:nil];
    //[self setAddPtcpBtn:nil];
    [self setTextCountV:nil];
    [self setSendBtn:nil];
    [self setIptWrappV:nil];
    [_loadingV release];
    _loadingV = nil;
    [_participantsInfV release];
    _participantsInfV = nil;
    [_bgV release];
    _bgV = nil;
    
    _tableView.delegate = nil;
    [_tableView release];
    _tableView = nil;
    
    [self setInputToolBarView:nil];
    [self setPhotoButton:nil];
    [self setPictureButton:nil];
    [self setThumbnailHolderView:nil];
    [self setThumbnailImageView:nil];
    [self setRemoveThumbnailbtn:nil];
    self.activityIndicatorView = nil;
    [super viewDidUnload];
}

#pragma mark -  Public methods

- (KDDMThread *)data {
    return self.thread;
}

#pragma mark - Private methods
- (BOOL)isNewThread {
    return (self.thread.threadId == nil);
}

- (BOOL)hasAttachment {
    return (self.pickedImage != nil);
}
- (void)updateParticipantsLabel {
    if ([self.participants count] == 0) {
        return;
    }
    NSMutableString *names = [NSMutableString string];
    NSUInteger idx = 0;
    NSUInteger count = [self.participants count];
    
    for (KDUser *user in self.participants) {
        [names appendString:user.username];
        if(idx++ != (count - 1)){
            [names appendString:@","];
        }
    }
    _participantsInfV.text = names;
    
}

- (void)storeJoinedUserIDs {
    if ([self.thread.participantIDs length] >0) {
        return;
    }
    NSMutableString *IDs = [NSMutableString string];
    NSUInteger idx = 0;
    NSUInteger count = [self.participants count];
    
    for (KDUser *user in self.participants) {
        [IDs appendString:user.userId];
        if(idx++ != (count - 1)){
            [IDs appendString:@","];
        }
    }
    
    self.thread.participantIDs = IDs;
    
    // save thread into database
    if ([self isNewThread]) {
        return;
    }
    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
        [threadDAO saveDMThreads:@[self.thread] database:fmdb rollback:rollback];
        
        return nil;
        
    } completionBlock:nil];
    
}

- (void)fetchParticipants {
    if ([self.participants count] >0 ) {
        [self updateParticipantsLabel];
        [self storeJoinedUserIDs];
        return;
    }
    KDQuery *query = [KDQuery query];
    [query setProperty:self.thread.threadId forKey:@"threadId"];
    
    __block KWIConversationVCtrl *vc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        // [tmvc _activityViewWithVisible:NO info:nil];
        
        if ([response isValidResponse]) {
            if (results != nil) {
                vc.participants = results;
                [vc updateParticipantsLabel];
                [vc storeJoinedUserIDs];
                //[tmvc.tableView reloadData];
            }
            
        }
        else {
            if (![response isCancelled]) {
                //                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                //                                                  inView:tmvc.view.window];
            }
        }
        
        // release current view controller
        [vc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadParticipants" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
    
}
- (void)loadLatestMessages {
    //[self toggleMoreButtonEnabledWithLoading:YES];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"threadId" stringValue:_thread.threadId]
     setParameter:@"count" stringValue:@"20"];
    [query setProperty:_thread.threadId forKey:@"threadId"];
    
    if (_thread.nextSinceDMId != nil) {
        [query setParameter:@"since_id" stringValue:_thread.nextSinceDMId];
    }
    
    __block KWIConversationVCtrl *dmvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            NSArray *messages = nil;
            if (results != nil) {
                messages = results;
                if([messages count] > 0){
                    // update next since id
                    KDDMMessage *message = [messages lastObject];
                    dmvc.thread.nextSinceDMId = message.messageId;
                    
                    // mark read
                  //  NSUInteger changedUnreadCount = dmvc.thread.unreadCount;
                    dmvc.thread.unreadCount = 0;
                    
                    [dmvc.messages addObjectsFromArray:messages.reverseObjectEnumerator.allObjects];
                    
                    // truncate the direct messages to make sure don't miss any direct messages in thread.
                    // eg. There are 100 direct messages in a thread, And current 50 messages (range[0, 49]) exists at local database now.
                    // So try to load latest 20 messages with range[80, 99] from network. If append them to database directly.
                    // Then the direct messages in range [50, 79] will be missed.
                    // If to do truncate direct messages, to make sure do load older direct messages can
                    // retrieve messages in range [50, 79]
                    
                    //                    NSUInteger count = [dmvc.messages count];
                    //                    if(count > KD_DM_MAX_MESSAGES_COUNT_PER_PAGE){
                    //                        [dmvc.messages removeObjectsInRange:NSMakeRange(0, count - KD_DM_MAX_MESSAGES_COUNT_PER_PAGE)];
                    //                    }
                    //
                    //                    // should change unread badge value
                    //                    if(changedUnreadCount > 0 && dmvc.delegate != nil
                    //                       && [dmvc.delegate respondsToSelector:@selector(dmThread:didChangeUnreadCount:)]){
                    //                        [dmvc.delegate dmThread:dmvc.dmThread didChangeUnreadCount:changedUnreadCount];
                    //                    }
                    
                }
            }
            
            // save direct message into database
            if (messages != nil) {
                [dmvc retain]; // retain the view controller before async update database
                
                [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                    id<KDDMMessageDAO> messageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
                    [messageDAO saveDMMessages:messages threadId:dmvc.thread.threadId database:fmdb rollback:rollback];
                    
                    BOOL fakeRollback = NO; // just ignore it's value
                    id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
                    [threadDAO saveDMThreads:@[dmvc.thread] database:fmdb rollback:&fakeRollback];
                    
                    return nil;
                    
                } completionBlock:^(id val){
                    [dmvc release];
                }];
            }
            
        } else {
            if (![response isCancelled]) {
                //[KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                // inView:dmvc.view.window];
            }
        }
        
        ////[dmvc toggleMoreButtonEnabledWithLoading:NO];
        //[dmvc toggleMoreMessageButtonVisible];
        
        // release current view controller
        [dmvc.tableView reloadData];
        [dmvc scrollToBottom];
        [dmvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadMessages" query:query
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)addNoMoreTips {
    CGRect nomoreFrm = CGRectMake(0, -50, CGRectGetWidth(self.tableView.frame), 30);
    UILabel *nomoreLbl = [[[UILabel alloc] initWithFrame:nomoreFrm] autorelease];
    nomoreLbl.backgroundColor = [UIColor clearColor];
    nomoreLbl.textAlignment = UITextAlignmentCenter;
    nomoreLbl.font = [UIFont systemFontOfSize:14];
    nomoreLbl.textColor = [UIColor colorWithHexString:@"999"];
    nomoreLbl.text = @"没了";
    [self.tableView addSubview:nomoreLbl];
}
// get more messages
- (void)loadOlderMessages {
    //[self toggleMoreButtonEnabledWithLoading:YES];
    
    KDDMMessage *dm = [self.messages objectAtIndex:0];
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"threadId" stringValue:_thread.threadId]
      setParameter:@"count" stringValue:@"20"]
     setParameter:@"max_id" stringValue:dm.messageId];
    
    [query setProperty:_thread.threadId forKey:@"threadId"];
    
    __block KWIConversationVCtrl *dmvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            NSUInteger count = 0;
            if (results != nil) {
                NSArray *messages = [[results reverseObjectEnumerator] allObjects];
                count = [messages count];
                if (count > 0) {
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];
                    [dmvc.messages insertObjects:messages atIndexes:indexSet];
                }
            }
            if (count < 20) {
                _nomore = YES;
                [self addNoMoreTips];
                [dmvc.tableView reloadData];
            }else {
                CGFloat offsetBefore = self.tableView.contentOffset.y;
                CGFloat heightBefore = self.tableView.contentSize.height;
                [dmvc.tableView reloadData];
                CGFloat heightAfter = self.tableView.contentSize.height;
                CGFloat offsetAfter = heightAfter - heightBefore + offsetBefore;
                [dmvc.tableView setContentOffset:CGPointMake(0, offsetAfter) animated:NO];
            }
        } else {
            if (![response isCancelled]) {
                //                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                //                                              inView:dmvc.view.window];
            }
        }
        
        // [dmvc toggleMoreButtonEnabledWithLoading:NO];
        // [dmvc toggleMoreMessageButtonVisible];
        
        // release current view controller
        
        [dmvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadMessages" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_loadmore
{
    if (_isLoading)  return;
    
    _isLoading = YES;
    _isLoadMore = YES;
    
    // [[KDWeiboCore sharedKDWeiboCore] fetchConversationListIsLoad:YES forThread:self.thread.id_ delegate:self];
    [self loadOlderMessages];
}

- (void)_appendMessage:(KDDMMessage *)message
{
    [self.messages addObject:message];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationTop];
}

- (void)scrollToBottom
{
    if (0 == self.messages.count) {
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}


- (void)messageWillSend {
        self.sendBtn.enabled = NO;
        self.msgInput.editable = NO;
        self.activityIndicatorView.hidden = NO;
       [self.activityIndicatorView startAnimating];
       self.sendBtn.enabled = YES;
       self.msgInput.editable = YES;
       self.msgInput.frame = msgInputOrignFrame;
    
}

- (void)messageDidSendFailed {
    [self.activityIndicatorView stopAnimating];
}
- (void)messageDidSendSucess {
    [self.msgInput resignFirstResponder];
            [self.activityIndicatorView stopAnimating];
            self.msgInput.text = @"";
            self.textCountV.text = @"";
            self.sendBtn.enabled = YES;
            self.msgInput.editable = YES;
            self.msgInput.frame = msgInputOrignFrame;
            self.thumbnailHolderView.hidden = YES;
            self.pickedImage = nil;
            self.thumbnailImageView.image = nil;
            [self scrollToBottom];
}
// 发送短邮
- (void)sendMessage {
        NSString *text = [self _getProcessedText];
    
        if (text.length == 0 ) {
        if (self.pickedImage) {
                text = @"分享图片";
         }else
                 return;
        }
    [self messageWillSend];
    __block KWIConversationVCtrl *dmvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                KDDMMessage *dm = results;
                [dmvc _appendMessage:dm];
                
                //保存图片避免再次从网络获取
                if ([dmvc hasAttachment]) {
                    UIImage *image = dmvc.pickedImage;
                    NSData *data = [image asJPEGDataWithQuality:kKDJPEGPreviewImageQuality];
                    [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreview];
                    
                    data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                    [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreviewBlur];
                    
                    data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
                    [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.middleImageURL imageType:KDCacheImageTypeMiddle];
                    [[KDCache sharedCache] storeImageData:data forURL:dm.compositeImageSource.thumbnailImageURL imageType:KDCacheImageTypeThumbnail];
                    
                }
                [dmvc messageDidSendSucess];
                
                if ([dmvc isNewThread]) {
                    self.thread.threadId = dm.threadId;
                }
            }
            else {
                [dmvc messageDidSendFailed];
            }
        }
        else {
            if (![response isCancelled]) {
                id result = [response responseAsJSONObject];
                NSString *errorMessage = NSLocalizedString(@"DM_SEND_DIRECT_MESSAGE_DID_FAIL", @"");
                
                if (result) {
                    NSInteger code = [result integerForKey:@"code"];
                    if (code == 40006 ) {
                        errorMessage = NSLocalizedString(@"NO_IDENTICAL_DM_IN_TRHEE_MIN", @"");
                    }
                }
                [dmvc messageDidSendFailed];
                [[iToast makeText:errorMessage] show];
                                  
            }
        }
        
        [dmvc release];
    };

    if (![self isNewThread]) {
        DLog(@"new message");
        KDQuery *query = [KDQuery query];
        [query setParameter:@"text" stringValue:text];
        [query setProperty:self.thread.threadId forKey:@"threadId"];
        if ([self hasAttachment]) {
           // NSString *imagePath = hasAttachments ? dmChatInputView.pickedImage.cachePath : nil;
            [query setProperty:@(YES) forKey:@"hasAttachments"];
            
            [[query setParameter:@"thread" stringValue:self.thread.threadId]
             setParameter:@"pic" fileData:UIImageJPEGRepresentation(self.pickedImage, 0.75)];
            
        } else {
           [query setParameter:@"threadId" stringValue:self.thread.threadId];
            [query setProperty:@(NO) forKey:@"hasAttachments"];
        }
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadByIdNewMessage" query:query
                                     configBlock:nil completionBlock:completionBlock];
  
    }
    else {
        if ([self.thread.participantIDs length] == 0) {
            DLog(@"self.thread.participantIds is null");
              return;
        }
        KDQuery *query = [KDQuery query];
        [[query setParameter:@"text" stringValue:text]
          setParameter:@"participants" stringValue:self.thread.participantIDs];
        
        if ([self hasAttachment]) {
            //[query setParameter:@"pic" filePath:imagePath];
            [query setParameter:@"pic" fileData:UIImageJPEGRepresentation(self.pickedImage, 0.75)];
        }
        
        [query setProperty:@([self hasAttachment]) forKey:@"hasAttachments"];
              
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/dm/:newMulti" query:query
                                     configBlock:nil completionBlock:completionBlock];
 
    }
    
    //    KWEngine *api = [KWEngine sharedEngine];
    //    self.sendBtn.enabled = NO;
    //    self.msgInput.editable = NO;
    //    self.activityIndicatorView.hidden = NO;
    //    [self.activityIndicatorView startAnimating];
    //
    //    void (^onSuccess)(id) = ^(NSDictionary * dict) {
    //        [self.msgInput resignFirstResponder];
    //        [self.activityIndicatorView stopAnimating];
    //        self.msgInput.text = @"";
    //        self.textCountV.text = @"";
    //        self.sendBtn.enabled = YES;
    //        self.msgInput.editable = YES;
    //        self.msgInput.frame = msgInputOrignFrame;
    //        self.thumbnailHolderView.hidden = YES;
    //        self.pickedImage = nil;
    //        self.thumbnailImageView.image = nil;
    //        [self _appendMessage:[KWMessage messageFromDict:dict]];
    //        [self _scrollToBottom];
    //
    //
    //    };
    //
    //    void (^onSuccessMulti)(id) = ^(NSDictionary * dict) {
    //        self.thread.id_ = [dict objectForKey:@"thread_id"];
    //        [self.msgInput resignFirstResponder];
    //        [self.activityIndicatorView stopAnimating];
    //        self.msgInput.text = @"";
    //        self.msgInput.frame = msgInputOrignFrame;
    //        self.textCountV.text = @"";
    //        self.thumbnailHolderView.hidden = YES;
    //        self.pickedImage = nil;
    //        self.thumbnailImageView.image = nil;
    //        self.sendBtn.enabled = YES;
    //        self.msgInput.editable = YES;
    //        [self _refresh];
    //
    //    };
    //
    //    void (^onError)(id) = ^(NSError *error) {
    //        [error KWIGeneralProcess];
    //        self.sendBtn.enabled = YES;
    //        self.msgInput.editable = YES;
    //        [self.activityIndicatorView stopAnimating];
    //
    //    };
    //
    //    NSDictionary *data = nil;
    //    if (self.pickedImage != nil) {
    //       data = [NSDictionary dictionaryWithObjectsAndKeys:@"pic", @"key",
    //                             UIImageJPEGRepresentation(self.pickedImage, 0.9), @"data", nil];
    //
    //
    //    }
    //
    //    NSDictionary *params = nil;
    //    if (self.thread.id_) { //为特定话串创建短邮
    //
    //        if (self.pickedImage == nil) {
    //            params = [NSDictionary dictionaryWithObjectsAndKeys:self.thread.id_,@"id",text,@"text" ,nil];
    //            [api post:[NSString stringWithFormat:@"direct_messages/thread/%@/new_msg.json", self.thread.id_]
    //               params:params
    //            onSuccess:onSuccess
    //              onError:onError];
    //
    //        }else {
    //
    //            params = [NSDictionary dictionaryWithObjectsAndKeys:self.thread.id_,@"thread",text,@"text" ,nil];
    //           [api post:@"direct_messages/upload.json"
    //               params:params
    //                data:[NSArray arrayWithObject:data]
    //            onSuccess:onSuccess
    //             onError:onError];
    //
    //
    //        }
    //    }else if(self.thread.participants.count) { //新短邮
    //        NSMutableArray *participantIds = [NSMutableArray arrayWithCapacity:self.thread.participants.count];
    //        for (KWUser *user in self.thread.participants) {
    //            [participantIds addObject:user.id_];
    //        }
    //        NSString *participantIdString = [participantIds componentsJoinedByString:@","];
    //        params = [NSDictionary dictionaryWithObjectsAndKeys:participantIdString,@"participants",text,@"text",nil];
    //
    //        if (self.pickedImage == nil) {
    //            [api post:@"direct_messages/new_multi.json"
    //               params:params
    //            onSuccess:onSuccessMulti
    //              onError:onError];
    //
    //        }else {
    //            [api post:@"direct_messages/upload.json"
    //               params:params
    //                 data:[NSArray arrayWithObject:data]
    //            onSuccess:onSuccessMulti
    //              onError:onError];
    //
    //             }
    //
    //    }
    
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.topShadowV.alpha = [self _calulateTopShadowAlpha:scrollView.contentOffset.y];
    
    //[_refreshHeaderV egoRefreshScrollViewDidScroll:scrollView];
}


- (CGFloat)_calulateTopShadowAlpha:(CGFloat)scrollTop
{
    static BOOL _initialized;
    static NSUInteger MAX_Y;
    static CGFloat MIN_ALPHA;
    static CGFloat C1;
    static CGFloat C2;
    
    if (!_initialized) {
        MAX_Y = 500.0;
        MIN_ALPHA = 0.2;
        C1 = MIN_ALPHA * MAX_Y / (1 - MIN_ALPHA);
        C2 = (1 - MIN_ALPHA) / MAX_Y;
        _initialized = YES;
    }
    
    CGFloat y = MIN(scrollTop, MAX_Y);
    return C2 * (y + C1);
}


- (void)_onFollowingsSelected:(NSNotification *)note
{
    //    KWUser *user = [note.userInfo objectForKey:@"user"];
    //
    //    for (KWUser *existing in self.thread.participants) {
    //        if ([existing.id_ isEqualToString:user.id_]) {
    //            // skip add logic
    //            return;
    //        }
    //    }
    //
    //    KWEngine *api = [KWEngine sharedEngine];
    //    [api post:[NSString stringWithFormat:@"direct_messages/thread/%@/add_participant", self.thread.id_]
    //       params:[NSDictionary dictionaryWithObjectsAndKeys:user.id_, @"participants", self.thread.id_, @"id", nil]
    //    onSuccess:^(id x){
    //
    //    }
    //      onError:^(NSError *error) {
    //          [error KWIGeneralProcess];
    //      }];
    //
    //    [_poper dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    //[popoverController release];
    
    _poper = nil;
}

//- (KWISimpleFollowingsVCtrl *)followingsVCtrl {
//    //    if (nil == _followingsVCtrl) {
//    //        _followingsVCtrl = [[KWISimpleFollowingsVCtrl vctrlWithExclusions:self.thread.participants] retain];
//    //    }
//    //    return _followingsVCtrl;
//    return nil;
//}


- (UIPopoverController *)pictureVCPopoverController {
    if (pictureVCPopovercontroller_ == nil) {
        pictureVCPopovercontroller_ = [[UIPopoverController alloc] initWithContentViewController:[self picturePickerController]];
        
    }
    return pictureVCPopovercontroller_;
}


//获取相册图片
- (UIImagePickerController *)picturePickerController {
    if (picturePickerController_ == nil) {
        picturePickerController_ = [[UIImagePickerController alloc] init];
        picturePickerController_.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picturePickerController_.allowsEditing = NO;
        picturePickerController_.delegate = self;
    }
    return picturePickerController_;
    
}

//照相

-(UIImagePickerController *)photoPickerController {
    if (photoPickerController_ == nil) {
        photoPickerController_ = [[UIImagePickerController alloc] init];
        photoPickerController_.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoPickerController_.allowsEditing = NO;
        photoPickerController_.delegate = self;
        photoPickerController_.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return photoPickerController_;
    
}

//- (void)setFollowingsVCtrl:(KWISimpleFollowingsVCtrl *)followingsVCtrl {
//    if (nil != _followingsVCtrl) {
//        [_followingsVCtrl release];
//        _followingsVCtrl = nil;
//    }
//    
//    _followingsVCtrl = [followingsVCtrl retain];
//}

- (NSCache *)cellCache {
    if (cellCache_ == nil) {
        cellCache_ = [[NSCache alloc] init];
        cellCache_.totalCostLimit = 50;
        cellCache_.name = [[self class] description];
    }
    return cellCache_;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *cellId = @"KWIMessageCell";
//    KWDMMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (nil == cell) {
//        cell = [[[KWDMMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
//    }
//      //  KWMessage *curMsg = [self.messages objectAtIndex:indexPath.row];
//       KDDMMessage *message = [self.messages objectAtIndex:indexPath.row];
//    
//        CGRect rect = CGRectMake(0,0,tableView.frame.size.width -10 - 48 -10,300);
//        KDMessageLayouter *layouter = [self layouterByMessage:message frame:rect];
//       // KDMessageLayouter *layouter = [curMsg layouter:rect];
//        //[cell setMessage:curMsg];
//        [cell update:message layouter:layouter];
//    
//   
//    return cell;
    
//    static NSString *cellId = @"KWIMessageCell";
//    
//    KWIMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    
//    if (nil == cell) {
//        cell = [KWIMessageCell cell];
//    }
//    
//    KDDMMessage *curMsg = [self.messages objectAtIndex:indexPath.row];
//    KDDMMessage *lastMsg = nil;
//    if (0 < indexPath.row) {
//        lastMsg = [self.messages objectAtIndex:indexPath.row - 1];
//    }
//
//    [cell setData:curMsg lastMessage:lastMsg];
   
     KDDMMessage *curMsg = [self.messages objectAtIndex:indexPath.row];
     KDMMessageCell *cell = nil;
     cell = [[self cellCache] objectForKey:curMsg.messageId];
     if (cell == nil) {
        cell = [[[KDMMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
         [cell setMessage:curMsg shouldDisplayTimeStamp:[curMsg shouldDisplayTimeStamp:self.messages]];
         [[self cellCache] setObject:cell forKey:curMsg.messageId];

     }
    return cell;

}

//- (KDMessageLayouter *)layouterByMessage:(KDDMMessage *)message frame:(CGRect)frame  {
//    KDMessageLayouter *layouter = [message propertyForKey:KD_DM_LAYOUTER_PROPERTY_KEY];
//    if (layouter == nil) {
//        layouter = [KDMessageLayouter layouterMessage:message frame:frame];
//        [layouter updateFrame];
//        [message setProperty:layouter forKey:KD_DM_LAYOUTER_PROPERTY_KEY];
//        //[message message:layouter forKey:KD_DM_LAYOUTER_PROPERTY_KEY];
//    }
//    return layouter;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
//    KDDMMessage *message = [self.messages objectAtIndex:indexPath.row];
//    CGRect rect = CGRectMake(0,0,tableView.frame.size.width -10 - 48 -10,300);
//    KDMessageLayouter *layouter = [self layouterByMessage:message frame:rect];
//    return MAX(layouter.frame.size.height +30 ,70);
    
    KDDMMessage *curMsg = [self.messages objectAtIndex:indexPath.row];
    CGFloat height;
    
//    KDDMMessage *lastMsg = nil;
//    if (0 < indexPath.row) {
//        lastMsg = [self.messages objectAtIndex:indexPath.row - 1];
//    }
//    
//    return [KWIMessageCell calculateHeightWithMessage:curMsg lastMessage:lastMsg];
    //CGRect frame = [KDDMMessageLayouter layouter:curMsg constrainedWidth:tableView.frame.size.width-20-15-43].frame;
    BOOL shouldDisplayTimeStamp = [curMsg shouldDisplayTimeStamp:self.messages];
    KDLayouter *layouer = [KDDMMessageLayouter layouter:curMsg constrainedWidth:tableView.frame.size.width-20-20-40 shouldDisplayTimeStamp:shouldDisplayTimeStamp];
    height = layouer.frame.size.height;
    CGFloat avatarHeight = 10+43+23;
    avatarHeight = shouldDisplayTimeStamp?avatarHeight+20:avatarHeight;
    height = MAX(height, avatarHeight);
    return height;

}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    static const float SIZE_LIMIT = 1280.0;
    CGFloat scale = 1.0;
    CGFloat longerEdge = MAX(pickedImg.size.width, pickedImg.size.height);
    scale = longerEdge / SIZE_LIMIT;
    CGSize targetSize;
    if (1 < scale) {
        targetSize = CGSizeMake(pickedImg.size.width / scale, pickedImg.size.height / scale);
    } else {
        targetSize = pickedImg.size;
    }
    
    // resize even if no need to change size, just to get correct orientation
    self.pickedImage = [pickedImg resizedImage:targetSize interpolationQuality:kCGInterpolationHigh];;
    
    if (picker == [self picturePickerController]) {
        [[self pictureVCPopoverController] dismissPopoverAnimated:YES];
       
    } else {
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [KWIRootVCtrl.curInst dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissModalViewControllerAnimated:YES];
        }
        
    }
    
    // to make UIImagePickerController able to release
    [self performSelector:@selector(configPickedImage) withObject:nil afterDelay:0];
}

- (void)configPickedImage {
    if (self.pickedImage == nil) {
        return;
    }
    
    self.thumbnailHolderView.hidden = NO;
    self.thumbnailImageView.image = self.pickedImage;
    
    CGRect rect = self.msgInput.frame;
    msgInputOrignFrame = rect;
    rect.origin.x = CGRectGetMaxX(self.thumbnailHolderView.frame);
    rect.size.width = rect.size.width - CGRectGetWidth(self.thumbnailHolderView.frame);
    self.msgInput.frame = rect;
    self.sendBtn.enabled = YES;
     
    
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    /*if (!_isLoading && !_nomore) {
        [self _loadmore];
    }*/
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];     
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//[refreshTableHeaderView_ egoRefreshScrollViewDidEndDragging:scrollView];
   if (800 > scrollView.contentOffset.y) {
        if (!_isLoading && !_nomore) {
            [self _loadmore];
        }
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (800 > scrollView.contentOffset.y) {
        if (!_isLoading && !_nomore) {
            [self _loadmore];
        }
    }
}

- (NSUInteger)pageSize {
    return 20;
}

- (UIActivityIndicatorView *)topIngV {
    if (!_topIngV) {
        _topIngV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect frame = _topIngV.frame;
        _topIngV.hidesWhenStopped = YES;
        frame.origin.x = CGRectGetMidX(self.tableView.bounds) - CGRectGetMidX(_topIngV.bounds);
        frame.origin.y = -frame.size.height;
        _topIngV.frame = frame;
        [self.tableView addSubview:_topIngV];
    }
    
    return _topIngV;
}

- (void)_configBgVForCurrentOrientation {
    if ([UIDevice isPortrait]) {
        _bgV.image = [UIImage imageNamed:@"cardBgP.png"];
    } else {
        _bgV.image = [UIImage imageNamed:@"cardBg.png"];
    }
    
    CGRect frame = _bgV.frame;
    frame.size = _bgV.image.size;
    _bgV.frame = frame;
   
}

- (NSString *)_getProcessedText {
    NSString *text = self.msgInput.text;
    NSRange emojiRange = [text rangeOfCharacterFromSet:[NSCharacterSet emojiCharacterSet]];
    if (emojiRange.length) {
        text = [text stringByReplacingCharactersInRange:emojiRange withString:@""];
    }
    return text;
}

#pragma mark - UItextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self _sendBtnTapped:nil];
    
    return YES;
}


#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    // for ios 4
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        return;
    }
    
    CGRect frame = self.view.frame;
    frame.origin.y = _defaultTop;
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = frame;
                     }
                     completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = [self _getProcessedText];
    
    // convert all url into a placeholder with length 10
    // use same regx pattern as the one in API
    NSRegularExpression *urlRegx= [NSRegularExpression regularExpressionWithPattern:@"(http[s]?://[\\p{Graph}]*)"
                                                                            options:0
                                                                              error:nil];
    NSMutableArray *matchedUrls = [NSMutableArray array];
    [urlRegx enumerateMatchesInString:text
                              options:0
                                range:NSMakeRange(0, text.length)
                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                               [matchedUrls addObject:[text substringWithRange:result.range]];
                           }];
    for (NSString *url in matchedUrls) {
        text = [text stringByReplacingOccurrencesOfString:url withString:@"0123456789"];
    }
    
    unsigned int len = 0;
    for (unsigned int i = 0; i < text.length; i++) {
        len += (128 > [text characterAtIndex:i])?1:2;
    }
    
    // or if there are only one ascii char it will be count as 0
    len = ceil(len/2.0);
    
    
    if (480 >= len) {
        self.textCountV.textColor = [UIColor darkTextColor];
    } else {
        self.textCountV.textColor = [UIColor redColor];
    }
    self.textCountV.text = [NSString stringWithFormat:@"%d", 480 - len];
    self.textCountV.alpha = len / 480;
    
    self.sendBtn.enabled = (0 < len) && (480 >= len);
}


#pragma mark - Notifcation  handle methods 
- (void)_onOrientationWillChange:(NSNotification *)note {
    //_bgV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)_onOrientationChanged:(NSNotification *)note {
    DLog(@"_onOrientationChanged")
    [self _configBgVForCurrentOrientation];
}

- (void)_onKeyboardChange:(NSNotification *)note {
    CGRect kbFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbFrame = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] convertRect:kbFrame fromView:nil];
    CGFloat kbTop = kbFrame.origin.y;
    
    CGFloat contentTop = MIN(_defaultTop, (kbTop - ([UIDevice isPortrait]?996:740)));
    CGRect frame = self.view.frame;
    frame.origin.y = contentTop;
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = frame;
                     }
                     completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // ios 4
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        return;
    }
    
    CGRect frame = self.view.frame;
    _defaultTop = frame.origin.y;
    frame.origin.y = ([UIDevice isPortrait]?-576:-320);
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = frame;
                     }
                     completion:nil];
}


#pragma mark - event handle methods 
- (IBAction)_sendBtnTapped:(id)sender {
    [self sendMessage];
}

- (IBAction)photoBtnTapped:(id)sender {
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [KWIRootVCtrl.curInst presentViewController:[self photoPickerController] animated:YES completion:nil];
    } else {
        [self presentModalViewController:[self photoPickerController] animated:YES];
    }
    
}

- (IBAction)pictureBtnTapped:(id)sender {
    CGRect rect  = [self.view convertRect:self.pictureButton.frame fromView:inputToolBarView_];
    [[self pictureVCPopoverController] presentPopoverFromRect:rect
                                                      inView:self.view
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:YES];
    
}

- (IBAction)removeThumbnailBtnTapped:(id)sender {
    self.thumbnailHolderView.hidden = YES;
    self.thumbnailImageView.image = nil;
    self.pickedImage = nil;
    self.msgInput.frame = msgInputOrignFrame;
}


#pragma mark - 
//- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
//    dispatch_block_t block = ^{
//        
//        _isLoading = NO;
//        
//        self.messages = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].conversationList];
//        
//        if(_isLoadMore) {
//            [self.topIngV stopAnimating];
//            
//            if(userInfo && ![[userInfo objectForKey:KDWeiBoCoreUserInfoKey_TimeLineHasMore] boolValue] && self.messages.count > 0) {
//                _nomore = YES;
//                
//                CGRect nomoreFrm = CGRectMake(0, -50, CGRectGetWidth(self.tableView.frame), 30);
//                UILabel *nomoreLbl = [[[UILabel alloc] initWithFrame:nomoreFrm] autorelease];
//                nomoreLbl.backgroundColor = [UIColor clearColor];
//                nomoreLbl.textAlignment = UITextAlignmentCenter;
//                nomoreLbl.font = [UIFont systemFontOfSize:14];
//                nomoreLbl.textColor = [UIColor colorWithHexString:@"999"];
//                nomoreLbl.text = @"没了";
//                [self.tableView addSubview:nomoreLbl];
//                [self.tableView reloadData];
//            }else {
//                CGFloat offsetBefore = self.tableView.contentOffset.y;
//                CGFloat heightBefore = self.tableView.contentSize.height;
//                [self.tableView reloadData];
//                CGFloat heightAfter = self.tableView.contentSize.height;
//                CGFloat offsetAfter = heightAfter - heightBefore + offsetBefore;
//                [self.tableView setContentOffset:CGPointMake(0, offsetAfter) animated:NO];
//            }
//        }else {
//            [_loadingV stopAnimating];
//            
//            if(!error) {
//                NSInteger total = [KDWeiboCore sharedKDWeiboCore].unread.unreadMessages;
//              //  total -= self.thread.unread;
//                total = MAX(total, 0);
//                [[KDWeiboCore sharedKDWeiboCore].unread setUnreadMessages:total];
//                
//               // self.thread.unread = 0;
//            }
//            
//            [self.tableView reloadData];
//            
//           // [self _scrollToBottom];
//        }
//    };
//    
//    dispatch_async(dispatch_get_main_queue(), block);
//}
- (void)shadowOn {
   
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff {
   
    [self _configBgVForCurrentOrientation];
}
@end
