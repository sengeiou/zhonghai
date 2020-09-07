//
//  KDSignInViewController+Share.m
//  kdweibo
//
//  Created by shifking on 16/1/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController+Share.h"
#import "KDSignInRecord.h"
#import <objc/runtime.h>
#import "KDSocialsShareManager.h"
#import "KDSignInShareSheetView.h"
#import "KDSignInClient.h"
#import "BOSConfig.h"
#import "XTShareManager.h"
#import "NSData+Base64.h"
//#import "KDURLPathManager.h"
#import "NSString+URLEncode.h"
#import "KDForwardChooseViewController.h"
static const char kAssociatedkey;
static const char kSearchSignInShareUrlClientKey;
static const char kExtraRemarkKey;


@interface KDSignInViewController()
@property (nonatomic, strong ) KDSignInClient *searchSignInShareUrlClient;
@property (strong , nonatomic) NSString       *extraRemark;

@end

@implementation KDSignInViewController (Share)

#pragma mark - public methods
- (BOOL)OfficeSignInSuccessToShareToWXWithRecord:(KDSignInRecord *)record {
    if (record.extraRemark && ![record.extraRemark isKindOfClass:[NSNull class]] && record.extraRemark.length > 0) {
        [KDPopup hideHUDInView:self.view];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:record.extraRemark delegate:self cancelButtonTitle:ASLocalizedString(@"取消") otherButtonTitles:ASLocalizedString(@"分享我的奋斗史到朋友圈"), nil];
        alert.tag = KDSignInShareAlertTag;
        [alert show];
        
        objc_setAssociatedObject(alert, &kAssociatedkey, record, OBJC_ASSOCIATION_RETAIN);
        
        return YES;
    }
    return NO;
}

/**
 *  发送微博
 */
- (void)sendWeibo:(KDSignInRecord *)record {
    [KDEventAnalysis event:event_signin_record_share];
    if (record.status == -1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"当前签到记录未能上传，请稍后再试") delegate:nil cancelButtonTitle:ASLocalizedString(@"知道了") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    KDSignInShareSheetView *shareSheetView = [[KDSignInShareSheetView alloc] initWithFrame:self.navigationController.view.frame];
    shareSheetView.record = record;
    shareSheetView.shareBlock = ^(KDSignInShareViewType type,KDSignInRecord *record){
        if(type == KDSignInShareViewType_friend) {
            [self shareSignInRecordWithRecord:record type:KDSignInShareViewType_friend];
        }
        else if(type == KDSignInShareViewType_buluo) {
            [self shareSignInRecordWithRecord:record type:KDSignInShareViewType_buluo];
        }
        else if(type == KDSignInShareViewType_chat) {
            [self shareSignInRecordWithRecord:record type:KDSignInShareViewType_chat];
        }
    };
    [self.tabBarController.view addSubview:shareSheetView];
}

- (void)shareSignInRecordToWXWithAlert:(UIAlertView *)alert {
    [KDPopup showHUDInView:self.view];
    KDSignInRecord *record = objc_getAssociatedObject(alert, &kAssociatedkey);
    [self searchSignInShareUrlServerWithSignInRecord:record];
}

#pragma mark - private methods

- (void)shareViewToChoosePersonWithRecord:(KDSignInRecord *)record urlStr:(NSString *)urlStr
{
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"app_btn_sgin_normal"], 0.3);
    NSString *imageStr = [imageData base64EncodedString];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@(ShareMessageApplication) forKey:@"shareType"];
    [dict setObject:imageStr forKey:@"thumbData"];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:record.singinTime ? record.singinTime :[NSDate date]];
    NSInteger hour = [weekdayComponents hour];
    NSInteger minute = [weekdayComponents minute];
    
    NSString *str = [NSString stringWithFormat:ASLocalizedString(@"%@的位置分享"),[BOSConfig sharedConfig].user.name];
    [dict setObject:str forKey:@"title"];
    NSString *contentStr = [NSString stringWithFormat:ASLocalizedString(@"%02ld:%02ld 我在%@"),(long) hour, (long) minute,record.featurename];
    [dict setObject:contentStr forKey:@"content"];
    [dict setObject:str forKey:@"theme"];
    [dict setObject:contentStr forKey:@"cellContent"];
    [dict setObject:urlStr forKey:@"webpageUrl"];
    [dict setObject:@"all" forKey:@"shareObject"];
    [dict setObject:ASLocalizedString(@"签到") forKey:@"appName"];
    [dict setObject:kSignInPublicAccountID forKey:@"appId"];
    [XTShareManager shareWithDictionary:dict];
}

- (void)shareViewToBuluoWithRecord:(KDSignInRecord *)record urlStr:(NSString *)urlStr
{
    if(record.status == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"KDSignInViewController_Upload_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
        [alert show];
        return;
    }
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeShareSign];
    draft.content = (record.mbShare && ![record.mbShare isKindOfClass:[NSNull class]])?record.mbShare :  [NSString stringWithFormat:ASLocalizedString(@"KDSignInViewController_draft_content"),[record.singinTime formatWithFormatter:KD_DATE_TIME],record.featurename];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = record.latitude;
    coordinate.longitude = record.longitude;
    draft.coordinate = coordinate;
    draft.address = record.featurename;
    pvc.draft = draft;
    
    UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:pvc];
    [self presentViewController:nav animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark - service response

- (void)searchSignInShareUrlServerWithSignInRecord:(KDSignInRecord *)record {
    [self.searchSignInShareUrlClient searchAtteShareLinkWithRecord:record];
    if (record.extraRemark && ![record.extraRemark isKindOfClass:[NSNull class]] && record.extraRemark.length > 0) {
        self.extraRemark = [record.extraRemark copy];
    }
}


- (void)searchSignInShareUrlDidReceived:(KDSignInClient *)client result:(id)result {
    [KDPopup hideHUDInView:self.view];
    if (result && ![result isKindOfClass:[NSNull class]]) {
        BOOL success = [result[@"success"] boolValue];
        if (success) {
            NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"app_btn_sgin_normal"], 0.3);
            [[KDSocialsShareManager shareSocialsShareManager] shareToWechatWithTitle:(self.extraRemark && self.extraRemark.length > 0) ? self.extraRemark : ASLocalizedString(@"早知道加班总是难免的，我又何苦一往情深")
                                                                         description:@""
                                                                           thumbData:imageData
                                                                          webpageUrl:result[@"data"]
                                                                          isTimeline:YES];
        } else {
            [KDPopup showHUDToast:ASLocalizedString(@"分享朋友圈失败") inView:self.view];
        }
    }
    else {
        [KDPopup showHUDToast:ASLocalizedString(@"分享朋友圈失败") inView:self.view];
    }
}

- (void)shareSignInRecordWithRecord:(KDSignInRecord *)record type:(KDSignInShareViewType)type
{
    NSString *kdweiboUrlStr = [NSString stringWithFormat:@"%@/attendancelight/attendanceshare.json?clockid=%@",[[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getServerBaseURL],record.singinId];
    NSString* encodedString = [kdweiboUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if(type == KDSignInShareViewType_friend) {
        [self shareViewToChoosePersonWithRecord:record urlStr:encodedString];
    }
    else if(type == KDSignInShareViewType_buluo) {
        [self shareViewToBuluoWithRecord:record urlStr:encodedString];
    }
    else if(type == KDSignInShareViewType_chat) {
        NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"app_btn_sgin_normal"], 0.3);
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *weekdayComponents =
        [gregorian components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:record.singinTime ? record.singinTime :[NSDate date]];
        NSInteger hour = [weekdayComponents hour];
        NSInteger minute = [weekdayComponents minute];
        NSString *contentStr = [NSString stringWithFormat:ASLocalizedString(@"%02ld:%02ld 我在%@"),(long) hour, (long) minute,record.featurename];
        [[KDSocialsShareManager shareSocialsShareManager] shareToWechatWithTitle:contentStr
                                                                     description:@""
                                                                       thumbData:imageData
                                                                      webpageUrl:encodedString
                                                                      isTimeline:YES];
    }
}


#pragma mark - setter & getter
- (KDSignInClient *)searchSignInShareUrlClient {
    KDSignInClient *client = objc_getAssociatedObject(self, &kSearchSignInShareUrlClientKey);
    if (client) return client;
    
    client = [[KDSignInClient alloc] initWithTarget:self action:@selector(searchSignInShareUrlDidReceived:result:)];
    
    objc_setAssociatedObject(self, &kSearchSignInShareUrlClientKey, client, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return client;
}


- (void)setExtraRemark:(NSString *)extraRemark {
    objc_setAssociatedObject(self, &kExtraRemarkKey, extraRemark, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)extraRemark {
    return objc_getAssociatedObject(self, &kExtraRemarkKey);
}


@end
