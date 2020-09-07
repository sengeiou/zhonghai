//
//  BuluoObject.h
//  KDWeiBoSDK
//
//  Created by haining_huang on 16/5/26.
//  Copyright © 2016年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenUser : NSObject
/** 用户id 必传*/
@property (nonatomic, copy) NSString *mId;
/** 微信社区id 必传*/
@property (nonatomic, copy) NSString *networkId;
/** 用户头像 */
@property (nonatomic, copy) NSString *photoUrl;
/** 用户名字 */
@property (nonatomic, copy) NSString *mName;
/** 用户手机号码 */
@property (nonatomic, copy) NSString *mTelephone;
/** 用户性别 */
@property (nonatomic, assign) int *mGender;

@end

