//
//  KDVersionCheck.m
//  kdweibo_common
//
//  Created by Gil on 14-9-19.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDVersionCheck.h"
#import "KDNotificationView.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MobClick.h"

static char resultKey;
@implementation KDVersionCheck

+ (KDVersionCheck *)sharedKDVersionCheck {
	static dispatch_once_t pred;
	static KDVersionCheck *sharedKDVersionCheck = nil;

	dispatch_once(&pred, ^{
	    sharedKDVersionCheck = [[[self class] alloc] init];
	});

	return sharedKDVersionCheck;
}

+ (void)checkUpdate:(BOOL)showUpdateInfo {
	KDVersionCheck *sharedKDVersionCheck = [KDVersionCheck sharedKDVersionCheck];
	sharedKDVersionCheck.showUpdateInfo = showUpdateInfo;
//	[MobClick checkUpdateWithDelegate:self selector:@selector(receiveUpdate:)];
}

+ (void)receiveUpdate:(NSDictionary *)result {
	//无更新
	if (!result || ![[result objectForKey:@"update"] boolValue]) {
		if ([KDVersionCheck sharedKDVersionCheck].showUpdateInfo) {
			[self checkVersionInfoVisible:YES info:ASLocalizedString(@"Current_LastestVersion")];
		}
		return;
	}


	NSString *title = [NSString stringWithFormat:ASLocalizedString(@"KDVersionCheck_alter_title"), [result objectForKey:@"version"]];
	NSString *message = [result objectForKey:@"update_log"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:ASLocalizedString(@"KDVersionCheck_cancel")otherButtonTitles:ASLocalizedString(@"KDVersionCheck_update"), nil];// autorelease];
	objc_setAssociatedObject(alert, &resultKey,
	                         result,
	                         OBJC_ASSOCIATION_RETAIN);
	alert.tag = 9999;
	[alert show];
}

+ (void)checkVersionInfoVisible:(BOOL)visible info:(NSString *)info {
    if(!visible){
        return ;
    }
	UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];

	KDNotificationView *notificationView = [KDNotificationView defaultMessageNotificationView];
	[notificationView showInView:keyWindow
	                     message:info
	                        type:KDNotificationViewTypeNormal];
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 9999) {
		NSDictionary *resultDic  = (NSDictionary *)objc_getAssociatedObject(alertView, &resultKey);
		if (buttonIndex != alertView.cancelButtonIndex) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[resultDic objectForKey:@"path"]]];
		}
		return;
	}
}

@end
