//
//  KDABPerson.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDABPerson.h"
#import "KDUser.h"
#import "KDCache.h"
#import "KDImageSize.h"
#import "NSString+Additions.h"
@implementation KDABPerson {
 @private
    ABRecordRef record_;
}

@synthesize pId=pId_;
@synthesize userId=userId_;
@synthesize name=name_;
@synthesize jobTitle=jobTitle_;
@synthesize department=department_;

@synthesize networkId=networkId_;

@synthesize emails=emails_;
@synthesize phones=phones_;
@synthesize mobiles=mobiles_;
@synthesize md5String = md5String_;
@synthesize profileImageURL=profileImageURL_;

@synthesize favorited=favorited_;
@synthesize type=type_;

@dynamic mobileNumbers;

- (id)initWithType:(KDABPersonType)type {
    self = [super init];
    if (self) {
        type_ = type;
    }
    
    return self;
}

- (id)initWithABRecord:(ABRecordRef)record {
    self = [super init];
    if (self) {
        record_ = CFRetain(record);
        [self _buildWithABRecord:record_];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Address Book methods

- (NSString *)stringPropertyInRecord:(ABRecordRef)record propertyId:(ABPropertyID)propId {
    return (__bridge NSString *) ABRecordCopyValue(record, propId);// autorelease];
}

- (NSArray *)arrayPropertyInRecord:(ABRecordRef)record propertyId:(ABPropertyID)propId {
    CFTypeRef prop = ABRecordCopyValue(record, propId);
	NSArray *items = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(prop);
	CFRelease(prop);
    
    return items;// autorelease];
}

- (NSArray *)_formatPhoneNumbers:(NSArray *)source {
    NSUInteger count = 0;
    NSMutableArray *phoneNumbers = nil;
    
    if (source != nil && (count = [source count]) > 0) {
        phoneNumbers = [NSMutableArray arrayWithCapacity:count];
        
        static NSRegularExpression *regex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // Match any character that is not a decimal digit.
            regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:0 error:NULL];// retain];
        });
        
        for (NSString *item in source) {
            // Replace any character that is not a decimal digit. only [0-9] is available
            NSString *val = [regex stringByReplacingMatchesInString:item options:0 range:NSMakeRange(0, [item length]) withTemplate:@""];
            [phoneNumbers addObject:val];
        }
    }
    
    return phoneNumbers;
}

- (void)_buildWithABRecord:(ABRecordRef)record {
    // Can not use the ABRecordCopyCompositeName() method at here
    // eg: one person named: 张三 (chinese order)
    // and the address book may be return as: 三 张 (saved first name and last name at different field)
    NSString *fname = [self stringPropertyInRecord:record propertyId:kABPersonFirstNameProperty];
    NSString *mname = [self stringPropertyInRecord:record propertyId:kABPersonMiddleNameProperty];
    NSString *lname = [self stringPropertyInRecord:record propertyId:kABPersonLastNameProperty];
    
    self.name = [NSString stringWithFormat:@"%@%@%@", (lname != nil) ? lname : @"",
                                          (mname != nil) ? mname : @"",
                                          (fname != nil) ? fname : @""];
    
    
    NSArray *mobiles = [self arrayPropertyInRecord:record propertyId:kABPersonPhoneProperty];
    if (mobiles != nil) {
        self.mobiles = [self _formatPhoneNumbers:mobiles];
    }
    
    self.emails = [self arrayPropertyInRecord:record propertyId:kABPersonEmailProperty];
    
    NSString *md5 ;
    if(name_){
        md5 = name_;
    }
    for(NSString *mobile in self.mobiles){
        md5 = [md5 stringByAppendingString:mobile];
    }
    for(NSString *email in self.emails){
        md5 = [md5 stringByAppendingString:email];
    }
    self.md5String = [md5 MD5DigestKey];
    
}

- (ABRecordRef)record {
    return record_;
}


+ (BOOL)addValue:(NSString *)value propertyId:(ABPropertyID)propertyId toRecord:(ABRecordRef)record {
    CFErrorRef error;
	BOOL success = ABRecordSetValue(record, propertyId, (__bridge CFStringRef)value, &error);
//    if (!success) DLog(@"Error: %@", [(NSError *)CFBridgingRelease(error localizedDescription]);

    
	return success;
}

+ (BOOL)addMultiValues:(ABMutableMultiValueRef)multiValues propertyId:(ABPropertyID)propertyId toRecord:(ABRecordRef)record {
	CFErrorRef error;
	BOOL success = ABRecordSetValue(record, propertyId, multiValues, &error);
//	if (!success) DLog(@"Error: %@", [(NSError *)CFBridgingRelease(error localizedDescription]);
    
	return success;
}

+ (void)mergeValues:(NSArray *)values withLabel:(CFTypeRef)label to:(ABMultiValueRef)container {
    for (id val in values) {
        ABMultiValueAddValueAndLabel(container, (__bridge CFTypeRef)val, label, NULL);
    }
}

// merge person properties to specificed record
+ (void)mergeKDABPerson:(KDABPerson *)person to:(ABRecordRef)record isExistsRecord:(BOOL)exists {
    if (person.name != nil) {
        [KDABPerson addValue:person.name propertyId:kABPersonFirstNameProperty toRecord:record];
    }
    
    if (exists) {
        // if merge the property to exists record. The last name and middle name may be not null.
        // So remove these values if need.
        ABRecordRemoveValue(record, kABPersonLastNameProperty, NULL);
        ABRecordRemoveValue(record, kABPersonMiddleNameProperty, NULL);
    }
    
    if (person.jobTitle != nil) {
        [KDABPerson addValue:person.jobTitle propertyId:kABPersonJobTitleProperty toRecord:record];
    }
    
    if (person.department != nil) {
        [KDABPerson addValue:person.department propertyId:kABPersonDepartmentProperty toRecord:record];
    }
    
    NSInteger mask = 0x00;
    if ([person hasMobileNumbers]) mask |= 0xf0;
    if ([person hasPhoneNumbers]) mask |= 0x0f;
    
    if (mask != 0x00) {
        ABMultiValueRef multiPhones = NULL;
        
        // retrieve stored phones
        ABMultiValueRef storedValues = ABRecordCopyValue(record, kABPersonPhoneProperty);
        if (storedValues != NULL) {
            multiPhones = ABMultiValueCreateMutableCopy(storedValues);
            CFRelease(storedValues);
            
        } else {
            multiPhones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        }
        
        if ((mask & 0xf0) != 0x00) {
            [KDABPerson mergeValues:person.mobiles withLabel:kABPersonPhoneMobileLabel to:multiPhones];
        }
        
        if ((mask & 0x0f) != 0x00) {
            [KDABPerson mergeValues:person.phones withLabel:kABWorkLabel to:multiPhones];
        }
        
        // update phones property
        [KDABPerson addMultiValues:multiPhones propertyId:kABPersonPhoneProperty toRecord:record];
        
        CFRelease(multiPhones);
    }
    
    //其他
    ABMultiValueRef multiOthers = NULL;
    
    // retrieve stored multiOthers
    ABMultiValueRef otherValues = ABRecordCopyValue(record, kABPersonPhoneProperty);
    if (otherValues != NULL) {
        multiOthers = ABMultiValueCreateMutableCopy(otherValues);
        CFRelease(otherValues);
        
    } else {
        multiOthers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
    
    if (person.others.count >0) {
        [KDABPerson mergeValues:person.others withLabel:kABPersonPhoneMainLabel to:multiOthers];
    }
    
    [KDABPerson addMultiValues:multiOthers propertyId:kABPersonPhoneProperty toRecord:record];
    CFRelease(multiOthers);

    
    if ([person hasEmails]) {
        ABMultiValueRef multiEmails = NULL;
        
        // retrieve stored emails
        ABMultiValueRef storedValues = ABRecordCopyValue(record, kABPersonEmailProperty);
        if (storedValues != NULL) {
            multiEmails = ABMultiValueCreateMutableCopy(storedValues);
            CFRelease(storedValues);
            
        } else {
            multiEmails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        }
        
        [KDABPerson mergeValues:person.emails withLabel:kABWorkLabel to:multiEmails];
        
        // update emails property
        [KDABPerson addMultiValues:multiEmails propertyId:kABPersonEmailProperty toRecord:record];
        
        CFRelease(multiEmails);
    }
    
    // add profile image
    NSString *cacheKey = [person getAvatarCacheKey];
    NSString *path = [KDCacheUtlities avatarFullPathForCacheKey:cacheKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data != nil) {
            CFErrorRef error;
            BOOL success = ABPersonSetImageData(record, (__bridge CFDataRef) data, &error);
            if (!success) {
                DLog(@"Can not set profile image to person=%@", person.name);
            }
        }
    }
}


////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Persistence

#define KD_AB_PERSON_DIVIDER    @"<,>"

+ (NSString *)ABPersonCompositeValueToString:(NSArray *)compositeValue {
    if (compositeValue == nil || [compositeValue count] < 1) return nil;
    
    return [compositeValue componentsJoinedByString:KD_AB_PERSON_DIVIDER];
}

+ (NSArray *)ABPersonCompositeValueFromString:(NSString *)string {
    if (string == nil || [string length] < 1) return nil;
    return [string componentsSeparatedByString:KD_AB_PERSON_DIVIDER];
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark utlity methods

- (BOOL)hasMobileNumbers {
    return (mobiles_ != nil && [mobiles_ count] > 0) ? YES : NO;
}

- (BOOL)hasPhoneNumbers {
    return (phones_ != nil && [phones_ count] > 0) ? YES : NO;
}

- (BOOL)hasEmails {
    return (emails_ != nil && [emails_ count] > 0) ? YES : NO;
}

- (NSArray *)allMobileAndPhoneNumbers {
    NSMutableArray *items = nil;
    
    NSInteger mask = 0x00;
    mask |= [self hasMobileNumbers] ? 0xf0 : 0x00;
    mask |= [self hasPhoneNumbers] ? 0x0f : 0x00;
    
    if ((mask | 0x00) != 0x00) {
        items = [NSMutableArray array];
        
        if ((mask & 0xf0) != 0x00) {
            [items addObjectsFromArray:mobiles_];
        }
        
        if ((mask & 0xf0) != 0x00) {
            [items addObjectsFromArray:phones_];
        }
    }
    
    return items;
}

- (void)_appendRecords:(NSArray *)source to:(NSMutableString *)body subject:(NSString *)subject {
    NSUInteger count = 0;
    if (source != nil && (count = [source count]) > 0) {
        NSUInteger idx = 0;
        for (NSString *item in source) {
            if (idx < count) {
                [body appendFormat:@"%@ %@\n", subject, item];
            }
            
            idx++;
        }
    }
}

- (NSString *)formatAsMessageBody {
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"%@\n", name_];
    
    [self _appendRecords:mobiles_ to:body subject:NSLocalizedString(@"AB_RECORD_MOBILE", @"")];
    [self _appendRecords:phones_ to:body subject:NSLocalizedString(@"AB_RECORD_PHONE", @"")];
    [self _appendRecords:emails_ to:body subject:NSLocalizedString(@"AB_RECORD_EMAIL", @"")];
    
    return body;
}

- (KDUser *)convertToUser {
    KDUser *user = [[KDUser alloc] init];// autorelease];
    user.userId = userId_;
    user.username = name_;
    user.screenName = name_;
    
    return user;
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Setters and Getters

- (NSString *)mobileNumbers {
    return [KDABPerson ABPersonCompositeValueToString:mobiles_];
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAvatarDataSource protocol methods

- (KDAvatarType)getAvatarType {
    return KDAvatarTypeUser;
}

- (KDImageSize *)avatarScaleToSize {
    return [KDImageSize defaultUserAvatarSize];
}

- (NSString *)getAvatarLoadURL {
    return profileImageURL_;
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


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageDataSource protocol methods

- (BOOL)hasImageSource {
    return (profileImageURL_ != nil && [profileImageURL_ length] > 1) ? YES : NO;
}

- (BOOL)hasManyImageSource {
    return NO;
}
- (BOOL)isTimeLineDataSource
{
    return NO;
}
- (KDImageSource *)getTimeLineImageSourceAtIndex:(NSInteger)index
{
    return nil;
}
- (NSString *)thumbnailImageURL {
    return [self middleImageURL];
}

- (NSArray *)thumbnailImageURLs {
    return [self middleImageURLs];
}

- (NSString *)middleImageURL {
    return [self hasImageSource] ? profileImageURL_ : nil;
}

- (NSArray *)middleImageURLs {
    return [self hasImageSource] ? @[profileImageURL_] : nil;
}

- (NSString *)bigImageURL {
    return [self middleImageURL];
}

- (NSArray *)bigImageURLs {
    return [self middleImageURLs];
}
- (NSArray *)noRawURLs {
    return [self middleImageURLs];
}
- (NSString *)cacheKeyForImageSourceURL:(NSString *)imageSourceURL {
    return [self getAvatarCacheKey];
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:pId_ forKey:@"pId"];
    [aCoder encodeObject:userId_ forKey:@"userId"];
    [aCoder encodeObject:name_ forKey:@"name"];
    [aCoder encodeObject:mobiles_ forKey:@"mobiles"];
    [aCoder encodeObject:emails_ forKey:@"emails"];
    [aCoder encodeObject:md5String_ forKey:@"md5String"];
}

//@property(nonatomic, retain) NSString *pId; // address book
//@property(nonatomic, retain) NSString *userId;
//@property(nonatomic, retain) NSString *name;
//@property(nonatomic, retain) NSString *jobTitle;
//@property(nonatomic, retain) NSString *department;
//
//@property(nonatomic, retain) NSString *networkId;
//
//@property(nonatomic, retain) NSArray *emails;
//@property(nonatomic, retain) NSArray *phones;
//@property(nonatomic, retain) NSArray *mobiles;
//
//@property(nonatomic, retain) NSString *profileImageURL;
//
//@property(nonatomic, assign) BOOL favorited;
//@property(nonatomic, assign) KDABPersonType type;
//
//@property(nonatomic, retain, readonly) NSString *mobileNumbers;
- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        
        self.pId = [aDecoder decodeObjectForKey:@"pId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.mobiles = [aDecoder decodeObjectForKey:@"mobiles"];
        self.emails = [aDecoder decodeObjectForKey:@"emails"];
        self.md5String = [aDecoder decodeObjectForKey:@"md5String"];
    }
    return self;
}
- (void)dealloc {
    if (record_ != NULL) {
        CFRelease(record_);
    }
    
    //KD_RELEASE_SAFELY(pId_);
    //KD_RELEASE_SAFELY(userId_);
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(jobTitle_);
    //KD_RELEASE_SAFELY(department_);
    //KD_RELEASE_SAFELY(md5String_);
    //KD_RELEASE_SAFELY(networkId_);
    
    //KD_RELEASE_SAFELY(emails_);
    //KD_RELEASE_SAFELY(phones_);
    //KD_RELEASE_SAFELY(mobiles_);
    
    //KD_RELEASE_SAFELY(profileImageURL_);
    
    //[super dealloc];
}

@end
