//
//  KDVersion.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-13.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    Alpha = 0x01,
    Beta,
    ReleaseCondidate,
    Release,
}KDReleaseStatus;


@interface KDVersion : NSObject {
@private
    
    NSInteger major_; // 1.x.x
    NSInteger minor_; // x.1.x
    NSInteger micro_; // x.x.1
    
    KDReleaseStatus releaseStatus_;
    NSString *dateString_;
    
    NSString *versionString_; // 1.8.3_beta1_0415 --> 1.8.3.beta1_0827
}

- (id) initWithMajor:(NSInteger)major minor:(NSInteger)minor micro:(NSInteger)micro 
       releaseStatus:(KDReleaseStatus)releaseStatus dateString:(NSString *)dateString;

- (id) initWithVersionString:(NSString *)versionString;

@property (nonatomic, assign, readonly) NSInteger major;
@property (nonatomic, assign, readonly) NSInteger minor;
@property (nonatomic, assign, readonly) NSInteger micro;

@property (nonatomic, assign, readonly) KDReleaseStatus releaseStatus;
@property (nonatomic, copy, readonly) NSString *dateString;

@property (nonatomic, copy, readonly) NSString *versionString;

- (NSComparisonResult) compare:(KDVersion *)version;

// quick compare the version A and version B, If these two versions can do compare together return YES. otherwise return NO
// Please check the comparison result as final result.
+ (BOOL) quickCompareVersionA:(NSString *)versionStringA versionB:(NSString *)versionStringB results:(NSComparisonResult *)results;

+ (BOOL)quickCompareVersionA:(NSString *)versionStringA versionB:(NSString *)versionStringB results:(NSComparisonResult *)results inRange:(NSRange)range;
@end
