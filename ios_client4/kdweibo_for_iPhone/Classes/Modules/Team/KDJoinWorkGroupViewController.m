//
//  KDJoinWorkGroupViewController.m
//  kdweibo
//
//  Created by bird on 14-9-23.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDJoinWorkGroupViewController.h"
#import "KDCrookTitleSelectCell.h"
#import "XTCompanyDelegate.h"
#import "XTOpenSystemClient.h"
#import "BOSSetting.h"
#import "NSDictionary+Additions.h"
#import "MBProgressHUD.h"

@interface KDJoinWorkGroupViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) XTOpenSystemClient *openSystemClient;
@end

@implementation KDJoinWorkGroupViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.navigationItem.title = ASLocalizedString(@"KDJoinWorkGroupViewController_my_com");
        
        [KDWeiboAppDelegate setExtendedLayout:self];
    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_openSystemClient);
    //KD_RELEASE_SAFELY(_datas);
    //KD_RELEASE_SAFELY(_tableView);
    //[super dealloc];
}
- (void)loadView
{
    [super loadView];
    
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = view;
//    [view release];
    self.view.backgroundColor = MESSAGE_BG_COLOR;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.view.bounds), 122.f);
    CGRect rect = self.view.bounds;
    rect.origin.y = rect.size.height - 122.f- self.navigationController.navigationBar.bounds.size.height;
    rect.size = CGSizeMake(290.f, 40.f);
    rect.origin.x = (size.width - rect.size.width)*0.5f;
    
   
    
    CGRect frame = self.view.bounds;
    frame.size.height -= 122.f;
    frame.origin.y+=64;
    // comments table view
    UITableView *aTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    aTableView.backgroundColor = MESSAGE_BG_COLOR;
    aTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:aTableView];
    self.tableView = aTableView;
//    [aTableView release];
//    
    [aTableView reloadData];
    
    if ([aTableView contentSize].height < aTableView.bounds.size.height - 60.f) {
        
        rect.origin.y -= 30.f;
        
    }
    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinButton setBackgroundColor:UIColorFromRGB(0x1a85ff)];
    [joinButton setTitle:ASLocalizedString(@"KDJoinWorkGroupViewController_look")forState:UIControlStateNormal];
    [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    joinButton.frame = rect;
//    [self.view addSubview:joinButton];
    
    rect.origin.y = CGRectGetMaxY(rect) +10.f;
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createButton setBackgroundColor:MESSAGE_CT_COLOR];
    [createButton setTitleColor:UIColorFromRGB(0x1a85ff) forState:UIControlStateNormal];
    [createButton setTitle:ASLocalizedString(@"KDJoinWorkGroupViewController_create_com")forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(goToCreateView) forControlEvents:UIControlEventTouchUpInside];
    createButton.frame = rect;
//    [self.view addSubview:createButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)joinButtonClick:(id)sender{
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    self.openSystemClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(joinCompanyDidReceived:result:)];// autorelease];
    [self.openSystemClient joinToDefaultCompany:[BOSSetting sharedSetting].userName];
    
}
- (void)joinCompanyDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result{

    [MBProgressHUD hideHUDForView:self.view.window animated:YES];
    
    if (client.hasError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
//        [alert release];
        
        self.openSystemClient = nil;
        
        return;
    }
    
    self.openSystemClient = nil;
    
    if (result.success)
    {
        if (result.errorCode == 7001) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            
            return;
        }
        
        NSDictionary *data = result.data;
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *eid = [data stringForKey:@"eid"];
            if ([eid length] == 0) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDJoinWorkGroupViewController_join_fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
//                [alert release];
            }
            else{
            
                if (_delegate && [_delegate respondsToSelector:@selector(joinWorkGroupViewDidJoinCompany:)]) {
                    [_delegate joinWorkGroupViewDidJoinCompany:eid];
                }
            }
        }
        else{
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"KDJoinWorkGroupViewController_join_fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
//            [alert release];
            
        }
        
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alert show];
//    [alert release];
}
- (void)goToCreateView{
    if (_delegate && [_delegate respondsToSelector:@selector(joinWorkGroupViewDidCreateCompany)]) {
        [_delegate joinWorkGroupViewDidCreateCompany];
    }
}
#pragma mark - UITableViewDataSource and UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 265.f;
    }
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        static NSString *HeaderViewCellIdentifier = @"HeaderViewCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderViewCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HeaderViewCellIdentifier"];// autorelease];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 155)] ;//autorelease];
            headerView.backgroundColor = [UIColor clearColor];
            
            UIImageView *cloudImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud"]];
            [cloudImageView sizeToFit];
            cloudImageView.center = CGPointMake(CGRectGetMidX(headerView.bounds), CGRectGetHeight(cloudImageView.bounds)*0.5f + 15.f);
            [headerView addSubview:cloudImageView];
//            [cloudImageView release];
            
            UIFont *font = [UIFont systemFontOfSize:15.f];
//            NSString *infoString = [NSString stringWithFormat:ASLocalizedString(@"还没有可以登录的工作圈。\n建议你先随便看看，体验一下，也可以创建一个新的工作圈，邀请同事一起加入。\n%@，和同事一起使用才有趣。"),KD_APPNAME];
            NSString *infoString = ASLocalizedString(@"KDJoinWorkGroupViewController_account_cancel");
            CGSize size = [infoString sizeWithFont:font constrainedToSize:CGSizeMake(CGRectGetWidth(tableView.bounds) - 2*20.f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(cloudImageView.frame) +7.f, ScreenFullWidth, size.height)] ;///；autorelease];
            headerLabel.numberOfLines = 0;
            headerLabel.textColor = MESSAGE_NAME_COLOR;
            headerLabel.font = font;
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.text = infoString;
            headerLabel.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:headerLabel];
            
            CGRect rect = headerLabel.frame;
            rect.origin.y = CGRectGetMaxY(rect) + 22.f;
            rect.size.height = 23.f;
            
            UILabel *wLabel = [[UILabel alloc] initWithFrame:rect];// autorelease];
            wLabel.textColor = MESSAGE_NAME_COLOR;
            wLabel.font = [UIFont systemFontOfSize:14.f];
            wLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:wLabel];
            wLabel.text = ASLocalizedString(@"KDJoinWorkGroupViewController_tips_2");
            
            wLabel.hidden = _datas.count == 0;
            
            rect = headerView.frame;
            rect.size.height = CGRectGetMaxY(wLabel.frame);
            headerView.frame = rect;
            
            [cell addSubview:headerView];
        }
        
        return cell;
        
    }
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    KDCrookTitleSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[KDCrookTitleSelectCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier];// autorelease];
    }
    
    XTOpenCompanyDataModel *company = [_datas objectAtIndex:indexPath.row -1];
    [cell hideCrookView:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.titleLabel.text            = company.companyName;
    cell.companyIdLabel.text        = company.companyId;
    
    return cell;
}
@end
