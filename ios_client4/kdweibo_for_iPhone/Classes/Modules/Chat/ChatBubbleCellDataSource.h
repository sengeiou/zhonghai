//
//  ChatBubbleCellDataSource.h
//  kdweibo
//
//  Created by bird on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KDCompositeImageSource;
@class KDUser;

@protocol ChatBubbleCellDataSource <NSObject>
@optional
- (id) propertyForKey:(NSString *)key;
- (BOOL)hasLocationInfo;
- (NSString *)address;
- (void) setProperty:(id)obj forKey:(NSString *)key;
- (NSString *)message;
- (BOOL)isSystemMessage;
- (NSString*)timestamp;
- (KDCompositeImageSource *)compositeImageSource;
- (NSArray *)attachments;
- (float)latitude;
- (float)longitude;
- (KDUser *)sender;
- (NSTimeInterval)createdAtTime;
- (BOOL)isSending;
- (BOOL)isSendFailure;
- (BOOL)hasVideo;
@end
