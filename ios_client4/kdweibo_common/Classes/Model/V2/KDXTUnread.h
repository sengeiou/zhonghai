//
//  KDXTUnread.h
//  kdweibo_common
//
//  Created by weihao_xu on 14-7-22.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDObject.h"
@interface KDXTUnread : KDObject

@property (nonatomic, retain) NSDictionary *unreadDictionary;

- (NSUInteger )unreadCountForUserId : (NSString *)userId;
@end
