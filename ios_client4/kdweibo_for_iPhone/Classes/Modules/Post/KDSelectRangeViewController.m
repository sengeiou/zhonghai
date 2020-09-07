//
//  KDSelectRangeViewController.m
//  kdweibo
//
//  Created by kingdee on 16/5/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSearchBar.h"
#import "KDSelectRangeViewController.h"
#import "KDWeiboServicesContext.h"
#import "GroupCellView.h"
#import "MBProgressHUD.h"
#import "KDErrorDisplayView.h"
#import "KDNotificationView.h"
#import "UIView+Blur.h"
#import "PostViewController.h"
#import "KDDefaultViewControllerContext.h"

@interface KDSelectRangeViewController ()<KDSearchBarDelegate,UIAlertViewDelegate> {
    BOOL isCompanySeleted;
}
@property(nonatomic,retain)UITableViewCell *companyCell;
@property(nonatomic,retain)UITableViewCell *groupCell;
@property(nonatomic,retain)KDSearchBar *searchBar;
@property(nonatomic,retain)NSArray *filteredGroups;
@property(nonatomic,retain)UITableViewCell *noSearchResultCell;
@property(nonatomic,retain)NSMutableArray *groups; // 保存选中的小组
@property(nonatomic,retain)NSMutableArray *unGroups;
@property(nonatomic,retain)NSMutableArray *allGroups;
@property(nonatomic,retain)UITableView *tableView;
@end

@implementation KDSelectRangeViewController
@synthesize companyCell = companyCell_;
@synthesize groupCell = groupCell_;
@synthesize searchBar = searchBar_;
@synthesize noSearchResultCell = noSearchResultCell_;
@synthesize groups = groups_;
@synthesize filteredGroups = fileteredGroups_;
@synthesize unGroups = unGroups_;
@synthesize allGroups = allGroups_;
@synthesize tableView = tableView_;

- (void)dealloc {
    //[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UITableViewCell *)companyCell {
    if (!companyCell_) {
        companyCell_ = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        companyCell_.backgroundColor = [UIColor kdBackgroundColor2];//MESSAGE_CT_COLOR;
        companyCell_.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_in_share_company"]];// autorelease];
        [imageView sizeToFit];
        CGRect frame = imageView.frame;
        frame.origin.x = 10;
        frame.origin.y = (CGRectGetHeight(companyCell_.bounds) - CGRectGetHeight(frame))*0.5;
        imageView.frame = frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [companyCell_.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];// autorelease];
        label.text = ASLocalizedString(@"KDSignInSettingViewController_group_name");
        label.textColor = MESSAGE_TOPIC_COLOR;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:17.0f];
        [label sizeToFit];
        frame = label.frame;
        frame.origin.x = CGRectGetMaxX(imageView.frame) +12;
        frame.origin.y = (CGRectGetHeight(companyCell_.bounds) - CGRectGetHeight(frame))*0.5;
        label.frame = frame;
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [companyCell_.contentView addSubview:label];
        
        UIImageView *accesoryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];// autorelease];
        companyCell_.accessoryView = accesoryImageView;
    }
    return companyCell_;
}

-(UITableViewCell *)groupCell {
    if (!groupCell_) {
        groupCell_ = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        groupCell_.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(236.f, 236.f, 236.f);
        groupCell_.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];/// autorelease];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.backgroundColor = [UIColor clearColor];
        label.text = ASLocalizedString(@"DraftTableViewCell_tips_1");
        label.textColor = MESSAGE_DATE_COLOR;
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin.x = 10.f;
        frame.origin.y = (CGRectGetHeight(groupCell_.bounds) - CGRectGetHeight(frame))*0.5;
        label.frame = frame;
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [groupCell_ addSubview:label];
    }
    return groupCell_;
}

- (NSMutableArray *)groups {
    if (!groups_) {
        groups_ = [[NSMutableArray alloc] init];
    }
    return groups_;
}
- (NSMutableArray *)unGroups {
    if (!unGroups_) {
        unGroups_ = [[NSMutableArray alloc] init];
    }
    return unGroups_;
}
- (NSMutableArray *)allGroups {
    if (!allGroups_) {
        allGroups_ = [[NSMutableArray alloc] init];
    }
    return allGroups_;
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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = ASLocalizedString(@"KDSelectRangeViewController_title");
        isCompanySeleted = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DLog(@"didScrollView....");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _searchBarResignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];//MESSAGE_BG_COLOR;
    tableView.backgroundColor = [UIColor kdBackgroundColor1];//MESSAGE_BG_COLOR;
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0.0, 0.0, 61.0, 32.0);
    [sendButton setTitleColor:[UIColor kdTextColor5] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [sendButton setTitle:ASLocalizedString(@"Global_Sure")forState:UIControlStateNormal];
    [sendButton sizeToFit];
    [sendButton addTarget:self action:@selector(confirmRange:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];
    
    [self reloadDataSource];
    
}

- (void)confirmRange:(id)sender {
    KDGroup *selectGroup = [[KDGroup alloc] init];
    if ([self.groups count] > 0) {
        selectGroup = [self.groups lastObject];
        
    } else {
        selectGroup.groupId = nil;
        selectGroup.name = nil;
        selectGroup.profileImageURL = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RangeUpdated" object:selectGroup];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadDataSource{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block KDSelectRangeViewController *weakSelf = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSString *errorMessage = nil;
        BOOL success = NO;
        if(results) {
            NSDictionary *returnDic = results;
            success = [(NSNumber *)[returnDic objectForKey:@"success"] boolValue];
            if (success) {
                NSMutableArray *theGroups = [returnDic objectNotNSNullForKey:@"groups"];
                if (theGroups) {
                    //                    [weakSelf.groups addObjectsFromArray:theGroups];
                    [weakSelf.allGroups addObjectsFromArray:theGroups];
                }
                
                NSMutableArray *theUngroups = [returnDic objectNotNSNullForKey:@"unGroups"];
                if (theUngroups) {
                    //                    [weakSelf.unGroups addObjectsFromArray:theUngroups];
                    [weakSelf.allGroups addObjectsFromArray:theUngroups];
                }
                weakSelf.filteredGroups = weakSelf.allGroups;
                [weakSelf.tableView reloadData];
            }else {
                errorMessage = [returnDic objectForKey:@"errorMessage"];
            }
        }else {
            errorMessage = [[response responseDiagnosis] networkErrorMessage];
        }
        if (!success) {
            [KDErrorDisplayView showErrorMessage:errorMessage inView:weakSelf.view.window];
        }
        if ([weakSelf.view superview]) {
            [[MBProgressHUD HUDForView:self.view] hide:YES];
        }
//        [weakSelf release];
    };
    
    [KDServiceActionInvoker invokeWithSender:weakSelf actionPath:@"/signId/:getSelectedAndDeSelectedGroups" query:nil
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    
    if (section == 2) {
        if (!searchBar_) {
            searchBar_ = [[KDSearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 49.5)];
            searchBar_.delegate = self;
            searchBar_.placeHolder = ASLocalizedString(@"SignInShareRangeViewController_searchBar_placeHolder");
            searchBar_.showsCancelButton = NO;
            [searchBar_ addBorderAtPosition:KDBorderPositionBottom | KDBorderPositionTop];
        }
        return searchBar_;
    }else if (section == 1) {
        UIImage *image  = [UIImage imageNamed:@"sign_in_range_section"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width *0.5 topCapHeight:image.size.height *0.5];
        UIImageView  *imageView = [[UIImageView alloc] initWithImage:image];// autorelease];
        view = imageView;
    }
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 1) {
        height = 0;
    }else if (section == 2) {
        height = 49.5;
    }
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    if (indexPath.section == 0) {
        height = 60;
    }else if(indexPath.section == 1){
        height = 25;
    }else {
        if ([self.filteredGroups count] >0) {
            height = 60;
        }else {
            height = 44;
        }
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return  1;
        case 1:
            return 1;
        case 2:
            return [self.filteredGroups count];
        default:
            return 0;
            
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIImageView *imageView = (UIImageView *)cell.accessoryView;
        imageView.frame = CGRectMake(0, 0, 22, 22);
        if (isCompanySeleted) {
            imageView.image = [UIImage imageNamed:@"choose_circle_n"];
            
        }else {
            imageView.image = [UIImage imageNamed:@"choose-circle-o"];
            
        }
        //[imageView sizeToFit];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            cell  = [self companyCell];
            break;
        case 1:
            cell = [self groupCell];
            break;
        case 2: {
            static NSString *identifier1 = @"cell";
            
            id object = [self.filteredGroups objectAtIndex:indexPath.row];
            if([object isKindOfClass:[NSNull class]]) {
                cell = [self noSearchResultCell];
            }else {
                cell = (GroupCellView *)[tableView dequeueReusableCellWithIdentifier:identifier1];
                if(!cell) {
                    cell = [[GroupCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];// autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    ((GroupCellView *)cell).cellAccessoryImageView.hidden = YES;
                    ((GroupCellView *)cell).separatorLineInset = UIEdgeInsetsMake(0, 52, 0, 0);
                }
                KDGroup *group =  object;
                ((GroupCellView *)cell).group = group;
                if ([self.groups containsObject:group]) {
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
            
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        isCompanySeleted = YES;
        if (isCompanySeleted) {
            [self.groups removeAllObjects];
        }
    }else {
        if (indexPath.section == 2) {
            if (isCompanySeleted) {
                isCompanySeleted = NO;
            }
            
            KDGroup *group = [self.filteredGroups objectAtIndex:indexPath.row];
            [self.groups removeAllObjects];
            [self.groups addObject:group];
        }
    }
    
    [tableView reloadData];
}

- (void)showWarning {
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDSignInSettingViewController_notificationView_message")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:ASLocalizedString(@"Global_Cancel"), nil];
    [alerView show];
//    [alerView release];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        isCompanySeleted = YES;
        [tableView_ reloadData];
    }
}

#pragma mark -
#pragma mark KDSearchBar delegate methods
- (void)searchBarTextDidBeginEditing:(KDSearchBar *)searchBar {
    
}

- (void)searchBarTextDidEndEditing:(KDSearchBar *)searchBar {
    
}

- (void)searchBar:(KDSearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        searchBar.text = @"";
        
        self.filteredGroups = self.allGroups;
        [tableView_ reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView reloadData];
        //[self _searchBarResignFirstResponder];
    }
}
- (void)_searchBarResignFirstResponder {
    if ([searchBar_ isFirstResponder] && [searchBar_ canResignFirstResponder]) {
        [searchBar_ resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(KDSearchBar *)searchBar {
    
    /*
     点击搜索时，去掉maskview
     */
    [self keyboardWillHide:nil];
    
    if ([self search:searchBar.text]) {
        [self _searchBarResignFirstResponder];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)search:(NSString *)text {
    BOOL succes = NO;
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length == 0) {
        return succes;
    }
    
    NSArray *array = [self.allGroups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS %@",text]];
    if (array && [array count] >0) {
        self.filteredGroups = [NSMutableArray arrayWithArray:array];
        succes = YES;
    }else {
        self.filteredGroups = [NSMutableArray arrayWithObject:[NSNull null]];
    }
    return succes;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];// autorelease];
    view.backgroundColor = [UIColor clearColor];
    view.tag = 100;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapped:)];
    [view addGestureRecognizer:gr];
    [self.view addSubview:view];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIView *mask = [self.view viewWithTag:100];
    if (mask) {
        [mask removeFromSuperview];
    }
}
- (void)maskTapped:(UITapGestureRecognizer *)gr {
    [self _searchBarResignFirstResponder];
}
@end
