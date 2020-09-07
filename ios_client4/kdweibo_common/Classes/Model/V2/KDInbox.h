//
//  KDInbox.h
//  kdweibo_common
//
//  Created by bird on 13-7-1.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDObject.h"

#import "KDAvatarProtocol.h"
#import "KDUser.h"

@interface LatestFeed : NSObject

@property (nonatomic, retain) NSString  *content;
@property (nonatomic, retain) KDUser    *senderUser;
@property (nonatomic, retain) NSString  *refId;
@property (nonatomic, retain) NSString  *subtype;
@property (nonatomic, retain) NSString  *type;
@property (nonatomic, retain) NSString  *groupId;
@property (nonatomic, retain) NSString  *repliederName;
@property (nonatomic, retain) NSString  *repliederId;

+ (LatestFeed *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
@end

@interface KDInbox : KDObject <KDCompositeAvatarDataSource>

@property (nonatomic, retain) NSString *_id;
@property (nonatomic, retain) NSString *refUserName;
@property (nonatomic, retain) NSArray  *participants;
@property (nonatomic, retain) NSString *networkId;
@property (nonatomic, assign) double unReadCount;
@property (nonatomic, assign) double updateTime;
@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, retain) NSString *refId;
@property (nonatomic, retain) LatestFeed *latestFeed;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *itemsIdentifier;
@property (nonatomic, retain) NSArray  *participantsPhoto;
@property (nonatomic, assign) BOOL isUnRead;
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, assign) double    createTime;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *refUserId;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *userId;

+ (KDInbox *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
@end
