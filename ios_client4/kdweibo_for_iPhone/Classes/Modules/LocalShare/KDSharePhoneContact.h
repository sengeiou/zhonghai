//
//  KDSharePhoneContact.h
//  kdweibo
//
//  Created by kingdee on 14-8-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDSharePhoneContact : NSObject
+ (KDSharePhoneContact *)defaultContactManager;
- (void)startAccessingAddressPerson;
@end
