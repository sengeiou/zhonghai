//
//  KWIStatusVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/26/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIStatusVCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "Logging.h"
#import "UIImageView+WebCache.h"
#import "NSDate+RelativeTime.h"
#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"
#import "iToast.h"

#import "NSObject+KWDataExt.h"

#import "KWIPeopleVCtrl.h"
#import "KWIStatusContent.h"
#import "KWIAvatarV.h"
#import "KWICommentCell.h"
#import "KWIStatusCell.h"
#import "KWIElectionCell.h"

#import "KDStatusCounts.h"
#import "KDCommonHeader.h"
#import "KDVote.h"
#import "KDCommentStatus.h"

#import "KDLayouter.h"
#import "KDCommentCell.h"
#import "KDRepostStatusCell.h"
#import "KWPaging.h"
#import "KWIWebVCtrl.h"

@interface KWIStatusVCtrl () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UIPopoverControllerDelegate> {
    struct {
    unsigned int init:1;
    unsigned int initCommentLoad:1 ;
    unsigned int  initRepostLoad:1 ;
    }flag_;
    
    BOOL isLoadingComments;
    BOOL isLoadingReposts;
}

@property (retain, nonatomic) IBOutlet UIView *statusV;
@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UILabel *jobtitleV;

@property (retain, nonatomic) IBOutlet UIView *oprtsV;
@property (retain, nonatomic) IBOutlet UIButton *replyBtn;
@property (retain, nonatomic) IBOutlet UIButton *repostBtn;
@property (retain, nonatomic) IBOutlet UIButton *delBtn;
@property (retain, nonatomic) IBOutlet UIButton *moreBtn;

@property (retain, nonatomic, readonly) UITableViewCell *ctnCell;
@property (retain, nonatomic) UITableViewCell *electionCell;

@property (retain, nonatomic) NSMutableArray *comments;
@property (retain, nonatomic) NSMutableArray *reposts;
@property (retain, nonatomic) NSCache *cellCache;

@property (retain, nonatomic, readonly) UITableViewCell *notesTabCell;
@property (retain, nonatomic) UILabel *metaV;
@property (retain, nonatomic) UITextView *emptyMsgV;

@property (assign, nonatomic, readonly) NSUInteger PAGE_SIZE_;
@property (nonatomic,retain)KDVote *vote;
@property (nonatomic,retain)UIPopoverController *popoverController;

@end

@implementation KWIStatusVCtrl
{
    IBOutlet UIImageView *_bgV;
    BOOL _isShadowDisabled;
    IBOutlet UITableView *_tableV;
    UIImageView *_topShadowV;
    NSArray *_curNotes;
    UIButton *_commentsBtn;
    UIButton *_repostsBtn;
    BOOL _isCommentShown;
    BOOL _isCommentsNomore;
    BOOL _isRepostsNomore;
    BOOL _firstLoadDidHappend;
}

@synthesize data = _data;
@synthesize statusV = _statusV;
@synthesize avatarV = _avatarV;
@synthesize usernameV = _usernameV;
@synthesize jobtitleV = _jobtitleV;
@synthesize oprtsV = _oprtsV;
@synthesize replyBtn = _replyBtn;
@synthesize repostBtn = _repostBtn;
@synthesize delBtn = _delBtn;
@synthesize ctnCell = _ctnCell;
@synthesize comments = _comments;
@synthesize reposts = _reposts;
@synthesize cellCache = _cellCache;
@synthesize notesTabCell = _notesTabCell;
@synthesize metaV = _metaV;
@synthesize electionCell = _electionCell;
@synthesize emptyMsgV = _emptyMsgV;
@synthesize vote = vote_;
@synthesize popoverController = popoverController_;


+ (KWIStatusVCtrl *)vctrlWithStatus:(KDStatus *)status
{
    KWIStatusVCtrl *vctrl = [[[self alloc] initWithNibName:self.description bundle:nil] autorelease];
    
    vctrl.data = status;
    return vctrl;
}

+ (KWIStatusVCtrl *)vctrlWithStatusId:(NSString *)statusId{
    KDStatus *placeholderStatus = [[[KDStatus alloc] init] autorelease];
    placeholderStatus.statusId = statusId;
    
    KWIStatusVCtrl *vctrl = [self vctrlWithStatus:placeholderStatus];
    
    return vctrl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
        
        [dnc addObserver:self selector:@selector(_onCommentAdded:) name:@"KWIPostVCtrl.newComment" object:nil];
        [dnc addObserver:self selector:@selector(_onCommentRemoved:) name:@"KWComment.remove" object:nil];
        [dnc addObserver:self selector:@selector(_onRepostAdded:) name:@"KWIPostVCtrl.newStatus" object:nil];
        
        [dnc addObserver:self selector:@selector(voteHasBeenDelete:) name:@"KWIElectionCell.voteDeleted" object:nil];
        flag_.init = 1;
        flag_.initCommentLoad = 1;
        flag_.initRepostLoad = 1;
    }
    return self;
}

-(UIPopoverController *)popoverController {
    if (!popoverController_) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"report" ofType:@"html"];
        KWIWebVCtrl *webVC = [KWIWebVCtrl vctrlWithUrl:[NSURL fileURLWithPath:path]];
        webVC.statusVCtrl = self;
        popoverController_ = [[UIPopoverController alloc] initWithContentViewController:webVC];
        [popoverController_ setPopoverContentSize:CGSizeMake(330, 370)];
        popoverController_.delegate = self;
        
    }
    return popoverController_;
}

- (void)dismissPopoverController {
    [self.popoverController dismissPopoverAnimated:NO];
    KD_RELEASE_SAFELY(popoverController_);
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _tableV.delegate = nil;
    [_tableV release];
    _tableV = nil;
    
    [_avatarV release];
    [_usernameV release];
    [_jobtitleV release];
    [_statusV release];
    [_oprtsV release];
    [_replyBtn release];
    [_repostBtn release];
    [_delBtn release];
    [_data release];
    
    [_commentsBtn release];
    [_repostsBtn release];
    [_bgV release];
    
    [_ctnCell release];
    [_topShadowV release];
    [_cellCache release];
    [_notesTabCell release];
    [_metaV release];
 
    [_electionCell release];
    [_emptyMsgV release];
    [_comments release];
    [_reposts release];
    KD_RELEASE_SAFELY(vote_);
    KD_RELEASE_SAFELY(popoverController_)
    [_moreBtn release];
    [super dealloc];
}

#pragma mark - view stuff

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self _configBgVForCurrentOrientation];
    
    // make sure only when view have loaded we populate it with data
    // we dont sure of that when we call setData
   
}

- (void)updateStatus {
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.data.statusId];
    [query setProperty:self.data.statusId forKey:@"statusId"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if(results) {
                NSDictionary *info = results;
                
                BOOL isExist = [info boolForKey:@"isExist"];
                if (!isExist) {
                    [[iToast makeText:NSLocalizedString(@"KD_STATUS_DETAIL_VIEW_UNEXIST", @"")] show];
                    return;
                }
                KDStatus *status = [info objectForKey:@"status"];
                self.data = status;
               // [_tableV reloadData];
                [self initialization];
               // [self viewDidAppear:NO];
            }
        }
        else {
            if (![response isCancelled]) {
                if(response.statusCode == 400) {
                    // [KDErrorDisplayView showErrorMessage:NSLocalizedString(@"STATUS_DID_DELETED", @"")
                    // inView:sdvc.view.window];
                    [[iToast makeText:NSLocalizedString(@"STATUS_DID_DELETED", @"")] show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.remove"
                                                                        object:self.data
                                                                      userInfo:nil];
                    
                } else {

                    [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
                }
                
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:showById" query:query
                                 configBlock:nil completionBlock:completionBlock];
 
    
}
- (void)updateCommentsAndRepostsCount {
    KDQuery *query = [KDQuery queryWithName:@"ids" value:self.data.statusId];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if(results != nil) {
                NSArray *countList = results;
                if ([countList count] > 0) {
                    KDStatusCounts *statusCount = countList[0];
                    [self setCommentCount:statusCount.commentsCount fowardCount:statusCount.forwardsCount];
                }
            }
            
        } else {
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:counts" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}


- (void)initialization {
    [self _configure];
    [self initCommentLoad];
    [self updateCommentsAndRepostsCount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (flag_.init == 1) {
        flag_.init = 0;
        if (self.data.createdAt) {
            [self initialization];
        }else {
            [self updateStatus];
        }
    }
}

- (void)initCommentLoad {
    if (flag_.initCommentLoad == 1) {
        flag_.initCommentLoad = 0;
        _curNotes = self.comments;
        [self _fetchComments];
    }
}

- (void)initRepostLoad {
    if(flag_.initRepostLoad == 1) {
        flag_.initRepostLoad = 0;
        _curNotes = self.reposts;
        [self _fetchReposts];
    }
}
- (void)viewDidUnload
{
    [self setAvatarV:nil];
    [self setUsernameV:nil];
    [self setJobtitleV:nil];
    [self setStatusV:nil];
    [self setOprtsV:nil];
    [self setReplyBtn:nil];
    [self setRepostBtn:nil];
    [self setDelBtn:nil];    
    
    [_bgV release];
    _bgV = nil;
    
    _tableV.delegate = nil;
    [_tableV release];
    _tableV = nil;
    
    [self setMoreBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
}

- (void)setCommentCount:(NSInteger)commentCount fowardCount:(NSInteger)fowardCount {
    NSString *commentBtnTitle = commentCount >0?[NSString stringWithFormat:@"回复 %d", commentCount]:@"回复";
    NSString *forwadedBtnTitle = fowardCount >0?[NSString stringWithFormat:@"转发 %d", fowardCount]:@"转发";
        [_commentsBtn setTitle:commentBtnTitle
                      forState:UIControlStateNormal];
   
        [_repostsBtn setTitle:forwadedBtnTitle
                     forState:UIControlStateNormal];
}

- (void)_configure {
    if (!self.data.createdAt) {
        return;
    }
    self.usernameV.text = self.data.author.screenName;
    
   // KWEngine *api = [KWEngine sharedEngine];
    _isCommentsNomore = NO;
    _isRepostsNomore = NO;
    
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:self.data.author.thumbnailImageURL size:48];
    avatarV.userInteractionEnabled = YES;    
    [avatarV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    
    [self.usernameV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    
    UIImage *shadowImg = [UIImage imageNamed:@"commentsTopShadow.png"];
    _topShadowV = [[UIImageView alloc] initWithImage:shadowImg];
    CGRect shadowFrame = _tableV.frame;
    shadowFrame.size = shadowImg.size;
    shadowFrame.origin.y -= 1;
    _topShadowV.frame = shadowFrame;
    _topShadowV.alpha = [self _calulateTopShadowAlpha:0];
    [self.view insertSubview:_topShadowV aboveSubview:_tableV]; 
    
    if (self.data.groupId) {
        self.metaV.text = [NSString stringWithFormat:@"%@  来自%@", 
                   [self.data createdAtDateAsString],
                   self.data.groupName];
    } else {
        self.metaV.text = [NSString stringWithFormat:@"%@  来自%@", 
                   [self.data createdAtDateAsString], 
                   self.data.source];
    }
    
   

    
    self.delBtn.hidden = ![self isMyStatus];
    if (![self isMyStatus]) {
        CGRect oprtsFrame = self.oprtsV.frame;
        oprtsFrame.size.width -= self.delBtn.frame.size.width;
        oprtsFrame.origin.x += self.delBtn.frame.size.width;
        self.oprtsV.frame = oprtsFrame;
    } 
    
    self.repostBtn.hidden = self.data.groupId.length >0;
    if (self.data.groupId.length >0) {
        CGRect oprtsFrame = self.oprtsV.frame;
        oprtsFrame.size.width -= self.repostBtn.frame.size.width;
        oprtsFrame.origin.x += self.repostBtn.frame.size.width;
        self.oprtsV.frame = oprtsFrame;
    }
    
    if ([self hasVote]) {

        NSString *voteId = self.data.extraMessage.referenceId;
        KDQuery *query = [KDQuery queryWithName:@"id" value:voteId];
        [query setProperty:voteId forKey:@"voteId"];
        
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if([response isValidResponse]) {
                if (results != nil) {
                    NSDictionary *info = results;
                    KDVote *vote = [info objectForKey:@"vote"];
                    int code = [info intForKey:@"code"];
                    if (code == 500) {
                         [self voteHadBeenDelectAction];
                    } else {
                        self.vote = vote;
                
                        [_tableV reloadData];
                        // save vote into database
                        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
                            id<KDVoteDAO> voteDAO = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
                            [voteDAO saveVote:vote database:fmdb];
                            return nil;
                            
                        } completionBlock:nil];
                    }
                }
            }
             else {
                if (![response isCancelled]) {
                    if (404 == [response statusCode]) {
                        [self voteHadBeenDelectAction];
                        
                    } else {
                        [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
                    }
                }
            }
            
        };
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:resultById" query:query
                                     configBlock:nil completionBlock:completionBlock];

        
    }

  
    [_tableV reloadData];
}


- (void)voteHadBeenDelectAction {
    self.data = nil;
    self.electionCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    self.electionCell.textLabel.textColor = [UIColor lightGrayColor];
    self.electionCell.textLabel.textAlignment = UITextAlignmentCenter;
    self.electionCell.textLabel.text = @"该投票已删除";
    [_tableV reloadData];
}


- (BOOL)isMyStatus {
    return [[KDManagerContext globalManagerContext].userManager isCurrentUserId:self.data.author.userId];
}
#pragma mark - event handlers

- (void)_handlePeopleTapped
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.data.author];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

- (IBAction)_handleReplyBtnTapped:(id)sender 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.addComment" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"status"]];
}

- (IBAction)_repostBtnTapped:(id)sender 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.repost" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"status"]];
}

- (IBAction)_onDelBtnTapped:(id)sender
{
    NSString *msg;
    if (10 < self.data.text.length) {
        msg = [NSString stringWithFormat:@"%@...", [self.data.text substringWithRange:NSMakeRange(0, 10)]];
    } else {
        msg = self.data.text;
    }
    
    UIAlertView *alertV = [[[UIAlertView alloc] initWithTitle:@"删除微博"
                                                      message:[NSString stringWithFormat:@"确认删除“%@”吗？", msg]
                                                     delegate:self 
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"删除", nil] autorelease];
    [alertV show];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    KD_RELEASE_SAFELY(popoverController_);
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
       
        CGRect rect = [self.view convertRect:self.statusV.bounds fromView:self.view];
        [self.popoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1: 
        {
            self.delBtn.enabled = NO;

            KDQuery *query = [KDQuery queryWithName:@"id" value:self.data.statusId];
            [query setProperty:self.data.statusId forKey:@"statusId"];
            
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                if([response isValidResponse]) {
                    if ([(NSNumber *)results boolValue]) {
                        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
                            id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
                            [statusDAO removeStatusWithId:self.data.statusId database:fmdb];
                        } completionBlock:nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.remove"
                                                                                             object:self.data
                                                                                          userInfo:nil];
                         self.delBtn.enabled = YES;
                    }
                    
                } else {
                    if (![response isCancelled]) {
                        [[iToast makeText:@"删除失败"] show];
                       self.delBtn.enabled = YES;
                    }
                }
            };
            
            [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:destoryById" query:query
                                         configBlock:nil completionBlock:completionBlock];
        }
        break;
    }
}


- (void)_onCommentAdded:(NSNotification *)note
{
    NSDictionary *uinf = note.userInfo;
    KDCommentStatus *comment = [uinf objectForKey:@"comment"];
    if ([comment.replyStatusId isEqualToString:self.data.statusId]) {
        self.data.commentsCount ++;
        
        [_commentsBtn setTitle:[NSString stringWithFormat:@"回复 %d", self.data.commentsCount]
                      forState:UIControlStateNormal];
        
        NSDictionary *uinf = [NSDictionary dictionaryWithObjectsAndKeys:@(self.data.commentsCount), @"count",
                                                                        self.data.statusId, @"id", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"comment_count_updated"
                                                            object:self 
                                                          userInfo:uinf];
        
        [self.comments insertObject:comment atIndex:0];
        if (_curNotes == self.comments) {
            _tableV.tableFooterView = nil;
            
            [_tableV insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

- (void)_onCommentRemoved:(NSNotification *)note
{
    KDCommentStatus *comment = note.object;
    if ([comment.replyStatusId isEqualToString:self.data.statusId]) {
        self.data.commentsCount--;
        
        if (0 > self.data.commentsCount) {
            self.data.commentsCount = 0;
        }
        
        [_commentsBtn setTitle:[NSString stringWithFormat:@"回复 %d", self.data.commentsCount]
                      forState:UIControlStateNormal];
        
        KDCommentStatus *toRemove = nil;
        for (KDCommentStatus *cs in self.comments) {
            if ([cs.statusId isEqualToString:comment.statusId]) {
                toRemove = cs;
                break;
            }
        }
        if (toRemove) {
            NSArray *indexpaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments indexOfObject:toRemove] inSection:1]];
            [self.comments removeObject:toRemove];
            
            if (_curNotes == self.comments) {
                [_tableV deleteRowsAtIndexPaths:indexpaths
                               withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)_onRepostAdded:(NSNotification *)note
{
    NSDictionary *uinf = note.userInfo;
    KDStatus *status = [uinf objectForKey:@"status"];
    if ([status.replyStatusId isEqualToString:self.data.statusId]) {
        
        self.data.forwardsCount++;;
        [_repostsBtn setTitle:[NSString stringWithFormat:@"转发 %d", self.data.forwardsCount] 
                     forState:UIControlStateNormal];
    }
}

- (void)_onOrientationWillChange:(NSNotification *)note
{
    _bgV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)_onOrientationChanged:(NSNotification *)note
{
    [self _configBgVForCurrentOrientation];
}

- (void)_onQuotedStatuesTapped:(NSNotification *)note
{
    KWIStatusVCtrl *vctrl = [note.userInfo objectForKey:@"vctrl"];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf]; 
}

- (void)_onCommentsBtnTapped
{
    [self commentBtnSelected];
    
    if (!isLoadingComments) {
        _curNotes = self.comments;
        [_tableV reloadData];
        [self freshTableViewFooterView];
    }
    //[self _fetchComments];
}

- (void)_onRepostsBtnTapped
{
    [self repostBtnSelected];
    [self initRepostLoad];
    
    if (!isLoadingReposts) {
        _curNotes = self.reposts;
        [_tableV reloadData];
        [self freshTableViewFooterView];
    }

   // [self _fetchReposts];
}
- (IBAction)_onMoreBtnTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"举报该微博",nil];
    //CGRect rect = [btn convertRect:btn.frame toView:self.view];
    CGRect rect = [self.view convertRect:btn.bounds fromView:btn];
    [actionSheet showFromRect:rect inView:self.view animated:YES];
    [actionSheet release];
}

- (void)voteHasBeenDelete:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    KDVote *vote = [info objectForKey:@"vote"];
    if (vote && [vote.voteId isEqualToString:self.vote.voteId]) {
        [self voteHadBeenDelectAction];
    }
    
}
#pragma mark - tableView stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.data.createdAt?2:0;

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    switch (section) {
//        case 0:
//            return self.electionCell?3:2;
//            break;
//            
//        default:
//        {
//            NSInteger count = 0;
//            count = _curNotes?_curNotes.count:0;
//            DLog(@"theeeecount = %d",count);
//            return _curNotes?_curNotes.count:0;
//            break;
//        }
//    }
  
    NSInteger count = 0;
    if (section == 0) {
     
        count = self.electionCell?3:2;
    }else if (section == 1) {
        //DLog(@"seciton = %d",section)
        count = _curNotes?_curNotes.count:0;
        
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    CGFloat height = 0;
//    switch (indexPath.section) {
//        case 0:
//        {
//            switch (indexPath.row) {
//                case 0:
//                    height = CGRectGetHeight(self.ctnCell.frame);
//                    break;
//                case 1:{
//                    
//                        if (self.electionCell) {
//                         height = CGRectGetHeight(self.electionCell.frame);
//                         }else {
//                          height = CGRectGetHeight(self.notesTabCell.frame);
//                         }
//                       }
//                    break;
//                case 2:
//                    height = CGRectGetHeight(self.notesTabCell.frame);
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
//       case 1:
//            height = CGRectGetHeight([[self _loadCellAtIndexPath:indexPath] frame]);
//            break;
//        default:
//            break;
//    }
//    return height;
    
    switch (indexPath.section) {
       
        case 0:
            switch (indexPath.row) {
                case 0:
                    return CGRectGetHeight(self.ctnCell.frame);
                    break;
                    
                case 1:
                    if (self.electionCell) {
                        return CGRectGetHeight(self.electionCell.frame);
                        break;
                    }
                    // else fall into default
                    
                default:
                    return CGRectGetHeight(self.notesTabCell.frame);
                    break;
            }
            break;
            
        default:
        {
            CGFloat height = 0;

           if (_isCommentShown) {
            
                CGRect frame = [KDCommentCellLayouter layouter:(KDCommentStatus *)[_curNotes objectAtIndex:indexPath.row] constrainedWidth:tableView.frame.size.width-20-15-40].frame;
                height = frame.size.height;
                
            }else {
                CGRect frame = [KDRepostStatusLayouter layouter:(KDStatus *)[_curNotes objectAtIndex:indexPath.row] constrainedWidth:tableView.frame.size.width-20-15-40].frame;
                height = frame.size.height;
            }
            return height;
            return 100;
            break;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return self.ctnCell;
                    break;
                    
                case 1:
                    if (self.electionCell) {
                        return self.electionCell;
                        break;
                    }
                    // else fall into default
                    
                default:
                    return self.notesTabCell;
                    break;
            }
            break;
            
        default:
            return [self _loadCellAtIndexPath:indexPath];
            break;
    }
}

- (UITableViewCell *)_loadCellAtIndexPath:(NSIndexPath *)indexPath
{
   // KWEntity *note = _curNotes?[_curNotes objectAtIndex:indexPath.row]:nil;
    KDStatus *status = _curNotes?[_curNotes objectAtIndex:indexPath.row]:nil;
    if ([status isKindOfClass:[KDCommentStatus class]]) {
        KDCommentStatus *comment = (KDCommentStatus *)status;
                KDCommentCell *cell = [self.cellCache objectForKey:comment.statusId];
                if (!cell) {
                    cell = [KDCommentCell cell];
                    cell.comment = comment;
                   // cell.status = self.data;
                    [self.cellCache setObject:cell forKey:comment.statusId];
               }
                return cell;
    } else  {
        KDRepostStatusCell *cell = [self.cellCache objectForKey:status.statusId];
        if (!cell) {
            cell = [KDRepostStatusCell cell];
            cell.repostedStatus = status;
            [self.cellCache setObject:cell forKey:status.statusId];
        }
        return cell;
    }
    
    @throw [NSException exceptionWithName:@"ThisShouldNotHappen" 
                                   reason:[NSString stringWithFormat:@"check [%@ _loadCellAtIndexPath] if this happened", self.class]
                                 userInfo:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _topShadowV.alpha = [self _calulateTopShadowAlpha:scrollView.contentOffset.y];
    
    if ((!isLoadingComments||!isLoadingReposts) && (300 > (scrollView.contentSize.height - scrollView.contentOffset.y - CGRectGetHeight(scrollView.frame)))) {
        if(_isCommentShown)
            [self _fetchComments];
        else
            [self _fetchReposts];
    }
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
        MIN_ALPHA = 0;
        C1 = MIN_ALPHA * MAX_Y / (1 - MIN_ALPHA);
        C2 = (1 - MIN_ALPHA) / MAX_Y;
        _initialized = YES;
    }
    
    CGFloat y = MIN(scrollTop, MAX_Y);
    return C2 * (y + C1);
}

#pragma mark - logic

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        if (_isShadowDisabled) {
            _bgV.image = [UIImage imageNamed:@"cardBgPNoShadow.png"];
        } else {
            _bgV.image = [UIImage imageNamed:@"cardBgP.png"];
        }
    } else {
        _bgV.image = [UIImage imageNamed:@"cardBg.png"];
    }
    
    CGRect frame = _bgV.frame;
    frame.size = _bgV.image.size;
    _bgV.frame = frame;
}

- (void)shadowOn
{
    _isShadowDisabled = NO;
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff
{
    _isShadowDisabled = YES;
    [self _configBgVForCurrentOrientation];
}

- (void)_fetchComments
{
//    if (!_firstLoadDidHappend) {
//        [self performSelector:@selector(_fetchComments) withObject:nil afterDelay:0.3];
//        _firstLoadDidHappend = YES;
//        return;
//    }

    if (isLoadingComments || _isCommentsNomore) {
        return;
    }
    
    isLoadingComments = YES;
    KWPaging *p;    
    if (self.PAGE_SIZE_ > self.comments.count) {
        p = [KWPaging pagingWithPage:1 count:self.PAGE_SIZE_];        
    } else {
        p = [KWPaging pagingWithPage:ceil(self.comments.count / (CGFloat)self.PAGE_SIZE_)+1 count:self.PAGE_SIZE_];
    } 
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"id" stringValue:self.data.statusId];
    query = [query queryByAddQuery:[p toQuery]];
    __block KWIStatusVCtrl *svc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            NSArray *comments = nil;
            if(results != nil) {
                comments = results;
                [comments makeObjectsPerformSelector:@selector(setStatus:) withObject:self.data];
                [svc.comments addObjectsFromArray:comments];
                
                if (svc->_isCommentShown) {
                    svc->_curNotes = svc.comments;
                    [svc->_tableV reloadData];
                    [svc freshTableViewFooterView];
                }
            }
             
                if (svc.PAGE_SIZE_ > comments.count) {
                        _isCommentsNomore = YES;
                    }
            
        } else {
            if (![response isCancelled]) {
                [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            }
        }
        isLoadingComments = NO;
        [svc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:comments" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (void)_fetchReposts
{
    if (isLoadingReposts || _isRepostsNomore) {
        return;
    }
    
    isLoadingReposts = YES;
    KWPaging *p;    
    if (self.PAGE_SIZE_ > self.reposts.count) {
        p = [KWPaging pagingWithPage:1 count:self.PAGE_SIZE_];        
    } else {
        p = [KWPaging pagingWithPage:ceil(self.reposts.count / (CGFloat)self.PAGE_SIZE_)+1 count:self.PAGE_SIZE_];
    }
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"id" stringValue:self.data.statusId];
    query = [query queryByAddQuery:[p toQuery]];
    
     __block KWIStatusVCtrl *svc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSArray *forwards = nil;
        if([response isValidResponse]) {
            if (results != nil) {
               forwards = (NSArray *)results;
                [svc.reposts addObjectsFromArray:forwards];
              
            }
            if (self.PAGE_SIZE_ > forwards.count) {
                svc->_isRepostsNomore = YES;
            }
            if (!svc->_isCommentShown) {
                _curNotes = svc.reposts;
                [svc->_tableV reloadData];
                [svc freshTableViewFooterView];
            }
            
        } else {
            if (![response isCancelled]) {
                [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            
            }
        }
        svc->isLoadingReposts = NO;
        [svc release];
         
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/statuses/:forwards" query:query
                                 configBlock:nil completionBlock:completionBlock];

}

//- (BOOL)_hasElection {
//    return (self.data.extra && [@"vote" isEqualToString:[self.data.extra objectForKey:@"type"]]);
//}

- (BOOL)hasVote {
    return [self.data.extraMessage isVote];
}
#pragma mark - accessors
- (UITableViewCell *)ctnCell
{
    if (!_ctnCell) {
        _ctnCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        CGRect ctnFrm = CGRectMake(20, 0, 380, 10);        
        KWIStatusContent *ctnV = [KWIStatusContent viewForStatus:self.data
                                                           frame:ctnFrm contentFontSize:16 textInteractionEnabled:YES];
        ctnV.autoresizingMask = UIViewAutoresizingNone;
        [_ctnCell.contentView addSubview:ctnV];
        //_ctnCell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        CGRect cellFrm = _ctnCell.frame;
        cellFrm.size.height = CGRectGetHeight(ctnV.frame) - 30;
        _ctnCell.frame = cellFrm;
        // minus 30 and clipsToBounds are hacks to hide meta string in KWIStatusContent
        _ctnCell.clipsToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onQuotedStatuesTapped:) name:@"KWIStatusContent.retweetedStatusTapped" object:ctnV];
    }
    
    return _ctnCell;
}

- (UITableViewCell *)notesTabCell
{
    DLog(@"notesTabelCell...");
    if (!_notesTabCell) {
         DLog(@"ssssnotesTabelCell...");
        _notesTabCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        CGRect cellFrm = _notesTabCell.frame;
        cellFrm.size.height = 30;
        _notesTabCell.frame = cellFrm;
        
        [_notesTabCell.contentView addSubview:self.metaV];
        
        _commentsBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _commentsBtn.frame = CGRectMake(CGRectGetWidth(cellFrm) - 116, 0, 50, 30);
        [_commentsBtn setTitle:@"回复" forState:UIControlStateNormal];
        [_commentsBtn addTarget:self action:@selector(_onCommentsBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [_notesTabCell.contentView addSubview:_commentsBtn];
        
        _repostsBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];   
        _repostsBtn.frame = CGRectMake(CGRectGetWidth(cellFrm) - 66, 0, 50, 30);
        [_repostsBtn setTitle:@"转发" forState:UIControlStateNormal];
        [_repostsBtn addTarget:self action:@selector(_onRepostsBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [_notesTabCell.contentView addSubview:_repostsBtn];
        
      
        for (UIButton *btn in [NSArray arrayWithObjects:_commentsBtn, _repostsBtn, nil]) {
            btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [btn setTitleColor:[UIColor colorWithHexString:@"333"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"666"] forState:UIControlStateSelected];
            //btn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setBackgroundImage:[UIImage imageNamed:@"statusVCtrlTabBg.png"] forState:UIControlStateSelected];
        }
        
       
        
       // [self _onCommentsBtnTapped];
        
        //如果是小组微博
        if (self.data.groupId) {
            //_commentsBtn.hidden = YES;
            _repostsBtn.hidden = YES;
            _commentsBtn.hidden = YES;
             _isCommentShown = YES;
        
        }else {
           [self setCommentCount:self.data.commentsCount fowardCount:self.data.forwardsCount];
//            //初始状态  .....
            [self commentBtnSelected];
        }
    }
    
    return _notesTabCell;
}

- (void)commentBtnSelected {
    if (!_isCommentShown) {
        _commentsBtn.selected = YES;
        _repostsBtn.selected = NO;
        _isCommentShown = YES;
    }
}

- (void)repostBtnSelected {
    if (_isCommentShown) {
        _commentsBtn.selected = NO;
        _repostsBtn.selected = YES;
        _isCommentShown = NO;
    }
}

- (UILabel *)metaV
{
    if (!_metaV) {
        _metaV = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
        _metaV.font = [UIFont systemFontOfSize:13];
        _metaV.textColor = [UIColor lightGrayColor];
        _metaV.backgroundColor = [UIColor clearColor];
    }
    
    return _metaV;
}

//- (void)setIng:(BOOL)ing
//{
//    _ing = ing;
//}

- (NSCache *)cellCache
{
    if (!_cellCache) {
        _cellCache = [[NSCache alloc] init];
        _cellCache.countLimit = 20;
    }
    
    return _cellCache;
}

- (NSMutableArray *)comments
{
    if (!_comments) {
        _comments = [[NSMutableArray array] retain];
    }
    
    return _comments;
}

- (NSMutableArray *)reposts
{
    if (!_reposts) {
        _reposts = [[NSMutableArray array] retain];
    }
    
    return _reposts;
}

- (NSUInteger)PAGE_SIZE_
{
    return 10;
}

- (UITableViewCell *)electionCell
{
    if (!_electionCell) {
        if (self.vote) {
//            _electionCell = [[KWIElectionCell cellForElection:self.vote width:CGRectGetWidth(self.view.frame)] retain];
            _electionCell = [[KWIElectionCell cellForElection:self.vote] retain];
        }
    }
    
    return _electionCell;
}

- (UITextView *)emptyMsgV
{
    if (!_emptyMsgV) {
        _emptyMsgV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 60)];
        _emptyMsgV.backgroundColor = [UIColor clearColor];
        //_emptyMsgV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        _emptyMsgV.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
        _emptyMsgV.userInteractionEnabled = NO;
        _emptyMsgV.textColor = [UIColor lightGrayColor];
        _emptyMsgV.font = [UIFont systemFontOfSize:14];
        _emptyMsgV.textAlignment = UITextAlignmentCenter;
    }
    
    _emptyMsgV.text = (_curNotes == self.comments)?@"还没有人回复":@"还没有人转发";
    return _emptyMsgV;
}

//added by shenkuikui 2012.10.12
- (void)freshTableViewFooterView
{
    if(_curNotes == _comments)
        _tableV.tableFooterView = ([_comments count] == 0) ? self.emptyMsgV : nil;
    else
        _tableV.tableFooterView = ([_reposts count] == 0) ? self.emptyMsgV : nil;
}

@end
