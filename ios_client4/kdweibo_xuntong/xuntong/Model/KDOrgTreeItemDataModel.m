//
//  IDOrgTreeDataModel.m
//  kdweibo
//
//  Created by KongBo on 15/9/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDOrgTreeItemDataModel.h"

@implementation KDOrgTreeItemDataModel
-(BOOL)isEqual:(id)object
{
    KDOrgTreeItemDataModel *org = object;
    return [self.orgId isEqualToString:org.orgId];
}
@end
