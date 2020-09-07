//
//  XTSelectContactsView.h
//  XT
//
//  Created by Gil on 14-4-10.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTSelectContactsViewDelegate,XTSelectContactsViewDataSource;
@class XTAddressBookModel;
@interface XTSelectContactsView : UIView

@property (nonatomic, strong, readonly) NSMutableArray *contacts;
@property (nonatomic, weak) id<XTSelectContactsViewDelegate> delegate;
@property (nonatomic, weak) id<XTSelectContactsViewDataSource> dataSource;

- (void)addContact:(XTAddressBookModel *)contact;
- (void)deleteContact:(XTAddressBookModel *)contact;

@end

@protocol XTSelectContactsViewDelegate <NSObject>

- (void)selectContactViewDidConfirm:(NSMutableArray *)contacts;

@end

@protocol XTSelectContactsViewDataSource <NSObject>

- (void)selectContactsViewDidAddContact:(XTAddressBookModel *)contact;
- (void)selectContactsViewDidDeleteContact:(XTAddressBookModel *)contact;

@end

@interface XTSelectContactButton : UIButton
@property (strong, nonatomic) XTAddressBookModel *contact;
@end
