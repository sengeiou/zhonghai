//
//  KDResponseDiagnosis.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KDResponseWrapper;

@interface KDResponseDiagnosis : NSObject {
@private
    KDResponseWrapper *responseWrapper_;
    int statusCode_;
    
    NSDictionary *codeToReason_;
}

@property (nonatomic, retain, readonly) KDResponseWrapper *responseWrapper;

- (id) initWithResponseWrapper:(KDResponseWrapper *)responseWrapper;

- (BOOL) resourceNotFound;
- (NSString *) getErrorMessage;

- (NSString *)networkErrorMessage;

@end
