//
//  KWIHometlVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/25/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIHometlVCtrl.h"


#import "UIImageView+WebCache.h"
#import "RCPMemCacheMgr.h"
#import "iToast.h"


#import "NSError+KWIExt.h"

#import "KWIStatusCell.h"
#import "KWIStatusVCtrl.h"
#import "KWILoadMoreVCtrl.h"

#import "KDCompanyStatusViewController.h"
#import "KDFriendStatusViewController.h"
#import "KDCommonHeader.h"

@interface KWIHomeTLVCtrl ()

@property (retain, nonatomic) NSCache *cellCache;
@property (retain, nonatomic) NSMutableArray *data;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) KDCompanyStatusViewController *companyStatusViewController;
@property (nonatomic, retain) KDFriendStatusViewController *friendStatusViewController;

@end

@implementation KWIHomeTLVCtrl
{
    BOOL _isPreloading;
    KWIStatusCell *_curOprtCell;
    
    UIButton *_publicTLBtn;
    UIButton *_followingTLBtn;
    UIButton *_curNetworkBtn;
    
    NSString *_identifier;
    
    BOOL isPublic_;
//    BOOL isLoadMore_; //move to super class define
}

@synthesize cellCache = _cellCache;
@synthesize identifier = _identifier;
@synthesize headerView = headerView_;
@synthesize companyStatusViewController = companyStatusViewController_;
@synthesize friendStatusViewController = friendStatusViewController_;

- (void)refreshCompanyStatus {
    if (companyStatusViewController_ == nil) {
        companyStatusViewController_ = [[KDCompanyStatusViewController alloc] init];
        [self.view addSubview:companyStatusViewController_.view];
        CGRect frame = companyStatusViewController_.view.frame;
        frame.origin.y = CGRectGetHeight(headerView_.frame);
        frame.size.height -= frame.origin.y;
        companyStatusViewController_.view.frame = frame;
        
        [companyStatusViewController_ viewWillAppear:NO];
        [companyStatusViewController_ viewDidAppear:NO];
    }else {
        [self.view bringSubviewToFront:companyStatusViewController_.view];
        [companyStatusViewController_ reloadCurrentDataSource];
    }
    
    companyStatusViewController_.view.hidden = NO;
    if (friendStatusViewController_ && [friendStatusViewController_.view superview]) {
        friendStatusViewController_.view.hidden = YES;
    }
    
}

- (void)refreshFriendStatus {
    if (friendStatusViewController_ == nil) {
        friendStatusViewController_ = [[KDFriendStatusViewController alloc] init];
        [self.view addSubview:friendStatusViewController_.view];
        CGRect frame = friendStatusViewController_.view.frame;
        frame.origin.y = CGRectGetHeight(headerView_.frame);
        frame.size.height -= frame.origin.y;
        friendStatusViewController_.view.frame = frame;
        [friendStatusViewController_ viewWillAppear:NO];
        [friendStatusViewController_ viewDidAppear:NO];
    }else {
        [self.view bringSubviewToFront:friendStatusViewController_.view];
        [friendStatusViewController_ reloadCurrentDataSource];
    }
    friendStatusViewController_.view.hidden = NO;
    CGRect frame = friendStatusViewController_.view.frame;
    frame.size.width = self.view.bounds.size.width;
    friendStatusViewController_.view.frame = frame;
    if (companyStatusViewController_ && [companyStatusViewController_.view superview]) {
        companyStatusViewController_.view.hidden = YES;
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    isLoadMore_ = NO; // yes ==> refresh; //move to super class define
    isPublic_ = YES; //no ==> friendtimeline;
    
   // self.data = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].publicTimeLines];
    
    [self _configHeader];
    
    [self _onPublicTLBtnTapped];
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];    
    [dnc addObserver:self 
            selector:@selector(_onNewStatusPosted) 
                name:@"KWIPostVCtrl.newStatus" 
              object:nil];
    [dnc addObserver:self 
            selector:@selector(_onCellEnterEditing:) 
                name:@"KWIStatusCell.showOperations"
              object:nil];   
    
    [dnc addObserver:self 
            selector:@selector(_onCommentCountUpdated:) 
                name:@"KWStatusVCtrl.comment_count_updated" 
              object:nil];
    [dnc addObserver:self
            selector:@selector(_onNetworkChanged:)
                name:@"KWNetwork.changed"
              object:nil];
}

//- (void)initWithDataProvider {
//    self.dataProvider = [[[KDStatusDataProvider alloc] initWithViewController:self] autorelease];
//}

//- (void)viewDidUnload
//{
//    self.tableView = nil;
//    if(_cellCache) self.cellCache = nil;
//    
//    [super viewDidUnload];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    if(_cellCache) self.cellCache = nil;
//    [super didReceiveMemoryWarning];
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    KD_RELEASE_SAFELY(companyStatusViewController_);
    KD_RELEASE_SAFELY(friendStatusViewController_);
    [_curOprtCell release];
    
    [super dealloc];
}

#pragma mark -
- (void)_configHeader
{
    headerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    headerView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView_.clipsToBounds = YES;
    
    UIImage *bg = [UIImage imageNamed:@"mpHdBg.png"];
    UIImageView *bgv = [[[UIImageView alloc] initWithFrame:CGRectMake(-14, 0, bg.size.width, bg.size.height)] autorelease];
    bgv.image = bg;
    [headerView_ addSubview:bgv];
    
    UIView *bottomBorderH = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView_.frame) - 2, CGRectGetWidth(headerView_.frame), 1)] autorelease];
    bottomBorderH.backgroundColor = [UIColor colorWithHexString:@"f3f1e9"];
    bottomBorderH.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [headerView_ addSubview:bottomBorderH];
    
    UIView *bottomBorderL = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView_.frame) - 1, CGRectGetWidth(headerView_.frame), 1)] autorelease];
    bottomBorderL.backgroundColor = [UIColor colorWithHexString:@"d2cdb4"];
    bottomBorderL.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [headerView_ addSubview:bottomBorderL];
    
    _followingTLBtn = [UIButton buttonWithType:UIButtonTypeCustom];   
    _followingTLBtn.frame = CGRectMake((headerView_.frame.size.width - 90 - 6), (headerView_.frame.size.height - 40) / 2.0, 90, 40);
    [_followingTLBtn setTitle:@"我的关注" forState:UIControlStateNormal];
    [_followingTLBtn addTarget:self action:@selector(_onFollowingTLBtnTapped) forControlEvents:UIControlEventTouchDown];
    [headerView_ addSubview:_followingTLBtn];
    
    _publicTLBtn = [UIButton buttonWithType:UIButtonTypeCustom];    
    _publicTLBtn.frame = CGRectMake(CGRectGetMinX(_followingTLBtn.frame) - 90, (headerView_.frame.size.height - 40) / 2.0, 90, 40);
    [_publicTLBtn setTitle:@"全部动态" forState:UIControlStateNormal];
    [_publicTLBtn addTarget:self action:@selector(_onPublicTLBtnTapped) forControlEvents:UIControlEventTouchDown];
    [headerView_ addSubview:_publicTLBtn];
    
    for (UIButton *btn in [NSArray arrayWithObjects:_followingTLBtn, _publicTLBtn, nil]) {
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [btn setTitleColor:[UIColor colorWithHexString:@"333"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"666"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        [btn setBackgroundImage:[UIImage imageNamed:@"homeTLTabBg.png"] forState:UIControlStateSelected];
    }
    
    _curNetworkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _curNetworkBtn.frame = CGRectMake(20, 0, 100, 50);
    [_curNetworkBtn setImage:[UIImage imageNamed:@"curNetworkBtn.png"] forState:UIControlStateNormal];
    _curNetworkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_curNetworkBtn setTitleColor:[UIColor colorWithHexString:@"333"] forState:UIControlStateNormal];
    _curNetworkBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    [_curNetworkBtn addTarget:self action:@selector(_onNetworkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    _curNetworkBtn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [headerView_ addSubview:_curNetworkBtn];
    
    [self.view addSubview:headerView_];
}

#pragma mark -

//- (void)_refresh
//{
//    if(!self.isLoading) {
//        self.isLoading = YES;
//        isLoadMore_ = NO;
//        
//        NSString *temp = nil;
//        if(isPublic_)
//            [[KDWeiboCore sharedKDWeiboCore] fetchPublicTimeLineIsLoad:NO delegate:self];
//        else
//            [[KDWeiboCore sharedKDWeiboCore] fetchFriendTimeLineIsLoad:NO delegate:self];
//        self.identifier = temp;
//    }
//}
//
//- (void)_loadmore
//{
//    if(!self.isLoading) {
//        self.isLoading = YES;
//        isLoadMore_ = YES;
//        NSString *temp = nil;
//        if(isPublic_)
//            [[KDWeiboCore sharedKDWeiboCore] fetchPublicTimeLineIsLoad:YES delegate:self];
//        else
//            [[KDWeiboCore sharedKDWeiboCore] fetchFriendTimeLineIsLoad:YES delegate:self];
//        self.identifier = temp;
//    }
//}
//
#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]];
//    
//    return CGRectGetHeight(cell.frame);
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]];
//}
//
//- (KWIStatusCell *)_loadCellForStatus:(KWStatus *)status
//{
//    KWIStatusCell *cell = [[KWIStatusCell cell] retain];
//    cell.data = status;
//    
//    return [cell autorelease];
//}
//
//- (void)_resetTableV
//{
//    [self _disableLoadmore];
//    [self.emptyV removeFromSuperview];
//    [self.tableView reloadData];
//}

#pragma mark -
//点击全部动态
- (void)_onPublicTLBtnTapped
{
    isPublic_ = YES;
    _publicTLBtn.selected = YES;
    _followingTLBtn.selected = NO;
    
    //self.data = [NSArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].publicTimeLines];

 
    [self refreshCompanyStatus];
//    if(self.data.count == 0)
//        [self _refresh];
//
//    [self _resetTableV];
}
//点击我的关注
- (void)_onFollowingTLBtnTapped
{
    isPublic_ = NO;
    _followingTLBtn.selected = YES;
    _publicTLBtn.selected = NO;
    
   // self.data = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].friendTimeLines];


    [self refreshFriendStatus];
    
//    if(self.data.count == 0)
//        [self _refresh];
//
//    [self _resetTableV];
}

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:[self.data objectAtIndex:indexPath.row]];
//    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [KWIStatusCell class], @"from", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];
//}

- (void)_onCellEnterEditing:(NSNotification *)note;
{
    KWIStatusCell *newEditingCell = note.object;
    if (_curOprtCell != newEditingCell) {
        [_curOprtCell hideOperations];
        _curOprtCell = newEditingCell;
    }    
}


- (void)_onNewStatusPosted
{
    //不需要刷新 改动：2012-10－31
//    [self _refresh];
}


//社区选择后 更新titile 
- (void)_onNetworkChanged:(NSNotification *)note
{
    KDCommunity *community = [note.userInfo objectForKey:@"network"];
    if (community && _curNetworkBtn) {
        [_curNetworkBtn setTitle:[NSString stringWithFormat:@"  %@", community.name] forState:UIControlStateNormal];
        CGSize suggestedSize = [community.name sizeWithFont:_curNetworkBtn.titleLabel.font];
        NSUInteger targetWidth = MIN(suggestedSize.width + 36, 240);
        CGRect btnFrm = _curNetworkBtn.frame;        
        btnFrm.size.width = targetWidth;
        _curNetworkBtn.frame = btnFrm;
    }
}

- (void)_onNetworkBtnTapped:(id)sender{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWNetwork.showList" object:self];
   
}

//- (void)_onStatusDeleted:(NSNotification *)note
//{
//    KWStatus *status = note.object;
//    KWStatus *toDel = nil;
//    unsigned int idxRm = 0;
//    for (KWStatus *e in self.data) {
//        if ([e.id_ isEqualToString:status.id_]) {
//            toDel = e;
//            break;
//        }
//        idxRm++;
//    }
//    
//    if (nil == toDel) {
//        return;
//    }
//    
//    NSArray *indexpaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:idxRm inSection:0]];    
//    [self.tableView deleteRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationFade];
//}

//- (void)_onCommentCountUpdated:(NSNotification *)note
//{
//    NSDictionary *uinf = note.userInfo;
//    NSString *id_ = [uinf objectForKey:@"id"];
//    NSNumber *count = [uinf objectForKey:@"count"];
//    
//    unsigned int idx = 0;
//    for (KWStatus *status in self.data) {
//        if ([status.id_ isEqualToString:id_]) {
//            status.reply_count = count;
//            [self.cellCache removeObjectForKey:status.id_];
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationNone];
//            break;
//        }        
//        idx++;
//    }
//}

#pragma mark -
//- (NSCache *)cellCache
//{
//    if (!_cellCache) {
//        _cellCache = [[NSCache alloc] init];
//        _cellCache.name = self.class.description;
//        _cellCache.countLimit = 100;
//    }
//    
//    return _cellCache;
//}

#pragma mark - empty view

- (NSString *)emptyImageName
{
    return @"emptyStatus.png";
}

- (NSString *)emptyTextPartial
{
    return @"微博";
}

- (BOOL)isPublic {
    return isPublic_;
}

#pragma mark -

////override this method to do sth. special
// - (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
//     if(isPublic_)
//         self.data = [NSArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].publicTimeLines];
//     else
//         self.data = [NSArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].friendTimeLines];
//     [super kdWeiboCore:core didFinishLoadFor:delegate withError:error userInfo:userInfo];
// }
//

- (void)refreshStatus
{
    if (isPublic_) {
        [self _onPublicTLBtnTapped];
    } else {
        [self _onFollowingTLBtnTapped];
    }
}

@end
