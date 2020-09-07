//
//  KDVoteTitleView.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/30/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteTitleView.h"

#import "NSDate+Additions.h"
#import "UIViewAdditions.h"

@interface KDVoteTitleView()
@property(retain,nonatomic) UILabel * voteCount;
@property(retain,nonatomic) UILabel * voteCountTip;
@property(retain,nonatomic) UILabel * deadline;
@property(retain,nonatomic) UIImageView * voteTpye;
@property(retain,nonatomic) UIImageView  *bottomSeparator;
@property(nonatomic,retain) UIImageView * countBgImageView;
@property(retain,nonatomic) KDUsersURLView * voteDetail;
@property(retain,nonatomic) KDTimeLineDetailURLViewHandle *timeLineDetURLViewHandle;

@end

@implementation KDVoteTitleView
@synthesize voteCount = _voteCount;
@synthesize deadline = _deadline;
@synthesize voteTpye = _voteTpye;
@synthesize voteDetail = _voteDetail;
@synthesize countBgImageView = _countBgImageView;
@synthesize vote = vote_;
@synthesize timeLineDetURLViewHandle = timeLineDetURLViewHandle_;
@synthesize bottomSeparator = _bottomSeparator;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(_voteCount);
    //KD_RELEASE_SAFELY(_deadline);
    //KD_RELEASE_SAFELY(_voteTpye);
    //KD_RELEASE_SAFELY(_voteDetail);
    //KD_RELEASE_SAFELY(vote_);
    //KD_RELEASE_SAFELY(timeLineDetURLViewHandle_);
    //KD_RELEASE_SAFELY(_bottomSeparator);
    //KD_RELEASE_SAFELY(_countBgImageView);
    
    //[super dealloc];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        self.timeLineDetURLViewHandle = [[KDTimeLineDetailURLViewHandle alloc] init];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        [self addSubview:self.countBgImageView];
        [self.countBgImageView makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.mas_left).with.offset(10);
             make.centerY.equalTo(self.mas_centerY);
             make.width.mas_equalTo(60);
             make.height.mas_equalTo(60);
         }];
        
        [self.countBgImageView addSubview:self.voteCount];
        [self.voteCount makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.and.left.and.bottom.and.right.equalTo(self.countBgImageView).with.insets(UIEdgeInsetsMake(5, 0, 30, 0));
         }];
        
        [self.countBgImageView addSubview:self.voteCountTip];
        [self.voteCountTip makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.and.left.and.bottom.and.right.equalTo(self.countBgImageView).with.insets(UIEdgeInsetsMake(25, 0, 0 , 0));
         }];
        
        
        
        [self addSubview:self.voteDetail];
        [self.voteDetail makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.equalTo(self.mas_top).with.offset(20);
            make.left.equalTo(self.mas_left).with.offset(40);
            make.right.equalTo(self.mas_right).with.offset(5);
            make.height.mas_equalTo(20);
        }];
        [self addSubview:self.voteTpye];
        [self addSubview:self.deadline];
        
        [self.deadline makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.countBgImageView.mas_right).with.offset(15);
             make.bottom.equalTo(self.mas_bottom).with.offset( -20);
             make.right.equalTo(self.voteTpye.mas_left).with.offset(10);
             make.height.mas_equalTo(20);
         }];
        
        [self.voteTpye makeConstraints:^(MASConstraintMaker *make)
         {
             make.right.equalTo(self.mas_right).with.offset(-15);
             make.width.mas_equalTo(50);
             make.bottom.equalTo(self.deadline.mas_bottom);
             make.height.mas_equalTo(18);
         }];

        
        
        [self addSubview:self.bottomSeparator];
        [self.bottomSeparator makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.and.bottom.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 1));
             make.height.mas_equalTo(1);
         }];

    }
    return self;
}

-(NSString *)voteDetailStringLimeInTwoLine
{
    NSString *needCountString = [NSString stringWithFormat:@"%@: %@", vote_.author.screenName, vote_.name];
    NSString *outString = [CommenMethod getTheRightStringWithOringString:needCountString
                                                                    line:MAX_VOTE_DETAIL_LAB_LINE fontSize:MAX_VOTE_DETAIL_LAB_FONT width:MAX_VOTE_DETAIL_LAB_WIDTH
                                                            isFirstCheck:YES];
    NSInteger removeStringIndex = [vote_.author.screenName length]+1;
    NSString * returnString = [outString substringFromIndex:removeStringIndex];
    return returnString;
}

- (void)refreshVoteDetail
{
    [self.voteDetail layoutUsersUrlViewWith:[self voteDetailStringLimeInTwoLine]
                                   userName:vote_.author.screenName
                                     userId:vote_.author.userId];

    _voteDetail.frame = CGRectMake(CGRectGetMinX(self.deadline.frame),20 , ScreenFullWidth - CGRectGetMinX(self.deadline.frame) - 12 , 30);
    //there is stil some problem that it will show wrong when the text is too long
//    [self.voteDetail setFrame:CGRectMake(VOTE_DETAIL_LEFT, VOTE_DETAIL_TOP, MAX_VOTE_DETAIL_LAB_WIDTH, self.voteDetail.frame.size.height)];
    //紧挨操作
//    self.deadline.frame = CGRectMake(VOTE_DETAIL_LEFT, CGRectGetMaxY(self.voteDetail.frame) + DEAD_TIME_TOP_GAP , self.deadline.frame.size.width, self.deadline.size.height);
//    
//    self.voteTpye.center = CGPointMake(self.voteTpye.center.x, self.deadline.center.y);
    //>
    //居中操作
//    float moveToCenterOffSetY =VOTE_COUNT_BG_WIDTH/2 - (self.voteDetail.frame.size.height + DEAD_TIME_TOP_GAP +self.deadline.frame.size.height)/2;
//    [self.voteDetail setTop:self.voteDetail.top + moveToCenterOffSetY+ 10];
//    [self.deadline setTop:self.deadline.top + moveToCenterOffSetY + 44];
//    [self.voteTpye setTop:self.voteTpye.top + moveToCenterOffSetY + 44];
    //<
}

- (void)refreshDeadTime {
    NSString *endTimeTampStr = [NSDate formatMonthOrDaySince1970:vote_.closedTime];
    self.deadline.text = [NSString stringWithFormat:@"%@：%@",ASLocalizedString(@"KDCreateTaskViewController_end_time"), endTimeTampStr];
    [self.deadline sizeToFit];
}

- (void)refreshVoteCount {
    [self.voteCount setText:[NSString stringWithFormat:@"%ld", (long)vote_.participantCount]];
}

//select type image singleSelect@2x.png
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (vote_ != nil) {
        [self refreshVoteDetail];
        [self refreshVoteCount];
        [self refreshDeadTime];
        
        //multipleSelect@2x.png
        NSString *selectTypeImageName = nil;
        if ([vote_ isMultipleSelections]) {
            selectTypeImageName = @"vote_multiple_select_v3.png";
        }
        else {
            selectTypeImageName = @"vote_single_select_v3.png";
        }
        UIImage *image = [UIImage imageNamed:selectTypeImageName];
        [self.voteTpye setImage:image];
        
    }
    
}


- (UIImageView *)countBgImageView
{
    if (_countBgImageView == nil) {
        _countBgImageView = [[UIImageView alloc]init];
        _countBgImageView.backgroundColor = RGBCOLOR(255, 255, 255);
        _countBgImageView.layer.borderColor = RGBCOLOR(0xcb, 0xcb, 0xcb).CGColor;
        _countBgImageView.layer.borderWidth = 3.0f;
    }
    return _countBgImageView;
}

- (UILabel *)voteCount
{
    if (_voteCount == nil) {
        _voteCount = [[UILabel alloc]init];
        _voteCount.backgroundColor = [UIColor clearColor];
        _voteCount.textAlignment = NSTextAlignmentCenter;
        [_voteCount setTextColor:RGBCOLOR(0xff, 0x62, 0x5a)];
    }
    return  _voteCount;
}

- (UILabel *)voteCountTip
{
    if (_voteCountTip == nil) {
        _voteCountTip = [[UILabel alloc]init];
        _voteCountTip.backgroundColor = [UIColor clearColor];
        _voteCountTip.textAlignment = NSTextAlignmentCenter;
        [_voteCountTip setTextColor:[UIColor blackColor]];
        _voteCountTip.font = [UIFont systemFontOfSize:12.0f];
        _voteCountTip.text = ASLocalizedString(@"KDVoteView_Vote_Num");
        
    }
    return  _voteCountTip;
}

-(KDUsersURLView *) voteDetail
{
    if (_voteDetail == nil) {
        _voteDetail = [[KDUsersURLView alloc]
                            initWithFontSize:MAX_VOTE_DETAIL_LAB_FONT
                            width:MAX_VOTE_DETAIL_LAB_WIDTH
                            delegate:self.timeLineDetURLViewHandle];
        _voteDetail.backgroundColor = [UIColor clearColor];
        _voteDetail.FontSize = 15.f;
    }
    return _voteDetail;
}

- (UILabel *)deadline
{
    if (_deadline == nil) {
        _deadline = [[UILabel alloc]init];
        _deadline.backgroundColor = [UIColor clearColor];
        [_deadline setTextColor:[UIColor grayColor]];
        _deadline.font = [UIFont systemFontOfSize:15.f];
    }
    return  _deadline;
}

- (UIImageView *)voteTpye
{
    if (_voteTpye == nil) {
        _voteTpye = [[UIImageView alloc]init];
        _voteTpye.backgroundColor = [UIColor clearColor];
    }
    return _voteTpye;
}

- (UIImageView *)bottomSeparator
{
    if (_bottomSeparator == nil) {
        _bottomSeparator = [[UIImageView alloc]init];
        UIImage *image = [UIImage imageNamed:@"vote_seperator_v3.png"];
        image = [image stretchableImageWithLeftCapWidth:ScreenFullWidth topCapHeight:1];
        _bottomSeparator.image = image;
    }
    return _bottomSeparator;
}
@end
