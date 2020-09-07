//
//  KDAppVersionUpdates.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-12.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDAppVersionUpdates.h"

#import "KDAppUserDefaultsAdapter.h"
#import "KDWeiboServicesContext.h"

#define KD_APP_VERSION_UPDATES_CACHE_KEY    @"appVersionUpdates"

@implementation KDAppVersionUpdates

@synthesize buildNumber=buildNumber_;
@synthesize version=version_;
@synthesize updateURL=updateURL_;
@synthesize commentURL=commentURL_;
@synthesize updatePolicy=updatePolicy_;
@synthesize changes=changes_;
@synthesize forceUpdateNo = forceUpdateNo_;
@synthesize desc = desc_;

- (id)init {
    self = [super init];
    if (self) {
        buildNumber_ = nil;
        version_ = nil;
        updateURL_ = nil;
        commentURL_ = nil;
        updatePolicy_ = KDWeiboUpdatePolicyRecommend;
        changes_ = nil;
        forceUpdateNo_= nil;
        desc_ = nil;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.buildNumber = [aDecoder decodeObjectForKey:@"buildNumber"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.updateURL = [aDecoder decodeObjectForKey:@"updateURL"];
        self.commentURL = [aDecoder decodeObjectForKey:@"commentURL"];
        self.updatePolicy = [aDecoder decodeIntForKey:@"updatePolicy"];
        self.changes = [aDecoder decodeObjectForKey:@"changes"];
        self.forceUpdateNo = [aDecoder decodeObjectForKey:@"forceUpdateNo"];
        self.desc = [aDecoder decodeObjectForKey:@"desc"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (buildNumber_ != nil) {
        [aCoder encodeObject:buildNumber_ forKey:@"buildNumber"];
    }
    
    if (version_ != nil) {
        [aCoder encodeObject:version_ forKey:@"version"];
    }
    
    if (updateURL_ != nil) {
        [aCoder encodeObject:updateURL_ forKey:@"updateURL"];
    }
    
    if (commentURL_ != nil) {
        [aCoder encodeObject:commentURL_ forKey:@"commentURL"];
    }
    
    [aCoder encodeInt:updatePolicy_ forKey:@"updatePolicy"];
    
    if(desc_ != nil){
        [aCoder encodeObject:desc_ forKey:@"desc"];
    }
    
    if (changes_ != nil) {
        [aCoder encodeObject:changes_ forKey:@"changes"];
    }
    if (forceUpdateNo_ != nil) {
        [aCoder encodeObject:forceUpdateNo_ forKey:@"forceUpdateNo"];
    }
}

+ (void)store:(KDAppVersionUpdates *)versionUpdates {
    if (versionUpdates != nil) {
        KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:versionUpdates];
        if (data != nil) {
            [userDefaultAdapter storeObject:data forKey:KD_APP_VERSION_UPDATES_CACHE_KEY];
        }
    }
}

+ (KDAppVersionUpdates *)retrieveLatestVersionUpdates {
    KDAppVersionUpdates *versionUpdates = nil;
    
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSData *data = [userDefaultAdapter objectForKey:KD_APP_VERSION_UPDATES_CACHE_KEY];
    if (data != nil) {
        versionUpdates = (KDAppVersionUpdates *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return versionUpdates;
}

- (NSString *)description {
    NSMutableString *body = [NSMutableString string];
    
    [body appendString:@"{"];
    [body appendFormat:@"\"buildNumber\" : \"%@\", ", (buildNumber_ != nil) ? buildNumber_ : [NSNull null]];
    [body appendFormat:@"\"version\" : \"%@\", ", (version_ != nil) ? version_ : [NSNull null]];
    [body appendFormat:@"\"updateURL\" : \"%@\", ", (updateURL_ != nil) ? updateURL_ : [NSNull null]];
    [body appendFormat:@"\"commentURL\": \"%@\", ", (commentURL_) ? commentURL_ : [NSNull null]];
    [body appendFormat:@"\"desc\": \"%@\", ", (desc_) ? desc_ : [NSNull null]];
    [body appendFormat:@"\"updatePolicy\": \"%d\", ", updatePolicy_];
    [body appendFormat:@"\"forceUpdateNo\": \"%@\", ",(forceUpdateNo_) ? forceUpdateNo_ : [NSNull null]];
    [body appendFormat:@"\"changes\" : \"%@\"", (changes_ != nil) ? [changes_ description] : [NSNull null]];
    [body appendString:@"}"];
    
    return body;
} 

- (void)dealloc {
    //KD_RELEASE_SAFELY(buildNumber_);
    //KD_RELEASE_SAFELY(version_);
    //KD_RELEASE_SAFELY(updateURL_);
    //KD_RELEASE_SAFELY(commentURL_);
    //KD_RELEASE_SAFELY(changes_);
    //KD_RELEASE_SAFELY(forceUpdateNo_);
    //KD_RELEASE_SAFELY(desc_);
    //[super dealloc];
}

@end
