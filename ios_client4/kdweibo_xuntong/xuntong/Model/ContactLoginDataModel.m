//
//  ContactLoginDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-11-30.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "ContactLoginDataModel.h"
#import "PersonDataModel.h"

@implementation ContactLoginDataModel

-(id)init
{
    self = [super init];
    if (self) {
        _extraData = nil;
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        id extraData = [dict objectForKey:@"extraData"];
        if (![extraData isKindOfClass:[NSNull class]] && extraData) {
            ExtraDataModel *extraDM = [[ExtraDataModel alloc] initWithDictionary:extraData];
            self.extraData = extraDM;
        }
    }
    return self;
}

@end

@implementation ExtraDataModel

-(id)init
{
    self = [super init];
    if (self) {
        _user = nil;
        _pubAccount = nil;
        _grammarId = [[NSString alloc] init];
        _orgTree = false;
        _cloudpassport = [[NSString alloc] init];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id user = [dict objectForKey:@"user"];
        id pubAccount = [dict objectForKey:@"pubAccount"];
        if (![user isKindOfClass:[NSNull class]] && user) {
            PersonDataModel *person = [[PersonDataModel alloc] initWithDictionary:user];
            self.user = person;
        }
        if (![pubAccount isKindOfClass:[NSNull class]] && pubAccount) {
            PubAccountListDataModel *pub = [[PubAccountListDataModel alloc] initWithDictionary:pubAccount];
            self.pubAccount = pub;
        }
        
        id grammarId = [dict objectForKey:@"grammarId"];
        if (![grammarId isKindOfClass:[NSNull class]] && grammarId) {
            self.grammarId = grammarId;
        }
        
        id orgTree = [dict objectForKey:@"orgTree"];
        if (![orgTree isKindOfClass:[NSNull class]] && orgTree) {
            self.orgTree = [orgTree boolValue];
        }
        id cloudpassport = [dict objectForKey:@"cloudpassport"];
        if (![cloudpassport isKindOfClass:[NSNull class]] && cloudpassport) {
            self.cloudpassport = cloudpassport;
        }
    }
    return self;
}

@end

@implementation PubAccountListDataModel

-(id)init
{
    self = [super init];
    if (self) {
        _list = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id list = [dict objectForKey:@"list"];
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                PubAccountDataModel *pub = [[PubAccountDataModel alloc] initWithDictionary:each];
                [self.list addObject:pub];
            }
        }
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.list forKey:@"list"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.list = [aDecoder decodeObjectForKey:@"list"];
    }
    return self;
}

@end

@implementation PubAccountDataModel

-(id)init
{
    self = [super init];
    if (self) {
        _publicId = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _photoUrl = [[NSString alloc] init];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id publicId = [dict objectForKey:@"publicId"];
        id name = [dict objectForKey:@"name"];
        id photoUrl = [dict objectForKey:@"photoUrl"];
        id manager = [dict objectForKey:@"manager"];
        if (![publicId isKindOfClass:[NSNull class]] && publicId) {
            self.publicId = publicId;
        }
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        if (![photoUrl isKindOfClass:[NSNull class]] && photoUrl) {
            self.photoUrl = photoUrl;
        }
        if (![manager isKindOfClass:[NSNull class]] && manager) {
            self.manager = [manager boolValue];
        }
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.publicId forKey:@"publicId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [aCoder encodeObject:@(self.manager) forKey:@"manager"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.publicId = [aDecoder decodeObjectForKey:@"publicId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.photoUrl = [aDecoder decodeObjectForKey:@"photoUrl"];
        self.manager = [[aDecoder decodeObjectForKey:@"manager"] boolValue];
    }
    return self;
}

@end
