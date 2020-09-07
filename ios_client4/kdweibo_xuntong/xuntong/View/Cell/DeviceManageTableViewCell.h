//
//  DeviceManageTableViewCell.h
//  kdweibo
//
//  Created by kingdee on 2019/5/21.
//  Copyright © 2019 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceInfoModel.h"

@class DeviceInfoModel;
@interface DeviceManageTableViewCell : KDTableViewCell
@property (nonatomic,strong) DeviceInfoModel *deviceModel;
@end
