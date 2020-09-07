//
//  KWIRateVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/26/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIRateVCtrl.h"
#import "KWIAppDelegate.h"

@interface KWIRateVCtrl ()

@end

@implementation KWIRateVCtrl

+ (KWIRateVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:@"KWIRateVCtrl" bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"评价";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)_onOKBtnTapped:(id)sender
{
    NSString *urlString = [(KWIAppDelegate *)[UIApplication sharedApplication].delegate commentURL];
    
    if(!urlString || [urlString isEqualToString:@""])
        urlString = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=554142143";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)_onNoBtnTapped:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
