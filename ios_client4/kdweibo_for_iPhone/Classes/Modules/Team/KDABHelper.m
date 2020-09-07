//
//  KDABHelper.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDABHelper.h"
#import "KDABRecord.h"
#import "KDABPerson.h"
#import <AddressBook/AddressBook.h>

@implementation KDABHelper

+ (BOOL)hasContactPermission
{
    ABAddressBookRef addressBook = nil;
    
   
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     DLog(@"%uud",granted);
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        dispatch_release(sema);
   
    
    if(addressBook == nil) {
        return NO;
    }else {
        CFRelease(addressBook);
        return YES;
    }
}

+ (NSArray *)allPhoneContacts
{
    ABAddressBookRef addressBook = nil;
    
    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    dispatch_release(sema);
    
    if(addressBook == nil) {
        return nil;
    }
    
    CFArrayRef personArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    CFIndex count = CFArrayGetCount(personArray);
    
    NSMutableArray *allContacts = [NSMutableArray arrayWithCapacity:count];
    
    for(CFIndex index = 0; index < count; index++) {
        ABRecordRef record = CFArrayGetValueAtIndex(personArray, index);
        
        KDABRecord *person = [[KDABRecord alloc] init];
        
        NSString *personFirstName = (__bridge NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        NSString *personLastName = (__bridge NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
        
        person.name = [NSString stringWithFormat:@"%@%@", (personLastName ? personLastName : @""), (personFirstName ? personFirstName : @"")];
//        [personFirstName release];
//        [personLastName release];
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFIndex phoneCount = ABMultiValueGetCount(phoneNumbers);
        
        for(CFIndex idx = 0; idx < phoneCount; idx++) {
            CFStringRef personPhone = ABMultiValueCopyValueAtIndex(phoneNumbers, idx);
            
            if(personPhone && CFStringGetLength(personPhone) > 0) {
                NSMutableString *phoneNumber = [NSMutableString stringWithFormat:@"%@", personPhone];
                
                if([phoneNumber hasPrefix:@"+86"]) {
                    [phoneNumber deleteCharactersInRange:NSMakeRange(0, 3)];
                }
                
                NSMutableString *pn = [NSMutableString string];
                
                for(NSInteger index = 0; index < phoneNumber.length; index++) {
                    unichar c = [phoneNumber characterAtIndex:index];
                    if(c >= '0' && c <= '9') {
                        [pn appendFormat:@"%c", c];
                    }
                }
                
                if(pn && pn.length && [self isValidateMobile:pn]) {
                    person.phoneNumber = pn;
                    CFRelease(personPhone);
                    break;
                }
            }
            
            CFRelease(personPhone);
        }
        
        CFRelease(phoneNumbers);
        
        if(person.name.length > 0 && person.phoneNumber.length > 0) {
            [allContacts addObject:person];
        }
        
//        [person release];
    }
    
    CFRelease(personArray);
    CFRelease(addressBook);
    
    return allContacts;
}

+ (NSArray *)allPhoneCompleteContacts
{
    ABAddressBookRef addressBook = nil;
    
    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    dispatch_release(sema);
    
    if(addressBook == nil) {
        return nil;
    }
    
    CFArrayRef personArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    CFIndex count = CFArrayGetCount(personArray);
    
    NSMutableArray *allContacts = [NSMutableArray arrayWithCapacity:count];
    
    for(CFIndex index = 0; index < count; index++) {
        ABRecordRef record = CFArrayGetValueAtIndex(personArray, index);
        
        KDABPerson *person = [[KDABPerson alloc] initWithABRecord:record];
        
        if(person.name.length > 0 && person.mobiles.count > 0) {
            [allContacts addObject:person];
        }
        
//        [perso/n release];
    }
    
    CFRelease(personArray);
    CFRelease(addressBook);
    
    return allContacts;
}


+ (BOOL)isValidateMobile:(NSString *)mobile
{
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    return [phoneTest evaluateWithObject:mobile];
}


@end
