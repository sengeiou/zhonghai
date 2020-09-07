//
//  KDABPersonDetailsViewController.m
//  kdweibo
//
//  Created by laijiandong on 12-11-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDABPersonDetailsViewController.h"

//#import "KDABPersonProfileHeaderView.h"
#import "KDABActionTabBar.h"
#import "KDABPersonRecordCell.h"
#import "KDABPersonActionCell.h"
#import "KDActivityIndicatorView.h"
#import "KDErrorDisplayView.h"

#import "KDABPerson.h"
#import "KDABPersonActionHelper.h"

#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"
#import "KDRequestWrapper.h"

#import "KDUIUtils.h"
#import "KDDatabaseHelper.h"
#import "NSDictionary+Additions.h"
#import "MBProgressHUD.h"
#import "MPFoldTransition.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface KDABPersonDetailsViewController () <UITableViewDelegate, UITableViewDataSource, KDABActionTabBarDelegate, KDRequestWrapperDelegate>

@property(nonatomic, retain) KDABPersonActionHelper *actionHelper;
@property(nonatomic, retain) NSMutableArray *recordItems;

//@property(nonatomic, retain) KDABPersonProfileHeaderView *profileView;
@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) KDABActionTabBar *actionBar;
@property(nonatomic, retain) KDActivityIndicatorView *activityView;

@end

@implementation KDABPersonDetailsViewController {
 @private
    NSInteger selectedSection;
    
    struct {
        unsigned int updatedFavoriteState:1;
        unsigned int hasFavoritedRequests:1;
        unsigned int initWithUserId:1;
    }personDetailsFlags_;
}

@synthesize person=person_;
@synthesize userId = userId_;
@synthesize actionHelper=actionHelper_;
@synthesize recordItems=recordItems_;


@synthesize tableView=tableView_;
@synthesize actionBar=actionBar_;
@synthesize activityView=activityView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"AB_VIEWING_CONTACT_PROFILE", @"");
        
        personDetailsFlags_.updatedFavoriteState = 0;
        personDetailsFlags_.hasFavoritedRequests = 0;
        actionHelper_ = [[KDABPersonActionHelper alloc] initWithViewController:self];
        selectedSection = NSNotFound;
    }
    
    return self;
}

- (id)initWithABPerson:(KDABPerson *)person {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        person_ = person;// retain];
        actionHelper_.pickedPerson = person_;
        personDetailsFlags_.initWithUserId = 0;
        
        [self _buildContactRecordItems];
    }
    
    return self;
}

- (id)initWithUserId:(NSString *)userId {
    self = [self initWithNibName:nil bundle:nil];
    
    if(self) {
        personDetailsFlags_.initWithUserId = 1;
        
        userId_ = [userId copy];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(237, 237, 237);
    
    // search bar
    CGFloat offsetY = 0.0;
    CGRect frame = CGRectMake(0.0f, offsetY, CGRectGetWidth(self.view.bounds), 0.0f);
    
    // table view
    offsetY += frame.size.height;
    frame.origin.y = offsetY;
    frame.size.height = self.view.bounds.size.height - offsetY - 44.0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView = tableView;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.backgroundColor = [UIColor clearColor];
    tableView_.backgroundView = nil;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // action tab bar
    frame.origin.y = self.view.bounds.size.height - 45.0;
    frame.size.height = 45.0;
    
    KDABActionTabBar *actionBar = [[KDABActionTabBar alloc] initWithFrame:frame type:KDABActionTabBarTypeActionBar selectedIndex:0];
    self.actionBar = actionBar;
    actionBar.backgroundColor = [UIColor clearColor];
//    [actionBar release];
    actionBar.clipsToBounds = YES;
    
    actionBar_.delegate = self;
    actionBar_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:actionBar_];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(personDetailsFlags_.initWithUserId == 1) {
        [self loadPersonAddressBookInfo];
    }else {
        if (personDetailsFlags_.updatedFavoriteState == 0) {
            personDetailsFlags_.updatedFavoriteState = 1;
            
            [self _toggleFavoritedState];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = (recordItems_ != nil) ? [recordItems_ count] : 0;
    NSInteger sections = (count > 0) ? [recordItems_ count] / 3 : 0;
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == selectedSection) return 2;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor clearColor];
    
    return header;// autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor clearColor];
    
    return footer ;//autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!(selectedSection == indexPath.section && indexPath.row == 1)) {
        static NSString *CellIdentifier = @"Cell";
        
        KDABPersonRecordCell *cell = (KDABPersonRecordCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[KDABPersonRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
          //  cell.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f);
            
            //        if ([KDUIUtils isSupportedPhoneCall]) {
            //            [cell.recordButton addTarget:self action:@selector(_recordButtonFire:) forControlEvents:UIControlEventTouchUpInside];
            //        }
            cell.indicatorButton.userInteractionEnabled = NO;
        }
        
        NSInteger section = indexPath.section;
        
        NSInteger idx = section * 3;
        NSString *subject = recordItems_[idx];
        NSString *value = recordItems_[idx + 1];
        NSNumber *enabled = recordItems_[idx + 2];
        
        [cell update:subject value:value enabled:[enabled boolValue]];
        if([subject isEqualToString:NSLocalizedString(@"AB_RECORD_MOBILE", nil)] && value.length > 0) {
            cell.indicatorButton.hidden = NO;
        }else {
            cell.indicatorButton.hidden = YES;
        }
        
        if(indexPath.section == selectedSection) {
            [cell setIndicatorButtonExpand:YES];
        }else {
            [cell setIndicatorButtonExpand:NO];
        }
        
        if([subject isEqualToString:NSLocalizedString(@"AB_RECORD_MOBILE", nil)]) {
            cell.recordButton.userInteractionEnabled = NO;
        }else {
            if([KDUIUtils isSupportedPhoneCall]) {
                [cell.recordButton addTarget:self action:@selector(_recordButtonFire:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        return cell;
    }else {
        return [self actionCell];
    }
}

- (KDABPersonActionCell *)actionCell {
    KDABPersonActionCell *cell = [[KDABPersonActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];// autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   // cell.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f);
    
    NSInvocation *call = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(actionMenuCall)]];
    call.target = self;
    call.selector = @selector(actionMenuCall);
    
    NSInvocation *sms = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(actionMenuSMS)]];
    sms.target = self;
    sms.selector = @selector(actionMenuSMS);
    
    cell.titles = @[ASLocalizedString(@"KDABPersonDetailsViewController_tips_1"), ASLocalizedString(@"KDABPersonDetailsViewController_tips_2")];
    cell.images = @[[UIImage imageNamed:@"user_profile_message_icon_v3.png"], [UIImage imageNamed:@"user_profile_phone_icon_v3.png"]];
    cell.invocations = @[sms, call];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectedSection != NSNotFound && indexPath.section == selectedSection && indexPath.row == 1) return;
    
    KDABPersonRecordCell *cell = (KDABPersonRecordCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.indicatorButton.hidden) {
        return;
    }
    
    UITableViewRowAnimation animation = UITableViewRowAnimationAutomatic;
    NSIndexPath *deleteIndexPath = nil;
    NSIndexPath *insertIndexPath = nil;
    
    
    if(selectedSection == NSNotFound) {
        insertIndexPath = [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
        [cell setIndicatorButtonExpand:YES];
        selectedSection = indexPath.section;
    }else {
        if(selectedSection == indexPath.section) {
            deleteIndexPath = [NSIndexPath indexPathForRow:1 inSection:selectedSection];
            [cell setIndicatorButtonExpand:NO];
            selectedSection = NSNotFound;
        }else {
            insertIndexPath = [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
            deleteIndexPath = [NSIndexPath indexPathForRow:1 inSection:selectedSection];
            
            [cell setIndicatorButtonExpand:YES];
            
            KDABPersonRecordCell *oldCell = (KDABPersonRecordCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedSection]];
            [oldCell setIndicatorButtonExpand:NO];
            
            selectedSection = indexPath.section;
        }
    }
    
    [CATransaction begin];
    [self.tableView beginUpdates];
//    [CATransaction setAnimationDuration:0.4];
    if(insertIndexPath) {
        [self.tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:animation];
    }
    
    if(deleteIndexPath) {
        [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:animation];
    }
    [self.tableView endUpdates];
    [CATransaction commit];

    
//    if(insertIndexPath) {
//    //setup temporary cell
//        KDABPersonActionCell *fromCell = [[KDABPersonActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        fromCell.backgroundColor = RGBCOLOR(237, 237, 237);
//        fromCell.frame = CGRectMake(0, 0, 320 - 16.0f, 50.0f);
//        
//        //setup cell to animate to
//        KDABPersonActionCell *toCell = (KDABPersonActionCell *)[self.tableView cellForRowAtIndexPath:insertIndexPath];
//        
//        
//        [MPFoldTransition transitionFromView:fromCell
//                                      toView:toCell
//                                    duration:0.25
//                                       style:MPFoldStyleUnfold
//                            transitionAction:MPTransitionActionNone
//                                  completion:^(BOOL finished) {
//                                      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedSection] withRowAnimation:UITableViewRowAnimationNone];
//                                  }];
//    }
//    
//    
//    if(deleteIndexPath) {
//        KDABPersonActionCell *toCell = [[KDABPersonActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        toCell.backgroundColor = RGBCOLOR(237, 237, 237);
//        toCell.frame = CGRectMake(0, 0, 320, 0);
//        //setup cell to animate to
//        KDABPersonActionCell *fromCell = (KDABPersonActionCell *)[self.tableView cellForRowAtIndexPath:deleteIndexPath];
//        
//        [MPFoldTransition transitionFromView:fromCell
//                                      toView:toCell
//                                    duration:0.4
//                                       style:MPFoldStyleDefault
//                            transitionAction:MPTransitionActionNone
//                                  completion:^(BOOL finished) {
//
//                                  }];
//
//    }
}

- (void)actionMenuCall {
    if(selectedSection != NSNotFound) {
        KDABPersonRecordCell *cell = (KDABPersonRecordCell *)[tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedSection]];
        if(cell.recordButton)
            [self _recordButtonFire:cell.recordButton];
    }
}

- (void)actionMenuSMS {
    if(selectedSection != NSNotFound) {
        KDABPersonRecordCell *cell = (KDABPersonRecordCell *)[tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedSection]];
        if(cell.recordButton) {
            NSString *phoneNumber = [cell.recordButton titleForState:UIControlStateNormal];
            [actionHelper_ shareViaMessageCompose:phoneNumber body:nil sharingContact:NO];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDABActionTabBar delegate methods

- (void)actionTabBar:(KDABActionTabBar *)actionTabBar didSelectAtIndex:(NSInteger)index {
    if (0x00 == index) {
        // favorite / unfavorite
        [self _changeFavoritedABPersonRequest:!person_.favorited];
    
    } else if (0x01 == index) {
        // save to local
        [actionHelper_ addToLocalAddressBookStore];
        
    } else if (0x02 == index) {
        [actionHelper_ shareViaMessageCompose:nil body:[person_ formatAsMessageBody] sharingContact:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)_didTapProfileImage:(UIButton *)sender {
    // show profile image
    NSString *url = [person_ getAvatarLoadURL];
    MJPhoto *photo = [[MJPhoto alloc] init];//;// autorelease];
    photo.url = [NSURL URLWithString:url];
    photo.placeholder = [[SDWebImageManager sharedManager] diskImageForURL:[NSURL URLWithString:url]];
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];// autorelease];
    browser.currentPhotoIndex = 0;
    browser.photos = [NSArray arrayWithObject:photo];
    [browser show];

}

- (void)_recordButtonFire:(UIButton *)btn {
    NSString *phoneNumber = [btn titleForState:UIControlStateNormal];
//    [actionHelper_ phoneCallOutToRecipient:phoneNumber];
    [actionHelper_ performSelector:@selector(phoneCallOutToRecipient:) withObject:phoneNumber afterDelay:0.01f];
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

- (void)_sendDM:(UIButton *)sender {
    [actionHelper_ sendDM];
}

- (void)_sendSMS:(UIButton *)sender {
    if ([person_ hasMobileNumbers]) {
        [actionHelper_ sendSMS];
    }
}

- (void)_appendRecordItems:(NSString *)subject source:(NSArray *)source isPhoneNumber:(BOOL)isPhoneNumber {
    if (source != nil && [source count] > 0) {
        for (NSString *item in source) {
            [recordItems_ addObject:subject];
            [recordItems_ addObject:item];
            [recordItems_ addObject:[NSNumber numberWithBool:isPhoneNumber]];
        }
    
    } else {
        // at least item as placeholder
        [recordItems_ addObject:subject];
        [recordItems_ addObject:@""];
        [recordItems_ addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)_buildContactRecordItems {
//    if (person_ == nil) return;
    
    if (recordItems_ == nil) {
        recordItems_ = [[NSMutableArray alloc] init];
    
    } else {
        // clear
        [recordItems_ removeAllObjects];
    }
    
    // mobiles
    [self _appendRecordItems:NSLocalizedString(@"AB_RECORD_MOBILE", @"") source:person_.mobiles isPhoneNumber:YES];
    
    // phones
    [self _appendRecordItems:NSLocalizedString(@"AB_RECORD_PHONE", @"") source:person_.phones isPhoneNumber:YES];
    
    // emails
    [self _appendRecordItems:NSLocalizedString(@"AB_RECORD_EMAIL", @"") source:person_.emails isPhoneNumber:NO];
}

- (void)_toggleFavoritedState {
    UIButton *btn = [actionBar_ actionBarButtonAtIndex:0x00];
    if (btn != nil) {
        UIImage *image = [UIImage imageNamed:(person_.favorited ? @"ab_person_favorited_v3.png" : @"ab_person_unfavorited_v3.png")];
        NSString *title = person_.favorited ? ASLocalizedString(@"KDABPersonDetailsViewController_tips_3"): ASLocalizedString(@"KDABPersonDetailsViewController_tips_4");
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateNormal];
    }
}

- (void)_didChangeFavoritedState {
    // change the image of button about toogle favorite/unfavorite state
    [self _toggleFavoritedState];
    
    // update the favorited state for all cached ABPerson type
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDABPersonDAO> personDAO = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
        [personDAO updateABPersonFavoritedState:person_ database:fmdb];
        
        return nil;
        
    } completionBlock:nil];
    
    if (person_.favorited) {
        // no matter what's the type of person, save to temporary variable before save it
        KDABPersonType temp = person_.type;
        person_.type = KDABPersonTypeFavorited;
        
        // save ab persons
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDABPersonDAO> personDAO = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
            BOOL *rollback = NO; // ignore this value at now
            [personDAO saveABPersons:@[person_] type:KDABPersonTypeFavorited clear:NO database:fmdb rollback:rollback];
            
            return nil;
            
        } completionBlock:^(id results){
            person_.type = temp;
        }];
        
    } else {
        // remove the item from favorited table
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDABPersonDAO> personDAO = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
            BOOL success = [personDAO removeABPerson:person_ type:KDABPersonTypeFavorited database:fmdb];
            
            return @(success);
            
        } completionBlock:nil];
    }
    
    // TODO: notify the previous view controller
}

- (void)_changeFavoritedABPersonRequest:(BOOL)favorited {
    if (personDetailsFlags_.hasFavoritedRequests == 1) return;
    personDetailsFlags_.hasFavoritedRequests = 1;
    
    KDQuery *query = [KDQuery queryWithName:@"addressBookId" value:person_.pId];
    
    __block KDABPersonDetailsViewController *pdvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results != nil) {
            if ([(NSNumber *)results boolValue]) {
                pdvc.person.favorited = favorited;
                [pdvc _didChangeFavoritedState];
                
            } else {
                NSString *message = favorited ? NSLocalizedString(@"AB_FAVORITE_CONTACT_DID_FAIL", @"")
                                              : NSLocalizedString(@"AB_UNFAVORITE_CONTACT_DID_FAIL", @"");
                
                [pdvc.actionHelper showNotificationMessage:message];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:pdvc.view.window];
            }
        }
        
        (pdvc -> personDetailsFlags_).hasFavoritedRequests = 0;
        
        // release current view controller
//        [pdvc release];
    };
    
    NSString *actionPath = favorited ? @"/ab/:favorite" : @"/ab/:unfavorite";
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)loadPersonAddressBookInfo
{
    if(self.person) return;
    
    __block KDABPersonDetailsViewController *pdvc = self;// retain];
    
    KDQuery *query = [KDQuery queryWithName:@"userId" value:userId_];
    [query setProperty:userId_ forKey:@"userId"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if(results != nil) {
            NSArray *persons = (NSArray *)results;
            
            if(persons.count > 0) {
                KDABPerson *person = [persons objectAtIndex:0];
                pdvc.person = person;
            
                [pdvc _toggleFavoritedState];
                
                [pdvc.tableView reloadData];
            }
        }else {
            [self _buildContactRecordItems];
            [pdvc.tableView reloadData];
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:pdvc.view.window];
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/ab/:personByUserId"
                                       query:query configBlock:nil completionBlock:completionBlock];
}

///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark setter methods

- (void)setPerson:(KDABPerson *)person {
    if (person_ != person) {
//        [person_ release];
        person_ = person;// retain];
    
        actionHelper_.pickedPerson = person_;
        
        [self _buildContactRecordItems];
        
    }
}

- (void)setUserId:(NSString *)userId
{
    if(userId_ != userId) {
//        [userId_ release];
        userId_ = [userId copy];
        
        personDetailsFlags_.initWithUserId = 1;
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
    

    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(actionBar_);
    //KD_RELEASE_SAFELY(activityView_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(person_);
    //KD_RELEASE_SAFELY(actionHelper_);
    //KD_RELEASE_SAFELY(recordItems_);
    

    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(actionBar_);
    //KD_RELEASE_SAFELY(activityView_);
    
    //[super dealloc];
}

@end
