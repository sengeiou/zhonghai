//
//  MFAppDataModel.h
//  MobileFamily
//
//  Created by kingdee eas on 13-5-16.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseAppDataModel.h"
@interface MFAppDataModel : BaseAppDataModel
{
    int appStatus;                      //应用状态, 二进制数值,转化为二进制值      后从右边数,第一位值表示此应用是否为正式购买应用(0—否,1—是),第二位值表示设备是否授权此应用(0—否,1—是).
    NSString *appClientSchema;             //应用的调整协议,用于打开应用
    NSString *appDldURL;                //应用的下载地址,用于跳转到应用详情页面
    NSString *appVersion;
}
@property (nonatomic,assign) int appStatus;
@property (nonatomic,copy) NSString *appClientSchema;
@property (nonatomic,copy) NSString *appDldURL;
@property (nonatomic,copy) NSString *appVersion;
@property (nonatomic) BOOL isLightApp;     //是否轻应用
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary2:(NSDictionary *)dict;
@end
