//
//  KWIMPanelVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/16/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMPanelVCtrl.h"

#import "EGORefreshTableHeaderView.h"
#import "KDRefreshTableView.h"
#import "NSError+KWIExt.h"
#import "KWILoadMoreVCtrl.h"

@interface KWIMPanelVCtrl () <EGORefreshTableHeaderDelegate,KDRefreshTableViewDataSource,KDRefreshTableViewDelegate>

@property (retain, nonatomic) KWILoadMoreVCtrl *loadmoreVCtrl;

@end

@implementation KWIMPanelVCtrl
{
    EGORefreshTableHeaderView *_refreshHeaderV;
}

@synthesize data = _data;
@synthesize pagesize = _pagesize;
@synthesize loadmoreVCtrl = _loadmoreVCtrl;
@synthesize tableView = _tableView;
@synthesize isLoading = _isLoading;
@synthesize emptyV = _emptyV;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isLoadMore_ = NO;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
//    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    //self.tableView.layer.cornerRadius = 12;
//    //self.tableView.clipsToBounds = YES;
//    [self.view addSubview:self.tableView];    
    KDRefreshTableView *aTableView = [[KDRefreshTableView alloc] initWithFrame:self.view.bounds
                                                        kdRefreshTableViewType:KDRefreshTableViewType_Both
                                                                         style:UITableViewStylePlain];
    
    
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    aTableView.backgroundColor = [UIColor whiteColor];
    aTableView.separatorColor = [UIColor clearColor];
    self.tableView = aTableView;
    [aTableView release];
    
    //self.tableView.separatorColor = [UIColor colorWithRed:213.0/255 green:209.0/255 blue:188.0/255 alpha:1];
    
    _refreshHeaderV = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshHeaderV.delegate = self;
    [self.tableView addSubview:_refreshHeaderV];
    
    self.data = [NSArray array];
    self.pagesize = 20;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_data release];
    [_loadmoreVCtrl release];
    [_refreshHeaderV release];
    [_emptyV release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:@"UnimplementedException" 
                                   reason:@"[KWIMPanelVCtrl cellForRowAtIndexPath] must be override in subclass" 
                                 userInfo:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderV egoRefreshScrollViewDidScroll:scrollView];    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderV egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat height = scrollView.contentSize.height;
    
    if ((1000 > (height - offset)) && self.loadmoreVCtrl.isAvailable) {
        [self.loadmoreVCtrl trigger];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if(!_isLoading) {
        [self _refresh];
        _isLoading = YES;
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];     
}

#pragma mark -
- (void)_refresh
{
    @throw [NSException exceptionWithName:@"UnimplementedException" 
                                   reason:@"[KWIMPanelVCtrl _refresh] must be override in subclass" 
                                 userInfo:nil];
}

- (void)_loadmore
{
    @throw [NSException exceptionWithName:@"UnimplementedException" 
                                   reason:@"[KWIMPanelVCtrl _loadmore] must be override in subclass" 
                                 userInfo:nil];
}

#pragma mark -
//- (BOOL)_beforeRefresh
//{
//    if ([self _beforeLoading]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (BOOL)_beforeLoadmore
//{
//    if ([self _beforeLoading]) {
//        _isLoading = YES;
//        return YES;
//    } else {
//        return NO;
//    }
//}

//- (BOOL)_beforeLoading
//{
//    return !_isLoading;
//}

- (void)_afterRefresh
{
    [self _afterLoading];
    [_refreshHeaderV egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    if (0 == [self.tableView numberOfRowsInSection:0]) {
        self.emptyV.frame = [self _getEmptyVFrame];
        [self.view addSubview:self.emptyV];
    }
}

- (void)_afterLoadmore
{
    [self _afterLoading];
    if ([self.loadmoreVCtrl isAvailable]) {
        [self.loadmoreVCtrl setStateDefault];
    }
}

- (void)_afterLoading
{
    _isLoading = NO;
}

- (void)_enableLoadmore
{
    if (nil == self.loadmoreVCtrl) {
        self.loadmoreVCtrl = [KWILoadMoreVCtrl vctrl];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(_loadmore) 
                                                     name:@"KWILoadMoreVCtrl.load" 
                                                   object:self.loadmoreVCtrl];
    }
    self.tableView.tableFooterView = self.loadmoreVCtrl.view;
    [self.loadmoreVCtrl setStateDefault];
}

- (void)_disableLoadmore
{
    self.tableView.tableFooterView = nil;
}

- (void)_setNomore
{
    [self.loadmoreVCtrl setStateNoMore];
}

- (void)scrollToTop
{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    if (!_isLoading) {
        [self _refresh];
        _isLoading = YES;
    }
}

#pragma mark - empty view
- (UIView *)emptyV
{
    if (!_emptyV) {
        _emptyV = [[UIView alloc] initWithFrame:[self _getEmptyVFrame]];
        _emptyV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _emptyV.backgroundColor = [UIColor clearColor];
        //_emptyV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        
        if ([self emptyImageName]) {
            UIImageView *imgV = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[self emptyImageName]]] autorelease];
            CGRect imgFrm = imgV.frame;
            //imgFrm.origin.y = 0;
            imgFrm.origin.x = (CGRectGetWidth(_emptyV.bounds) - CGRectGetWidth(imgFrm)) / 2;
            imgV.frame = imgFrm;
            imgV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [_emptyV addSubview:imgV];
        }
        
        if ([self emptyTextPartial]) {
            UILabel *emptyTextV = [[[UILabel alloc] initWithFrame:CGRectMake(0, 120, CGRectGetWidth(_emptyV.bounds), 40)] autorelease];
            emptyTextV.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            emptyTextV.backgroundColor = [UIColor clearColor];
            //emptyTextV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            emptyTextV.textAlignment = UITextAlignmentCenter;
            emptyTextV.textColor = [UIColor colorWithHexString:@"666"];
            emptyTextV.font = [UIFont fontWithName:@"STHeitiSC-Light" size:18];
            //emptyTextV.shadowColor = [UIColor darkGrayColor];
            //emptyTextV.shadowOffset = CGSizeMake(0.5, 0.5);
            emptyTextV.text = [NSString stringWithFormat:@"你还没有收到任何%@", [self emptyTextPartial]];
            [_emptyV addSubview:emptyTextV];
        }
    }
    
    return _emptyV;
}

- (CGRect)_getEmptyVFrame
{
    NSUInteger height = 160;
    NSUInteger y = CGRectGetMaxY(self.tableView.frame) - CGRectGetHeight(self.tableView.frame) * 0.618 - height / 2;
    return CGRectMake(0, y, CGRectGetWidth(self.view.bounds), height);
}

- (NSString *)emptyImageName
{
    return nil;
}

- (NSString *)emptyTextPartial
{
    return nil;
}

//- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
//    dispatch_block_t block = ^{
//        [self.tableView reloadData];
//        
//        if(isLoadMore_)
//            [self _afterLoadmore];
//        else
//            [self _afterRefresh];
//        
//        if(userInfo && self.data > 0) {
//            if([[userInfo objectForKey:KDWeiBoCoreUserInfoKey_TimeLineHasMore] boolValue])
//                [self _enableLoadmore];
//            else
//                [self _disableLoadmore];
//        }
//        
//        if(self.data.count == 0)
//            [self _disableLoadmore];
//        
//        if(self.data.count == 0)
//            [self.view addSubview:self.emptyV];
//        else
//            [self.emptyV removeFromSuperview];
//        
//        if(error) {
//            [error KWIGeneralProcess];
//        }
//    };
//    
//    dispatch_async(dispatch_get_main_queue(), block);
//}
@end
