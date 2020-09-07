//
//  KDWeiboServicesImpl.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDWeiboServices.h"
#import "KDAuthorization.h"

@interface KDWeiboServicesImpl : NSObject <KDWeiboServices> {
@private
    id<KDAuthorization> authorization_;
    
    NSString *currentCommunityDomain_;
}

@property (nonatomic, retain) id<KDAuthorization> authorization;

- (id)initWithAuthorization:(id<KDAuthorization>)authorization;

@end
