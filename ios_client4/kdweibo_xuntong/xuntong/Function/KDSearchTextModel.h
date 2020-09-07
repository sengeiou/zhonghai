//
//  KDSearchTextModel.h
//  kdweibo
//
//  Created by sevli on 15/8/7.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//  全局搜索文本模型

#import <Foundation/Foundation.h>
#import "GroupDataModel.h"


@class RecordDataModel;
@interface KDSearchTextModel : GroupDataModel


@property (nonatomic, assign) NSInteger count;//消息条数

@property (nonatomic ,copy) NSString *highlight;//高亮文本

@property (nonatomic, getter=more)BOOL more;//是否还有内容

@property (nonatomic, strong) RecordDataModel *searchMessageData;

-(id)initWithDictionary:(NSDictionary *)dict;

-(void)setMessageDataModel:(NSDictionary *)messageDict Highlight:(NSString *)highlight;

@end
