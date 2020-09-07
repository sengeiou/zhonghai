//
//  KWIAboutVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/26/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIAboutVCtrl.h"
#import "KDUnderLineButton.h"
#import "KWIAppDelegate.h"
#import "KDWebViewController.h"
@interface KWIAboutVCtrl ()
@property (retain, nonatomic) IBOutlet KDUnderLineButton *protocalBtn;

@end

@implementation KWIAboutVCtrl

+ (KWIAboutVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:@"KWIAboutVCtrl" bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configTitle:@"关于"];
    
    self.versionLabel.text = [NSString stringWithFormat:@"V%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

- (void)dealloc {
    [_versionLabel release];
    [_protocalBtn release];
    [super dealloc];
}

- (IBAction)protocalBtnTapped:(id)sender {
    //[[KWIAppDelegate getAppDelegate] openWebView:@"kdweibo.com/public/agreement.jsp"];
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

- (void)viewDidUnload {
    [self setVersionLabel:nil];
    [self setProtocalBtn:nil];
    [super viewDidUnload];
}
@end
