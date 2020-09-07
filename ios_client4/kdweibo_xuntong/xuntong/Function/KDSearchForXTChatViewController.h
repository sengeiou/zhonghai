//
//  KDSearchForXTChatViewController.h
//  kdweibo
//
//  Created by 陈彦安 on 15/5/12.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTSelectPersonsView.h"

@interface KDSearchForXTChatViewController : NSObject

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) UISearchDisplayController *searchDisplayController;

@property (nonatomic, strong) XTSelectPersonsView *selectedPersonsView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) NSInteger pType;
@property (nonatomic, assign) BOOL isMult;

- (id)initWithContentsController:(UIViewController *)contentsController;
@end
