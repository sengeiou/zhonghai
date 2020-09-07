//
//  KDVoteView.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteView.h"
#import "KDManagerContext.h"
#import "KDVoteOption.h"

#import "UIViewAdditions.h"

@interface KDVoteView()

@property(retain,nonatomic) KDVoteTitleView *voteTitleView;
@property(retain,nonatomic) UITableView *tableView;
@property(retain,nonatomic) UIImageView *toolBarImageView;
@property(retain,nonatomic) UIButton *refresh;
@property(retain,nonatomic) UIButton *voteBtn;
@property(retain,nonatomic) KDVoteCellHeadView * voteCellHeadView;
@property(retain,nonatomic) KDVote *vote;
@property(assign,nonatomic) NSInteger totalNumberOfVotes;
@property(retain,nonatomic) NSMutableArray *tempOwnItemIdList;
@property(retain,nonatomic) UIView *voteAndRefreshActionBg;
@property(retain,nonatomic) KDVoteViewLayoutInfo * voteViewLayoutInfo;

- (void)refreshAction:(id)sender;
//- (IBAction)refreshTouchDown:(id)sender;
//- (IBAction)refreshTouchUpOutSide:(id)sender;

- (void)voteAction:(id)sender;
//- (IBAction)voteTouchDown:(id)sender;
//- (IBAction)voteTouchUpOutSide:(id)sender;

@end
@implementation KDVoteView
@synthesize voteTitleView = _voteTitleView;
@synthesize tableView = _tableView;
@synthesize toolBarImageView = _toolBarImageView;
@synthesize refresh = _refresh;
@synthesize voteBtn = _voteBtn;
@synthesize voteCellHeadView = _voteCellHeadView;
@synthesize delegate = delegate_;
@synthesize vote = vote_;
@synthesize totalNumberOfVotes = totalNumberOfVotes_;
@synthesize tempOwnItemIdList = tempOwnItemIdList_;
@synthesize voteAndRefreshActionBg = voteAndRefreshActionBg_;
@synthesize voteViewLayoutInfo = voteViewLayoutInfo_;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(_voteTitleView);
    //KD_RELEASE_SAFELY(_tableView);
    //KD_RELEASE_SAFELY(_toolBarImageView);
    //KD_RELEASE_SAFELY(_refresh);
    //KD_RELEASE_SAFELY(_voteBtn);
    //KD_RELEASE_SAFELY(_voteCellHeadView);
    //KD_RELEASE_SAFELY(vote_);
    //KD_RELEASE_SAFELY(tempOwnItemIdList_);
    //KD_RELEASE_SAFELY(voteAndRefreshActionBg_);
    //KD_RELEASE_SAFELY(voteViewLayoutInfo_);
    
    //[super dealloc];
}


- (id)init{
    self = [super init];
    if (self) {
        
        [self addSubview:self.voteTitleView];
        [self.voteTitleView makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.and.left.and.right.equalTo(self);
             make.height.mas_equalTo(100);
         }];

        
        
        [self addSubview:self.toolBarImageView];
        [self.toolBarImageView makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.and.bottom.equalTo(self);
             make.height.mas_equalTo(50);
         }];
        
        [self.toolBarImageView addSubview:self.voteBtn];
        [self.voteBtn makeConstraints:^(MASConstraintMaker *make)
         {
             make.center.equalTo(self.toolBarImageView);
             make.top.and.bottom.equalTo(self.toolBarImageView).with.insets(UIEdgeInsetsMake(8, 0, 8, 0));
             make.width.mas_equalTo(80);
         }];
        
        [self.toolBarImageView addSubview:self.refresh];
        [self.refresh makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(self.toolBarImageView.mas_centerX).with.offset(-ScreenFullWidth / 4);
             make.top.and.bottom.equalTo(self.toolBarImageView).with.insets(UIEdgeInsetsMake(8, 0, 8, 0));
             make.width.mas_equalTo(80);
         }];
        
        [self addSubview:self.tableView];
        [self.tableView makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.equalTo(self);
             make.top.equalTo(self.voteTitleView.mas_bottom);
             make.bottom.equalTo(self.toolBarImageView.mas_top);
         }];
    }
    return self;
}

//check if the creater is me
-(BOOL)isMeTheVoteCreater
{
    if (vote_ == nil || vote_.author.userId == nil ) {
        return NO;
    }
    
    return [KDUser isCurrentSignedUserWithId:vote_.author.userId];
}

//check if it has been vote by my self
-(BOOL)isHasBeenVoteByMyself
{
    if (vote_.selectedOptionIDs == nil || [vote_.selectedOptionIDs count] == 0) {
        return NO;
    }
    return YES;
}


-(void)setVote:(KDVote *)vote {
    if (vote_ != vote) {
//        [vote_ release];
        vote_ = vote;// retain];
    }
}
-(BOOL)isVoteEnd
{
    return vote_.isEnded;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

-(void)setVoteButtonCenter:(BOOL)isCenter
{
    if (isCenter) {
        [self.refresh setHidden:YES];
        [_voteBtn setCenterX:ScreenFullWidth / 2 ];
    }
    else {
        [self.refresh setHidden:NO];
        [_voteBtn setCenterX:ScreenFullWidth *  3/4];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // set original talble height
    static CGFloat originalTableHeight;
    if (originalTableHeight == 0) {
        originalTableHeight = self.bounds.size.height - 163;
    }
    //
    
    if ([self isVoteEnd]) {
        [self.toolBarImageView setHidden:YES];
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y , self.tableView.frame.size.width, CGRectGetHeight(self.tableView.frame) + 50);
    }
    else
    {
        
        //        [self.voteAndRefreshActionBg setHidden:NO];
        //        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, originalTableHeight);
        //
        //        if(![self isHasBeenVoteByMyself])
        //        {
        //            [voteBtn_ setTitle:@"投票" forState:UIControlStateNormal];
        //        }
        //        else {
        //            [voteBtn_ setTitle:@"重新投票" forState:UIControlStateNormal];
        //        }
        
        
        //是否能重新投票
        //        if( (self.tempOwnItemIdList == nil || [self.tempOwnItemIdList count] == 0 ) && vote_.canRevote) {
        
        [self.toolBarImageView setHidden:NO];
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y , self.tableView.frame.size.width, ScreenFullHeight - 144 -54);
        if(![self isHasBeenVoteByMyself])
        {
            [_voteBtn setTitle:ASLocalizedString(@"KDStatusHeaderView_voteIndicator") forState:UIControlStateNormal];
        }
        else
        {
            if (vote_.canRevote)
            {
                [_voteBtn setTitle:ASLocalizedString(@"KDVoteView_Vote_Again") forState:UIControlStateNormal];
            }
            else
            {
                [self.voteAndRefreshActionBg setHidden:YES];
//            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, ScreenFullHeight - 144 -54);
                
                [self.voteBtn setTitle:ASLocalizedString(@"KDVoteView_Voted") forState:UIControlStateNormal];
                self.voteBtn.enabled = NO;
            }
            
        }
        //            [self.voteAndRefreshActionBg setHidden:NO];
        //        }
        //        else
        //            [self.voteAndRefreshActionBg setHidden:YES];
        
        
        
    }
    
    if ([self isHasBeenVoteByMyself]) {
        [self setVoteButtonCenter:NO];
    }
    else {
        [self setVoteButtonCenter:YES];
    }
    self.tableView.allowsSelection = self.voteViewLayoutInfo.isEditing;
}

- (void)setUpTotalNumberOfVotes
{
    NSInteger tempCount = 0;
    for (KDVoteOption * vp in vote_.voteOptions) {
        tempCount += vp.count;
    }
    self.totalNumberOfVotes = tempCount;
}

//use this method to reload data to refresh the view
-(void)reloadData
{
    self.vote = [self.delegate kDVoteViewGetVoteData:self];
    //tempOwnItemIdList 在投票操作中动态的
    //ownItemIdList  在整个投票全程都是静态的
    self.tempOwnItemIdList =[NSMutableArray arrayWithArray:self.vote.selectedOptionIDs];
    self.voteTitleView.vote = vote_;
    [self setUpTotalNumberOfVotes];
    //[self setUpEditStatue];
    self.voteViewLayoutInfo = [[KDVoteViewLayoutInfo alloc] init] ;//autorelease];
    
    if ([self isVoteEnd] )
    {
        //vote end
        self.voteViewLayoutInfo.isEditing = NO;
        self.voteViewLayoutInfo.tableViewHeadTitle = VOTE_HAS_ENDED;
        self.voteViewLayoutInfo.isShowVotePercent = YES;
        
        //        if ([self isHasBeenVoteByMyself])
        //        {
        //            //me vote
        //            self.voteViewLayoutInfo.isShowVotePercent = YES;
        //        }
        //        else
        //        {
        //            //me not vote
        //            self.voteViewLayoutInfo.isShowVotePercent = NO;
        //        }
        
    }
    else
    {
        //not end
        if ([self isMeTheVoteCreater])
        {
            //me the creater
            if ([self isHasBeenVoteByMyself])
            {
                //me vote
                self.voteViewLayoutInfo.isEditing = NO;
                self.voteViewLayoutInfo.tableViewHeadTitle = nil;
                self.voteViewLayoutInfo.isShowVotePercent = YES;
            }
            else
            {
                //me not vote
                self.voteViewLayoutInfo.isEditing = YES;
                self.voteViewLayoutInfo.tableViewHeadTitle = nil;
                self.voteViewLayoutInfo.isShowVotePercent = YES;
            }
        }
        else
        {
            //me not the creater
            if ([self  isHasBeenVoteByMyself])
            {
                //me vote
                self.voteViewLayoutInfo.isEditing = NO;
                self.voteViewLayoutInfo.tableViewHeadTitle = nil;
                self.voteViewLayoutInfo.isShowVotePercent = YES;
            }
            else
            {
                //me not vote
                self.voteViewLayoutInfo.isEditing = YES;
                self.voteViewLayoutInfo.tableViewHeadTitle = RESULT_CAN_BE_SEE_ONLY_VOTE_BY_MYSELF;
                self.voteViewLayoutInfo.isShowVotePercent = NO;
            }
        }
    }
    
    [self.voteTitleView setNeedsLayout];
    [self.tableView reloadData];
    [self setNeedsLayout];
    
}


-(void)refreshAction:(id)sender
{
    [self.refresh setBackgroundColor:RGBCOLOR(32, 192, 0)];
    [self.delegate KDVoteViewRefreshActionWith:self];
}

-(void)voteAction:(id)sender
{
    // 设置了不能重复投票，已投票，就不能再投
    if ([self isHasBeenVoteByMyself] && !self.vote.canRevote) {
        return;
    }
    
    self.voteBtn.backgroundColor = RGBCOLOR(23, 131, 253);
    if (self.voteViewLayoutInfo.isEditing)
    {
        if (self.tempOwnItemIdList == nil || [self.tempOwnItemIdList count] == 0 )
        {
            //if nothing has been select,cancle vote action
            [[KDWeiboAppDelegate getAppDelegate] alert:nil message:ASLocalizedString(@"KDVoteView_Vote_Select")];
            return;
        }
        else if ([self.tempOwnItemIdList count] < vote_.minVoteItemCount || [self.tempOwnItemIdList count] > vote_.maxVoteItemCount)
        {
            [[KDWeiboAppDelegate getAppDelegate] alert:nil message:[NSString stringWithFormat:ASLocalizedString(@"KDVoteView_Tips"),(long)vote_.minVoteItemCount,(long)vote_.maxVoteItemCount]];
            return;
            
        }
        
        [self.delegate KDVoteViewRefreshVoteActionWith:self voteItmeIdList:self.tempOwnItemIdList];
        // vote action
    }
    else
    {
        //do not thing
    }
    self.voteViewLayoutInfo.isEditing = !self.voteViewLayoutInfo.isEditing;
    
    if (!self.vote.canRevote) {
        [self.voteBtn setTitle:ASLocalizedString(@"KDVoteView_Voted") forState:UIControlStateNormal];
        self.voteBtn.enabled = NO;
    }
    
    [self setNeedsLayout];
    [self.tableView reloadData];
    
}
- (void)disableButtons {
    self.refresh.enabled = NO;
    _voteBtn.enabled = NO;
    
}

- (void)enableButtons {
    self.refresh.enabled = YES;
    _voteBtn.enabled = YES;
    
}

#pragma mark UITableViewDelegate,UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (vote_ == nil) {
        return 0;
    }
    
    if (self.voteViewLayoutInfo.tableViewHeadTitle ==nil) {
        return 0;
    }
    else {
        return self.voteCellHeadView.frame.size.height;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (vote_ == nil) {
        return 0;
    }
    if (self.voteViewLayoutInfo.tableViewHeadTitle ==nil) {
        return 0;
    }
    else {
        self.voteCellHeadView.alterText = self.voteViewLayoutInfo.tableViewHeadTitle;
        return self.voteCellHeadView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDVoteOption *vp = [vote_.voteOptions objectAtIndex:indexPath.row];
    BOOL isVoteByMyself;
    if (self.voteViewLayoutInfo.isShowVotePercent)
    {
        isVoteByMyself = YES;
    }
    else {
        isVoteByMyself = NO;
    }
    
    CGFloat height = [KDGetCellHeight getVoteCellHeightWithText:vp.name isIncludProcessView:isVoteByMyself];
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    assert(tableView == _tableView);
    if (vote_.voteOptions == nil) {
        return 0;
    }
    return [vote_.voteOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"voteCell";
    KDVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[KDVoteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.voteCellData = [self makeKDVoteCellDataWithtableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

-(KDVoteCellData *)makeKDVoteCellDataWithtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDVoteOption *vp = [vote_.voteOptions objectAtIndex:indexPath.row];
    KDVoteCellData *voteCellData = [[KDVoteCellData alloc] init];// autorelease];
    voteCellData.content = vp.name;
    voteCellData.totalCount = self.totalNumberOfVotes;
    voteCellData.thisItemVoteCount = vp.count;
    
    //controll the hidden of vote persent bar
    if (self.voteViewLayoutInfo.isShowVotePercent)
    {
        voteCellData.isSelectedByMyself = YES;
        
    }
    else {
        voteCellData.isSelectedByMyself = NO;
    }
    //
    if (self.voteViewLayoutInfo.isEditing)
    {
        if ([self.tempOwnItemIdList containsObject:vp.optionId]) {
            voteCellData.voteStatue = VoteSelectNow;
        }
        else {
            voteCellData.voteStatue = VoteCanSelect;
        }
    }
    else
    {
        if ([self.tempOwnItemIdList containsObject:vp.optionId]) {
            voteCellData.voteStatue = VoteSelected;
        }
        else {
            voteCellData.voteStatue = voteCannotSelect;
        }
    }
    return voteCellData;
}

// un finish work!
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KDVoteOption *vp = [vote_.voteOptions objectAtIndex:indexPath.row];
    
    if ([vote_ isMultipleSelections]) {
        if ([self.tempOwnItemIdList containsObject:vp.optionId]) {
            [self.tempOwnItemIdList removeObject:vp.optionId];
        }
        else
        {
            [self.tempOwnItemIdList addObject:vp.optionId];
        }
    }
    else
    {
        [self.tempOwnItemIdList removeAllObjects];
        [self.tempOwnItemIdList addObject:vp.optionId];
    }
    
    [self.tableView reloadData];
}


- (KDVoteTitleView *)voteTitleView
{
    if (_voteTitleView == nil) {
        _voteTitleView = [[KDVoteTitleView alloc]init];
        _voteTitleView.backgroundColor = [UIColor whiteColor];
    }
    return  _voteTitleView;
}


- (KDVoteCellHeadView *)voteCellHeadView
{
    if (_voteCellHeadView == nil) {
        _voteCellHeadView = [[KDVoteCellHeadView alloc]init];
        _voteCellHeadView.frame = CGRectMake(0, 0, ScreenFullWidth,50);
        _voteCellHeadView.backgroundColor = [UIColor clearColor];
    }
    return _voteCellHeadView;
}

- (UIImageView *)toolBarImageView
{
    if (_toolBarImageView == nil) {
        _toolBarImageView = [[UIImageView alloc]init];
        [_toolBarImageView setImage:[[UIImage imageNamed:@"vote_tool_bar_bg_v3"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 0, 24)]];
        _toolBarImageView.userInteractionEnabled = YES;
    }
    return _toolBarImageView;
}
- (UIButton *)voteBtn
{
    if (_voteBtn == nil) {
        _voteBtn = [[UIButton alloc]init];
        _voteBtn.backgroundColor = RGBCOLOR(23, 131, 253);
        _voteBtn.layer.cornerRadius = 5.0f;
        _voteBtn.layer.masksToBounds = YES;
        _voteBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_voteBtn addTarget:self action:@selector(voteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voteBtn;
}
- (UIButton *)refresh
{
    if (_refresh == nil) {
        _refresh = [[UIButton alloc]init];
        [_refresh setBackgroundColor:RGBCOLOR(32, 192, 0)];
        [_refresh setTitle:ASLocalizedString(@"KDDefaultViewControllerContext_refresh") forState:UIControlStateNormal];
        _refresh.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _refresh.layer.cornerRadius = 5.0f;
        _refresh.layer.masksToBounds = YES;
        _refresh.hidden = YES;
        
        [_refresh addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refresh;
}
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounces = NO;
    }
    return _tableView;
}

@end
