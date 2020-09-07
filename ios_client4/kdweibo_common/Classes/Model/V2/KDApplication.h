//
//  KDApplication.h
//  kdweibo_common
//
//  Created by Tan yingqi on 10/11/12.
//  Copyright (c) 2012 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDApplication : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *detailDesc;
@property (nonatomic, copy) NSString *httpUrl;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *installUrl;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *mobileType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *networkId;
@property (nonatomic, copy) NSString *schemeUrl;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *appVersion;

@property (nonatomic, assign) BOOL   needAuth;

@end
