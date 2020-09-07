//
//  KDChatDetailSearch.h
//  kdweibo
//
//  Created by liwenbo on 16/2/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDChatDetailSearch : NSObject

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) GroupDataModel *group;

- (id)initWithContentsController:(UIViewController *)contentsController;

- (void)cancelSearch;
@end
