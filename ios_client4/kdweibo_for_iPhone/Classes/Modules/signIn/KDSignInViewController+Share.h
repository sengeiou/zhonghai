//
//  KDSignInViewController+Share.h
//  kdweibo
//
//  Created by shifking on 16/1/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController.h"
#define KDSignInShareAlertTag 800001

@class KDSignInRecord;
@interface KDSignInViewController (Share)
- (void)sendWeibo:(KDSignInRecord *)record ;
- (BOOL)OfficeSignInSuccessToShareToWXWithRecord:(KDSignInRecord *)record;
- (void)shareSignInRecordToWXWithAlert:(UIAlertView *)alert;
@end
