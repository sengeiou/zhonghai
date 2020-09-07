//
//  KDSignInPoint.h
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDSignInPoint : NSObject<NSCopying>

@property (nonatomic, strong) NSString *signInPointId;
@property (nonatomic, strong) NSString *positionName;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, strong) NSString *startWorkBegin;
@property (nonatomic, strong) NSString *startWorkEnd;
@property (nonatomic, strong) NSString *endWorkBegin;
@property (nonatomic, strong) NSString *endWorkEnd;
@property (nonatomic, strong) NSString *detailAddress;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger clockInSectionTimes;

@property (nonatomic, strong) NSMutableArray *wifiDataArray;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
