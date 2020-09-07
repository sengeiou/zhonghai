//
//  FriendsTimelineController.h
//  kdweibo
//
//

#import <UIKit/UIKit.h>
#import "KDCommon.h"

#import "KDTabBarViewControllerInteraction.h"

#import "FriendsTimelineDataSource.h"
#import "KDStatusTimelineProvider.h"

#import "EGORefreshTableHeaderView.h"
#import "RefreshTableFootView.h"

#import "KDMenuView.h"
//#import "KDTimelineDropDownView.h"

#import "KDRequestWrapper.h"

#import "KDSession.h"
#import "KDManagerContext.h"

#import "KDRefreshTableView.h"

#import "PostViewController.h"

extern const char* extrainfo;

@interface FriendsTimelineController : UIViewController <KDRefreshTableViewDataSource,KDRefreshTableViewDelegate, KDRequestWrapperDelegate> {
   @private
    
    UIView *teamTipsView_;
    
    struct {
        unsigned int showingNewMessagesPromptView:1;
        unsigned int didReceiveMemoryWarning:1;
        unsigned int loadStatusesOnFirstEnterStage:1;
        unsigned int shouldRefresh:1;
        unsigned int shouldReloadDataSourceWhenLayoutDidChange:1;
        unsigned int shouldReloadTableData:1;
        unsigned int shouldShowNoDataTipsView:1;
        
        unsigned int hasRequests:1;
        unsigned int isSearching:1;
    }_timelineFlags;
    
}

@property(nonatomic, retain) KDRefreshTableView *tableView;
//@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, assign) BOOL hasFooterView;
@property(nonatomic, assign) KDTLStatusType timelineType;
@property(nonatomic, retain)NSCache *cellCache;
// public methods
- (void)restoreStatus;
- (void)initRefreshTableView;
- (void)finishLoadMore;
- (void)finishRefreshed:(BOOL)isSuccessful;
- (void)reloadTableView;
//- (void)shouldShowNoDataTipsView:(BOOL)isShould;
- (void)removeKDWeiboPlaceholderView;
- (void)showPrompView:(NSInteger)count;
- (void)removeAllCellCache;
- (void)shouldShowBlankHolderView:(BOOL)should;
- (void)reload;
- (void)showTipsOrNot;
@end
