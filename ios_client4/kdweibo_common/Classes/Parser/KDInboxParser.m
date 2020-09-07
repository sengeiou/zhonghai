//
//  BaseClass.m
//
//  Created by kingdee  on 13-7-1
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "KDInboxParser.h"
#import "KDInbox.h"
@interface KDInboxParser ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation KDInboxParser

@synthesize success = _success;
@synthesize items = _items;
@synthesize total = _total;
@synthesize error = _error;

- (void)parse:(NSDictionary *)dict
{
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.success = [[dict objectForKey:@"success"] boolValue];
        NSObject *receivedItems = [dict objectForKey:@"items"];
        NSMutableArray *parsedItems = [NSMutableArray array];
        if ([receivedItems isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedItems) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedItems addObject:[KDInbox modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedItems isKindOfClass:[NSDictionary class]]) {
            [parsedItems addObject:[KDInbox modelObjectWithDictionary:(NSDictionary *)receivedItems]];
        }
        
        
        self.items = [NSArray arrayWithArray:parsedItems];
        //self.total = [[dict objectForKey:@"total"] doubleValue];
        //调用dictionary的扩展方法 以免 NSNull调用boolvalue 出错。
        self.total = [dict doubleForKey:@"total"];
        self.error = [self objectOrNilForKey:@"error" fromDictionary:dict];
        
    }
}
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.success] forKey:@"success"];
NSMutableArray *tempArrayForItems = [NSMutableArray array];
    for (NSObject *subArrayObject in self.items) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForItems addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForItems addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForItems] forKey:@"items"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.total] forKey:@"total"];
    [mutableDict setValue:self.error forKey:@"error"];

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
//    [_items release];
//    [_error release];
    //[super dealloc];
}

@end
