//
//  T9SearchPerson.h
//  ContactsLite
//
//  Created by Gil on 13-1-23.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface T9SearchPerson : BOSBaseDataModel

//本地表中的id，用于搜索表，非personId
@property (nonatomic,assign) int userId;
//T9搜索初始化字段
@property (nonatomic,retain) NSArray *fullPinyins;
@property (nonatomic,retain) NSString * personId;

-(void)setFullPinyin:(NSString *)fullPinyin;

@end
