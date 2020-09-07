//
//  KDLocationDefineManager.h
//  kdweibo
//
//  Created by lichao_liu on 5/12/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^DidLocationSuccessBlock)(CLLocation *data);

@interface KDLocationDefineManager : NSObject
@property(nonatomic, copy) DidLocationSuccessBlock locationSuccessBlock;

+(KDLocationDefineManager *)shareManager;
- (void)startLocation;
- (void)stopLocationOperation;

@end
