//
//  KDThirdPartAppAuthActionHandler.h
//  kdweibo_common
//
//  Created by laijiandong on 12-8-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDAbstractActionHandler.h"

@class KDResponseWrapper;

@interface KDThirdPartAppAuthActionHandler : KDAbstractActionHandler {
 @private
    
}

+ (KDQuery *)toQueryWithOpenURL:(NSURL *)url;

+ (NSString *)messageForAuthorizeDidFailResponse:(KDResponseWrapper *)response canRetry:(BOOL *)canRetry;

@end


