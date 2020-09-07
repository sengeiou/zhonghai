//
//  KDVoteCell.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteCell.h"
#import "UIViewAdditions.h"

@implementation KDVoteCell
@synthesize selectStatus = _selectStatus;
@synthesize voteDetail = _voteDetail;
@synthesize voteProcessView = _voteProcessView;
@synthesize voteCellData = voteCellData_;
@synthesize bottomSeparator = _bottomSeparator;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(_selectStatus);
    //KD_RELEASE_SAFELY(_voteDetail);
    //KD_RELEASE_SAFELY(_voteProcessView);
    //KD_RELEASE_SAFELY(voteCellData_);
    //KD_RELEASE_SAFELY(_bottomSeparator);
//    [super  dealloc];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.selectStatus];
        [self.selectStatus makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.mas_left).with.offset(15);
             make.centerY.mas_equalTo(self.mas_centerY);
             make.width.mas_equalTo(23);
             make.height.mas_equalTo(23);
         }];

        [self addSubview:self.voteDetail];
        [self.voteDetail makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.selectStatus.mas_right).with.offset(10);
//             make.centerY.equalTo(self.centerXWithinMargins);
             make.top.and.right.equalTo(self).with.insets(UIEdgeInsetsMake(8, 0, 0, 5));
             make.height.mas_equalTo(15);
         }];
        
        [self addSubview:self.voteProcessView];
        [self.voteProcessView makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(self.voteDetail.mas_bottom).with.offset(-8);
             make.left.equalTo(self.selectStatus.mas_right).with.offset(10);
             //             make.centerY.equalTo(self.centerXWithinMargins);
             make.right.equalTo(self).with.offset(5);
             make.height.mas_equalTo(15);
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

- (void)resetVoteProcessView
{
    if (self.voteCellData.isSelectedByMyself) {
        [self.voteProcessView setHidden:NO];
    }
    else {
        [self.voteProcessView setHidden:YES];
    }

    [self.voteProcessView setVoteCount:self.voteCellData.thisItemVoteCount];
    [self.voteProcessView setTotalVoteCount:self.voteCellData.totalCount];
    [self.voteProcessView setNeedsLayout];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.voteDetail setText:self.voteCellData.content];
    
//    CGSize labelSize = [CommenMethod getSizeByLableWithMaxHeight:VOTE_DETAIL_MAX_HEIGHT lable:self.voteDetail];
    
    //    CGSize size = [self.voteCellData.content sizeWithFont:self.voteDetail.font constrainedToSize:CGSizeMake(self.voteDetail.frame.size.width, MAXFLOAT)];
    
//    self.voteDetail.frame = CGRectMake(self.voteDetail.frame.origin.x, self.voteDetail.frame.origin.y, labelSize.width, labelSize.height);
//    
//    //    [self.voteProcessView setTop:labHeight / 2 + self.voteDetail.top];
//    CGFloat height = self.frame.size.height;
//    self.voteDetail.centerY = height / 2 - 5;
//    self.selectStatus.centerY = height / 2;

    
    
//    self.voteProcessView.frame = CGRectMake(self.voteDetail.frame.origin.x , 16 , 203, labelSize.height);
//    self.voteProcessView.centerY = height / 4;
//    [_voteProcessView setLeft:CGRectGetWidth(self.voteDetail.frame) + 5];
//    [self.voteProcessView setWidth:<#(CGFloat)#>]
//    [self addSubview:self.voteProcessView];
    
    
    
    [self resetVoteProcessView];
    
    
    NSString *imageName = nil;
    
    switch (self.voteCellData.voteStatue) {
        case VoteCanSelect:
            imageName = @"vote_check_box_can_select_v3.png";
            break;
        case VoteSelectNow:
            imageName = @"vote_check_box_selected_v3.png";
            break;
        case VoteSelected:
            imageName = @"vote_check_box_selected_can_not_change_v3.png";
            break;
        case voteCannotSelect:
            imageName = @"vote_check_box_can_not_select_v3.png";
            break;
            
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [self.selectStatus setImage:image];

}

- (UIImageView *)selectStatus
{
    if (_selectStatus == nil) {
        _selectStatus = [[UIImageView alloc]init];
        _selectStatus.backgroundColor = [UIColor clearColor];
    }
    return _selectStatus;
    
}

- (UILabel *)voteDetail
{
    if (_voteDetail == nil) {
        _voteDetail = [[UILabel alloc]init];
        _voteDetail.textColor = [UIColor grayColor];
        _voteDetail.backgroundColor = [UIColor clearColor];
        _voteDetail.font = [UIFont systemFontOfSize:14];
        _voteDetail.numberOfLines = 1;
    }
    return _voteDetail;
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

- (KDVoteProcessView *)voteProcessView
{
    if (_voteProcessView == nil) {
        _voteProcessView = [[KDVoteProcessView alloc]initWithFrame:CGRectMake(self.voteDetail.frame.origin.x, self.voteDetail.frame.origin.y, ScreenFullWidth - self.voteDetail.frame.size.width, 30)];
        _voteProcessView.backgroundColor = [UIColor clearColor];
    }
    return _voteProcessView;
}

@end
