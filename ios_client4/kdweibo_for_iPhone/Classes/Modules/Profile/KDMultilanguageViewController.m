//
//  KDMultilanguageViewController.m
//  kdweibo
//
//  Created by wenjie_lee on 16/3/30.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDMultilanguageViewController.h"
#import "KDMultilanguageTableViewCell.h"
#import "XTOpenSystemClient.h"
#import "KDApplicationQueryAppsHelper.h"
#import "URL+MCloud.h"
#import "BOSSetting.h"
#import "XTSetting.h"

static NSString * const typeName[]  = {@"简体中文",@"English"};

@interface KDMultilanguageViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    UIView *_toolBarView;
    NSIndexPath *_selectedIndexPath;

}
@property (nonatomic,strong) NSIndexPath *oldIndexPath;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) XTOpenSystemClient *client;
@end

@implementation KDMultilanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = ASLocalizedString(@"Multilanguage");
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:ASLocalizedString(@"KDABActionTabBar_tips_2")style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItems = @[rightBarButton];
    
    NSInteger row = 0;
    [[NSUserDefaults standardUserDefaults] valueForKey:AppLanguage];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:AppLanguage] hasPrefix:@"en"]) {
        row = 1;
    }
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _tableView = [[UITableView alloc]initWithFrame:frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:_tableView];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
   [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"refreshMainView"];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    KDMultilanguageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDMultilanguageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.label.text = typeName[indexPath.row];
    
//    if (_selectedIndexPath == nil) {
//        
//    }
    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row)
    {
        //         cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.accessoryImageView setImage:[UIImage imageNamed:@"common_tip_check"]];
    }
    else
    {
        //         cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.accessoryImageView setImage:nil];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.oldIndexPath = self.selectedIndexPath;
    self.selectedIndexPath = indexPath;
    [_tableView reloadRowsAtIndexPaths:@[self.oldIndexPath,self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)save
{
    NSInteger row = self.selectedIndexPath.row;
    NSString *key = nil;
    switch (row) {
        case 0: {
            key = @"zh";
        }
            break;
        case 1: {
             key = @"en";
        }
            break;
        default:
            break;
    }
//    //用于刷新主界面
//    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"refreshMainView"];
//    
//    if ([key isEqualToString:@"en"]) {
//        [[NSUserDefaults standardUserDefaults] setObject:key forKey:AppLanguage];
//    }else
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
//    }
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeLanguage" object:nil];
//    [self.navigationController popViewControllerAnimated:YES];

    [self changeLanguage:key];
}
- (void)changeLanguage:(NSString *)key
{
    NSString *path = MCLOUD_IP_FOR_PUBACC;
    path = [path stringByAppendingString:@"openaccess/rest/lanage/resetResource"];
    NSURL *pathUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    [request setValue:[BOSConnect userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"userName=%@&languageKey=%@&ua=%@",[BOSSetting sharedSetting].userName, key,[BOSConnect userAgent]]dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data];
        if ([[result objectForKey:@"success"] boolValue]) {
            //用于刷新主界面
//            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"refreshMainView"];
            
            //重新拉消息列表数据
            [XTSetting sharedSetting].updateTime = @"";
            if ([[result objectForKey:@"data"] isEqualToString:@"en"]) {
                 [[NSUserDefaults standardUserDefaults] setObject:key forKey:AppLanguage];
            }else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
            }
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"changeLanguage" object:nil];
//            [self.navigationController popViewControllerAnimated:YES];
//            BOOL show =[[[NSUserDefaults standardUserDefaults] valueForKey:@"refreshMainView"] boolValue];
//            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"refreshMainView"] boolValue]) {
                [[KDWeiboAppDelegate getAppDelegate] resetMainView];
//                [[NSUserDefaults standardUserDefaults]setValue:@"0" forKey:@"refreshMainView"];
//            }
        }else
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:NO].mode = ASLocalizedString(@"JSBridge_Tip_6");
        }
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
