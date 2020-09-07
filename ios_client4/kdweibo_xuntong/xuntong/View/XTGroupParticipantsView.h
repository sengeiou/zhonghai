//
//  XTGroupParticipantsView.h
//  XT
//
//  Created by Gil on 13-7-9.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderCanDeleteView.h"

@protocol XTGroupParticipantsViewDelegate;
@class GroupDataModel;

/**
 *  7.0.2后，该类已经不用了
 */
@interface XTGroupParticipantsView : UIView <XTPersonHeaderCanDeleteViewDelegate,XTPersonHeaderViewDelegate>

@property (nonatomic, weak) id<XTGroupParticipantsViewDelegate> delegate;
@property (nonatomic, weak) UIViewController *controller;

- (id)initWithGroup:(GroupDataModel *)group;

- (void)layoutParticipantsView;

@end

@class PersonSimpleDataModel;
@protocol XTGroupParticipantsViewDelegate <NSObject>

- (void)groupParticipantsViewAddPerson;
- (void)groupParticipantsViewDeletePerson;
- (void)groupParticipantsViewDeletePerson:(PersonSimpleDataModel *)person;

@end
