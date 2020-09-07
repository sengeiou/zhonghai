//
//  MFClient.h
//  MobileFamily
//
//  Created by kingdee eas on 13-5-15.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

/**
 *  与应用相关的接口调用集中到AppsClent中
 *  例如获取推荐应用列表、搜索应用、公共号等等
 *  alanwong 2014-9-24
 *
 */

#import "MCloudClient.h"
#import "EMPServerClient.h"


@interface AppsClient : MCloudClient

/**
 *  获取应用中心的应用数据
 *  4.2.6之后废弃，使用getAllApps这个方法
 */
-(void)getApps;
/**
 *  已经废弃的方法
 *  具体使用情况不明
 *
 */
-(void)getHotApps:(NSString *)type;
/**
 *  获取所有的公共号数据
 */
-(void)getPublicList;
/**
 *  批量获取公共号信息
 */
-(void)getPublicListWithPublicIds:(NSArray *)publicIds;
/**
 *  关注公共号
 *
 *  @param ID   关注的公共号ID
 *  @param data 0为取消关注，1为关注
 */
-(void)attention:(NSString*)ID withdata:(NSString*)data;
/**
 *  获取公共号的信息
 *
 *  @param ID 公共号的ID
 */
-(void)getPublicAccount:(NSString*)ID;

/**
 *  获取推荐应用列表数据
 */
-(void)getRecommendApps;
/**
 *  获取应用中心的应用数据
 */
-(void)getAllApps;
/**
 *  搜索应用
 *
 *  @param string 搜索的关键字
 *
 */
-(void)searchAppsWithKey:(NSString *)key;


/**
 *  上传被添加的单个轻应用/公共号的id
 *
 *  @param KDAppDataModel 当前被添加轻应用/公共号的数据结构
 *
 */
-(void)postOneApp:(KDAppDataModel *)app;


/**
 *  上传被添加的单个云端轻应用
 *
 *  @param KDAppDataModel 当前被添加轻应用/公共号的数据结构
 *
 */
-(void)postCloudApp:(KDAppDataModel *)app;

/**
 *  数据迁移将所有本地的轻应用/公共号的id上传
 *
 *  @param string 所有本地的轻应用/公共号的id拼接成的字符串
 *
 */
-(void)postAllLocalApps:(NSString *)apps;

/**
 *  告知服务器删除被选中的单个轻应用/公共号的id
 *
 *  @param KDAppDataModel 当前被选中轻应用/公共号的数据结构
 *
 */
-(void)deleteOneApp:(KDAppDataModel *)app;

/**
 *  断网情况下程序会记录用户删除的轻应用/公共号，网络连接时会上传这些被记录的轻应用/公共号id
 *
 *  @param string 所有这些轻应用/公共号的id拼接成的字符串
 *
 */
-(void)deleteFromNSUserDefaultWithApps:(NSString *)apps;

/**
 *  获取用户的应用列表
 */
-(void)queryAppList;

-(void)queryQrcodeInfo:(NSString *)url;


-(void)makeNoteWhenAppClickedWithMid:(NSString *)mid Appid:(NSString *)appid PersonId:(NSString *)personId;

// 获取微信社区帐号信息
- (void)getBuluoAccountWithEid:(NSString *)eid Oid:(NSString *)oid;

//app列表排序
-(void)sortAppListWithAppIds:(NSArray *)appIds;

@end

