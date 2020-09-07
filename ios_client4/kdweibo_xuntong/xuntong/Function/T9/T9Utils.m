//
//  T9Utils.m
//  ContactsLite
//
//  Created by Gil on 13-1-24.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "T9Utils.h"

@implementation T9Utils

+(int)getMatchWord:(NSArray *)match
{
    if (match == nil)
        return 0;
    int rtn = 0;
    for (int i = 0; i < [match count]; i++) {
        id matchObj = [match objectAtIndex:i];
        rtn += (matchObj != [NSNull null] && [matchObj intValue] > 0) ? 1 : 0;
    }
    return rtn;
}

+(NSString *)toFirstUpper:(NSString *)s
{
    if (s.length == 0)
        return s;
    if ([s characterAtIndex:0] >= 'a' && [s characterAtIndex:0] <= 'z') {
        return [NSString stringWithFormat:@"%c%@",(char) ([s characterAtIndex:0] - 32),[s substringFromIndex:1]];
    }
    return s;
}

+(int)getCharMaxLen
{
    return 37;
}

+(int)getIndex:(char)ch
{
    if (ch >= 'a' && ch <= 'z') {
        return ch - 'a' + 11;
    }
    if (ch >= 'A' && ch <= 'Z') {
        return ch - 'A' + 11;
    }
    if (ch >= '0' && ch <= '9') {
        return ch - '0' + 1;
    }
    return 0;
}

+(BOOL)isWanted:(unichar)character
{
    if(character >= 'a' && character <= 'z')
        return YES;
    if(character > 0x4E00 && character < 0x9FFF){
        return YES;
    }
    if(character >= 'A' && character <= 'Z')
        return YES;
    if(character >= '0' && character <= '9')
        return YES;
    return NO;
}

static NSArray *t9 = nil;

+(NSString *)getChars:(char)ch
{
    if (t9 == nil) {
        t9 = [[NSArray alloc ] initWithObjects:@"abc2", @"def3", @"ghi4", @"jkl5", @"mno6", @"pqrs7", @"tuv8", @"wxyz9", nil];
    }
        
    if (ch >= '2' && ch <= '9') {
        return t9[ch - '2'];
    } else if (ch >= 'a' && ch <= 'z') {
        return [NSString stringWithFormat:@"%c",ch];
    } else if (ch >= 'A' && ch <= 'Z') {
        return [NSString stringWithFormat:@"%c",ch];
    } else {
        return [NSString stringWithFormat:@"%d",0];
    }
}


+ (NSArray *)getPinYins:(NSString *)fullPinyins
{
    NSString * trimFullPinyin = [fullPinyins stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *pys = [trimFullPinyin componentsSeparatedByString:@" "];
    NSMutableArray *tempPinyins = [[NSMutableArray alloc]init];
    //去掉为空的单元
    if (pys) {
        for(NSArray * arr in pys)
        {
            if(![arr isEqual:@""])
            {
                [tempPinyins addObject:arr];
            }
        }
    }
    return tempPinyins;
}



@end
