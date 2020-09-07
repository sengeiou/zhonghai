//
//  KWIConversationVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/21/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWIRPanelVCtrl.h"
@class KDDMThread;

@interface KWIConversationVCtrl : UIViewController<KWICardlikeVCtrl>

+ (KWIConversationVCtrl *)vctrlForThread:(KDDMThread *)thread;

- (KDDMThread *)data;
@property(nonatomic, retain)NSArray * participants;
@end
