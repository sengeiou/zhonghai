//
//  KDABPersonDetailsViewController.h
//  kdweibo
//
//  Created by laijiandong on 12-11-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDABPerson;
@class KDABPersonActionHelper;

@interface KDABPersonDetailsViewController : UIViewController

@property(nonatomic, retain) KDABPerson *person;
@property(nonatomic, copy)   NSString   *userId;
@property(nonatomic, readonly) KDABPersonActionHelper *actionHelper;

- (id)initWithABPerson:(KDABPerson *)person;

- (id)initWithUserId:(NSString *)userId;

- (void)loadPersonAddressBookInfo;
@end
