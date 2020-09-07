//
//  T9SearchResult.m
//  TestT9
//
//  Created by Gil on 13-1-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "T9SearchResult.h"
#import "T9Utils.h"

@implementation T9SearchResult

-(id)initWithUserId:(int)userId matchLength:(NSArray *)matchLength weight:(int)weight type:(T9ResultType)type
{
    self = [super init];
    if (self) {
        _userId = userId;
        _matchLength = [matchLength copy];
        _weight = weight;
        _type = type;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[T9SearchResult class]]) {
        return NO;
    }
    T9SearchResult *result = (T9SearchResult *)object;
    return self.userId == result.userId;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id=%d,weight=%d",self.userId,self.weight];
}

- (NSString*)calcHighlightName:(NSString*)name
{
    if (_type == T9ResultTypeHanzi)
    {
        if ([_matchLength count] == 2)
        {
            int begin = [[_matchLength objectAtIndex:0] intValue];
            int end = [[_matchLength objectAtIndex:1] intValue];
            NSMutableString *sb = [NSMutableString string];
            [sb appendString:[name substringToIndex:begin]];
            [sb appendFormat:@"<font color=\"#06A3EC\">%@</font>",[name substringWithRange:NSMakeRange(begin, end-begin)]];
            [sb appendString:[name substringFromIndex:end]];
            return sb;
        }
    }
    
    //无需加亮，原样显示
    return name;
}

- (NSString*)calcHighlightPhone:(NSString*)phone
{
    if(_type == T9ResultTypePhoneNumber)
    {
        if ([_matchLength count] == 2)
        {
            int begin = [[_matchLength objectAtIndex:0] intValue];
            int end = [[_matchLength objectAtIndex:1] intValue];
            NSMutableString *sb = [NSMutableString string];
            [sb appendString:[phone substringToIndex:begin]];
            [sb appendFormat:@"<font color=\"#06A3EC\">%@</font>",[phone substringWithRange:NSMakeRange(begin, end-begin)]];
            [sb appendString:[phone substringFromIndex:end]];
            return sb;
        }
    }
    //无需加亮，原样显示
    return phone;
}

- (NSString*)calcHighlightPinYin:(NSString*)fullpinyin
{
    NSArray *py = [T9Utils getPinYins:fullpinyin];
    NSMutableString *sb = [NSMutableString string];
    if(_type == T9ResultTypeT9)
    {
        int i = 0;
        if (_matchLength != nil)
        {
            for (; i < [py count] && i < [_matchLength count]; i++)
            {
                int ml = [[_matchLength objectAtIndex:i] intValue];
                if (i > 0)
                    [sb appendString:@" "];
                if (ml > 0)
                {
                    [sb appendFormat:@"<font color=\"#06A3EC\">%@</font>",[T9Utils toFirstUpper:[[py objectAtIndex:i] substringToIndex:ml]]];
                    [sb appendString:[[py objectAtIndex:i] substringFromIndex:ml]];
                }
                else
                {
                    [sb appendString:[T9Utils toFirstUpper:[py objectAtIndex:i]]];
                }
            }
        }
        for (; i < [py count]; i++)
        {
            if (i > 0)
                [sb appendString:@" "];
            [sb appendString:[T9Utils toFirstUpper:[py objectAtIndex:i]]];
        }
    }
    else
    {
        //首字母大写
        [py enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx > 0)
                [sb appendString:@" "];
            [sb appendString:[T9Utils toFirstUpper:obj]];
        }];
    }
    return sb;
}

@end
