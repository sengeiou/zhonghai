//
//  KDRefreshTableView.h
//  TableViewPull
//
//  Created by shen kuikui on 12-8-22.
//
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableViewSideView.h"

typedef enum
{
    KDRefreshTableViewType_None   = 0x00,
    KDRefreshTableViewType_Header = 0x01,
    KDRefreshTableViewType_Footer = 0x01 << 1,
    KDRefreshTableViewType_Both   = 0x03
}KDRefreshTableViewType;

typedef enum
{
    KDRefreshTableViewPosition_Header = 0x00,
    KDRefreshTableViewPosition_Header_Title ,
    KDRefreshTableViewPosition_Header_UpdatedTime ,
    
    KDRefreshTableViewPosition_Footer ,
    KDRefreshTableViewPosition_Footer_Title
}KDRefreshTableViewPosition;

#define KD_REFRESHTABLEVIEW_STATE_NORMAL  @"KDRefreshTableViewStateNormal"
#define KD_REFRESHTABLEVIEW_STATE_PULL    @"KDRefreshTableViewStatePull"
#define KD_REFRESHTABLEVIEW_STATE_LOADING @"KDRefreshTableViewStateLoading"

#define KDREFRESHTABLEVIEW_REFRESHDATE \
\
- (NSDate *)kdRefresheTableViewLastUpdatedDate:(KDRefreshTableView *)kdRefreshTableView {\
NSDictionary *refreshDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kdweibo_refresh_date"];\
NSDate *date = [refreshDate objectForKey:NSStringFromClass([self class])];\
\
NSMutableDictionary *refreshDateNew = [NSMutableDictionary dictionaryWithDictionary:refreshDate];\
[refreshDateNew setObject:[NSDate date] forKey:NSStringFromClass([self class])];\
\
[[NSUserDefaults standardUserDefaults] setObject:refreshDateNew forKey:@"kdweibo_refresh_date"];\
\
return date;\
}

UIKIT_EXTERN NSString *const KDRefreshTableViewBeginLoadingNotification;
UIKIT_EXTERN NSString *const KDRefreshTableViewEndLoadingNotification;

@class KDRefreshTableView;

@protocol KDRefreshTableViewDataSource <UITableViewDataSource>

@optional

//实现此方法来设置”更新时间“
//如果不实现，“更新时间”始终为最新时间
//建议实现此方法
- (NSDate *)kdRefresheTableViewLastUpdatedDate:(KDRefreshTableView *)kdRefreshTableView;

@end

@protocol KDRefreshTableViewDelegate <UITableViewDelegate>
@optional

- (void)kdRefresheTableViewReload:(KDRefreshTableView *)refreshTableView;
- (void)kdRefresheTableViewLoadMore:(KDRefreshTableView *)refreshTableView;

@end

 
@interface KDRefreshTableView : UITableView
{
    
}

@property (nonatomic, assign) id<KDRefreshTableViewDataSource> dataSource;
@property (nonatomic, assign) id<KDRefreshTableViewDelegate> delegate;
@property (nonatomic, retain) UIView<KDRefreshTableViewSideView> *topView;

@property (nonatomic, assign) BOOL isDoubleLoading;

@property (nonatomic, assign) BOOL shouldKeepOriginalContentInset;
@property (nonatomic, assign) BOOL shouldKeepOriginalContentOffset;

- (void)setBottomView:(UIView<KDRefreshTableViewSideView> *)nBottomView;


//public methods

///这是你应该用来初始化的方法
//method to init this tableview
- (id)initWithFrame:(CGRect)frame kdRefreshTableViewType:(KDRefreshTableViewType)type style:(UITableViewStyle)style;
//默认style为UITableViewStylePlain;
- (id)initWithFrame:(CGRect)frame kdRefreshTableViewType:(KDRefreshTableViewType)type;
//默认type为both，style为plain;
- (id)initWithFrame:(CGRect)frame;

//刷新完成后应该调用的方法
//isSuccess表示是否刷新成功。
//send this message after refresh data,'isSuccess' means whether load success
- (void)finishedRefresh:(BOOL)isSuccess;

//加载完成后应该调用的方法
//！！！注意：此方法会刷新TableView，故客户端代码可不调用reloadData。
//send this message after load more data
- (void)finishedLoadMore;

//在收到UIScrollView的delegate方法'scrollViewDidScroll:'时调用此方法。
//send this message when get UIScrollview's delegate method 'scrollViewDidScroll:'
- (void)kdRefreshTableViewDidScroll:(UIScrollView *)scrollView;

//在收到UIScrollView的delegate方法'scrollViewDidEndDragging:'时调用此方法。
//send this message when get UIScrollView's delegate method 'scrollViewDidEndDragging:'
- (void)kdRefreshTableviewDidEndDraging:(UIScrollView *)scrollView;

//设置是否要显示BottomView
- (void)setBottomViewHidden:(BOOL)isHidden;
//只能被调用一次
- (void)setFirstInLoadingState;

- (BOOL)isLoading;

- (void)shouldShowNoDataTipView:(BOOL)should;

//是否显示更新时间
@property (nonatomic, assign) BOOL showUpdataTime;

@end
