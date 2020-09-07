//
//  KDRefreshTableView.m
//  TableViewPull
//
//  Created by shen kuikui on 12-8-22.
//
//

#import <QuartzCore/QuartzCore.h>

#import "KDRefreshTableView.h"
#import "KDRefreshTableViewSideViewTopForiPhone.h"
#import "KDRefreshTableViewSideViewBottomForiPhone.h"
#import "KDRefreshTableViewSideViewTopForiPhone.h"
#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

#define KD_DEFAULT_HEADER_HEIGHT 60.0f
#define KD_DEFAULT_FOOTER_HEIGHT 60.0f

NSString *const KDRefreshTableViewBeginLoadingNotification = @"kd_refresh_table_view_begin_loading_notification_201308141641";
NSString *const KDRefreshTableViewEndLoadingNotification = @"kd_refresh_table_view_end_loading_notification_201308141642";

@interface KDRefreshTableView ()
{
    KDRefreshTableViewType  type_;
    
    UIView<KDRefreshTableViewSideView> *topView_;
    UIView<KDRefreshTableViewSideView> *bottomView_;
}

- (void)setUpHeader;
- (void)setUpFooter;

- (NSDate *)updatedTime;

- (void)layoutFooterView;
@end


@implementation KDRefreshTableView

@dynamic delegate,dataSource;
@synthesize isDoubleLoading = isDoubleLoading_;
@synthesize topView = topView_;
@synthesize shouldKeepOriginalContentInset = shouldKeepOriginalContentInset_;
@synthesize shouldKeepOriginalContentOffset = shouldKeepOriginalContentOffset_;

- (void)dealloc
{
    topView_ = nil;
    bottomView_ = nil;
    
    //[super dealloc];
}

#pragma mark - public methods
- (id)initWithFrame:(CGRect)frame kdRefreshTableViewType:(KDRefreshTableViewType)type style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if(self) {
        type_ = type;
        
        isDoubleLoading_ = NO;
        shouldKeepOriginalContentInset_ = NO;
        shouldKeepOriginalContentOffset_ = NO;
        _showUpdataTime = YES;
        
        //设置头部
        if(type_ & KDRefreshTableViewType_Header){
            [self setUpHeader];
        }
        //设置底部
        if(type_ & KDRefreshTableViewType_Footer){
            [self setUpFooter];
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame kdRefreshTableViewType:(KDRefreshTableViewType)type
{
    return [self initWithFrame:frame kdRefreshTableViewType:type style:UITableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame kdRefreshTableViewType:KDRefreshTableViewType_Both];
}

//isSuccess判断是否加载成功，以决定是否更新上次更新时间
- (void)finishedRefresh:(BOOL)isSuccess
{
    if(isSuccess && [topView_ respondsToSelector:@selector(refreshUpdatedTime:)])
        [topView_ refreshUpdatedTime:[self updatedTime]];
    
    [UIView beginAnimations:@"splash" context:nil];
    [UIView setAnimationDuration:0.35f];
    UIEdgeInsets insets = self.contentInset;
    if(shouldKeepOriginalContentInset_) {
        self.contentInset = UIEdgeInsetsMake(insets.top - [topView_ respondHeight], insets.left, insets.bottom, insets.right);
    }else {
        self.contentInset = UIEdgeInsetsMake(0.0f, insets.left, insets.bottom, insets.right);
    }
    [UIView commitAnimations];
    
    [topView_ setStatus:KDPullRefreshNormal];
    
    [self postEndLoadingNotification];
}

- (void)finishedLoadMore
{
    [UIView beginAnimations:@"splash" context:nil];
    [UIView setAnimationDuration:0.35f];
    UIEdgeInsets inset = self.contentInset;
    if(shouldKeepOriginalContentInset_) {
        self.contentInset = UIEdgeInsetsMake(inset.top, 0.0f, inset.bottom - [bottomView_ respondHeight], 0.0f);
    }else {
        self.contentInset = UIEdgeInsetsMake(inset.top, inset.left, 0.0, inset.right);
    }
    [UIView commitAnimations];
    
    [bottomView_ setStatus:KDPullRefreshNormal];
}

- (void)kdRefreshTableViewDidScroll:(UIScrollView *)scrollView
{
    assert(self == scrollView);
    
    CGFloat offset = scrollView.contentOffset.y;
    
    //offset<0说明是顶部的刷新，否则经过计算确认是否是底部的刷新
    if(offset < 0 && (type_ & KDRefreshTableViewType_Header)){
        offset *= -1;
        
        if(![topView_ isLoading]){
            if(offset >= [topView_ respondHeight])
                [topView_ setStatus:KDPullRefreshPulling];
            else
                [topView_ setStatus:KDPullRefreshNormal];
        }
    }
    else if((type_ & KDRefreshTableViewType_Footer) && !bottomView_.hidden){
        
        if(self.contentSize.height > self.bounds.size.height)
            offset -= (self.contentSize.height - self.bounds.size.height);
        
        if(![bottomView_ isLoading]){
            if(offset >= [bottomView_ respondHeight])
                [bottomView_ setStatus:KDPullRefreshPulling];
            else
                [bottomView_ setStatus:KDPullRefreshNormal];
        }
    }
}

- (void)kdRefreshTableviewDidEndDraging:(UIScrollView *)scrollView
{
    if(!isDoubleLoading_ && ([topView_ isLoading] || [bottomView_ isLoading])) return;
    
    CGFloat offset = scrollView.contentOffset.y;
    
    if(offset < 0 && (type_ & KDRefreshTableViewType_Header)){
        offset *= -1;

        if(![topView_ isLoading]){
            if(offset > [topView_ respondHeight]){
                [topView_ setStatus:KDPullRefreshLoading];
                offset = [topView_ respondHeight];
                
                if([self.delegate respondsToSelector:@selector(kdRefresheTableViewReload:)]) {
                    [self.delegate kdRefresheTableViewReload:self];
                    [self postBeginLoadingNotification];
                }
                
                //以免上下同时加载时，会把对方隐藏掉，下同
                [UIView animateWithDuration:0.35f animations:^{
                    UIEdgeInsets insets = scrollView.contentInset;
                    if(shouldKeepOriginalContentInset_) {
                        scrollView.contentInset = UIEdgeInsetsMake(offset + insets.top, insets.left, insets.bottom, insets.right);
                    }else {
                        scrollView.contentInset = UIEdgeInsetsMake(offset, insets.left, insets.bottom, insets.right);
                    }
                }];
            }else
                [topView_ setStatus:KDPullRefreshNormal];
        }
    }
    else if((type_ & KDRefreshTableViewType_Footer) && !bottomView_.hidden){
        if(self.contentSize.height > self.bounds.size.height)
            offset -= (self.contentSize.height - self.bounds.size.height);
        
        if(![bottomView_ isLoading]){
            if(offset >= [bottomView_ respondHeight]){
                [bottomView_ setStatus:KDPullRefreshLoading];
                
                offset = [bottomView_ respondHeight];
                
                if(self.contentSize.height < self.bounds.size.height)
                    offset -= (self.contentSize.height - self.bounds.size.height);
                
                if([self.delegate respondsToSelector:@selector(kdRefresheTableViewLoadMore:)])
                    [self.delegate kdRefresheTableViewLoadMore:self];
                
                [UIView animateWithDuration:0.35f animations:^{
                    UIEdgeInsets insets = scrollView.contentInset;
                    if(shouldKeepOriginalContentInset_) {
                        scrollView.contentInset = UIEdgeInsetsMake(insets.top, insets.left, offset + insets.bottom, insets.right);
                    }else {
                        scrollView.contentInset = UIEdgeInsetsMake(insets.top, insets.left, offset, insets.right);
                    }
                }];
            }else{
                [bottomView_ setStatus:KDPullRefreshNormal];
            }
        }
    }
}

- (void)setBottomViewHidden:(BOOL)isHidden {
    if(bottomView_)
        [bottomView_ setHidden:isHidden];
}

- (void)setFirstInLoadingState
{
    if(topView_){
        if(self.dataSource && [self.dataSource respondsToSelector:@selector(kdRefresheTableViewLastUpdatedDate:)]) {
            [topView_ refreshUpdatedTime:[self.dataSource kdRefresheTableViewLastUpdatedDate:self]];
            [self postBeginLoadingNotification];
        }
        [topView_ setStatus:KDPullRefreshLoading];
        
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:.35f];
        if(shouldKeepOriginalContentOffset_) {
            self.contentOffset = CGPointMake(self.contentOffset.x, -1 * [topView_ respondHeight] + self.contentOffset.y);
        }else {
            self.contentOffset = CGPointMake(self.contentOffset.x, -1 * [topView_ respondHeight]);
        }
        if(shouldKeepOriginalContentInset_) {
            self.contentInset = UIEdgeInsetsMake([topView_ respondHeight] + self.contentInset.top, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
        }else {
            self.contentInset = UIEdgeInsetsMake([topView_ respondHeight], self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
        }
        [UIView commitAnimations];
    }
}

- (BOOL)isLoading
{
    BOOL isLoading = NO;
    
    if(topView_)
        isLoading = isLoading || [topView_ isLoading];
    if(bottomView_)
        isLoading = isLoading || [bottomView_ isLoading];
    
    return isLoading;
}

- (void)setTopView:(UIView<KDRefreshTableViewSideView> *)nTopView
{
    if(!nTopView || nTopView == topView_) return;
    
    [topView_ removeFromSuperview];
    topView_ = nTopView;
    
    CGRect frame = topView_.frame;
    topView_.frame = CGRectMake( 0.0f, -frame.size.height, frame.size.width, frame.size.height);
    [topView_ setStatus:KDPullRefreshNormal];
    
    if([topView_ respondsToSelector:@selector(refreshUpdatedTime:)])
        [topView_ refreshUpdatedTime:nil];
    
    [self addSubview:topView_];
}

- (void)setBottomView:(UIView<KDRefreshTableViewSideView> *)nBottomView
{
    if(!nBottomView || nBottomView == bottomView_) return;
    
    [bottomView_ removeFromSuperview];
    bottomView_ = nBottomView;
    [bottomView_ setStatus:KDPullRefreshNormal];
    
    [self addSubview:bottomView_];
}

#pragma mark - private methods
//构建头部的刷新组件
- (void)setUpHeader
{
    NSString  *className = [UIDevice isiPadDevice]?@"KDRefreshTableViewSideViewTopForiPad":@"KDRefreshTableViewSideViewTopForiPhone";
    Class clazz = NSClassFromString(className);
    [self setTopView:[[clazz alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)]];// autorelease]];
}

//构建底部的刷新组件
- (void)setUpFooter
{
    [self setBottomView:[[KDRefreshTableViewSideViewBottomForiPhone alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)]];

}

- (void)postBeginLoadingNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KDRefreshTableViewBeginLoadingNotification object:nil];
}

- (void)postEndLoadingNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KDRefreshTableViewEndLoadingNotification object:nil];
}

- (NSDate *)updatedTime
{
    NSDate *resultDate = nil;
    
    if([self.dataSource respondsToSelector:@selector(kdRefresheTableViewLastUpdatedDate:)])
        resultDate = [self.dataSource kdRefresheTableViewLastUpdatedDate:self];
   
    if(!resultDate)
        resultDate = [NSDate date];
    
    return resultDate;
}

- (void)layoutFooterView
{
    CGRect nFrame = CGRectMake(0.0f, MAX(self.contentSize.height, self.bounds.size.height), self.bounds.size.width, bottomView_.frame.size.height);
    
    if(!CGRectEqualToRect(bottomView_.frame, nFrame))
        bottomView_.frame = nFrame;
}

//delegate and dataSource
- (void)setDataSource:(id<KDRefreshTableViewDataSource>)dataSource
{
    super.dataSource = dataSource;
}

- (id<KDRefreshTableViewDataSource>)dataSource
{
    return (id<KDRefreshTableViewDataSource>)super.dataSource;
}

- (void)setDelegate:(id<KDRefreshTableViewDelegate>)delegate
{
    super.delegate = delegate;
}

- (id<KDRefreshTableViewDelegate>)delegate
{
    return (id<KDRefreshTableViewDelegate>)super.delegate;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(type_ & KDRefreshTableViewType_Footer)
        [self layoutFooterView];
}

- (void)shouldShowNoDataTipView:(BOOL)should {
    if (should) {
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 80)];
        
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textColor = [UIColor darkGrayColor];
        infoLabel.font = [UIFont systemFontOfSize:15.0];
        infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        
        infoLabel.text = ASLocalizedString(@"No_Data_Refresh");
        
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tableFooterView = infoLabel;
//        [infoLabel release];

    }else {
        self.tableFooterView = nil;
    }
   
}

- (void)setShowUpdataTime:(BOOL)showUpdataTime
{
    _showUpdataTime = showUpdataTime;
    ((KDRefreshTableViewSideViewTopForiPhone *)self.topView).showUpdataTime = self.showUpdataTime;
}

@end
