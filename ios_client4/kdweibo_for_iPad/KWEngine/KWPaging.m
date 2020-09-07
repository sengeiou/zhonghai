//
//  KWPaging.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KWPaging.h"

@implementation KWPaging

@synthesize page = _page, count = _count, sinceId = _sinceId, maxId = _maxId;

+ (KWPaging *)paging
{
    return [[[self alloc] init] autorelease];
}

+ (KWPaging *)pagingWithPage:(NSUInteger)page
{
    KWPaging *p = [self paging];
    [p setPage:page];    
    return p;
}

+ (KWPaging *)pagingWithSinceId:(NSString *)sinceId
{
    KWPaging *p = [self paging];
    [p setSinceId:sinceId];    
    return p;
}

+ (KWPaging *)pagingWithMaxId:(NSString *)maxId
{
    KWPaging *p = [self paging];
    p.maxId = maxId;    
    return p;
}

+ (KWPaging *)pagingWithPage:(NSUInteger)page count:(NSUInteger)count
{
    KWPaging *p = [self pagingWithPage:page];
    [p setCount:count];    
    return p;
}

+ (KWPaging *)pagingWithPage:(NSUInteger)page sinceId:(NSString *)sinceId
{
    KWPaging *p = [self pagingWithPage:page];
    [p setSinceId:sinceId];    
    return p;
}

+ (KWPaging *)pagingWithPage:(NSUInteger)page count:(NSUInteger)count sinceId:(NSString *)sinceId
{
    KWPaging *p = [self pagingWithPage:page count:count];
    [p setSinceId:sinceId];    
    return p;
}

+ (KWPaging *)pagingWithPage:(NSUInteger)page count:(NSUInteger)count sinceId:(NSString *)sinceId maxId:(NSString *)maxId
{
    KWPaging *p = [self pagingWithPage:page count:count sinceId:sinceId];
    [p setMaxId:maxId];    
    return p;
}

- (NSDictionary *)toDict
{
    NSMutableDictionary *_d = [NSMutableDictionary dictionaryWithCapacity:4];
    if (self.page) {
        [_d setObject:[NSNumber numberWithInt:self.page] forKey:@"page"];
    }
    
    if (self.count) {
        [_d setObject:[NSNumber numberWithInt:self.count] forKey:@"count"];
    }
    
    if (self.sinceId) {
        [_d setObject:self.sinceId forKey:@"since_id"];
    }
    
    if (self.maxId) {
        [_d setObject:self.maxId forKey:@"max_id"];
    }
    
    return [NSDictionary dictionaryWithDictionary:_d];
}

- (KDQuery *)toQuery {
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"page" integerValue:self.page]
     setParameter:@"count" integerValue:self.count];
    return query;
}
@end
