//
//  KDDMThreadMembersViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-3.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDDMThreadMembersViewController.h"
#import "KDDefaultViewControllerContext.h"
#import "KDDMConversationViewController.h"
#import "KDNetworkUserBaseCell.h"

#import "ResourceManager.h"
#import "KDManagerContext.h"
#import "KDWeiboServicesContext.h"

#import "KDDMParticipantGridCellView.h"
//#import "KDDMParticipantPickerViewController.h"
#import "KDSingleInputViewController.h"
#import "KDActivityIndicatorView.h"
#import "KDErrorDisplayView.h"
#import "KDAddingGridView.h"
#import "KDDeletingGridView.h"
#import "KDDatabaseHelper.h"
#import "KDFrequentContactsPickViewController.h"
#import "KLSwitch.h"

@interface KDDMThreadMembersViewController ()<KDDMparticipantPickerViewDataSource,KDDMparticipantPickerViewDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property(nonatomic, retain) NSMutableArray *users;
@property(nonatomic,copy)NSString *dmTitle;
@property(nonatomic, retain) KDActivityIndicatorView *activityView;
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, assign)BOOL isPickerViewInEdite;
@property(nonatomic, assign)BOOL isMyThread;
@property(nonatomic, retain)KLSwitch *theSwitch;
@property(nonatomic, retain)UIButton *quitThreadBtn;
@property(nonatomic, assign)KDUser *userToBeDeleted; // 需要删除的人

@end



@implementation KDDMThreadMembersViewController

@synthesize dmThread=dmThread_;
@synthesize users = users_;
@synthesize pickerView = pickerView_;
@synthesize dmTitle = dmTitle_;
@synthesize activityView = activityView_;
@synthesize dmThreadId = dmThreadId_;
@synthesize tableView = tableView_;
@synthesize theSwitch = theSwitch_;
@synthesize quitThreadBtn = quitThreadBtn_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dmThread_ = nil;
        users_ = nil;
        
        viewControllerFlags_.initilization = 1;
        
        self.navigationItem.title = ASLocalizedString(@"KDDMThreadMembersViewController_sms");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dmThreadSubjectChanged:) name:KDDMThreadSubjectDidChangeNofication object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridCellAddingViewTouched:) name:KDGridCellAddingViewTouched object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridCellDeletingViewTouched:) name:KDGridCellDeltingViewTouched object:nil];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dm_info_bg"]];
    
    self.navigationController.navigationItem.rightBarButtonItem = nil;
    tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(self.view.bounds) - 16, CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.contentInset = UIEdgeInsetsMake(10.f, 0.0f, 0.0f, 0.0f);
    tableView_.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dm_info_bg"]];    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView_];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(viewControllerFlags_.initilization == 1){
        viewControllerFlags_.initilization = 0;
        
        [self retrieveJoinedUsers];
    }
}

///////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (UIButton *)quitThreadBtn {
    if (!quitThreadBtn_) {
        quitThreadBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        quitThreadBtn_.titleLabel.font = [UIFont systemFontOfSize:15.0];
        quitThreadBtn_.layer.cornerRadius = 5.0f;
        quitThreadBtn_.layer.masksToBounds = YES;
        [quitThreadBtn_ setBackgroundColor:RGBCOLOR(255, 102, 0)];
        
        [quitThreadBtn_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [quitThreadBtn_ setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [quitThreadBtn_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [quitThreadBtn_ setTitle:ASLocalizedString(@"KDDMThreadMembersViewController_exit")forState:UIControlStateNormal];
        quitThreadBtn_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [quitThreadBtn_ addTarget:self action:@selector(quitThreadBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return quitThreadBtn_;
}

// 置顶
- (void)topThread {
    if (!dmThread_) {
        return;
    }
    KDQuery *query = [KDQuery query];
    [query setParameter:@"threadId" stringValue:dmThread_.threadId];
    
    __block KDDMThreadMembersViewController *tvc = self;// retain];
    [tvc _activityViewWithVisible:YES info:nil];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [tvc _activityViewWithVisible:NO info:nil];
        BOOL success = NO;
        if ([response isValidResponse]) {
            NSDictionary *info = results;
            if (info != nil) {
                success = [info boolForKey:@"result"];
            }
        }else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:tvc.view.window];
            }
        }
        
        tvc.dmThread.isTop = success;
        [tvc updateSiwtch];
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KDDMThreadHasBeenToped object:self userInfo:@{@"threadId":tvc.dmThread.threadId}];
        }
//        [tvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:topThreadById" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

//撤销置顶
- (void)deTopThread {
    if (!dmThread_) {
        return;
    }
    KDQuery *query = [KDQuery query];
    [query setParameter:@"threadId" stringValue:dmThread_.threadId];
    
    __block KDDMThreadMembersViewController *tvc = self;// retain];
    
    [tvc _activityViewWithVisible:YES info:nil];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [tvc _activityViewWithVisible:NO info:nil];
        BOOL success = NO;
        if ([response isValidResponse]) {
            NSDictionary *info = results;
            if (info != nil) {
                success = [info boolForKey:@"result"];
                
            }
        }else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:tvc.view.window];
            }
        }
        
        tvc.dmThread.isTop = !success;
        [tvc updateSiwtch];
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KDDMThreadHasBeenCancelTope object:self userInfo:@{@"threadId":tvc.dmThread.threadId}];
        }
//        [tvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:cancelTopThreadById" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (void)updateSiwtch {
    //theSwitch_.on = self.dmThread.isTop;
    [theSwitch_ updateStateWithNoEvent:self.dmThread.isTop];
}
- (KLSwitch *)theSwitch {
    if (!theSwitch_) {
        theSwitch_ = [[KLSwitch alloc] initWithFrame:CGRectMake(0, 0, 50.0, 31.0)];
        [theSwitch_ setOnTintColor:RGBCOLOR(0.f, 119.f, 255.f)];
        [theSwitch_ setThumbBorderColor:MESSAGE_CT_COLOR];
        
        theSwitch_.didChangeHandler =  ^(BOOL on) {
            if(on) {
                [self topThread];
            }else {
                [self deTopThread];
            }
            
            
        };
    }
    [self updateSiwtch];
    return theSwitch_;
}

- (void)setDmThread:(KDDMThread *)dmThread {
    if(dmThread_ != dmThread) {
//        [dmThread_ release];
        dmThread_ = dmThread;// retain];
        self.dmTitle = [dmThread_.subject stringByRemovingDMSubjectPostfix];
    }
}

- (BOOL)hasUsers {
    return (self.users && [users_ count] >0);
}

- (void)storeJoinedUserIDs {
    NSMutableString *IDs = [NSMutableString string];
    NSUInteger idx = 0;
    NSUInteger count = [self.users count];
    
    for (KDUser *user in self.users) {
        [IDs appendString:user.userId];
        if(idx++ != (count - 1)){
            [IDs appendString:@","];
        }
    }
    
    if(!self.dmThread) {
        self.dmThread = [[KDDMThread alloc] init];// autorelease];
        dmThread_.threadId = self.dmThreadId;
    }
    
    dmThread_.participantIDs = IDs;
    
    // save thread into database
    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
        [threadDAO saveDMThreads:@[dmThread_] database:fmdb rollback:rollback];
        
        return nil;
        
    } completionBlock:nil];
}

- (void)loadJoinedUserFromServer {
    [self _activityViewWithVisible:YES info:ASLocalizedString(@"RecommendViewController_Load")];
    __block KDDMThreadMembersViewController *tmvc = self;// retain];
    if((dmThreadId_ && [dmThreadId_ hasPrefix:@"tempThreadId"])||[self.dmThread.threadId hasPrefix:@"tempThreadId"]) {
        [KDDatabaseHelper asyncInDatabase:^id(FMDatabase *fmdb){
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            
            NSArray *userIds = [dmThreadId_ componentsSeparatedByString:@"+"];
            NSUInteger count = userIds.count;
            NSMutableArray *users = [NSMutableArray array];
            for(NSUInteger index = 1; index < count; index++) {
                NSString *userId = [userIds objectAtIndex:index];
                KDUser *user = [userDAO queryUserWithId:userId database:fmdb];
                [users addObject:user];
            }
            
            return users;
        }completionBlock:^(id result){
            [tmvc _activityViewWithVisible:NO info:nil];
            if (!users_) {
                tmvc.users = [NSMutableArray array];
            }
            [tmvc.users addObjectsFromArray:result];
            [tmvc.tableView reloadData];
            
//            [tmvc release];
        }];
    } else if(![self.dmThread.threadId hasPrefix:@"tempThreadId"]) {
        KDQuery *query = [KDQuery query];
        
        NSString *threadId = self.dmThread.threadId;
        if(!threadId) threadId = self.dmThreadId;
        
        [query setProperty:threadId forKey:@"threadId"];
        
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            [tmvc _activityViewWithVisible:NO info:nil];
            
            if ([response isValidResponse]) {
                if (results != nil) {
                    NSArray *user = results[@"user"];
                    if (![user isKindOfClass:[NSNull class]]) {
                        if (!users_) {
                            self.users = [NSMutableArray array];
                        }
                        [self.users addObjectsFromArray:user];
                    }
                    
                    if (!dmThread_ &&![results[@"thread"] isKindOfClass:[NSNull class]]) {
                        self.dmThread = results[@"thread"];
                    }
                    tmvc.isMyThread = [(NSNumber *)results[@"isMyThread"] boolValue];
                    [tmvc storeJoinedUserIDs];
                    [tmvc.tableView reloadData];
                    
                }
                
            } else {
                if (![response isCancelled]) {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:tmvc.view.window];
                }
            }
            
            // release current view controller
//            [tmvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:threadParticipants" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}

- (void) retrieveJoinedUsers {
    [self loadJoinedUserFromServer];
}


///////////////////////////////////////////////////////////////////////////
- (KDDMParticipantPickerView *)pickerView {
    if(pickerView_ == nil ) {
        pickerView_ = [[KDDMParticipantPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        pickerView_.delegate = self;
        pickerView_.dataSource = self;
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(participantPickerViewTapped:)];
        [pickerView_ addGestureRecognizer:gestureRecognizer];
//        [gestureRecognizer release];
        
    }
    return pickerView_;
    
}

- (void)executeUserDeleting {
    if ([self.users containsObject:self.userToBeDeleted]) {
        [self.users removeObject:self.userToBeDeleted];
        self.userToBeDeleted = nil;
        self.pickerView = nil;
        [self.tableView reloadData];
    }
    if (self.conversationViewController && [self.conversationViewController respondsToSelector:@selector(shouldLoadMessages)]) {
        [self.conversationViewController performSelector:@selector(shouldLoadMessages) withObject:nil];
    }
}

- (void)deleteParticipant:(KDUser *)user {
    
    if (!user) {
        return;
    }
    if ([user.userId isEqualToString:[[KDUtility defaultUtility] currentUserId]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_tips")message:ASLocalizedString(@"KDDMThreadMembersViewController_tips_error1")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
//        [alertView release];
        return;
    }
    self.userToBeDeleted = user;
    if (!dmThread_) { //临时创建的会话
        //
        [self executeUserDeleting];
        if (self.conversationViewController && [self.conversationViewController respondsToSelector:@selector(deleParticipiant:)]) {
            [self.conversationViewController performSelector:@selector(deleParticipiant:) withObject:self.users];
        }
        
    }else {
        
        __block KDDMThreadMembersViewController *tmvc = self;// retain];
        [tmvc _activityViewWithVisible:YES info:nil];
        KDQuery *query = [KDQuery query];
        [query setProperty:dmThread_.threadId forKey:@"threadId"];
        [query setParameter:@"userId" stringValue:user.userId];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            [tmvc _activityViewWithVisible:NO info:nil];
            
            if ([response isValidResponse]) {
                if (results != nil) {
                    if ([(NSNumber *)results boolValue]) {
                        [tmvc executeUserDeleting];
                        
                    }
                }
                
            } else {
                if (![response isCancelled]) {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:tmvc.view.window];
                }
            }
            
            // release current view controller
//            [tmvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/dm/:deleteParticipant" query:query
                                     configBlock:nil completionBlock:completionBlock];
        
    }
    
}


- (void)doAfterQuit {
    NSString *threaId = dmThreadId_;
    if (!threaId) {
        threaId = self.dmThread.threadId;
    }
    if (threaId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDDMThreadHasBeenDeleted object:self userInfo:@{@"threadId":threaId}];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (void)askToQuitThread {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDDMThreadMembersViewController_tips_exit")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDDMThreadMembersViewController_exit2"), nil];
    [actionSheet showInView:self.view];
//    [actionSheet release];
    
}

- (void)quitThread {
    if (!dmThread_) { //临时会话
        [self doAfterQuit];
    }
    else{
        __block KDDMThreadMembersViewController *tmvc = self;// retain];
        [tmvc _activityViewWithVisible:YES info:nil];
        KDQuery *query = [KDQuery query];
        [query setProperty:dmThread_.threadId forKey:@"threadId"];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            [tmvc _activityViewWithVisible:NO info:nil];
            
            if ([response isValidResponse]) {
                if (results != nil) {
                    if ([(NSNumber *)results boolValue]) {
                        [tmvc doAfterQuit];
                    }
                }
                
            } else {
                if (![response isCancelled]) {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:tmvc.view.window];
                }
            }
            
            // release current view controller
//            [tmvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/dm/:quitThread" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
    
}

#pragma mark -
#pragma mark UITableView delegate and data source methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //
    NSInteger num = 1;
    if (self.dmThread &&self.dmThread.isPublic) {
        num = 4;
    }else if (self.dmThread &&!self.dmThread.isPublic) {
        num = 2;
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return [self hasUsers] ? [users_ count] : 1;
    NSInteger row = 0;
    if (section != 0) {
        row = 1;
    }
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat rowHeight = 44.0f;
    if (indexPath.section == 0) {
        rowHeight = 0;
    }
    return rowHeight;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] ;//autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
        selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selectBgView.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = selectBgView;
        
        cell.layer.borderColor = RGBCOLOR(203.f, 203.f, 203.f).CGColor;
        cell.layer.borderWidth = 0.5;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        
    }
    if (self.dmThread && self.dmThread.isPublic) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row == 0 && indexPath.section == 1) {
            cell.textLabel.text = ASLocalizedString(@"KDDMThreadMembersViewController_sms_name");
            cell.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = self.dmTitle;
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3"]];
        }else if (indexPath.row == 0 && indexPath.section == 2) {
            cell.textLabel.text = ASLocalizedString(@"KDDMThreadMembersViewController_pop_sms");
            cell.accessoryView = self.theSwitch;
            
        }else if(indexPath.row == 0 && indexPath.section == 3) {
            cell.backgroundView = self.quitThreadBtn;
        }
    }else if(self.dmThread &&!self.dmThread.isPublic){
        if (indexPath.row == 0 && indexPath.section == 1) {
            cell.textLabel.text = ASLocalizedString(@"KDDMThreadMembersViewController_pop_sms");
            cell.accessoryView = self.theSwitch;
        }
    }
    
    return cell;
    
}


- (CALayer *)genLine
{
    CALayer *line = [CALayer layer];
    line.backgroundColor = RGBCOLOR(203, 203, 203).CGColor;
    
    return line;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dmThread && self.dmThread.isPublic) {
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                KDSingleInputViewController *singleInputViewCongroller = [[KDSingleInputViewController alloc] initWithBaseViewController:self content:self.dmTitle type:KDSingleInputContentTypeDMThreadSubject];
                [self.navigationController pushViewController:singleInputViewCongroller animated:YES];
//                [singleInputViewCongroller release];
                
            }
        }else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                //
                [self askToQuitThread];
            }
        }
    }
    
}

//修改背景颜色  王松 2013-12-24
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = nil;
    if (section == 0) {
        if ([self.users count] >0) {
            DLog(@"viewfo header....");
            view = [self pickerView];
            //[(KDDMParticipantPickerView *)view reloadData:NO];
        }
    }else {
        view = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
        view.backgroundColor = [UIColor clearColor];
    }
    return view;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [[self pickerView] realHeight];
    }else {
        return 20;
    }
    
}


#pragma mark - KDDMParticipantPickerView DataSoure and Delegate Methods

- (NSInteger)gridCount {
    return [self.users count]; //[users_ count]; 20
}

- (KDGridCellView *)gridCellView:(NSInteger)index {
    KDDMParticipantGridCellView *gridCellView = [[KDDMParticipantGridCellView alloc] initWithFrame:[self boundsOfCell]];
    KDUser *theUser = [users_ objectAtIndex:index];
    gridCellView.user = theUser;
    
    return gridCellView;// autorelease];
}

- (KDGridCellView *)addButtonView {
    KDAddingGridView *view = [[KDAddingGridView alloc] initWithFrame:[self boundsOfCell]];
    
    return view;// autorelease];
    
}

- (KDGridCellView *)deleteButtonView {
    KDDeletingGridView *view = [[KDDeletingGridView alloc] initWithFrame:[self boundsOfCell]];
    return view;// autorelease];
}


- (CGRect)boundsOfCell {
    return CGRectMake(0, 0, 60, 85);
}

- (BOOL)addViewEnable {
    return YES;
}

- (BOOL)deleViewEnable {
    return ((self.isMyThread && self.dmThread.isPublic)||(dmThreadId_ && [dmThreadId_ hasPrefix:@"tempThreadId"])||([self.dmThread.threadId hasPrefix:@"tempThreadId"]));
}

- (void)pickerView:(KDDMParticipantPickerView *)view shouldDeleteGridAtIndex:(NSInteger)index {
    if (self.isPickerViewInEdite) {
        KDUser *user = [users_ objectAtIndex:index];
        [self deleteParticipant:user];
    }
    
}



- (void)pickerView:(KDDMParticipantPickerView *)view didSelectGridAtIndex:(NSInteger)index {
    KDUser *user = [users_ objectAtIndex:index];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:user sender:view];
}

- (void)participantPickerViewTapped:(UITapGestureRecognizer *)gestrueRecognizer {
    if (self.isPickerViewInEdite) {
        self.isPickerViewInEdite = NO;
        [self.pickerView reloadCell:NO shouldReArrange:NO];
    }
}

- (void)pickerView:(KDDMParticipantPickerView *)view willDisplayGridView:(KDGridCellView *)gridCellView {
    if (self.isPickerViewInEdite) {
        // [pickerView_ reloadCell:NO shouldReArrange:NO];
        [gridCellView changedToEdited];
    }else {
        [gridCellView recoveredFromEdited];
    }
}

#pragma mark - Public Methods

- (void)updateDMThreadSubject:(NSString *)subject completedBlock:(id (^)(BOOL, BOOL))block {
    __block KDDMThreadMembersViewController *tmvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL success = [(NSNumber *)results boolValue];
        if (success) {
            
            NSString *threadId = dmThreadId_;
            if (threadId == nil) {
                threadId = dmThread_.threadId;
            }
            
            NSDictionary *userInfo = @{@"subject" : subject, @"threadId":threadId};
            [[NSNotificationCenter defaultCenter] postNotificationName:KDDMThreadSubjectDidChangeNofication
                                                                object:nil userInfo:userInfo];
        }
        
        if (block != nil) {
            block(success, [response isCancelled]);
        }
        
        // release current view controller
//        [tmvc release];
    };
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"threadId" stringValue:self.dmThread.threadId]
     setParameter:@"subject" stringValue:subject];
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/dm/:updateSubject" query:query
                                 configBlock:nil completionBlock:completionBlock];
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
#pragma mark - Notification Handler

//- (void)gridCellAddingViewTouched:(NSNotification *)notification {
//    KDDMParticipantPickerViewController *pickerViewController = [[KDDMParticipantPickerViewController alloc] init];
//    NSArray *viewControllers = [self.navigationController viewControllers];
//    if ([viewControllers count] > 1) {
//        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:1];
//        if ([viewController isKindOfClass:[KDDMConversationViewController class]]) {
//            pickerViewController.delegate = (KDDMConversationViewController*)viewController;
//        }
//    }
//
//    pickerViewController.alreadyExistsUserIds = [users_ valueForKeyPath:@"userId"];
//
//    [self.navigationController pushViewController:pickerViewController animated:YES];
//    [pickerViewController release];
//}

- (void)gridCellAddingViewTouched:(NSNotification *)notification {
    KDFrequentContactsPickViewController *pickerViewController = [[KDFrequentContactsPickViewController alloc] initWithType:KDFrequentContactsType_DM_ADD_PEOPLE];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    if ([viewControllers count] > 1) {
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:1];
        if ([viewController isKindOfClass:[KDDMConversationViewController class]]) {
            pickerViewController.delegate = (KDDMConversationViewController*)viewController;
        }
    }
    
    pickerViewController.alreadyExistsUserIds = [users_ valueForKeyPath:@"userId"];
    
    [self.navigationController pushViewController:pickerViewController animated:YES];
//    [pickerViewController release];
}

- (void)gridCellDeletingViewTouched:(NSNotification *)notification {
    if(!self.isPickerViewInEdite) {
        self.isPickerViewInEdite = YES;
        [self.pickerView reloadCell:NO shouldReArrange:NO];
    }
}

- (void)dmThreadSubjectChanged:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *subject = [userInfo objectForKey:@"subject"];
    NSString *threadId = [userInfo objectForKey:@"threadId"];
    
    if (threadId && [threadId isEqualToString:dmThread_.threadId]) {
        [self updateThreadSubject:subject];
    }
    
    
}

- (void)updateThreadSubject:(NSString *)subject {
    self.dmTitle = subject;
    self.dmThread.subject = [NSString stringWithFormat:ASLocalizedString(@"KDDMThreadMembersViewController_tips_member"), subject, (unsigned long)dmThread_.participantsCount];

    [self.tableView reloadData];
    
    // save thread into database
    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDDMThreadDAO> threadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
        [threadDAO saveDMThreads:@[dmThread_] database:fmdb rollback:rollback];
        
        return nil;
        
    } completionBlock:nil];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"buttonIndex = %d",buttonIndex);
    if (buttonIndex == 0) {
        [self quitThread];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KDDMThreadSubjectDidChangeNofication
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KDGridCellAddingViewTouched
                                                  object:nil];
    
    //KD_RELEASE_SAFELY(dmThread_);
    //KD_RELEASE_SAFELY(users_);
    //KD_RELEASE_SAFELY(pickerView_);
    //KD_RELEASE_SAFELY(dmTitle_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(dmThreadId_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(theSwitch_);
    //KD_RELEASE_SAFELY(quitThreadBtn_);
    
    //[super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    //KD_RELEASE_SAFELY(pickerView_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(theSwitch_);
    //KD_RELEASE_SAFELY(quitThreadBtn_);
}

@end
