//
//  KDInbox.m
//  kdweibo_common
//
//  Created by bird on 13-7-1.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDInbox.h"
#import "KDCache.h"
#import "NSDictionary+Additions.h"
#import "KDUserParser.h"
#import "KDParserManager.h"

@implementation KDInbox
@synthesize _id;
@synthesize refUserName = _refUserName;
@synthesize participants = _participants;
@synthesize networkId = _networkId;
@synthesize unReadCount = _unReadCount;
@synthesize updateTime = _updateTime;
@synthesize isUpdate = _isUpdate;
@synthesize isNew = _isNew;
@synthesize refId = _refId;
@synthesize latestFeed = _latestFeed;
@synthesize type = _type;
@synthesize itemsIdentifier = _itemsIdentifier;
@synthesize participantsPhoto = _participantsPhoto;
@synthesize isUnRead = _isUnRead;
@synthesize groupName = _groupName;
@synthesize createTime = _createTime;
@synthesize isDelete = _isDelete;
@synthesize groupId = _groupId;
@synthesize refUserId = _refUserId;
@synthesize content = _content;
@synthesize userId = _userId;

+ (KDInbox *)modelObjectWithDictionary:(NSDictionary *)dict
{
    KDInbox *instance = [[KDInbox alloc] initWithDictionary:dict];
    return instance;// autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self._id = [self objectOrNilForKey:@"id" fromDictionary:dict];
        self.refUserName = [self objectOrNilForKey:@"refUserName" fromDictionary:dict];
        self.participants = [self objectOrNilForKey:@"participants" fromDictionary:dict];
        self.networkId = [self objectOrNilForKey:@"networkId" fromDictionary:dict];
        self.unReadCount = [[dict objectForKey:@"unReadCount"] doubleValue];
        self.updateTime = [[dict ASCDatetimeWithMillionSecondsForKey:@"updateTime"] timeIntervalSince1970];
        self.isUpdate = [[dict objectForKey:@"isUpdate"] boolValue];
        self.isNew = [[dict objectForKey:@"isNew"] boolValue];
        self.refId = [self objectOrNilForKey:@"refId" fromDictionary:dict];
        self.latestFeed = [LatestFeed modelObjectWithDictionary:[dict objectForKey:@"latestFeed"]];
        self.type = [self objectOrNilForKey:@"type" fromDictionary:dict];
        self.itemsIdentifier = [self objectOrNilForKey:@"id" fromDictionary:dict];
        self.participantsPhoto = [self objectOrNilForKey:@"participants_photo" fromDictionary:dict];
        self.isUnRead = [[dict objectForKey:@"isUnRead"] boolValue];
        self.groupName = [self objectOrNilForKey:@"groupName" fromDictionary:dict];
        self.createTime = [[dict ASCDatetimeWithMillionSecondsForKey:@"createTime"] timeIntervalSince1970];
        self.isDelete = [[dict objectForKey:@"delete"] boolValue];
        self.groupId = [self objectOrNilForKey:@"groupId" fromDictionary:dict];
        self.refUserId = [self objectOrNilForKey:@"refUserId" fromDictionary:dict];
        self.content = [self objectOrNilForKey:@"content" fromDictionary:dict];
        self.userId = [self objectOrNilForKey:@"userId" fromDictionary:dict];
        
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self._id forKey:@"id"];
    [mutableDict setValue:self.refUserName forKey:@"refUserName"];
    [mutableDict setValue:self.participants forKey:@"participants"];
    [mutableDict setValue:self.networkId forKey:@"networkId"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.unReadCount] forKey:@"unReadCount"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.updateTime] forKey:@"updateTime"];
    [mutableDict setValue:[NSNumber numberWithBool:self.isUpdate] forKey:@"isUpdate"];
    [mutableDict setValue:[NSNumber numberWithBool:self.isNew] forKey:@"isNew"];
    [mutableDict setValue:self.refId forKey:@"refId"];
    [mutableDict setValue:[self.latestFeed dictionaryRepresentation] forKey:@"latestFeed"];
    [mutableDict setValue:self.type forKey:@"type"];
    [mutableDict setValue:self.itemsIdentifier forKey:@"id"];
    [mutableDict setValue:self.participantsPhoto forKey:@"participants_photo"];
    [mutableDict setValue:[NSNumber numberWithBool:self.isUnRead] forKey:@"isUnRead"];
    [mutableDict setValue:self.groupName forKey:@"groupName"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.createTime] forKey:@"createTime"];
    [mutableDict setValue:[NSNumber numberWithBool:self.isDelete] forKey:@"delete"];
    [mutableDict setValue:self.groupId forKey:@"groupId"];
    [mutableDict setValue:self.refUserId forKey:@"refUserId"];
    [mutableDict setValue:self.content forKey:@"content"];
    [mutableDict setValue:self.userId forKey:@"userId"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];}

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



#pragma mark -
#pragma mark KDAvatarDataSource protocol methods

- (KDAvatarType)getAvatarType {
    return KDAvatarTypeDMThread;
}

- (KDImageSize *)avatarScaleToSize {
    return [self.participantsPhoto count]>0? [KDImageSize defaultDMThreadAvatarSize] : [KDImageSize defaultUserAvatarSize];
}

- (NSString *)getAvatarLoadURL {
    return [self avatarLoadURLAtIndex:0x00];
}

- (NSString *)getAvatarCacheKey {
    return [self avatarCacheKeyAtIndex:0x00];
}

- (void)removeAvatarCacheKey {
    // unsupport now.
}

- (NSString *)avatarLoadURLAtIndex:(NSUInteger)index {
    NSString *url = nil;
    if (self.participantsPhoto != nil && index < [self.participantsPhoto count]) {
        url = [self.participantsPhoto objectAtIndex:index];
    }
    
    return url;
}

- (NSString *)avatarCacheKeyAtIndex:(NSUInteger)index {
    NSString *url = [self avatarLoadURLAtIndex:index];
    NSString *cacheKey = nil;
    if (url != nil) {
        cacheKey = [super propertyForKey:url];
        if(cacheKey == nil){
            cacheKey = [KDCache cacheKeyForURL:url];
            if(cacheKey != nil){
                [super setProperty:cacheKey forKey:url];
            }
        }
    }
    
    return cacheKey;
}
- (void)dealloc
{
//    [_id release];
//    [_refUserName release];
//    [_participants release];
//    [_networkId release];
//    [_refId release];
//    [_latestFeed release];
//    [_type release];
//    [_itemsIdentifier release];
//    [_participantsPhoto release];
//    [_groupName release];
//    [_groupId release];
//    [_refUserId release];
//    [_content release];
//    [_userId release];
    //[super dealloc];
}
@end

@implementation LatestFeed
@synthesize content = _content;
@synthesize senderUser = _senderUser;
@synthesize refId = _refId;
@synthesize subtype = _subtype;
@synthesize type = _type;
@synthesize groupId = _groupId;
@synthesize repliederName = _repliederName;
@synthesize repliederId = _repliederId;

+ (LatestFeed *)modelObjectWithDictionary:(NSDictionary *)dict
{
    LatestFeed *instance = [[LatestFeed alloc] initWithDictionary:dict];
    return instance ;//];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.content = [self objectOrNilForKey:@"content" fromDictionary:dict];
//        self.senderUser = [[KDUserParser alloc] parseAsSimple:[dict objectForKey:@"senderUser"]];
        self.senderUser = [[[KDParserManager globalParserManager] parserWithClass:[KDUserParser class]] parseAsSimple:[dict objectForKey:@"senderUser"]];
        self.refId = [self objectOrNilForKey:@"refId" fromDictionary:dict];
        self.subtype = [self objectOrNilForKey:@"subtype" fromDictionary:dict];
        self.type = [self objectOrNilForKey:@"type" fromDictionary:dict];
        self.groupId = [self objectOrNilForKey:@"groupId" fromDictionary:dict];
        self.repliederName = [self objectOrNilForKey:@"repliederName" fromDictionary:dict];
        self.repliederId = [self objectOrNilForKey:@"repliederId" fromDictionary:dict];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.content forKey:@"content"];
    [mutableDict setValue:self.refId forKey:@"refId"];
    [mutableDict setValue:self.subtype forKey:@"subtype"];
    [mutableDict setValue:self.type forKey:@"type"];
    [mutableDict setValue:self.groupId forKey:@"groupId"];
    [mutableDict setValue:self.repliederName forKey:@"repliederName"];
    [mutableDict setValue:self.repliederId forKey:@"repliederId"];
    
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
//    [_content release];
//    [_senderUser release];
//    [_refId release];
//    [_subtype release];
//    [_type release];
//    [_groupId release];
//    [_repliederName release];
//    [_repliederId release];
    
    //[super dealloc];
}
@end