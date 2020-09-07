//
//  KDSignPointPoiSearch.h
//  officialDemo2D
//
//  Created by lichao_liu on 15/3/6.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@protocol KDSignInPointSearchDelegate <NSObject>

- (void)searchResultDidSelectedWithAMapTip:(AMapGeocode *)geocode;

@end

@interface KDSignPointPoiSearch : NSObject

@property(nonatomic, strong, readonly) UISearchBar *searchBar;
@property(nonatomic, strong, readonly) UISearchDisplayController *searchDisplayController;
@property(nonatomic, strong) NSMutableArray *results;
@property(nonatomic, assign) id <KDSignInPointSearchDelegate> signInPointSearchDelegate;

- (id)initWithContentsController:(UIViewController *)contentsController;

- (void)showSearchBar;

@end
