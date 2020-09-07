//
//  KDFileInMessageDataModel.h
//  kdweibo
//
//  Created by janon on 15/3/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDFileInMessageDataModel : NSObject
@property(nonatomic, strong) NSString *networkId;
@property(nonatomic, strong) NSString *personId;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *fileId;
@property(nonatomic, strong) NSString *messageId;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSDate *time;
@property(nonatomic, strong) NSString *length;
@property(nonatomic, strong) NSString *contentType;
@property(nonatomic, strong) NSString *fileExt;
@property(nonatomic, assign) BOOL encrypted;
@property(nonatomic, assign) BOOL fileHasOrNot;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
