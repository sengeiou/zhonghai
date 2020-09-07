//
//  GroupHeadView.h
//  ContactsLite
//
//  Created by kingdee eas on 13-2-21.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroupDataModel;
@class PersonSimpleDataModel;
@protocol XTGroupHeaderImageViewDelegate;

@interface XTGroupHeaderImageView : UIImageView

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, weak) id<XTGroupHeaderImageViewDelegate> delegate;

@end

@protocol XTGroupHeaderImageViewDelegate <NSObject>
@optional
- (void)groupHeaderClicked:(XTGroupHeaderImageView *)headerImageView person:(PersonSimpleDataModel *)person;
@end
