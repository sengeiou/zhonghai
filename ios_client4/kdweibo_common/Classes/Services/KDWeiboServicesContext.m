//
//  KDWeiboServicesContext.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-15.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDWeiboServicesContext.h"
#import "KDConfigurationContext.h"

#import "KDWeiboServicesFactory.h"
#import "KDImageLoaderAdapter.h"

static KDWeiboServicesContext *defaultKDWeiboContext_ = nil;


@interface KDWeiboServicesContext ()

@property(nonatomic, retain) KDWeiboServicesFactory *weiboServicesFactory;
@property(nonatomic, retain) KDServiceActionExecutor *serviceActionExecutor;
@property(nonatomic, retain) KDImageLoaderAdapter *imageLoaderAdapter;
@property(nonatomic, retain) KDAppUserDefaultsAdapter *userDefaultsAdapter;

@end


@implementation KDWeiboServicesContext

@synthesize weiboServicesFactory=weiboServicesFactory_;
@synthesize serviceActionExecutor=serviceActionExecutor_;
@synthesize imageLoaderAdapter=imageLoaderAdapter_;
@synthesize userDefaultsAdapter=userDefaultsAdapter_;

- (id)init {
    self = [super init];
    if(self){
        weiboServicesFactory_ = [[KDWeiboServicesFactory alloc] init];
        serviceActionExecutor_ = [[KDServiceActionExecutor alloc] init];
        
        imageLoaderAdapter_ = [[KDImageLoaderAdapter alloc] init];
        userDefaultsAdapter_ = [[KDAppUserDefaultsAdapter alloc] init];
    }
    
    return self;
}

+ (KDWeiboServicesContext *) defaultContext {
    if(defaultKDWeiboContext_ == nil){
        defaultKDWeiboContext_ = [[KDWeiboServicesContext alloc] init];
    }
    
    return defaultKDWeiboContext_;
}

- (id<KDWeiboServices>)getKDWeiboServices {
    return [weiboServicesFactory_ getDefaultKDWeiboServices];
}

- (KDImageLoaderAdapter *)getImageLoaderAdapter {
    return imageLoaderAdapter_;
}

- (KDAppUserDefaultsAdapter *)userDefaultsAdapter {
    return userDefaultsAdapter_;
}

- (KDParserManager *)globalParserManager {
    return [KDParserManager globalParserManager];
}

- (KDWeiboDAOManager *)globalWeiboDAOManager {
    return [KDWeiboDAOManager globalWeiboDAOManager];
}

- (void)updateAuthorization:(id<KDAuthorization>)authorization {
    [[self getKDWeiboServices] updateAuthorization:authorization];
}

- (NSString *)serverBaseURL {
    return [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getServerBaseURL];
}

- (NSString *)serverSNSBaseURL {
    return [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getRestBaseURL];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(weiboServicesFactory_);
    //KD_RELEASE_SAFELY(serviceActionExecutor_);
    
    //KD_RELEASE_SAFELY(imageLoaderAdapter_);
    //KD_RELEASE_SAFELY(userDefaultsAdapter_);
    
    //[super dealloc];
}

@end
