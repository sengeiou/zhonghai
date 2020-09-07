//
//  KWIWebVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/7/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIWebVCtrl.h"
#import "UIDevice+KWIExt.h"
#import "Reachability.h"
#import "iToast.h"
@interface KWIWebVCtrl () <UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webv;
@property (retain, nonatomic) NSURL *originUrl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *ingIdctr;


@end

@implementation KWIWebVCtrl
{
    IBOutlet UINavigationItem *_navItem;
    BOOL isLoading;
}

@synthesize webv = _webv;
@synthesize originUrl = _originUrl;
@synthesize ingIdctr = _ingIdctr;

+ (KWIWebVCtrl *)vctrlWithUrl:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (KWIWebVCtrl *)initWithURL:(NSURL *)url
{
    self = [super initWithNibName:@"KWIWebVCtrl" bundle:nil];
    if (self) {
        self.originUrl = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webv.delegate = self;
    [self.webv loadRequest:[NSURLRequest requestWithURL:self.originUrl]];
    
    _navItem.title = self.originUrl.description;
}

- (void)viewDidUnload
{
    [self setWebv:nil];
    [self setIngIdctr:nil];
    [_navItem release];
    _navItem = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self.presentingViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)dealloc {
    [_webv release];
    [_originUrl release];
    [_ingIdctr release];
    [_navItem release];
    [super dealloc];
}

- (IBAction)_onDoneBtnTapped:(id)sender 
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.ingIdctr startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.ingIdctr stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *pgTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    _navItem.title = pgTitle;
    
    //self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.ingIdctr stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
function testFunc(cmd,parameter1)
{
    alert(1);
    document.write(Date());
    document.location="objc://"+cmd+":/"+parameter1;  //cmd代表objective-
    c中的的方法名，parameter1自然就是参数了
    
}
 
 */

//而在objective-c中，也是利用uiwebview的一个方法，
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:
(NSURLRequest*)request navigationType:
(UIWebViewNavigationType)navigationType 
{
    NSString *urlString = [[request URL] absoluteString];
    
    NSArray *urlComps = [urlString
                         componentsSeparatedByString:@"://"];
    
    if([urlComps count] && [[urlComps objectAtIndex:0]
                            isEqualToString:@"objc"])
    {
        
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps
                                                       objectAtIndex:1] componentsSeparatedByString:@"/"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        
        if (1 == [arrFucnameAndParameter count])
        {
            // 没有参数
            if([funcStr isEqualToString:@"submit"])
            {
                
                /*调用本地函数1*/
                NSLog(@"doFunc1");
                
            }
        }
        else if(2 == [arrFucnameAndParameter count])
        {
            //有参数的
            if([funcStr isEqualToString:@"submit"] &&
               [arrFucnameAndParameter objectAtIndex:1])
            {
                /*调用本地函数1*/
                NSLog(@"doFunc1:parameter = %@",[arrFucnameAndParameter objectAtIndex:1]);
                [self submit:[arrFucnameAndParameter objectAtIndex:1]];
            }
        }
        return NO;
    };
    return YES;
    
}

- (void)submit:(NSString *)str {
    if (isLoading) {
        return;
    }
    isLoading = YES;
    
    NSString *device = [UIDevice platformString];
    UIDevice *curDev = [UIDevice currentDevice];
    NSString *sys = [NSString stringWithFormat:@"%@ %@", curDev.systemName, curDev.systemVersion];
    NSString *netEnv = @"";
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWiFi)
    {
        netEnv = @"wifi";
    }
    else if (status == ReachableViaWWAN)
    {
        netEnv = @"wwan";
    }
    [reachability stopNotifier];
    
    NSString *ver = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *text = [NSString stringWithFormat:@"#%@, %@, %@, ver%@# %@", device, sys, netEnv, ver, str];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"title" stringValue:@"iPad客户端意见反馈"]
     setParameter:@"content" stringValue:text];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if ([(NSNumber *)results boolValue]) {
                isLoading = NO;
                if (self.statusVCtrl) {
                    [self.statusVCtrl dismissPopoverController];
                }
                 
                
            }
        } else {
            if (![response isCancelled]) {
                //                [[response.responseDiagnosis networkErrorMessage] inView:ivc.view.window];
                //[[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            }
        }
        
        // release current view controller
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:feedback" query:query
                                 configBlock:nil completionBlock:completionBlock];

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
@end
