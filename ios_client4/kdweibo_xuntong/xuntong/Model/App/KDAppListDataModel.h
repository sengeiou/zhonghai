//
//  KDAppListDataModel.h
//  kdweibo
//
//  Created by AlanWong on 14-9-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDAppDataModel.h"

@interface KDAppListDataModel : BOSBaseDataModel

@property(nonatomic,assign)NSInteger total;
@property(nonatomic,assign)BOOL end;
@property(nonatomic,strong)NSMutableArray * list;  //包含KDAppDataModel类型的数组

- (id)initWithDictionary:(NSDictionary *)dict ;

@end
