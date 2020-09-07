//
//  T9TrieSearchQueueResultData.m
//  kdweibo
//
//  Created by stone on 14-5-11.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "T9TrieSearchQueueResultData.h"

@implementation T9TrieSearchQueueResultData

- (id)initWithPerson:(int)personId andWeight:(int)weight
{
    self = [super init];
    if(self)
    {
        self.personId = personId;
        self.weight = weight;
    }
    return self;
}

- (NSString*) description
{
    NSMutableString * str = [NSMutableString stringWithFormat:@"%d",_personId];
    if(_match != nil)
    {
        [str appendString:@" ("];
        for(int i = 0, len = (int)[_match count]; i < len; i++ )
        {
            if(i > 0)
            {
                [str appendString:@","];
            }
            [str appendFormat:@"%d",[_match[i] intValue]];
        }
        [str appendString:@")"];
    }
    [str appendString:@" "];
    [str appendFormat:@"%d",_weight];
    return str;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        return _personId == ((T9TrieSearchQueueResultData*)object).personId;
    }
    else
    {
        return NO;
    }
}

//在比较key时，条件是：hash & isEqual
- (NSUInteger)hash
{
    return _personId;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    T9TrieSearchQueueResultData * copy = [[[self class] allocWithZone:zone]initWithPerson:_personId andWeight:_weight];
    copy.match = [_match copy];
    return copy;
}

@end
