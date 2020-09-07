//
//  KDAutoSignInLinkWifiController.h
//  kdweibo
//
//  Created by lichao_liu on 1/12/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAutoSignInLinkWifiController : UIViewController
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *bssid;
@property (nonatomic, strong) NSString *attendSetId;
@property (nonatomic, strong) NSString *featureName;

- (void)setSsid:(NSString *)ssid bssid:(NSString *)bssid attendSetId:(NSString *)attendSetId featureName:(NSString *)featureName;
@end
