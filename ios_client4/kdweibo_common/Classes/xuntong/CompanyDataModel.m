//
//  CompanyDataModel.m
//  kdweibo
//
//  Created by Gil on 14-4-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "CompanyDataModel.h"

@implementation CompanyDataModel

- (id)init {
    self = [super init];
    if (self) {
        _eid = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _wbNetworkId = [[NSString alloc] init];
        _user = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id eid = [dict objectForKey:@"eid"];
        if (![eid isKindOfClass:[NSNull class]] && eid) {
            self.eid = eid;
        }
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        id wbNetworkId = [dict objectForKey:@"wbNetworkId"];
        if (![wbNetworkId isKindOfClass:[NSNull class]] && wbNetworkId) {
            self.wbNetworkId = wbNetworkId;
        }
        id person = [dict objectForKey:@"person"];
        if (person && [person isKindOfClass:[NSDictionary class]]) {
            UserDataModel *user = [[UserDataModel alloc] initWithDictionary:person];// autorelease];
            self.user = user;
        }
    }
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(_eid);
    //KD_RELEASE_SAFELY(_name);
    //KD_RELEASE_SAFELY(_wbNetworkId);
    //KD_RELEASE_SAFELY(_user);
    //[super dealloc];
}

#pragma mark - NSCoding

//- (id)copyWithZone:(NSZone *)zone
//{
//    return [self copyWithZone:zone];
//}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.eid forKey:@"eid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.wbNetworkId forKey:@"wbNetworkId"];
    [aCoder encodeObject:self.user forKey:@"person"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.eid = [aDecoder decodeObjectForKey:@"eid"];
        self.user = [aDecoder decodeObjectForKey:@"person"];
        self.wbNetworkId = [aDecoder decodeObjectForKey:@"wbNetworkId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
