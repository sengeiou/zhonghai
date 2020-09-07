//
//  KWPaging.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDQuery.h"
/**
 @brief container of API pagination params, and related utils
 */
@class KDQuery;
@interface KWPaging : NSObject

@property (nonatomic) NSUInteger page;
@property (nonatomic) NSUInteger count;
@property (nonatomic, retain) NSString *sinceId;
@property (nonatomic, retain) NSString *maxId;

+ (KWPaging *)pagingWithPage:(NSUInteger)page;

// - (KWPaging *)initWithPage:(NSUInteger)page;

+ (KWPaging *)pagingWithSinceId:(NSString *)sinceId;

+ (KWPaging *)pagingWithMaxId:(NSString *)maxId;

// - (KWPaging *)initWithSinceId:(NSString *)sinceId;

+ (KWPaging *)pagingWithPage:(NSUInteger)page count:(NSUInteger)count;

// - (KWPaging *)initWithPage:(NSUInteger)page count:(NSUInteger)count;

+ (KWPaging *)pagingWithPage:(NSUInteger)page sinceId:(NSString *)sinceId;

// - (KWPaging *)initWithPage:(NSUInteger)page sinceId:(NSString *)sinceId;

+ (KWPaging *)pagingWithPage:(NSUInteger)page 
                       count:(NSUInteger)count 
                     sinceId:(NSString *)sinceId;

// - (KWPaging *)initWithPage:(NSUInteger)page count:(NSUInteger)count sinceId:(NSString *)sinceId;

+ (KWPaging *)pagingWithPage:(NSUInteger)page 
                       count:(NSUInteger)count 
                     sinceId:(NSString *)sinceId 
                       maxId:(NSString *)maxId;

// - (KWPaging *)initWithPage:(NSUInteger)page count:(NSUInteger)count sinceId:(NSString *)sinceId maxId:(NSString *)maxId;

- (NSDictionary *)toDict;
- (KDQuery *)toQuery;
@end
