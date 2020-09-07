//
//  KDTeamPageViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTeamPageViewController.h"
#import "KDCommon.h"
#import "KDWeiboServices.h"
#import "KDWeiboServicesContext.h"
#import "KDTeamCell.h"
#import "KDApplyingTeamCell.h"
#import "KDInviteTeamCell.h"
#import "KDCreateAndJoinTeamCell.h"
#import "KDTeamRequestHelper.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD.h"
#import "KDCreateTeamViewController.h"
#import "KDSearchTeamViewController.h"
#import "KDAccountTipView.h"
#import "KDManagerContext.h"

NSString *const KDTeamInvitationFinishedNotification = @"com.kingdee.www/kd_team_invitation_finished_notification";
NSString *const KDTeamInvitationOnceNotification = @"com.kingdee.www/kd_team_invitation_once_notification";

@interface KDTeamPageViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, KDApplyingTeamCellDelegate, KDInviteTeamCellDelegate, KDCreateAndJoinTeamCellDelegate>
{
    KDTeamPageContentType contentType_;
    
    NSMutableArray *allInvitation_;
    NSMutableArray *allMyTeams_;
    NSMutableArray *allMyApplyingTeams_;
    
    
    BOOL shouldShowBackground_;
}

@property (nonatomic, retain) UITableView *tableView;

@end

NS_INLINE NSInteger sectionLocation(KDTeamPageContentType type, KDTeamPageContentType contentType)
{
    NSInteger sectionLocation = -1;
    
    while (type > 0) {
        sectionLocation += contentType & 0x01;
        type >>= 1;
        contentType >>= 1;
    }
    
    return sectionLocation;
}

@implementation KDTeamPageViewController

@synthesize tableView = tableView_;
@synthesize allInvitation = allInvitation_;
@synthesize allMyApplyingTeams = allMyApplyingTeams_;
@synthesize allMyTeams = allMyTeams_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allMyTeams_ = [[NSMutableArray alloc] init];
        allMyApplyingTeams_ = [[NSMutableArray alloc] init];
        allInvitation_ = [[NSMutableArray alloc] init];
        shouldShowBackground_ = NO;
    }
    return self;
}

- (id)initWithContentType:(KDTeamPageContentType)ct
{
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        contentType_ = ct;
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(tableView_);
    
    //KD_RELEASE_SAFELY(allMyTeams_);
    //KD_RELEASE_SAFELY(allInvitation_);
    //KD_RELEASE_SAFELY(allMyApplyingTeams_);
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tv.delegate = self;
    tv.dataSource = self;
    tv.backgroundColor = [UIColor clearColor];
    tv.backgroundView = nil;
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:tv];
    self.view.backgroundColor = RGBCOLOR(230, 230, 230);
    self.tableView = tv;
//    [tv release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[KDManagerContext globalManagerContext].communityManager joinedCommunities].count > 0 && [[[KDManagerContext globalManagerContext].communityManager currentCommunity] subDomainName].length > 0) {
        self.navigationItem.rightBarButtonItems = nil;
    }else {
        [self setRightItem];
    }
    

    if([[KDManagerContext globalManagerContext].communityManager joinedCommunities].count > 0 && [[[KDManagerContext globalManagerContext].communityManager currentCommunity] subDomainName].length > 0) {
        
        if(contentType_ == KDTeamPageContentType_InviteMe) {
            self.navigationItem.title = ASLocalizedString(@"KDTeamPageViewController_navigationItem_title_noti");
        }else {
            self.navigationItem.title =[NSString stringWithFormat: ASLocalizedString(@"KDTeamPageViewController_navigationItem_title_me"),KD_APPNAME];
        }
        
    }else {
        self.navigationItem.title = ASLocalizedString(@"KDTeamPageViewController_navigationItem_title_company");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if((contentType_ & KDTeamPageContentType_InviteMe) && allInvitation_.count == 0) {
        [self loadTeamInvitation];
    }
    
    if((contentType_ & KDTeamPageContentType_MyApplyingTeams) && allMyApplyingTeams_.count == 0) {
        [self loadMyApplyingTeams];
    }
}

- (void)setRightItem
{
    self.navigationItem.rightBarButtonItems = [KDCommon rightNavigationItemWithTitle:ASLocalizedString(@"KDTeamPageViewController_exit")target:self action:@selector(exit:)];
}

//TODO:导航栏右侧的“退出”按钮
- (void)exit:(id)sender
{
    __block KDTeamPageViewController *weakself = self;// retain];
    
    [[KDWeiboAppDelegate getAppDelegate] checkHasSetPassword:^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if ([response isValidResponse]) {
            if (results) {
                BOOL hasSetPwd = [((NSDictionary *)results) boolForKey:@"hasRestPassword"];
                if (hasSetPwd) {
                    if([weakself.navigationController viewControllers].count > 1) {
                        [weakself.navigationController popViewControllerAnimated:YES];
                    }else {
                        [weakself.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                }else {
                    [weakself showPasswordView];
                }
            }
        }else {
            if([weakself.navigationController viewControllers].count > 1) {
                [weakself.navigationController popViewControllerAnimated:YES];
            }else {
                [weakself.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
//        [weakself release];
    }];
}

- (void)showPasswordView
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NetWork Methods
- (void)loadTeamInvitation
{
    __block KDTeamPageViewController *tpvc = self ;//retain];
    
    [MBProgressHUD showHUDAddedTo:tpvc.view animated:YES];
    
    [[KDTeamRequestHelper sharedTeamRequestHelper] fetchTeamInvitationWithFinishedBlock:^(id results) {
        [MBProgressHUD hideAllHUDsForView:tpvc.view animated:YES];
        [tpvc.allInvitation addObjectsFromArray:(NSArray *)results];
        [tpvc.tableView reloadData];
        
//        [tpvc release];
    }];
}

- (void)loadMyApplyingTeams
{
    __block KDTeamPageViewController *tpvc = self;// retain];
    
    [MBProgressHUD showHUDAddedTo:tpvc.view animated:YES];
    
    [[KDTeamRequestHelper sharedTeamRequestHelper] fetchMyApplyingTeamWithFinishedBlock:^(id results) {
        [MBProgressHUD hideAllHUDsForView:tpvc.view animated:YES];
        
        [tpvc.allMyApplyingTeams addObjectsFromArray:(NSArray *)results];
        [tpvc.tableView reloadData];
        
//        [tpvc release];
    }];
}


- (void)processInvitationOfTeam:(KDCommunity *)team ignoreOrConfirm:(BOOL)isIgnore
{
    KDQuery *query = [KDQuery queryWithName:@"teamId" value:team.communityId];
    [query setParameter:@"type" intValue:isIgnore ? 0 : 1];
    
    __block KDTeamPageViewController *tpvc = self;// retain];
    
    [MBProgressHUD showHUDAddedTo:tpvc.view animated:YES].labelText = ASLocalizedString(@"KDTeamPageViewController_HUD_labelText_joining");
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [MBProgressHUD hideAllHUDsForView:tpvc.view animated:YES];
        if([response isValidResponse]) {
            tpvc->shouldShowBackground_ = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:KDTeamInvitationOnceNotification object:nil];
            
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDTeamPageViewController_Join_Success")message:nil buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:^{
                [tpvc checkFinishedAllInvitation];
            }]  showWithType:KDAccountTipViewTypeSuccess window:self.view.window];
            
            NSMutableArray *shouldRemove = [NSMutableArray array];
            for(KDCommunity *community in tpvc->allInvitation_) {
                if([community.communityId isEqualToString:team.communityId]) {
                    [shouldRemove addObject:community];
                }
            }
            
            [tpvc->allInvitation_ removeObjectsInArray:shouldRemove];
            [tpvc->tableView_ reloadData];
        }else {
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDTeamPageViewController_Join_Fail")message:[response.responseDiagnosis networkErrorMessage] buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:NULL]  showWithType:KDAccountTipViewTypeFaild window:self.view.window];
        }
      
//        [tpvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:processTeamInvitation"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)cancelApplyTeam:(KDCommunity *)team
{
    KDQuery *query = [KDQuery queryWithName:@"teamId" value:team.communityId];
    //TODO：撤销申请的理由
    
    __block KDTeamPageViewController *tpvc = self;// retain];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tpvc.view animated:YES];
    hud.labelText = ASLocalizedString(@"KDTeamPageViewController_HUD_labelText_Undo");
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [MBProgressHUD hideHUDForView:tpvc.view animated:YES];
        if([response isValidResponse]) {
            tpvc->shouldShowBackground_ = YES;
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDTeamPageViewController_Undo_Success")message:nil buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:^{
                [tpvc checkFinishedAllApplying];
            }] showWithType:KDAccountTipViewTypeSuccess window:self.view.window];
            
            [tpvc->allMyApplyingTeams_ removeObject:team];
            [tpvc->tableView_ reloadData];
        }else {
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDTeamPageViewController_Undo_Fail")message:[response.responseDiagnosis networkErrorMessage] buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:NULL]  showWithType:KDAccountTipViewTypeFaild window:self.view.window];
        }
        
//        [tpvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:cancelApplying"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

#pragma mark - Private Methods
- (UIView *)viewForHeaderWithText:(NSString *)text;
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:13.0f];
    label.text = text;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    label.frame = CGRectMake(10.0f, 0.0f, CGRectGetWidth(tableView_.frame), 20.0f);
    
    [view addSubview:label];
//    [label release];
//
    return view;// autorelease];
}

- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)msg
{
    if(title == nil && msg == nil) return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}

- (void)checkFinishedAllInvitation
{
    if(self.allInvitation.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDTeamInvitationFinishedNotification object:self];
    }
}

- (void)checkFinishedAllApplying
{
    if(self.allMyApplyingTeams.count == 0) {
        contentType_ = KDTeamPageContentType_CreatAndJoin;
    }
}

- (void)setBackgroundVisible:(BOOL)visible
{
    if(visible) {
        if(tableView_.backgroundView) {
            tableView_.backgroundView.hidden = NO;
        }else {
            UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds] ;//autorelease];
            backgroundView.backgroundColor = [UIColor clearColor];
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]] ;//autorelease];
            [bgImageView sizeToFit];
            bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
            
            [backgroundView addSubview:bgImageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, self.view.bounds.size.width, 15.0f)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:15.0f];
            label.textColor = MESSAGE_NAME_COLOR;
            label.text = ASLocalizedString(@"KDTeamPageViewController_OK");
            
            [backgroundView addSubview:label];
//            [label release];
            
            tableView_.backgroundView = backgroundView;
        }
    }else {
        if(tableView_.backgroundView) {
            tableView_.backgroundView.hidden = YES;
        }
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 0;
    
    if(contentType_ & KDTeamPageContentType_CreatAndJoin) {
        sectionCount++;
    }
    
    if(contentType_ & KDTeamPageContentType_InviteMe) {
        sectionCount++;
    }
    
    if(contentType_ & KDTeamPageContentType_MyTeams) {
        sectionCount++;
    }
    
    if(contentType_ & KDTeamPageContentType_MyApplyingTeams) {
        sectionCount++;
    }
    
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sectionLocationForInvitation = sectionLocation(KDTeamPageContentType_InviteMe, contentType_);
    NSInteger sectionLocationForMyTeams = sectionLocation(KDTeamPageContentType_MyTeams, contentType_);
    NSInteger sectionLocationForMyApplyingTeams = sectionLocation(KDTeamPageContentType_MyApplyingTeams, contentType_);
    NSInteger sectionLocationForCreate = sectionLocation(KDTeamPageContentType_CreatAndJoin, contentType_);
    
    NSInteger rowCount = 0;
    
    if((contentType_ & KDTeamPageContentType_InviteMe) && sectionLocationForInvitation == section) {
        
        rowCount = allInvitation_.count;
    }
    
    if((contentType_ & KDTeamPageContentType_MyTeams) && sectionLocationForMyTeams == section) {
        rowCount = allMyTeams_.count;
    }
    
    if((contentType_ & KDTeamPageContentType_MyApplyingTeams) && sectionLocationForMyApplyingTeams == section) {
        rowCount = allMyApplyingTeams_.count;
    }
    
    if((contentType_ & KDTeamPageContentType_CreatAndJoin) && sectionLocationForCreate == section) {
        rowCount = 1;
    }
    
    if(shouldShowBackground_) {
        [self setBackgroundVisible:(rowCount == 0)];
    }
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO:
    NSInteger section = indexPath.section;
    NSInteger sectionLocationForInvitation = sectionLocation(KDTeamPageContentType_InviteMe, contentType_);
    NSInteger sectionLocationForMyTeams = sectionLocation(KDTeamPageContentType_MyTeams, contentType_);
    NSInteger sectionLocationForMyApplyingTeams = sectionLocation(KDTeamPageContentType_MyApplyingTeams, contentType_);
    NSInteger sectionLocationForCreate = sectionLocation(KDTeamPageContentType_CreatAndJoin, contentType_);
    
    if((contentType_ & KDTeamPageContentType_InviteMe) && sectionLocationForInvitation == section) {
        return [KDInviteTeamCell defaultHeight] + 10.0f;
    }
    
    if((contentType_ & KDTeamPageContentType_MyTeams) && sectionLocationForMyTeams == section) {
        return [KDTeamCell defaultHeight] + 10.0f;
    }
    
    if((contentType_ & KDTeamPageContentType_MyApplyingTeams) && sectionLocationForMyApplyingTeams == section) {
        return [KDApplyingTeamCell defaultHeight] + 10.0f;
    }
    
    if((contentType_ & KDTeamPageContentType_CreatAndJoin) && sectionLocationForCreate == section) {
        return [KDCreateAndJoinTeamCell defaultHeight];
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //TODO:
    NSInteger sectionLocationForInvitation = sectionLocation(KDTeamPageContentType_InviteMe, contentType_);
    NSInteger sectionLocationForMyTeams = sectionLocation(KDTeamPageContentType_MyTeams, contentType_);
    NSInteger sectionLocationForMyApplyingTeams = sectionLocation(KDTeamPageContentType_MyApplyingTeams, contentType_);
    NSInteger sectionLocationForCreate = sectionLocation(KDTeamPageContentType_CreatAndJoin, contentType_);
    
    if((contentType_ & KDTeamPageContentType_InviteMe) && sectionLocationForInvitation == section) {
        return 0.0f;
    }
    
    if((contentType_ & KDTeamPageContentType_MyTeams) && sectionLocationForMyTeams == section && allMyApplyingTeams_.count > 0) {
        return 20.0f;
    }
    
    if((contentType_ & KDTeamPageContentType_MyApplyingTeams) && sectionLocationForMyApplyingTeams == section && allMyApplyingTeams_.count > 0) {
        return 20.0f;
    }
    
    if((contentType_ & KDTeamPageContentType_CreatAndJoin) && sectionLocationForCreate == section) {
        return 0.0f;
    }
    
    return 0.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger sectionLocationForInvitation = sectionLocation(KDTeamPageContentType_InviteMe, contentType_);
    NSInteger sectionLocationForMyTeams = sectionLocation(KDTeamPageContentType_MyTeams, contentType_);
    NSInteger sectionLocationForMyApplyingTeams = sectionLocation(KDTeamPageContentType_MyApplyingTeams, contentType_);
    NSInteger sectionLocationForCreate = sectionLocation(KDTeamPageContentType_CreatAndJoin, contentType_);
    
    if((contentType_ & KDTeamPageContentType_InviteMe) && sectionLocationForInvitation == section) {
        return nil;
    }
    
    if((contentType_ & KDTeamPageContentType_MyTeams) && sectionLocationForMyTeams == section && allMyApplyingTeams_.count > 0) {
        return [self viewForHeaderWithText:ASLocalizedString(@"KDTeamPageViewController_navigationItem_title_company")];
    }
    
    if((contentType_ & KDTeamPageContentType_MyApplyingTeams) && sectionLocationForMyApplyingTeams == section && allMyApplyingTeams_.count > 0) {
        return [self viewForHeaderWithText:ASLocalizedString(@"KDTeamPageViewController_navigationItem_title_company")];
    }
    
    if((contentType_ & KDTeamPageContentType_CreatAndJoin) && sectionLocationForCreate == section) {
        return nil;
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TOOD:
    NSInteger section = indexPath.section;
    NSInteger sectionLocationForInvitation = sectionLocation(KDTeamPageContentType_InviteMe, contentType_);
    NSInteger sectionLocationForMyTeams = sectionLocation(KDTeamPageContentType_MyTeams, contentType_);
    NSInteger sectionLocationForMyApplyingTeams = sectionLocation(KDTeamPageContentType_MyApplyingTeams, contentType_);
    NSInteger sectionLocationForCreate = sectionLocation(KDTeamPageContentType_CreatAndJoin, contentType_);
    
    if((contentType_ & KDTeamPageContentType_InviteMe) && sectionLocationForInvitation == section) {
        static NSString *inviteCellIdentifier = @"invite_cell_identifier";
        KDInviteTeamCell *cell = (KDInviteTeamCell *)[tableView dequeueReusableCellWithIdentifier:inviteCellIdentifier];
        if(!cell) {
            cell = [[KDInviteTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inviteCellIdentifier] ;//autorelease];
            cell.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        KDCommunity *cmty = [allInvitation_ objectAtIndex:indexPath.row];
        cell.community = cmty;
        
        if(!tableView.decelerating && !tableView.dragging) {
            [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        }
        
        return cell;
    }
    
    if((contentType_ & KDTeamPageContentType_MyTeams) && sectionLocationForMyTeams == section) {
        static NSString *teamCellIdentifier = @"team_cell_identifier";
        KDTeamCell *cell = (KDTeamCell *)[tableView dequeueReusableCellWithIdentifier:teamCellIdentifier];
        if(!cell) {
            cell = [[KDTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:teamCellIdentifier];// autorelease];
            cell.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        KDCommunity *cmty = [allMyTeams_ objectAtIndex:indexPath.row];
        cell.community = cmty;
        
        if (!tableView.decelerating && !tableView.dragging) {
            [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        }
        
        return cell;
    }
    
    if((contentType_ & KDTeamPageContentType_MyApplyingTeams) && sectionLocationForMyApplyingTeams == section) {
        static NSString *applyingTeamCellIdentifier = @"applying_team_cell_identifier";
        KDApplyingTeamCell *cell = (KDApplyingTeamCell *)[tableView dequeueReusableCellWithIdentifier:applyingTeamCellIdentifier];
        if(!cell) {
            cell = [[KDApplyingTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applyingTeamCellIdentifier];// autorelease];
            cell.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        KDCommunity *cmty = [allMyApplyingTeams_ objectAtIndex:indexPath.row];
        cell.community = cmty;
        
        if(!tableView.decelerating && !tableView.dragging) {
            [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        }
        
        return cell;
    }
    
    if((contentType_ & KDTeamPageContentType_CreatAndJoin) && sectionLocationForCreate == section) {
        static NSString *cjCellIdentifier = @"create_join_cell_identifier";
        KDCreateAndJoinTeamCell *cell = (KDCreateAndJoinTeamCell *)[tableView dequeueReusableCellWithIdentifier:cjCellIdentifier];
        if(!cell) {
            cell = [[KDCreateAndJoinTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cjCellIdentifier];// autorelease];
            cell.delegate = self;
        }
        
        return cell;
    }
    
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [KDAvatarView loadImageSourceForTableView:tableView_];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self checkFinishedAllInvitation];
}

#pragma mark - KDApplyingTeamCellDelegate Methods
 - (void)cancelApplyTeamOfApplyingTeamCell:(KDApplyingTeamCell *)cell
{
    [self cancelApplyTeam:cell.community];
}

#pragma mark - KDInviteTeamCellDelegate Methods
- (void)ignoreInviteInTeamCell:(KDInviteTeamCell *)cell
{
    [self processInvitationOfTeam:cell.community ignoreOrConfirm:YES];
}

- (void)joinTeamInTeamCell:(KDInviteTeamCell *)cell
{
    [self processInvitationOfTeam:cell.community ignoreOrConfirm:NO];
}

#pragma mark - KDCreateAndJoinTeamCellDelegate Methods
- (void)createButtonClickedInCreateAndJoinTeamCell:(KDCreateAndJoinTeamCell *)cell
{
    KDCreateTeamViewController *ctvc = [[KDCreateTeamViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    ctvc.fromType = KDCreateTeamFromTypeDidLogin;
    
    [self.navigationController pushViewController:ctvc animated:YES];
}

- (void)joinButtonClickedInCreateAndJoinTeamCell:(KDCreateAndJoinTeamCell *)cell
{
    KDSearchTeamViewController *stvc = [[KDSearchTeamViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    [self.navigationController pushViewController:stvc animated:YES];
}

@end
