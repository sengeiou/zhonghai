//
//  KDContactInfo.m
//  kdweibo_common
//
//  Created by AlanWong on 15/1/12.
//  Copyright (c) 2015年 kingdee. All rights reserved.
//

#import "KDContactInfo.h"

@implementation KDContactInfo

- (id)init {
    self = [super init];
    if (self) {
        _name = [[NSString alloc]init];
        _type = [[NSString alloc]init];
        _value = [[NSString alloc]init];
        _publicid = [[NSString alloc]init];
        _permission = [[NSString alloc]init];
        
    }
    return self;
}

- (id)initWithName:(NSString *)name type:(NSString *)type value:(NSString *)value {
    self = [super init];
    if (self) {
        self.name = name;
        self.type = type;
        self.value = value;
    }
    return self;
}

- (NSString *)checkNullAndNil:(NSString *)value {
    if (![value isKindOfClass:[NSString class]]) {
        return @"";
    }
    if (value == nil) {
        return @"";
    }
    return value;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{@"name":[self checkNullAndNil:self.name],
                                                                             @"type":[self checkNullAndNil:self.type],
                                                                             @"value":[self checkNullAndNil:self.value]}];
    if (self.publicid.length > 0) {
        [d setObject:self.publicid forKey:@"publicid"];
    }
    if (self.permission.length > 0) {
        [d setObject:self.permission forKey:@"permission"];
    }
    
    return d;
}

- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        id type = [dict objectForKey:@"type"];
        if (![type isKindOfClass:[NSNull class]] && type) {
            self.type = type;
        }
        id value = [dict objectForKey:@"value"];
        if (![value isKindOfClass:[NSNull class]] && value) {
            self.value = value;
        }
        id publicid = [dict objectForKey:@"publicid"];
        if (![publicid isKindOfClass:[NSNull class]] && publicid) {
            self.publicid = publicid;
        }
        id permission = [dict objectForKey:@"permission"];
        if (![permission isKindOfClass:[NSNull class]] && permission) {
            self.permission = permission;
        }
        
    }
    return self;
}

@end


@implementation KDContactAttributeInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _attributeId = [[NSString alloc]init];
        _name = [[NSString alloc]init];
        _value = [[NSString alloc]init];
        _type = 0;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    
    if (self) {
        id attributeId = [dict objectForKey:@"id"];
        if (![attributeId isKindOfClass:[NSNull class]] && attributeId) {
            self.attributeId = attributeId;
        }
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        id value = [dict objectForKey:@"value"];
        if (![value isKindOfClass:[NSNull class]] && value) {
            self.value = value;
        }
        id type = [dict objectForKey:@"type"];
        if (![type isKindOfClass:[NSNull class]] && type) {
            self.type = [type integerValue];
        }
    }
    
    return self;
}

@end
