//
//  KDSignInSchema.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDObject.h"

@interface KDSignInSchema : KDObject
@property(nonatomic, assign)NSInteger count;
@property(nonatomic, retain)NSDate *time;
@end
