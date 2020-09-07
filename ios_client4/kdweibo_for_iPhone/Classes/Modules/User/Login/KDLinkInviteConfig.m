//
//  KDLinkInviteConfig.m
//  kdweibo
//
//  Created by bird on 14-9-23.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDLinkInviteConfig.h"
#import "NSString+URLEncode.h"
#import "KDWebViewController.h"
#import "KDWeiboAppDelegate.h"
#import "XTCompanyDelegate.h"
#import "NSDictionary+Additions.h"

@interface KDLinkInviteConfig()
@property (nonatomic, assign, readwrite) BOOL isExistInvite;
@property (nonatomic, retain, readwrite) NSURL *inviteUrl;
@property (nonatomic, retain) NSString *eid;
@end

@implementation KDLinkInviteConfig
static KDLinkInviteConfig *_KDLinkInviteConfig = nil;

+(KDLinkInviteConfig *)sharedInstance
{
    @synchronized(self)
	{
		if(_KDLinkInviteConfig == nil)
		{
			_KDLinkInviteConfig=[[KDLinkInviteConfig alloc] init];
            _KDLinkInviteConfig.code = LinkInviteErrorCode_Undefine;
		}
	}
	return _KDLinkInviteConfig;
}
- (void)dealloc{
    //KD_RELEASE_SAFELY(_eid);
    //KD_RELEASE_SAFELY(_openId);
    //KD_RELEASE_SAFELY(_extraInfo);
    //KD_RELEASE_SAFELY(_inviteUrl);
    //[super dealloc];
}
- (BOOL)isAvailableInviteFromUrl:(NSURL *)url{

    NSString    *absoluteString     = [[url absoluteString] decodeFromURL];
    BOOL        available           = ([absoluteString rangeOfString:@"kingdee_invite_eid"].location!=NSNotFound);

    if (available) {
        self.isExistInvite = available;
        self.inviteUrl = url;
        self.eid = [absoluteString searchAsURLQueryWithNeedle:@"kingdee_invite_eid="];
    }
    
    return available;
}
- (void)waitForCheck:(id)data{
    [self cancelInvite];
}
- (void)inviteFinished{

    self.presented = NO;
    self.isExistInvite = NO;
    self.inviteUrl = nil;
    self.code = LinkInviteErrorCode_Success;
    if (_delegate && [_delegate respondsToSelector:@selector(inviteFinishedBecauseOfAlreadyInCompany:)]) {
        [_delegate inviteFinishedBecauseOfAlreadyInCompany:[self eid]];
    }
}
- (void)cancelInvite{
    
    self.presented = NO;
    self.isExistInvite = NO;
    self.inviteUrl = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(inviteFinishedBecauseOfAlreadyInCompany:)]) {
        [_delegate inviteFinishedBecauseOfAlreadyInCompany:nil];
    }
}
- (void)goToInviteFormType:(Invite_From)type{
    if (!_isExistInvite || _inviteUrl == nil) {
        return;
    }
    NSString *absoluteString = [[_inviteUrl absoluteString] decodeFromURL];
    DLog(@"abolutestring = %@",absoluteString);
    if ([absoluteString rangeOfString:@"kingdee_invite_eid"].location!=NSNotFound) {
        
        if (type == Invite_From_Logined) {
            
            if (![self checkJoinByURL:absoluteString]){
                
                NSString *noSchemaString = [absoluteString stringByReplacingOccurrencesOfString:@"kdweibov4://" withString:@""];
                NSString *finalUrl = nil;
                if (![noSchemaString hasPrefix:@"http://"]&&![noSchemaString hasPrefix:@"https://"])
                {
                    finalUrl = [absoluteString stringByReplacingOccurrencesOfString:@"kdweibov4" withString:@"http"];
                }else {
                    finalUrl =  noSchemaString;
                }
                
                KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:finalUrl];
                webVC.hidesBottomBarWhenPushed = YES;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];//autorelease];
                
                [[KDWeiboAppDelegate getAppDelegate].window.rootViewController presentViewController:nav animated:YES completion:nil];
            }
            else{
                
                self.isExistInvite = NO;
                self.inviteUrl = nil;
            }
            
        }
        else if (type == Invite_From_Launched){
            
            UINavigationController *nav = (UINavigationController *)[[KDWeiboAppDelegate getAppDelegate].window rootViewController];
            if ([nav isKindOfClass:[UINavigationController class]]) {
                
                KDAuthViewController *loginViewController = (KDAuthViewController *)[[nav viewControllers] firstObject];
                if ([loginViewController isKindOfClass:[KDAuthViewController class]]) {
                    
                    NSString *eid = [absoluteString searchAsURLQueryWithNeedle:@"kingdee_invite_eid="];
                    NSString *token = [absoluteString searchAsURLQueryWithNeedle:@"token="];
                    [loginViewController invitedByPersonChannelWithToken:token toCompany:eid];
                }
            }
        }
        else if (type == Invite_From_Logining){
            
            NSString *eid = [absoluteString searchAsURLQueryWithNeedle:@"kingdee_invite_eid="];
            XTOpenCompanyListDataModel *companyList = [[XTOpenCompanyListDataModel alloc] initWithDictionary:[(BOSResultDataModel *)_extraInfo data]];// autorelease];
            if ([companyList checkInvitedCompany:eid]) {
                
                self.isExistInvite = NO;
                self.inviteUrl = nil;
                if (_delegate && [_delegate respondsToSelector:@selector(inviteFinishedBecauseOfAlreadyInCompany:)]) {
                    [_delegate inviteFinishedBecauseOfAlreadyInCompany:[self eid]];
                }
            }
            else{
                
                NSString *noSchemaString = [absoluteString stringByReplacingOccurrencesOfString:@"kdweibov4://" withString:@""];
                NSString *finalUrl = nil;
                if (![noSchemaString hasPrefix:@"http://"]&&![noSchemaString hasPrefix:@"https://"])
                {
                    finalUrl = [absoluteString stringByReplacingOccurrencesOfString:@"kdweibov4" withString:@"http"];
                }else {
                    finalUrl =  noSchemaString;
                }
                
                UINavigationController *rootNav = (UINavigationController *)[[KDWeiboAppDelegate getAppDelegate].window rootViewController];
                if ([rootNav isKindOfClass:[UINavigationController class]]) {
             
                    KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:finalUrl];// autorelease];
                    webVC.hidesBottomBarWhenPushed = YES;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];//autorelease];
                    
                    [rootNav presentViewController:nav animated:YES completion:nil];
                    _presented = YES;
                }
            }
        }
    }
}
- (NSString *)eid{
    if (_eid) {
        return _eid;
    }
    NSString *url = [[_inviteUrl absoluteString] decodeFromURL];
    return [url searchAsURLQueryWithNeedle:@"kingdee_invite_eid="];
}
- (BOOL)checkJoinByURL:(NSString *)url {
    BOOL can = NO;
    if(!KD_IS_BLANK_STR(url)) {
        if ([url rangeOfString:@"kingdee_invite_eid"].location!= NSNotFound) {
            NSString *eid = [url searchAsURLQueryWithNeedle:@"kingdee_invite_eid="];
            
            if (!KD_IS_BLANK_STR(eid) && [[KDManagerContext globalManagerContext].communityManager isJoinedCompany:eid]) {
                can = YES;
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@""
                                                                    message:ASLocalizedString(@"KDLinkInviteConfig_tips_exist")delegate:nil
                                                          cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                [alertView show];
//                [alertView release];
            }
            
        }
    }
    return can;
}
@end
