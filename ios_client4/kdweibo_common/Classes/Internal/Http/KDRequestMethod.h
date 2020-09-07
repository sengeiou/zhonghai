//
//  KDRequestMethod.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDRequestMethod : NSObject  {
@private
    NSString *name_;
}

@property (nonatomic, copy) NSString *name;

- (id) initWithName:(NSString *)name;

+ (KDRequestMethod *) GET;
+ (KDRequestMethod *) POST;
+ (KDRequestMethod *) DELETE;
+ (KDRequestMethod *) HEAD;
+ (KDRequestMethod *) PUT;

+ (KDRequestMethod *) getInstance:(NSString *)name;

- (BOOL) isPostMethod;
- (BOOL) isGetMethod;

@end
