//
//  RecordListDataModel.h
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface RecordListDataModel : BOSBaseDataModel

@property (nonatomic,copy) NSString *groupId;
@property (nonatomic,copy) NSString *updateTime;//本次更新时间, yyyy-MM-dd HH:mm:ss
@property (nonatomic,assign) int count;//记录总数
@property (nonatomic,strong) NSMutableArray *list;//记录列表,RecordDataModel数组
@property (nonatomic, assign) int unreadCount; // 201501014新增，用于提高消息未读提示的准确率。

@property (nonatomic, assign) int undoCount; //待办为读书。
@property (nonatomic, assign) int notifyUnreadCount; // 通知未读数。
@property (nonatomic, assign) NSInteger lastIgnoreNotifyScore; //最后一条通知score
- (id)initForToDoWithDictionary:(NSDictionary *)dict;
@end
