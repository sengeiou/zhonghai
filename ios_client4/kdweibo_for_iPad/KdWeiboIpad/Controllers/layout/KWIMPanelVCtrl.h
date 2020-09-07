//
//  KWIMPanelVCtrl.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/16/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWIMPanelVCtrl : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
@protected
    BOOL isLoadMore_;
}

@property (retain, nonatomic) UITableView *tableView;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic) NSUInteger pagesize;
@property (assign, nonatomic) BOOL isLoading;
@property (retain, nonatomic, readonly) UIView *emptyV;

- (void)_afterRefresh;
- (void)_afterLoadmore;

- (void)_enableLoadmore;
- (void)_disableLoadmore;
- (void)_setNomore;

- (void)scrollToTop;

@end
