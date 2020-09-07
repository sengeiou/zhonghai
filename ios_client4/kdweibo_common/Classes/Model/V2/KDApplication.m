//
//  KDApplication.m
//  kdweibo_common
//
//  Created by Tan yingqi on 10/11/12.
//  Copyright (c) 2012 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDApplication.h"

@implementation KDApplication

@synthesize desc = desc_;
@synthesize detailDesc = detailDesc_;
@synthesize httpUrl = httpUrl_;
@synthesize iconUrl = iconUrl_;
@synthesize appId = appId_;
@synthesize installUrl = installUrl_;
@synthesize key = key_;
@synthesize mobileType = mobileType_;
@synthesize name = name_;
@synthesize networkId = networkId_;
@synthesize schemeUrl = schemeUrl_;
@synthesize tenantId = tenantId_;
@synthesize appVersion = appVersion_;
@synthesize needAuth = needAuth_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(desc_);
    //KD_RELEASE_SAFELY(detailDesc_);
    //KD_RELEASE_SAFELY(httpUrl_);
    //KD_RELEASE_SAFELY(iconUrl_);
    //KD_RELEASE_SAFELY(appId_);
    //KD_RELEASE_SAFELY(installUrl_);
    //KD_RELEASE_SAFELY(key_);
    //KD_RELEASE_SAFELY(mobileType_);
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(networkId_);
    //KD_RELEASE_SAFELY(schemeUrl_);
    //KD_RELEASE_SAFELY(tenantId_);
    //KD_RELEASE_SAFELY(appVersion_);
    
    //[super dealloc];
}
@end
