//
//  GroupInfoViewController.m
//  TwitterFon
//
//  Created by  on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "GroupInfoViewController.h"

#import "ResourceManager.h"
#import "JSON.h"
#import "GroupUserController.h"
#import "KDWeiboAppDelegate.h"

#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"
#import "KDDatabaseHelper.h"
#import "UIViewAdditions.h"
#import "KDAnimationAvatarView.h"

//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDGroupDetailsCell class
#define KD_GROUP_INFO_CELL_MIN_HEIGHT   50
#define KD_GROUP_INFO_CELL_SUBTITLE_TOP_MARIGN 15
#define KD_GROUP_INFO_CELL_SUBTITLE_BUTTOM_MARGIN  20
#define KD_GROUP_INFO_CELL_SUBTITLE_MAX_HEIGHT  100.0
#define KD_GROUP_INFO_CELL_SUBTITLE_MAX_WIDTH   240.0
#define KD_GROUP_INFO_SUBTITILE_SIZE(text)  [text  sizeWithFont:[UIFont systemFontOfSize:15] \
                                                   constrainedToSize:CGSizeMake(KD_GROUP_INFO_CELL_SUBTITLE_MAX_WIDTH,KD_GROUP_INFO_CELL_SUBTITLE_MAX_HEIGHT) \
                                                   lineBreakMode:NSLineBreakByTruncatingTail]

@interface KDGroupDetailsCell : UITableViewCell {
@private
    BOOL subTitleLabelNeedDisplay_;
    BOOL cellAccessoryNeedDisplay_;
    
    UIImageView      *backgroundView_;
}

@property (nonatomic, assign) BOOL cellAccessoryNeedDisplay;
@property (nonatomic, assign) BOOL subTitleLabelNeedDisplay;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *subTitleLabel;
@property (nonatomic, retain) UILabel *separatorView;
@property (nonatomic, retain) UIImageView *cellAccessoryImageView;
@property(nonatomic,retain)UIView  *highlightedView;
@end


@implementation KDGroupDetailsCell
@synthesize cellAccessoryNeedDisplay= cellAccessoryNeedDisplay_;
@synthesize subTitleLabelNeedDisplay=subTitleLabelNeedDisplay_;
@synthesize cellAccessoryImageView=cellAccessoryImageView_;
@synthesize titleLabel = titleLabel_;
@synthesize iconImageView = iconImageView_;
@synthesize subTitleLabel = subTitleLabel_;
@synthesize separatorView = separatorView_;
@synthesize highlightedView = highlightedView_;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImage *bgImg = [UIImage imageNamed:@"todo_bg"];
        bgImg = [bgImg stretchableImageWithLeftCapWidth:bgImg.size.width/2.0f topCapHeight:bgImg.size.height/2.0f];
        backgroundView_ = [[UIImageView alloc] initWithImage:bgImg];// autorelease];
        backgroundView_.userInteractionEnabled = YES;
        [self.contentView addSubview:backgroundView_];
        
        highlightedView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:highlightedView_];

        
        titleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel_.backgroundColor = [UIColor clearColor];
        titleLabel_.font = [UIFont systemFontOfSize:16];
        titleLabel_.textColor = MESSAGE_TOPIC_COLOR;
        [backgroundView_ addSubview:titleLabel_];
       
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:iconImageView_];
        
        subTitleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        subTitleLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
        subTitleLabel_.backgroundColor = [UIColor clearColor];
        subTitleLabel_.font = [UIFont systemFontOfSize:15];
        subTitleLabel_.numberOfLines = 0;
        subTitleLabel_.textColor = MESSAGE_NAME_COLOR;
        [backgroundView_ addSubview:subTitleLabel_];
        
        separatorView_ = [[UILabel alloc] initWithFrame:CGRectZero];
        separatorView_.backgroundColor = MESSAGE_LINE_COLOR;
        [backgroundView_ addSubview:separatorView_];
        
        cellAccessoryImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        cellAccessoryImageView_.image = [UIImage imageNamed:@"profile_edit_narrow_v3"];
        [backgroundView_ addSubview:cellAccessoryImageView_];
    }
    return self;
}
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect frame = CGRectZero;
    if (iconImageView_.image) {
        frame.origin.x=  10.f;
        frame.origin.y = (KD_GROUP_INFO_CELL_MIN_HEIGHT - iconImageView_.image.size.height)/2.0;
        frame.size = iconImageView_.image.size;
        iconImageView_.frame = frame;
    }
   
    frame.origin.x = CGRectGetMaxX(frame) + 10;
    frame.origin.y= (KD_GROUP_INFO_CELL_MIN_HEIGHT - 20)/2.0;
    frame.size.height = 20;
    frame.size.width = 120;
    titleLabel_.frame = frame;
    
    separatorView_.hidden = !subTitleLabelNeedDisplay_;
    if (subTitleLabelNeedDisplay_) {
        separatorView_.frame = CGRectMake(0, KD_GROUP_INFO_CELL_MIN_HEIGHT, self.bounds.size.width, 0.5);
    }
    cellAccessoryImageView_.hidden = !cellAccessoryNeedDisplay_;
    if (cellAccessoryNeedDisplay_) {
        cellAccessoryImageView_.frame = CGRectMake(self.bounds.size.width - cellAccessoryImageView_.image.size.width -10, (KD_GROUP_INFO_CELL_MIN_HEIGHT - cellAccessoryImageView_.image.size.height)/2.0, cellAccessoryImageView_.image.size.width, cellAccessoryImageView_.image.size.height);
    }

    CGRect rect = self.bounds;
    if (subTitleLabel_.text.length >0) {
        frame = self.titleLabel.frame;
        frame.origin.y = KD_GROUP_INFO_CELL_MIN_HEIGHT + KD_GROUP_INFO_CELL_SUBTITLE_TOP_MARIGN;
        frame.size = KD_GROUP_INFO_SUBTITILE_SIZE(subTitleLabel_.text);
        subTitleLabel_.frame = frame;
        
        rect.size.height = CGRectGetMaxY(frame) + KD_GROUP_INFO_CELL_SUBTITLE_BUTTOM_MARGIN;
    }
    else
        rect.size.height = KD_GROUP_INFO_CELL_MIN_HEIGHT;
    
    backgroundView_.frame = rect;
    highlightedView_.frame = CGRectInset(backgroundView_.bounds, 0.5f, 0.5f);
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    // Configure the view for the selected state
    if (cellAccessoryNeedDisplay_)
    {
        highlightedView_.backgroundColor = highlighted?[UIColor colorWithRed:240/255.0 green:241/255.0 blue:242/255.f alpha:1.0f]:[UIColor clearColor];
        cellAccessoryImageView_.image = highlighted?[UIImage imageNamed:@"smallTriangle"]:[UIImage imageNamed:@"profile_edit_narrow_v3"];
    }
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(highlightedView_);
    //KD_RELEASE_SAFELY(cellAccessoryImageView_);
    //KD_RELEASE_SAFELY(titleLabel_);
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(separatorView_);
    //KD_RELEASE_SAFELY(subTitleLabel_);
    //[super dealloc];
}
@end



//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark GroupInfoViewController class

@interface GroupInfoViewController ()

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) KDAnimationAvatarView *groupAvatarView;
@property (nonatomic, retain) UILabel *introLabel;

- (void) update;

@end


@implementation GroupInfoViewController

@dynamic group;

@synthesize tableView=tableView_;
@synthesize groupAvatarView=groupAvatarView_;
@synthesize introLabel=introLabel_;

- (id)init {
    self = [super init];
    if (self) {
        groupDetailsFlags_.didLoadGroupDetails = 0;
        groupDetailsFlags_.enterGroup = 0;
    }
    
    return self;
}

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
//    [aView release];
    
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    
    CGRect rect = CGRectMake(6.0, 0.0, self.view.bounds.size.width-12, self.view.bounds.size.height);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = MESSAGE_BG_COLOR;
    self.tableView = tableView;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    
    // header view
    rect = CGRectMake(0.0, 0.0, tableView_.bounds.size.width, 112.0);
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    
    // group avatar view
    rect = CGRectMake(10.0, (rect.size.height - 70.f) * 0.5, 70.f, 70.f);
    self.groupAvatarView = [[KDAnimationAvatarView alloc] initWithFrame:rect andNeedHighLight:NO] ;//autorelease];
    self.groupAvatarView.ringImage = nil;
    groupAvatarView_.frame = rect;
    
    // avatar view background
    UIImageView *avatarBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_circle"]];
    [avatarBgView sizeToFit];
    avatarBgView.center = groupAvatarView_.center;
    [headerView addSubview:avatarBgView];
//    [avatarBgView release];
    
    [headerView addSubview:groupAvatarView_];
    
    // group introduce label
    CGFloat offsetX = rect.origin.x + rect.size.width + 5.0;
    rect = CGRectMake(offsetX, 5.0, headerView.bounds.size.width - offsetX - 5.0, headerView.bounds.size.height - 10.0);
    UILabel *introLabel = [[UILabel alloc] initWithFrame:rect];
    self.introLabel = introLabel;
//    [introLabel release];
    
    introLabel_.backgroundColor = [UIColor clearColor];
    introLabel_.numberOfLines = 0;
    introLabel.textColor = MESSAGE_NAME_COLOR;
    introLabel_.font = [UIFont systemFontOfSize:16];
    
    introLabel_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:introLabel_];
    
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableView_.tableHeaderView = headerView;
//    [headerView release];
    
    if(group_ != nil) {
        [self update];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(groupDetailsFlags_.enterGroup == 1) {
        groupDetailsFlags_.enterGroup = 0;
    }
    
    if (groupDetailsFlags_.didLoadGroupDetails == 0) {
        groupDetailsFlags_.didLoadGroupDetails = 1;
        
        // retrieve group details info from server and update it if need
        KDQuery *query = [KDQuery queryWithName:@"group_id" value:group_.groupId];
        
        __block GroupInfoViewController *givc = self;// retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if(results != nil){
                KDGroup *group = results;
                givc.group = group;
                
                [givc update];
                [givc.tableView reloadData];
                
                // update group
                [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                    id<KDGroupDAO> groupDAO = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
                    [groupDAO saveGroups:@[group] database:fmdb rollback:rollback];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
            
            // release current view controller
//            [givc release];
        };

        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/group/:details" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 0x02;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0x01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];// autorelease];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init] ;//autorelease];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = KD_GROUP_INFO_CELL_MIN_HEIGHT;
    if(indexPath.section == 0x00) {
        if (group_.bulletin.length >0) {
            CGSize size = KD_GROUP_INFO_SUBTITILE_SIZE(group_.bulletin);
            height+= (size.height + KD_GROUP_INFO_CELL_SUBTITLE_TOP_MARIGN + KD_GROUP_INFO_CELL_SUBTITLE_BUTTOM_MARGIN);
        }
    }
    
    return height;
}
- (UITableViewCell *) tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDGroupDetailsCell *cell = (KDGroupDetailsCell *)[tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[KDGroupDetailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    
    if(0 == indexPath.section){
        cell.titleLabel.text = ASLocalizedString(@"GroupInfoViewController_tips_1");
        cell.iconImageView.image = [UIImage imageNamed:@"group_notice"];
        if (group_.bulletin.length >0) {
            cell.subTitleLabel.text = group_.bulletin;
            cell.subTitleLabelNeedDisplay = YES;
                   }else {
            cell.subTitleLabel.text = nil;
                       cell.subTitleLabelNeedDisplay = NO;
        }
        cell.cellAccessoryNeedDisplay = NO;
    } else if(1 == indexPath.section ){
        cell.titleLabel.text = ASLocalizedString(@"GroupInfoViewController_tips_2");
        cell.iconImageView.image = [UIImage imageNamed:@"group_member"];
        cell.subTitleLabelNeedDisplay = NO;
        cell.cellAccessoryNeedDisplay = YES;
    }
    
    return  cell;   
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0x01 == indexPath.section) {
        groupDetailsFlags_.enterGroup = 1;
        
        GroupUserController *guc = [[GroupUserController alloc] initWithNibName:nil bundle:nil];
        guc.group = group_;
        
        [self.navigationController pushViewController:guc animated:YES];
//        [guc release];
    }
}

- (void) update {
    groupAvatarView_.avatarImageURL = group_.getAvatarLoadURL;
    
    //introLabel_.text = group_.description;
    introLabel_.text = group_.summary;
}

- (void) setGroup:(KDGroup *)group {
    if(group_ != group){
//        [group_ release];
        group_ = group;// retain];
        
        self.navigationItem.title = group_.name;
    }
}

- (KDGroup *)group {
    return group_;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(groupDetailsFlags_.enterGroup == 0){
        [[KDRequestDispatcher globalRequestDispatcher] cancelRequestsWithAPIIdentifier:KDAPITrends];
    }
}

//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
    //[[KDRequestDispatcher globalRequestDispatcher] cancelRequestsForReceiveTypeWithDelegate:self];
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(groupAvatarView_);
    //KD_RELEASE_SAFELY(introLabel_);
    //KD_RELEASE_SAFELY(tableView_);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(group_);
    
    //KD_RELEASE_SAFELY(groupAvatarView_);
    //KD_RELEASE_SAFELY(introLabel_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //[super dealloc];
}

@end
