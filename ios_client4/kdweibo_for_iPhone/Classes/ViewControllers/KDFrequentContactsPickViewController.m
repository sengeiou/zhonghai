//
//  KDFrequentContactsPickViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-8-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "KDCommon.h"
#import "KDFrequentContactsPickViewController.h"
#import "KDDMConversationViewController.h"
#import "KDDMThread.h"

#import "KDUserPickableCell.h"
#import "KDDMSelectedUserCell.h"
#import "KDActivityIndicatorView.h"
#import "KDMentionPickerSectionView.h"
#import "KDErrorDisplayView.h"

#import "KDUser.h"
#import "KDQuery.h"
#import "KDWeiboServicesContext.h"
#import "KDDBManager.h"
#import "KDManagerContext.h"
#import "KDRequestDispatcher.h"

#import "KDDatabaseHelper.h"
#import "KDSearchBar.h"
#import "UIView+Blur.h"
#import "ProfileViewController.h"

#import "KDDefaultViewControllerContext.h"

enum {
    KDDMParticipantPickerStatePicking = 0x00,
    KDDMParticipantPickerStateSearching,
};

typedef NSUInteger KDDMentionPickerState;

#define KD_MAX_SEARCH_USERS_PAGE_COUNT  20
#define KD_SELECTED_PARTICIPANT_TABLE_VIEW_HEIGHT  58
@interface KDFrequentContactsPickViewController () <UITableViewDelegate, UITableViewDataSource, KDSearchBarDelegate, KDRequestWrapperDelegate, KDUserPickableCellDelegate>
{
    
    KDDMentionPickerState state_;
    KDFrequentContactsType type_;
    
    struct {
        unsigned int indexingCachedUsers:1;
        unsigned int loadedCachedUsers:1;
        unsigned int isLoadPagingUsers:1; // means the search keyword did not change, load next page
        unsigned int hasRequests:1;
    }mentionPickerFlags_;
}
@property(nonatomic, retain) NSMutableArray *localCachedUsers;
@property(nonatomic, retain) NSMutableArray *networkUsers;

@property(nonatomic, retain) NSMutableArray *pickedUsersArray;

@property(nonatomic, retain) NSString *previousKeywords;

@property(nonatomic, assign) NSInteger currentPage;

@property(nonatomic, retain) KDSearchBar *searchBar;
@property(nonatomic, retain) KDMentionPickerSectionView *pickingHeaderView;
@property(nonatomic, retain) UITableView *tableView;

@property(nonatomic, retain) UIView *footerView;
@property(nonatomic, assign) UIButton *loadBtn;

@property(nonatomic, retain) UILabel *promptInfoLabel;
@property(nonatomic, retain) KDActivityIndicatorView *activityView;

@property(nonatomic, retain) UIView *maskView;
@property(nonatomic,retain)UITableView *selectedparticipantTableView;
@property(nonatomic, retain)UIView *toolBarView;
@property(nonatomic, retain)UIButton *doneBtn;

@end

@implementation KDFrequentContactsPickViewController
@synthesize selectedparticipantTableView = selectedparticipantTableView_;
@synthesize delegate=delegate_;

@synthesize localCachedUsers=localCachedUsers_;
@synthesize networkUsers=networkUsers_;

@synthesize pickedUsersArray= pickedUsersArray_;
@synthesize previousKeywords=previousKeywords_;

@synthesize currentPage=currentPage_;

@synthesize searchBar=searchBar_;
@synthesize pickingHeaderView=pickingHeaderView_;
@synthesize tableView=tableView_;
@synthesize footerView=footerView_;
@synthesize loadBtn=loadBtn_;

@synthesize promptInfoLabel=promptInfoLabel_;
@synthesize activityView=activityView_;

@synthesize maskView=maskView_;

@synthesize toolBarView = toolBarView_;
@synthesize doneBtn = doneBtn_;

@synthesize alreadyExistsUserIds = _alreadyExistsUserIds;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        state_ = KDDMParticipantPickerStatePicking;
        
        mentionPickerFlags_.indexingCachedUsers = 0;
        mentionPickerFlags_.loadedCachedUsers = 0;
        mentionPickerFlags_.isLoadPagingUsers = 0;
        mentionPickerFlags_.hasRequests = 0;
        
        currentPage_ = 1;
        
        self.navigationItem.title = ASLocalizedString(@"KDFrequentContactsPickViewController_choice_contact");
    }
    
    return self;
}

- (id)initWithType:(KDFrequentContactsType)type {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        type_ = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    [KDWeiboAppDelegate setExtendedLayout:self];
    CGFloat offsetY = 64.f;
    CGRect frame = CGRectMake(0.0, offsetY, self.view.bounds.size.width, 50.0);
    
    KDSearchBar *searchBar = [[KDSearchBar alloc] initWithFrame:frame];
    searchBar.showsCancelButton = NO;
    self.searchBar = searchBar;
//    [searchBar release];
    
    searchBar_.delegate = self;
    searchBar_.placeHolder = ASLocalizedString(@"KDFrequentContactsPickViewController_search_in_all");
    searchBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:searchBar_];
    
    // picking section hader view
    offsetY += frame.size.height;
    frame.origin.y = offsetY;
    frame.size.height = 25.0;
    self.pickingHeaderView = [self _sectionViewWithFrame:frame text:ASLocalizedString(@"FREQUENT_CONTACTS")];
    
    pickingHeaderView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pickingHeaderView_.backgroundColor = [UIColor kdBackgroundColor1];
    pickingHeaderView_.sectionLabel.textColor = MESSAGE_NAME_COLOR;
    pickingHeaderView_.sectionLabel.font = [UIFont systemFontOfSize:12.f];
    [pickingHeaderView_ addBorderAtPosition:KDBorderPositionBottom];
    [self.view addSubview:pickingHeaderView_];
    
    // table view
    offsetY += frame.size.height;
    frame.origin.y = offsetY;
    frame.size.height = self.view.bounds.size.height - offsetY - KD_SELECTED_PARTICIPANT_TABLE_VIEW_HEIGHT;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.rowHeight = 58.0;
    tableView_.backgroundColor = [UIColor kdBackgroundColor1];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    offsetY = self.view.bounds.size.height - KD_SELECTED_PARTICIPANT_TABLE_VIEW_HEIGHT;
    frame.origin.y = offsetY;
    frame.origin.x -=2;
    frame.size.width +=4;
    frame.size.height = KD_SELECTED_PARTICIPANT_TABLE_VIEW_HEIGHT+2;
    UIView *aView = [[UIView alloc] initWithFrame:frame];
    aView.backgroundColor = [UIColor kdBackgroundColor2];
    [aView addBorderAtPosition:KDBorderPositionTop];
    aView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: aView];
    self.toolBarView = aView;
//    [aView release];
    
    UIButton *btn = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDFrequentContactsPickViewController_start")];
    btn.titleLabel.font = FS6;
    btn.bounds = CGRectMake(0, 0, 54, 30);
//    UIImage *bgImage = [UIImage imageNamed:@"contact_start_v3.png"];
//    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width*0.5 topCapHeight:bgImage.size.height*0.5];
//    [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_didFinishPicking:) forControlEvents:UIControlEventTouchUpInside];
    CGPoint center = CGPointZero;
    center.y = CGRectGetMidY(self.toolBarView.bounds);
    center.x = self.toolBarView.bounds.size.width - CGRectGetMidX(btn.bounds) - 9;
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn.center = center;
//    btn.layer.cornerRadius = 6.f;
//    btn.layer.masksToBounds = YES;
    [btn setCircle];
    [self.toolBarView addSubview:btn];
    self.doneBtn = btn;
    [self _updateDoneButton];
    
    
    frame = self.toolBarView.bounds;
    frame.origin.x = 10;
    frame.origin.y = 5;
    frame.size.width = frame.size.width - 80;
    frame.size.height = frame.size.height - 12;
    
    UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    aTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    aTableView.showsVerticalScrollIndicator = NO;
    aTableView.rowHeight = 50;
    aTableView.frame = frame;
    aTableView.backgroundColor = [UIColor clearColor];
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.selectedparticipantTableView = aTableView;
//    [aTableView release];
    self.toolBarView.backgroundColor = [UIColor kdBackgroundColor2];
    [self.toolBarView addSubview:aTableView];
    
    [self setUpNavigationBar];
    
}

-(void)setUpNavigationBar {
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
//    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(back:)];
}


- (void)_maskViewWithVisible:(BOOL)visible {
    if (maskView_ == nil) {
        CGRect rect = tableView_.frame;
        maskView_ = [[UIView alloc] initWithFrame:rect];
        
        // tap gesture recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTapOnMaskView:)];
        tap.numberOfTapsRequired = 1;
        
        [maskView_ addGestureRecognizer:tap];
//        [tap release];
        
        // swipe gesture recognizer
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_didSwipeOnMaskView:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
        
        [maskView_ addGestureRecognizer:swipe];
//        [swipe release];
        
        maskView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:maskView_];
    }
    
    maskView_.hidden = !visible;
}

- (void)_didTapOnMaskView:(UITapGestureRecognizer *)gestureRecognizer {
    [self _resignFirstResponderForSearchBar];
}

- (void)_didSwipeOnMaskView:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self _resignFirstResponderForSearchBar];
}

- (void)back:(id)sender {
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(cancelContactsPickViewController)]) {
        [self.delegate cancelContactsPickViewController];
    }
    if(self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (mentionPickerFlags_.loadedCachedUsers == 0) {
        mentionPickerFlags_.loadedCachedUsers = 1;
        
        [self _loadLocalCachedUsers];
    }
    if (pickedUsersArray_.count > 0) {
        [self.selectedparticipantTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:pickedUsersArray_.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)updateState:(KDDMentionPickerState)nState
{
    if(state_ != nState) {
        state_ = nState;
        
        [self.tableView reloadData];
        
        if(state_ == KDDMParticipantPickerStateSearching) {
            self.pickingHeaderView.sectionLabel.text = ASLocalizedString(@"MENTION_NETWORK_CONTACTS");
        }else {
            self.pickingHeaderView.sectionLabel.text = ASLocalizedString(@"FREQUENT_CONTACTS");
        }
    }
}

/////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (tableView == tableView_) {
        if(state_ == KDDMParticipantPickerStateSearching)
            rows = [networkUsers_ count];
        else
            rows = localCachedUsers_.count;
    }else if (tableView == selectedparticipantTableView_) {
        rows = [pickedUsersArray_ count];
        
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    static NSString *CellIdentifier2 =@"cell2";
    KDTableViewCell *cell = nil;
    if (tableView == tableView_) {
        cell = (KDUserPickableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (KDUserPickableCell *)[[KDUserPickableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;//autorelease];
            [(KDUserPickableCell *)cell setDelegate:self];
            [(KDUserPickableCell *)cell setAllowedShowUserProfile:NO ];
        }
        
        KDUser *user = nil;
        
        if(KDDMParticipantPickerStateSearching == state_) {
            user = [networkUsers_ objectAtIndex:indexPath.row];
        }else {
            user = [localCachedUsers_ objectAtIndex:indexPath.row];
        }
        
        
        ((KDUserPickableCell *)cell).user = user;
        
        ((KDUserPickableCell *)cell).picked = [self _isPickedUser:user];
        
        cell.backgroundColor = RGBCOLOR(250.f, 250.f, 250.f);
        cell.contentView.backgroundColor = RGBCOLOR(250.f, 250.f, 250.f);
        
        [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:((KDUserPickableCell *)cell).avatarView];
        
    }else if(tableView == selectedparticipantTableView_) {
        if (indexPath.row <[pickedUsersArray_ count]) {
            cell = (KDDMSelectedUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil) {
                cell = [[KDDMSelectedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
                cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }
            if (indexPath.row <[pickedUsersArray_ count]) {
                KDUser *user = [pickedUsersArray_ objectAtIndex:indexPath.row];
                ((KDDMSelectedUserCell *)cell).user = user;
                [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:((KDDMSelectedUserCell *)cell).avatarView];
            }
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if(cell == nil) {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] ;//autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_add_participant_btn"]];
                [cell.contentView addSubview:imageView];
//                [imageView release];
                
                CGRect rect = cell.contentView.bounds;
                rect.origin.y = rect.size.height - 47;
                rect.origin.x = 0;
                rect.size = CGSizeMake(46, 46);
                
                imageView.frame = rect;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == tableView_) {
        KDUser *user = nil;
        if(state_ == KDDMParticipantPickerStatePicking) {
            user = [localCachedUsers_ objectAtIndex:indexPath.row];
        }else {
            user = [networkUsers_ objectAtIndex:indexPath.row];
        }
        if (type_ == KDFrequentContactsType_DM_ADD_PEOPLE && [user.userId isEqualToString:[[KDUtility defaultUtility] currentUserId]]) {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDFrequentContactsPickViewController_cannot_add_self")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alterView show];
//            [alterView release];
        }else {
            
            [self _didPickingUser:user atIndexPath:indexPath];
        }
       
    }else if(tableView == selectedparticipantTableView_) {
        if(indexPath.row >= pickedUsersArray_.count) return;
        
        [pickedUsersArray_ removeObjectAtIndex:indexPath.row];
        [self.selectedparticipantTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView reloadData];
        [self _updateDoneButton];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [KDAvatarView loadImageSourceForTableView:(UITableView *)scrollView];
    
}
///////////////////////////////////////////////////////////////

#pragma mark - KDSearchBar delegate methods

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar {
    [self _maskViewWithVisible:YES];
    
    [self _changeMentionPickerState:KDDMParticipantPickerStateSearching];
    
}
- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar {
    [self _maskViewWithVisible:NO];
    [self textChanged:searchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(KDSearchBar *)searchBar {
    return (mentionPickerFlags_.indexingCachedUsers == 0);
}

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    [self textChanged:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar {
    if ([searchBar isFirstResponder] && [searchBar canResignFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    
    [self _changeMentionPickerState:KDDMParticipantPickerStatePicking];
}
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    currentPage_ = 1;
    [self _search];
}

- (void)textChanged:(NSString *)text
{
    if(!text || text.length == 0) {
        [self _showPromptInfo:NO info:nil];
        [self _changeMentionPickerState:KDDMParticipantPickerStatePicking];
    }
}

/////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)_updateDoneButton {
    NSUInteger count = (pickedUsersArray_ != nil) ? [pickedUsersArray_ count] : 0;
    NSString *btnTitle = nil;
    if (count > 0) {
        btnTitle = [NSString stringWithFormat:@"%@(%d)", ASLocalizedString(@"XTSelectPersonsView_Begin"),(unsigned long)count];
    } else {
        btnTitle = ASLocalizedString(@"XTSelectPersonsView_Begin");
    }
    self.doneBtn.enabled = (count > 0);
    [self.doneBtn setTitle:btnTitle forState:UIControlStateNormal];
    
}

- (void)saveSelectedParticipant {
    if (pickedUsersArray_ == nil || [pickedUsersArray_ count] < 1) return;
    
    // save picked user into database
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
        
        // access picked users at here is not thread safely at here
        [userDAO saveUsersSimple:pickedUsersArray_ database:fmdb];
        
        return nil;
        
    } completionBlock:nil];
}

- (void)_didFinishPicking:(UIButton *)btn {
    [self saveSelectedParticipant];
    if (delegate_ != nil &&[delegate_ respondsToSelector:@selector(frequentContactsPickViewController:pickedUsers:)]) {
        
        //filter
        NSMutableArray *shouldAddUsers = [NSMutableArray arrayWithCapacity:pickedUsersArray_.count];
        for(KDUser *nUser in pickedUsersArray_) {
            BOOL isExists = NO;
            for(NSString *userId in _alreadyExistsUserIds) {
                if([nUser.userId isEqualToString:userId]) {
                    isExists = YES;
                    break;
                }
            }
            
            if(!isExists) {
                [shouldAddUsers addObject:nUser];
            }
        }
        
        if(shouldAddUsers.count > 0)
            [delegate_ frequentContactsPickViewController:self pickedUsers:shouldAddUsers];
        
        [self.navigationController popToViewController:(KDDMConversationViewController *)delegate_ animated:YES];
        
        return;
    }
    
    __block NSString *threadId = nil;
    
    //add current user
    KDUser *curUser = [[KDUser alloc] init];
    curUser.userId = [KDManagerContext globalManagerContext].userManager.currentUserId;
    [pickedUsersArray_ addObject:curUser];
    
    if(pickedUsersArray_.count == 2) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *db){
            id<KDDMThreadDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
            return [dao queryDMThreadsWithLimit:-1 database:db];
        }completionBlock:^(id results){
            NSArray *threads = (NSArray *)results;
            if(threads && threads.count) {
                for(KDDMThread *thread in threads) {
                    if(thread.participantsCount == 2) {
                        KDUser *pickedUser = [pickedUsersArray_ objectAtIndex:0];
                        if(thread.subject && [thread.subject isEqualToString:pickedUser.screenName]) {
                            threadId = thread.threadId;
                            break;
                        }
                    }
                }
            }
        }];
    }
    
    if(threadId == nil) {
        NSMutableString *tempID = [NSMutableString string];
        [tempID appendString:@"tempThreadId"];
        
        //sort pickedUsersArray_
        [pickedUsersArray_ sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            KDUser *user1 = (KDUser *)obj1;
            KDUser *user2 = (KDUser *)obj2;
            
            NSString *userId1 = user1.userId;
            NSString *userId2 = user2.userId;
            
            return [userId1 compare:userId2];
        }];
        
        for(KDUser *user in pickedUsersArray_) {
            [tempID appendString:[NSString stringWithFormat:@"+%@", user.userId]];
        }
        
        threadId = tempID;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartConversation" object:self userInfo:[NSDictionary dictionaryWithObject:threadId forKey:@"NewDMThreadID"]];
    
}

- (void)_shouldUpdateContentViewPosition {
    BOOL isPickingState = [self _isPickingState];
    pickingHeaderView_.hidden = !isPickingState;
    
    UIView *topView = isPickingState ? pickingHeaderView_ : searchBar_;
    CGRect frame = topView.frame;
    CGFloat offsetY = frame.origin.y + frame.size.height;
    
    frame = tableView_.frame;
    frame.origin.y = offsetY;
    frame.size.height = self.view.bounds.size.height - offsetY-KD_SELECTED_PARTICIPANT_TABLE_VIEW_HEIGHT;
    tableView_.frame = frame;
}

- (void)_shouldUpdateTableFooterView {
    BOOL isPickingState = [self _isPickingState];
    if (isPickingState) {
        tableView_.tableFooterView = nil;
        currentPage_ = 1;
        //KD_RELEASE_SAFELY(previousKeywords_);
        
    }else if(searchBar_.text.length > 0) {
        [self _buildTableFooterView];
        
        [self _updateLoadButtonState];
    }
}

- (void)_buildTableFooterView {
    if (footerView_ == nil) {
        // footer view
        CGRect frame = CGRectMake(0.0, 0.0, tableView_.bounds.size.width, 54.0);
        footerView_ = [[UIView alloc] initWithFrame:frame];
        
        // load button
        UIButton *loadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loadBtn_ = loadBtn;
        
        loadBtn.frame = CGRectMake((frame.size.width - 240.0) * 0.5, (frame.size.height - 32.0) * 0.5, 240.0, 32.0);
        loadBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        
        [loadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [loadBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        UIImage *bgImage = [UIImage imageNamed:@"dm_thread_more_btn_bg.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:0.5*bgImage.size.width topCapHeight:0.5*bgImage.size.height];
        [loadBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
        
        [loadBtn addTarget:self action:@selector(_loadUsers:) forControlEvents:UIControlEventTouchUpInside];
        [footerView_ addSubview:loadBtn];
        
        footerView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    if (tableView_.tableFooterView == nil) {
        tableView_.tableFooterView = footerView_;
    }
}

- (void)_updateLoadButtonState {
    mentionPickerFlags_.isLoadPagingUsers = 1;
    [loadBtn_ setTitle: ASLocalizedString(@"KDPlaceAroundTableView_More") forState:UIControlStateNormal];

    loadBtn_.hidden = NO;
    loadBtn_.enabled = YES;
}

- (void)_toggleLoadButtonEnabled:(BOOL)enabled isLoading:(BOOL)loading{
    if (loadBtn_ != nil) {
        NSString *btnTitle = loading ? ASLocalizedString(@"RecommendViewController_Load") :  ASLocalizedString(@"KDPlaceAroundTableView_More");
        [loadBtn_ setTitle:btnTitle forState:UIControlStateNormal];
        
        loadBtn_.hidden = NO;
        loadBtn_.enabled = enabled;
    }
}

- (KDMentionPickerSectionView *)_sectionViewWithFrame:(CGRect)frame text:(NSString *)text {
    KDMentionPickerSectionView *sv = [[KDMentionPickerSectionView alloc] initWithFrame:frame];// autorelease];
    sv.sectionLabel.text = text;
    
    return sv;
}

- (void)_showPromptInfo:(BOOL)visible info:(NSString *)info {
    if (visible) {
        if (promptInfoLabel_ == nil) {
            CGRect frame = CGRectMake(0.0, 80.0, self.view.bounds.size.width, 30.0);
            promptInfoLabel_ = [[UILabel alloc] initWithFrame:frame];
            
            promptInfoLabel_.backgroundColor = [UIColor clearColor];
            promptInfoLabel_.textColor = [UIColor grayColor];
            promptInfoLabel_.font = [UIFont systemFontOfSize:15.0];
            promptInfoLabel_.textAlignment = NSTextAlignmentCenter;
            
            [self.view insertSubview:promptInfoLabel_ aboveSubview:tableView_];
        }
        
        promptInfoLabel_.text = info;
    }
    
    promptInfoLabel_.hidden = !visible;
}

- (void)_activityViewWithVisible:(BOOL)visible info:(NSString *)info {
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 120.0) * 0.5, (self.view.bounds.size.height - 80.0) * 0.5, 120.0, 80.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.view addSubview:activityView_];
    }
    
    if(visible){
        [activityView_ show:YES info:info];
        
    }else {
        [activityView_ hide:YES];
    }
}


- (void)_resignFirstResponderForSearchBar {
    if ([searchBar_ isFirstResponder] && [searchBar_ canResignFirstResponder]) {
        [searchBar_ resignFirstResponder];
    }
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark The data source for current picking state

- (BOOL)_isPickingState {
    return KDDMParticipantPickerStatePicking == state_;
}

- (void)_changeMentionPickerState:(KDDMentionPickerState)state {
    if (state_ != state) {
        [self updateState:state];
//        [self _shouldUpdateContentViewPosition];
        [self _shouldUpdateTableFooterView];
        
        if ([self _isPickingState]) {
            [self _clearLoadedNetworkUsers];
        }else {
            [self _updateLoadButtonState];
        }
    }
    
}
//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark picking users

- (BOOL)_isPickedUser:(KDUser *)user {
    __block BOOL picked = NO;
    [pickedUsersArray_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(KDUser *)obj userId] isEqualToString:user.userId]) {
            picked = YES;
            *stop = YES;
        }
    }];
    
    return picked;
}

- (void)_addPickedUser:(KDUser *)user {
    if (user == nil) {
        return;
    }
    
    if (pickedUsersArray_ == nil) {
        pickedUsersArray_ = [[NSMutableArray alloc] init];
    }
    [pickedUsersArray_ addObject:user];
}

- (void)addPickedUsers:(NSArray *)users {
    if (users != nil && [users count] > 0) {
        for (KDUser *user in users) {
            [self _addPickedUser:user];
        }
    }
}

- (void)_removePickedUser:(KDUser *)user {
    [pickedUsersArray_ removeObject:user];
}

- (NSMutableArray *)_buildGroupedUserContainer {
    // initiailize grouped users container
    NSMutableArray *groupedUsers = [NSMutableArray array];
    int i = 0;
    for (; i < 27; i++) {
        [groupedUsers addObject:[NSMutableArray array]];
    }
    
    return groupedUsers;
}

- (NSUInteger)_indexAtLocalCacheWithUser:(KDUser *)user {
    NSUInteger index = NSNotFound;
    if (localCachedUsers_ != nil) {
        BOOL found = NO;
        NSUInteger anchor = 0;
        for (KDUser *item in localCachedUsers_) {
            if ([user.userId isEqualToString:item.userId]) {
                found = YES;
                break;
            }
            
            anchor++;
        }
        
        if (found) {
            index = anchor;
        }
    }
    
    return index;
}

- (BOOL)_isExistAtLocalCacheWithUser:(KDUser *)user {
    return (NSNotFound != [self _indexAtLocalCacheWithUser:user]);
}

- (void)_didPickingUser:(KDUser *)user atIndexPath:(NSIndexPath *)indexPath {
    BOOL picked = [self _isPickedUser:user];
    if (picked) {
        //NSInteger index = [pickedUsersArray_ indexOfObject:user];
        __block NSInteger index;
        __block KDUser *theUser = nil;
        [pickedUsersArray_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(KDUser *)obj userId] isEqualToString:user.userId]) {
                theUser = obj;
                index = idx;
                *stop = YES;
            }
            
        }];
        
        [self _removePickedUser:theUser];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index  inSection:0];
        [self.selectedparticipantTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        
    } else {
        [self _addPickedUser:user];
        
        NSInteger index = [pickedUsersArray_ indexOfObject:user];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index  inSection:0];
        [self.selectedparticipantTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView_ reloadData];
    if (pickedUsersArray_.count > 0) {
        [self.selectedparticipantTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:pickedUsersArray_.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [self _updateDoneButton];
}

- (void)_clearLoadedNetworkUsers {
    if (networkUsers_ != nil) {
        [networkUsers_ removeAllObjects];
    }
}

////////////////////////////////////////////////////////

#pragma mark -
#pragma mark load network users

- (void)_loadUsers:(UIButton *)btn {
    [self _search];
}

- (void)_mergeUsers:(NSArray *)users {
    if(users == nil) return;
    
    [self.networkUsers addObjectsFromArray:users];
    
    NSUInteger count = [users count];
    
    [self.tableView reloadData];
    
    BOOL matched = (networkUsers_.count <= 0) ? NO : YES;
    NSString *info = matched ? nil : ASLocalizedString(@"SEARCH_NO_MATCHED_USER");
    [self _showPromptInfo:!matched info:info];
    
    if (matched) {
        BOOL hasNext = (count == KD_MAX_SEARCH_USERS_PAGE_COUNT) ? YES : NO;
        if (hasNext) {
            mentionPickerFlags_.isLoadPagingUsers = 1;
        }
        
        [self _toggleLoadButtonEnabled:hasNext isLoading:NO];
    }
    
    if (!matched || count < KD_MAX_SEARCH_USERS_PAGE_COUNT) {
        loadBtn_.hidden = YES;
    }
}

- (void)_search {
    if([searchBar_ canResignFirstResponder]){
        [searchBar_ resignFirstResponder];
    }
    
    [self _showPromptInfo:NO info:ASLocalizedString(@"SEARCH_NO_MATCHED_USER")];
    
    BOOL isPaging = (mentionPickerFlags_.isLoadPagingUsers == 1);
    NSString *keywords = searchBar_.text;
    
    self.previousKeywords = keywords;
    
    if(keywords.length == 0) return;
    
    if (!isPaging || currentPage_ == 1) {
        // if start search with new keywords, clear cached network users
        [self _clearLoadedNetworkUsers];
    }
    
    if (mentionPickerFlags_.hasRequests == 1) {
        [self _cancelRequets];
        
    } else {
        mentionPickerFlags_.hasRequests = 1;
        
        [self _activityViewWithVisible:YES info:ASLocalizedString(@"RecommendViewController_Load")];
        [self _toggleLoadButtonEnabled:NO isLoading:YES];
        
        // request parameters
        KDQuery *query = [KDQuery query];
        [[[query setParameter:@"q" stringValue:keywords]
          setParameter:@"count" integerValue:KD_MAX_SEARCH_USERS_PAGE_COUNT]
         setParameter:@"page" integerValue:currentPage_];
        
        __block KDFrequentContactsPickViewController *ppvc = self;// retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            [ppvc _activityViewWithVisible:NO info:nil];
            [ppvc _toggleLoadButtonEnabled:YES isLoading:NO];
            
            [self _shouldUpdateTableFooterView];
            
            if(!ppvc.networkUsers) {
                ppvc.networkUsers = [[NSMutableArray alloc] initWithCapacity:10];// autorelease];
            }
            
            if([response isValidResponse]) {
                if (results != nil) {
                    NSArray *users = results;
                    [ppvc _mergeUsers:users];
                    
                    // plus 1 to current page index
                    if(isPaging){
                        ppvc.currentPage += 1;
                    }
                }else {
                    [ppvc _showPromptInfo:YES info:ASLocalizedString(@"SEARCH_NO_MATCHED_USER")];
                    ppvc.loadBtn.hidden = YES;
                }
            } else {
                if(![response isCancelled]) {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:ppvc.view.window];
                }
            }
            
            (ppvc -> mentionPickerFlags_).hasRequests = 0;
            
            [ppvc.tableView reloadData];
            // release current view controller
//            [ppvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:search" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}



- (void)_cancelRequets {
    if(mentionPickerFlags_.hasRequests == 1){
        // cancel the requests
        [[KDRequestDispatcher globalRequestDispatcher] cancelRequestsWithDelegate:self force:NO];
    }
}

#pragma mark - KDUserPickableCell Delegate Method
- (void)didTapUserCell:(KDUserPickableCell *)cell
{
//    ProfileViewController *profile = [[ProfileViewController alloc] initWithUser:cell.user];
//    [self.navigationController pushViewController:[profile autorelease] animated:YES];
     [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:cell.user sender:cell];
}

////////////////////////////////////////////////////////

#pragma mark -
#pragma mark load local cached users

- (void)_loadLocalCachedUsers {
    [self _activityViewWithVisible:YES info:ASLocalizedString(@"RecommendViewController_Load")];
    
    mentionPickerFlags_.indexingCachedUsers = 1;
    
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
        return [userDAO queryFrequentcontactsWithType:type_ from:fmdb];
    }completionBlock:^(id result){
        mentionPickerFlags_.indexingCachedUsers = 0;
        if(!localCachedUsers_) {
            localCachedUsers_ = [[NSMutableArray alloc] initWithCapacity:10];
        }
        
        [localCachedUsers_ removeAllObjects];
        [localCachedUsers_ addObjectsFromArray:result];
        
        [self.tableView reloadData];
        
        [self _activityViewWithVisible:NO info:nil];
        [self _fetchFrequentContactsFromNetwork];
    }];
}

- (void)_fetchFrequentContactsFromNetwork {
    KDQuery *query = [KDQuery query];
    [query setParameter:@"limits" intValue:20];
    
    [self _activityViewWithVisible:YES info:nil];
    __block KDFrequentContactsPickViewController *fcpvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [self _activityViewWithVisible:NO info:nil];
        if([response isValidResponse]) {
            NSArray *users = (NSArray *)results;
            
            if(users && users.count > 0) {
                [localCachedUsers_ removeAllObjects];
                [localCachedUsers_ addObjectsFromArray:results];
                [self.tableView reloadData];
                
                [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    [userDAO saveFrequentContacts:users withType:type_ intoDatabase:fmdb];
                    
                    return nil;
                }completionBlock:NULL];
            }
        }else {
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:fcpvc.view.window];
            }
        }
        
//        [fcpvc release];
    };
    
    NSString *actionPath = nil;
    
    if(KDFrequentContactsType_At == type_) {
        actionPath = @"/users/:frequentAtContacts";
    }else if(KDFrequentContactsType_DM == type_ ||KDFrequentContactsType_DM_ADD_PEOPLE == type_) {
        actionPath = @"/users/:frequentDMContacts";
    }
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query configBlock:NULL completionBlock:completionBlock];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self _cancelRequets];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    loadBtn_ = nil;
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(pickingHeaderView_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(footerView_);
    
    //KD_RELEASE_SAFELY(promptInfoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    
    //KD_RELEASE_SAFELY(maskView_);
    //KD_RELEASE_SAFELY(toolBarView_);
    //KD_RELEASE_SAFELY(selectedparticipantTableView_);
    //KD_RELEASE_SAFELY(doneBtn_);
}



- (void)dealloc {
    delegate_ = nil;
    loadBtn_ = nil;
    
    //KD_RELEASE_SAFELY(localCachedUsers_);
    //KD_RELEASE_SAFELY(networkUsers_);
    
    //KD_RELEASE_SAFELY(pickedUsersArray_);
    //KD_RELEASE_SAFELY(previousKeywords_);
    
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(pickingHeaderView_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(footerView_);
    
    //KD_RELEASE_SAFELY(promptInfoLabel_);
    //KD_RELEASE_SAFELY(activityView_);
    
    //KD_RELEASE_SAFELY(maskView_);
    //KD_RELEASE_SAFELY(toolBarView_);
    //KD_RELEASE_SAFELY(selectedparticipantTableView_);
    //KD_RELEASE_SAFELY(doneBtn_);
    //[super dealloc];
}
@end
