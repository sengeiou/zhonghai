//
//  KDStatusDAOImpl.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-5.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseDAOImpl.h"
#import "KDStatusDAO.h"

@interface KDStatusDAOImpl : KDBaseDAOImpl <KDStatusDAO>

//zgbin 获取单例对象,为了给数据库加字段
+ (KDStatusDAOImpl *)sharedStatusDAOInstance;

- (void)addField;
- (void)addFieldWithFMDatabase:(FMDatabase *)fmdb;
//end

@end

