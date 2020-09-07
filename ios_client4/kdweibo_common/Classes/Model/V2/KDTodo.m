//
//  KDTodo.m
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTodo.h"
#import "KDUserParser.h"
#import "KDUtility.h"
@interface Action ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Action

@synthesize params = _params;
@synthesize color = _color;
@synthesize actDate = _actDate;
@synthesize url = _url;
@synthesize title = _title;
@synthesize flag = _flag;
@synthesize type = _type;
@synthesize actId = _actId;

+ (Action *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Action *instance = [[Action alloc] initWithDictionary:dict];
    return instance;// autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.params = [self objectOrNilForKey:@"params" fromDictionary:dict];
        self.color = [self objectOrNilForKey:@"color" fromDictionary:dict];
        self.actDate = [self objectOrNilForKey:@"actDate" fromDictionary:dict];
        self.url = [self objectOrNilForKey:@"url" fromDictionary:dict];
        self.title = [self objectOrNilForKey:@"title" fromDictionary:dict];
        self.flag = [self objectOrNilForKey:@"flag" fromDictionary:dict];
        self.type = [self objectOrNilForKey:@"type" fromDictionary:dict];
        self.actId = [self objectOrNilForKey:@"actId" fromDictionary:dict];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.params forKey:@"params"];
    [mutableDict setValue:self.color forKey:@"color"];
    [mutableDict setValue:self.actDate forKey:@"actDate"];
    [mutableDict setValue:self.url forKey:@"url"];
    [mutableDict setValue:self.title forKey:@"title"];
    [mutableDict setValue:self.flag forKey:@"flag"];
    [mutableDict setValue:self.type forKey:@"type"];
    [mutableDict setValue:self.actId forKey:@"actId"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}
- (void)dealloc
{
//    [_params release];
//    [_color release];
//    [_actDate release];
//    [_url release];
//    [_title release];
//    [_flag release];
//    [_type release];
//    [_actId release];
    
    //[super dealloc];
}
@end

@interface KDTodo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end
@implementation KDTodo
@synthesize fromId = _fromId;
@synthesize fromType = _fromType;
@synthesize toUser = _toUser;
@synthesize networkId = _networkId;
@synthesize fromUser = _fromUser;
@synthesize actName = _actName;
@synthesize createDate = _createDate;
@synthesize contentHead = _contentHead;
@synthesize title = _title;
@synthesize toUserId = _toUserId;
@synthesize fromUserId = _fromUserId;
@synthesize connectType = _connectType;
@synthesize updateDate = _updateDate;
@synthesize actDate = _actDate;
@synthesize status = _status;
@synthesize content = _content;
@synthesize action = _action;
@synthesize todoId = _todoId;
@synthesize taskCommentCount = _taskCommentCount;

+ (KDTodo *)modelObjectWithDictionary:(NSDictionary *)dict
{
    KDTodo*instance = [[KDTodo alloc] initWithDictionary:dict];// autorelease];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.todoId = [self objectOrNilForKey:@"todoId" fromDictionary:dict];
        self.fromId = [self objectOrNilForKey:@"fromId" fromDictionary:dict];
        self.fromType = [self objectOrNilForKey:@"fromType" fromDictionary:dict];
        
        KDUserParser *parser = [KDUserParser alloc];// autorelease];
        if([dict objectForKey:@"toUser"] != [NSNull null])
            self.toUser = [parser parseAsSimple:[dict objectForKey:@"toUser"]];
        self.networkId = [self objectOrNilForKey:@"networkId" fromDictionary:dict];
        
        if([dict objectForKey:@"fromUser"] != [NSNull null])
            self.fromUser = [parser parseAsSimple:[dict objectForKey:@"fromUser"]];
        self.actName = [self objectOrNilForKey:@"actName" fromDictionary:dict];
        self.createDate = [dict ASCDatetimeWithMillionSecondsForKey:@"createDate"];
        self.contentHead = [self objectOrNilForKey:@"contentHead" fromDictionary:dict];
        self.title = [self objectOrNilForKey:@"title" fromDictionary:dict];

        
        self.toUserId = [self objectOrNilForKey:@"toUserId" fromDictionary:dict];
        self.fromUserId = [self objectOrNilForKey:@"fromUserId" fromDictionary:dict];
        self.connectType = [self objectOrNilForKey:@"connectType" fromDictionary:dict];
        self.updateDate = [dict ASCDatetimeWithMillionSecondsForKey:@"updateDate"];
        
        self.actDate = [dict ASCDatetimeWithMillionSecondsForKey:@"actDate"];
        self.status = [self objectOrNilForKey:@"status" fromDictionary:dict];
        self.content = [self objectOrNilForKey:@"content" fromDictionary:dict];
        
        id count = [self objectOrNilForKey:@"taskCommentCount" fromDictionary:dict];
        if ([count isKindOfClass:[NSNumber class]])
            self.taskCommentCount = [NSString stringWithFormat:@"%ld",(long)[count integerValue]];
        else
            self.taskCommentCount = count;
        
        
        NSObject *receivedAction = [dict objectForKey:@"action"];
        NSMutableArray *parsedAction = [NSMutableArray array];
        if ([receivedAction isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedAction) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedAction addObject:[Action modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedAction isKindOfClass:[NSDictionary class]]) {
            [parsedAction addObject:[Action modelObjectWithDictionary:(NSDictionary *)receivedAction]];
        }
        
        self.action = [NSArray arrayWithArray:parsedAction];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.todoId forKey:@"todoId"];
    [mutableDict setValue:self.fromId forKey:@"fromId"];
    [mutableDict setValue:self.fromType forKey:@"fromType"];
//    [mutableDict setValue:[self.toUser dictionaryRepresentation] forKey:@"toUser"];
    [mutableDict setValue:self.networkId forKey:@"networkId"];
//    [mutableDict setValue:[self.fromUser dictionaryRepresentation] forKey:@"fromUser"];
    [mutableDict setValue:self.actName forKey:@"actName"];
    [mutableDict setValue:self.createDate forKey:@"createDate"];
    [mutableDict setValue:self.contentHead forKey:@"contentHead"];
    [mutableDict setValue:self.title forKey:@"title"];
   
    [mutableDict setValue:self.toUserId forKey:@"toUserId"];
    [mutableDict setValue:self.fromUserId forKey:@"fromUserId"];
    [mutableDict setValue:self.connectType forKey:@"connectType"];
    [mutableDict setValue:self.updateDate forKey:@"updateDate"];
    [mutableDict setValue:self.actDate forKey:@"actDate"];
    [mutableDict setValue:self.status forKey:@"status"];
    [mutableDict setValue:self.content forKey:@"content"];
    [mutableDict setValue:self.taskCommentCount forKey:@"taskCommentCount"];
    
    NSMutableArray *tempArrayForAction = [NSMutableArray array];
    for (NSObject *subArrayObject in self.action) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForAction addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForAction addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForAction] forKey:@"action"];
    
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}


-(BOOL)isTask
{
    if([self.status isEqualToString:@"30"]
       ||[self.status isEqualToString:@"50"])
        return YES;
    else
        return NO;
}//为了方便起见，将task临时存进去了todo表

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

- (void)dealloc
{
//    [_todoId release];
//    [_fromId release];
//    [_fromType release];
//    [_toUser release];
//    [_networkId release];
//    [_fromUser release];
//    [_actName release];
//    [_actDate release];
//    [_createDate release];
//    [_updateDate release];
//    [_contentHead release];
//    [_title release];
//    [_toUserId release];
//    [_fromUserId release];
//    [_connectType release];
//    [_taskCommentCount release];
//
//    [_status release];
//    [_content release];
    //[super dealloc];
}

@end
