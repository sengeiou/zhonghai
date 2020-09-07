//
//  KDTimeLineDetailURLViewHandle.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDTimeLineDetailURLViewHandle.h"
#import "CommenMethod.h"
#import "KDTopic.h"
#import "KDDefaultViewControllerContext.h"

@implementation KDTimeLineDetailURLViewHandle
@synthesize delegate = delegate_;

- (void)dealloc {
    delegate_ = nil;
    
    //[super dealloc];
}

#pragma mark -
#pragma mark DSURLViewDelegate method

- (void)urlWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString
{	
	KDWeiboAppDelegate *appDelegate=[KDWeiboAppDelegate getAppDelegate];
	[appDelegate openWebView:urlString];
}

- (void)topicWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString {
	KDTopic *topic = [[KDTopic alloc] init];
    NSRange searchRange = NSMakeRange(1, urlString.length - 2);
    topic.name = [urlString substringWithRange:searchRange];
    
    UIViewController *vc = [[KDDefaultViewControllerContext defaultViewControllerContext] topViewController];
    KDStatus *status = nil;
    if ([vc respondsToSelector:@selector(status)]) {
        status = [vc performSelector:@selector(status)];
    }
    
    TrendStatusViewController *tsvc = [[TrendStatusViewController alloc] initWithTopic:topic];
    tsvc.topicStatus = status;
	
    [vc.navigationController pushViewController:tsvc animated:TRUE];
    
//    [topic release];
//    [tsvc release];
}

- (void)userWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString {	
    [CommenMethod jumToProfileViewControllerWithUserName:urlString];
}

- (void)viewTouchesBegan:(DSURLView*)view
{
    if (self.delegate&&[(id)self.delegate respondsToSelector:@selector(kDTimeLineDetailURLViewHandle:viewTouchesBegan:)]) {
        [self.delegate kDTimeLineDetailURLViewHandle:self viewTouchesBegan:view];
    }
}

- (void)viewTouchesEnded:(DSURLView*)view
{
    if (self.delegate&&[(id)self.delegate respondsToSelector:@selector(kDTimeLineDetailURLViewHandle:viewTouchesEnded:)]) {
        [self.delegate kDTimeLineDetailURLViewHandle:self viewTouchesEnded:view];
    }
}

- (void)viewTouchesMove:(DSURLView *)view
{
    if (self.delegate&&[(id)self.delegate respondsToSelector:@selector(kDTimeLineDetailURLViewHandle:viewTouchesEnded:)]) {
        [self.delegate kDTimeLineDetailURLViewHandle:self viewTouchesMove:view];
    }
}
- (void)viewTouchesCancle:(DSURLView *)view
{
    if (self.delegate&&[(id)self.delegate respondsToSelector:@selector(kDTimeLineDetailURLViewHandle:viewTouchesEnded:)]) {
        [self.delegate kDTimeLineDetailURLViewHandle:self viewTouchesCancle:view];
    }
}

@end
