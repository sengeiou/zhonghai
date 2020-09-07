//
//  KDAppDataModel.h
//  kdweibo
//
//  Created by AlanWong on 14-9-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//


/**
 *  4.2.6版本后台调整接口和返回的数据
 *  有关应用的model统一使用KDAppDataModel
 *  不再使用多个应用的model
 *
 */
#import <Foundation/Foundation.h>


typedef enum{
    KDAppTypeNativeKingdee = 1,     //金蝶本地应用
    KDAppTypeWeb = 2,               //web应用（企业内轻应用
    KDAppTypeNativeThirdPart = 3,   //本地应用 三方研发
    KDAppTypeLight = 4,             //轻应用
    KDAppTypePublic = 5,            //公共号应用
    KDAppTypeSpecial = 6,           // 原内嵌本地应用：签到、我的文件、任务、公共号
    KDAppTypeYunApp = 101           //云应用
}KDAppType;

typedef enum{
    KDAppActionTypeCompany = 1,        //企业级应用不可删除
    KDAppActionTypeManyCompany = 2,    //跨企业级应用不可删除
    KDAppActionTypeOrganization = 3,   //部门应用可以删除
    KDAppActionTypePerson = 4,         //个人应用可以删除
}KDAppActionType;


@interface KDAppDataModel : BOSBaseDataModel

@property(nonatomic,assign)KDAppType appType; //应用类型

@property(nonatomic ,copy)NSString * appName;//应用名称

@property(nonatomic ,copy)NSString * appID;//应用id

@property(nonatomic ,copy)NSString * appClientID;//应用客户端id (long)  (匹配提交客户端的类型)

@property(nonatomic ,copy)NSString * appDesc;// 应用的详细介绍

@property(nonatomic ,copy)NSString * appLogo;//应用的图标url

@property(nonatomic ,copy)NSString * downloadURL;//应用下载的url（类型4轻应用的打开地址）

@property(nonatomic ,copy)NSString * appClientSchema;//应用的跳转协议

@property(nonatomic ,copy)NSString * appClientVersion;//应用版本号，可能为null

@property(nonatomic ,copy)NSString * detailURL;// 应用介绍详情url地址

@property(nonatomic ,copy)NSString * versionUpdateTime;// 应用版本更新时间，可能为null
//以下属性针对appType== 2
@property(nonatomic ,copy)NSString * webURL; //web应用的入口地址
//以下属性针对appType== 5
@property(nonatomic ,copy)NSString * pid; //公共号id

@property(nonatomic,assign)KDAppActionType appActionMode;

@property(nonatomic, copy)NSString * packageName;

@property(nonatomic, copy)NSString *deleteAble; // 该应用能否被删 Yes/No

@property(nonatomic, strong)NSArray *appClasses;//app所属类型

//用于临时存储数据，不入库
@property(nonatomic,assign)BOOL delFlag;
@property(nonatomic,assign)BOOL isFeatureFuc;

//用于云app
@property(nonatomic,copy)NSString *appSecret;
//用于特殊的app(KDAppTypeSpecial)
@property (nonatomic, copy) NSString *FIOSLaunchParams;
@property (nonatomic, copy,readonly) NSString *iosSchdeme;


- (id)initWithDictionary:(NSDictionary *)dict;
-(id)initWithDictionaryFromWeb:(NSDictionary *)dict;



@end
