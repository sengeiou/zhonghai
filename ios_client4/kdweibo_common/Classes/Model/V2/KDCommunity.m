//
//  KDCommunity.m
//  kdweibo_common
//
//  Created by laijiandong on 12-8-21.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDCommunity.h"
#import "KDCache.h"

#define KD_COMMUNITY_IDENTIFIER_COMPANY     @"COMPANY"
#define KD_COMMUNITY_IDENTIFIER_COMMUNITY   @"COMMUNITY"
#define KD_COMMUNITY_IDENTIFIER_TEAM        @"TEAM"


@implementation KDCommunity

@synthesize communityId=communityId_;
@synthesize name=name_;
@synthesize subDomainName=subDomainName_;
@synthesize url=url_;
@synthesize logoURL=logoURL_;
@synthesize parentId = parentId_;
@synthesize inviter = inviter_;
@synthesize isApply = isApply_;
@synthesize isAllowInto = isAllowInto_;
@synthesize communityType=communityType_;

@synthesize unreadNum=unreadNum_;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if(self){
        self.communityId = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.subDomainName = [aDecoder decodeObjectForKey:@"sub_domain_name"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.logoURL = [aDecoder decodeObjectForKey:@"logo_url"];
        self.communityType = [aDecoder decodeInt32ForKey:@"subType"];
        self.parentId = [aDecoder decodeObjectForKey:@"parent_id"];
        self.inviter = [aDecoder decodeObjectForKey:@"inviter"];
        self.isAdmin = [aDecoder decodeBoolForKey:@"is_admin"];
        self.isAllowInto = [aDecoder decodeBoolForKey:@"is_allow_into"];
        self.isApply = [aDecoder decodeBoolForKey:@"is_apply"];
        self.code = [aDecoder decodeObjectForKey:@"code"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if(communityId_ != nil){
        [aCoder encodeObject:communityId_ forKey:@"id"];
    }
    
    if(name_ != nil){
        [aCoder encodeObject:name_ forKey:@"name"];
    }
    
    if(subDomainName_ != nil){
        [aCoder encodeObject:subDomainName_ forKey:@"sub_domain_name"];
    }
    
    if(url_ != nil){
        [aCoder encodeObject:url_ forKey:@"url"];
    }
    
    if(logoURL_ != nil){
        [aCoder encodeObject:logoURL_ forKey:@"logo_url"];
    }
    
    if(parentId_) {
        [aCoder encodeObject:parentId_ forKey:@"parent_id"];
    }
    
    if(inviter_) {
        [aCoder encodeObject:inviter_ forKey:@"inviter"];
    }
    
    if(code_) {
        [aCoder encodeObject:code_ forKey:@"code"];
    }
    
    [aCoder encodeBool:isAdmin_ forKey:@"is_admin"];
    
    [aCoder encodeBool:isApply_ forKey:@"is_apply"];
    
    [aCoder encodeBool:isAllowInto_ forKey:@"is_allow_into"];
    
    [aCoder encodeInteger:communityType_ forKey:@"subType"];
}

+ (KDCommunityType)convertCommunityTypeFromString:(NSString *)string {
    KDCommunityType communityType = KDCommunityTypeUndefined;
    if(string == nil || [string length] < 1){
        return communityType;
    }
    
    NSString *type = [string uppercaseString];
    if([KD_COMMUNITY_IDENTIFIER_COMPANY isEqualToString:type]){
        communityType = KDCommunityTypeCompany;
        
    }else if([KD_COMMUNITY_IDENTIFIER_COMMUNITY isEqualToString:type]){
        communityType = KDCommunityTypeCommunity;
    }else if([KD_COMMUNITY_IDENTIFIER_TEAM isEqualToString:type]) {
        communityType = KDCommunityTypeTeam;
    }
    
    return communityType;
}
- (BOOL)isCompany {
    return (communityType_ == KDCommunityTypeCompany);
}

- (BOOL)isTeam {
    return (communityType_ == KDCommunityTypeTeam);
}

#pragma mark - KDAvatarDataSource
- (KDAvatarType)getAvatarType {
    return KDAvatarTypeUser;
}

- (KDImageSize *)avatarScaleToSize {
    return [KDImageSize defaultUserAvatarSize];
}

- (NSString *)getAvatarLoadURL {
    return logoURL_;
}

- (NSString *)getAvatarCacheKey {
    NSString *cacheKey = [super propertyForKey:kKDAvatarPropertyCacheKey];
    if(cacheKey == nil){
        NSString *loadURL = [self getAvatarLoadURL];
        cacheKey = [KDCache cacheKeyForURL:loadURL];
        if(cacheKey != nil){
            [super setProperty:cacheKey forKey:kKDAvatarPropertyCacheKey];
        }
    }
    
    return cacheKey;
}

- (void)removeAvatarCacheKey {
    [super setProperty:nil forKey:kKDAvatarPropertyCacheKey];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(communityId_);
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(subDomainName_);
    //KD_RELEASE_SAFELY(url_);
    //KD_RELEASE_SAFELY(logoURL_);
    
    //[super dealloc];
}

@end
