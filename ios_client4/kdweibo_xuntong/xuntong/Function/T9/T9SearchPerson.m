//
//  T9SearchPerson.m
//  ContactsLite
//
//  Created by Gil on 13-1-23.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "T9SearchPerson.h"

#define kKeyUserId      @"userId"
#define kKeyFullPinYins @"fullPinYins"
@implementation T9SearchPerson

- (id)init {
    self = [super init];
    if (self) {
        _userId = 0;
        _fullPinyins = [[NSArray alloc] init];
    }
    return self;
}

-(void)setFullPinyin:(NSString *)fullPinyin
{
    if (![fullPinyin isKindOfClass:[NSNull class]] && fullPinyin) {
        //去掉左右的空格和换行符，防止错误的统计
        NSString * trimFullPinyin = [fullPinyin stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *fullPinyins = [trimFullPinyin componentsSeparatedByString:@" "];
        NSMutableArray *tempPinyins = [[NSMutableArray alloc]init];
        //去掉为空的单元
        if (fullPinyins) {
            for(NSArray * arr in fullPinyins)
            {
                if(![arr isEqual:@""])
                {
                    [tempPinyins addObject:arr];
                }
            }
            self.fullPinyins = tempPinyins;
        }
    }
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if(self)
    {
        self.userId = [[dict objectForKey:kKeyUserId] intValue];
        [self setFullPinyin:[dict objectForKey:kKeyFullPinYins]];
    }
    return self;
}

#pragma mark - isEqual

- (BOOL)isEqual:(T9SearchPerson *)object
{
    return (_userId == object.userId);
}

@end
