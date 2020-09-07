//
//  KDLike.h
//  kdweibo_common
//
//  Created by kingdee on 14-9-2.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDObject.h"
#import "KDUser.h"

@interface KDLike : KDObject

@property (nonatomic, retain) NSString *likeId;
@property (nonatomic, retain) NSString *networkId;
@property (nonatomic, retain) NSString *refId;
@property (nonatomic, retain) NSString *refType;
@property (nonatomic, retain) NSDate   *time;
@property (nonatomic, retain) KDUser   *user;
@property (nonatomic, retain) NSString *userId;

@end