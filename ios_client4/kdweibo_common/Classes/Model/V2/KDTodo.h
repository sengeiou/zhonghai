//
//  KDTodo.h
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDObject.h"
@class KDUser;

@interface Action : NSObject

@property (nonatomic, strong) NSString *params;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *actDate;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *flag;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *actId;

+ (Action *)modelObjectWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
@end

@interface KDTodo : KDObject

@property (nonatomic, retain) NSString *todoId;
@property (nonatomic, retain) NSString *fromId;
@property (nonatomic, retain) NSString *fromType;
@property (nonatomic, retain) KDUser *toUser;
@property (nonatomic, retain) NSString *networkId;
@property (nonatomic, retain) KDUser *fromUser;
@property (nonatomic, retain) NSString *actName;
@property (nonatomic, retain) NSDate   *createDate;
@property (nonatomic, retain) NSString *contentHead;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *toUserId;
@property (nonatomic, retain) NSString *fromUserId;
@property (nonatomic, retain) NSString *connectType;
@property (nonatomic, retain) NSDate   *updateDate;
@property (nonatomic, retain) NSDate   *actDate;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSArray *action;
@property (nonatomic, retain) NSString *taskCommentCount;

+ (KDTodo *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
-(BOOL)isTask;//为了方便起见，将task临时存进去了todo表
@end
