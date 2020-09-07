//
//  KDServiceActionPath.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

// eg: /statuses/:update
// /statuses/ is the action path,
// :update is the service name

@interface KDServiceActionPath : NSObject {
 @private
	NSString *actionPath_;
	NSString *serviceName_;
}

@property(nonatomic, retain) NSString *actionPath;
@property(nonatomic, retain) NSString *serviceName;

- (id)initWithActionPath:(NSString *)actionPath serviceName:(NSString *)serviceName;

// the fully action path like /statuses/:update
+ (KDServiceActionPath *)serviceActionPath:(NSString *)fullyActionPath;

- (BOOL)isEqualsToFullyActionPath:(NSString *)fullyActionPath;

@end
