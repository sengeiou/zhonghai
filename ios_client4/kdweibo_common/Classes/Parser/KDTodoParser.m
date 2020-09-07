//
//  KDTodoParser.m
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTodoParser.h"
#import "KDTodo.h"
@interface KDTodoParser ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation KDTodoParser
@synthesize doneCount = _doneCount;
@synthesize itemstotal = _itemstotal;
@synthesize undoCount = _undoCount;
@synthesize ignoreCount = _ignoreCount;
@synthesize success = _success;
@synthesize errormsg = _errormsg;
@synthesize items = _items;

- (void)parse:(NSDictionary *)dict
{
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.doneCount = [[dict objectForKey:@"doneCount"] doubleValue];
        self.itemstotal = [[dict objectForKey:@"itemstotal"] doubleValue];
        self.undoCount = [[dict objectForKey:@"undoCount"] doubleValue];
        self.ignoreCount = [[dict objectForKey:@"ignoreCount"] doubleValue];
        self.success = [[dict objectForKey:@"success"] boolValue];
        self.errormsg = [self objectOrNilForKey:@"errormsg" fromDictionary:dict];
        NSObject *receivedItems = [dict objectForKey:@"items"];
        NSMutableArray *parsedItems = [NSMutableArray array];
        if ([receivedItems isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedItems) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedItems addObject:[KDTodo modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedItems isKindOfClass:[NSDictionary class]]) {
            [parsedItems addObject:[KDTodo modelObjectWithDictionary:(NSDictionary *)receivedItems]];
        }
        
        self.items = [NSArray arrayWithArray:parsedItems];
        
    }
}
- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.doneCount] forKey:@"doneCount"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.itemstotal] forKey:@"itemstotal"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.undoCount] forKey:@"undoCount"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.ignoreCount] forKey:@"ignoreCount"];
    [mutableDict setValue:[NSNumber numberWithBool:self.success] forKey:@"success"];
    [mutableDict setValue:self.errormsg forKey:@"errormsg"];
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
//    [_errormsg release];
//    [_items release];
    //[super dealloc];
}
@end
