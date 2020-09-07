//
//  SendDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface SendDataModel : BOSBaseDataModel

@property (nonatomic,copy) NSString *groupId;
@property (nonatomic,copy) NSString *msgId;
@property (nonatomic,copy) NSString *sendTime;

@end
