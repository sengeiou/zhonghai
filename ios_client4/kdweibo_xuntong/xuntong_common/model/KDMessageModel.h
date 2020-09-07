//
//  KDMessageModel.h
//  kdweibo
//
//  Created by 王 松 on 14-5-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

@interface KDMessageModel : NSObject

@property (nonatomic, retain) NSString *groupId;

@property (nonatomic, retain) NSString *publicId;

@property (nonatomic, retain) NSData *sendData;

@property (nonatomic, retain) NSString *toUserId;

@property (nonatomic, retain) NSString *content;

@property (nonatomic, retain) NSString *param;

@property (nonatomic, retain) NSString *clientMessageId;

@property (nonatomic, retain) NSString *translateId;

@property (nonatomic, assign) long messageLength;

@property (nonatomic, assign) MessageType messageType;

//add by fang 2015-7-22
@property (nonatomic, strong) id paramObj;

@property (nonatomic, retain) NSString *isOriginalPic;

@property (nonatomic, assign) BOOL transmit;

@end
