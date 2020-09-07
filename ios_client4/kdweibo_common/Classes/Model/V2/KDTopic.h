//
//  KDTopic.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-17.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"

@class KDStatus;

@interface KDTopic : KDObject

@property (nonatomic, retain) NSString *topicId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *internalAd;

@property (nonatomic, assign) BOOL isHot;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, copy) NSString *truncatedName;
@property (nonatomic, retain) KDStatus *latestStatus;

@end
