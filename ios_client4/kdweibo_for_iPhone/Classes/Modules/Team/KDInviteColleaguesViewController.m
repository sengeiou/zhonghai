//
//  KDInviteColleaguesViewController.m
//  kdweibo
//
//  Created by 王 松 on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDInviteColleaguesViewController.h"
#import "UIImage+XT.h"
#import "UIButton+XT.h"
#import "KDInvitePhoneContactsViewController.h"
#import "KDInviteByPhoneNumberViewController.h"
#import "KDWeiboAppDelegate.h"
#import "BOSSetting.h"
#import "BOSConfig.h"
#import "KDPhoneInputViewController.h"
#import "KDInviteColleagueTableViewCell.h"
#import "KDQRCodeInvitationViewController.h"
#import "NSDictionary+Additions.h"
#import "KDLinkInvitationViewController.h"
#import "KDSocialsShareManager.h"

#define labelLeftCap 15.0
#define KD_INVITE_CLOLLEGURES_ALERTT_GET_COMPANY_COFIG   1024
#define KD_INVITE_CLOLLEGURES_ALERTT_GET_IS_ADMIN        1029


static NSString * const inviteImageNames[] = {@"menu_img_txlyaoqin",@"menu_img_sjyaoqin.png",@"invite_img_2weima"};//,@"invite_img_link"};//@"invite_img_qq2",
//static NSString * const inviteLabelNames[] = {@"通讯录邀请",@"手机号码邀请",@"面对面邀请"};//,ASLocalizedString(@"生成邀请地址"),ASLocalizedString(@"面对面邀请")};//ASLocalizedString(@"微信邀请"),ASLocalizedString(@"QQ邀请"),

@interface KDInviteColleaguesViewController ()<UIAlertViewDelegate, KDLoginPwdConfirmDelegate, UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate> {
    struct {
        int isAdmin;  //是否为当前企业的管理员
        int isInvitation; //是否可以邀请
        int isInviteApprove; //邀请是否需要管理员验证
    }_flag;
    BOOL _retryVerificateAdmin;  //是否重试调用管理员接口
}

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) KDInviteIndex selectedIndex;
@property (nonatomic, strong) XTOpenSystemClient *checkAdminClient; //检查是否为管理员
@property (nonatomic, strong) XTOpenSystemClient *getQRcodeOrLinkInviteParamClinet; //获取二维码或链接邀请权限的client
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *inviteLabelNames;

@end

@implementation KDInviteColleaguesViewController

- (void)dealloc {
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedIndex = KDInviteIndexNoDefined;
        _flag.isAdmin = -1;
        _flag.isInvitation = -1;
        _flag.isInviteApprove = -1;
        self.title = ASLocalizedString(@"KDInviteColleaguesViewController_invite_colleague");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inviteLabelNames = @[ASLocalizedString(@"KDInviteColleaguesViewController_addressbook_invite"),ASLocalizedString(@"KDInviteByPhoneNumberViewController_mobile_invite"),ASLocalizedString(@"KDInviteColleaguesViewController_facetoface_invite")];
    [self setupViews];
    // [self checkIsAdmin];
}

- (void)setupViews
{
    if(_showRightBtn)
    {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel")style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.rightBarButtonItems = @[cancelItem];
    }
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    // _tableView.backgroundColor = UIColorFromRGB(0xfafafa);
    _tableView.backgroundColor = [UIColor kdBackgroundColor1];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    //[self.view addSubview:topBarView];
    [self.view addSubview:_tableView];
    
    /////////////////////////////
    
    
    UIView *topBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    topBarView.backgroundColor = [UIColor kdBackgroundColor2];
    
    UILabel *enterpriseLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, (topBarView.frame.size.height - 18.f)/2, 300, 18)];
    enterpriseLabel.textColor = FC1;
    enterpriseLabel.font = FS5;
    NSString *enterpriseText = [NSString stringWithFormat:ASLocalizedString(@"KDInviteColleaguesViewController_current_com"),[BOSSetting sharedSetting].customerName];
    enterpriseLabel.text = enterpriseText;
    [topBarView addSubview:enterpriseLabel];
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0, CGRectGetMaxY(topBarView.frame) - 0.5, ScreenFullWidth, 0.5);
    lineLayer.backgroundColor = [UIColor kdBackgroundColor1].CGColor;
    
    [topBarView.layer addSublayer:lineLayer];
    
    //////////////////////////
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(_tableView.bounds), 70)];
    tableFooterView.backgroundColor = [UIColor kdBackgroundColor1];
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDInviteColleaguesViewController_tips1"),KD_APPNAME];
    infoLabel.font = FS5;
    infoLabel.numberOfLines = 2;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = FC1;
    
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.text = ASLocalizedString(@"KDInviteColleaguesViewController_tips_2");
    noticeLabel.numberOfLines = 0;
    noticeLabel.font = [UIFont systemFontOfSize:13];
    noticeLabel.textAlignment = NSTextAlignmentLeft;
    noticeLabel.textColor = UIColorFromRGB(0xff6600);
    
    infoLabel.frame = CGRectMake(labelLeftCap, 10.f, CGRectGetWidth(_tableView.frame) - labelLeftCap * 2 , 40);
    
    noticeLabel.frame = CGRectMake(labelLeftCap, CGRectGetMaxY(infoLabel.frame) + 20.f, CGRectGetWidth(_tableView.frame) - labelLeftCap * 2, 100.f);
    
    [tableFooterView addSubview:infoLabel];
    //去掉
    //[tableFooterView addSubview:noticeLabel];
    
    _tableView.tableHeaderView = topBarView;
    _tableView.tableFooterView = tableFooterView;
    
}


- (void)checkIsAdmin {
    _flag.isAdmin = -1;
    _flag.isInvitation = -1;
    _flag.isInviteApprove = -1;
    _isLoading = YES;
    [self showHud:YES];
    [self.checkAdminClient checkIsAdmin:[BOSConfig sharedConfig].user.openId eid:[BOSConfig sharedConfig].user.eid token:[BOSConfig sharedConfig].user.token];
}

- (XTOpenSystemClient *)checkAdminClient {
    if (!_checkAdminClient) {
        _checkAdminClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(checkAdminReceiveResultFrom:result:)];
    }
    return _checkAdminClient;
}

- (void)umengEvent:(NSString *)inviteType
{
    NSString *inviterIdentity = [self isAdmin] ? label_invite_open_inviterIdentity_admin : label_invite_open_inviterIdentity_user;
    NSString *inviteStatus = [[BOSSetting sharedSetting] isInviteApprove] ? label_invite_open_inviteStatus_needReview : label_invite_open_inviteStatus_notNeedReview;
    NSString *inviteSource = label_invite_open_inviteSource_sidebar;
    if (self.inviteSource == KDInviteSourceShortcut) {
        inviteSource = label_invite_open_inviteSource_shortcut;
    }
    else if (self.inviteSource == KDInviteSourceContact) {
        inviteSource = label_invite_open_inviteSource_contact;
    }
    NSDictionary *attributes = @{ label_invite_open_inviterIdentity: inviterIdentity, label_invite_open_inviteStatus:inviteStatus, label_invite_open_inviteSource :  inviteSource, label_invite_open_inviteType : inviteType };
    [KDEventAnalysis event:event_invite_open attributes:attributes];
}

- (void)checkAdminReceiveResultFrom:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
    _isLoading = NO;
    [self hideHud:YES];
    
    if (client.hasError || ![result isKindOfClass:[BOSResultDataModel class]] || !result.success)
    {
        return;
    }
    
    if (result.data) {
        _flag.isAdmin = [result.data boolValue]?1:0;
    }
    
    //如果重试获取管理员接口的请求
    if (_retryVerificateAdmin) {
        _retryVerificateAdmin = NO;
    }
    
    [self getQRcodeOrLinkInvitePermission];
}


- (BOOL)checkAdminError {
    return _flag.isAdmin == -1;
}

- (BOOL)isAdmin {
    return _flag.isAdmin == 1;
}

- (void)getQRcodeOrLinkInviteParams {
    if (_flag.isInvitation == -1 ||_flag.isInviteApprove == -1) {
        _isLoading = YES;
        [self showHud:YES];
        [self.getQRcodeOrLinkInviteParamClinet getCompanyConfiguration:[BOSConfig sharedConfig].user.eid token:[BOSConfig sharedConfig].user.token];
    }else {
        [self getQRcodeOrLinkInviteParamsCompletion];
    }
}

- (XTOpenSystemClient *)getQRcodeOrLinkInviteParamClinet {
    if (!_getQRcodeOrLinkInviteParamClinet) {
        _getQRcodeOrLinkInviteParamClinet = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(getQRcodeOrLinkInviteParamsCallback:result:)];
    }
    return _getQRcodeOrLinkInviteParamClinet;
}

- (void)getQRcodeOrLinkInviteParamsCallback:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
    _isLoading = NO;
    [self hideHud:YES];
    if (client.hasError)
    {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]])
    {
        return;
    }
    if (!result.success && ![result.data isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSDictionary *data = result.data;
    NSString *isInviteApprove = data[@"isInviteApprove"];
    if (!KD_IS_BLANK_STR(isInviteApprove)) {
        if ([isInviteApprove isEqualToString:@"null"])
            _flag.isInviteApprove = 0;
        else {
            _flag.isInviteApprove = [isInviteApprove intValue];
            
        }
    }
    NSString *invitation = data[@"invitation"];
    if (!KD_IS_BLANK_STR(invitation)) {
        if ([invitation isEqualToString:@"null"]) {
            _flag.isInvitation = 0;
        }else {
            _flag.isInvitation = [invitation intValue];
        }
    }
    
    [self getQRcodeOrLinkInviteParamsCompletion];
    
}

- (void)getQRcodeOrLinkInviteParamsCompletion {
    if (_flag.isInvitation == 0) { // 普通用户没有邀请权限
        [self alertNoPermission];
    }else if(_flag.isInvitation == 1) {// 普通用户可以邀请
        if (_flag.isInviteApprove == 0) { //不需要验证
            if (_selectedIndex == KDInviteIndexWeXin || _selectedIndex == KDInviteIndexQQ || _selectedIndex == KDInviteIndexContact || _selectedIndex == KDInviteIndexPhoneNum) {
                [self shareInviteLink];
            }
            else{
                [self showChooseVerificationTypeActionSheet];
            }
        }else if(_flag.isInviteApprove == 1) { //需要验证
            [self goToNextWithVerificaiton];
        }else { //错误
            [self alertNetErrorWithTag:KD_INVITE_CLOLLEGURES_ALERTT_GET_COMPANY_COFIG];
        }
    }else { //错误
        [self alertNetErrorWithTag:KD_INVITE_CLOLLEGURES_ALERTT_GET_COMPANY_COFIG];
    }
}

- (void)alertNetErrorWithTag:(NSInteger)tag {
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:ASLocalizedString(@"KDInviteColleaguesViewController_server_error")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:ASLocalizedString(@"重试"), nil];
    alert.tag = tag;
    [alert show];
    
}

- (void)alertNoPermission {
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:ASLocalizedString(@"KDInviteColleaguesViewController_tips_3")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDNotOrganizationVie_Tip_4"), nil];
    [alert show];
    alert.tag = 0x99;
}

//// 点击选择微信邀请
//- (void)inviteWeChat:(id)sender
//{
//    _selectedIndex = KDInviteIndexWeXin;
//}

// 点击选择QQ邀请
//- (void)inviteQQ:(id)sender
//{
//    _selectedIndex = KDInviteIndexQQ;
//}

// 点击电话邀请
- (void)invitePhone:(id)sender
{
    _selectedIndex = KDInviteIndexPhoneNum;
}

// 点击选择通讯录邀请
- (void)inviteContact:(id)sender
{
    _selectedIndex = KDInviteIndexContact;
}

////点击选择链接邀请
//-(void)inviteLink:(id)sender
//{
//    _selectedIndex = KDInviteIndexLink;
//}
//
//
//点击选择二维码邀请
-(void)inviteQRCode:(id)sender
{
    _selectedIndex = KDInviteIndexQRCode;
}



-(void)ContactInvite
{
    if(![self hasInvitePermisson])
    {
        return;
    }
    [self gotoContactInvite:nil];
}


- (void)phoneInvite
{
    if(![self hasInvitePermisson])
    {
        return;
    }
    [self gotoPhoneNumberInvite:nil];
}

- (void)showChooseVerificationTypeActionSheet {
    /*
     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"请选择生成的链接类型")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDInviteColleaguesViewController_tips_4"),ASLocalizedString(@"KDInviteColleaguesViewController_tips_5""), nil];
     [actionSheet showInView:self.view];
     */
    [self goToNextWithNoVerification];
}


//验证为管理员后的处理
- (void)vertifiedAsAdmin {
    
    switch (_selectedIndex) {
            //        case KDInviteIndexWeXin:  // 微信邀请
            //            [self shareInviteLink];
            //            break;
            //        case KDInviteIndexQQ:  // QQ邀请
            //            [self shareInviteLink];
            //            break;
        case KDInviteIndexContact:  // 通讯录邀请
            //            [self gotoContactInvite];
            [self shareInviteLink];
            break;
        case KDInviteIndexPhoneNum: // 手机号码邀请
            //            [self gotoPhoneNumberInvite];
            [self shareInviteLink];
            break;
        case KDInviteIndexQRCode:
        case KDInviteIndexLink:
            [self showChooseVerificationTypeActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)gotoContactInvite:(NSString *)url {
    
    [self umengEvent:label_invite_open_inviteType_contact];
    
    KDInvitePhoneContactsViewController *controller = [[KDInvitePhoneContactsViewController alloc] init];
    controller.invitedUrl = url;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)gotoPhoneNumberInvite:(NSString *)url {
    
    [self umengEvent:label_invite_open_inviteType_phone];
    
    KDInviteByPhoneNumberViewController *controller = [[KDInviteByPhoneNumberViewController alloc] init];
    controller.invitedUrl = url;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)gotoQRcodeInvitationViewController:(KDVerificationType)type {
    
    [self umengEvent:label_invite_open_inviteType_facetoface];
    
    KDQRCodeInvitationViewController * controller = [[KDQRCodeInvitationViewController alloc]init];
    controller.type = type;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)gotoLinkInvitationViewController:(KDVerificationType)type {
    
    [self umengEvent:label_invite_open_inviteType_link];
    
    KDLinkInvitationViewController * controller = [[KDLinkInvitationViewController alloc]init];
    controller.type = type;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)getQRcodeOrLinkInvitePermission {
    if ([self checkAdminError]) { //需要调用接口
        [self alertNetErrorWithTag:KD_INVITE_CLOLLEGURES_ALERTT_GET_IS_ADMIN];
    }else {
        if ([self isAdmin]) {//管理员
            [self vertifiedAsAdmin];
        }else { //非管理员
            [self getQRcodeOrLinkInviteParams];
        }
    }
}

- (void)goToNextWithVerificaiton { //邀请需要管理员审核
    DLog(@"KDInviteColleaguesViewController_tips_6");
    if (_selectedIndex == KDInviteIndexQRCode) {
        [self gotoQRcodeInvitationViewController:KDVerificationTypeShould];
    }
    else if (_selectedIndex == KDInviteIndexLink){
        [self gotoLinkInvitationViewController:KDVerificationTypeShould];
    }
    else if (_selectedIndex == KDInviteIndexWeXin || _selectedIndex == KDInviteIndexQQ || _selectedIndex == KDInviteIndexContact || _selectedIndex == KDInviteIndexPhoneNum){
        [self shareInviteLink];
    }
}

- (void)goToNextWithNoVerification { //邀请不需要管理员审核
    DLog(@"一个月免验证");
    if (_selectedIndex == KDInviteIndexQRCode) {
        [self gotoQRcodeInvitationViewController:KDVerificationTypeNone];
    }
    else if (_selectedIndex == KDInviteIndexLink){
        [self gotoLinkInvitationViewController:KDVerificationTypeNone];
    }
    
}


- (UIButton *)buttonWithImage:(NSString *)imageName action:(SEL)action andTitle:(NSString *)title
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 290.0f, 41.0f);
    UIButton *bgView = [[UIButton alloc] initWithFrame:rect];
    bgView.layer.cornerRadius = 5.0f;
    bgView.layer.masksToBounds = YES;
    [bgView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bgView setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(32, 192, 0)] forState:UIControlStateNormal];
    
    [bgView addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [bgView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bgView setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 30.0f)];
    [bgView setTitle:title forState:UIControlStateNormal];
    
    return bgView;
}

- (void)cancel:(id)sender
{
    if(self.bShouldDismissOneLayer)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [[KDWeiboAppDelegate getAppDelegate].tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)hasInvitePermisson
{
    if(![[BOSSetting sharedSetting] hasInvitePermission])
    {
        [self alertNoPermission];
        
        return NO;
    }
    
    if ([[BOSConfig sharedConfig].user.phone length] == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDCreateTeamViewController_bind_mobile")message:ASLocalizedString(@"KDCreateTeamViewController_tips_un_bind")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"KDAuthViewController_ok"), nil];
        [alertView setDelegate:self];
        [alertView show];
        alertView.tag = 0x98;
        
        return NO;
    }
    
    return YES;
}

- (void)bindPhone
{
    KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
    ctr.type = KDPhoneInputTypeBind;
    ctr.delegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
}
- (void)authViewConfirmPwd
{
    [self.navigationController popToViewController:self animated:YES];
}


- (void)showHud:(BOOL)animated{
    if (_hud == nil) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:animated];;
    }else {
        [_hud show:animated];
    }
}

- (void)hideHud:(BOOL)animated {
    if (_hud) {
        [_hud hide:YES];
    }
}

#pragma mark - UIActionsheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (title) {
        if ([title isEqualToString:ASLocalizedString(@"KDInviteColleaguesViewController_tips_4")]) {
            [self goToNextWithNoVerification];
        }else if ([title isEqualToString:ASLocalizedString(@"KDInviteColleaguesViewController_tips_5")]) {
            [self goToNextWithVerificaiton];
        }
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == 0x99) {
            
            //TODO: 通知管理员，暂时未实现
#ifdef DEBUG
            NSLog(ASLocalizedString(@"通知管理员..."));
#endif
        }
        else if(alertView.tag == 0x98)
        {
            [self bindPhone];
        }
        else if(alertView.tag == KD_INVITE_CLOLLEGURES_ALERTT_GET_IS_ADMIN) {
            _retryVerificateAdmin = YES;
            [self checkIsAdmin];
            
        }else if (alertView.tag == KD_INVITE_CLOLLEGURES_ALERTT_GET_COMPANY_COFIG) {
            [self getQRcodeOrLinkInviteParams]; //重试获取二维码或者链接邀请权限的接口调用
        }
    }
}


#pragma mark -
#pragma mark UITableViewDataSource And Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *inviteColleaguesCellIdentifier = @"InviteColleagueCellIdentifier";
    int row = (int)[indexPath row ];
    KDInviteColleagueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteColleaguesCellIdentifier];
    if(cell == nil){
        cell = [[KDInviteColleagueTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inviteColleaguesCellIdentifier];
    }
    [cell.imageView setImage:[UIImage imageNamed:inviteImageNames[row]]];
    [cell.titleTextLabel setText:self.inviteLabelNames[row]];
    return cell;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isLoading) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = (int)[indexPath row];
    switch (row) {
            //        case 0://微信邀请邀请
            //            [self inviteWeChat:nil];
            //            break;
            //        case 1://QQ邀请
            //            [self inviteQQ:nil];
            //            break;
        case 0://通讯录邀请
            [self inviteContact:nil];
            break;
        case 1://手机号码邀请
            [self invitePhone:nil];
            break;
            //        case 2://链接邀请
            //            [self inviteLink:nil];
            //            break;
        case 2://二维码邀请
            [self inviteQRCode:nil];
            break;
        default:
            break;
    }
    [self checkIsAdmin];
    
    
}
//QQ微信分享用的是同一个方法
-(void)shareInviteLink{
    [self showHud:YES];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [self hideHud:YES];
        if([response isValidResponse]) {
            if(results) {
                NSString *url = results[@"url"];
                if (url && [url length] > 0) {
                    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
                    CompanyDataModel *currentUser = communityManager.currentCompany;
                    UserDataModel * userDataModel = currentUser.user;
                    if (_selectedIndex == KDInviteIndexQQ) {
                        //                        [[KDSocialsShareManager shareSocialsShareManager] shareToQQText:[NSString stringWithFormat: ASLocalizedString(@"%@邀请你加入【%@】工作圈。%@（需要管理员审核）。"),userDataModel.name,currentUser.name,url] delegate:nil];
                        
                        [SHARE_MANAGER shareToQQWithText:[NSString stringWithFormat: ASLocalizedString(@"KDInviteColleaguesViewController_tips_10"),userDataModel.name,currentUser.name,url] isQzone:NO];
                        
                    }
                    else if (_selectedIndex == KDInviteIndexWeXin){
                        NSString * title =  [NSString stringWithFormat:ASLocalizedString(@"KDInviteColleaguesViewController_tips_11"),currentUser.name];
                        NSString * description = [NSString stringWithFormat:ASLocalizedString(@"KDInviteColleaguesViewController_tips_12"),currentUser.name,url];
                        UIImage * thumbImage = [UIImage imageNamed:@"icon120.png"];
                        //                        [[KDSocialsShareManager shareSocialsShareManager]shareToWeChatLinkUrl:url title:title description:description thumbImage:thumbImage];
                        if (self.isFromFirstToDo) {
                            [self umengEvent:label_invite_open_inviteType_firstToDo];
                        }
                        else {
                            [self umengEvent:label_invite_open_inviteType_weixin];
                        }
                        [SHARE_MANAGER shareToWechatWithTitle:title description:description thumbData:UIImageJPEGRepresentation(thumbImage, 0) webpageUrl:url isTimeline:NO];
                        
                    }
                    else if(_selectedIndex == KDInviteIndexPhoneNum){
                        [self gotoPhoneNumberInvite:url];
                    }
                    else if(_selectedIndex == KDInviteIndexContact){
                        [self gotoContactInvite:url];
                    }
                }
                else{
                    [self showInviteLinkAlertView];
                }
            }
            else{
                
                [self showInviteLinkAlertView];
            }
        }else {
            [self showInviteLinkAlertView];
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"eid" stringValue:[BOSConfig sharedConfig].user.eid ];
    [query setParameter:@"openid" stringValue:[BOSConfig sharedConfig].user.openId];
    [query setParameter:@"type" stringValue:[self isAdmin]?@"0":@"1"];
    
    NSString *sourceType = @"0";
    if (_selectedIndex == KDInviteIndexPhoneNum) {
        sourceType =@"1";
    }
    else if(_selectedIndex == KDInviteIndexContact){
        sourceType =@"2";
    }
    else if( _selectedIndex == KDInviteIndexLink){
        sourceType =@"3";
    }
    else if(_selectedIndex == KDInviteIndexQRCode){
        sourceType =@"4";
    }
    else if(_selectedIndex == KDInviteIndexQQ || _selectedIndex == KDInviteIndexWeXin ){
        sourceType = @"5";
    }
    
    [query setParameter:@"source_type" stringValue:sourceType];
    
    //暂时没有用，随便传一个
    [query setParameter:@"ticket" stringValue:@"123"];
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:getInvitationURL"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

-(void)showInviteLinkAlertView{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDInviteColleaguesViewController_share_error")delegate:nil
                                              cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alertView show];
}

@end
