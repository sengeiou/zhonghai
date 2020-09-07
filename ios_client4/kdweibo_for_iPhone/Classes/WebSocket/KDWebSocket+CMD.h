//
//  KDWebSocket+CMD.h
//  kdweibo
//
//  Created by Gil on 15/12/3.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWebSocket.h"

@interface KDWebSocket (CMD)

- (void)queryAll;

- (void)handle:(id)message;
- (void)handle:(id)message needRecord:(BOOL)needRecord;

@end
