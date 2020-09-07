//
//  ContactConfig.h
//  ContactsLite
//
//  Created by Gil on 12-11-30.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "PersonDataModel.h"

@class PubAccountListDataModel;
@class NeedUpdateDataModel;
@interface ContactConfig : NSObject {
    
}

//更新标志
@property (nonatomic,strong) NeedUpdateDataModel *needUpdateDataModel;

//---------------------------------
//需要持久化的
//当前的登录用户
//@property (nonatomic,strong) PersonDataModel *currentUser;
//当前登录用户的公共帐号
@property (nonatomic,strong) PubAccountListDataModel *publicAccountList;

+(ContactConfig *)sharedConfig;

-(void)clearConfig;
-(BOOL)saveConfig;

@end
