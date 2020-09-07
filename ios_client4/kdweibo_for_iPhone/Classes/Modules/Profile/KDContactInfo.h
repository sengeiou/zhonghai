//
//  KDContactInfo.h
//  kdweibo_common
//
//  Created by AlanWong on 15/1/12.
//  Copyright (c) 2015年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDContactInfo : NSObject
@property (retain, nonatomic) NSString * name;        //属性名称
@property (retain, nonatomic) NSString * type;        //属性类型，”E”表示email，”P”表示phone，”O”表示other

@property (retain, nonatomic) NSString * value;       //属性值
@property (retain, nonatomic) NSString * publicid;    //只有公共属性才会有的id
@property (retain, nonatomic) NSString * permission;  //权限，与publicid同时存在，”R”表示value不可修改，”W” 表示value可修改

- (id)initWithDictionary:(NSDictionary *)dict;

- (id)initWithName:(NSString *)name type:(NSString *)type value:(NSString *)value;

- (NSDictionary *)dictionary;

@end

@interface KDContactAttributeInfo : NSObject

@property (strong, nonatomic) NSString * attributeId;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * value; //属性值
@property (assign, nonatomic) NSInteger type; // 0不可修改 1可以修改

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
