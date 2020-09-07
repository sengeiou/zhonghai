//
//  KDMainUserDataModel.m
//  kdweibo_common
//
//  Created by kingdee on 16/7/27.
//  Copyright © 2016年 kingdee. All rights reserved.
//

#import "KDMainUserDataModel.h"

@implementation KDMainUserDataModel
- (id)init {
    self = [super init];
    if (self) {
        _bizId = [[NSString alloc] init];
        _department = [[NSString alloc] init];
        _eid = [[NSString alloc] init];
        _emails = [[NSString alloc] init];
        _email = [[NSString alloc] init];
        _gender = 0;
        _userId = [[NSString alloc] init];
        _jobTitle = [[NSString alloc] init];
        _lastUpdateTime = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _openId = [[NSString alloc] init];
        _oId = [[NSString alloc] init];
        _orgId = [[NSString alloc] init];
        _petName = [[NSString alloc] init];
        _phones = [[NSString alloc] init];
        _phone = [[NSString alloc] init];
        _photoUrl = [[NSString alloc] init];
        _token = [[NSString alloc] init];
        _bindedEmail = [[NSString alloc] init];
        _bindedPhone = [[NSString alloc] init];
        _status = 0;
        _isAdmin = 0;
        
        _wbUserId = [[NSString alloc] init];
        _wbNetworkId = [[NSString alloc] init];
        _oauthToken = [[NSString alloc] init];
        _oauthTokenSecret = [[NSString alloc] init];
        //        _cloudpassport = [[NSString alloc] init];
        _enableLanguage = 0;
        
        _teamAccount = [[NSArray alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id bizId = [dict objectForKey:@"bizId"];
        if (![bizId isKindOfClass:[NSNull class]] && bizId) {
            self.bizId = bizId;
        }
        id department = [dict objectForKey:@"department"];
        if (![department isKindOfClass:[NSNull class]] && department) {
            self.department = department;
        }
        id eid = [dict objectForKey:@"eid"];
        if (![eid isKindOfClass:[NSNull class]] && eid) {
            self.eid = eid;
        }
        id emails = [dict objectForKey:@"emails"];
        if (![emails isKindOfClass:[NSNull class]] && emails) {
            self.emails = emails;
        }
        
        id email = [dict objectForKey:@"email"];
        if (![email isKindOfClass:[NSNull class]] && email) {
            self.email = email;
        }
        
        id gender = [dict objectForKey:@"gender"];
        if (![gender isKindOfClass:[NSNull class]] && gender) {
            self.gender = [gender intValue];
        }
        id userId = [dict objectForKey:@"id"];
        if (![userId isKindOfClass:[NSNull class]] && userId) {
            self.userId = userId;
        }
        id jobTitle = [dict objectForKey:@"jobTitle"];
        if (![jobTitle isKindOfClass:[NSNull class]] && jobTitle) {
            self.jobTitle = jobTitle;
        }
        id lastUpdateTime = [dict objectForKey:@"lastUpdateTime"];
        if (![lastUpdateTime isKindOfClass:[NSNull class]] && lastUpdateTime) {
            self.lastUpdateTime = lastUpdateTime;
        }
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.name = name;
        }
        id openId = [dict objectForKey:@"openId"];
        if (![openId isKindOfClass:[NSNull class]] && openId) {
            self.openId = openId;
        }
        id oId = [dict objectForKey:@"oId"];
        if (![oId isKindOfClass:[NSNull class]] && oId) {
            self.oId = oId;
        }
        id orgId = [dict objectForKey:@"orgId"];
        if (![orgId isKindOfClass:[NSNull class]] && orgId) {
            self.orgId = orgId;
        }
        id petName = [dict objectForKey:@"petName"];
        if (![petName isKindOfClass:[NSNull class]] && petName) {
            self.petName = petName;
        }
        id phones = [dict objectForKey:@"phones"];
        if (![phones isKindOfClass:[NSNull class]] && phones) {
            self.phones = phones;
        }
        id phone = [dict objectForKey:@"phone"];
        if (![phone isKindOfClass:[NSNull class]] && phone) {
            self.phone = phone;
        }
        id companyName = [dict objectForKey:@"companyName"];
        if (![companyName isKindOfClass:[NSNull class]] && companyName) {
            self.companyName = companyName;
        }
        id photoUrl = [dict objectForKey:@"photoUrl"];
        if (![photoUrl isKindOfClass:[NSNull class]] && photoUrl) {
            self.photoUrl = photoUrl;
        }
        id bindedPhone = [dict objectForKey:@"bindedPhone"];
        if (![bindedPhone isKindOfClass:[NSNull class]] && bindedPhone) {
            self.bindedPhone = bindedPhone;
        }
        id bindedEmail = [dict objectForKey:@"bindedEmail"];
        if (![bindedEmail isKindOfClass:[NSNull class]] && bindedEmail) {
            self.bindedEmail = bindedEmail;
        }
        
        id token = [dict objectForKey:@"token"];
        if (![token isKindOfClass:[NSNull class]] && token) {
            self.token = token;
        }
        id status = [dict objectForKey:@"status"];
        if (![status isKindOfClass:[NSNull class]] && status) {
            self.status = [status intValue];
        }
        
        id wbUserId = [dict objectForKey:@"wbUserId"];
        if (![wbUserId isKindOfClass:[NSNull class]] && wbUserId) {
            self.wbUserId = wbUserId;
        }
        id wbNetworkId = [dict objectForKey:@"wbNetworkId"];
        if (![wbNetworkId isKindOfClass:[NSNull class]] && wbNetworkId) {
            self.wbNetworkId = wbNetworkId;
        }
        id oauthToken = [dict objectForKey:@"oauth_token"];
        if (![oauthToken isKindOfClass:[NSNull class]] && oauthToken) {
            self.oauthToken = oauthToken;
        }
        id oauthTokenSecret = [dict objectForKey:@"oauth_token_secret"];
        if (![oauthTokenSecret isKindOfClass:[NSNull class]] && oauthTokenSecret) {
            self.oauthTokenSecret = oauthTokenSecret;
        }
        id isAdmin = [dict objectForKey:@"isAdmin"];
        if (![status isKindOfClass:[NSNull class]] && status) {
            self.isAdmin = [isAdmin intValue];;
        }
        id enableLanguage = [dict objectForKey:@"enabledLanguage"];
        if (![enableLanguage isKindOfClass:[NSNull class]] && enableLanguage) {
            self.enableLanguage = [enableLanguage intValue];
        }
        
        id partnerType = [dict objectForKey:@"partnerType"];
        if (![partnerType isKindOfClass:[NSNull class]] && partnerType) {
            self.partnerType = [partnerType intValue];
        }
        //        id cloudpassport = [dict objectForKey:@"cloudpassport"];
        //        if (![cloudpassport isKindOfClass:[NSNull class]] && cloudpassport) {
        //            self.cloudpassport = cloudpassport;
        //        }
        id teamAccount = [dict objectForKey:@"teamAccount"];
        if (![teamAccount isKindOfClass:[NSNull class]] && teamAccount) {
            self.teamAccount = teamAccount;
        }
    }
    return self;
}

- (BOOL)isDefaultAvatar
{
    return self.photoUrl.length == 0 || [self.photoUrl rangeOfString:@"id=null"].location != NSNotFound;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(_phone);
    //KD_RELEASE_SAFELY(_bizId);
    //KD_RELEASE_SAFELY(_department);
    //KD_RELEASE_SAFELY(_eid);
    //KD_RELEASE_SAFELY(_emails);
    //KD_RELEASE_SAFELY(_email);
    //KD_RELEASE_SAFELY(_userId);
    //KD_RELEASE_SAFELY(_jobTitle);
    //KD_RELEASE_SAFELY(_lastUpdateTime);
    //KD_RELEASE_SAFELY(_name);
    //KD_RELEASE_SAFELY(_openId);
    //KD_RELEASE_SAFELY(_petName);
    //KD_RELEASE_SAFELY(_phones);
    //KD_RELEASE_SAFELY(_photoUrl);
    //KD_RELEASE_SAFELY(_token);
    //KD_RELEASE_SAFELY(_oId);
    
    //KD_RELEASE_SAFELY(_wbUserId);
    //KD_RELEASE_SAFELY(_wbNetworkId);
    //KD_RELEASE_SAFELY(_oauthToken);
    //KD_RELEASE_SAFELY(_oauthTokenSecret);
    //    //KD_RELEASE_SAFELY(_cloudpassport);
    //KD_RELEASE_SAFELY(_teamAccount);
    //[super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bizId forKey:@"bizId"];
    [aCoder encodeObject:self.companyName forKey:@"companyName"];
    [aCoder encodeObject:self.department forKey:@"department"];
    [aCoder encodeObject:self.eid forKey:@"eid"];
    [aCoder encodeObject:self.emails forKey:@"emails"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:@(self.gender) forKey:@"gender"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.jobTitle forKey:@"jobTitle"];
    [aCoder encodeObject:self.lastUpdateTime forKey:@"lastUpdateTime"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.openId forKey:@"openId"];
    [aCoder encodeObject:self.oId forKey:@"oId"];
    [aCoder encodeObject:self.orgId forKey:@"orgId"];
    [aCoder encodeObject:self.petName forKey:@"petName"];
    [aCoder encodeObject:self.phones forKey:@"phones"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.wbUserId forKey:@"wbUserId"];
    [aCoder encodeObject:self.wbNetworkId forKey:@"wbNetworkId"];
    [aCoder encodeObject:self.oauthToken forKey:@"oauthToken"];
    [aCoder encodeObject:self.oauthTokenSecret forKey:@"oauthTokenSecret"];
    [aCoder encodeObject:@(self.isAdmin) forKey:@"isAdmin"];
    [aCoder encodeObject:@(self.enableLanguage) forKey:@"enableLanguage"];
    [aCoder encodeObject:@(self.partnerType) forKey:@"partnerType"];
    //    [aCoder encodeObject:self.cloudpassport forKey:@"cloudpassport"];
    [aCoder encodeObject:self.teamAccount forKey:@"teamAccount"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.bizId = [aDecoder decodeObjectForKey:@"bizId"];
        self.department = [aDecoder decodeObjectForKey:@"department"];
        self.companyName = [aDecoder decodeObjectForKey:@"companyName"];
        self.eid = [aDecoder decodeObjectForKey:@"eid"];
        self.emails = [aDecoder decodeObjectForKey:@"emails"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.gender = [[aDecoder decodeObjectForKey:@"gender"] intValue];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.jobTitle = [aDecoder decodeObjectForKey:@"jobTitle"];
        self.lastUpdateTime = [aDecoder decodeObjectForKey:@"lastUpdateTime"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.openId = [aDecoder decodeObjectForKey:@"openId"];
        self.oId = [aDecoder decodeObjectForKey:@"oId"];
        self.orgId = [aDecoder decodeObjectForKey:@"orgId"];
        self.petName = [aDecoder decodeObjectForKey:@"petName"];
        self.phones = [aDecoder decodeObjectForKey:@"phones"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.photoUrl = [aDecoder decodeObjectForKey:@"photoUrl"];
        self.status = [[aDecoder decodeObjectForKey:@"status"] intValue];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.wbUserId = [aDecoder decodeObjectForKey:@"wbUserId"];
        self.wbNetworkId = [aDecoder decodeObjectForKey:@"wbNetworkId"];
        self.oauthToken = [aDecoder decodeObjectForKey:@"oauthToken"];
        self.oauthTokenSecret = [aDecoder decodeObjectForKey:@"oauthTokenSecret"];
        self.isAdmin = [[aDecoder decodeObjectForKey:@"isAdmin"] intValue];
        self.enableLanguage =  [[aDecoder decodeObjectForKey:@"enableLanguage"]intValue];
        self.partnerType =  [[aDecoder decodeObjectForKey:@"partnerType"]intValue];
        //        self.cloudpassport = [aDecoder decodeObjectForKey:@"cloudpassport"];
        self.teamAccount = [aDecoder decodeObjectForKey:@"teamAccount"];
    }
    return self;
}
- (NSString *)externalPersonId {
    if (self.wbUserId.length == 0) {
        return nil;
    }
    if ([self.wbUserId hasSuffix:@"_ext"]) {
        return self.wbUserId;
    }
    return [NSString stringWithFormat:@"%@_ext",self.wbUserId];
}
@end
