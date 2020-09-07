//
//  KDObject.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDObject.h"


NSString * const kKDAvatarPropertyCacheKey = @"avatarCacheKey";


@interface KDObject ()

@property (nonatomic, retain) NSMutableDictionary *extensions;
@property (nonatomic, retain) NSMutableDictionary *userProperties;

@end


@implementation KDObject

@synthesize extensions=extensions_;
@synthesize userProperties=userProperties_;

- (id) init {
    self = [super init];
    if(self){
        extensions_ = nil;
        userProperties_ = nil;
    }
    
    return self;
}

- (NSString *)classToKey:(Class)clazz {
    return NSStringFromClass(clazz);
}

- (NSArray *)objectsForExtensionClass:(Class)theClass {
    id obj = [extensions_ objectForKey:[self classToKey:theClass]];
    if (obj == nil) return nil;
    
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    
    return [NSArray arrayWithObject:obj];
}

- (id)objectForExtensionClass:(Class)theClass {
    id obj = [extensions_ objectForKey:[self classToKey:theClass]];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)obj count] > 0) {
            return [obj objectAtIndex:0];
        }
        
        // an empty array
        return nil;
    }
    
    return obj;
}

// replace all actual extensions of the specified class with a single object
- (void)setObject:(id)object forExtensionClass:(Class)theClass {
    if (extensions_ == nil && object != nil) {
        extensions_ = [[NSMutableDictionary alloc] init];
    }
    
    if (object) {
        [extensions_ setObject:object forKey:[self classToKey:theClass]];
        
    } else {
        [extensions_ removeObjectForKey:[self classToKey:theClass]];
    }
}

// add an extension of the specified class
- (void)addObject:(id)newObj forExtensionClass:(Class)theClass {
    if (newObj == nil) return;
    
    NSString *key = [self classToKey:theClass];
    id previousObjOrArray = [extensions_ objectForKey:key];
    if (previousObjOrArray) {
        if ([previousObjOrArray isKindOfClass:[NSArray class]]) {
            [previousObjOrArray addObject:newObj];
            
        } else {
            // create an array with the previous object and the new object
            NSMutableArray *array = [NSMutableArray arrayWithObjects:
                                     previousObjOrArray, newObj, nil];
            [extensions_ setObject:array forKey:key];
        }
        
    } else {
        // no previous object
        [self setObject:newObj forExtensionClass:theClass];
    }
}

// remove a known extension of the specified class
- (void)removeObject:(id)object forExtensionClass:(Class)theClass {
    NSString *key = [self classToKey:theClass];
    
    id previousObjOrArray = [extensions_ objectForKey:key];
    if ([previousObjOrArray isKindOfClass:[NSArray class]]) {
        // remove from the array
        [(NSMutableArray *)previousObjOrArray removeObject:object];
        
    } else if ([object isEqual:previousObjOrArray]) {
        // no array, so remove if it matches the sole object
        [extensions_ removeObjectForKey:key];
    }
}


- (void) setProperty:(id)obj forKey:(NSString *)key {
    if (obj == nil) {
        // user passed in nil, so delete the property
        [userProperties_ removeObjectForKey:key];
    
    } else {
        // be sure the property dictionary exists
        if (userProperties_ == nil) {
            userProperties_ = [[NSMutableDictionary alloc] init];
        }
        
        [userProperties_ setObject:obj forKey:key];
    }
}

- (id) propertyForKey:(NSString *)key {
    id obj = [userProperties_ objectForKey:key];
    
    // be sure the returned pointer has the life of the autorelease pool,
    // in case self is released immediately
    return obj;// retain] ;//autorelease];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(extensions_);
    //KD_RELEASE_SAFELY(userProperties_);
    
    //[super dealloc];
}

@end
