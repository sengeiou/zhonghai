//
//  KDWeiboServicesContext.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-15.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDWeiboServices.h"
#import "KDServiceActionExecutor.h"
#import "KDAppUserDefaultsAdapter.h"
#import "KDParserManager.h"
#import "KDWeiboDAOManager.h"

@protocol KDAuthorization;
@class KDWeiboServicesFactory;
@class KDImageLoaderAdapter;

@interface KDWeiboServicesContext : NSObject {
 @private
    KDWeiboServicesFactory *weiboServicesFactory_;
    KDServiceActionExecutor *serviceActionExecutor_;
    
    KDImageLoaderAdapter *imageLoaderAdapter_;
    KDAppUserDefaultsAdapter *userDefaultsAdapter_;
}

@property(nonatomic, retain, readonly) KDServiceActionExecutor *serviceActionExecutor;

+ (KDWeiboServicesContext *)defaultContext;

- (id<KDWeiboServices>)getKDWeiboServices;
- (KDImageLoaderAdapter *)getImageLoaderAdapter;

- (KDAppUserDefaultsAdapter *)userDefaultsAdapter;

// the global parser manager used to retrieve specicied parser.
- (KDParserManager *)globalParserManager;

// the global dao manager used to save results to database.
- (KDWeiboDAOManager *)globalWeiboDAOManager;

- (void)updateAuthorization:(id<KDAuthorization>)authorization;

- (NSString *)serverBaseURL;
- (NSString *)serverSNSBaseURL;

@end
