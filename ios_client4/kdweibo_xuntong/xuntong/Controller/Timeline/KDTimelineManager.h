//
//  KDTimelineManager.h
//  kdweibo
//
//  Created by AlanWong on 14-10-9.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDTimelineManager : NSObject
+(KDTimelineManager *)shareManager;
//查询是否已经完成了分页请求初始化
-(BOOL)shouldStarPagingRequest;
//设置已经完成分页请求初始化的标识
-(void)setFinishPageRequest;
//获取当前已经页数
-(NSInteger)numberOfPages;
//设置当前已经获取的页数
-(void)setNumberOfPages:(NSInteger)numberOfPages;

//删除相关工作圈的数据（在推出工作圈的时候，需要调用）
-(void)deleteCompanyInfoForPageRequest;

@end
