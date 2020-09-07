//
//  PersonDataModel.m
//  ContactsLite
//
//  Created by kingdee eas on 12-11-13.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "PersonDataModel.h"
#import "KDContactInfo.h"

@interface PersonDataModel ()
@property (nonatomic, assign) BOOL smsChecked;
@property (nonatomic, assign) BOOL canSms;
@end

@implementation PersonDataModel

- (id)init {
    self = [super init];
    if (self) {
        _smsChecked = NO;
        _canSms = NO;
        _contact = [[NSMutableArray alloc] init];
        
        _attributesArray = [NSMutableArray array];
//        _parttimejob = [[NSMutableArray alloc]init];
//        _orgId = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithPersonSimple:(PersonSimpleDataModel *)personSimple {
    self = [self init];
    if (self) {
        if (personSimple) {
            self.personId = personSimple.personId;
            self.personName = personSimple.personName;
            self.defaultPhone = personSimple.defaultPhone;
            self.department = personSimple.department;
            self.photoUrl = personSimple.photoUrl;
            self.status = personSimple.status;
            self.fullPinyin = personSimple.fullPinyin;
            self.jobTitle = personSimple.jobTitle;
            self.menu = personSimple.menu;
            self.note = personSimple.note;
            self.reply = personSimple.reply;
            self.subscribe = personSimple.subscribe;
            self.canUnsubscribe = personSimple.canUnsubscribe;
        }
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
        self = [super initWithDictionary:dict];
        
        id contact = [dict objectForKey:@"contact"];
        if (![contact isKindOfClass:[NSNull class]] && contact && [contact isKindOfClass:[NSArray class]]) {
            for (id contactDic in contact ) {
                ContactDataModel *cDM = [[ContactDataModel alloc] initWithDictionary:contactDic];
                if (![@"" isEqualToString:cDM.cvalue]) {
                    [self.contact addObject:cDM];
                }
            }
        }
//       //add by lee
//        id partTimejob = [dict objectForKey:@"parttimejob"];
//        if (![partTimejob isKindOfClass:[NSNull class]] && partTimejob && [partTimejob isKindOfClass:[NSArray class]]) {
//            for (id contactDic in partTimejob ) {
//                ParttimejobDataModel *cDM = [[ParttimejobDataModel alloc] initWithDictionary:contactDic];
//                if (![@"" isEqualToString:cDM.department]) {
//                    [self.parttimejob addObject:cDM];
//                }
//            }
//        }

//        id orgId = [dict objectForKey:@"orgId"];
//        if (![orgId isKindOfClass:[NSNull class]] && orgId) {
//            self.orgId = orgId;
//        }
        
        id isVisible = [dict objectForKey:@"isVisible"];
        if (![isVisible isKindOfClass:[NSNull class]] && isVisible) {
            self.isVisible = ([isVisible integerValue] == 1);
        }
        
        self.orgLeaders = [NSMutableArray array];
        id orgLeaders = [dict objectForKey:@"orgLeaders"];
        if (![orgLeaders isKindOfClass:[NSNull class]] && orgLeaders && [orgLeaders isKindOfClass:[NSArray class]]) {
            for (id data in orgLeaders) {
                PersonSimpleDataModel *leader = [[PersonSimpleDataModel alloc] init];
                leader.gender = [[data objectForKey:@"gender"] intValue];
                leader.personId = [data objectForKey:@"id"];
                leader.personName = [data objectForKey:@"name"];
                NSString *photoUrl = [data objectForKey:@"photoUrl"];
                if(photoUrl == [NSNull null])
                    photoUrl = @"";
                leader.photoUrl = photoUrl;
                leader.status = 7;
                [self.orgLeaders addObject:leader];
            }
        }

    }
    return self;
}

- (id)initWithOpenDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        self = [super initWithDictionary:dict];
        
        id contactArray = [dict objectForKey:@"contact"];
        if (![contactArray isKindOfClass:[NSNull class]] && contactArray && [contactArray isKindOfClass:[NSArray class]]) {
            self.contactArray = contactArray;
        }
        
        
        id attributesArray = [dict objectForKey:@"attributes"];
        if (![attributesArray isKindOfClass:[NSNull class]] && attributesArray && [attributesArray isKindOfClass:[NSArray class]]) {
            self.attributesArray = attributesArray;
        }
        
        id mutableArray = [dict objectForKey:@"mutable"];
        if (![mutableArray isKindOfClass:[NSNull class]] && mutableArray && [mutableArray isKindOfClass:[NSArray class]]) {
            self.mutableArray = mutableArray;
        }
        
        
        //       //add by lee
        //        id partTimejob = [dict objectForKey:@"parttimejob"];
        //        if (![partTimejob isKindOfClass:[NSNull class]] && partTimejob && [partTimejob isKindOfClass:[NSArray class]]) {
        //            for (id contactDic in partTimejob ) {
        //                ParttimejobDataModel *cDM = [[ParttimejobDataModel alloc] initWithDictionary:contactDic];
        //                if (![@"" isEqualToString:cDM.department]) {
        //                    [self.parttimejob addObject:cDM];
        //                }
        //            }
        //        }
        id eName = [dict objectForKey:@"eName"];
        if (![eName isKindOfClass:[NSNull class]] && eName) {
            self.eName = eName;
        }
        
//        id orgId = [dict objectForKey:@"orgId"];
//        if (![orgId isKindOfClass:[NSNull class]] && orgId) {
//            self.orgId = orgId;
//        }
        
        
        id phone1 = [dict objectForKey:@"officePhone1"];
        if (![phone1 isKindOfClass:[NSNull class]] && phone1) {
            self.phone1 = phone1;
        }
        
        id phone2 = [dict objectForKey:@"officePhone2"];
        if (![phone2 isKindOfClass:[NSNull class]] && phone2) {
            self.phone2 = phone2;
        }
        
        id systemEmail = [dict objectForKey:@"emails"];
        if (![systemEmail isKindOfClass:[NSNull class]] && systemEmail) {
            self.systemEmail = systemEmail;
        }
        
        id birthday = [dict objectForKey:@"birthday"];
        if (![birthday isKindOfClass:[NSNull class]] && birthday) {
            self.birthday = birthday;
        }
    }
    return self;
}

- (void)setContactArray:(NSArray *)contactArray {
    if (contactArray == nil) {
        return;
    }
    _contactArray = contactArray;
    for (id dic in _contactArray) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            KDContactInfo *contactInfo = [[KDContactInfo alloc]initWithDictionary:dic];
            if (contactInfo.value.length == 0) {
                continue;
            }
            
            if ([contactInfo.type isEqualToString:@"E"]) {
                if (_emailArray == nil) {
                    _emailArray = [[NSMutableArray alloc]init];
                }
                if (contactInfo.publicid.length) {
                    [_emailArray insertObject:contactInfo atIndex:0];
                }
                else {
                    [_emailArray addObject:contactInfo];
                }
            }
            else if ([contactInfo.type isEqualToString:@"P"]) {
                if (_phoneArray == nil) {
                    _phoneArray = [[NSMutableArray alloc]init];
                }
                if (contactInfo.publicid.length) {
                    [_phoneArray insertObject:contactInfo atIndex:0];
                }
                else {
                    [_phoneArray addObject:contactInfo];
                }
            }
            else if ([contactInfo.type isEqualToString:@"O"]) {
                if (_otherArray == nil) {
                    _otherArray = [[NSMutableArray alloc]init];
                }
                if (contactInfo.publicid.length) {
                    [_otherArray insertObject:contactInfo atIndex:0];
                }
                else {
                    [_otherArray addObject:contactInfo];
                }
            }
        }
    }
}

- (void)setAttributesArray:(NSArray *)attributesArray {
    if (attributesArray.count == 0) {
        return;
    }
//    _attributesArray = attributesArray;
    
    for (NSDictionary *dic in attributesArray) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            KDContactAttributeInfo *contact = [[KDContactAttributeInfo alloc] initWithDictionary:dic];
            [_attributesArray addObject:contact];
        }
    }
    
}


- (BOOL)canSms
{
    if (self.smsChecked) {
        return _canSms;
    }
    
    for (ContactDataModel *contactDM in self.contact) {
        if (contactDM.ctype == ContactCellPhone) {
            _canSms = YES;
        }
    }
    self.smsChecked = YES;
    
    return _canSms;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.personId forKey:@"personId"];
    [aCoder encodeObject:self.personName forKey:@"personName"];
    [aCoder encodeObject:self.defaultPhone forKey:@"defaultPhone"];
    [aCoder encodeObject:self.department forKey:@"department"];
    [aCoder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    [aCoder encodeObject:@(self.userId) forKey:@"userId"];
    [aCoder encodeObject:self.fullPinyin forKey:@"fullPinyin"];
    [aCoder encodeObject:self.menu forKey:@"menu"];
    [aCoder encodeObject:self.note forKey:@"note"];
    [aCoder encodeObject:self.reply forKey:@"reply"];
    [aCoder encodeObject:self.subscribe forKey:@"subscribe"];
    [aCoder encodeObject:self.canUnsubscribe forKey:@"canUnsubscribe"];
    [aCoder encodeObject:self.jobTitle forKey:@"jobTitle"];
//    [aCoder encodeObject:self.orgId forKey:@"orgId"];
    [aCoder encodeObject:self.contact forKey:@"contact"];
//    [aCoder encodeObject:self.parttimejob forKey:@"parttimejob"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.personId = [aDecoder decodeObjectForKey:@"personId"];
        self.personName = [aDecoder decodeObjectForKey:@"personName"];
        self.defaultPhone = [aDecoder decodeObjectForKey:@"defaultPhone"];
        self.department = [aDecoder decodeObjectForKey:@"department"];
        self.photoUrl = [aDecoder decodeObjectForKey:@"photoUrl"];
        self.status = [[aDecoder decodeObjectForKey:@"status"] intValue];
        self.userId = [[aDecoder decodeObjectForKey:@"userId"] intValue];
        self.fullPinyin = [aDecoder decodeObjectForKey:@"fullPinyin"];
        self.menu = [aDecoder decodeObjectForKey:@"menu"];
        self.note = [aDecoder decodeObjectForKey:@"note"];
        self.reply = [aDecoder decodeObjectForKey:@"reply"];
        self.subscribe = [aDecoder decodeObjectForKey:@"subscribe"];
        self.canUnsubscribe = [aDecoder decodeObjectForKey:@"canUnsubscribe"];
        self.jobTitle = [aDecoder decodeObjectForKey:@"jobTitle"];
//        self.orgId = [aDecoder decodeObjectForKey:@"orgId"];
        self.contact = [aDecoder decodeObjectForKey:@"contact"];
//        self.parttimejob = [aDecoder decodeObjectForKey:@"parttimejob"];
    }
    return self;
}

@end

@implementation ContactDataModel

- (id)init {
    self = [super init];
    if (self) {
        _ctext = [[NSString alloc] init];
        _cvalue = [[NSString alloc] init];
        _ctype = ContactOther;
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
        id type = [dict objectForKey:@"type"];
        id text = [dict objectForKey:@"text"];
        id value = [dict objectForKey:@"value"];
        
        if (![type isKindOfClass:[NSNull class]] && type) {
            self.ctype = [type intValue];
        }
        if (![text isKindOfClass:[NSNull class]] && text) {
            self.ctext = text;
        }
        if (![value isKindOfClass:[NSNull class]] && value) {
            self.cvalue = value;
        }
    }
    return self;
}

- (NSString *)formatedTextName
{
    NSString *formatedTextName = nil;
    if (self.ctext != nil && self.ctext.length > 0) {
        return self.ctext;
    }
      switch (self.ctype) {
        case ContactCellPhone:
            formatedTextName = ASLocalizedString(@"PersonDataModel_Phone");
            break;
//        case ContactHomePhone:
//            formatedTextName = ASLocalizedString(@"固定电话");
//            break;
        case ContactEmail:
            formatedTextName = ASLocalizedString(@"KDAuthViewController_email");
            break;
        default:
            formatedTextName = self.ctext;
            break;
    }
    
    return formatedTextName;
}


-(void)setCvalue:(NSString *)value
{
    if (_cvalue != value){
        if (_ctype == ContactCellPhone) {
            //如果是手机号码，处理掉'-'号、空格、'+'号
            value = [value stringByReplacingOccurrencesOfString:@"-" withString:@""];
            value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@""];
        }
        _cvalue = [value copy];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ctext forKey:@"ctext"];
    [aCoder encodeObject:self.cvalue forKey:@"cvalue"];
    [aCoder encodeObject:@(self.ctype) forKey:@"ctype"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.ctext = [aDecoder decodeObjectForKey:@"ctext"];
        self.cvalue = [aDecoder decodeObjectForKey:@"cvalue"];
        self.ctype = [[aDecoder decodeObjectForKey:@"ctype"] intValue];
    }
    return self;
}

@end



//@implementation ParttimejobDataModel
//
//- (id)init {
//    self = [super init];
//    if (self) {
//        _orgId = [[NSString alloc] init];
//        _eName = [[NSString alloc] init];
//        _department = [[NSString alloc] init];
//        _jobTitle = [[NSString alloc] init];
////        _ctype = ContactOther;
//    }
//    return self;
//}
//
//
//-(id)initWithDictionary:(NSDictionary *)dict
//{
//    self = [self init];
//    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
//        return self;
//    }
//    if (![dict isKindOfClass:[NSDictionary class]]) {
//        return self;
//    }
//    if (self) {
//        id orgID= [dict objectForKey:@"orgId"];
//        id eName = [dict objectForKey:@"eName"];
//        id departName = [dict objectForKey:@"department"];
//        id jobTitle = [dict objectForKey:@"jobTitle"];
//        id jobType = [dict objectForKey:@"jobType"];
//        
//        if (![jobType isKindOfClass:[NSNull class]] && jobType) {
//            self.JobType = [jobType intValue];
//        }
//        if (![orgID isKindOfClass:[NSNull class]] && orgID) {
//            self.orgId = orgID;
//        }
//        if (![eName isKindOfClass:[NSNull class]] && eName) {
//            self.eName = eName;
//        }
//        if (![departName isKindOfClass:[NSNull class]] && departName) {
//            self.department = departName;
//        }
//        if (![jobTitle isKindOfClass:[NSNull class]] && jobTitle) {
//            self.jobTitle = jobTitle;
//        }
//    }
//    return self;
//}
//
//#pragma mark - NSCoding
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.orgId forKey:@"orgId"];
//    [aCoder encodeObject:self.eName forKey:@"eName"];
//    [aCoder encodeObject:self.department forKey:@"department"];
//    [aCoder encodeObject:self.jobTitle forKey:@"jobTitle"];
//    [aCoder encodeObject:@(self.jobType) forKey:@"jobType"];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self)
//    {
//        self.orgId = [aDecoder decodeObjectForKey:@"orgId"];
//        self.eName = [aDecoder decodeObjectForKey:@"eName"];
//        self.department = [aDecoder decodeObjectForKey:@"department"];
//        self.jobTitle = [aDecoder decodeObjectForKey:@"jobTitle"];
//        self.jobType = [[aDecoder decodeObjectForKey:@"jobType"] intValue];
//    }
//    return self;
//}
//
//@end