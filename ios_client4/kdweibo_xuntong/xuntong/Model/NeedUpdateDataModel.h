//
//  UnreadTotalDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

@class PubAccountList;
@interface NeedUpdateDataModel : BOSBaseDataModel 
@property (nonatomic,assign) BOOL flag;//是否需要更新
@property (nonatomic,strong) PubAccountList *pubAccount;
@end

@interface PubAccountList : BOSBaseDataModel
@property (nonatomic,assign) BOOL flag;//是否需要更新
@property (nonatomic,assign) int unreadTotal;
@property (nonatomic,strong) NSMutableArray *list;
@end

@interface PubAccount :  BOSBaseDataModel
@property (nonatomic,assign) BOOL flag;//是否需要更新
@property (nonatomic,copy) NSString *publicId;//公众号ID
@property (nonatomic,assign) int unreadCount;//公众号未读数
@end
