//
//  KDSigninMedalModel.h
//  kdweibo
//
//  Created by shifking on 16/3/26.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDSigninMedalModel : NSObject
@property (assign , nonatomic) BOOL alertEnable;  //是否弹窗
@property (strong , nonatomic) NSString *picUrl;
@property (strong , nonatomic) NSString *detailAddress;  //访问地址
@property (strong , nonatomic) NSString *leftBtnText;
@property (strong , nonatomic) NSString *rightBtnText;
@property (strong , nonatomic) NSString *title;
@property (strong , nonatomic) NSString *content;
@property (assign , nonatomic) NSInteger priority;
@property (assign , nonatomic) NSInteger points;  //积分
@property (assign , nonatomic) NSInteger rank;   //排名
@property (assign , nonatomic) NSInteger medalLevel;  //勋章等级,0、1、2、3、4、5
@property (strong , nonatomic) NSString *appId;
/**
 *  勋章榜弹框类型，1：积分弹窗、2：勋章弹窗
 */
@property (assign , nonatomic) NSInteger alertType;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
