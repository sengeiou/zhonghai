//
//  KWITrendStreamVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KWIRPanelVCtrl.h"

@class KDTopic;

@interface KWITrendStreamVCtrl : UIViewController <KWICardlikeVCtrl>

@property (retain, nonatomic) KDTopic *topic;

+ (KWITrendStreamVCtrl *)vctrlWithTopic:(KDTopic *)trend;

- (void)shadowOn;
- (void)shadowOff;

@end
