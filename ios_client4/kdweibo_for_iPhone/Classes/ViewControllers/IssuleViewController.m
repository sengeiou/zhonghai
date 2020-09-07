//
//  IssuleViewController.m
//  TwitterFon
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KDCommon.h"
#import "IssuleViewController.h"
#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "KDWeiboServicesContext.h"

@interface IssuleViewController ()

@property(nonatomic, retain) UIButton *sendButton;
@property(nonatomic, assign) UIAlertView *alertView; // weak reference

@end

@implementation IssuleViewController

@synthesize issuleTextView=issuleTextView_;
@synthesize sendButton=sendButton_;
@synthesize alertView=alertView_;
@synthesize text = text_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = ASLocalizedString(@"IssuleViewController_tips_1");
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            // Register notification when the keyboard will be show
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardChangeFrame:)
                                                         name:UIKeyboardWillChangeFrameNotification
                                                       object:nil];
        }
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItems = [KDCommon rightNavigationItemWithTitle:ASLocalizedString(@"Global_Send")target:self action:@selector(sendIssule:)];
    
    UIBarButtonItem *rightItem = nil;
//    if(isAboveiOS7) {
        rightItem = self.navigationItem.rightBarButtonItems[1];
//    }else {
//        rightItem = self.navigationItem.rightBarButtonItem;
//    }
    
    self.sendButton = (UIButton *)rightItem.customView;

    issuleTextView_.layer.masksToBounds = YES;
    issuleTextView_.layer.cornerRadius = 5.f;
    issuleTextView_.layer.borderWidth = 1.0f;
    issuleTextView_.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
    [issuleTextView_ becomeFirstResponder];
    
    issuleTextView_.text = text_;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(cancel)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.sendButton.enabled = self.issuleTextView.text.length > 0;
}

- (void)cancel
{
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//IOS5 键盘大小变化
-(void)keyboardChangeFrame:(id)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];    
    
    CGRect keyboardRect = [aValue CGRectValue];
    [UIView beginAnimations:@"keyChange" context:nil];
    [UIView setAnimationDuration:0.1];    
    issuleTextView_.frame=CGRectMake(5, 5, 310, 460-44-keyboardRect.size.height-10);
    [UIView commitAnimations];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.sendButton.enabled = [textView.text length] > 0;
}

- (NSString *)generateIssueContent {
    NSString *version = [KDCommon clientVersion];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    
    return [NSString stringWithFormat:@"#%@:%@##%@｜iOS%@#:%@",KD_APPNAME,version, model, iosVersion, issuleTextView_.text];
}

- (void)sendIssule:(id)sender {
    sendButton_.enabled = NO;
    
    [MBProgressHUD showHUDAddedTo:issuleTextView_ animated:YES];
    
    NSString *content = [self generateIssueContent];
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"title" stringValue:ASLocalizedString(@"IssuleViewController_tips_2")]
            setParameter:@"content" stringValue:content];
    
    __block IssuleViewController *ivc = self; //retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if ([(NSNumber *)results boolValue]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"IssuleViewController_tips_3")message:ASLocalizedString(@"IssuleViewController_tips_4")delegate:ivc cancelButtonTitle:ASLocalizedString(@"IssuleViewController_tips_5")otherButtonTitles:nil];
                
                ivc.alertView = alertView;
                [alertView show];
//                [alertView release];
                
                [MBProgressHUD hideAllHUDsForView:ivc.issuleTextView animated:YES];
            }
        
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage] inView:ivc.view.window];
            }
        }
        
        [MBProgressHUD hideAllHUDsForView:ivc.issuleTextView animated:YES];
        ivc.sendButton.enabled = YES;
        
        // release current view controller
//        [ivc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:feedback" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertView_ = nil;
    
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    if (alertView_) {
        alertView_.delegate = nil;
        alertView_ = nil;
    }
    
    //KD_RELEASE_SAFELY(issuleTextView_);
    //KD_RELEASE_SAFELY(sendButton_);
}

- (void)dealloc {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];[defaultCenter removeObserver:self];
    }
    
    if (alertView_) {
        alertView_.delegate = nil;
        alertView_ = nil;
    }
    
    //KD_RELEASE_SAFELY(issuleTextView_);
    //KD_RELEASE_SAFELY(sendButton_);
    
    //[super dealloc];
}

@end
