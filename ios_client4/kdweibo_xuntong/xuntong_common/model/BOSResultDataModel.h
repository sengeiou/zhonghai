//
//  BOSResultDataModel.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 数据返回模型类，所以以JSON数据格式返回的数据都遵从此模型
 */

#import "BOSBaseDataModel.h"

//云平台错误类型,目前仅对于认证接口
typedef enum _MCloudErrorType {
    MCloudNoError = 0,//没有错误
    MCloudGeneralError = 1,//通用错误
    MCloudVersionLowError = 2,//版本过低
    MCloudDeviceStateError = 3,//设备状态错误，即指令错误
    MCloudUserUnauthorizedError = 4,//用户白名单校验失败
    MCloudDeviceUnauthorizedError = 5,//设备未授权
    MCloudBindingPolicyError = 6,//用户设备的绑定策略检查失败
    MCloudTOSError = 7//TOS使用的服务条款未签署或许需要再签署
}MCloudErrorType;

//企业服务器错误类型，每个不同的业务服务器可能会存在不同的错误类型
typedef enum _EMPServerErrorType{
    EMPServerNoError = 0,//没有错误
    EMPServerGeneralError = 1,//通用错误
    EMPServerSessionExpiresError = 2,//会话过期
    EMPServerKeyExpiresError = 4//密钥失效
}EMPServerErrorType;


@interface BOSResultDataModel : BOSBaseDataModel{
    BOOL _success_;
    NSString *_error_;    
    int _errorCode_;      
    id _data_;            
}

//返回结果，成功与否
@property (nonatomic,assign) BOOL success;

//错误描述，一般用于显示
@property (nonatomic,copy) NSString *error;

//错误码，每个接口都可以不同
//对于MCloud Auth接口，见MCloudErrorType
//对于EMP Server接口，有几个码是所有接口通用的，见EMPServerErrorType
@property (nonatomic,assign) int errorCode;

//返回业务数据
@property (nonatomic,retain) id data;

// 返回的JSON原始数据，作为额外增加字段时的一种补充。add by Darren
@property (nonatomic, retain) NSDictionary *dictJSON;

/*
 @desc 判断某对象是否是BOSResultDataModel类的实例
 @param dataModel; -- 待判断的对象
 @return BOOL;
 since 3.0
 */
+(BOOL)isBOSResultDataModelClass:(id)dataModel;

@end
