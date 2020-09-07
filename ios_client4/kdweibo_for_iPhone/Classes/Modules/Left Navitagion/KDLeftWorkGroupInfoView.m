//
//  KDLeftWorkGroupInfoView.m
//  kdweibo
//
//  Created by bird on 13-12-13.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLeftWorkGroupInfoView.h"
#import "KDLeftMenuCommunityCell.h"
#import "KDManagerContext.h"
#import "CompanyDataModel.h"
#import "BOSSetting.h"

#define ROW_HEIGHT 64.f
#define MESSAGE_MARGIN 5.f
@interface KDLeftWorkGroupInfoView ()<UITableViewDataSource, UITableViewDelegate, KDUnreadListener>
{
    NSArray *groups_;
    
    UIButton *createGroup_;
    UIButton *joinGroup_;
    
    BOOL invitedMessage_;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImageView *separatorView;
@end
@implementation KDLeftWorkGroupInfoView
@synthesize titleLabel = titleLabel_;
@synthesize tableView = tableView_;
@synthesize user = user_;
@synthesize groups = groups_;
@synthesize separatorView = separatorView_;
@synthesize delegate = delegate_;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //KD_RELEASE_SAFELY(separatorView_);
    //KD_RELEASE_SAFELY(groups_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(user_);
    //KD_RELEASE_SAFELY(titleLabel_);
    [[KDManagerContext globalManagerContext].unreadManager removeXTUnreadListener:self];
    //[super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupTableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserName:) name:KDProfileUserNameUpdateNotification object:nil];
        
        
        
        [[KDManagerContext globalManagerContext].unreadManager addXTUnreadListener:self];
    }
    return self;
}
- (void)setupTableView
{
    UIImage * separatorImage = [UIImage imageNamed:@"wLine"];
    UIImageView *separatorView = [[UIImageView alloc] initWithFrame:CGRectZero];
    separatorView.image = separatorImage;
    //    [self addSubview:separatorView];
    separatorView_ = separatorView;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollsToTop = NO;
    //    tableView.scrollEnabled = NO;
    [self addSubview:tableView];
    
    tableView_ = tableView;
}
- (void)setupHeaderView
{
    UIImage *notice = [UIImage imageNamed:@"left_notices_bg"];
    UIImageView *noticeView = [[UIImageView alloc] initWithImage:notice];
    [noticeView sizeToFit];
    noticeView.tag = 0x98;
    [self addSubview:noticeView];
//    [noticeView release];
    noticeView.hidden = YES;
    
    UIImage *unread = [UIImage imageNamed:@"left_notices_unread_v3"];
    UIButton *unreadView = [UIButton buttonWithType:UIButtonTypeCustom];
    [unreadView setBackgroundImage:unread forState:UIControlStateNormal];
    [unreadView setBackgroundImage:unread forState:UIControlStateHighlighted];
    [unreadView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    unreadView.titleLabel.font = [UIFont systemFontOfSize:12.f];
    unreadView.titleLabel.adjustsFontSizeToFitWidth = YES;
    unreadView.titleLabel.textAlignment = NSTextAlignmentCenter;
    [unreadView setTitleEdgeInsets:UIEdgeInsetsMake(0.5f, 17.5, 8, 1)];
    unreadView.tag = 0x99;
    [unreadView sizeToFit];
    [self addSubview:unreadView];
    [unreadView addTarget:self action:@selector(invitedTeamsClicked) forControlEvents:UIControlEventTouchUpInside];
    unreadView.hidden = YES;
    
    UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.numberOfLines   = 1;
    titleLabel.font            = [UIFont systemFontOfSize:19];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor       = [UIColor whiteColor];
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    titleLabel.lineBreakMode   = NSLineBreakByTruncatingMiddle;
    [self addSubview:titleLabel];
    
    titleLabel_ = titleLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    
    UIImageView *notice = (UIImageView *)[self viewWithTag:0x98];
    UIButton *unread = (UIButton *)[self viewWithTag:0x99];
    
    notice.hidden = unread.hidden = !invitedMessage_;
    
    if (user_)
        titleLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"KDLeftWorkGroupInfoView_tips_company"),user_.screenName?user_.screenName:@""];
    
    CGFloat gap = MESSAGE_MARGIN + notice.image.size.width;
    if (!invitedMessage_)
        gap = 0.f;
    
    CGSize size = [titleLabel_.text sizeWithFont:titleLabel_.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 21.f) lineBreakMode:NSLineBreakByTruncatingMiddle];
    CGFloat maxWidth = self.bounds.size.width - 25.f*2 - gap;
    
    if (size.width > maxWidth)
        size.width = maxWidth;
    size.height = 21.f;
    rect.origin.y += 7.0f;
    
    rect.origin.x = (rect.size.width - size.width + gap)/2.0f ;
    rect.size = size;
    
    titleLabel_.frame = rect;
    
    rect.origin.x = rect.origin.x - MESSAGE_MARGIN - notice.image.size.width;
    rect.origin.y -= 2.f;
    rect.size = notice.image.size;
    notice.frame = rect;
    
    rect.origin.x += 2.f;
    rect.origin.y -= 2.f;
    rect.size = [unread backgroundImageForState:UIControlStateNormal].size;
    unread.frame = rect;
    
    rect = titleLabel_.frame;
    rect.size.width = self.bounds.size.width;
    
    CGFloat bottomMargin = 62.f;
    
    rect.origin.x = 1.0f;
    rect.origin.y = CGRectGetMaxY(rect) + 10.f - separatorView_.image.size.height;
    rect.origin.y += 3.f;
    rect.size.height = separatorView_.image.size.height;
    
    separatorView_.frame = rect;
    
    rect.origin.x = 0.0f;
    rect.origin.y += separatorView_.image.size.height +18.f;
    rect.size.height = CGRectGetHeight(self.bounds) - rect.origin.y - bottomMargin -13.f;
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f)
    //        rect.size.height += 22.f;
    
    tableView_.frame = rect;
    
    rect.origin.y = CGRectGetMaxY(rect) + 12.5f;
    rect.origin.x = 30.f;
    rect.size = CGSizeMake(90.f, 30.f);
    createGroup_.frame = rect;
    
    rect.origin.x  = CGRectGetMaxX(rect) + 23.f;
    joinGroup_.frame = rect;
    
    rect.origin.y = CGRectGetMaxY(tableView_.frame);
    rect.origin.x = 0;
    rect.size.width = self.bounds.size.width + 50;;
    rect.size.height = bottomMargin;
    
    UIView *bottomView = (UIView *)[self viewWithTag:0x97];
    bottomView.frame = rect;
    
}
- (NSArray *)sortCommunity:(NSArray *)array
{
    return [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if (((CompanyDataModel *)obj1).unreadCount + ((CompanyDataModel *)obj1).wbUnreadCount>
            ((CompanyDataModel *)obj2).unreadCount + ((CompanyDataModel *)obj2).wbUnreadCount) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (((CompanyDataModel *)obj1).unreadCount + ((CompanyDataModel *)obj1).wbUnreadCount
            < ((CompanyDataModel *)obj2).unreadCount + ((CompanyDataModel *)obj2).wbUnreadCount) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}
- (NSArray *)sortStatusCompany:(NSArray *)array{

    return [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if (((CompanyDataModel *)obj1).user.status>((CompanyDataModel *)obj2).user.status) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (((CompanyDataModel *)obj1).user.status<((CompanyDataModel *)obj2).user.status) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}
- (void)placeCommunityToFirst:(CompanyDataModel *)community
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:groups_];

//    [community retain];
    [array removeObject:community];
    
    int idx = 0;
    for (CompanyDataModel *model in array) {
        if (model.user.status == 1) {
            break;
        }
        idx++;
    }
    if (idx > array.count || idx <=0) {
        idx = 0;
    }

    [array insertObject:community atIndex:idx];
//    [community release];
    
    if (groups_) {
//        [groups_ release];
        groups_ = nil;
    }
    groups_ = array ;//retain];
}
#pragma mark - notice
- (void)updateUserName:(NSNotification *)notifi {
    NSDictionary *userInfo = notifi.userInfo;
    KDUser *nUser = [userInfo objectForKey:@"user"];
    [self setUser:nUser];
}
#pragma mark - set methods
- (void)setInfoCount:(NSInteger)count
{
    UIButton *unread = (UIButton *)[self viewWithTag:0x99];
    invitedMessage_ = count >0;
    
    if (count <1)
        [unread setTitle:@"" forState:UIControlStateNormal];
    else if(count <10)
        [unread setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
    else
        [unread setTitle:@"9+" forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}
- (void)setUser:(KDUser *)user
{
    if (user != user_) {
        if (user_) {
//            [user_ release];
            user_ = nil;
        }
        user_ = user;// retain];
    }
    
    [self setNeedsLayout];
}
- (void)setGroups:(NSArray *)groups
{
    if (groups_) {
//        [groups_ release];
        groups_ = nil;
    }
    groups_ = [self sortStatusCompany:[self sortCommunity:groups]];// retain];
    
    [self sortGroups];
    [tableView_ reloadData];
}
#pragma mark -
#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSInteger maxnNum = CGRectGetHeight(tableView.frame)/ROW_HEIGHT;
    NSInteger count = [groups_ count];
//    maxnNum = count>=maxnNum?maxnNum:count+1;
    return count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    KDLeftMenuCommunityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDLeftMenuCommunityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];// autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CompanyDataModel * commnuity = ((CompanyDataModel *)[groups_ objectAtIndex:indexPath.row]);
    cell.contentLabel.text       = commnuity.name;
    [cell.badgeIndicatorView setBadgeValue:commnuity.unreadCount + commnuity.wbUnreadCount];
    
    if ([commnuity.eid isEqual:[BOSSetting sharedSetting].cust3gNo])
    {
         cell.badgeIndicatorView.hidden = YES;
        [cell setSelectedBg:YES];
    }
    else{
        cell.badgeIndicatorView.hidden = NO;
        [cell setSelectedBg:NO];
    }
    
    cell.statusLabel.text = nil;
    if (commnuity.user.status != 1) {
        cell.badgeIndicatorView.hidden = YES;
        if (commnuity.user.status == 3) {
            cell.statusLabel.text = ASLocalizedString(@"KDLeftWorkGroupInfoView_tips_1");
        }
    }
    
    // 显示当前的工作圈的分割线不要
    if (indexPath.row == 0) {
        cell.separatorView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CompanyDataModel * community = (CompanyDataModel *)[groups_ objectAtIndex:indexPath.row];
    
    if ([community.eid isEqual:[BOSSetting sharedSetting].cust3gNo]) {
        return;
    }
    
    if (community.user.status == 3) {
        NSString *info = [NSString stringWithFormat:ASLocalizedString(@"KDLeftWorkGroupInfoView_tips_2"),community.name];
        [[[UIAlertView alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:info delegate:nil cancelButtonTitle:ASLocalizedString(@"KDLeftWorkGroupInfoView_tips_ok")otherButtonTitles:nil, nil] show];
        
        return;
    }
    
    
    if (community.user.status != 1) {
        return;
    }
    
//    if (!community.isAllowInto)
//        return;
//    
    [[KDWeiboAppDelegate getAppDelegate] changeNetWork:community finished:^(BOOL finished) {
        [[KDManagerContext globalManagerContext].APNSManager sendProviderDeviceToken];
    }];
    
    if ([delegate_ respondsToSelector:@selector(hideLeftView)]) {
        [delegate_ hideLeftView];
    }
    
    [tableView_ reloadData];
    
}

#pragma mark -
#pragma mark - 外部调用

- (void)sortGroups
{
    for (CompanyDataModel *community in groups_) {
        if ([community.eid isEqual:[BOSSetting sharedSetting].cust3gNo] ) {
            [self placeCommunityToFirst:community];
            break;
        }
    }
    
    [tableView_ reloadData];
    
}

//- (NSArray *)getUnreadInfoCommunity
//{
//    KDXTUnread *xtUnread = [KDManagerContext globalManagerContext].unreadManager.xtUnread;
//    
//    BOOL showBadge = NO;
//    
//    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
//    
//    NSArray *menuLists_ = communityManager.joinedCommunities;
//    
//    if((menuLists_!=nil)&&([menuLists_ count]>0)){
//        
//        KDCommunity *currentCommunity = [KDManagerContext globalManagerContext].communityManager.currentCommunity;
//        for(int i= 0;i<[menuLists_ count];i++){
//            
//            KDCommunity * community = (KDCommunity *)[menuLists_ objectAtIndex:i];
//            NSInteger badgeValue    = [xtUnread noticeForCommunityId:community.subDomainName];
//            community.unreadNum = badgeValue;
//            showBadge = (badgeValue > 0) || showBadge;
////            if ([community.communityId isEqualToString:currentCommunity.communityId])
////                community.unreadNum = unread.directMessages + unread.inboxTotal;
//            
//        }
//    }
//    return menuLists_;
//}

#pragma mark -
#pragma mark KDUnreadListener methods
/**
 *  从Unread中读取是否有最新的未读消息
 *
 *  @param unreadManager
 *  @param unread
 */

- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType{
    [self.tableView reloadData];
}
//


//- (void)xtUnreadManager:(KDUnreadManager *)unreadManager didChangeUnread:(KDUnread *)unread {
//}

@end
