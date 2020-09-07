//
//  KDRequestMethod.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDRequestMethod.h"

#import "KDCommon.h"

static NSMutableDictionary *instances_ = nil;

static KDRequestMethod *GET_ = nil;
static KDRequestMethod *POST_ = nil;
static KDRequestMethod *DELETE_ = nil;
static KDRequestMethod *HEAD_ = nil;
static KDRequestMethod *PUT_ = nil;


static NSString * const kKDRequestMethodGet     = @"GET";
static NSString * const kKDRequestMethodPost    = @"POST";
static NSString * const kKDRequestMethodDelete  = @"DELETE";
static NSString * const kKDRequestMethodHead    = @"HEAD";
static NSString * const kKDRequestMethodPut     = @"PUT";


@implementation KDRequestMethod

@synthesize name=name_;

- (id) init {
    self = [super init];
    if(self){
        name_ = nil;
    }
    
    return self;
}

- (id) initWithName:(NSString *)name {
    self = [super init];
    if(self){
        name_ = [name copy];
        [KDRequestMethod pushRequestMethod:self forName:name_];
    }
    
    return self;
}

+ (void) pushRequestMethod:(KDRequestMethod *)method forName:(NSString *)name {
    if(method != nil && name != nil){
        @synchronized(self){
            if(instances_ == nil){
                instances_ = [[NSMutableDictionary alloc] init]; 
            }
            
            [instances_ setObject:method forKey:name];
        }
    }
}

+ (KDRequestMethod *) GET {
    @synchronized(self){
        if(GET_ == nil){
            GET_ = [[KDRequestMethod alloc] initWithName:kKDRequestMethodGet]; 
        }
    }
    
    return GET_;
}

+ (KDRequestMethod *) POST {
    @synchronized(self){
        if(POST_ == nil){
            POST_ = [[KDRequestMethod alloc] initWithName:kKDRequestMethodPost]; 
        }
    }
    
    return POST_;
}

+ (KDRequestMethod *) DELETE {
    @synchronized(self){
        if(DELETE_ == nil){
            DELETE_ = [[KDRequestMethod alloc] initWithName:kKDRequestMethodDelete]; 
        }
    }
    
    return DELETE_;
}

+ (KDRequestMethod *) HEAD {
    @synchronized(self){
        if(HEAD_ == nil){
            HEAD_ = [[KDRequestMethod alloc] initWithName:kKDRequestMethodHead]; 
        }
    }
    
    return HEAD_;
}

+ (KDRequestMethod *) PUT {
    @synchronized(self){
        if(PUT_ == nil){
            PUT_ = [[KDRequestMethod alloc] initWithName:kKDRequestMethodPut]; 
        }
    }
    
    return PUT_;
}

+ (KDRequestMethod *) getInstance:(NSString *)name {
    KDRequestMethod *method = nil;
    @synchronized(self){
        method = (instances_ != nil) ? [instances_ objectForKey:name] : nil;
    }
    
    return method;
}

- (BOOL) isPostMethod {
    return NSOrderedSame == [kKDRequestMethodPost compare:name_ options:NSCaseInsensitiveSearch];
}

- (BOOL) isGetMethod {
    return NSOrderedSame == [kKDRequestMethodGet compare:name_ options:NSCaseInsensitiveSearch];
}

- (NSUInteger) hash {
    return [name_ hash];
}

- (BOOL) isEqual:(id)object {
    if(self == object) return YES;
    if(![object isKindOfClass:[KDRequestMethod class]]) return NO;
    
    KDRequestMethod *that = (KDRequestMethod *)object;
    
    return NSOrderedSame == [that.name caseInsensitiveCompare:self.name];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"KDRequestMethod{name='%@'}", name_];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(name_);
    
    //[super dealloc];
}

@end
