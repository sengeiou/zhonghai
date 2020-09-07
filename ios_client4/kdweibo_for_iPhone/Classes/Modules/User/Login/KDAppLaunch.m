//
//  KDAppLaunch.m
//  kdweibo
//
//  Created by bird on 14/11/19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDAppLaunch.h"
#import "BOSConfig.h"
//#import "KDLoginLogic.h"
#import "XTShareManager.h"
//#import "KDDetail.h"
//#import "KDOauthManager.h"
#import "XTOpenConfig.h"
#import "UINavigationController+Chat.h"

@interface KDAppLaunch () <UIAlertViewDelegate>
@property(nonatomic, strong) NSString *launchPath;
@end

@implementation KDAppLaunch

+ (KDAppLaunch *)instance {
    static dispatch_once_t onceToken;
    static KDAppLaunch *_KDAppLaunch;

    dispatch_once(&onceToken, ^{
        _KDAppLaunch = [[KDAppLaunch alloc] init];
    });

    return _KDAppLaunch;
}

- (BOOL)hasLaunchOption {
    return self.launchPath.length > 0;
}

- (BOOL)checkLaunchPathWithUrl:(NSURL *)url {
    NSString *launchPath = url.absoluteString;
    if (launchPath.length > 0 && [launchPath hasPrefix:@"cloudhub://"]) {
        self.launchPath = launchPath;
        return YES;
    }
    return NO;
}

- (BOOL)handleLaunch:(NSURL *)url {
    if ([self checkLaunchPathWithUrl:url]) {
        KDSchemeHostType host;
        id result = [self.launchPath externalSchemeInfoWithType:&host];

        if ([result isKindOfClass:[NSDictionary class]]) {

            NSString *token = result[@"token"];
            if (token.length > 0) {
//                [LOGIN_LOGIC saveTokenFromShare:token];
//                BOS_CONFIG.networkIdFromShare = result[@"networkId"];
//
//                NSString *strAppName = result[@"appName"];
//                if (strAppName) {
//                    BOS_CONFIG.thirdAppName = strAppName;
//                }
//
//                NSString *strAppId = result[@"appId"];
//                if (strAppId) {
//                    BOS_CONFIG.thirdAppId = strAppId;
//                }
//                
//                NSString *strSig = result[@"signature"];
//                if (strSig) {
//                    BOS_CONFIG.signatureFromShare = strSig;
//                }
//
//                // 登录逻辑
//                [LOGIN_MANAGER loginLogicByShare];
//                return YES;
//            }
//            if (host == KDSchemeHostType_Chat) {
//                [LOGIN_LOGIC saveTokenFromShare:token];
//                BOS_CONFIG. = result[@"msgId"];
//                
//                NSString *strAppName = result[@"appName"];
//                if (strAppName) {
//                    BOS_CONFIG.thirdAppName = strAppName;
//                }
//                
//                NSString *strAppId = result[@"appId"];
//                if (strAppId) {
//                    BOS_CONFIG.thirdAppId = strAppId;
//                }
//                
//                NSString *strSig = result[@"signature"];
//                if (strSig) {
//                    BOS_CONFIG.signatureFromShare = strSig;
//                }                <#statements#>
            }
        }
    }

    return NO;
}

- (BOOL)handleLaunchWhenLoginFinished {
    if ([self hasLaunchOption]) {
        KDSchemeHostType host;
        id result = [self.launchPath externalSchemeInfoWithType:&host];
        if (host == KDSchemeHostType_Share) {
            [self share:result];
        }
        else if (host == KDSchemeHostType_Start) {
            [self start:result];
        }
        else if (host == KDSchemeHostType_Chat) {
            [self chat:result];
        }
        else if (host == KDSchemeHostType_Profile) {
            [self profile:result];
        }
//        else if (host == KDSchemeHostType_Oauth) {
//            [self oauth:result];
//        }
        [[KDAppLaunch instance] setLaunchPath:nil];

        return YES;
    }
    return NO;
}

//- (void)oauth:(id)result {
//    NSString *params = result[@"p"];
//    [[KDOauthManager sharedManager] oauthWithUrl:params];
//}


- (void)share:(id)result {
    if (result) {
        [XTShareManager shareWithDictionary:result];
    }
}

- (void)chat:(id)result {
    if (result) {
        __block PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonDetailWithWebPersonId:result[@"userId"]];

        void (^gotoChatLogic)() = ^{
            XTShareDataModel *shareDM = [[XTShareDataModel alloc] init];
            shareDM.appId = result[@"appId"];
            shareDM.appName = result[@"appName"];
            GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
            if (group) {
                [[KDWeiboAppDelegate getAppDelegate].timelineViewController.navigationController pushToChatWithGroup:group shareDataModel:shareDM isPopToRoot:YES];
            }
            else {
                [[KDWeiboAppDelegate getAppDelegate].timelineViewController.navigationController pushToChatWithPerson:person shareDataModel:shareDM isPopToRoot:YES];
            }
        };

        if (!person) {
//            [LOGIN_LOGIC getPersonByEid:[BOSConfig sharedConfig].user.eid
//                              andOpenId:result[@"userId"]
//                                  token:[BOSConfig sharedConfig].user.token
//                             completion:^(BOOL succ, PersonSimpleDataModel *p) {
//                                 if (succ) {
//                                     person = p;
//                                     gotoChatLogic();
//                                 }
//                             }];
        }
        else {
            gotoChatLogic();
        }
    }
}

- (void)start:(id)result {
    if (result) {
    
        NSString *userId = result[@"userId"];
        NSString *networkId = result[@"eid"];
        if (userId.length > 0 && networkId.length > 0 && userId && networkId) {
            // 短信验证start
//            BOS_CONFIG.isMessageStart = YES;
//            BOS_CONFIG.messageStartUserId = userId;
//            BOS_CONFIG.messageStartNetworkId = networkId;
//            [self startFromMessageLogic];
        }
        
        if ([result[@"count"] isEqualToString:@"0"]) {
            [[KDWeiboAppDelegate getAppDelegate].tabBarController setSelectedIndex:2];
        }
        else if ([result[@"count"] isEqualToString:@"1"]) {
            [[KDWeiboAppDelegate getAppDelegate].tabBarController setSelectedIndex:0];
        }
    }
}

// 短信登录逻辑
- (void)startFromMessageLogic {

//    NSString *userId = BOS_CONFIG.messageStartUserId;
//    NSString *networkId = BOS_CONFIG.messageStartNetworkId;
//    
//    if (!userId || !networkId || [userId isEqualToString:@""] || [networkId isEqualToString:@""]) {
//        return;
//    }
//
//    // 已经登录
//    if (BOS_CONFIG.user.token.length > 0) {
//    
//        if (![BOS_CONFIG.user.wbUserId isEqualToString:userId]) {
//            // 当前user不是 message跳转user
//            [self cleanMessageStart];
//            return;
//        }
//        else {
//        
//            if ([BOS_CONFIG.user.wbNetworkId isEqualToString:networkId]) {
//                // 相同工作圈
//                [self cleanMessageStart];
//                return;
//            }
//            else {
//                // 不同工作圈 需要切圈
//                __weak __typeof(self) weakSelf = self;
//                [XTOpenConfig sharedConfig].needCheckPhoto = YES;
//                CompanyDataModel *companyDataModel = [[CompanyDataModel alloc] init];
//                companyDataModel.wbNetworkId = networkId;
//                companyDataModel.eid = networkId;
//                [LOGIN_MANAGER changeNetWork:companyDataModel finished:^(BOOL finished) {
//                    [weakSelf cleanMessageStart];
//                }];
//                return;
//            }
//        }
//    }
//    // 未登录
//    else {
//        return;
//    }
}

- (void)cleanMessageStart {
//
//    BOS_CONFIG.isMessageStart = NO;
//    BOS_CONFIG.messageStartUserId = @"";
//    BOS_CONFIG.messageStartNetworkId = @"";

}


- (void)profile:(id)result {
    if (result) {
        NSString *userId = result[@"id"];
        if (userId) {
            [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
            if ([KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex != 0) {
                [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
            }
//            [KDDetail toDetailWithPersonId:userId inController:[KDWeiboAppDelegate getAppDelegate].timelineViewController];
        }
    }
}

@end
