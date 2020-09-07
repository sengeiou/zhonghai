//
//  KDBaseInvitationViewController.m
//  kdweibo
//
//  Created by AlanWong on 14-7-23.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDBaseInvitationViewController.h"
#import "KDCommunityManager.h"
#import "BOSConfig.h"
#import "MBProgressHUD+Add.h"
@interface KDBaseInvitationViewController ()<UIAlertViewDelegate>


@end

@implementation KDBaseInvitationViewController

- (void)showHud:(BOOL)animated{
    if (_hud == nil) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:animated];;
    }else {
        [_hud show:animated];
    }
}
- (void)hideHud:(BOOL)animated{
    if (_hud) {
        [_hud hide:YES];
    }
}

-(void)getUrlFailed{
  //  [self hideHud:YES];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDBaseInvitationViewController_get_link_fail")delegate:self
                                              cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
    [alertView show];
    
}

- (void)setButtonEnable:(BOOL)isEnable buttonCount:(NSUInteger)count{
 //   [self hideHud:YES];
    
    for (int i = 0 ; i < count; i++) {
        UIButton * button = (UIButton * )[self.view viewWithTag:1000+i];
        button.enabled = isEnable;
    }
}


- (void)getInvitationURLWithCompleteBlock:(KDServiceActionDidCompleteBlock)completionBlock source:(NSString *)type{
    KDQuery *query = [KDQuery query];
    [query setParameter:@"eid" stringValue:[BOSConfig sharedConfig].user.eid ];
    [query setParameter:@"openid" stringValue:[BOSConfig sharedConfig].user.openId];
    [query setParameter:@"type" stringValue:self.type == 1?@"1":@"0"];
    //暂时没有用，随便传一个
    [query setParameter:@"ticket" stringValue:@"123"];
    [query setParameter:@"source_type" stringValue:type];
    
    [KDServiceActionInvoker invokeWithSender:self
                                  actionPath:@"/network/:getInvitationURL"
                                       query:query
                                 configBlock:nil completionBlock:completionBlock];
}

#pragma mark -
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (!self.canShare) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
