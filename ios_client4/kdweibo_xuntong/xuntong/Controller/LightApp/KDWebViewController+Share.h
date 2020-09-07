//
//  KDWebViewController+Share.h
//  kdweibo
//
//  Created by Gil on 14-10-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController.h"
#define Success				@"success"
#define ErrorMessage		@"error"
#define ErrorCode			@"errorCode"
#define Data				@"data"

@interface KDWebViewController (Share)
- (void)geturltoweb;
- (void)showShareActionSheet;
- (BOOL)shareActionWithTitle:(NSString *)title;
- (void)shareToCommunity;
- (void)shareToSocial ;
- (void)shareToSocialWithTitle:(NSString *)title image:(UIImage *)image detail:(NSString *)detail;
@end
