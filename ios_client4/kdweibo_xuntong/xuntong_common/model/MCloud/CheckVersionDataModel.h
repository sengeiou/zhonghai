//
//  CheckVersionDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 版本检测接口数据模型
 */

#import "BOSBaseDataModel.h"

typedef enum _UpdateFlag{
    UpdateNotNeed = 0,//不需要更新
    UpdateNeed = 1 //需要更新
}UpdateFlag;

@interface CheckVersionDataModel : BOSBaseDataModel{
    UpdateFlag _updateFlag_;
    NSString *_newversion_;
    NSString *_iosURL_;
    NSString *_message_;
    NSString *_updateNote_;
}

//更新标志
@property (nonatomic,assign) UpdateFlag updateFlag;

//要更新的的版本号，如1.2.1
@property (nonatomic,copy) NSString *newversion;

//iTunes AppStore上的url
@property (nonatomic,copy) NSString *iosURL;

//给客户的提示信息
@property (nonatomic,copy) NSString *message;

//更新说明
@property (nonatomic,copy) NSString *updateNote;

@end
