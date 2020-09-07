//
//  KDABPerson.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "KDObject.h"
#import "KDAvatarProtocol.h"
#import "KDImageSourceProtocol.h"


@class KDUser;

typedef enum : NSUInteger {
    KDABPersonTypeRecently = 0x01,
    KDABPersonTypeAll,
    KDABPersonTypeFavorited
    
}KDABPersonType;


#define KD_AB_PERSON_MATCHED_KEY            @"matched_key"
#define KD_AB_PERSON_MATCHED_MASK_KEY       @"matched_mask"
#define KD_AB_PERSON_MATCHED_ITEMS          @"matched_items"


@interface KDABPerson : KDObject <KDAvatarDataSource, KDImageDataSource,NSCoding>

@property(nonatomic, retain) NSString *pId; // address book
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *jobTitle;
@property(nonatomic, retain) NSString *department;

@property(nonatomic, retain) NSString *networkId;

@property(nonatomic, retain) NSArray *emails;
@property(nonatomic, retain) NSArray *phones;
@property(nonatomic, retain) NSArray *mobiles;
@property(nonatomic, retain) NSArray *others;
@property(nonatomic, retain) NSString *md5String;
@property(nonatomic, retain) NSString *profileImageURL;

@property(nonatomic, assign) BOOL favorited;
@property(nonatomic, assign) KDABPersonType type;

@property(nonatomic, retain, readonly) NSString *mobileNumbers;

- (id)initWithType:(KDABPersonType)type;

- (id)initWithABRecord:(ABRecordRef)record;
- (ABRecordRef)record;

+ (void)mergeKDABPerson:(KDABPerson *)person to:(ABRecordRef)record isExistsRecord:(BOOL)exists;

- (BOOL)hasMobileNumbers;
- (BOOL)hasPhoneNumbers;
- (BOOL)hasEmails;
- (NSArray *)allMobileAndPhoneNumbers;

- (NSString *)formatAsMessageBody;

- (KDUser *)convertToUser;

@end
