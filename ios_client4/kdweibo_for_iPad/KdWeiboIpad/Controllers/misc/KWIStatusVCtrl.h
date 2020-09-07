//
//  KWIStatusVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/26/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KWIRPanelVCtrl.h"

@class KDStatus;

@interface KWIStatusVCtrl : UIViewController <KWICardlikeVCtrl>

@property (nonatomic, retain) KDStatus *data;

+ (KWIStatusVCtrl *)vctrlWithStatus:(KDStatus *)status;
+ (KWIStatusVCtrl *)vctrlWithStatusId:(NSString *)statusId;
- (void)dismissPopoverController;
- (void)shadowOn;
- (void)shadowOff;

@end
