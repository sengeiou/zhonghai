//
//  BaseAppDataModel.h
//  kdweibo
//
//  Created by stone on 14-4-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//enum KDAppType
//{
//    KDAppTypeNativeKingdee = 1,     //本地应用 金蝶研发
//    KDAppTypeWeb = 2,               //web应用
//    KDAppTypeNativeThirdPart = 3,   //本地应用 三方研发
//    KDAppTypeLight = 4              //轻应用
//};

@interface BaseAppDataModel : NSObject
{
    int appType;
    NSString *appID;                    //应用ID
    NSString *appClientID;              //应用客户端ID
    NSString *appName;                  //应用名称
    NSString *appLogo;                  //应用的Logo图片
    NSString *appDescribe;              //应用的描述
    NSDictionary *data;
}

@property (nonatomic,copy) NSString *appID;
@property (nonatomic,assign) int appType;
@property (nonatomic,copy) NSString *appClientID;
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSString *appLogo;
@property (nonatomic,copy) NSString *appDescribe;
@property (nonatomic,copy) NSDictionary *data;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)getData;

@end
