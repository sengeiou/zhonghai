//
//  KDWebViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-7-17.
//
//

#import "KDWebViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface KDWebViewController ()
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation KDWebViewController
@synthesize url = _url;
@synthesize webView = _webView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self  action:@selector(back:)];
    self.navigationItem.leftBarButtonItem =leftBtnItem;
    [leftBtnItem release];
    self.webView.scalesPageToFit = YES;

    [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

-(void)back:(id)sender {
    if ([self.navigationController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    KD_RELEASE_SAFELY(_url);
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
