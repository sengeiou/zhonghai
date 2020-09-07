//
//  KDLocationOptionSearchBar.h
//  kdweibo
//
//  Created by shifking on 15/11/10.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KDSearchBarDidSelectResultBlock)(NSObject *object , NSIndexPath *index);

@interface KDLocationOptionSearchBar : NSObject

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) UISearchDisplayController *searchDisplayController;

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSArray *sourceData; // 搜索POI失败的时候才会在此数组里匹配
@property (nonatomic, strong) KDSearchBarDidSelectResultBlock selectedBlock;

- (id)initWithContentsController:(UIViewController *)contentsController locationData:(KDLocationData *)locationData;

@end
