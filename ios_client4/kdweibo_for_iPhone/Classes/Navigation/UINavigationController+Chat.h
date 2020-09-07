//
//  UINavigationController+Chat.h
//  kdweibo
//
//  Created by Gil on 16/5/17.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Chat)

- (void)setupTimelineTab;
- (void)setupAppTab;

- (void)pushToChatWithGroup:(GroupDataModel *)group
             shareDataModel:(XTShareDataModel *)shareDM
                isPopToRoot:(BOOL)isPopToRoot;

- (void)pushToChatWithPerson:(PersonSimpleDataModel *)person
              shareDataModel:(XTShareDataModel *)shareDM
                 isPopToRoot:(BOOL)isPopToRoot;

- (void)pushToTodo;

@end
