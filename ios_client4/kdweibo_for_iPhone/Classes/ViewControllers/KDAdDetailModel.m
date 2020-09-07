//
//  KDAdDetailModel.m
//  kdweibo
//
//  Created by Darren on 15/4/17.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDAdDetailModel.h"

@implementation KDAdDetailModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
         id detailUrl =  dict[@"detailUrl"];
        if(![detailUrl isKindOfClass:[NSNull class]] && detailUrl)
        {
            self.detailUrl = detailUrl;
        }
        else {
            self.detailUrl = @"";
        }
        
        id pictureUrl = dict[@"pictureUrl"];
        if(![pictureUrl isKindOfClass:[NSNull class]] && pictureUrl)
        {
            self.pictureUrl = pictureUrl;
        }
        else {
            self.pictureUrl = @"";
        }
        
        id Description = dict[@"description"];
        if(![Description isKindOfClass:[NSNull class]] && Description)
        {
            self.Description = Description;
        }
        
        id canClose = dict[@"canClose"];
        if(![canClose isKindOfClass:[NSNull class]] && canClose)
        {
            self.canClose = [canClose boolValue];
        }
        
        id closeType = dict[@"closeType"];
        if(![closeType isKindOfClass:[NSNull class]] && closeType)
        {
            self.closeType = [closeType intValue];
        }
        
        id key = dict[@"key"];
        if(![key isKindOfClass:[NSNull class]] && key)
        {
            self.key = key;
        }
        
        id title = dict[@"title"];
        if(![title isKindOfClass:[NSNull class]] && title)
        {
            self.title = title;
        }
        
        id type = dict[@"type"];
        if(![type isKindOfClass:[NSNull class]] && type){
            self.type = [type integerValue];
        }
        
    }
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.detailUrl forKey:@"detailUrl"];
    [aCoder encodeObject:self.pictureUrl forKey:@"pictureUrl"];
    [aCoder encodeObject:self.Description forKey:@"Description"];
    [aCoder encodeObject:@(self.canClose) forKey:@"canClose"];
    [aCoder encodeObject:@(self.closeType) forKey:@"closeType"];
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:@(self.bDisplaying) forKey:@"bDisplaying"];
    [aCoder encodeObject:@(self.type) forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.detailUrl = [aDecoder decodeObjectForKey:@"detailUrl"];
        self.pictureUrl = [aDecoder decodeObjectForKey:@"pictureUrl"];
        self.Description = [aDecoder decodeObjectForKey:@"Description"];
        self.canClose = [[aDecoder decodeObjectForKey:@"canClose"] boolValue];
        self.closeType = [[aDecoder decodeObjectForKey:@"closeType"] intValue];
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.bDisplaying = [[aDecoder decodeObjectForKey:@"bDisplaying"] boolValue];
        self.type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
        }
    return self;
}
@end
