//
//  iAppRevisionServices.h
//  iAppRevision
//
//  Created by A449 on 15/12/16.
//  Copyright © 2015年 com.kinggrid. All rights reserved.
//

/*
 * 更新于：2017-02-17
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class iAppRevision;
@class iMessageServer;
@class KGBase64;

/** 网络服务类型 */
typedef NS_ENUM(NSInteger, iAppRevisionServiceType) {
    iAppRevisionServiceTypeBasic = 0,  //标准版
    iAppRevisionServiceTypeExtend,     //扩展版
};

@interface iAppRevisionService : NSObject {
    
}

@property (assign, nonatomic, readonly) iAppRevisionServiceType serviceType DEPRECATED_MSG_ATTRIBUTE("已弃用");

/** 单例模式初始化
 *
 * @return iAppRevisionServices单例对象
 */
+ (instancetype)service;

/** 从签批区域值中的单个签批数据的位置获取相对应的范围
 *
 * @param position   新的签批图片数据
 *
 * @return 范围
 */
+ (CGRect)fieldValueSignatureFrameFromPostion:(NSString *)position;

/** 从签批区域值中的单个签批数据的范围设置相对应的位置
 *
 * @param frame   新的签批图片数据
 *
 * @return 位置
 */
+ (NSString *)fieldValueSignaturePositionWithFrame:(CGRect)frame;

/** 将base64的图片信息转为图片数据
 *
 * @param base64String base64的图片字符串
 *
 * @return 图片数据
 */
- (NSData *)imageDataWithBase64String:(NSString *)base64String;

/** 将图片数据转为base64的图片信息
 *
 * @param imageData 图片数据
 *
 * @return base64的图片信息
 */
- (NSString *)imageBase64StringWithData:(NSData *)imageData;

/** 解析服务器上的原始签批数据
 *
 * @note 不支持扩展版
 *
 * @param fieldValue 原始签批数据
 *
 * @return 解析后的签批信息
 */
- (NSArray *)fieldValuesWithValue:(NSString *)fieldValue DEPRECATED_MSG_ATTRIBUTE("已弃用，使用“+fieldValuesWithValue:serviceType:”代替");
+ (NSArray *)fieldValuesWithValue:(NSString *)fieldValue serviceType:(iAppRevisionServiceType)serviceType;

/** 将解析后的签批信息组织成服务器所需要的签批信息
 *
 * @note 不支持扩展版
 *
 * @param fieldValues   解析后的签批信息
 *
 * @return 服务器所需要的签批信息
 */
- (NSString *)fieldValueFromValues:(NSArray *)fieldValues DEPRECATED_MSG_ATTRIBUTE("已弃用，使用“+fieldValueFromValues:serviceType:”代替");
+ (NSString *)fieldValueFromValues:(NSArray *)fieldValues serviceType:(iAppRevisionServiceType)serviceType;

/** 组织签批区域内的签批数据
 *
 * @note 标准版方法
 *
 * @param signatureImageData   新的签批图片数据
 * @param signatureRect        新的签批数据所在的区域位置
 * @param userName             签批的用户名
 * @param oldFieldValue        签批区域的原有数据，（新建的可以忽略）
 *
 * @return 签批区域数据
 */
- (NSString *)fieldValueWithSignatureImageData:(NSData *)signatureImageData
                                 signatureRect:(CGRect)signatureRect
                                      userName:(NSString *)userName
                                 oldFieldValue:(NSString *)oldFieldValue;

/** 组织签批数据
 *
 * @note 扩展版方法
 *
 * @param signatureData        签批数据（图片或文字）
 * @param signatureScale       签批图片缩放倍数
 * @param signatureType        签批类型（0：图片签批；1：文字批注。必须与signatureData对应）
 * @param dateTime             日期时间
 * @param userName             签批的用户名
 *
 * @return 签批值
 */
+ (NSString *)fieldValueEXWithSignatureData:(NSData *)signatureData
                             signatureScale:(NSString *)signatureScale
                              signatureType:(NSString *)signatureType
                                   dateTime:(NSString *)dateTime
                                   userName:(NSString *)userName;

#pragma mark - webService
/** 获取文件列表
 * @param webService  服务器地址
 * @param success     成功回调（docLists：文档列表。@[<NSArrary *>@{<NSDictionary *>@"dateTime" : @"日期时间",
                                                                @"recordID" : @"ID",
                                                                @"title" : @"标题",
                                                                @"userName" : @"用户名"},
                                                               @{字典2},
                                                  ...]）
 * @param failure     失败回调
 */
#warning - The parameter of "success" is changed from "message" to "docLists"
- (void)getDocListWithWebService:(NSString *)webService
                         success:(void (^)(NSArray *docLists))success
                         failure:(void (^)(NSError *error))failure;

/** 保存文档
 * @param webService  服务器地址
 * @param recordID    文档ID
 * @param userName    用户名
 * @param dateTime    日期时间
 * @param docNo       文档编号
 * @param security    保密级别
 * @param draft       草稿
 * @param check       处理进度
 * @param title       文档标题
 * @param copyTo      抄送
 * @param subject     关键字
 * @param copies      份数
 * @param success     成功回调
 * @param failure     失败回调
 */
- (void)saveDocWithWebService:(NSString *)webService
                     recordID:(NSString *)recordID
                     userName:(NSString *)userName
                     dateTime:(NSString *)dateTime
                        docNo:(NSString *)docNo
                     security:(NSString *)security
                        draft:(NSString *)draft
                        check:(NSString *)check
                        title:(NSString *)title
                       copyTo:(NSString *)copyTo
                      subject:(NSString *)subject
                       copies:(NSString *)copies
                      success:(void (^)(NSString *message))success
                      failure:(void (^)(NSError *error))failure;

/** 获取签名区域信息
 * @param webService  服务器地址
 * @param recordID    文档ID
 * @param success     成功回调（signatureInfo：签名区域信息。@{fieldName1 : userName1, fieldName2, userName2, ...}）
 * @param failure     失败回调
 */
#warning - The parameter of "success" is changed from "message" to "signatureInfo"
- (void)getSignatureInfoWithWebService:(NSString *)webService
                              recordID:(NSString *)recordID
                               success:(void (^)(NSDictionary *signatureInfo))success
                               failure:(void (^)(NSError *error))failure;

/** 加载单个签名区域内容
 * @param webService   服务器地址
 * @param recordID     文档记录号
 * @param fieldName    签名区域名称
 * @param userName     用户名
 * @param success      成功回调（fieldValue，签批区域的内容。）
 * @param failure      失败回调
 */
#warning - The parameter of "success" is changed from "message" to "fieldValue"
- (void)loadSignatureWithWebService:(NSString *)webService
                           recordID:(NSString *)recordID
                           userName:(NSString *)userName
                          fieldName:(NSString *)fieldName
                            success:(void (^)(NSString *fieldValue))success
                            failure:(void (^)(NSError *error))failure;

/** 加载多个签名区域内容
 * @param webService     服务器地址
 * @param recordID       文档记录号
 * @param signatureInfo  签名信息 @{fieldName1（NSString：签名区域名称）: userName1（NSString，用户名）,
                                   fieldName2（NSString：签名区域名称）: userName2（NSString，用户名）,
                                   ...}
 * @param success : 成功回调
 * @param failure : 失败回调
 * @param completion : 完成回调
 */
#warning - The parameter of "success" is changed from "message" to "fieldInfo"
- (void)loadSignatureWithWebService:(NSString *)webService
                           recordID:(NSString *)recordID
                      signatureInfo:(NSDictionary *)signatureInfo
                            success:(void (^)(NSDictionary *fieldInfo))success
                            failure:(void (^)(NSError *error))failure
                         completion:(void (^)(NSUInteger expectedTasksCount))completion;

/** 保存单个签名
 * @param webService   服务器地址
 * @param recordID     文档记录号
 * @param fieldName    签名区域名称
 * @param userName     用户名
 * @param fieldValue   签名值
 * @param dateTime     日期时间（格式：yyyy-MM-dd HH:mm:ss）
 * @param extractImage 是否单独提取签名图片
 * @param success      成功回调
 * @param failure      失败回调
 */
- (void)saveSignatureWithWebService:(NSString *)webService
                           recordID:(NSString *)recordID
                           userName:(NSString *)userName
                          fieldName:(NSString *)fieldName
                         fieldValue:(NSString *)fieldValue
                           dateTime:(NSString *)dateTime
                       extractImage:(BOOL)extractImage
                            success:(void (^)(NSString *message))success
                            failure:(void (^)(NSError *error))failure;

/** 保存单个签名
 * @param webService   服务器地址
 * @param recordID     文档记录号
 * @param fieldName    签名区域名称
 * @param userName     用户名
 * @param fieldValue   签名值
 * @param dateTime     日期时间（格式：yyyy-MM-dd HH:mm:ss）
 * @param allImage     追加所有签批图片
 * @param success      成功回调
 * @param failure      失败回调
 */
- (void)saveSignatureWithWebService:(NSString *)webService
                           recordID:(NSString *)recordID
                           userName:(NSString *)userName
                          fieldName:(NSString *)fieldName
                         fieldValue:(NSString *)fieldValue
                           dateTime:(NSString *)dateTime
                           allImage:(BOOL)allImage
                            success:(void (^)(NSString *message))success
                            failure:(void (^)(NSError *error))failure;

/** 保存单个签名
 * @param webService   服务器地址
 * @param recordID     文档记录号
 * @param fieldName    签名区域名称
 * @param userName     用户名
 * @param fieldValue   签名值
 * @param dateTime     日期时间（格式：yyyy-MM-dd HH:mm:ss）
 * @param success      成功回调
 * @param failure      失败回调
 */
- (void)saveSignatureWithWebService:(NSString *)webService
                           recordID:(NSString *)recordID
                           userName:(NSString *)userName
                          fieldName:(NSString *)fieldName
                         fieldValue:(NSString *)fieldValue
                           dateTime:(NSString *)dateTime
                            success:(void (^)(NSString *message))success
                            failure:(void (^)(NSError *error))failure;

/** 保存多个签名
 * @param webService   服务器地址
 * @param recordID     文档ID
 * @param userName     用户名
 * @param fieldInfo    域信息 @{fieldName1（NSString：签名区域名称）: fieldValue1（NString，base64类型，签名区域值）,
                               fieldName2（NSString：签名区域名称） : fieldValue2（NString，base64类型，签名区域值）,
                               ...}
 * @param dateTime     日期时间（格式：yyyy-MM-dd HH:mm:ss）
 * @param success      成功回调
 * @param failure      失败回调
 * @param completion   完成回调（剩余的线程任务，为0则所有任务都完成）
 */
- (void)saveSignatureWithWebService:(NSString *)webService
                           recordID:(NSString *)recordID
                           userName:(NSString *)userName
                          fieldInfo:(NSDictionary *)fieldInfo
                           dateTime:(NSString *)dateTime
                            success:(void (^)(NSString *message))success
                            failure:(void (^)(NSError *error))failure
                         completion:(void (^)(NSUInteger expectedTasksCount))completion;

/** 获取印章列表
 * @param webService  服务器地址
 * @param success     成功回调
 * @param failure     失败回调
 */
- (void)getSignatureListWithWebService:(NSString *)webService
                               success:(void (^)(NSString *message))success
                               failure:(void (^)(NSError *error))failure;

/** 获取印章内容
 * @param webService  服务器地址
 * @param imageName   印章名称
 * @param userName    用户名
 * @param password    印章密码
 * @param success     成功回调
 * @param failure     失败回调
 */
- (void)getSignatureImageWithWebService:(NSString *)webService
                              imageName:(NSString *)imageName
                               userName:(NSString *)userName
                               password:(NSString *)password
                                success:(void (^)(NSString *message))success
                                failure:(void (^)(NSError *error))failure;

/** 显示历史信息
 * @param webService  服务器地址
 * @param recordID    文档ID
 * @param fieldName   签名区域
 * @param userName    用户名
 * @param success     成功回调
 * @param failure     失败回调
 */
- (void)showHistoryWithWebService:(NSString *)webService
                         recordID:(NSString *)recordID
                        fieldName:(NSString *)fieldName
                         userName:(NSString *)userName
                          success:(void (^)(NSString *message))success
                          failure:(void (^)(NSError *error))failure;

/** 保存历史信息
 * @param webService   服务器地址
 * @param recordID     文档号
 * @param fieldName    签章区域
 * @param markName     印章名称
 * @param userName     用户名
 * @param dateTime     日期时间
 * @param markGuid     序列号
 * @param success      成功回调
 * @param failure      失败回调
 */
- (void)saveHistoryWithWebService:(NSString *)webService
                         recordID:(NSString *)recordID
                        fieldName:(NSString *)fieldName
                         markName:(NSString *)markName
                         userName:(NSString *)userName
                         dateTime:(NSString *)dateTime
                         markGuid:(NSString *)markGuid
                          success:(void (^)(NSString *message))success
                          failure:(void (^)(NSError *error))failure;

/** 保存签章日志信息
 * @param webService     服务器地址
 * @param historyArray   内容对象为字典（NSDictionary），@[@{recordID（NSString）: value（NSString，文档ID值）,
                                                        userName（NSString）: value（NSString，签名用户名称）,
                                                        fieldName（NSString）: value（NSString，签名区域名称）,
                                                        markName（NSString）: value（NSString，签章名称）,
                                                        markGuid（NSString）: value（NSString，签章序列号）,
                                                        dateTime（NSString）: value（NSString，签章日期时间）
                                                        },
                                                        ...]
 * @param success        成功回调
 * @param failure        失败回调
 * @param completion     完成回调
 */
- (void)saveHistoryWithWebService:(NSString *)webService
                     historyArray:(NSArray *)historyArray
                          success:(void (^)(NSString *message))success
                          failure:(void (^)(NSError *error))failure
                       completion:(void (^)(NSUInteger expectedTasksCount))completion;

#pragma mark - webService - 扩展版
/** 获取签名信息
 * @note 扩展版方法
 * @param webService  服务器地址
 * @param recordID    文档ID
 * @param fieldName   签批区域名称
 * @param userName    用户名
 * @param success     成功回调（signatureInfos：签批信息集合）
 * @param failure     失败回调
 */
- (void)getSignatureInfoWithWebService:(NSString *)webService recordID:(NSString *)recordID fieldName:(NSString *)fieldName userName:(NSString *)userName success:(void (^)(NSString *message))success failure:(void (^)(NSError *))failure DEPRECATED_MSG_ATTRIBUTE("已弃用，使用“-getSignatureEXInfoWithWebService:recordID:fieldName:userName:success:failure:”代替");
- (void)getSignatureEXInfoWithWebService:(NSString *)webService
                                recordID:(NSString *)recordID
                                userName:(NSString *)userName
                               fieldName:(NSString *)fieldName
                                 success:(void (^)(NSArray *signatureInfos))success
                                 failure:(void (^)(NSError *))failure DEPRECATED_MSG_ATTRIBUTE("已弃用，使用“-loadSignatureEXWithWebService:recordID:fieldName:userName:success:failure:”代替");

- (void)loadSignatureEXWithWebService:(NSString *)webService
                             recordID:(NSString *)recordID
                             userName:(NSString *)userName
                            fieldName:(NSString *)fieldName
                              success:(void (^)(NSString *fieldValue))success
                              failure:(void (^)(NSError *error))failure;

/** 保存签名
 * @note 扩展版方法
 * @param webService       服务器地址
 * @param recordID         文档ID
 * @param userName         用户名
 * @param fieldName        签批区域名称
 * @param signatureData    签名图片数据
 * @param signatureType    签名类型（0，手写签批；1，文字批注）
 * @param signatureScale   签名缩放比例
 * @param success          成功回调
 * @param failure          失败回调
 */
- (void)saveSignatureWithWebService:(NSString *)webService recordID:(NSString *)recordID userName:(NSString *)userName fieldName:(NSString *)fieldName signatureData:(NSData *)signatureData signatureType:(NSString *)signatureType signatureScale:(NSString *)signatureScale success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure DEPRECATED_MSG_ATTRIBUTE("已弃用，使用“-saveSignatureEXWithWebService:recordID:userName:fieldName:signatureData:signatureType:signatureScale:success:failure:”代替");
- (void)saveSignatureEXWithWebService:(NSString *)webService
                             recordID:(NSString *)recordID
                             userName:(NSString *)userName
                            fieldName:(NSString *)fieldName
                        signatureData:(NSData *)signatureData
                        signatureType:(NSString *)signatureType
                       signatureScale:(NSString *)signatureScale
                              success:(void (^)(NSString *))success
                              failure:(void (^)(NSError *))failure;

/** 保存签名
 * @note 扩展版方法
 * @param webService        服务器地址
 * @param recordID          NSString，文档ID
 * @param userName          用户名
 * @param fieldName         签批区域名称
 * @param fieldValueInfos   签批数据集合@[@{@"data" : NSData<图片数据>, 
                                          @"type" : NSString<@"0" 或 @"1"。0，手写签批；1，文字批注>, 
                                          @"scale" : NSString<图片缩放比例>}, 
                                        @{...},
                                      ...]
 * @param session           会话回调（expectedSessions：剩余会话数，currentSessionSuccess：当前会话是否成功，currentSessionCompletionMessage：当前会话完成的消息）
 */
- (void)saveSignatureEXWithWebService:(NSString *)webService
                             recordID:(NSString *)recordID
                             userName:(NSString *)userName
                            fieldName:(NSString *)fieldName
                      fieldValueInfos:(NSArray *)fieldValueInfos
                              session:(void (^)(NSUInteger expectedSessions, BOOL currentSessionSuccess, NSString *currentSessionCompletionMessage))session DEPRECATED_MSG_ATTRIBUTE("已弃用，使用“-saveSignatureEXWithWebService:recordID:fieldName:fieldValue:signatureType:session:”代替");

- (void)saveSignatureEXWithWebService:(NSString *)webService
                             recordID:(NSString *)recordID
                            fieldName:(NSString *)fieldName
                           fieldValue:(NSString *)fieldValue
                              session:(void (^)(NSUInteger expectedSessions, BOOL currentSessionSuccess, NSString *currentSessionCompletionMessage))session;

#pragma mark -
/** 取消任务 */
- (void)invalidateAndCancel;

@end
