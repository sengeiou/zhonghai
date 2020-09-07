//
//  KDMessageModel.m
//  kdweibo
//
//  Created by 王 松 on 14-5-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDMessageModel.h"

@implementation KDMessageModel

- (NSString *)groupId
{
    return [self checkNullOrNil:_groupId];
}

- (NSString *)publicId
{
    return [self checkNullOrNil:_publicId];
}

- (NSString *)toUserId
{
    return [self checkNullOrNil:_toUserId];
}

- (NSString *)content
{
    return [self checkNullOrNil:_content];
}

- (NSString *)param
{
    return [self checkNullOrNil:_param];
}
- (NSString *)isOriginalPic
{
    return [self checkNullOrNil:_isOriginalPic];;
}
- (NSString *)clientMessageId
{
    return  [self checkNullOrNil:_clientMessageId];
}

- (NSString *)checkNullOrNil:(NSString *)str
{
    if ([str isKindOfClass:[NSNull class]] || str == nil) {
        return @"";
    }
    return str;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_groupId);
    //KD_RELEASE_SAFELY(_publicId);
    //KD_RELEASE_SAFELY(_sendData);
    //KD_RELEASE_SAFELY(_toUserId);
    //KD_RELEASE_SAFELY(_content);
    //KD_RELEASE_SAFELY(_param);
    //KD_RELEASE_SAFELY(_clientMessageId);
    //KD_RELEASE_SAFELY(_isOriginalPic);
    //[super dealloc];
}

@end
