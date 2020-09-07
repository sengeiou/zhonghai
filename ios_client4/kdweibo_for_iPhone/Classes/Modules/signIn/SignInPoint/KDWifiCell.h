//
//  KDWifiCell.h
//  kdweibo
//
//  Created by lichao_liu on 1/27/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDWifiCell : UITableViewCell
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *wifiSsidStr;
- (void)setWifiBssid:(NSString *)wifiBssid;
@end
