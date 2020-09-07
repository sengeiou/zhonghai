//
//  KDStatusDataProvider.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-1.
//
//

#import <Foundation/Foundation.h>
#import "KDCommonHeader.h"
#import "KDStatusBaseViewController.h"

typedef void (^statuesCountUpdatingCompletionBlock) ();

@interface KDStatusDataProvider : NSObject
@property(nonatomic,retain)KDStatusDataset *dataSet;
@property(nonatomic,assign)KDStatusBaseViewController *viewController;
//@property(nonatomic,assign)id<KDImageDataSource>imageDataSource; // weak reference
- (id)initWithViewController:(KDStatusBaseViewController *)viewController;
- (void)loadCachedStatus;
- (void)loadLatestStatus;
- (void)loadEarlierStatus;
- (void)loadImageSourceInTableView:(UITableView *)tableView;
- (void)cancleAllNetworkRequest;

- (KDQuery *)latestStatusQuery;
- (KDQuery *)earlierStatusQuery;
// override
- (KDTLStatusType)type;
// override
- (NSString *)actionPath;
// override
- (SEL)statuesSavingSelector;
// override
- (SEL)countingSavingSelector;
// override
- (BOOL)showAccurateGroupName;
// override
- (NSInteger)statueslimits;
// override
- (CGFloat)calculateStatusContentHeight:(KDStatus *)status;
// override
- (UITableViewCell *)timelineStatusCellInTableView:(UITableView *)tableView status:(KDStatus *)status;
- (void)updateUnread;

@end
