//
//  KDSearchTextModel.m
//  kdweibo
//
//  Created by sevli on 15/8/7.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSearchTextModel.h"

@implementation KDSearchTextModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self)
    {
        
    }
    return self;
}

-(void)setMessageDataModel:(NSDictionary *)messageDict Highlight:(NSString *)highlight
{
    if (!_searchMessageData)
    {
        _searchMessageData = [[RecordDataModel alloc]initWithDictionary:messageDict];
    }
    
    if (![_highlight isEqualToString:highlight])
    {
        _highlight = highlight;
    }
    
}

@end
