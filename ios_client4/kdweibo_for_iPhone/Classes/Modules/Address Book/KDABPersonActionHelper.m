//
//  KDABPersonActionHelper.m
//  kdweibo
//
//  Created by laijiandong on 12-11-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDABPersonActionHelper.h"

#import "KDABPersonDetailsViewController.h"
#import "KDNotificationView.h"
#import "KDABPerson.h"

#import "KDDefaultViewControllerContext.h"
#import "KDUIUtils.h"
#import "NSString+Additions.h"
#import "KDDMConversationViewController.h"
#import "KDManagerContext.h"
#import "KDWeiboDAOManager.h"
#import "KDDatabaseHelper.h"

#define KD_AB_PERSON_MAIN_MENU_TAG          0x64
#define KD_AB_PERSON_PHONE_CALL_MENU_TAG    0x65
#define KD_AB_PERSON_SMS_MENU_TAG           0x66

#define KD_AB_PERSON_CREATE_MENU_TAG        0x67


static ABAddressBookRef createAddressBook();



@implementation KDABPersonActionHelper

@synthesize viewController = viewController_;
@synthesize pickedPerson   = pickedPerson_;
@synthesize delegate       = delegate_;

- (id)initWithViewController:(UIViewController *)vc {
    self = [super init];
    if (self) {
        viewController_ = vc;
    }
    
    return self;
}

- (void)showNotificationMessage:(NSString *)message {
    [[KDNotificationView defaultMessageNotificationView] showInView:viewController_.view
                                                            message:message
                                                               type:KDNotificationViewTypeNormal];
}

- (void)showContactMainActionMenu:(KDABPerson *)person {
    self.pickedPerson = person;
    
    BOOL hasMobileNumbers = [pickedPerson_ hasMobileNumbers];
    BOOL hasPhoneNumbers = [pickedPerson_ hasPhoneNumbers];
    
    NSMutableArray *menus = [NSMutableArray array];
    [menus addObject:NSLocalizedString(@"AB_ACTION_SEND_DM", @"")];
    
    if (hasMobileNumbers || hasPhoneNumbers) {
        [menus addObject:NSLocalizedString(@"AB_ACTION_PHONE_CALL", @"")];
    }
    
    if (hasMobileNumbers) {
        [menus addObject:NSLocalizedString(@"AB_ACTION_SEND_SMS", @"")];
    }
    
    [menus addObject:NSLocalizedString(@"AB_VIEWING_CONTACT_PROFILE", @"")];
    [menus addObject:ASLocalizedString(@"Global_Cancel")];
    
    [self showActionMenuTitle:person.name menus:menus cancelButtonIndex:([menus count] - 1) tag:KD_AB_PERSON_MAIN_MENU_TAG];
}

- (void)showActionMenuTitle:(NSString *)title menus:(NSArray *)menus
           cancelButtonIndex:(NSInteger)cancelButtonIndex tag:(NSInteger)tag {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = tag;
    
    if (title != nil) {
        actionSheet.title = title;
    }
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    actionSheet.cancelButtonIndex = cancelButtonIndex;
    
    [actionSheet showInView:viewController_.view];
//    [actionSheet release];
}



////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark action methods

- (void)sendDM {
    __block KDUser *curUser = [KDManagerContext globalManagerContext].userManager.currentUser;
    __block KDUser *pickedUser = [pickedPerson_ convertToUser];
    
    [KDDatabaseHelper inDatabase:^id(FMDatabase *fmdb){
        id<KDUserDAO> userDAO = [KDWeiboDAOManager globalWeiboDAOManager].userDAO;
        if(!curUser) {
            NSString *curUserId = [KDManagerContext globalManagerContext].userManager.currentUserId;
            curUser = [userDAO queryUserWithId:curUserId database:fmdb];
        }
        
        KDUser *user = [userDAO queryUserWithId:pickedUser.userId database:fmdb];
        if(user) {
            pickedUser = user;
        }
        
        return nil;
    }completionBlock:^(id result) {
    }];
    KDDMConversationViewController *con = [[KDDMConversationViewController alloc] initWithParticipants:[NSArray arrayWithObjects:curUser, pickedUser, nil]];// autorelease];
    [self.viewController.navigationController pushViewController:con animated:YES];
}

- (void)phoneCallOut {
    if ([KDUIUtils isSupportedPhoneCall]) {
        NSArray *items = [pickedPerson_ allMobileAndPhoneNumbers];
        if ([items count] > 1) {
            NSMutableArray *menus = [NSMutableArray arrayWithArray:items];
            [menus addObject:ASLocalizedString(@"Global_Cancel")];
            
            [self showActionMenuTitle:pickedPerson_.name menus:menus
                     cancelButtonIndex:([menus count] - 1) tag:KD_AB_PERSON_PHONE_CALL_MENU_TAG];
            
        } else {
            [self phoneCallOutToRecipient:items[0]];
        }
        
    } else {
        [self showNotificationMessage:NSLocalizedString(@"NOT_SUPPORTED_PHONE_CALL", @"")];
    }
}

- (void)phoneCallOutToRecipient:(NSString *)recipient {
    if([KDUIUtils isSupportedPhoneCall]) {
        NSString *string = [NSString stringWithFormat:@"tel:%@", recipient];
        [KDCommon openURLInApplication:string];
    }else {
        [self showNotificationMessage:NSLocalizedString(@"NOT_SUPPORTED_PHONE_CALL", @"")];
    }
}

- (void)sendSMS {
    if ([KDUIUtils canSendTextViaMessageCompose]) {
        if ([pickedPerson_.mobiles count] > 1) {
            NSMutableArray *menus = [NSMutableArray arrayWithArray:pickedPerson_.mobiles];
            [menus addObject:ASLocalizedString(@"Global_Cancel")];
            
            [self showActionMenuTitle:pickedPerson_.name menus:menus
                     cancelButtonIndex:([menus count] - 1) tag:KD_AB_PERSON_SMS_MENU_TAG];
            
        } else {
            [self shareViaMessageCompose:pickedPerson_.mobiles[0] body:nil sharingContact:NO];
        }
        
    } else {
        [self showNotificationMessage:NSLocalizedString(@"NOT_SUPPORTED_SEND_SMS", @"")];
    }
}

- (void)sendSMSToRecipient:(NSString *)recipient body:(NSString *)body {
    NSString *encodeBody = nil;
    if (body != nil) {
        encodeBody = [body escapeAsURLQueryParameter];
    }
    
    NSString *string = [NSString stringWithFormat:@"sms:%@", (recipient != nil) ? recipient : @""];
    if (encodeBody != nil) {
        string = [string stringByAppendingFormat:@"?body=%@", encodeBody];
    }
    
    [KDCommon openURLInApplication:string];
}

- (void)shareViaMessageCompose:(NSString *)recipient body:(NSString *)body sharingContact:(BOOL)sharingContact {
    if (sharingContact) {
        // This app has a bug about pick ABPerson(MFMessageComposeViewController) on iOS 4.3 devices.
        // And not have enough time to fixs it at this version.
        // just copy content to pasteboard if the iOS version of current device before 5.0
        // 修复V2.1.0因高德地图sdk引起的发短信crash问题后，分享通讯录功能crash问题也莫名消失
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.3) {
            if (body != nil) {
                [[UIPasteboard generalPasteboard] setString:body];
                
                [self showNotificationMessage:NSLocalizedString(@"AB_PERSON_COPIED_TO_PASTEBOARD", @"")];
            }
            
            return;
        }
    }
    
    if ([KDUIUtils canSendTextViaMessageCompose]) {
        MFMessageComposeViewController *mcvc = [[MFMessageComposeViewController alloc] init];
        mcvc.messageComposeDelegate = self;
        
        if (body != nil) {
            mcvc.body = body;
        }
        
        if (recipient != nil) {
            mcvc.recipients = @[recipient];
        }
        
        [viewController_ presentViewController:mcvc animated:YES completion:nil];
//        [mcvc release];
        
    } else {
        [self showNotificationMessage:NSLocalizedString(@"NOT_SUPPORTED_SEND_SMS", @"")];
    }
}

- (void)showABPersonProfile {
    KDABPersonDetailsViewController *abpdvc = [[KDABPersonDetailsViewController alloc] initWithABPerson:pickedPerson_];
    [viewController_.navigationController pushViewController:abpdvc animated:YES];
//    [abpdvc release];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Address book methods

- (NSArray *)_allLocalABContacts {
    NSMutableArray *persons = nil;
    
    ABAddressBookRef addressBook = createAddressBook();
    
    if (addressBook != NULL) {
        NSArray *contacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        persons = [NSMutableArray arrayWithCapacity:[contacts count]];
        KDABPerson *p = nil;
        
        for (id record in contacts) {
            p = [[KDABPerson alloc] initWithABRecord:(ABRecordRef)record];
            [persons addObject:p];
//            [p release];
        }
        
//        [contacts release];
        
        CFRelease(addressBook);
    }
    
    return persons;
}

- (NSArray *)_matchABPerson:(KDABPerson *)person in:(NSArray *)persons {
    if (person == nil || (persons == nil || [persons count] == 0)) {
        return nil;
    }
    
    // clear cached properties begin match action
    [person setProperty:nil forKey:KD_AB_PERSON_MATCHED_KEY];
    [person setProperty:nil forKey:KD_AB_PERSON_MATCHED_MASK_KEY];
    
    BOOL found = NO;
    NSArray *matchedItems = nil;
    
    NSString *pattern = nil;
    NSPredicate *predicate = nil;
    if ([person hasMobileNumbers]) {
        // match the mobile phones
        for (NSString *mobile in person.mobiles) {
            pattern = [NSString stringWithFormat:@".*%@.*", mobile];
            predicate = [NSPredicate predicateWithFormat:@"mobileNumbers MATCHES[cd] %@", pattern];
            
            matchedItems = [persons filteredArrayUsingPredicate:predicate];
            if (matchedItems != nil && [matchedItems count] > 0) {
                found = YES;
                [person setProperty:mobile forKey:KD_AB_PERSON_MATCHED_KEY];
                [person setProperty:@(0xf0) forKey:KD_AB_PERSON_MATCHED_MASK_KEY];
                
                break;
            }
        }
    }

    if (!found) {
        // match the name of person
        pattern = [NSString stringWithFormat:@".*%@.*", person.name];
        predicate = [NSPredicate predicateWithFormat:@"name MATCHES[cd] %@", pattern];
        matchedItems = [persons filteredArrayUsingPredicate:predicate];
        if (matchedItems != nil && [matchedItems count] > 0) {
            [person setProperty:person.name forKey:KD_AB_PERSON_MATCHED_KEY];
            [person setProperty:@(0x0f) forKey:KD_AB_PERSON_MATCHED_MASK_KEY];
        }
    }
    
    return matchedItems;
}

- (void)_removeMatachedItemsInPerson:(KDABPerson *)person {
    [person setProperty:nil forKey:KD_AB_PERSON_MATCHED_ITEMS];
}

- (void)addToLocalAddressBookStore {
    NSArray *allContacts = [self _allLocalABContacts];
    NSArray *matchedItems = [self _matchABPerson:pickedPerson_ in:allContacts];
    
    NSUInteger count = 0;
    if (matchedItems != nil && (count = [matchedItems count]) > 0) {
        // store matched items
        [pickedPerson_ setProperty:matchedItems forKey:KD_AB_PERSON_MATCHED_ITEMS];
        
        NSString *matchedKey = [pickedPerson_ propertyForKey:KD_AB_PERSON_MATCHED_KEY];
        NSNumber *matchedMask = [pickedPerson_ propertyForKey:KD_AB_PERSON_MATCHED_MASK_KEY];
        
        // build action sheet title
        BOOL matchedMobile = (([matchedMask integerValue] & 0xf0) != 0) ? YES : NO;
        NSString *prefix = matchedMobile ? NSLocalizedString(@"AB_SUBJECT_PHONE_NUMBER", @"") : @"";
        
        NSString *suffix = nil;
        if (count > 1) {
            suffix = NSLocalizedString(@"AB_PERSON_COUNT_MULTI", @"");
            
        } else {
            KDABPerson *person = matchedItems[0];
            suffix = person.name;
        }
        
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"AB_EXISTS_PERSON_%@_%@_%@", @""),
                                                     prefix, matchedKey, suffix];
        
        NSArray *menus = @[NSLocalizedString(@"AB_NEW_PERSON", @""),
                           NSLocalizedString(@"AB_ADD_TO_EXISTS_PERSON", @""),
                           ASLocalizedString(@"Global_Cancel")];
        
        [self showActionMenuTitle:title menus:menus cancelButtonIndex:([menus count] - 1) tag:KD_AB_PERSON_CREATE_MENU_TAG];
        
    } else {
        [self createNewLocalABPerson];
    }
}

- (void)showNewLocalABPersonViewController:(ABRecordRef)record {
    ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
	npvc.newPersonViewDelegate = self;
    
    if (record != NULL) {
        npvc.displayedPerson = record;
    }
	
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:npvc];
    nvc.delegate = self;
    [viewController_ presentViewController:nvc animated:YES completion:nil];
	
//	[npvc release];
//	[nvc release];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSInteger index = [navigationController.viewControllers indexOfObject:viewController];
    if (index == 0 )
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:FC5 forState:UIControlStateNormal];
        [btn setTitle:ASLocalizedString(@"Global_Cancel") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];// autorelease];
//        [btn release];
    }
}

-(void)dismiss:(UIButton *)btn
{
    [viewController_ dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNewLocalABPerson {
    ABRecordRef record = ABPersonCreate();
    [KDABPerson mergeKDABPerson:pickedPerson_ to:record isExistsRecord:NO];
    
    [self showNewLocalABPersonViewController:record];
    CFRelease(record);
}

- (void)editExistLocalABPerson {
    NSArray *matchedItems = [pickedPerson_ propertyForKey:KD_AB_PERSON_MATCHED_ITEMS];
    KDABPerson *person = matchedItems[0];
    
    // the address book exists record
    ABRecordRef record = [person record];
    
    BOOL saved = NO;
    ABRecordRef cachedRecord = NULL;
    
    ABAddressBookRef addressBook = createAddressBook();
    if (addressBook != NULL) {
        ABRecordID recordId = ABRecordGetRecordID(record);
        if (kABRecordInvalidID != recordId) {
            cachedRecord = ABAddressBookGetPersonWithRecordID(addressBook, recordId);
            if (cachedRecord != NULL) {
                // merge picked person value to exist address book record
                [KDABPerson mergeKDABPerson:pickedPerson_ to:cachedRecord isExistsRecord:YES];
                
                if (ABAddressBookHasUnsavedChanges(addressBook)) {
                    CFErrorRef error = NULL;
                    if (ABAddressBookSave(addressBook, &error)) {
                        saved = YES;
                        
                    } else {
                        if (error != NULL) {
//                            DLog(@"save address book changes did fail with error = %@", [(NSError *)CFBridgingRelease(error localizedDescription]);
                        }
                        
                        ABAddressBookRevert(addressBook); // revert changes if save did fail
                    }
                }
            }
        }
    }
    
    if (saved) {
        // show person view controller
        ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
        pvc.personViewDelegate = self;
        pvc.displayedPerson = cachedRecord;
        pvc.allowsEditing = YES;
        
        [viewController_.navigationController pushViewController:pvc animated:YES];
//        [pvc release];
    }
    
    // release the address book at finally,
    // aviod it and cachedRecord become wild pointer before bind to ABPersonViewController.
    if (addressBook != NULL) {
        CFRelease(addressBook);
    }
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        if (actionSheet.tag == KD_AB_PERSON_CREATE_MENU_TAG) {
            // remove cached matched items
            [self _removeMatachedItemsInPerson:pickedPerson_];
        }
        if(delegate_ && [delegate_ respondsToSelector:@selector(cancleMenuClicked)]) {
            [delegate_ cancleMenuClicked];
        }
        return;
    }
    
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (actionSheet.tag == KD_AB_PERSON_MAIN_MENU_TAG) {
        if ([btnTitle isEqualToString:NSLocalizedString(@"AB_ACTION_SEND_DM", @"")]) {
            [self sendDM];
            
        } else if ([btnTitle isEqualToString:NSLocalizedString(@"AB_ACTION_PHONE_CALL", @"")]) {
            [self phoneCallOut];
            
        } else if ([btnTitle isEqualToString:NSLocalizedString(@"AB_ACTION_SEND_SMS", @"")]) {
            [self sendSMS];
            
        } else if ([btnTitle isEqualToString:NSLocalizedString(@"AB_VIEWING_CONTACT_PROFILE", @"")]) {
            [self showABPersonProfile];
        }
        
    } else if (actionSheet.tag == KD_AB_PERSON_PHONE_CALL_MENU_TAG) {
        [self phoneCallOutToRecipient:btnTitle];
        
    } else if (actionSheet.tag == KD_AB_PERSON_SMS_MENU_TAG) {
        [self shareViaMessageCompose:btnTitle body:nil sharingContact:NO];
        
    } else if(actionSheet.tag == KD_AB_PERSON_CREATE_MENU_TAG) {
        if (0x00 == buttonIndex) {
            [self createNewLocalABPerson];
            
        } else {
            [self editExistLocalABPerson];
        }
        
        // remove cached matched items
        [self _removeMatachedItemsInPerson:pickedPerson_];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark MFMessageComposeViewController delegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [viewController_ dismissViewControllerAnimated:YES completion:nil];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark ABNewPersonViewController delegate methods

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController
       didCompleteWithNewPerson:(ABRecordRef)person {
    [viewController_ dismissViewControllerAnimated:YES completion:nil];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark ABNewPersonViewController delegate methods

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
    return YES;
}

- (void)dealloc {
    viewController_ = nil;
    
    //KD_RELEASE_SAFELY(pickedPerson_);
   
    
    //[super dealloc];
}

@end



// you should release returned object
static ABAddressBookRef createAddressBook() {
    ABAddressBookRef addressBook = NULL;
    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    return addressBook;
}
