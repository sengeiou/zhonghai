//
//  KDABHelper.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDABHelper : NSObject

+ (BOOL)hasContactPermission;

+ (NSArray *)allPhoneContacts;
+ (NSArray *)allPhoneCompleteContacts;

@end
