//
//  KDStatusBaseViewController.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-1.
//
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableView.h"
#import "KDWeiboServices.h"
#import "KDStatus.h"
@class KDStatusDataProvider;
@interface KDStatusBaseViewController : UIViewController<KDRefreshTableViewDataSource,KDRefreshTableViewDelegate,KDRequestWrapperDelegate> {
    KDRefreshTableView *tableView_;
    KDStatusDataProvider *dataProvider_;
    KDStatus  *selectStatus_;
    BOOL haveMore_;
    struct {
        unsigned int initDataProvider:1;
        unsigned int shouldLoadFromLocal:1;
        unsigned int shouldRefresh:1;
        unsigned int viewDidUnload:1;
    }flags_;
    NSArray *dataSourceArray_;
}

@property(nonatomic, retain) KDRefreshTableView *tableView;
@property(nonatomic, retain) KDStatusDataProvider *dataProvider;
@property(nonatomic, retain) KDStatus  *selectStatus;
@property(nonatomic, assign) BOOL  haveMore;
@property(nonatomic, retain) NSArray *dataSourceArray;
@property(nonatomic, assign) BOOL haveFootView;
@property(nonatomic, retain)  NSCache *cellCache;

- (void)shouldShowBlankHolderView:(BOOL)should;
- (void)displayError:(NSString *)errorString;
- (void)setFirstInLoadingState;
- (void)showPrompView:(NSInteger)count;
- (void)finishRefreshed:(BOOL)isSuccessful;
- (void)finishLoadMore;
- (void)shouldShowNoDataTipsView:(BOOL)isShould;
- (void)reloadTableView;
- (void)reloadCurrentDataSource;
- (UITableViewCell *)loadCellForStatus:(KDStatus *)status;
//override
- (void)initWithDataProvider;
- (void)cellSelected;

@end


