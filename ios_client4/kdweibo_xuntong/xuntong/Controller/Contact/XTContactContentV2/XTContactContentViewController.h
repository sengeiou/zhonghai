//
//  XTContactContentViewController.h
//  kdweibo
//  通讯录控制器
//  Created by weihao_xu on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTContentViewController.h"

typedef NS_ENUM(NSUInteger, XTContactTopViewCellType) {
    XTContactTopViewCellTypeOrgan = 0x00,
    XTContactTopViewCellTypeGroup = 0x01,
    XTContactTopViewCellTypePublic = 0x02,
};

@interface XTContactContentViewController : XTContentViewController

- (void)toOrganizationViewControllerWithOrgId:(NSString *)orgId andPartnerType:(NSInteger)partnerType;
@end
