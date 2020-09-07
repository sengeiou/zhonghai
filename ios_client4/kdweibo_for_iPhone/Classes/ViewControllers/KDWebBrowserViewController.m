//
//  KDWebBrowserViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-3-15.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDWebBrowserViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface KDWebBrowserViewController () {
    
    UIView *headerview_; //weak
    
    UIWebView *webView_;
    UIToolbar *toolbar_;
    UITextField *urlTextField_;
    UIActivityIndicatorView *indicator_;
    
    NSString  *urlString_;
    
    NSURLRequest *request_;
    NSURLConnection *connection_;
    BOOL authenticated_;
    
    BOOL hiddeInput_;
}

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;

@end

@implementation KDWebBrowserViewController

@synthesize urlString = urlString_;
@synthesize delegate = delegate_;
@synthesize request = request_;
@synthesize connection = connection_;
@synthesize hiddeInput = hiddeInput_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hiddeInput_ = NO;
    }
    return self;
}

- (void)dealloc {
    [toolbar_ release];
    [webView_ release];
    [request_ release];
    
    [connection_ cancel];
    [connection_ release];
    
    [super dealloc];
}

//////////////
- (void)refresh {
    [webView_ reload];
}

- (void)stop {
    [webView_ stopLoading];
}

- (void)back {
    [webView_ goBack];
}

- (void)forward {
    [webView_ goForward];
}

- (void)go {
    [urlTextField_ resignFirstResponder];
    urlString_ = urlTextField_.text;
    
    if(![urlString_ hasPrefix:@"http://"]){
        urlString_ = [NSString stringWithFormat:@"http://%@", urlString_];
    }
    
    [self loadURL];
}
/////////////

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, 30.0f)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    
    urlTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0, headView.frame.size.width - 60.0f, headView.frame.size.height)];
    urlTextField_.backgroundColor = [UIColor whiteColor];
    urlTextField_.borderStyle = UITextBorderStyleBezel;
    urlTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    urlTextField_.returnKeyType = UIReturnKeyGo;
    urlTextField_.delegate = self;
    [headView addSubview:urlTextField_];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setBackgroundColor:[UIColor whiteColor]];
    goButton.layer.borderWidth = 1.0f;
    goButton.layer.borderColor = [UIColor blackColor].CGColor;
    [goButton setTitle:@"Go" forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    [goButton setFrame:CGRectMake(headView.frame.size.width - 50.0f, 0.0f, 50.0f, headView.frame.size.height)];
    [headView addSubview:goButton];
    
    [view addSubview:headView];
    [headView release];
    
    headerview_ = headView;
    /*
    toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, view.frame.size.height - 44.0f - 20.0f - 30.0f, view.frame.size.width, 30.0f)];
    [view addSubview:toolbar_];
//    [toolbar_ setBarStyle:UIBarStyleDefault];
    //config tool bar
    UIBarButtonItem *spaceHead = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(back)];
    UIBarButtonItem *spaceOne = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(forward)];
    UIBarButtonItem *spaceTwo = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop)];
    UIBarButtonItem *spaceThree = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    UIBarButtonItem *spaceTail = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
    
    [toolbar_ setItems:[NSArray arrayWithObjects:spaceHead, backItem, spaceOne, forwardItem, spaceTwo, stopItem, spaceThree, refreshItem, spaceTail, nil]];
    [backItem release];
    [forwardItem release];
    [stopItem release];
    [refreshItem release];
     */
    
    CGFloat offsetY = hiddeInput_ ? 0.0f : CGRectGetHeight(headView.frame);
    webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, offsetY, view.frame.size.width, view.frame.size.height - offsetY - 44.0f - 20.0f)];
    webView_.delegate = self;
    webView_.scalesPageToFit = YES;
//    webView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [view addSubview:webView_];
    
    
    indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator_.center = view.center;
    indicator_.hidden = YES;
    [indicator_ startAnimating];
    
    [view addSubview:indicator_];
    
    self.view = view;
    [view release];
}

- (void)setHiddeInput:(BOOL)hiddeInput {
    if(!hiddeInput_ != !hiddeInput) {
        hiddeInput_ = hiddeInput;
        headerview_.hidden = hiddeInput_;
        CGFloat offsetY = hiddeInput_ ? 0.0f : CGRectGetHeight(headerview_.frame);
        
        webView_.frame = CGRectMake(0.0f, offsetY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - offsetY - 44.0f - 20.0f);
    }
}

- (void)loadURL{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString_]];
    [webView_ loadRequest:request];
}

- (void)setupNavigationBar {
    UIImage *imageBack = [[UIImage imageNamed:@"navigationItem_back.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage: imageBack forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0.0f, 0.0f, imageBack.size.width, imageBack.size.height);
    [backBtn setImage: [[UIImage imageNamed: @"navigationItem_back.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(cancel)  forControlEvents:UIControlEventTouchUpInside];
    [backBtn sizeToFit];
    
    UIBarButtonItem *backItem = [[[UIBarButtonItem alloc] initWithCustomView:backBtn]autorelease];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi

    UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil] autorelease];
    negativeSpacer.width = kLeftNegativeSpacerWidth;
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,backItem, nil];

    UIImage *imageNormal = [UIImage imageNamed:@"attachment_view_link_v2.png"];
    UIButton *openAsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [openAsBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [openAsBtn setImage:imageNormal forState:UIControlStateNormal];
    openAsBtn.frame= CGRectMake(0.0, 0.0, imageNormal.size.width,imageNormal.size.height);
    [openAsBtn addTarget:self action:@selector(showAvailableActions) forControlEvents:UIControlEventTouchUpInside];
    [openAsBtn sizeToFit];
    
    UIBarButtonItem *reviewDownloadedbtnItem = [[[UIBarButtonItem alloc] initWithCustomView:openAsBtn] autorelease];
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer1 = [[[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil] autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer1,reviewDownloadedbtnItem, nil];

}

- (void)cancel {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showAvailableActions {
    
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[webView_.request.URL absoluteString]
															 delegate:self
													cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[actionSheet addButtonWithTitle:NSLocalizedString(@"OPEN_IN_SAFARI", @"")];
    
	[actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"")];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark - uiwebview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    BOOL shouldLoad = NO;
    
    if([delegate_ respondsToSelector:@selector(webBrowserViewController:shouldLoadRequest:)]) {
        shouldLoad = [delegate_ webBrowserViewController:self shouldLoadRequest:request];
    }
    
    if(!shouldLoad) {
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    
    if([[[request URL] scheme] isEqualToString:@"https"]) {
        if (!authenticated_) {
            authenticated_ = NO;
            
            self.request = request;
            
            self.connection = [[[NSURLConnection alloc] initWithRequest:request_ delegate:self] autorelease];
            
            if([connection_ respondsToSelector:@selector(set)])
            
            [connection_ start];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.navigationItem.title = NSLocalizedString(@"EORROR_HAPPEN", nil);
    indicator_.hidden = YES;
    authenticated_ = NO;
    
    NSString *url = [webView_ stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    urlTextField_.text = url;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	self.navigationItem.title = title;
    indicator_.hidden = YES;
    authenticated_ = NO;
    
    NSString *url = [webView_ stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    urlTextField_.text = url;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.navigationItem.title = NSLocalizedString(@"LOADING...", @"");
    indicator_.hidden = NO;
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0)
    {
        authenticated_ = YES;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    } else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    authenticated_ = YES;
    
    [webView_ loadRequest:request_];
    [connection_ cancel];
}

#pragma mark - UIActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ( buttonIndex != actionSheet.cancelButtonIndex) {
		if (buttonIndex == 0) {
			[[UIApplication sharedApplication] openURL:webView_.request.URL];
		} 
	}
}


#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self go];
    return YES;
}

/////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    if(urlString_) {
        urlTextField_.text = urlString_;
        [self loadURL];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
