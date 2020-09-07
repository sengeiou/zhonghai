//
//  NSString+Schema.h
//  kdweibo
//
//  Created by shen kuikui on 14-6-6.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KDSchemeHostType){
    KDSchemeHostType_NONE = 0,  //字符串为空
    KDSchemeHostType_NOTURI = 1,//非uri
    KDSchemeHostType_Unknow = 2,//不可识别的url
    KDSchemeHostType_HTTP = 3,
    KDSchemeHostType_HTTPS = 4,
    
    
    KDSchemeHostType_Status,//微博详情
    KDSchemeHostType_Topic,//话题
    KDSchemeHostType_Local,//设备的本地能力
    KDSchemeHostType_Todo,//任务详情
    KDSchemeHostType_Todonew,//新建任务
    KDSchemeHostType_Todolist,//任务列表
    KDSchemeHostType_Chat,//会话
    KDSchemeHostType_PersonalSetting,//个人设置
    KDSchemeHostType_Profile, //人员详情
    
    
    KDSchemeHostType_Signin,//签到点设置成功
    KDSchemeHostType_wifiSignInSetting,//关联成功
    KDSchemeHostType_wifiLink,//5人wifi签到后将这个wifi添加到签到点的可关联wifi列表中
    
    KDThirdPartSchemaType_Chat,     //为了兼容旧协议，请使用 KDSchemeHostType_Chat
    KDThirdPartSchemaType_Start,
    KDThirdPartSchemaType_Share,
    KDThirdPartSchemaType_Open,
    
    
    KDSchemeHostType_Start,//开始
    KDSchemeHostType_Share,//分享
    KDSchemeHostType_Invite,

    KDSchemeHostType_VoiceMeeting,   //在当前会话发起语音会议
    KDSchemeHostType_CreateVoiceMeeting, //发起语音会议
    KDSchemeHostType_FilePrevew, //文件预览
    KDSchemeHostType_EnterpriseAuth, //企业认证
    KDSchemeHostType_OrgList, //组织架构
    KDSchemeHostType_Appdetail, //应用详情
    KDSchemeHostType_Appcategory,    //应用分类
    KDSchemeHostType_LightApp,    //轻应用
    
};

@interface NSString (Scheme)
/**
 *  内部功能跳转协议解析
 *  if type = KDSchemeHostType_NONE, return nil
 *  if type = KDSchemeHostType_NOTURI or KDSchemeHostType_Unknow, return NSString
 *  if type = KDSchemeHostType_HTTP or KDSchemeHostType_HTTPS, return NSString
 *  if type = other, return NSDictionary
 */
- (id)internalSchemeInfoWithType:(out KDSchemeHostType *)type;

/**
 *  外部功能跳转协议解析，比如第三方APP跳转
 *  if type = KDSchemeHostType_NONE, return nil
 *  if type = KDSchemeHostType_NOTURI or KDSchemeHostType_Unknow, return NSString
 *  if type = KDSchemeHostType_HTTP or KDSchemeHostType_HTTPS, return NSString
 *  if type = other, return NSDictionary
 */
- (id)externalSchemeInfoWithType:(out KDSchemeHostType *)type;


/**
 *  if type = KDSchemeHostType_NONE, return nil
 *  if type = KDSchemeHostType_NOTURI or KDSchemeHostType_Unknow, return NSString
 *  if type = KDSchemeHostType_HTTP or KDSchemeHostType_HTTPS, return NSString
 *  if type = other, return NSDictionary
 */
- (id)schemeInfoWithType:(out KDSchemeHostType *)type shouldDecoded:(BOOL)shouldDecoded;

//给链接后面累加上参数
- (NSString *)addParams:(NSString *)params;
- (NSString *)appendParamsForShare;
@end
