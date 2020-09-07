//
//  KDDocFullScreenViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-9.
//
//

#import "KDDocFullScreenViewController.h"

@interface KDDocFullScreenViewController ()<UIWebViewDelegate>

@end

@implementation KDDocFullScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
    self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    KD_RELEASE_SAFELY(_webView);
    [super dealloc];
}

@end
