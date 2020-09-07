//
//  XTContactDataModel.m
//  XT
//
//  Created by Gil on 13-7-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContactDataModel.h"

@implementation XTContactDataModel

- (id)initWithType:(ContactDataType)type canOpen:(BOOL)canOpen datas:(NSArray *)datas
{
    self = [super init];
    if (self) {
        _type = type;
        _canOpen = canOpen;
        _datas = datas;
    }
    return self;
}

+ (id)dataWithType:(ContactDataType)type canOpen:(BOOL)canOpen datas:(NSArray *)datas
{
    return [[XTContactDataModel alloc] initWithType:type canOpen:canOpen datas:datas];
}

@end


@implementation XTContactFirstDataModel

- (id)initWithType:(ContactDataType)type title:(NSString *)title count:(int)count
{
    self = [super init];
    if (self) {
        _type = type;
        _title = [title copy];
        _count = count;
    }
    return self;
}

+ (id)dataWithType:(ContactDataType)type title:(NSString *)title count:(int)count
{
    return [[XTContactFirstDataModel alloc] initWithType:type title:title count:count];
}

@end


@implementation XTContactSecondDataModel

- (id)initWithType:(ContactDataType)type title:(NSString *)title fold:(BOOL)fold
{
    self = [super init];
    if (self) {
        _type = type;
        _title = [title copy];
        _fold = fold;
    }
    return self;
}

+ (id)dataWithType:(ContactDataType)type title:(NSString *)title fold:(BOOL)fold
{
    return [[XTContactSecondDataModel alloc] initWithType:type title:title fold:fold];
}

@end
