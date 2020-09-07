//
//  KDContactGroupDataMdeol.h
//  kdweibo
//
//  Created by AlanWong on 14-9-30.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

/**
 *  一个KDContactGroupDataModel的数据，包含在通讯录一个分组的数据
 *  sectionName 这个分组的名字，例如：最近联系人、"A"、"B"，用于显示HeaderView的文本
 *  contactArray 该分组的联系人信息，为PersonSimpleDataModel
 *
 *
 */

#import <Foundation/Foundation.h>

@interface KDContactGroupDataModel : NSObject
@property(nonatomic,strong)NSString * sectionName;
@property(nonatomic,copy)NSArray * contactArray;

@end
