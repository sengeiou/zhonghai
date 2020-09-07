//
//  KDAdDetailModel.h
//  kdweibo
//
//  Created by Darren on 15/4/17.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 data : [
 
 {
 
 module :	//模块(message、contact、application、me)
 
 ads : [	//广告实体，一个或者多个
 
 {
 
 key : string	//广告唯一标识
 
 canClose : bool	//是否可以关闭
 
 closeType : int	//关闭后逻辑（1=关闭后永远不再显示，2=仅本次进程中关闭）
 
 description : string //广告描述
 
 pictureUrl : string	//广告图片地址
 
 detailUrl : string	//广告详情地址
 type:NSInteger  0:平台广告 1:企业广告
 },
 
 ...
 
 ]

 */

@interface KDAdDetailModel : NSObject<NSCoding>

@property(nonatomic, strong) NSString *detailUrl;
@property(nonatomic, strong) NSString *pictureUrl;
@property(nonatomic, strong) NSString *Description;
@property(nonatomic, assign) BOOL canClose;
@property(nonatomic, assign) int closeType;
@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) NSInteger type;

// UI展示用
@property(nonatomic, assign) BOOL bDisplaying;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
