//
//  KDInvitePhoneContactsViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDInvitePhoneContactsViewController.h"
#import "KDABHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "KDPhoneContactCell.h"
#import "KDABRecord.h"
#import "KDWeiboServicesContext.h"
#import "KDWeiboServices.h"
#import "KDManagerContext.h"
#import "pinyin.h"
#import "UIView+Blur.h"
#import "KDAccountTipView.h"
#import "KDSearchBar.h"
#import "KDMaskView.h"
#import "pinyin.h"
#import "MBProgressHUD.h"
#import "KDErrorDisplayView.h"
#import "XTOpenSystemClient.h"
#import "XTAddressBookModel.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "BOSPublicConfig.h"
#import "XTOpenSystemClient.h"
#import "XTOpenConfig.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "MBProgressHUD.h"
#import "XTInitializationManager.h"

#define kNAMEFONTSIZE  15.0f

@interface KDInvitePhoneContactsViewController () <UITableViewDataSource, UITableViewDelegate, KDSearchBarDelegate, KDMaskViewDelegate, UIAlertViewDelegate>
{
    UITableView *allContactsTableView_;
    UITableView *didSelectTableView_;
    UIButton    *inviteButton_;
    UIView      *toolView_;
    KDSearchBar *searchBar_;
    
    UIView      *noPermissionTipsView_;
    
    NSMutableArray *allPhoneContacts_;
    NSMutableArray *allSelectedContacts_;
    NSMutableArray *searchResults_;
    
    NSMutableArray *alreadyInvitedContacts_;
    
    BOOL        isShowSearchResult_;
    
    KDMaskView *maskView_; //weak
}

@property (nonatomic, retain) UITableView *allContactsTableView;
@property (nonatomic, retain) UITableView *didSelectTableView;
@property (nonatomic, retain) UIButton    *inviteButton;
@property (nonatomic, retain) UIView      *toolView;
@property (nonatomic, retain) KDSearchBar *searchBar;
@property (nonatomic, retain) XTOpenSystemClient *openClient;

@end

@implementation KDInvitePhoneContactsViewController

@synthesize allContactsTableView = allContactsTableView_;
@synthesize didSelectTableView = didSelectTableView_;
@synthesize inviteButton = inviteButton_;
@synthesize toolView = toolView_;
@synthesize searchBar = searchBar_;
@synthesize invitePeople = invitePeople_;
@synthesize isNeedFilter = isNeedFilter_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = ASLocalizedString(@"KDInvitePhoneContactsViewController_invite_contact");
        
        allPhoneContacts_ = [[NSMutableArray alloc] initWithCapacity:5];
        allSelectedContacts_ = [[NSMutableArray alloc] initWithCapacity:5];
        searchResults_ = [[NSMutableArray alloc] initWithCapacity:5];
        isShowSearchResult_ = NO;
        isNeedFilter_ = NO;
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_invitedUrl);
    //KD_RELEASE_SAFELY(_openClient);
    //KD_RELEASE_SAFELY(allPhoneContacts_);
    //KD_RELEASE_SAFELY(allSelectedContacts_);
    //KD_RELEASE_SAFELY(alreadyInvitedContacts_);
    //KD_RELEASE_SAFELY(searchResults_);
    
    //KD_RELEASE_SAFELY(allContactsTableView_);
    //KD_RELEASE_SAFELY(didSelectTableView_);
    //KD_RELEASE_SAFELY(inviteButton_);
    //KD_RELEASE_SAFELY(toolView_);
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(invitePeople_);
    //KD_RELEASE_SAFELY(noPermissionTipsView_);
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor kdBackgroundColor3];
	// Do any additional setup after loading the view.
    self.searchBar = [[KDSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 50.0f)];// autorelease];
    searchBar_.delegate = self;
    searchBar_.showsCancelButton = NO;
    [self.view addSubview:searchBar_];
    
    //8.0f for toolview's shadow
    self.allContactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.searchBar.frame) - 64.0f) style:UITableViewStylePlain];// autorelease];
    allContactsTableView_.backgroundColor = [UIColor kdBackgroundColor3];
    allContactsTableView_.backgroundView = nil;
    allContactsTableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    allContactsTableView_.delegate = self;
    allContactsTableView_.dataSource = self;
//    allContactsTableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.allContactsTableView];
    allContactsTableView_.contentInset = UIEdgeInsetsMake(0, 0, 58.0f, 0);
    
    //tool view
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - 58.0f, CGRectGetWidth(self.view.frame), 58.0f)] ;//autorelease];
    toolView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    toolView_.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolView_];
    [toolView_ renderLayerWithView:self.view];
    
    //add back ground view to tool view
    UIImage *bgImage = [UIImage imageNamed:@"phone_contact_tool_bar_bg_v3"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.45f topCapHeight:bgImage.size.height * 0.45f];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.frame = self.toolView.bounds;
    [self.toolView addSubview:bgImageView];
    
    //selected table view
    UITableView *selected = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    selected.transform = CGAffineTransformMakeRotation(-M_PI_2);
    selected.delegate = self;
    selected.dataSource = self;
    selected.backgroundView = nil;
    selected.backgroundColor = [UIColor clearColor];
    selected.separatorStyle = UITableViewCellSeparatorStyleNone;
    selected.showsVerticalScrollIndicator = NO;
    selected.showsHorizontalScrollIndicator = NO;
    self.didSelectTableView = selected;// autorelease];
    didSelectTableView_.frame = CGRectMake(10.0f, 15.0f, CGRectGetWidth(toolView_.frame) - 100.0f, 30.0f);
    [self.toolView addSubview:self.didSelectTableView];
    
    //invite button
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteButton_.frame = CGRectMake(CGRectGetWidth(toolView_.frame) - 15.0f - 65.0f, 15.0f, 65.0f, 30.0f);
    [inviteButton_ addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
    inviteButton_.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [inviteButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    inviteButton_.backgroundColor = RGBCOLOR(23, 131, 253);
    inviteButton_.layer.cornerRadius = 5.0f;
    inviteButton_.layer.masksToBounds = YES;
    
    [self.toolView addSubview:self.inviteButton];
    
    [self updateInviteButtonTitle];
    
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn addTarget:self action:@selector(togAll:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [confirmBtn setTitle:ASLocalizedString(@"KDInvitePhoneContactsViewController_select_all")forState:UIControlStateNormal];
    [confirmBtn sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:confirmBtn];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil] ;//autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];
    
//    [rightItem release];

}
- (void)togAll:(id)sender
{
    int count = (int)allSelectedContacts_.count;
    
    if (isShowSearchResult_) {
        [allSelectedContacts_ removeAllObjects];
        if (count!= searchResults_.count)
            [allSelectedContacts_ addObjectsFromArray:searchResults_];
    }
    else
    {
        [allSelectedContacts_ removeAllObjects];
        if (count != allPhoneContacts_.count)
            [allSelectedContacts_ addObjectsFromArray:allPhoneContacts_];
    }
    
    [allContactsTableView_ reloadData];
    [didSelectTableView_ reloadData];
    
    [self updateInviteButtonTitle];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if([KDABHelper hasContactPermission]) {
//        if(isNeedFilter_) {
//            [self fetchAlreadyInvitedPhoneNumber];
//        }else {
//            [self fetchLocalPhoneContacts];
//        }
//    }else {
//        [self setNoPermissionTipsViewVisible:YES];
//    }
}

- (void)setNoPermissionTipsViewVisible:(BOOL)visible
{
    if(visible) {
        if(!noPermissionTipsView_) {
            noPermissionTipsView_ = [[UIView alloc] initWithFrame:self.view.bounds];
            noPermissionTipsView_.backgroundColor = RGBCOLOR(237, 237, 237);
            noPermissionTipsView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 53.0f, CGRectGetWidth(noPermissionTipsView_.frame), 15.0f)];
            title.font = [UIFont boldSystemFontOfSize:16.0f];
            title.textColor = [UIColor blackColor];
            title.text = [NSString stringWithFormat:ASLocalizedString(@"KDInvitePhoneContactsViewController_no_perm"),KD_APPNAME];
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = [UIColor clearColor];
            
            [noPermissionTipsView_ addSubview:title];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(title.frame) + 20.0f, CGRectGetWidth(noPermissionTipsView_.frame), 38.0f)];
            message.font = [UIFont systemFontOfSize:15.0f];
            message.textColor = MESSAGE_NAME_COLOR;
            message.backgroundColor = [UIColor clearColor];
            message.textAlignment = NSTextAlignmentCenter;
            message.text = [NSString stringWithFormat:ASLocalizedString(@"KDInvitePhoneContactsViewController_tips_1"),KD_APPNAME];
            message.numberOfLines = 0;
            
            [noPermissionTipsView_ addSubview:message];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"team_contact_permission_v3.png"]];
            [imageView sizeToFit];
            imageView.frame = CGRectMake((CGRectGetWidth(noPermissionTipsView_.frame) - CGRectGetWidth(imageView.frame)) * 0.5f, CGRectGetMaxY(message.frame) + 25.0f, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
            [noPermissionTipsView_ addSubview:imageView];
        }
        
        [self.view addSubview:noPermissionTipsView_];
    }else {
        if(noPermissionTipsView_) {
            [noPermissionTipsView_ removeFromSuperview];
        }
    }
}

- (void)fetchLocalPhoneContacts
{
    [self showProgressViewWithMessage:ASLocalizedString(@"KDInvitePhoneContactsViewController_get_local_addressbook")];
    NSArray *allPhoneContacts = [KDABHelper allPhoneContacts];
    
    for(KDABRecord *record in allPhoneContacts) {
        if(record.phoneNumber.length > 0 && record.name.length > 0) {
            if(isNeedFilter_ && alreadyInvitedContacts_ && alreadyInvitedContacts_.count > 0) {
                BOOL exist = NO;
                
                for(KDABRecord *r in alreadyInvitedContacts_) {
                    if([r.phoneNumber isEqualToString:record.phoneNumber]) {
                        r.name = record.name;
                        exist = YES;
                        break;
                    }
                }
                
                if(!exist) {
                    [allPhoneContacts_ addObject:record];
                }
            }else {
                [allPhoneContacts_ addObject:record];
            }
        }
    }
    
    [self sortPhoneContacts:allPhoneContacts_];
    
    //去掉获取的通讯录里没名字的
    NSUInteger index = 0;
    while (index < alreadyInvitedContacts_.count) {
        KDABRecord *record = [alreadyInvitedContacts_ objectAtIndex:index];
        if(record.name.length > 0) {
            index++;
        }else {
            [alreadyInvitedContacts_ removeObjectAtIndex:index];
        }
    }
    
    [self sortPhoneContacts:alreadyInvitedContacts_];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [self.allContactsTableView reloadData];
}

- (void)filterLocalPhoneContactsIn:(NSArray *)records
{
    NSUInteger index = 0;
    
    while (index < allPhoneContacts_.count) {
        KDABRecord *record = [allPhoneContacts_ objectAtIndex:index];
        
        BOOL exist = NO;
        
        for(KDABRecord *r in records) {
            if([record.phoneNumber isEqualToString:r.phoneNumber]) {
                r.name = record.name;
                exist = YES;
                break;
            }
        }
        
        if(exist) {
            [allPhoneContacts_ removeObjectAtIndex:index];
        }else {
            index++;
        }
    }
}

- (void)sortPhoneContacts:(NSMutableArray *)contacts
{
    [contacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        KDABRecord *r1 = (KDABRecord *)obj1;
        KDABRecord *r2 = (KDABRecord *)obj2;
        
        NSUInteger len1 = r1.name.length;
        NSUInteger len2 = r2.name.length;
        
        NSComparisonResult result = NSOrderedSame;
        
        NSUInteger len = MIN(len1, len2);
        
        for(NSUInteger index = 0; index < len; index++) {
            char c1 = pinyinFirstLetter([r1.name characterAtIndex:index]);
            char c2 = pinyinFirstLetter([r2.name characterAtIndex:index]);
            
            //转换为小写
            c1 |= 0x20;
            c2 |= 0x20;
            
            if(c1 > c2) {
                result = NSOrderedDescending;
            }else if(c1 < c2) {
                result = NSOrderedAscending;
            }
            
            if(result != NSOrderedSame) {
                break;
            }
        }
        
        if(result == NSOrderedSame) {
            if(len1 < len2) {
                result = NSOrderedAscending;
            }else if(len1 > len2) {
                result = NSOrderedDescending;
            }
        }
        
        return result;
    }];
}

- (void)fetchAlreadyInvitedPhoneNumber
{
    KDQuery *query = [KDQuery query];
    [query setParameter:@"page" intValue:-1];
    
    __block KDInvitePhoneContactsViewController *ipcvc = self ;//retain];
    [ipcvc showProgressViewWithMessage:ASLocalizedString(@"KDInvitePhoneContactsViewController_get_invite_msg")];
    KDServiceActionDidCompleteBlock block = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if([response isValidResponse]) {
            if(results) {
                if(!ipcvc->alreadyInvitedContacts_) {
                    ipcvc->alreadyInvitedContacts_ = [[NSMutableArray alloc] initWithCapacity:2];
                }
                
                NSArray *invitedRecords = (NSArray *)results;
                if(invitedRecords.count > 0) {
                    [ipcvc->alreadyInvitedContacts_ addObjectsFromArray:invitedRecords];
                }
            }
            
            [ipcvc fetchLocalPhoneContacts];
        }else {
            [ipcvc hideHUD];
            if(![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:ipcvc.view];
                [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
            }
        }
        
//        [ipcvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/users/:alreadyInvitedPerson"
                                       query:query
                                 configBlock:nil
                             completionBlock:block];
}

- (void)showProgressViewWithMessage:(NSString *)msg
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if(!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    hud.labelText = msg;
}

- (void)hideHUD
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInvitePeople:(NSMutableArray *)invitePeople
{
    if(invitePeople != invitePeople_) {
//        [invitePeople_ release];
        invitePeople_ = invitePeople;// retain];
        
        [allSelectedContacts_ addObjectsFromArray:invitePeople_];
    }
}

- (NSString *)teamMemberString
{
    if(allSelectedContacts_.count == 0) return nil;
    
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:2];
    
    for(KDABRecord *record in allSelectedContacts_) {
        [result appendString:record.phoneNumber];
        [result appendString:@","];
    }
    
    if([result hasSuffix:@","]) {
        [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
    }
    
    return result;// autorelease];
}

#pragma mark - Network Methods
- (void)invitePhoneContact
{
    if ([allSelectedContacts_ count] == 0)
    {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableArray *perons = [[NSMutableArray alloc] init] ;//autorelease];
    for (KDABRecord *record in allSelectedContacts_)
    {
        @autoreleasepool {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:record.phoneNumber forKey:@"phone"];
            [dict setObject:record.name forKey:@"name"];
            [perons addObject:dict];
        }
        
    }
    


    
    if (!self.openClient)
    {
        _openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(inviteDidReceived:result:)];
    }
    [self.openClient inviteWithEId:[BOSSetting sharedSetting].cust3gNo
                             eName:[BOSSetting sharedSetting].customerName
                           persons:perons
                              name:[BOSConfig sharedConfig].user.name
                               URL:_invitedUrl
     ];
}

- (void)inviteDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel*)result
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (client.hasError)
    {
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (result.success)
    {
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = ASLocalizedString(@"邀请成功");
        [hud hide:YES afterDelay:1.0];
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
        
        [[XTInitializationManager sharedInitializationManager] startInitializeCompletionBlock:nil failedBlock:nil];
        
        [KDEventAnalysis event:event_invite_send attributes:@{ label_invite_send_inviteType : label_invite_send_inviteType_contact }];
        
        return;
    }
    
    [hud hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
}

- (void)hide
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - Private Methods
- (void)invite:(id)sender
{
    //if invitePeople_ is not nil, means it is from create-team view or pre-invite-phone-contact view.
    //if invitePeople_ is nil, means from left-nav-view to invite some people to current team, and should request network method.
    if(invitePeople_) {
        [invitePeople_ removeAllObjects];
        [invitePeople_ addObjectsFromArray:allSelectedContacts_];
        
        [self.navigationController popViewControllerAnimated:YES];
    }else if(allSelectedContacts_.count > 0) {
        [self invitePhoneContact];
    }
}


- (BOOL)isPersonPicked:(KDABRecord *)person
{
    return [allSelectedContacts_ containsObject:person];
}

- (void)updateInviteButtonTitle
{
    NSString *title = ASLocalizedString(@"KDInviteByPhoneNumberViewController_invite");
    if(allSelectedContacts_.count > 0) {
        title = [NSString stringWithFormat:@"%@(%@)", title, allSelectedContacts_.count > 99 ? @"99+" : [NSString stringWithFormat:@"%lu", (unsigned long)allSelectedContacts_.count]];
//        inviteButton_.enabled = YES;
    }else {
//        inviteButton_.enabled = NO;
    }
    
    [inviteButton_ setTitle:title forState:UIControlStateNormal];
}

- (void)addPersonToSelected:(KDABRecord *)person
{
    [allSelectedContacts_ addObject:person];
    [self updateInviteButtonTitle];
    
    [didSelectTableView_ beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:allSelectedContacts_.count - 1 inSection:0];
    [didSelectTableView_ insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [didSelectTableView_ endUpdates];
    [self scrollSelectedViewToBottom];
}

- (void)scrollSelectedViewToBottom
{
    [didSelectTableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:allSelectedContacts_.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)removePersonFromSelected:(KDABRecord *)person
{
    NSInteger index = [allSelectedContacts_ indexOfObject:person];
    
    if(index != NSNotFound) {
        [allSelectedContacts_ removeObject:person];
        [self updateInviteButtonTitle];
        
        [didSelectTableView_ beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [didSelectTableView_ deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [didSelectTableView_ endUpdates];
        
        [self.allContactsTableView reloadData];
    }
}

- (void)searchWithKey:(NSString *)key
{
    [searchResults_ removeAllObjects];
    for(KDABRecord *record in allPhoneContacts_) {
        if((record.name && record.name.length > 0 && [record.name rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) || (record.phoneNumber && record.phoneNumber.length > 0 && [record.phoneNumber rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound)) {
            [searchResults_ addObject:record];
        }
    }
    
    isShowSearchResult_ = YES;
    [self.allContactsTableView reloadData];
    [allContactsTableView_ reloadData];
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.allContactsTableView && isNeedFilter_ && alreadyInvitedContacts_.count > 0) {
        return 2;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return 0;
    }else {
        return 25.0f;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 25.0f)] ;//autorelease];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, CGRectGetWidth(tableView.frame) - 15.f, 25.0f)];
    label.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_invite_record");
    label.font = [UIFont systemFontOfSize:13.f];
    label.textColor = MESSAGE_NAME_COLOR;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
//    [label release];
    [view addBorderAtPosition:KDBorderPositionBottom];
    view.backgroundColor = RGBCOLOR(237, 237, 237);
    
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.allContactsTableView ==  tableView) {
        return 60.0f;
    }else if(self.didSelectTableView == tableView) {
        KDABRecord *person = [allSelectedContacts_ objectAtIndex:indexPath.row];
        CGSize size = [person.name sizeWithFont:[UIFont systemFontOfSize:kNAMEFONTSIZE]];
        
        return size.width + 30.0f;
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.allContactsTableView ==  tableView) {
        return 60.0f;
    }else if(self.didSelectTableView == tableView) {
        KDABRecord *person = [allSelectedContacts_ objectAtIndex:indexPath.row];
        CGSize size = [person.name sizeWithFont:[UIFont systemFontOfSize:kNAMEFONTSIZE]];
        
        return size.width + 30.0f;
    }
    
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.allContactsTableView ==  tableView) {
        if(section == 0) {
            if(isShowSearchResult_) {
                return searchResults_.count;
            }else {
                return allPhoneContacts_.count;
            }
        }else if(section == 1) {
            return alreadyInvitedContacts_.count;
        }
    }else if(self.didSelectTableView == tableView) {
        return allSelectedContacts_.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.didSelectTableView == tableView) {
        //这是一段比较神奇的代码，慎入revise by weihao_xu,对tableview做180度旋转，对cell作180度旋转
        
        static NSString *didSelectCellIdentifier = @"did_select_cell_identifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:didSelectCellIdentifier];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:didSelectCellIdentifier] ;//autorelease];
            CGRect rect = CGRectMake(5.f, 5.f, CGRectGetWidth(cell.contentView.frame) - 10.f, CGRectGetHeight(cell.contentView
                                                                                                               .frame) - 10.f);
            UIView *backgroundView = [[UIView alloc]initWithFrame:rect];
            backgroundView.backgroundColor = [UIColor clearColor];
            backgroundView.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
            backgroundView.layer.borderWidth = 1.0f;
            backgroundView.tag = 0x05;
            backgroundView.layer.cornerRadius = 5.0f;
            backgroundView.layer.masksToBounds = YES;
            [cell addSubview:backgroundView];
         
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:kNAMEFONTSIZE];
            cell.transform = CGAffineTransformMakeRotation(M_PI_2);
            
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = nil;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            cell.contentView.layer.masksToBounds = YES;
            cell.layer.masksToBounds = YES;
        }

        KDABRecord *record = [allSelectedContacts_ objectAtIndex:indexPath.row];
        cell.textLabel.text = record.name;
        
        return cell;
    }else {
        if(indexPath.section == 0) {
            static NSString *cellIdentifier = @"identifier";
            KDPhoneContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(!cell) {
                cell = [[KDPhoneContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];// autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameLabel.font = [UIFont systemFontOfSize:kNAMEFONTSIZE + 2.0f];
                cell.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
                cell.backgroundColor = RGBCOLOR(250, 250, 250);
                
                [cell setShowStateLabel:NO];
            }
            
            KDABRecord *person;
            if(isShowSearchResult_) {
                person = [searchResults_ objectAtIndex:indexPath.row];
            }else {
                person = [allPhoneContacts_ objectAtIndex:indexPath.row];
            }
            
            cell.nameLabel.text = person.name;
            
            cell.picked = [self isPersonPicked:person];
            
            return cell;
        } else if(indexPath.section == 1) {
            static NSString *identifier = @"cell-identifier";
            KDPhoneContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell) {
                cell = [[KDPhoneContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];// autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameLabel.font = [UIFont systemFontOfSize:kNAMEFONTSIZE + 2.0f];
                cell.stateLabel.font = [UIFont systemFontOfSize:kNAMEFONTSIZE + 2.0f];
                cell.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
                cell.backgroundColor = RGBCOLOR(250, 250, 250);
                
                [cell setShowStateLabel:YES];
            }
            
            KDABRecord *person = [alreadyInvitedContacts_ objectAtIndex:indexPath.row];
            
            cell.nameLabel.text = person.name;
            if(person.state == KDABRecordState_Actived || person.state == KDABRecordState_Joined) {
                if(person.state == KDABRecordState_Actived) {
                    cell.stateLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_active");
                }else if(person.state == KDABRecordState_Joined) {
                    cell.stateLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_already_in");
                }
                
                cell.stateLabel.textColor = RGBCOLOR(23, 131, 253);
            }else {
                cell.stateLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_un_active");
                cell.stateLabel.textColor = MESSAGE_NAME_COLOR;
            }
            
            return cell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.didSelectTableView == tableView) {
        //由于backgroudview在return cell;之后不会自动适配，需自应用适配，由于cell作了旋转，下面设置的高和宽长度调转。
        UIView *backgroundView = [cell viewWithTag:0x05];
        backgroundView.frame = CGRectMake(5.f, 0.f,CGRectGetHeight(cell.frame) -10.f , CGRectGetWidth(cell.frame)  );
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) return;
    
    if(self.didSelectTableView == tableView) {
        [self removePersonFromSelected:[allSelectedContacts_ objectAtIndex:indexPath.row]];
    }else {
        KDABRecord *record = nil;
        if(isShowSearchResult_) {
            record = [searchResults_ objectAtIndex:indexPath.row];
        }else {
            record = [allPhoneContacts_ objectAtIndex:indexPath.row];
        }
        
        KDPhoneContactCell *cell = (KDPhoneContactCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.picked = !cell.picked;
        
        if(record) {
            if([allSelectedContacts_ containsObject:record]) {
                [self removePersonFromSelected:record];
            }else {
                [self addPersonToSelected:record];
            }
        }
    }
}

#pragma mark - KDMaskViewDelegate Methods
- (void)maskView:(KDMaskView *)maskView touchedInLocation:(CGPoint)location {
    [self.searchBar resignFirstResponder];
}

#pragma mark - KDSearchBar aid method
- (void)addMaskView {
    if(!maskView_) {
        maskView_ = [[KDMaskView alloc] initWithFrame:CGRectZero];
        maskView_.delegate = self;
        [self.view addSubview:maskView_];
//        [maskView_ release];
    }
    
    maskView_.frame = self.allContactsTableView.frame;
}

- (void)removeMaskView {
    if(maskView_) {
        if(maskView_.superview) {
            [maskView_ removeFromSuperview];
        }
        maskView_ = nil;
    }
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KDSearchBarDelegate Methods
- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar
{
    [self addMaskView];
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar
{
    [self removeMaskView];
}

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length > 0) {
        [self searchWithKey:searchText];
    }else {
        isShowSearchResult_ = NO;
        [self.allContactsTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar
{
    
    if(searchBar.text.length > 0) {
        [searchBar resignFirstResponder];
        [self searchWithKey:searchBar.text];
    }
}

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar
{
    
}

@end
