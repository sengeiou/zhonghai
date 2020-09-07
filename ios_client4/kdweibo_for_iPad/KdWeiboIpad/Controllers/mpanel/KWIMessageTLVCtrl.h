//
//  KWIMessageTLVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/18/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMPanelVCtrl.h"

@class KWUser;

@interface KWIMessageTLVCtrl : KWIMPanelVCtrl

- (void)newMessage:(NSArray *)participants;

- (void)refresh;

@end
