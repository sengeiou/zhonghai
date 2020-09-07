//
//  KDTaskShareViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-7-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskShareViewController.h"
#import "KDSearchBar.h"
#import "KDWeiboServicesContext.h"
#import "KDDatabaseHelper.h"
#import "KDErrorDisplayView.h"
#import "KDGroup.h"
#import "GroupCellView.h"
#import "KDAvatarView.h"
#import "UIViewAdditions.h"

@interface KDTaskShareCell : UITableViewCell
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UIImageView *tickImageView;
@property(nonatomic,retain)UILabel *label;
@property(nonatomic,retain)UILabel *separatorImageView;
- (void)setLabelText:(NSString *)str;
- (void)setTickImage:(UIImage *)image;
- (void)updateSelection:(NSDictionary *)dic;
@end

@implementation KDTaskShareCell
@synthesize tickImageView = tickImagView_;
@synthesize label = label_;
@synthesize iconImageView = iconImageView_;
@synthesize separatorImageView = separatorImageView_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconImageView_.layer.cornerRadius = 6;
        iconImageView_.layer.masksToBounds = YES;
        [self addSubview:iconImageView_];
        
        tickImagView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose_circle_n"]];
        [tickImagView_ sizeToFit];
        [self addSubview:tickImagView_];
        label_ = [[UILabel alloc] initWithFrame:CGRectZero];
        label_.backgroundColor = [UIColor clearColor];
        label_.textColor = MESSAGE_TOPIC_COLOR;
        label_.font = [UIFont systemFontOfSize:16.0f];
        [self addSubview:label_];
        
//        separatorImageView_ = [[UILabel alloc] initWithFrame:CGRectZero];
//        separatorImageView_.backgroundColor = MESSAGE_LINE_COLOR;
//        [self addSubview:separatorImageView_];
        
//        self.backgroundView = [UIView strokeCellSeparatorBgView];
//        self.backgroundView.backgroundColor = [UIColor kdBackgroundColor2];
    }
    return self;
}

- (void)updateSelection:(NSDictionary *)dic {
    [self setTickImage:[UIImage imageNamed:@"choose-circle-o"]];
    if (dic && [dic count]>0) {
        NSString *str = [dic objectForKey:@"range"];
        if ([str isEqualToString:label_.text]) {
            [self setTickImage:[UIImage imageNamed:@"choose_circle_n"]];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame ;
    
    if (tickImagView_.image) {
        frame = tickImagView_.frame;
        frame.origin.x = 15;
        frame.origin.y = (self.bounds.size.height - 22)/2.0;
        frame.size.height = 22;
        frame.size.width = 22;
        tickImagView_.frame = frame;
    }
    
    if (iconImageView_.image) {
        frame = tickImagView_.frame;
        frame.size = iconImageView_.image.size;
        frame.origin.x = CGRectGetMaxX(tickImagView_.frame) + 15;
        frame.origin.y = (self.bounds.size.height - frame.size.height)/2.0;
        iconImageView_.frame = frame;
    }
    
   
   
    if (label_.text) {
        frame = label_.frame;
        frame.size.width = MIN(222, CGRectGetWidth(frame));
        frame.size.height = 22.0;
        frame.origin.x = CGRectGetMaxX(iconImageView_.frame) +15;
        frame.origin.y  = (self.bounds.size.height - frame.size.height)/2.0;
        label_.frame = frame;
    }
    
    //separatorImageView_.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-0.5, self.bounds.size.width, 0.5);
}

- (void)setLabelText:(NSString *)str {
    label_.text = str;
    [label_ sizeToFit];
    [self setNeedsLayout];
}

- (void)setTickImage:(UIImage *)image {
    tickImagView_.image = image;
    [self setNeedsLayout];
}


- (void)dealloc {
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(tickImagView_);
    //KD_RELEASE_SAFELY(label_);
    ////KD_RELEASE_SAFELY(separatorImageView_);
    //[super dealloc];
}

@end

@interface KDTaskShareViewController ()<UITableViewDataSource,UITableViewDelegate,KDSearchBarDelegate> {
    BOOL isLoading;
    BOOL didUnload;
    NSInteger currentSelected;
}
@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)KDTaskShareCell *privateCell;
@property(nonatomic,retain)KDTaskShareCell *companyCell;
@property(nonatomic,retain)KDTaskShareCell *groupCell;
@property(nonatomic,retain)KDSearchBar *searchBar;
@property(nonatomic,retain)NSArray *groups;
@property(nonatomic,retain)NSArray *filteredgroups;
@property(nonatomic,retain)UITableViewCell *noSearchResultCell;

@end

@implementation KDTaskShareViewController
@synthesize tableView = tableView_;
@synthesize privateCell = privateCell_;
@synthesize companyCell = companyCell_;
@synthesize searchBar = searchBar_;
@synthesize groupCell = groupCell_;
@synthesize groups = groups_;
@synthesize filteredgroups = filteredgroups_;
@synthesize noSearchResultCell = noSearchResultCell_;
@synthesize shareRangeDic = shareRangeDic_;
@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initianavlization
        currentSelected = NSNotFound;
    }
    return self;
}

- (KDTaskShareCell *)privateCell {
    if (!privateCell_) {
        privateCell_ = [[KDTaskShareCell alloc] initWithFrame:CGRectZero];
        privateCell_.iconImageView.image = [UIImage imageNamed:@"task_share_private"];
        [privateCell_ setLabelText:ASLocalizedString(@"KDCreateTaskViewController_private")];
        
    }
    return privateCell_;
}

- (KDTaskShareCell *)companyCell {
    if (!companyCell_) {
        companyCell_ = [[KDTaskShareCell alloc] initWithFrame:CGRectZero];
        companyCell_.iconImageView.image = [UIImage imageNamed:@"task_share_company"];
        [companyCell_ setLabelText:ASLocalizedString(@"KDSignInSettingViewController_group_name")];
    }
    return companyCell_;
}

- (KDTaskShareCell *)groupCell {
    if (!groupCell_) {
        groupCell_ = [[KDTaskShareCell alloc] initWithFrame:CGRectZero];
        [groupCell_ setLabelText:ASLocalizedString(@"DraftTableViewCell_tips_1")];
    }
    return groupCell_;
}

- (UITableViewCell *)noSearchResultCell {
    if (!noSearchResultCell_) {
        noSearchResultCell_ = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        noSearchResultCell_.textLabel.textAlignment = NSTextAlignmentCenter;
        noSearchResultCell_.textLabel.font = [UIFont systemFontOfSize:15];
        noSearchResultCell_.textLabel.text = ASLocalizedString(@"KDTaskShareViewController_noSearchResultCell_textLabel_text");
    }
    
    return noSearchResultCell_;
}

- (NSArray *)groups {
    if (!groups_) {
        groups_ = [[NSArray alloc] init];
    }
    return groups_;
}

- (NSArray *)filteredgroups {
    if (!filteredgroups_) {
        filteredgroups_ = [[NSArray alloc] init];
    }
    return filteredgroups_;
}

- (void)loadView {
    [super loadView];
    tableView_ = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView_.dataSource = self;
    tableView_.delegate = self;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView_.backgroundColor = [UIColor clearColor];
    //隐藏风格线
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView_ setTableFooterView:view];
    [tableView_ setTableHeaderView:view];
    [self.view addSubview:tableView_];
    
    
    
    self.title = ASLocalizedString(@"KDCreateTaskViewController_share_scope");
}






- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.privateCell.selected = YES;
    if (!didUnload) {
        if (self.shareRangeDic) {
            NSString *str = [self.shareRangeDic objectForKey:@"range"];
            if ([str isEqualToString:ASLocalizedString(@"DraftTableViewCell_tips_1")]) {
                //[self restoreGroupList];
            }
        }
    }
    [self restoreGroupList];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    didUnload = YES;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 2;
    }else {
        row = [self.filteredgroups count];
    }
    return row;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"identifier1";
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell = [self privateCell];
                break;
             case 1:
                cell  = [self companyCell];
                break;
             case 2:
                cell = [self groupCell];
                break;
            default:
                break;
        }
        [(KDTaskShareCell *)cell  updateSelection:self.shareRangeDic];
    }else {
        
        id object = [self.filteredgroups objectAtIndex:indexPath.row];
        if([object isKindOfClass:[NSNull class]]) {
            cell = [self noSearchResultCell];
        }else {
            cell = (GroupCellView *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            if(!cell) {
                cell = [[GroupCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];// autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [(GroupCellView *)cell cellAccessoryImageView].hidden = YES;
            }
            KDGroup *group =  object;
            ((GroupCellView *)cell).group = group;
            KDGroup *theGroup = [self.shareRangeDic objectForKey:@"group"];
            if ([group.groupId isEqualToString:theGroup.groupId]) {
                    [(GroupCellView *)cell tickImageView].image = [UIImage imageNamed:@"choose_circle_n"];
                }else {
                    [(GroupCellView *)cell tickImageView].image = [UIImage imageNamed:@"choose-circle-o"];
                }
            if(!tableView.dragging && !tableView.decelerating){
                if(!((GroupCellView *)cell).avatarView.hasAvatar && !((GroupCellView *)cell).avatarView.loadAvatar){
                    [((GroupCellView *)cell).avatarView setLoadAvatar:YES];
                }
            }
        }
    }

    return cell;
    
}

- (void)_searchBarResignFirstResponder {
    if ([searchBar_ isFirstResponder] && [searchBar_ canResignFirstResponder]) {
        [searchBar_ resignFirstResponder];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = 60;
    }else {
        if ([self.filteredgroups count] >0) {
            height = 60;
        }else {
            height = 0;
        }
        
    }
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        height = 12;
    }else {
        if ([self.filteredgroups count] >0) {
            height = 75;
        }else {
            height = 0;
        }
    
    }
       return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if(section == 0)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 12)];
        bgView.backgroundColor = [UIColor kdBackgroundColor1];
        return bgView;
    }
    if (filteredgroups_ && [filteredgroups_ count] >0) {
        if (section == 1) {
            if (!searchBar_) {
                searchBar_ = [[KDSearchBar alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(tableView.bounds), 50.0f)];
                searchBar_.delegate = self;
                searchBar_.showsCancelButton = NO;
            }
            if (!searchBar_.superview) {
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(tableView.bounds), 50+25)];// autorelease];
                [bgView setBackgroundColor:[UIColor kdBackgroundColor1]];
                [bgView addSubview:searchBar_];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, CGRectGetHeight(tableView.bounds), 23)];
                label.textColor = MESSAGE_NAME_COLOR;
                label.font = [UIFont systemFontOfSize:14.0f];
                label.backgroundColor = [UIColor clearColor];
                label.text = ASLocalizedString(@"KDTaskShareViewController_Group");
                //label.layer.borderColor = MESSAGE_LINE_COLOR.CGColor;
                //label.layer.borderWidth = 0.5;
                [bgView addSubview:label];
//                [label release];
                
            }

            return searchBar_.superview;
        }
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"sssss = %d",indexPath.row);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"ddddd");
    NSDictionary *shareDic = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                shareDic = @{@"range":ASLocalizedString(@"KDCreateTaskViewController_private")};
                break;
              case 1:
                shareDic = @{@"range":ASLocalizedString(@"KDSignInSettingViewController_group_name")};
                break;
            case 2: {
                shareDic = @{@"range":ASLocalizedString(@"DraftTableViewCell_tips_1")};
//                [self restoreGroupList];
                self.shareRangeDic = shareDic;
                [tableView reloadData];
                return;
            }
                break;
            default:
                break;
        }
//        self.groups = nil;
//        self.filteredgroups = nil;
    }else if(indexPath.section == 1) {
        KDGroup *group = [filteredgroups_ objectAtIndex:indexPath.row];
        if([group isKindOfClass:[NSNull class]])
            return;
        else
            shareDic = @{@"range": ASLocalizedString(@"DraftTableViewCell_tips_1"),@"group":group};
     }
       if (!shareDic) {
           return;
       }
        self.shareRangeDic = shareDic;
        if (delegate_ && [delegate_ respondsToSelector:@selector(tashShareRangeDidSelected:) ]){
            [delegate_ tashShareRangeDidSelected:shareDic];
        }
    [tableView_ reloadData];
    //[self.navigationController popViewControllerAnimated:YES];
}


- (void)restoreGroupList {
    if ([self.groups count] >0) {
        return;
    }
    __weak KDTaskShareViewController *tvc = self;// retain];
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDGroupDAO> groupDAO = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
        NSArray *groups = [groupDAO queryGroupsWithLimit:999 database:fmdb];
        return groups;
        
    } completionBlock:^(id results){
          tvc.groups = results;
          tvc.filteredgroups = tvc.groups;
          [tvc.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
          [tvc getGroupList];
        
        // release current view controller
//        [tvc release];
    }];
}

- (void)getGroupList {
    if(isLoading) {
        return;
    }
    KDQuery *query = [KDQuery queryWithName:@"count" value:@"999"];
    
    __block KDTaskShareViewController *tvc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        tvc->isLoading = NO;
        if ([response isValidResponse]) {
            if(results != nil){
                tvc.groups = results;
                tvc.filteredgroups = tvc.groups;
                  [tvc.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                if ([tvc.groups count] > 0) {
                    // delete status from database
                    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
                        id<KDGroupDAO> groupDAO = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
                        [groupDAO saveGroups:results database:fmdb rollback:rollback];
                        return nil;
                        
                    } completionBlock:nil];
                }
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:tvc.view.window];
            }
        }
//        [tvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/group/:joined" query:query
                                 configBlock:nil completionBlock:completionBlock];
}
///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDSearchBar delegate methods

- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar {
   
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar {
    
}

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        searchBar.text = @"";
         self.filteredgroups = self.groups;
         //[tableView_ reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView_ reloadData];
    }
}
- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    if ([self search:searchBar.text]) {
        [self _searchBarResignFirstResponder];
    }
   [tableView_ reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)search:(NSString *)text {
    BOOL succes = NO;
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length == 0) {
        return succes;
    }
    
    NSArray *array = [self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS %@",text]];
    if (array && [array count] >0) {
        self.filteredgroups = [NSMutableArray arrayWithArray:array];
        succes = YES;
    }else {
        self.filteredgroups = [NSMutableArray arrayWithObject:[NSNull null]];
    }
    return succes;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(privateCell_);
    //KD_RELEASE_SAFELY(companyCell_);
    //KD_RELEASE_SAFELY(groupCell_);
    //KD_RELEASE_SAFELY(groups_);
    //KD_RELEASE_SAFELY(filteredgroups_);
    //KD_RELEASE_SAFELY(noSearchResultCell_);
    //KD_RELEASE_SAFELY(shareRangeDic_);
    //[super dealloc];
}
@end
