//
//  KDSearchTeamViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSearchTeamViewController.h"
#import "KDTeamCell.h"
#import "KDManagerContext.h"
#import "KDJoinTeamValidationViewController.h"
#import "KDWeiboServices.h"
#import "KDWeiboServicesContext.h"
#import "UIViewAdditions.h"
#import "MBProgressHUD.h"
#import "KDAccountTipView.h"
#import "KDSearchBar.h"
#import "KDMaskView.h"
#import "KDApplyingTeamCell.h"

@interface KDSearchTeamViewController () <UITableViewDataSource, UITableViewDelegate, KDSearchBarDelegate, KDMaskViewDelegate>
{
    UITableView *tableView_;
    
    NSMutableArray *communities_;
    
    KDSearchBar *searchBar_;
    
    KDMaskView *maskView_; //weak
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) KDSearchBar *searchBar;

@end

@implementation KDSearchTeamViewController

@synthesize tableView = tableView_;
@synthesize searchBar = searchBar_;
@synthesize shouldDelayShowKeyBoard = _shouldDelayShowKeyBoard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = ASLocalizedString(@"加入公司");
        communities_ = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(searchBar_);
    //KD_RELEASE_SAFELY(communities_);
    
    //[super dealloc];
}

- (BOOL)resignFirstResponder
{
    [searchBar_ resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (void)viewDidUnload
{
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(searchBar_);
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.searchBar = [[KDSearchBar alloc] init];// autorelease];
    searchBar_.showsCancelButton = YES;
    searchBar_.delegate = self;
    searchBar_.placeHolder = ASLocalizedString(@"KDSearchTeamViewController_searchBar_placeHolder");
    searchBar_.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 50.0f);
    [self.view addSubview:searchBar_];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(searchBar_.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(searchBar_.frame))];// autorelease];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.backgroundColor = RGBCOLOR(230, 230, 230);
    tableView_.backgroundView = nil;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView_];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_shouldDelayShowKeyBoard) {
        [self.searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25f];
    }else {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network Methods
- (void)searchWithKey:(NSString *)key
{
    KDQuery *query = [KDQuery queryWithName:@"key" value:key];
    
    __block KDSearchTeamViewController *stvc = self;// retain];
    [MBProgressHUD showHUDAddedTo:stvc.view animated:YES].labelText = ASLocalizedString(@"KDSearchTeamViewController_Searching");
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [MBProgressHUD hideAllHUDsForView:stvc.view animated:YES];
        [stvc->communities_ removeAllObjects];
        if([response isValidResponse]) {
            if(results) {
                [stvc->communities_ addObjectsFromArray:(NSArray *)results];
            }
        }else {
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDSearchTeamViewController_Search_Fail")message:[response.responseDiagnosis networkErrorMessage] buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:NULL]  showWithType:KDAccountTipViewTypeFaild window:self.view.window];
        }
        
        [stvc setBackground:[stvc->communities_ count] == 0];
        [stvc->tableView_ reloadData];
        
//        [stvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:searchTeam"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)setBackground:(BOOL)visible
{
    if(visible) {
        if(self.tableView.backgroundView) {
            self.tableView.backgroundView.hidden = NO;
        }else {
            UIView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];// autorelease];
            [backgroundView setUserInteractionEnabled:YES];
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]];// autorelease];
            [bgImageView sizeToFit];
            bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
            
            [backgroundView addSubview:bgImageView];
            backgroundView.backgroundColor = [UIColor clearColor];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 10.0f, self.view.bounds.size.width, 15.0f)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = MESSAGE_NAME_COLOR;
            label.font = [UIFont systemFontOfSize:12.0f];
            
            label.text = ASLocalizedString(@"KDSearchTeamViewController_Search_NoResult");
            
            [backgroundView addSubview:label];
//            [label release];
            
            self.tableView.backgroundView = backgroundView;
        }
    }else {
        if(self.tableView.backgroundView) {
            self.tableView.backgroundView.hidden = YES;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return communities_.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [KDTeamCell defaultHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDCommunity *community = [communities_ objectAtIndex:indexPath.row];
    
    if(!community.isAllowInto && community.isApply) {
        static NSString * applyingCellIdentifier = @"applying-team-cell-identifier";
        KDApplyingTeamCell *cell = (KDApplyingTeamCell *)[tableView dequeueReusableCellWithIdentifier:applyingCellIdentifier];
        if(!cell) {
            cell = [[KDApplyingTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applyingCellIdentifier];// autorelease];
            cell.backgroundColor = RGBCOLOR(250, 250, 250);
            cell.backgroundView = nil;
            
        }
        
        cell.community = community;
        
        if(!tableView.dragging && !tableView.decelerating){
            [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        }
        
        return cell;
    }else {
        static NSString *CellIdentifier = @"team-cell-identifier";
        
        KDTeamCell *cell = (KDTeamCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell) {
            cell = [[KDTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
            cell.showAddButton = YES;
            cell.showTeamNumber = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = RGBCOLOR(250, 250, 250);
            cell.backgroundView = nil;
            
            UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
            selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            selectBgView.backgroundColor = RGBCOLOR(26, 133, 255);
            cell.selectedBackgroundView = selectBgView;
        }
        
        if(community.communityType == KDCommunityTypeCompany) {
            cell.showAddButton = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else {
            cell.showAddButton = YES;
            
            if(community.isAllowInto) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }
        
        cell.community = community;
        
        
        if(!tableView.dragging && !tableView.decelerating){
            [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = RGBCOLOR(250, 250, 250);
}

#pragma mark - UITableviewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KDCommunity *cmty = [communities_ objectAtIndex:indexPath.row];
    if(cmty.communityType == KDCommunityTypeCompany || cmty.isAllowInto || cmty.isApply) {
        
        if(cmty.communityType == KDCommunityTypeCompany) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDSearchTeamViewController_alertView_message")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
            [alert show];
//            [alert release];
        }
        
        return;
    }
    
    KDJoinTeamValidationViewController *join = [[KDJoinTeamValidationViewController alloc] initWithNibName:nil bundle:nil] ;//autorelease];
    join.community = cmty;
    [self.navigationController pushViewController:join animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [KDAvatarView loadImageSourceForTableView:tableView_];
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

- (void)searchBarCancelButtonClicked:(KDSearchBar *)searchBar
{
    [searchBar setText:nil];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar
{
    if(searchBar.text.length > 0) {
        [searchBar resignFirstResponder];
        [self searchWithKey:searchBar.text];
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
    
    maskView_.frame = self.tableView.frame;
}

- (void)removeMaskView {
    if(maskView_) {
        if(maskView_.superview) {
            [maskView_ removeFromSuperview];
        }
        maskView_ = nil;
    }
}

@end
