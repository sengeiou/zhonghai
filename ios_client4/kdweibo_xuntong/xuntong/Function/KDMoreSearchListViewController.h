//
//  KDMoreSearchListViewController.h
//  kdweibo
//
//  Created by sevli on 15/8/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSearchCommon.h"

@protocol KDMoreSearchListViewControllerDelegate;

@interface KDMoreSearchListViewController : UIViewController

@property (nonatomic, copy) NSString *searchWord;

@property (nonatomic, assign) KDSearchType searchType;

@property (nonatomic, strong)id<KDMoreSearchListViewControllerDelegate>delegate;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@protocol KDMoreSearchListViewControllerDelegate <NSObject>

- (void)closeSearchUserInterface;

@end