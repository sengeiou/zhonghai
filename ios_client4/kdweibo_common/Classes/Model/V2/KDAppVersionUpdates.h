//
//  KDAppVersionUpdates.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    KDWeiboUpdatePolicyNot = 0x00,
    KDWeiboUpdatePolicyRecommend,
    KDWeiboUpdatePolicyMust
}KDWeiboUpdatePolicy;

@interface KDAppVersionUpdates : NSObject <NSCoding> {
@private
    NSString *buildNumber_;
    NSString *version_;
    NSString *updateURL_;
    NSString *commentURL_;
    NSString *forceUpdateNo_;
    KDWeiboUpdatePolicy updatePolicy_;
    NSString *desc_;
    NSArray *changes_;
}

@property (nonatomic, retain) NSString *buildNumber;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *updateURL;
@property (nonatomic, copy)   NSString *commentURL;
@property (nonatomic, assign) KDWeiboUpdatePolicy updatePolicy;
@property (nonatomic, retain) NSArray *changes;
@property (nonatomic, copy) NSString *forceUpdateNo;
@property (nonatomic, retain) NSString *desc;

+ (void)store:(KDAppVersionUpdates *)versionUpdates;
+ (KDAppVersionUpdates *)retrieveLatestVersionUpdates;

@end
