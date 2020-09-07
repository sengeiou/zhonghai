//
//  KDLaunchAdsClient.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "BOSConnect.h"
typedef NS_ENUM(NSInteger,KDAdsLocationType){
    KDAdsLocationType_message,
    KDAdsLocationType_contact,
    KDAdsLocationType_application,   //应用页签广告
    KDAdsLocationType_me,
    KDAdsLocationType_pop,
    KDAdsLocationType_index//启动页
};

@interface KDAdsClient : BOSConnect
- (void)queryAdsWithLocationType:(KDAdsLocationType)locationType;
@end
