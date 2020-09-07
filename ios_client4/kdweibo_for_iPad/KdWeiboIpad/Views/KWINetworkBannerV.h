//
//  KWINetworkBannerV.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/7/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDCommunity;

@interface KWINetworkBannerV : UIView

@property (retain, nonatomic) KDCommunity *network;

+ (KWINetworkBannerV *)viewWithNetwork:(KDCommunity *)network;

@end
