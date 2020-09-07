//
//  GroupListDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface GroupListDataModel : BOSBaseDataModel

@property (nonatomic,assign) int count;//会话总数
@property (nonatomic,assign) int unreadTotal;//会话总数
@property (nonatomic,assign) BOOL more;//是否还有下一页
@property (nonatomic,copy) NSString *updateTime;//会话更新时间
@property (nonatomic,strong) NSMutableArray *list;//会话列表，GroupDataModel数组
@property (nonatomic,strong) NSMutableArray *publicMember;//公共号成员，只有在公共号模式下才有数据


@end
