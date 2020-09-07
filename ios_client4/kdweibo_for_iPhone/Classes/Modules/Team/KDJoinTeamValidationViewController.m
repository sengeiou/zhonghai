//
//  KDJoinTeamValidationViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDJoinTeamValidationViewController.h"
#import "KDTeamCell.h"
#import "KDWeiboServicesContext.h"
#import "KDWeiboServices.h"
#import "KDAccountTipView.h"
#import "MBProgressHUD.h"
#import "KDTeamPageViewController.h"
#import "KDManagerContext.h"

#define KD_APPLY_BTN_TAG  10010

@interface KDJoinTeamValidationViewController ()<UITextViewDelegate>
{
    KDTeamCell *communityCell_;
    UIView *contentView_;
    UITextView *validationInfoTextView_;
}

@property (nonatomic, retain) UIView * contentView;

@end

@implementation KDJoinTeamValidationViewController

@synthesize community = community_;
@synthesize contentView = contentView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = ASLocalizedString(@"KDJoinTeamValidationViewController_tips_1");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidde:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //KD_RELEASE_SAFELY(communityCell_);
    //KD_RELEASE_SAFELY(community_);
    //KD_RELEASE_SAFELY(validationInfoTextView_);
    //KD_RELEASE_SAFELY(contentView_);
    
    //[super dealloc];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alert show];
//    [alert release];
}

#pragma mark - Network Methods
- (void)applyJoinTeam
{
    KDQuery *query = [KDQuery queryWithName:@"teamId" value:community_.communityId];
    [query setParameter:@"comment" stringValue:validationInfoTextView_.text];
    
    __block KDJoinTeamValidationViewController *jtvvc = self;// retain];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:jtvvc.view animated:YES];
    hud.labelText = ASLocalizedString(@"KDJoinTeamValidationViewController_tips_2");
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        [MBProgressHUD hideHUDForView:jtvvc.view animated:YES];
        if([response isValidResponse]) {
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDJoinTeamValidationViewController_tips_3")message:ASLocalizedString(@"KDJoinTeamValidationViewController_tips_4")buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:^{
                [jtvvc gotoTeamPage];
            }] showWithType:KDAccountTipViewTypeSuccess window:self.view.window];
        }else {
            [[[KDAccountTipView alloc] initWithTitle:ASLocalizedString(@"KDJoinTeamValidationViewController_tips_5")message:[response.responseDiagnosis networkErrorMessage] buttonTitle:ASLocalizedString(@"Global_Sure")completeBlock:NULL]showWithType:KDAccountTipViewTypeFaild window:self.view.window];
        }
        
//        [jtvvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:applyJoinTeam"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)gotoTeamPage
{
    if([[KDManagerContext globalManagerContext].communityManager joinedCommunities].count > 0 && [[KDManagerContext globalManagerContext].communityManager currentCommunity]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        NSArray *vcs = [self.navigationController viewControllers];
        
        KDTeamPageViewController *teamPage = [[KDTeamPageViewController alloc] initWithContentType:KDTeamPageContentType_MyApplyingTeams | KDTeamPageContentType_CreatAndJoin] ;//autorelease];
        
        if(vcs.count > 0) {
            UIViewController *vc = [vcs objectAtIndex:0];
            teamPage.navigationItem.leftBarButtonItems = vc.navigationItem.leftBarButtonItems;
        }
        
        [self.navigationController setViewControllers:@[teamPage] animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(230, 230, 230);
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds] ;//autorelease];
    [self.view addSubview:self.contentView];
    
	// Do any additional setup after loading the view.
    communityCell_ = [[KDTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    communityCell_.frame = CGRectMake(7.0f, 7.0f, CGRectGetWidth(self.view.frame) - 14.0f, 75.0f);
    communityCell_.needBottomSeperator = NO;
    communityCell_.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
    communityCell_.layer.borderWidth = 0.5f;
    communityCell_.community = community_;
    [self.contentView addSubview:communityCell_];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(communityCell_.frame) + 10.0f, CGRectGetWidth(self.view.frame) - 30.0f, 20.0f)];
    tipsLabel.text = ASLocalizedString(@"KDJoinTeamValidationViewController_tips_6");
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor darkGrayColor];
    tipsLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.contentView addSubview:tipsLabel];
//    [tipsLabel release];
    
    validationInfoTextView_ = [[UITextView alloc] initWithFrame:CGRectMake(7.0f, CGRectGetMaxY(tipsLabel.frame) + 5.0f, CGRectGetWidth(self.view.frame) - 14.0f, 111.0f)];
    validationInfoTextView_.delegate = self;
    validationInfoTextView_.layer.borderWidth = 1.0f;
    validationInfoTextView_.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
    validationInfoTextView_.layer.cornerRadius = 5.0f;
    validationInfoTextView_.layer.masksToBounds = YES;
    validationInfoTextView_.contentInset = UIEdgeInsetsMake(1.5, 0, 1.5, 0);
    
    [self.contentView addSubview:validationInfoTextView_];
    
    UIButton *sendApply = [UIButton buttonWithType:UIButtonTypeCustom];
    sendApply.frame = CGRectMake(75.0f, CGRectGetMaxY(validationInfoTextView_.frame) + 22.0f, 165, 39);
    [sendApply addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [sendApply setTitle:ASLocalizedString(@"KDJoinTeamValidationViewController_tips_7")forState:UIControlStateNormal];
    [sendApply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendApply.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    sendApply.layer.cornerRadius = 5.0f;
    sendApply.layer.masksToBounds = YES;
    sendApply.tag = KD_APPLY_BTN_TAG;
    sendApply.backgroundColor = RGBCOLOR(23, 131, 253);
    
    [self.contentView addSubview:sendApply];
}

- (void)setCommunity:(KDCommunity *)community
{
    if(community != community_) {
//        [community_ release];
        community_ = community;// retain];
        
        communityCell_.community = community_;
    }
}

- (void)send:(id)sender
{
    [validationInfoTextView_ resignFirstResponder];
    [self applyJoinTeam];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [validationInfoTextView_ resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KeyBoard
- (void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *option = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    
    UIView *sendBtn = [self.contentView viewWithTag:KD_APPLY_BTN_TAG];
    CGRect frame = [self.view convertRect:sendBtn.frame fromView:self.contentView];
    
    if(CGRectGetMaxY(frame) > CGRectGetHeight(self.view.frame) - CGRectGetHeight(keyboardRect)) {
        CGFloat delta = CGRectGetMaxY(frame) - (CGRectGetHeight(self.view.frame) - CGRectGetHeight(keyboardRect));
        
        [UIView animateWithDuration:[duration floatValue]
                              delay:0.0f
                            options:[option integerValue]
                         animations:^{
                             self.contentView.frame = CGRectMake(0, -delta, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
                         }
                         completion:NULL];
    }
}

- (void)keyboardWillHidde:(NSNotification *)noti
{
    if(CGRectGetMinY(self.contentView.frame) < 0) {
        NSDictionary *userInfo = [noti userInfo];

        NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *option = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        [UIView animateWithDuration:[duration floatValue]
                              delay:0
                            options:[option integerValue]
                         animations:^{
                             self.contentView.frame = self.view.bounds;
                         }completion:NULL];
    }
}

@end
