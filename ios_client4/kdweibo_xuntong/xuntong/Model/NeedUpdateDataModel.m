//
//  UnreadTotalDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "NeedUpdateDataModel.h"
#import "ContactLoginDataModel.h"

@implementation NeedUpdateDataModel

-(id)init
{
    self = [super init];
    if (self) {
        _flag = false;
        _pubAccount = nil;
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
        id flag = [dict objectForKey:@"flag"];
        id pubAccount = [dict objectForKey:@"pubAccount"];
        
        if (![flag isKindOfClass:[NSNull class]] && flag) {
            self.flag = [flag boolValue];
        }
        if (![pubAccount isKindOfClass:[NSNull class]] && pubAccount) {
            PubAccountList *pub = [[PubAccountList alloc] initWithDictionary:pubAccount];
            self.pubAccount = pub;
        }
    }
    return self;
}

@end

@implementation PubAccountList

-(id)init
{
    self = [super init];
    if (self) {
        _flag = false;
        _unreadTotal = 0;
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
        id flag = [dict objectForKey:@"flag"];
        id unreadTotal = [dict objectForKey:@"unreadTotal"];
        id list = [dict objectForKey:@"list"];
        
        if (![flag isKindOfClass:[NSNull class]] && flag) {
            self.flag = [flag boolValue];
        }
        if (![unreadTotal isKindOfClass:[NSNull class]] && unreadTotal) {
            self.unreadTotal = [unreadTotal intValue];
        }
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                PubAccount *pub = [[PubAccount alloc] initWithDictionary:each];
                [self.list addObject:pub];
            }
        }
    }
    return self;
}

@end

@implementation PubAccount

-(id)init
{
    self = [super init];
    if (self) {
        _flag = NO;
        _publicId = [[NSString alloc] init];
        _unreadCount = 0;
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
        id flag = [dict objectForKey:@"flag"];
        id publicId = [dict objectForKey:@"publicId"];
        id unreadCount = [dict objectForKey:@"unreadCount"];
        
        if (![flag isKindOfClass:[NSNull class]] && flag) {
            self.flag = [flag boolValue];
        }
        if (![publicId isKindOfClass:[NSNull class]] && publicId) {
            self.publicId = publicId;
        }
        if (![unreadCount isKindOfClass:[NSNull class]] && unreadCount) {
            self.unreadCount = [unreadCount intValue];
        }
    }
    return self;
}


@end
