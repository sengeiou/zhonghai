//
//  KDParserManager.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDParserManager.h"

@interface KDParserManager ()

@property(nonatomic, retain) NSMutableDictionary *parsersMap;

@end


@implementation KDParserManager

@synthesize parsersMap=parsersMap_;

- (id)init {
    self = [super init];
    if (self) {
        [self _setupParsers];
    }
    
    return self;
}

- (NSString *)_classToKey:(Class)clazz {
    return NSStringFromClass(clazz);
}

- (void)_addParserWithClass:(Class)clazz {
    id parser = [[clazz alloc] init];
    [parsersMap_ setObject:parser forKey:[self _classToKey:clazz]];
//    [parser release];
}

// setup some parser as default to aviod alloc memory frequency.
- (void)_setupParsers {
    parsersMap_ = [[NSMutableDictionary alloc] init];
    
    // user parser
    [self _addParserWithClass:[KDUserParser class]];
    
    // status parser
    [self _addParserWithClass:[KDStatusParser class]];
    
    // extend status parser
    [self _addParserWithClass:[KDExtendStatusParser class]];
    
    // status extra message parser
    [self _addParserWithClass:[KDStatusExtraMessageParser class]];
    
    // compiste image source parser
    [self _addParserWithClass:[KDCompositeImageSourceParser class]];
    
    // attachment parser
    [self _addParserWithClass:[KDAttachmentParser class]];
    
    // thread parser
    [self _addParserWithClass:[KDDMThreadParser class]];
    
    // message parser
    [self _addParserWithClass:[KDDMMessageParser class]];
    
    // AB person parser
    [self _addParserWithClass:[KDABPersonParser class]];
    
    // vote parser
    [self _addParserWithClass:[KDVoteParser class]];
    
    // group parser
    [self _addParserWithClass:[KDGroupParser class]];
    
    // composite parser
    [self _addParserWithClass:[KDCompositeParser class]];
    
    [self _addParserWithClass:[KDTaskParser class]];
    
    [self _addParserWithClass:[KDSignSchemaParser class]];
    
    [self _addParserWithClass:[KDSignInParser class]];
}

+ (KDParserManager *)globalParserManager {
    static KDParserManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KDParserManager alloc] init];
    });
    
    return manager;
}

- (id)parserWithClass:(Class)clazz {
    // check the class can not be Nil
    if (clazz == Nil) return nil;
    
    // try to find out parser from map
    id parser = [parsersMap_ objectForKey:[self _classToKey:clazz]];
    if (parser != nil) {
        return parser;
    }
    
    // if there is not exist associate parser for class, create one
    return [[clazz alloc] init] ;//autorelease];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(parsersMap_);
    
    //[super dealloc];
}

@end
