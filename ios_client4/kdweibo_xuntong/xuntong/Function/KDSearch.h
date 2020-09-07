//
//  KDSearch.h
//  kdweibo
//
//  Created by Gil on 15/1/8.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDSearch : NSObject

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) void(^blockBeginSearching)();
@property (nonatomic, copy) void(^blockEndSearching)();

- (id)initWithContentsController:(UIViewController *)contentsController;

- (void)willAppear;
- (void)willDisappear;

@end
