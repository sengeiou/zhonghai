//
//  PersonSimpleDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "PersonSimpleDataModel.h"
#import "BOSSetting.h"
#import "UserDataModel.h"

@interface PersonSimpleDataModel ()
@property (strong, nonatomic) NSNumber *inCompany;
@end

@implementation PersonSimpleDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _personId = [[NSString alloc] init];
        _personName = [[NSString alloc] init];
        _defaultPhone = [[NSString alloc] init];
        _department = [[NSString alloc] init];
        _photoUrl = [[NSString alloc] init];
        _status = 0;
        
        _jobTitle = [[NSString alloc] init];
        
        _userId = 0;
        _fullPinyin = [[NSString alloc] init];
        
        _menu = [[NSString alloc] init];
        
        _fullPinyin = [[NSString alloc] init];
        
        _wbUserId = [[NSString alloc] init];
        _share = 0;
        _isAdmin = NO;
        _parttimejob = [[NSMutableArray alloc]init];
        _remind = NO;
        _oid = [[NSString alloc]init];
        _orgId = [[NSString alloc] init];
        _gender = 1;
        _personScore = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        
        id personId = [dict objectForKey:@"id"];
        if (![personId isKindOfClass:[NSNull class]] && personId) {
            self.personId = personId;
        }
        
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name) {
            self.personName = name;
        }
        
        id account = [dict objectForKey:@"account"];
        if (![account isKindOfClass:[NSNull class]] && account) {
            self.defaultPhone = account;
        }
        
        id defaultPhone = [dict objectForKey:@"defaultPhone"];
        if (![defaultPhone isKindOfClass:[NSNull class]] && defaultPhone) {
            self.defaultPhone = defaultPhone;
        }
        
        id department = [dict objectForKey:@"department"];
        if (![department isKindOfClass:[NSNull class]] && department) {
            self.department = department;
        }
        
        id photoUrl = [dict objectForKey:@"photoUrl"];
        if (![photoUrl isKindOfClass:[NSNull class]] && photoUrl) {
            self.photoUrl = photoUrl;
        }
        
        id status = [dict objectForKey:@"status"];
        if (![status isKindOfClass:[NSNull class]] && status) {
            self.status = [status intValue];
        }
        
        id fullPinyin = [dict objectForKey:@"fullPinyin"];
        if (![fullPinyin isKindOfClass:[NSNull class]] && fullPinyin) {
            self.fullPinyin = fullPinyin;
        }
        
        id jobTitle = [dict objectForKey:@"jobTitle"];
        if (![jobTitle isKindOfClass:[NSNull class]] && jobTitle) {
            self.jobTitle = jobTitle;
        }
        
        id wbUserId = [dict objectForKey:@"wbUserId"];
        if (![wbUserId isKindOfClass:[NSNull class]] && wbUserId) {
            self.wbUserId = wbUserId;
        }
        
        id isAdmin = [dict objectForKey:@"isAdmin"];
        if (![isAdmin isKindOfClass:[NSNull class]] && isAdmin) {
            self.isAdmin= [isAdmin boolValue];
        }
        
        id eid = [dict objectForKey:@"eid"];
        if (![eid isKindOfClass:[NSNull class]] && eid) {
            self.eid = eid;
        }
        
        id oid = [dict objectForKey:@"oid"];
        if (![oid isKindOfClass:[NSNull class]] && oid) {
            self.oid = oid;
        }
        else {
            oid = [dict objectForKey:@"oId"];
            if (![oid isKindOfClass:[NSNull class]] && oid) {
                self.oid = oid;
            }
        }
        
        id orgId = [dict objectForKey:@"orgId"];
        if (![orgId isKindOfClass:[NSNull class]] && orgId) {
            self.orgId = orgId;
        }
        
        id orgUserType = [dict objectForKey:@"orgUserType"];
        if (![orgUserType isKindOfClass:[NSNull class]] && orgUserType) {
            self.orgUserType = [orgUserType intValue];
        }

        id isParttimejob = [dict objectForKey:@"isPartJob"];
        if (![isParttimejob isKindOfClass:[NSNull class]] && isParttimejob) {
            self.isPartJob= [isParttimejob boolValue];
        }
        
        //add by lee
        id partTimejob = [dict objectForKey:@"parttimejob"];
        if (![partTimejob isKindOfClass:[NSNull class]] && partTimejob && [partTimejob isKindOfClass:[NSArray class]]) {
            for (id contactDic in partTimejob ) {
                ParttimejobDataModel *cDM = [[ParttimejobDataModel alloc] initWithDictionary:contactDic];
                if (cDM.department.length > 0 || cDM.jobTitle.length > 0) {
                    [self.parttimejob addObject:cDM];
                }
            }
        }
        
        
        self.state = 2;//初始值为2
        self.reply = @"1";//初始值为1
        if ([self isPublicAccount]) {
            id publicmenu = [dict objectForKey:@"menu"];
            if (![publicmenu isKindOfClass:[NSNull class]] && publicmenu != nil) {
                if ([publicmenu isKindOfClass:[NSArray class]]) {
                    self.menu = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:publicmenu options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                }
                else if ([publicmenu isKindOfClass:[NSString class]]) {
                    self.menu = publicmenu;
                }
            }
            
            id note = [dict objectForKey:@"note"];
            if (![note isKindOfClass:[NSNull class]] && note) {
                self.note = note;
            }
            
            id subscribe = [dict objectForKey:@"subscribe"];
            if (![subscribe isKindOfClass:[NSNull class]] && subscribe) {
                self.subscribe = [subscribe stringValue];
            }
            
            id canUnsubscribe = [dict objectForKey:@"canUnsubscribe"];
            if (![canUnsubscribe isKindOfClass:[NSNull class]] && canUnsubscribe) {
                self.canUnsubscribe = [canUnsubscribe stringValue];
            }
            
            id manager = [dict objectForKey:@"manager"];
            if (![manager isKindOfClass:[NSNull class]] && manager) {
                self.manager = [manager boolValue];
            }
            
            id share = [dict objectForKey:@"share"];
            if (![share isKindOfClass:[NSNull class]] && share) {
                self.share = [share intValue];
            }
            
            id fold = [dict objectForKey:@"fold"];
            if (![fold isKindOfClass:[NSNull class]] && fold) {
                self.fold = [fold boolValue];
            }
            
            id remind = [dict objectForKey:@"remind"];
            if (![remind isKindOfClass:[NSNull class]] && remind) {
                self.remind = [remind boolValue];
            }
            
            id state = [dict objectForKey:@"state"];
            if (![state isKindOfClass:[NSNull class]] && state) {
                self.state = [state intValue];
            }
            
            id reply = [dict objectForKey:@"reply"];
            if (![reply isKindOfClass:[NSNull class]] && reply) {
                self.reply = [reply stringValue];
            }
            
            
            id hisNews = [dict objectForKey:@"hisNews"];
            if (![hisNews isKindOfClass:[NSNull class]] && hisNews) {
                self.hisNews = [hisNews boolValue];
            }
        }
        
        id partnerType = [dict objectForKey:@"partnerType"];
        if (![partnerType isKindOfClass:[NSNull class]] && partnerType) {
            self.partnerType = [partnerType intValue];
        }
        
        id gender = [dict objectForKey:@"gender"];
        if (![gender isKindOfClass:[NSNull class]] && gender) {
            self.gender = [gender intValue];
        }
        id personScore = [dict objectForKey:@"personScore"];
        if (![personScore isKindOfClass:[NSNull class]] && personScore) {
            self.personScore = personScore;
        }
    }
    return self;
}

- (void)setDefaultPhone:(NSString *)aPhone {
    if (_defaultPhone != aPhone) {
        //手机号码，处理掉'-'号、空格、'+'号
        aPhone = [aPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        aPhone = [aPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
        _defaultPhone = [aPhone copy];
    }
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[PersonSimpleDataModel class]]) {
        return NO;
    }
    
    PersonSimpleDataModel *person = (PersonSimpleDataModel *)object;
    
    NSString *personId = person.personId;
    if(person.group && person.group.groupType == GroupTypeDouble)
        personId = ((PersonSimpleDataModel *)(person.group.participant.firstObject)).personId;
    
    NSString *selfPersonId = self.personId;
    if(self.group && self.group.groupType == GroupTypeDouble)
        selfPersonId = ((PersonSimpleDataModel *)(self.group.participant.firstObject)).personId;
    
    return [selfPersonId isEqualToString:personId];
}

- (NSUInteger)hash
{
    return [self.personId hash];
}

#pragma mark - status method

- (BOOL)accountAvailable
{
    return self.status & 1;
}

- (BOOL)xtAvailable
{
    return (self.status >> 1) & 1;
}

- (BOOL)isPublicAccount
{
    return (self.status >> 3) & 1;
}

- (BOOL)hasHeaderPicture
{
    return self.photoUrl.length > 0;
}

- (BOOL)hasFavor
{
    return (self.status >> 2) & 1;
}

- (void)toggleFavor
{
    self.status ^= 0x4;
}

- (BOOL)isInCompany
{
    if([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]){
        return YES;
    }else{
        if (self.inCompany == nil) {
            self.inCompany = [NSNumber numberWithBool:([[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:self.personId] != nil)];
        }
        return [self.inCompany boolValue];
    }
}


//判断是否带有内部人员属性
- (BOOL)isEmployee
{
    if(self.partnerType == 1)
        return NO;
    else
        return YES;
}

//- (GroupDataModel *)packageGroup :(GroupType)type
//{
//    GroupDataModel *group =nil;
//    if(type == GroupTypePublic)
//        group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupWithPublicPersonId:self.personId];
//    else
//        group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:self];
//    if (group == nil)
//    {
//        group = [[GroupDataModel alloc] initWithParticipant:self];
//        group.groupType = type;
//        group.groupName = self.personName;
//        group.menu = self.menu;
//    }
//    return group;
//}//封装成一个groupdata


-(BOOL)allowInnerShare
{
    if(self.share == 0 || self.share == 2)
        return YES;
    
    return NO;
}

-(BOOL)allowOuterShare
{
    if(self.share == 0 || self.share == 3)
        return YES;
    
    return NO;
}

-(NSString *)getGenderDescription:(int)gender
{
    if(gender == 0)
        return ASLocalizedString(@"未设置");
    else if(gender == 1)
        return ASLocalizedString(@"男");
    else
        return ASLocalizedString(@"女");
}
@end



@implementation ParttimejobDataModel

- (id)init {
    self = [super init];
    if (self) {
        _orgId = [[NSString alloc] init];
        _eName = [[NSString alloc] init];
        _department = [[NSString alloc] init];
        _jobTitle = [[NSString alloc] init];
        //        _ctype = ContactOther;
        _totalSection = 2;
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id orgID= [dict objectForKey:@"orgId"];
        id eName = [dict objectForKey:@"eName"];
        id departName = [dict objectForKey:@"department"];
        id jobTitle = [dict objectForKey:@"jobTitle"];
        id jobType = [dict objectForKey:@"jobType"];
        id partnerType = [dict objectForKey:@"partnerType"];
        
        if (![jobType isKindOfClass:[NSNull class]] && jobType) {
            self.jobType = [jobType intValue];
        }
        if (![orgID isKindOfClass:[NSNull class]] && orgID) {
            self.orgId = orgID;
        }
        if (![eName isKindOfClass:[NSNull class]] && eName) {
            self.eName = eName;
            if (self.eName.length > 0) {
                self.totalSection = 3;
            }
        }
        if (![departName isKindOfClass:[NSNull class]] && departName) {
            self.department = departName;
        }
        if (![jobTitle isKindOfClass:[NSNull class]] && jobTitle) {
            self.jobTitle = jobTitle;
        }
        if (![partnerType isKindOfClass:[NSNull class]] && partnerType) {
            self.partnerType = [partnerType intValue];
        }
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.orgId forKey:@"orgId"];
    [aCoder encodeObject:self.eName forKey:@"eName"];
    [aCoder encodeObject:self.department forKey:@"department"];
    [aCoder encodeObject:self.jobTitle forKey:@"jobTitle"];
    [aCoder encodeObject:@(self.jobType) forKey:@"jobType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.orgId = [aDecoder decodeObjectForKey:@"orgId"];
        self.eName = [aDecoder decodeObjectForKey:@"eName"];
        self.department = [aDecoder decodeObjectForKey:@"department"];
        self.jobTitle = [aDecoder decodeObjectForKey:@"jobTitle"];
        self.jobType = [[aDecoder decodeObjectForKey:@"jobType"] intValue];
    }
    return self;
}

@end
@implementation NSString (PersonSimpleDataModel)
- (BOOL)isPublicAccount {
    if (self.length > 0 && [self hasPrefix:@"XT-"]) {
        return YES;
    }
    return NO;
}
- (BOOL)isExternalPerson {
    if (self.length > 0 && [self hasSuffix:@"_ext"]) {
        return YES;
    }
    return NO;
}
- (BOOL)isExternalGroup {
    if (self.length > 0 && [self hasSuffix:@"_ext"]) {
        return YES;
    }
    return NO;
}
@end
