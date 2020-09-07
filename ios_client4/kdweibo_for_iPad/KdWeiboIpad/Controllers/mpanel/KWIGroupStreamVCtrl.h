//
//  KWIGroupStreamVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMPanelVCtrl.h"

@class KDGroup;

@interface KWIGroupStreamVCtrl : KWIMPanelVCtrl

@property (retain, nonatomic) KDGroup *group;

+ (KWIGroupStreamVCtrl *)vctrlWithGroup:(KDGroup *)group;

@end
