//
//  XTShareManager.h
//  kdweibo
//
//  Created by Gil on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTShareManager : NSObject

+ (BOOL)shareWithDictionary:(NSDictionary *)result;

+ (BOOL)shareWithDictionary:(NSDictionary *)result andChooseContentType:(XTChooseContentType)type;

@end
