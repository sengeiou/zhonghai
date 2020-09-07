//
//  KDCommunityDropDownView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDCommunityDropDownView.h"
#import "KDBadgeIndicatorView.h"
#import "KDLeftNavBadgeIndicatorView.h"
#import "KDNotificationView.h"

#import "KDCommunity.h"
#import "KDServiceActionInvoker.h"
#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"

#import "KDManagerContext.h"



////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDCommunityDropDownFooterView class

@interface KDCommunityDropDownFooterView : UIView {
 @private
    UIView *dividerView_;
    UIButton *refreshButton_;
    UIActivityIndicatorView *activityView_;
}

@property(nonatomic, retain) UIView *dividerView;
@property(nonatomic, retain) UIButton *refreshButton;
@property(nonatomic, retain) UIActivityIndicatorView *activityView;

- (void)startLoading:(BOOL)loading;

@end


@implementation KDCommunityDropDownFooterView

@synthesize dividerView=dividerView_;
@synthesize refreshButton=refreshButton_;
@synthesize activityView=activityView_;

- (void)setupCommunityDropDownFooterView {
    // divider view
    dividerView_ = [[UIView alloc] initWithFrame:CGRectZero];
    dividerView_.backgroundColor = RGBCOLOR(54.0, 79.0, 108.0);
    
    [self addSubview:dividerView_];
    
    // refresh button
    refreshButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [refreshButton_ setImage:[UIImage imageNamed:@"refresh_button_bg.png"] forState:UIControlStateNormal];
    [refreshButton_ sizeToFit];
    
    [self addSubview:refreshButton_];
    
    // activity view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView_.hidden = YES;
    [self addSubview:activityView_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setupCommunityDropDownFooterView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGRect rect = CGRectMake(5.0, 0.0, width - 10.0, 1.0); 
    dividerView_.frame = rect;
    
    rect = refreshButton_.bounds;
    rect.origin.x = (width - rect.size.width) * 0.5;
    rect.origin.y = (height - rect.size.height) * 0.5;
    refreshButton_.frame = rect;
    
    rect = activityView_.bounds;
    rect.origin.x = (width - rect.size.width) * 0.5;
    rect.origin.y = (height - rect.size.height) * 0.5;
    activityView_.frame = rect;
}

- (void)startLoading:(BOOL)loading {
    refreshButton_.hidden = loading ? YES : NO;
    activityView_.hidden = loading ? NO : YES;
    
    if(loading){
        if(![activityView_ isAnimating]){
            [activityView_ startAnimating];
        }
        
    }else {
        if([activityView_ isAnimating]){
            [activityView_ stopAnimating];
        }
    }
}

- (void)dealloc {
    KD_RELEASE_SAFELY(dividerView_);
    KD_RELEASE_SAFELY(refreshButton_);
    KD_RELEASE_SAFELY(activityView_);
    
    [super dealloc];
}

@end


////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDCommunityDropDownView class

@interface KDCommunityDropDownView ()

@property(nonatomic, retain) NSArray *displayItems;
@property(nonatomic, retain) KDCommunity *currentCommunity;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) KDCommunityDropDownFooterView *footerView;

@end


#define KD_COMMUNITY_DROP_DOWN_CELL_HEIGHT  30.0
#define KD_COMMUNITY_DROP_DOWN_CELL_BADGE_VIEW_TAG  0x64

@implementation KDCommunityDropDownView

@synthesize displayItems=displayItems_;
@synthesize currentCommunity=currentCommunity_;

@synthesize tableView=tableView_;
@synthesize infoLabel=infoLabel_;
@synthesize footerView=footerView_;

- (void)setupCommunityDropDownView {
    //UIImage *bgImage = [UIImage imageNamed:@"community_drop_down_bg.png"];
    UIImage *bgImage = [UIImage imageNamed:@"timeline_switch_menu_bg.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:10 topCapHeight:bgImage.size.height * 0.5];
    
    [super setBackgroundImage:bgImage];
    
    // table view
    tableView_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView_.backgroundColor = [UIColor clearColor];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    
    [super.contentView addSubview:tableView_];
    
    // bottom footer view
    footerView_ = [[KDCommunityDropDownFooterView alloc] initWithFrame:CGRectZero];
    [footerView_.refreshButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    
    [super.contentView addSubview:footerView_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCommunityDropDownView];
    }
    
    return self;
}

- (void)layoutInfoLabel {
    if(infoLabel_ != nil){
        CGFloat offsetY = (super.contentView.bounds.size.height - footerView_.bounds.size.height - 40.0) * 0.5;
        CGRect rect = CGRectMake(0.0, offsetY + 5.0, super.contentView.bounds.size.width, 40.0);
        infoLabel_.frame = rect;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectInset(super.contentView.bounds, 15.0, 0.0);
    rect.origin.y = 20.0;
    rect.size.height = rect.size.height - 50.0f - 10.0f;
    tableView_.frame = rect;
    
    rect.origin.y = super.contentView.bounds.size.height - 40.0;
    rect.size.height = 40.0;
    footerView_.frame = rect;
    
    [self layoutInfoLabel];
}


//////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0x01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (displayItems_ != nil && [displayItems_ count] > 0) ? [displayItems_ count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KD_COMMUNITY_DROP_DOWN_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDCommunityDropDownCell *cell = (KDCommunityDropDownCell *)[tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
   // KDLeftNavBadgeIndicatorView *badgeView  = nil;
    if(cell == nil){
        cell = [[[KDCommunityDropDownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
//        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//        cell.textLabel.minimumFontSize = 16.0;
//        
//        cell.textLabel.textAlignment = UITextAlignmentCenter;
        //cell.textLabel.textColor = [UIColor whiteColor];
        
//        KDBadgeIndicatorView *badgeView = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
//        badgeView.userInteractionEnabled = NO;
//        badgeView.tag = KD_COMMUNITY_DROP_DOWN_CELL_BADGE_VIEW_TAG;
//        
//        [badgeView setBadgeBackgroundImage:[KDBadgeIndicatorView redBadgeBackgroundImage]];
//        CGRect frame = CGRectMake(tableView_.bounds.size.width - 32- 6.0, (KD_COMMUNITY_DROP_DOWN_CELL_HEIGHT - 28) * 0.5, 32, 28);
//        badgeView = [[KDLeftNavBadgeIndicatorView alloc] initWithFrame:frame];
//        badgeView.tag = KD_COMMUNITY_DROP_DOWN_CELL_BADGE_VIEW_TAG;
//        
//        
//        [cell.contentView addSubview:badgeView];
//        [badgeView release];
    }
    
    KDCommunity *community = [displayItems_ objectAtIndex:indexPath.row];
    //cell.textLabel.text = community.name;
    
    NSInteger badgeValue = [[KDManagerContext globalManagerContext].unreadManager.unread noticeForCommunityId:community.subDomainName];
    [cell setText:community.name badgeCount:badgeValue];
    
//    badgeView = (KDLeftNavBadgeIndicatorView *)[cell.contentView viewWithTag:KD_COMMUNITY_DROP_DOWN_CELL_BADGE_VIEW_TAG];
//    if (badgeView) {
//        [badgeView setCount:badgeValue];
//    }
//    if(badgeValue > 0){
//        [badgeView setCount:badgeValue];
//        
//        CGSize size = [badgeView getBadgeContentSize];
//        CGRect rect = CGRectMake(tableView_.bounds.size.width - size.width - 6.0,
//                                 (KD_COMMUNITY_DROP_DOWN_CELL_HEIGHT - size.height) * 0.5,
//                                 size.width, size.height);
//        
//        badgeView.frame = rect;
//    }else {
//        badgeView.hidden = YES;
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(super.delegate != nil && [super.delegate respondsToSelector:@selector(communityDropDownView:didSelectCommunity:)]){
        KDCommunity *community = [displayItems_ objectAtIndex:indexPath.row];
        [(id<KDCommunityDropDownViewDelegate>)super.delegate communityDropDownView:self didSelectCommunity:community];
    }
    
    if(super.showInKeyWindow){
        [super dismiss:YES];
    }
}

- (void)infoLabelWithVisible:(BOOL)visible info:(NSString *)info {
    if(infoLabel_ == nil){
        infoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        [self layoutInfoLabel];
        
        infoLabel_.userInteractionEnabled = NO;
        
        infoLabel_.backgroundColor = [UIColor clearColor];
        infoLabel_.textColor = [UIColor whiteColor];
        infoLabel_.font = [UIFont systemFontOfSize:15.0];
        infoLabel_.textAlignment = UITextAlignmentCenter;
        
        [super.contentView addSubview:infoLabel_];
    }
    
    if(visible){
        infoLabel_.text = info;
        
        infoLabel_.hidden = NO;
        [super.contentView bringSubviewToFront:infoLabel_];
        
    }else {
        infoLabel_.hidden = YES;
        [super.contentView sendSubviewToBack:infoLabel_];
    }
}

- (void)adjustCommunityMenuViewContentSize {
    NSInteger count = 0;
    
    if([displayItems_ count] > 7)
        count = 6.5;
    else
        count = [displayItems_ count];
    
    CGFloat height = MAX(count * KD_COMMUNITY_DROP_DOWN_CELL_HEIGHT + 5.0f, 40.0);
    height += 70.0; // top = 10.0 and bottom = 50.0
    
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (void)setCommunities:(NSArray *)communities selectedCommunity:(KDCommunity *)selectedCommunity {
    self.currentCommunity = selectedCommunity;
    if(communities != nil && [communities count] > 0){
        NSMutableArray *displayItems = [NSMutableArray arrayWithArray:communities];
        
        // remove current selected network from data source
        KDCommunity *target = nil;
        for(KDCommunity *item in displayItems){
            if([item.communityId isEqualToString:currentCommunity_.communityId]){
                target = item;
                break;
            }
        }
        
        if(target != nil){
            [displayItems removeObject:target];
        }
        
        self.displayItems = displayItems;
        
        // adjust the menu height
        [self adjustCommunityMenuViewContentSize];
    }
    
    BOOL infoLabelVisible = (displayItems_ != nil && [displayItems_ count] > 0) ? NO : YES;
    NSString *info = nil;
    if(infoLabelVisible){
        if ([[KDManagerContext globalManagerContext].communityManager isCompanyDomain]) {
            info = NSLocalizedString(@"NOT_JOIN_COMMUNITY_YET", @"");
        
        }else {
            info = NSLocalizedString(@"NOT_JOIN_OTHERS_COMMUNITY_YET", @"");
        }
    }
    
    [self infoLabelWithVisible:infoLabelVisible info:info];
}

- (void)reload:(UIButton *)btn {
    [footerView_ startLoading:YES];

    __block KDCommunityDropDownView *dropDownView = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                NSArray *communities = results;
                
                // update networks
                KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
                communityManager.joinedCommunities = communities;
                
                [dropDownView setCommunities:communityManager.joinedCommunities selectedCommunity:communityManager.currentCommunity];
                
                // reload data source
                [dropDownView.tableView reloadData];
                
            }
        }
       else {
           if (![response isCancelled]) {
               [[KDNotificationView defaultMessageNotificationView] showInView:dropDownView.window
                                                                       message:NSLocalizedString(@"REFRESH_COMMUNITIES_DID_FAIL", @"")
                                                                          type:KDNotificationViewTypeNormal];
           }
        }
        
        [dropDownView.footerView startLoading:NO];
        // release current view
        [dropDownView release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/network/:list" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)reloadData {
    [tableView_ reloadData];
}

- (void)dealloc {
    KD_RELEASE_SAFELY(displayItems_);
    KD_RELEASE_SAFELY(currentCommunity_);
    
    KD_RELEASE_SAFELY(tableView_);
    KD_RELEASE_SAFELY(infoLabel_);
    KD_RELEASE_SAFELY(footerView_);
    
    [super dealloc];
}

@end
