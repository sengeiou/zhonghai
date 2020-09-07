//
//  KDAbstractActionHandler.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDQuery.h"

@interface KDAbstractActionHandler : NSObject {
 @private
    KDQuery *query_; // query parameters
    NSMutableDictionary *messages_; // error message
}

@property(nonatomic, retain) KDQuery *query;

/**
 * Subclasses may override to perform validate parameters etc.
 */
- (BOOL)validate;

/**
 * Subclasses may override to perform action.
 */
- (BOOL)execute;

- (void)setMessage:(NSString *)message forKey:(id)key;
- (NSString *)messageForKey:(id)key;

@end
