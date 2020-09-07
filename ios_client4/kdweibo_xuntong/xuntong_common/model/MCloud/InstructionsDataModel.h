//
//  InstructionsDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 指令接口数据模型
 */

#import "BOSBaseDataModel.h"

//指令编码
typedef enum _InstructionsCode{
    InstructionsNone = 0,//没有任何指令
    InstructionsDataErase = 1,//数据擦除
    InstructionsLogout = 2, // 踢出/注销
    InstructionsMessageTip = 3 //消息提醒
}InstructionsCode;


@interface InstructionsCodeDataModel : BOSBaseDataModel{
    InstructionsCode _code_;
    NSString *_desc_;
    NSDictionary *_extra_;
}

/*云端的指令码*/
@property (nonatomic,assign) InstructionsCode code;

/*云端的指令描述*/
@property (nonatomic,copy) NSString *desc;

/*指令的附加信息*/
@property (nonatomic,copy) NSDictionary *extra;

@end

@interface InstructionsDataModel : BOSBaseDataModel{
    NSArray *_instructions_;
    NSString *_desc_;
}

/*指令的列表，EMP容器按顺序执行该数组中的指令
 执行过程做相应的提示
 */
@property (nonatomic,retain) NSArray *instructions;

/*本次云端指令的操作描述*/
@property (nonatomic,copy) NSString *desc;

@end
