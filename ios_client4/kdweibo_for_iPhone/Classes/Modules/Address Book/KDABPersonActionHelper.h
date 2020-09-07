//
//  KDABPersonActionHelper.h
//  kdweibo
//
//  Created by laijiandong on 12-11-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class KDABPerson;

@protocol KDABPersonActionHelperDelegate <NSObject>

- (void) cancleMenuClicked;

@end

@interface KDABPersonActionHelper : NSObject <MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, assign) UIViewController *viewController; // weak reference
@property (nonatomic, retain) KDABPerson *pickedPerson;
@property (nonatomic, assign) id<KDABPersonActionHelperDelegate> delegate;

- (id)initWithViewController:(UIViewController *)vc;

- (void)showNotificationMessage:(NSString *)message;

- (void)showContactMainActionMenu:(KDABPerson *)person;
- (void)showABPersonProfile;

- (void)sendDM;
- (void)phoneCallOut;
- (void)phoneCallOutToRecipient:(NSString *)recipient;
- (void)sendSMS;
- (void)sendSMSToRecipient:(NSString *)recipient body:(NSString *)body;

- (void)shareViaMessageCompose:(NSString *)recipient body:(NSString *)body sharingContact:(BOOL)sharingContact;

- (void)addToLocalAddressBookStore;

@end
