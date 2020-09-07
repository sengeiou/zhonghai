//
//  KDSchema.m
//  kdweibo
//
//  Created by Gil on 15/8/27.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSchema.h"
#import "NSDictionary+Additions.h"
#import "KDTaskDiscussViewController.h"
#import "KDTodoListViewController.h"
#import "KDSignInViewController.h"
#import "KDAddOrUpdateSignInPointController.h"

#import "BOSSetting.h"
#import "KDApplicationQueryAppsHelper.h"

#import "XTChatViewController.h"
#import "KDCreateTaskViewController.h"
#import "XTFileDetailViewController.h"

#import "XTOrganizationViewController.h"
#import "KDAppDetailViewController.h"
#import "NSString+URLEncode.h"

@interface KDSchema () <XTChooseContentViewControllerDelegate>
@property (weak, nonatomic) UIViewController *controller;

+ (KDSchema *)instance;
@end

@implementation KDSchema

+ (KDSchema *)instance {
    static dispatch_once_t onceToken;
    static KDSchema *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[KDSchema alloc] init];
    });
    
    return instance;
}

+ (KDSchemeHostType)openWithUrl:(NSString *)url
                     controller:(UIViewController *)controller {
   
    [KDSchema instance].controller = controller;
    
    KDSchemeHostType t = KDSchemeHostType_NONE;

	if (url.length > 0) {
        NSDictionary *dic = [url internalSchemeInfoWithType:&t];
        
        if (t == KDSchemeHostType_Todo) {
            NSString *taskId = dic[@"id"];
            KDTaskDiscussViewController *ctr = [[KDTaskDiscussViewController alloc] initWithTaskId:taskId];
            ctr.hidesBottomBarWhenPushed = YES;
            [controller.navigationController pushViewController:ctr animated:YES];
        }
        else if (t == KDSchemeHostType_Todolist) {
            NSString *type = [dic stringForKey:@"type"];
            TodoType tdType = kTodoTypeUndo;
            if (type.length == 0 || [type isEqualToString:@"undo"]) {
            }
            else if ([type isEqualToString:@"done"]) {
                tdType = kTodoTypeDone;
            }
            else if ([type isEqualToString:@"ignore"]) {
                tdType = kTodoTypeIgnore;
            }
            KDTodoListViewController *ctr = [[KDTodoListViewController alloc] initWithTodoType:tdType];
            ctr.hidesBottomBarWhenPushed = YES;
            [controller.navigationController pushViewController:ctr animated:YES];
        }
        else if (t == KDSchemeHostType_Todonew) {
            KDCreateTaskViewController *ctr = [[KDCreateTaskViewController alloc] init];
            ctr.title = @"创建任务";
            ctr.hidesBottomBarWhenPushed = YES;
            [controller.navigationController pushViewController:ctr animated:YES];
        }
        else if (t == KDSchemeHostType_Chat) {
            XTChatViewController *chatViewController = nil;
            if ([dic objectNotNSNullForKey:@"groupId"]) {
                GroupDataModel *gdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:[dic objectNotNSNullForKey:@"groupId"]];
                if (gdm) {
                    chatViewController = [[XTChatViewController alloc] initWithGroup:gdm pubAccount:nil mode:ChatPrivateMode];
                }
            }
            else if ([dic objectNotNSNullForKey:@"personId"]) {
                PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:[dic objectNotNSNullForKey:@"personId"]];
                if (person) {
                    GroupDataModel *gdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
                    if (gdm) {
                        chatViewController = [[XTChatViewController alloc] initWithGroup:gdm pubAccount:nil mode:ChatPrivateMode];
                    }
                    else {
                        chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
                    }
                }
            }
            if (chatViewController) {
                chatViewController.hidesBottomBarWhenPushed = YES;
                if ([dic objectNotNSNullForKey:@"msgId"]) {
                    chatViewController.strScrollToMsgId = [dic objectNotNSNullForKey:@"msgId"];
                }
//                if ([dic objectNotNSNullForKey:@"draft"]) {
//                    chatViewController.draft = [dic objectNotNSNullForKey:@"draft"];
//                }
                [controller.navigationController pushViewController:chatViewController animated:YES];
            }
        }
//        else if (t == KDSchemeHostType_PersonalSetting) {
//            KDProfileViewController *profile = [[KDProfileViewController alloc] init];
//            profile.hidesBottomBarWhenPushed = YES;
//            [controller.navigationController pushViewController:profile animated:YES];
//        }
//        else if (t == KDSchemeHostType_Signin) {
//            KDSignInViewController *signInController = [[KDSignInViewController alloc] init];
//            signInController.hidesBottomBarWhenPushed = YES;
//            [controller.navigationController pushViewController:signInController animated:YES];
//        }
        else if (t == KDSchemeHostType_Status) {
//            url = [url stringByReplacingOccurrencesOfString:@"cloudhub://status?id" withString:@"kdweibo://status?statusId"];
//            url = [url appendParamsForShare];
//            NSURL *realUrl = [NSURL URLWithString:url];
//            [KDAppOpen openURL:realUrl controller:controller];
            
            if ([BOSConfig sharedConfig].user.partnerType == 1) {
                [KDPopup showHUDToast:ASLocalizedString(@"NO_Privilege")];
                return t;
            }
            NSString *statusId = [dic objectForKey:@"id"];
            if(![statusId isKindOfClass:[NSNull class]] && statusId.length > 0) {
                KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatusID:statusId];
                [controller.navigationController pushViewController:sdvc animated:YES];
            }

            
        }
//        else if (t == KDSchemeHostType_Unknow) {
//            if ([url hasPrefix:@"kdweibo://"]) {
//                url = [url appendParamsForShare];
//            }
//            NSURL *realUrl = [NSURL URLWithString:url];
//            [KDAppOpen openURL:realUrl controller:controller];
//        }
//        else if (t == KDSchemeHostType_Invite) {
//            if ([[BOSSetting sharedSetting] isIntergrationMode]) {
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"该团队由管理员设置为后台维护，不支持移动端邀请操作。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                [alertView show];
//            }
//            else {
//                KDAddColleaguesVC *addColleagues = [[KDAddColleaguesVC alloc] init];
//                addColleagues.source = KDAddColleaguesSourceScheme;
//                UINavigationController *addColleaguesNav = [[UINavigationController alloc] initWithRootViewController:addColleagues];
//                addColleaguesNav.delegate = [KDNavigationManager sharedNavigationManager];
//                //在present动画结束之前锁住不让点击，因为用户点击蒙层过早会出现bug。
//                addColleaguesNav.view.userInteractionEnabled = NO;
//                [controller presentViewController:addColleaguesNav animated:YES completion:^{
//                    addColleaguesNav.view.userInteractionEnabled = YES;
//                }];
//            }
//        }
        else if (t == KDSchemeHostType_VoiceMeeting) {
            if ([controller isKindOfClass:[XTChatViewController class]]) {
                XTChatViewController *chatViewController = (XTChatViewController *)controller;
                [chatViewController goToMultiVoice];
            }
        }
//        else if (t == KDSchemeHostType_CreateVoiceMeeting) {
//            XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentCreate];
//            contentViewController.delegate = [KDSchema instance];
//            UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
//            contentViewController.bGoMultiVoiceAfterCreateGroup = YES;
//            contentNav.delegate = [KDNavigationManager sharedNavigationManager];
//            [[KDWeiboAppDelegate getAppDelegate].tabBarController presentViewController:contentNav animated:YES completion:nil];
//        }
//        else if (t == KDSchemeHostType_Profile) {
//            NSString *userId = dic[@"id"];
//            if (userId) {
//                [KDDetail toDetailWithPersonId:userId inController:controller];
//            }
//        }
        else if (t == KDSchemeHostType_FilePrevew) {
            NSString *fileId = [dic objectForKey:@"fileid"];
            if ([fileId isKindOfClass:[NSString class]] && fileId.length > 0) {
                NSString *fileName = [dic objectForKey:@"filename"];
                if (![fileName isKindOfClass:[NSString class]] || fileName.length == 0) {
                    fileName = @"";
                }
                NSString *fileExt = [dic objectForKey:@"fileext"];
                if (![fileExt isKindOfClass:[NSString class]] || fileExt.length == 0) {
                    fileExt = @"";
                }
                NSString *fileSize = [dic objectForKey:@"filesize"];
                if (![fileSize isKindOfClass:[NSString class]] || fileSize.length == 0) {
                    fileSize = @"";
                }
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fileId,@"id", fileName,@"fileName", fileExt,@"fileExt", fileSize, @"length",nil];
                FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
                XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
                filePreviewVC.hidesBottomBarWhenPushed = YES;
                [controller.navigationController pushViewController:filePreviewVC animated:YES];
            }
        }
        else if (t == KDSchemeHostType_LightApp) {
            NSString *url = [[dic objectForKey:@"urlparam"] decodeFromURL];
            NSString *appid = [dic objectForKey:@"appid"];
            [self openLightAppWithUrl:url appId:appid title:@"" share:nil controller:controller];
        }
//        else if (t == KDSchemeHostType_EnterpriseAuth) {
//            KDEnterpriseAuthenticationViewController *EAVC = [[KDEnterpriseAuthenticationViewController alloc] init];
//            EAVC.hidesBottomBarWhenPushed = YES;
//            [controller.navigationController pushViewController:EAVC animated:YES];
//        }
//        else if (t == KDSchemeHostType_OrgList) {
//            [KDEventAnalysis event:event_contact_mem_open];
//            NSString *orgId = [dic objectForKey:@"id"];
//            if (![orgId isKindOfClass:[NSString class]] || orgId.length == 0) {
//                orgId = @"";
//            }
//            XTOrganizationViewController *viewController = [[XTOrganizationViewController alloc] initFromAddressBookWithOrgId:orgId];
//            viewController.hidesBottomBarWhenPushed = YES;
//            [controller.navigationController pushViewController:viewController animated:YES];
//        }
//        else if (t == KDSchemeHostType_Appdetail) {
//            NSString *appid = [dic objectForKey:@"appid"];
//            NSString *appname = [dic objectForKey:@"appname"];
//            KDAppDetailViewController *detailVC = [[KDAppDetailViewController alloc] initWithAppId:appid appName:appname];
//            detailVC.hidesBottomBarWhenPushed = YES;
//            [controller.navigationController pushViewController:detailVC animated:YES];
//        }
//        else if (t == KDSchemeHostType_Appcategory) {
//            NSString *tagid = [dic objectForKey:@"tagid"];
//            NSString *tagname = [dic objectForKey:@"tagname"];
//            KDAppSubCategoryViewController *subCateVC = [[KDAppSubCategoryViewController alloc] init];
//            KDAppCategoryDataModel *categoryModel = [[KDAppCategoryDataModel alloc] init];
//            categoryModel.tagId = tagid;
//            categoryModel.tagName = tagname;
//            subCateVC.appCategoryDataModel = categoryModel;
//            subCateVC.hidesBottomBarWhenPushed = YES;
//            [controller.navigationController pushViewController:subCateVC animated:YES];
//            
//        }
//        else if (t == KDSchemeHostType_LightApp) {
//            NSString *url = [dic objectForKey:@"urlparam"];
//            NSString *appid = [dic objectForKey:@"appid"];
//            [self openLightAppWithUrl:url appId:appid title:@"" share:nil controller:controller];
//        }
    }

	return t;
}

+ (KDSchemeHostType)openWithUrl:(NSString *)url
                          appId:(NSString *)appId
                          title:(NSString *)title
                          share:(MessageNewsEachDataModel *)share
                     controller:(UIViewController *)controller {
	KDSchemeHostType t = KDSchemeHostType_NONE;

	if (url.length > 0) {
        t = [self openWithUrl:url controller:controller];
        if (t == KDSchemeHostType_Unknow) {
            if ([url hasPrefix:@"kdweibo://"]) {
                url = [url appendParamsForShare];
            }
            NSURL *realUrl = [NSURL URLWithString:url];
//            [KDAppOpen openURL:realUrl controller:controller];
        }
        else if (t == KDSchemeHostType_HTTP || t == KDSchemeHostType_HTTPS || t == KDSchemeHostType_NOTURI) {
            //可能是轻应用
            [self openLightAppWithUrl:url appId:appId title:title share:share controller:controller];
        }
	}
	else {
		//可能是轻应用
		[self openLightAppWithUrl:@"" appId:appId title:title share:share controller:controller];
	}

	return t;
}

+ (void)openLightAppWithUrl:(NSString *)url
                      appId:(NSString *)appId
                      title:(NSString *)title
                      share:(MessageNewsEachDataModel *)share
                 controller:(UIViewController *)controller {
	if (url.length == 0 && appId.length == 0) {
		return;
	}
    
	KDWebViewController *webVC = nil;
	if (appId.length > 0) {
		webVC = [[KDWebViewController alloc] initWithUrlString:url appId:appId];
	}
	else {
        GroupDataModel *group = nil;
        if ([controller isKindOfClass:[XTChatViewController class]]) {
            group = ((XTChatViewController *)controller).group;
        }
      
        if (group) {
            if ([group isPublicGroup]) {
                PersonSimpleDataModel *person = [group firstParticipant];
                webVC = [[KDWebViewController alloc] initWithUrlString:url pubAccId:person.personId menuId:@"pubmessagelink"];
            }
            else {
                webVC = [[KDWebViewController alloc] initWithUrlString:url];
            }
        }
	}

	if (webVC) {
        GroupDataModel *group = nil;
        if ([controller isKindOfClass:[XTChatViewController class]]) {
            group = ((XTChatViewController *)controller).group;
        }
    
        if (group) {
            PersonSimpleDataModel *person = [group firstParticipant];
            
//            if ([person isPublicAccount]) {
//                KDPublicAccountDataModel *pubAcct = (KDPublicAccountDataModel *)person;
//                if (pubAcct.share) {
//                    //传入数据，用于分享
//                    share.name = person.personName;
//                    share. = person.photoUrl;
//                    XTShareDataModel *shareData=  [[XTShareDataModel alloc] initWithNewsModel:share];
//                    webVC.shareModel = shareData;
//                }
//                else {
//                    webVC.canshare = NO;
//                }
//            } else if (share.f_appName && share.f_thumbUrl){
//                //通过点击转发新闻触发的跳转
//                KDWebShareDataModel *shareData=  [[KDWebShareDataModel alloc] initWithNewsModel:share];
//                webVC.shareModel = shareData;
//            }
            webVC.title = title;
            webVC.hidesBottomBarWhenPushed = YES;
            if (appId.length > 0) {
                __weak __typeof(webVC) weak_webvc = webVC;
                webVC.getLightAppBlock = ^() {
//                    if(weak_webvc && !weak_webvc.bPushed){
                        [controller.navigationController pushViewController:weak_webvc animated:YES];
//                    }
                };
            }
            else {
                [controller.navigationController pushViewController:webVC animated:YES];
            }
        }else{
//            if (share.f_appName && share.f_thumbUrl){
//                //通过点击转发新闻触发的跳转
//                KDWebShareDataModel *shareData=  [[KDWebShareDataModel alloc] initWithNewsModel:share];
//                webVC.shareModel = shareData;
//            }

            webVC.title = title;
            webVC.hidesBottomBarWhenPushed = YES;
            if (appId.length > 0) {
                __weak __typeof(webVC) weak_webvc = webVC;
                webVC.getLightAppBlock = ^() {
//                    if(weak_webvc && !weak_webvc.bPushed){
                        [controller.navigationController pushViewController:weak_webvc animated:YES];
//                    }
                };
            }
            else {
                [controller.navigationController pushViewController:webVC animated:YES];
            }
        }
	}
}

#pragma mark - XTChooseContentViewControllerDelegate -

- (void)chooseContentView:(XTChooseContentViewController *)controller group:(GroupDataModel *)group {
//    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:group pubAccount:nil mode:ChatPrivateMode];
//    chatViewController.hidesBottomBarWhenPushed = YES;
//    chatViewController.bGoMultiVoiceAfterCreateGroup = controller.bGoMultiVoiceAfterCreateGroup;
//    [self.controller.navigationController pushViewController:chatViewController animated:YES];
}

- (void)chooseContentView:(XTChooseContentViewController *)controller person:(PersonSimpleDataModel *)person {
//    XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithParticipant:person];
//    chatViewController.hidesBottomBarWhenPushed = YES;
//    chatViewController.bGoMultiVoiceAfterCreateGroup = controller.bGoMultiVoiceAfterCreateGroup;
//    [self.controller.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - 进入前到编辑页面 -

+ (void)findAttendSet4EditWithAttendsetid:(NSString *)attendSetId
	controller:(UIViewController *)controller {
	[MBProgressHUD showHUDAddedTo:controller.view animated:YES];
	KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
		[MBProgressHUD hideAllHUDsForView:controller.view animated:YES];
		if (results) {
			if ([results[@"success"] boolValue]) {
				KDSignInPoint *signInPoint = [[KDSignInPoint alloc] initWithDictionary:results[@"data"]];
				KDAddOrUpdateSignInPointController *signInPointController = [[KDAddOrUpdateSignInPointController alloc] init];
				signInPointController.signInPoint = signInPoint;
				signInPointController.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_update;
                //管理签到迁移，暂时屏蔽
				//signInPointController.sourceType = KDAddOrUpdateSignInPointSource_signinPointController;
                signInPointController.hidesBottomBarWhenPushed = YES;
				[controller.navigationController pushViewController:signInPointController animated:YES];
			}
			else {
				[KDSchema showErrorMessage:@"获取数据失败" seconds:1.0f view:controller.view];
			}
		}
		else {
			[KDSchema showErrorMessage:@"获取数据失败" seconds:1.0f view:controller.view];
		}
	};

	KDQuery *query = [KDQuery query];
	[query setParameter:@"attendSetId" stringValue:attendSetId];
	[KDServiceActionInvoker invokeWithSender:nil
                                  actionPath:@"/signId/:findAttendSet4Edit"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}

+ (void)showErrorMessage:(NSString *)message
                 seconds:(double)delayInSeconds
                    view:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = 0;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:delayInSeconds];
}

+ (void)goingToAddOrUpdateSignInPointControllerWithLat:(double)lat
                                                   lon:(double)lon
                                              position:(NSString *)position
                                               address:(NSString *)address
                                            controller:(UIViewController *)controller {
    KDSignInPoint *signInPoint = [[KDSignInPoint alloc] init];
    signInPoint.lat = lat;
    signInPoint.lng = lon;
    signInPoint.positionName = position;
    signInPoint.detailAddress = address;
    
    KDAddOrUpdateSignInPointController *signInPointController = [[KDAddOrUpdateSignInPointController alloc] init];
    signInPointController.addOrUpdateSignInPointType = KDAddOrUpdateSignInPointType_add;
    signInPointController.signInPoint = signInPoint;
    //管理签到迁移，暂时屏蔽
    //signInPointController.sourceType = KDAddOrUpdateSignInPointSource_signInControllerCell;
    signInPointController.hidesBottomBarWhenPushed = YES;
    [controller.navigationController pushViewController:signInPointController animated:YES];
}

@end
