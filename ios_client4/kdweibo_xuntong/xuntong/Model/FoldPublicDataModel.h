//
//  FoldPublicDataModel.h
//  kdweibo
//
//  Created by 王 松 on 14-5-12.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "BOSBaseDataModel.h"
#import "RecordDataModel.h"

@interface FoldPublicDataModel : NSObject

@property (nonatomic, retain) NSString *latestMessage;
@property (nonatomic, retain) NSString *latestMessageTime;
@property (nonatomic, assign) MessageType latestMessageType;
@property (nonatomic, assign) NSUInteger unreadCount;
@property (retain, nonatomic) NSString *groupName;

@property (nonatomic, assign) BOOL isTop;
@end
