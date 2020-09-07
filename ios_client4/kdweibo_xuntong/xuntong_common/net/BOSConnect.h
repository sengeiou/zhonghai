//
//  BOSConnect.h
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "BOSResultDataModel.h"
#import "BOSConnectAuthDataModel.h"

//网络连接类型
typedef enum _BOSConnectType{
    BOSConnect4ActionParam = 0,//将action当做参数放在body中请求
    BOSConnect4DirectURL = 1//直接使用baseUrl+action的方式请求
}BOSConnectType;


//url的类型
typedef enum : NSUInteger {
    BOSConnectUrlTypeBasic,
    BOSConnectUrlTypeSNSAPI
} BOSConnectUrlType;

//body类型
typedef NS_ENUM (NSUInteger, BOSConnectBodyType) {
    BOSConnectBodyWithJSON = 0, //默认使用JSON提交
    BOSConnectBodyWithParam = 1,
};

//网络连接传输加密类型，是否启用DES加密传输
typedef enum _BOSConnectSecurityType{
    BOSConnectNotEncryption = 0,
    BOSConnectEncryption = 1
}BOSConnectSecurityType;
//网络连接返回的数据压缩类型，返回的数据是否允许启用GZip压缩
typedef enum _BOSConnectCompressedResponseType{
    BOSConnectResponseAllowCompressed = 0,
    BOSConnectResponseNotAllowCompressed = 1
}BOSConnectCompressedResponseType;
//网络连接发送的数据压缩类型，发送的数据是否启用GZip压缩
typedef enum _BOSConnectCompressedRequestBodyType{
    BOSConnectRequestBodyNotCompressed = 0,
    BOSConnectRequestBodyCompressed = 1
}BOSConnectCompressedRequestType;


//BOS连接的标识
typedef struct _BOSConnectFlags {
    BOSConnectType _connectType;//连接类型
    BOSConnectSecurityType _securityType;//是否加密
    BOSConnectCompressedResponseType _compressedResponseType;//返回值是否允许压缩
    BOSConnectCompressedRequestType _compressedRequestType;//发送的数据是否压缩
    BOOL needOAuth;//是否需要OAuth认证，如果需要请设置
}BOSConnectFlags;

//网络连接错误
typedef enum _BOSConnectError{
    BOSConnectParseResponseError = 12,
    BOSConnectParseParamError = 13
}BOSConnectError;


@interface BOSConnect : NSObject <ASIHTTPRequestDelegate>{
    ASIHTTPRequest *_httpRequest_;//用于网络连接
    BOOL _hasError_;
    int _errorCode_;
    NSString *_errorMessage_;
    
    __weak id _target_;//响应对象
    SEL _action_;//响应方法
    BOSConnectFlags _connectFlags_;//初始化标示
    
    /******
     *  base url - BOSConnect类本身不指定，可以用以下3种方法实现：
     *  1、继承BOSConnect，在子类的init调用setBaseUrlString方法设置；
     *  2、直接继承EMPServerClient（已经将base url设置为[BOSSetting sharedSetting].url）；
     *  3、使用EMPServerClient的category。
     ******/
    NSString *_baseUrlString_;
    
    //认证信息 如果需要认证，请务必调用setOAuthInfo方法
    BOSConnectAuthDataModel *_connectOAuthInfo_;
    
    //DES加密的Key，如果启用加密，则必须使用setDesKey设置
    NSString *_desKey_;
}

//标示是否存在错误
@property (nonatomic,assign) BOOL hasError;
/* 错误号
      1-11 参见 ASIHTTPRequest - ASINetworkErrorType
      12-13 参见 BOSConnectionError
      其他如404,403等等，常用的http错误
      0 表示无错误
 */
@property (nonatomic,assign) int errorCode;
//错误提示字符串
@property (nonatomic,strong) NSString *errorMessage;

//default is BOSConnectUrlTypeBasic
@property (nonatomic, assign) BOSConnectUrlType urlType;

//default is BOSConnectBodyWithJSON
@property (nonatomic, assign) BOSConnectBodyType bodyType;


//是否需要在post参数里添加ua
@property (nonatomic, assign) BOOL shouldAppendUA;


/*
 @desc 初始化方法
 @param target; -- 响应对象
 @param action; -- 响应方法
 @param connectionFlags; -- 连接标示，说明如下：
    _connectType; -- 连接类型，见 BOSConnectType（默认为BOSConnect4ActionParam）
    _responseType;   -- 接口的返回值类型，见 BOSConnectResponseType（默认采用JSON）
                        如果接口的返回值为非JSON，请务必在初始化方法中传入返回值类型，否则底层会提示JSON解析失败的错误；
                        如果接口的返回值为JSON且符合BOSResultDataModel模型，则会构造成BOSResultDataModel对象并返回，否则返回id类型
    _securityType;   -- 接口的数据传输是否使用加密，见 BOSConnectSecurityType（默认为不加密）
    _compressionType -- 接口的数据传输是否使用压缩，见 BOSConnectCompressionType（默认压缩）
 @return BOSConnect;
 */
-(id)initWithTarget:(id)target action:(SEL)action;
-(id)initWithTarget:(id)target action:(SEL)action connectionFlags:(BOSConnectFlags)connectFlags;

/*
 @desc http post
 @param urlStr; -- 访问的URL，短格式
 @param body; -- post的数据，不需要时则传入nil。类型可以为：NSDictionary（参数）、NSData（二进制）
 @param header; -- http头，不需要时则传入nil
 @param timeout; -- 超时时间，默认为30秒
 @return void;
 */
-(void)post:(NSString *)urlStr;
-(void)post:(NSString *)urlStr body:(id)body;
-(void)post:(NSString *)urlStr body:(id)body header:(NSDictionary *)header;
-(void)post:(NSString *)urlStr body:(id)body header:(NSDictionary *)header timeout:(NSTimeInterval)seconds;

/*
 @desc get
 @param urlStr; -- 访问的URL，短格式
 @param params; -- get 参数，不需要时则传入nil
 @param header; -- http头，不需要时则传入nil
 @param timeout; -- 超时时间，默认为30秒
 @return void;
 */
-(void)get:(NSString *)urlStr;
-(void)get:(NSString *)urlStr params:(NSDictionary *)params;
-(void)get:(NSString *)urlStr params:(NSDictionary *)params header:(NSDictionary *)header;
-(void)get:(NSString *)urlStr params:(NSDictionary *)params header:(NSDictionary *)header timeout:(NSTimeInterval)seconds;

/*
 @desc 检查字符串是否为Null或者nil，如果是，返回空字符串，否则返回本身
 @param str; -- 要检查的字符串
 @return NSString;
 */
-(NSString *)checkNullOrNil:(NSString *)str;

/*
 @desc 设置连接的Base URL String，BOSConnect类本身不指定，需要在子类的init方法中指定
 @param baseUrlString; -- base url string
 @return void;
 since 3.0
 */
-(void)setBaseUrlString:(NSString *)baseUrlString;

/*
 @desc 设置OAuth认证的信息，如果需要认证，请务必设置此信息
 @param oauthInfo;
 @return void;
 since 3.0
 */
-(void)setOAuthInfo:(BOSConnectAuthDataModel *)oauthInfo;

/*
 @desc 设置DES加密的Key
 @param desKey; -- DES加密Key
 @return void;
 since 3.0
 */
-(void)setDesKey:(NSString *)desKey;

/*
 @desc 将错误或者数据返回给目标类
 @param errorCode; -- 错误码
 @param object; -- 返回值，默认为nil
 @return void;
 since 3.0
 */
-(void)performWithErrorCode:(int)errorCode objcet:(id)object;

/**
 *	@brief	设置UserAgent
 *
 *	@param 	appId 	服务端应用ID
 *	@param 	instanceName 	实例名称
 */
+ (void)setUAWithAppId:(int)appId name:(NSString *)instanceName;

/**
 *  获取UserAgent
 *
 *  @return UserAgent
 */
+ (NSString *)userAgent;

//取消当前请求
- (void)cancelRequest;

@end
