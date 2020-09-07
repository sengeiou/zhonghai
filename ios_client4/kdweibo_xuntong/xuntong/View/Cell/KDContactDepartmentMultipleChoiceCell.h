//
//  KDContactDepartmentMultipleChoiceCell.h
//  kdweibo
//
//  Created by shen kuikui on 14-5-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactPersonMultipleChoiceCell.h"

@interface KDContactDepartmentMultipleChoiceCell : XTContactPersonMultipleChoiceCell
@property(nonatomic,copy)NSString *orgId;
- (void)setDepartmentName:(NSString *)name;

@end
