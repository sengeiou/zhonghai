//
//  SimplePersonListDataModel.h
//  kdweibo
//
//  Created by wenbin_su on 15/5/21.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface SimplePersonListDataModel : BOSBaseDataModel
@property (nonatomic,assign) int count;//记录总数
@property (nonatomic,strong) NSMutableArray *list;

@property (nonatomic, assign) BOOL isFilterTeamAcc;

@property (nonatomic,assign) int totalCount;//记录总数
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger lastUpdateScore;

@property (nonatomic,strong) NSMutableArray *delList;

@end
