//
//  KDActionPathsConfigurator.h
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDActionPathsConfigurator : NSObject {
 @private
    NSDictionary *customizeServiceNames_;
}

- (BOOL)isValidActionPath:(NSString *)actionPath;
- (BOOL)isValidServiceName:(NSString *)serviceName forActionPath:(NSString *)actionPath;

- (NSArray *)allAllowedActionPaths;
- (NSArray *)serviceNamesForActionPath:(NSString *)actionPath;

@end
