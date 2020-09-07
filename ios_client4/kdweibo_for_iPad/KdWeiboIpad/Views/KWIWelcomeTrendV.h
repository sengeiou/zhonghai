//
//  KWIWelcomeTrendV.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDTopic;

@interface KWIWelcomeTrendV : UIView

@property (retain, nonatomic) KDTopic *topic;

+ (KWIWelcomeTrendV *)viewForTrend:(KDTopic *)topic;

@end
