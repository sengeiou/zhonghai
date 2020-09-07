//
//  KWISigninVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/14/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISigninVCtrl.h"

#import "Logging.h"
#import "iToast.h"

#import "SCPLocalKVStorage.h"

#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"

#import "KDCommonHeader.h"
#import "KWIAppDelegate.h"
#import "KDUnderLineButton.h"
#import "KDWebViewController.h"
@interface KWISigninVCtrl () <UITextFieldDelegate,UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *accountInput;
@property (retain, nonatomic) IBOutlet UITextField *passwordInput;
@property (retain, nonatomic) IBOutlet UITextField *signupAccountIpt;
@property (retain, nonatomic) IBOutlet UIButton *signinBtn;
@property (retain, nonatomic) IBOutlet UIButton *signupBtn;
@property (retain, nonatomic) IBOutlet UIButton *signinModBtn;
@property (retain, nonatomic) IBOutlet UIButton *signupModBtn;
@property (retain, nonatomic) IBOutlet UIView *oprtCtnV;
@property (retain, nonatomic) IBOutlet UIView *signinCtn;
@property (retain, nonatomic) IBOutlet UIView *signupCtn;
@property (retain, nonatomic) IBOutlet UIButton *checkBox;
@property (retain, nonatomic) IBOutlet KDUnderLineButton *userProtocalBtn;
@property (retain, nonatomic) IBOutlet UILabel *agreeLabel;


@property(nonatomic, retain) KDUser *currentUser;
@property (nonatomic, retain) NSMutableArray *userList;
@property (nonatomic, retain) KDQuery *thirdPartAuthorizeQuery;
@property (nonatomic, retain) KDActivityIndicatorView *activityView;
@property (nonatomic, retain) UIView *blockView;

@end

@implementation KWISigninVCtrl
{
    BOOL _shouldShow;
    IBOutlet UIImageView *_bgV;
    IBOutlet UILabel *_signupDoneLbl;
    IBOutlet UIImageView *_signupIptBgV;
    struct {
        unsigned int initialized:1;
        unsigned int protocolPresent:1;
    }flags_;
}

@synthesize accountInput = _accountInput;
@synthesize passwordInput = _passwordInput;
@synthesize signupAccountIpt = _signupAccountIpt;
@synthesize signinBtn = _signinBtn;
@synthesize signupBtn = _signupBtn;
@synthesize oprtCtnV = _oprtCtnV;
@synthesize signinCtn = _signinCtn;
@synthesize signupCtn = _signupCtn;
@synthesize signinModBtn = _signinModBtn;
@synthesize signupModBtn = _signupModBtn;

@synthesize userList = userList_;
@synthesize currentUser=currentUser_;
@synthesize thirdPartAuthorizeQuery=thirdPartAuthorizeQuery_;
@synthesize activityView = activityView_;
@synthesize blockView = blockView_;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        
        [self retrieveLoggedInUsers];
        _shouldShow = YES;
        flags_.initialized = 0;
        flags_.protocolPresent = 0;
    }
    return self;
}



+ (KWISigninVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:self.description bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.checkBox.hidden = YES;
    self.agreeLabel.hidden = YES;
    self.checkBox.selected = YES;
    self.signupCtn.hidden = YES;
    self.oprtCtnV.hidden = YES;
    [self alignUserProtocalBtnOnSingIn];
    
    [self _configBgVForCurrentOrientation];
    
    // UIKeyboardDidChangeFrameNotification since 5.0
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onKeyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    
    if (_shouldShow) {
        [self _show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (flags_.protocolPresent == 1) {
        flags_.protocolPresent = 0;
        return;
    }
    self.accountInput.text = nil;
    self.passwordInput.text = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     self.oprtCtnV.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.oprtCtnV.hidden = NO;
    if(flags_.initialized == 0){
        flags_.initialized = 1;
        KDQuery *query = [[KDSession globalSession] propertyForKey:KD_PROP_3RD_AUTH_QUERY_KEY];
        if (query != nil) {
            self.thirdPartAuthorizeQuery = query;
            
            // authorize with third part app
            [self thirdPartAuthorize];
        }
    }
    
}


- (void)activityViewWithVisible:(BOOL)visible block:(BOOL)block info:(NSString *)info {
    if(activityView_ == nil){
        CGRect rect = CGRectMake((self.view.bounds.size.width - 160.0) * 0.5, (self.view.bounds.size.height - 100.0) * 0.5 - 50.0, 160.0, 100.0);
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:rect];
        activityView_.alpha = 0.0;
        
        [self.view addSubview:activityView_];
    }
    
    if(visible){
        if (block && blockView_ == nil) {
            blockView_ = [[UIView alloc] initWithFrame:self.view.bounds];
            blockView_.backgroundColor = RGBACOLOR(145.0, 145.0, 145.0, 0.5);
            
            blockView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:blockView_ belowSubview:activityView_];
        }
        
        [activityView_ show:YES info:info];
        
    }else {
        if (blockView_ != nil) {
            if (blockView_.superview != nil) {
                [blockView_ removeFromSuperview];
            }
            
            KD_RELEASE_SAFELY(blockView_);
        }
        
        [activityView_ hide:YES];
    }
}

- (void)thirdPartAuthorize {
    NSString *token = [thirdPartAuthorizeQuery_ genericParameterForName:@"third_token"];
    
    // show loading activity view
    [self activityViewWithVisible:YES block:YES info:NSLocalizedString(@"SIGNINING...", @"")];
    
    KDXAuthAuthorization *genericAuth = [KDXAuthAuthorization xAuthorizationWithAccessToken:nil];
    [[[KDWeiboServicesContext defaultContext] getKDWeiboServices] updateAuthorization:genericAuth];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"ex_auth_logintoken" stringValue:token]
     setParameter:@"ex_auth_mode" stringValue:@"exchange_auth"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDAuthToken *authToken = nil;
        if([response isValidResponse]){
            NSString *responseString = [response responseAsString];
            authToken = [KDAuthToken authTokenWithString:responseString];
        }
        
        if (authToken != nil) {
            // bind access auth token
            KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
            userManager.accessToken = authToken;
            [userManager updateAuthorizationForServicesContext];
            
            [self verifyAccount];
            
        } else {
            // dismiss activity view
            [self activityViewWithVisible:NO block:NO info:nil];
            
            BOOL canRetry = NO;
            NSString *message = [KDThirdPartAppAuthActionHandler messageForAuthorizeDidFailResponse:response canRetry:&canRetry];
            if(message != nil){
                [self showPromptWithTitle:NSLocalizedString(@"SIGN_IN_DID_FAIL_TITLE", @"") message:message retry:canRetry];
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/auth/:accessToken" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)verifyAccount {
    NSString *subDomainName = [[KDSession globalSession] propertyForKey:KD_3RD_AUTH_DOMAIN_NAME];
    
    KDQuery *query = [KDQuery queryWithName:@"domain_name" value:subDomainName];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if(results != nil){
            KDUser *user = results;
            
            self.currentUser = user;
            
            [self listJoinedCommunities];
            
        } else {
            // dismiss activity view
            [self activityViewWithVisible:NO block:NO info:nil];
            
            if(![response isCancelled]){
                // verify account did failed
                if(subDomainName) {
                    [[KDSession globalSession] setProperty:nil forKey:KD_3RD_AUTH_DOMAIN_NAME];
                    [self showAlertWithTitle:nil message:NSLocalizedString(@"VERIFY_ACCOUNT_DID_FAIL_NETWORK_ERROR", @"")];
                    
                } else {
                    [self showAlertWithTitle:nil message:NSLocalizedString(@"VERIFY_ACCOUNT_DID_FAIL", @"")];
                }
            }
        }
    };
    
    NSString *actionPath = (subDomainName != nil) ? @"/account/:verifyCredentialsWithDomain"
    : @"/account/:verifyCredentials";
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)showPromptWithTitle:(NSString *)title message:(NSString *)message retry:(BOOL)retry {
    UIAlertView *alertView = [[UIAlertView alloc] initWithFrame:CGRectZero];
    alertView.delegate = self;
    alertView.tag = 0x02;
    alertView.title = title;
    alertView.message = message;
    
    alertView.cancelButtonIndex = 0x00;
    [alertView addButtonWithTitle:NSLocalizedString(@"OKAY", @"")];
    
    if (retry) {
        [alertView addButtonWithTitle:NSLocalizedString(@"RETRY", @"")];
    }
    
    [alertView show];
    [alertView release];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = nil;
    
    if([message isEqualToString:NSLocalizedString(@"SIGN_IN_DID_FAIL_DETAILS", @"")]) {
        alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") otherButtonTitles:NSLocalizedString(@"SIGN_IN_RESET_PASSWORD", @""),nil];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
    }
    
    alertView.tag = 0x01;
    [alertView show];
    [alertView release];
}


- (void)retrieveLoggedInUsers {
    // retrieve logged in users from cache if need
    if(userList_ == nil){
        NSMutableArray *users = [KDLoggedInUser retrieveLoggedInUsers];
        
        self.userList = (users != nil) ? users : [NSMutableArray array];
    }
}
- (void)listJoinedCommunities {
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSString *errorMessage = nil;
        if([response isValidResponse]) {
            if (results != nil) {
                NSArray *communities = results;
                
                // Generally speaking, the communities count always more than one,
                // But may be parse json has some problems
                if(communities != nil && [communities count] > 0){
                    NSString *subDomainName = [[KDSession globalSession] propertyForKey:KD_3RD_AUTH_DOMAIN_NAME];
                    
                    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
                    userManager.currentUserId = currentUser_.userId;
                    userManager.currentUserCompanyDomain = currentUser_.domain;
                    [userManager storeUserData];
                    
                    KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
                    if (subDomainName) {
                        [communityManager updateWithCommunities:communities currentDomain:subDomainName];
                        
                    } else {
                        [communityManager updateWithCommunities:communities currentDomain:currentUser_.domain];
                    }
                    
                    [communityManager storeCommunities];
                    
                    // check did connected to current community yet
                    if (![[KDDBManager sharedDBManager] isConnectingWithCommunity:communityManager.currentCommunity.communityId]) {
                        // connect to current community
                        [communityManager connectToCommunity:nil];
                    }
                    
                    userManager.currentUser = currentUser_;
                    // register remote notification
                    [[KDManagerContext globalManagerContext].APNSManager registerForRemoteNotification];
                    
                    // set user is signing flag
                    [[KDSession globalSession] setProperty:[NSNumber numberWithBool:YES] forKey:KD_PROP_USER_IS_SIGNING_KEY];
                    
                    KWIAppDelegate *appDelegate = [KWIAppDelegate getAppDelegate];
                    if (thirdPartAuthorizeQuery_ != nil) {
                        // remove cached third part auth query from global session
                        [[KDSession globalSession] setProperty:nil forKey:KD_PROP_3RD_AUTH_QUERY_KEY];
                        [[KDSession globalSession] setProperty:nil forKey:KD_3RD_AUTH_DOMAIN_NAME];
                        
                        // go to main page when third part authorization
                        [appDelegate showTimelineViewController];
                        
                    }
                    else {
                        [appDelegate dismissAuthViewController];
                    }
                    
                } else {
                    errorMessage = NSLocalizedString(@"LOAD_COMMUNITIES_DID_FAIL", @"");
                }
            }
        } else {
            if(![response isCancelled]){
                errorMessage = NSLocalizedString(@"SERVICES_UNAVAILABLE", @"");
            }
        }
        
        [self activityViewWithVisible:NO block:NO info:nil];
        
        if(errorMessage != nil){
            [self showAlertWithTitle:nil message:errorMessage];
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/network/:list" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_accountInput release];
    [_passwordInput release];
    [_signupAccountIpt release];
    [_signinBtn release];
    [_signupBtn release];
    [_oprtCtnV release];
    [_signinCtn release];
    [_signupCtn release];
    [_signinModBtn release];
    [_signupModBtn release];    
    [_bgV release];
    [_signupDoneLbl release];
    [_signupIptBgV release];
    KD_RELEASE_SAFELY(userList_);
    KD_RELEASE_SAFELY(currentUser_);
    KD_RELEASE_SAFELY(thirdPartAuthorizeQuery_);
    KD_RELEASE_SAFELY(activityView_);
    KD_RELEASE_SAFELY(blockView_);
    [_checkBox release];
    [_userProtocalBtn release];
    [_userProtocalBtn release];
    [_agreeLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    self.accountInput = nil;
    self.passwordInput = nil;
    self.signupAccountIpt = nil;
    self.signinBtn = nil;
    self.signupBtn = nil;
    self.oprtCtnV = nil;
    self.signinCtn = nil;
    self.signupCtn = nil;
    self.signinModBtn = nil;
    self.signupModBtn = nil;
    
    [_bgV release];
    _bgV = nil;
    [_signupDoneLbl release];
    _signupDoneLbl = nil;
    [_signupIptBgV release];
    _signupIptBgV = nil;
    [self setCheckBox:nil];
    [self setUserProtocalBtn:nil];
    [self setUserProtocalBtn:nil];
    [self setAgreeLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)show
{
    if (self.isViewLoaded) {
        [self _show];
    } else {
        _shouldShow = YES;
    }
}

- (void)_show
{
    CGRect defFrame = self.oprtCtnV.frame;
    CGRect standbyFrame = defFrame;
    standbyFrame.origin.y = -standbyFrame.size.height;
    self.oprtCtnV.frame = standbyFrame;
    self.oprtCtnV.hidden = NO;
    
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.oprtCtnV.frame = defFrame;
                     } 
                     completion:nil];
}


- (void)_resignInputFieldFirstResponder {
    if([self.accountInput isFirstResponder]) {
        [self.accountInput resignFirstResponder];
    }
    
    if([self.passwordInput isFirstResponder]) {
        [self.passwordInput resignFirstResponder];
    }
}

- (BOOL)validate {
    NSString *username = self.accountInput.text;
    NSString *password = self.passwordInput.text;
    
    // validate token
    if(username == nil || [username length] < 1){
        [self showAlertWithTitle:nil message:NSLocalizedString(@"USERNAME_CAN_NOT_BLANK", @"")];
        return NO;
    }
    
    if(password == nil || [password length] < 1){
        [self showAlertWithTitle:nil message:NSLocalizedString(@"PASSWORD_CAN_NOT_BLANK", @"")];
        return NO;
    }
    
    // resign first responder
   // [self _resignInputFieldFirstResponder];
    
    return YES;
}

- (void)storeToLoggedInUserList:(NSString *)username {
    [self retrieveLoggedInUsers];
    
    BOOL exists = NO;
    // check the username does exits
    for(KDLoggedInUser *user in userList_){
        if([user.identifier isEqualToString:username]){
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        KDLoggedInUser *userObj = [KDLoggedInUser loggedInUserWithIdentifier:username loggedInTime:time(NULL)];
        [userList_ insertObject:userObj atIndex:0x00];
        
        // remove the object over the boundary
        if([userList_ count] > 0x05){
            [userList_ removeLastObject];
        }
        
        // store to cache
        [KDLoggedInUser storeLoggedInUsers:userList_];
    }
}

#pragma mark -

- (IBAction)_signinBtnTapped:(id)sender 
{
    
    if (![self validate]) {
        return;
    }
    NSString *username = self.accountInput.text;
    NSString *password = self.passwordInput.text;
    username = [username lowercaseString];

    
   // [self _lockUI];
    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api XAuthWithUsername:account
//                  password:password 
//                 onSuccess:^(KWOAuthToken *accessToken) {
//                     //[api saveAccessTokenToKeychain];
//                     [SCPLocalKVStorage setObject:accessToken.key forKey:@"access_key"];
//                     [SCPLocalKVStorage setObject:accessToken.secret forKey:@"access_secret"];                     
//                     
//                     KWHomeTimelineDataProvider *htldp = [KWHomeTimelineDataProvider providerWithDelegate:nil];
//                     [htldp clearData];
//                     
//                     self.accountInput.text = @"";
//                     self.passwordInput.text = @"";
//                     [self _unlockUI];
//                     self.oprtCtnV.hidden = YES;
//                     
//                     [self.navigationController pushViewController:[KWIRootVCtrl vctrl] animated:YES];
//                 } 
//                   onError:^(NSError *error) {
//                       LogDebug(@"xauth failed: %@", error);
//                       [self _unlockUI];
//                       
//                       NSString *msg = @"噢，登录失败";
//                       if ([@"ASIHTTPRequestErrorDomain" isEqualToString:error.domain]) {
//                           switch (error.code) {
//                               case 1:
//                                   msg = [msg stringByAppendingString:@"，连不上服务器"];
//                                   break;
//                                   
//                               case 3:
//                                   msg = [msg stringByAppendingString:@"。邮箱或密码不对吧，重试一次？或是访问 kdweibo.com 重置密码"];
//                                   break;
//                                   
//                               default:
//                                   break;
//                           }                           
//                       } else if ([@"KdWeibo" isEqualToString:error.domain]) {
//                           switch (error.code) {
//                               case 1:
//                                   msg = [msg stringByAppendingString:@"，用户名或密码错误"];
//                                   break;
//                                   
//                               default:
//                                   break;
//                           }  
//                       }
//                       
//                       [[iToast makeText:msg] show];
//                   }];
    [self activityViewWithVisible:YES block:YES info:NSLocalizedString(@"SIGNINING...", @"")];
    KDXAuthAuthorization *genericAuth = [KDXAuthAuthorization xAuthorizationWithAccessToken:nil];
    [[[KDWeiboServicesContext defaultContext] getKDWeiboServices] updateAuthorization:genericAuth];
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"x_auth_username" stringValue:username]
      setParameter:@"x_auth_password" stringValue:password]
     setParameter:@"x_auth_mode" stringValue:@"client_auth"];
    
     KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDAuthToken *authToken = nil;
        if (results != nil) {
            authToken = results;
        }
        
        if (authToken != nil) {
            // bind access auth token
            NSLog(@"authToken = %@",authToken);
            KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
            userManager.accessToken = authToken;
            [userManager updateAuthorizationForServicesContext];
            
            // save current username to logged in user list if need
            [self storeToLoggedInUserList:username];
            
            [self verifyAccount];
            
        } else {
            // dismiss activity view
            [self activityViewWithVisible:NO block:NO info:nil];
            int statusCode = [response statusCode];
            NSString *message = nil;
            
            if ([response isNetworkUnavailable]) {
                   [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            } else {
                if(KDHTTPResponseCode_401 == statusCode){
                    message = NSLocalizedString(@"SIGN_IN_DID_FAIL_DETAILS", @"");
                    
                } else {
                    // 500, 502, 503 504 (Internal server error, bad gateway, service unavailable, gateway timeout)
                    // treat as server was broken.
                    // And the other error reason also treat as service unvailable.
                    message = NSLocalizedString(@"SERVICES_UNAVAILABLE", @"");
                }
            }
            
            if(message != nil){
                [self showAlertWithTitle:NSLocalizedString(@"SIGN_IN_DID_FAIL_TITLE", @"") message:message];
            
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/auth/:accessToken" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 0x02) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            NSString *callback = [thirdPartAuthorizeQuery_ genericParameterForName:@"callback"];
            if (callback != nil) {
                NSURL *url = [NSURL URLWithString:callback];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            
        } else {
            // try again
            [self thirdPartAuthorize];
        }
        
    } else if(alertView.tag == 0x01) {
        if([alertView.message isEqualToString:NSLocalizedString(@"VERIFY_ACCOUNT_DID_FAIL_NETWORK_ERROR", @"")]) {
            [self verifyAccount];
        } else if([alertView.message isEqualToString:NSLocalizedString(@"SIGN_IN_DID_FAIL_DETAILS", @"")]) {
            if(buttonIndex != alertView.cancelButtonIndex) {
                [[KWIAppDelegate getAppDelegate] openWebView:@"kdweibo.com/space/c/user/forget-password"];
            }
        }
    }
}


- (void)_onKeyboardChange:(NSNotification *)note
{
    DLog(@"=========");
    CGRect kbFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbFrame = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] convertRect:kbFrame fromView:nil];
    CGFloat kbTop = kbFrame.origin.y;    
    CGFloat contentTop = kbTop - 565;
    if (0 < contentTop) {
        contentTop = 0;
    }
    CGRect frame = self.oprtCtnV.frame;
    frame.origin.y = contentTop;
    [UIView animateWithDuration:0.1 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState  
                     animations:^{
                         self.oprtCtnV.frame = frame;
                     } 
                     completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     DLog(@"=========");
    // ios 4
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        return;
    }
    
    CGRect frame = self.oprtCtnV.frame;
    frame.origin.y = -170;
    [UIView animateWithDuration:0.1 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState  
                     animations:^{
                         self.oprtCtnV.frame = frame;
                     } 
                     completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // for ios 4
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        return;
    }
    
    CGRect frame = self.oprtCtnV.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.1 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState  
                     animations:^{
                         self.oprtCtnV.frame = frame;
                     } 
                     completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.accountInput) {
        [self.passwordInput becomeFirstResponder];
    } else if (textField == self.passwordInput) {
        [self _signinBtnTapped:self.signinBtn];
    }
    
    return YES;
}


- (BOOL)isValidEmail:(NSString *)email {
    // TODO: xxx validate the emails address use regex expression
    if(email == nil || [email length] < 5){
        return NO;
    }
    
    return YES;
}

- (IBAction)_onSignupBtnTapped:(id)sender 
{
    if (!self.checkBox.selected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先同意云之家用户使用协议" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        return;
    }
    NSString *email = self.signupAccountIpt.text;
    if(![self isValidEmail:email]) {
         return;
    }
   
        self.signupAccountIpt.enabled = NO;
        [self.signupAccountIpt resignFirstResponder];
        //        [self showProgressHUD];
        KDQuery *query = [KDQuery queryWithName:@"email" value:email];
        
        __block KWISigninVCtrl *svc = [self retain];
        //[MBProgressHUD showHUDAddedTo:cavc.view animated:YES];
        [self activityViewWithVisible:YES block:YES info:nil];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            NSString *message = nil;
            if ([response isValidResponse]) {
                if (results != nil) {
                    if ([results boolValue]) {
                        svc->_signupDoneLbl.hidden = NO;
                        svc.signupAccountIpt.hidden = YES;
                        svc.signupBtn.hidden = YES;
                        svc->_signupIptBgV.hidden = YES;
                        svc.signupAccountIpt.text = @"";
                    } else {
                      
                        NSDictionary *info = [response responseAsJSONObject];
                        NSString *description = [info stringForKey:@"errorMsg"];
                        message = [svc formatMessageWithError:description];
                    }
                }
                
            }
            else {
                if (![response isCancelled]){
                    if ([response statusCode] >= 500) {
                        message = NSLocalizedString(@"SERVICES_UNAVAILABLE", @"");
                        
                    } else {
                        
                        message = [response.responseDiagnosis networkErrorMessage];
                    }
                }
            }
            if(message != nil) {
                [[iToast makeText:message] show];
                
            }
            [self activityViewWithVisible:NO block:NO info:nil];
            svc.signupAccountIpt.enabled = YES;
            // release current view controller
            [svc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/admin/:registerAccount" query:query
                                     configBlock:nil completionBlock:completionBlock];
        

}

- (NSString *)formatMessageWithError:(NSString *)description {
        NSString *message = nil;
        if ([description isEqualToString:@"email syntax error"]) {
            message = NSLocalizedString(@"EMAIL_FORMAT_IS_WRONG", @"");
            
        } else if([description isEqualToString:@"public email denied"]) {
            message = NSLocalizedString(@"EMAIL_NOT_ENTERPRISE", @"");
            
        } else if([description hasPrefix:@"user exist for email"]) {
            message = NSLocalizedString(@"EXIST_EMAIL", @"");
            
        } else {
            message = description;
        }
        
        return message;
}


- (void)alignUserProtocalBtnOnSignUp {
    self.userProtocalBtn.center = CGPointMake(self.oprtCtnV.frame.size.width *0.69, self.userProtocalBtn.center.y);
}

- (void)alignUserProtocalBtnOnSingIn {
        self.userProtocalBtn.center = CGPointMake(self.oprtCtnV.frame.size.width *0.5, self.userProtocalBtn.center.y);
}

- (IBAction)_onSigninModBtnTapped:(id)sender 
{
    [self _switchSigninMod];
}

- (IBAction)_onSignupModBtnTapped:(id)sender 
{
   
    [self _switchSignupMod];
}


- (IBAction)checkBoxTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
}

- (IBAction)userProtocolBtnTapped:(id)sender {
    flags_.protocolPresent = 1;
    KDWebViewController *webVC = [[KDWebViewController alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://www.kdweibo.com/public/agreement.jsp"];
    webVC.url = url;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    [webVC release];
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        [self  presentModalViewController:nav animated:YES];
    }
    
    [nav release];
}

- (void)_switchSigninMod
{
    self.checkBox.hidden = YES;
    self.agreeLabel.hidden = YES;
    self.signinCtn.hidden = NO;
    [self alignUserProtocalBtnOnSingIn];
    [UIView animateWithDuration:0.2 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.signinCtn.alpha = 1;
                         self.signupBtn.alpha = 0;
                     } 
                     completion:^(BOOL finished) {
                         self.signupCtn.hidden = YES;
                     }];
}

- (void)_switchSignupMod
{
    
    self.checkBox.hidden = NO;
    self.agreeLabel.hidden = NO;
    self.signupCtn.hidden = NO;
    self.signupAccountIpt.hidden = NO;
    self.signupBtn.hidden = NO;
    [self alignUserProtocalBtnOnSignUp];
    _signupIptBgV.hidden = NO;
    _signupDoneLbl.hidden = YES;
    [UIView animateWithDuration:0.2 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.signinCtn.alpha = 0;
                         self.signupBtn.alpha = 1;
                     } 
                     completion:^(BOOL finished) {
                         self.signinCtn.hidden = YES;
                     }];
}

- (void)_lockUI
{
    self.accountInput.enabled = NO;
    self.passwordInput.enabled = NO;
    self.signupAccountIpt.enabled = NO;
    self.signinBtn.enabled = NO;
    self.signupBtn.enabled = NO;
    self.signinModBtn.enabled = NO;
    self.signupModBtn.enabled = NO;
}

- (void)_unlockUI
{
    self.accountInput.enabled = YES;
    self.passwordInput.enabled = YES;
    self.signupAccountIpt.enabled = YES;
    self.signinBtn.enabled = YES;
    self.signupBtn.enabled = YES;
    self.signinModBtn.enabled = YES;
    self.signupModBtn.enabled = YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _bgV.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
    } else {
        _bgV.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
    }
}

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        _bgV.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
    } else {
        _bgV.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
    }
}

@end
