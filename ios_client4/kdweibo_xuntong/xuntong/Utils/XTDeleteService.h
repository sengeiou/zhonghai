//
//  XTDeleteService.h
//  XT
//
//  Created by Gil on 13-10-14.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTDeleteService : NSObject

+ (XTDeleteService *)shareService;

- (void)deleteGroupWithGroupId:(NSString *)groupId;
- (void)deleteMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId;
- (void)deleteMessageWithPublicId:(NSString *)publicId groupId:(NSString *)groupId msgId:(NSString *)msgId;
- (void)cancelMessageWithGroupId:(NSString *)groupId msgId:(NSString *)msgId;
@end
