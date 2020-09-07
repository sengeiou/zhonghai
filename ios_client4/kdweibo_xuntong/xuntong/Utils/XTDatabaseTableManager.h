//
//  XTDatabaseTableManager.h
//  kdweibo
//
//  Created by Gil on 14-4-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _XTTableType
{
    XTTableTypeMin = -1,
    XTTableTypePrivateGroup = 0,//私人组
    XTTableTypePublicGroup = 1,//共有组，例如意见反馈组等等
    XTTableTypeParticipant = 2,//参与人
    XTTableTypePerson = 3,//人员
    XTTableTypeContact = 4,//人员联系信息
    XTTableTypePublicAccount = 5,//公共号
    XTTableTypeMessage = 6,//消息
    XTTableTypeApplication = 7,//应用
    XTTableTypeRecently = 8,//最近联系人
    XTTableTypeJob = 9,//人员职位信息
    XTTableTypeToDo = 10,//公共号逻辑
    XTTableTypeMessageReadState = 11,
    XTTableTypeMark = 12,//标记
    XTTableTypeMarkEvent = 13,//标记-日历事件
    XTTableTypeSignInRemind = 14,//签到提醒
    XTTableTypeMax = 15
   
}XTTableType;

@interface XTDatabaseTableManager : NSObject

+ (NSString *)tableNameWithTableType:(XTTableType)tableType eId:(NSString *)eId;
+ (NSString *)createTableSQLWithTableType:(XTTableType)tableType eId:(NSString *)eId;

@end
