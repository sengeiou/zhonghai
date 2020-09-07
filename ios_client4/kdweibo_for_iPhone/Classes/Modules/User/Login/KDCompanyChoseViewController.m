//
//  KDCompanyChoseViewController.m
//  kdweibo
//
//  Created by bird on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDCompanyChoseViewController.h"
#import "KDCrookTitleSelectCell.h"

@interface KDCompanyChoseViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic ,retain) UIView      *bottomView;
@end

@implementation KDCompanyChoseViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = ASLocalizedString(@"KDCompanyChoseViewController_choice_com");
        
//        [KDWeiboAppDelegate setExtendedLayout:self];
    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_selectedIndexPath);
    //KD_RELEASE_SAFELY(_tableView);
    //KD_RELEASE_SAFELY(_dataModel);
    
    //[super dealloc];
}
- (void)loadView
{
    [super loadView];
    
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = view;
//    [view release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    UIImage *bgImage = [UIImage imageNamed:@"phone_contact_tool_bar_bg_v3"];
    
    CGSize size = bgImage.size;

    CGRect frame = self.view.bounds;
    frame.origin.y = 0.0f;
    // comments table view
    UITableView *aTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    aTableView.backgroundColor = [UIColor kdBackgroundColor1];
    aTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:aTableView];
    self.tableView = aTableView;
//    [aTableView release];
    aTableView.contentInset = UIEdgeInsetsMake(0, 0, size.height, 0);
    
    if (_dataModel && [_dataModel.companys count]>0) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    frame.origin.y = CGRectGetHeight(frame) - size.height- NavigationBarHeight - StatusBarHeight + 62.f;
    frame.size = CGSizeMake(self.view.bounds.size.width, size.height);
    _bottomView = [[UIView alloc] initWithFrame:frame];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
//    [_bottomView release];
    
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.45f topCapHeight:bgImage.size.height * 0.45f];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.frame = CGRectMake(0, 0, frame.size.width, size.height);
    [_bottomView addSubview:bgImageView];
//    [bgImageView release];
    
    UIButton *confirmButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")];
//    confirmButton.backgroundColor = RGBACOLOR(23, 131, 253, 1.0f);
//    [confirmButton setTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = FS4;
    [confirmButton addTarget:self action:@selector(finishClick) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = CGRectMake((_bottomView.frame.size.width - 70)*0.5, (_bottomView.frame.size.height - 30)*0.5, 80, 30.f);
    [confirmButton setCircle];
    [_bottomView addSubview:confirmButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishClick
{
    if (_selectedIndexPath == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDCompanyChoseViewController_tips_choice_com")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(companyDidSelect:company:)])
    {
        [self.delegate companyDidSelect:self company:[_dataModel.companys objectAtIndex:_selectedIndexPath.row]];
    }
}
#pragma mark - UITableViewDataSource and UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _dataModel.companys.count;
    }
    return [_dataModel.authstrCompanys count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return _dataModel.authstrCompanys.count==0?0.0f:26.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 26.f)];// autorelease];
    headerLabel.textColor = MESSAGE_NAME_COLOR;
    headerLabel.font = [UIFont systemFontOfSize:13.f];
    headerLabel.backgroundColor = MESSAGE_BG_COLOR;
    if (section == 0) {
        headerLabel.text =  ASLocalizedString(@"KDCompanyChoseViewController_tips_1");
    }
    else{
        headerLabel.text =  ASLocalizedString(@"KDCompanyChoseViewController_tips_2");
    }
    
    return headerLabel;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    KDCrookTitleSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[KDCrookTitleSelectCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier];// autorelease];
    }
    
    if ([_selectedIndexPath isEqual:indexPath])
        [cell setIsSelected:YES];
    else
        [cell setIsSelected:NO];
    
    
    XTOpenCompanyDataModel *company = nil;
    if (indexPath.section == 0) {
        company = [_dataModel.companys objectAtIndex:indexPath.row];
        [cell hideCrookView:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else{
        company = [_dataModel.authstrCompanys objectAtIndex:indexPath.row];
        [cell hideCrookView:YES];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.titleLabel.text            = company.companyName;
    cell.companyIdLabel.text        = company.companyId;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        return;
    }
    
    if (![indexPath isEqual:_selectedIndexPath]) {
        self.selectedIndexPath = indexPath;
        [_tableView reloadData];
    }
}
@end
