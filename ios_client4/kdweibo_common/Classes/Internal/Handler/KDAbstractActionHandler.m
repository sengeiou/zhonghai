//
//  KDAbstractActionHandler.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDAbstractActionHandler.h"

@interface KDAbstractActionHandler ()

@property(nonatomic, retain) NSMutableDictionary *messages;

@end

@implementation KDAbstractActionHandler

@synthesize query=query_;
@synthesize messages=messages_;

- (BOOL)validate {
    return YES;
}

- (BOOL)execute {
    return YES;
}

- (void)setMessage:(NSString *)message forKey:(id)key {
    if (message != nil && key != nil) {
        if (messages_ == nil) {
            messages_ = [[NSMutableDictionary alloc] init];
        }
        
        [messages_ setObject:message forKey:key];
    }
}

- (NSString *)messageForKey:(id)key {
    if (messages_ == nil || key == nil) {
        return nil;
    }
    
    return [messages_ objectForKey:key];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(query_);
    //KD_RELEASE_SAFELY(messages_);
    
    //[super dealloc];
}

@end
