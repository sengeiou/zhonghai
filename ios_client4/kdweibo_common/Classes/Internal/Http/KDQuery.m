//
//  KDQuery.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-27.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDQuery.h"
#import "KDRequestParameter.h"

@interface KDQuery ()

@property(nonatomic, retain) NSMutableDictionary *genericParameters;
@property(nonatomic, retain) NSMutableDictionary *fileDataParameters;

@end

@implementation KDQuery

@synthesize genericParameters=genericParameters_;
@synthesize fileDataParameters=fileDataParameters_;

- (id)init {
    self = [super init];
    if(self){
        genericParameters_ = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (KDQuery *)queryByAddQuery:(KDQuery *)query {
    KDQuery *theQuery = [KDQuery query];
    [theQuery.genericParameters addEntriesFromDictionary:self.genericParameters];
    [theQuery.genericParameters addEntriesFromDictionary:query.genericParameters];
    return theQuery;
}

+ (KDQuery *)query {
    return [[KDQuery alloc] init];// autorelease];
}

+ (KDQuery *)queryWithName:(NSString *)name value:(NSString *)value {
    KDQuery *query = [[KDQuery alloc] init];// autorelease];
    if (query != nil) {
        [query setParameter:name stringValue:value];
    }
    
    return query;
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark methods for set generic request parameters

- (KDQuery *)setParameter:(NSString *)name booleanValue:(BOOL)value {
    return [self setParameter:name stringValue:(value ? @"true" : @"false")];
}

- (KDQuery *)setParameter:(NSString *)name charValue:(char)value {
    return [self setParameter:name stringValue:[NSString stringWithFormat:@"%c", value]];
}

- (KDQuery *)setParameter:(NSString *)name intValue:(int)value {
    return [self setParameter:name stringValue:[NSString stringWithFormat:@"%d", value]];
}

- (KDQuery *)setParameter:(NSString *)name integerValue:(NSInteger)value {
    return [self setParameter:name stringValue:[NSString stringWithFormat:@"%ld", (long)value]];
}

- (KDQuery *)setParameter:(NSString *)name longLongValue:(KDInt64)value {
    return [self setParameter:name stringValue:[NSString stringWithFormat:@"%lld", value]];
}

- (KDQuery *)setParameter:(NSString *)name unsignedLongLongValue:(KDUInt64)value {
    return [self setParameter:name stringValue:[NSString stringWithFormat:@"%llu", value]];
}

- (KDQuery *)setParameter:(NSString *)name floatValue:(float)value {
    return [self setParameter:name stringValue:[NSString stringWithFormat:@"%f", value]];
}

- (KDQuery *)setParameter:(NSString *)name doubleValue:(double)value {
  return [self setParameter:name stringValue:[NSString stringWithFormat:@"%f", value]];  
}

- (KDQuery *)setParameter:(NSString *)name stringValue:(NSString *)value {
    if(name != nil && value != nil){
        [genericParameters_ setObject:value forKey:name];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////

- (NSString *)genericParameterForName:(NSString *)name {
    if (name == nil) return nil;
    
    return [genericParameters_ objectForKey:name];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark methods for set file data as request parameter

- (KDQuery *)setParameter:(NSString *)name fileObject:(id)obj {
    if(name != nil && obj != nil){
        if (fileDataParameters_ == nil) {
            fileDataParameters_ = [[NSMutableDictionary alloc] init];
        }
        
        [fileDataParameters_ setObject:obj forKey:name];
    }
    
    if (nil != name && nil == obj) {
        [fileDataParameters_ removeObjectForKey:name];
        //KD_RELEASE_SAFELY(fileDataParameters_);
    }
    
    return self;
}

- (KDQuery *)setParameter:(NSString *)name filePath:(NSString *)filePath {
    return [self setParameter:name fileObject:filePath];
}

- (KDQuery *)setParameter:(NSString *)name fileData:(NSData *)fileData {
    return [self setParameter:name fileObject:fileData];
}


- (NSMutableArray *)toRequestParameters {
    NSMutableArray *params = nil;
    NSUInteger fileDataCount = (fileDataParameters_ != nil) ? [fileDataParameters_ count] : 0;
    NSUInteger count = [genericParameters_ count] + fileDataCount;
    if (count > 0) {
        params = [NSMutableArray arrayWithCapacity:count];
        NSArray *keys = [genericParameters_ allKeys];
        
        KDRequestParameter *item = nil;
        
        // generic request parameters
        for(NSString *key in keys){
            item = [[KDRequestParameter alloc] initWithName:key value:[genericParameters_ objectForKey:key]];
            [params addObject:item];
//            [item release];
        }
        
        // file data request parameters
        if (fileDataCount > 0) {
            keys = [fileDataParameters_ allKeys];
            id obj = nil;
            for (NSString *key in keys) {
                item = nil;
                obj = [fileDataParameters_ objectForKey:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    // file path
                    item = [KDRequestParameter parameterWithName:key filePath:(NSString *)obj];
                
                } else if ([obj isKindOfClass:[NSData class]]) {
                    // file data
                    item = [KDRequestParameter parameterWithName:key fileData:(NSData *)obj];
                }
                
                if (item != nil) {
                    [params addObject:item];
                }
            }
        }
    }
    
    return params;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(genericParameters_);
    //KD_RELEASE_SAFELY(fileDataParameters_);
    
    //[super dealloc];
}

@end
