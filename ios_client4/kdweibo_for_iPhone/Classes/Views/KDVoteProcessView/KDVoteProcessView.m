//
//  KDVoteProcessView.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/9/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteProcessView.h"
#import "UIViewAdditions.h"
#import "UILableAddition.h"

@interface KDVoteProcessView()

@property(retain,nonatomic)  UIView * voteBar;
@property(retain,nonatomic)  UILabel * voteCountPesent;

@end
@implementation KDVoteProcessView
@synthesize voteBar = _voteBar;
@synthesize voteCountPesent = _voteCountPesent;
@synthesize voteCount = voteCount_;
@synthesize totalVoteCount = totalVoteCount_;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(_voteBar);
    //KD_RELEASE_SAFELY(_voteCountPesent);

    //[super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization cod
        
        [self addSubview:self.voteBar];
        
        [self addSubview:self.voteCountPesent];

    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    self.voteCountPesent.highlighted = selected;
}

- (void)refreshVoteCounPersentView
{    
    CGFloat percent;
    if (self.totalVoteCount == 0) {
        percent = 0;
    }
    else {
        percent = ((CGFloat)(self.voteCount))/((CGFloat)(self.totalVoteCount));
    }

    CGFloat precessViewWidth = percent*(203 - PROCESS_BAR_HEIGHT_SMALL_THAN_BG);
    
    self.voteBar.frame = CGRectMake(0, CGRectGetMinY(self.frame) - 2, precessViewWidth, 8);
    
//    self.voteBar.centerY = self.centerY;
    
    if(percent <= 0.25) {
        self.voteBar.backgroundColor = RGBCOLOR(0xff, 0x62, 0x5a);
    }else if(percent <= 0.5) {
        self.voteBar.backgroundColor = RGBCOLOR(0xff, 0x92, 0x49);
    }else if(percent <= 0.75) {
        self.voteBar.backgroundColor = RGBCOLOR(0x3c, 0xdb, 0xb8);
    }else {
        self.voteBar.backgroundColor = RGBCOLOR(0x4c, 0x9f, 0xff);
    }
    
    NSString *percentString = [NSString stringWithFormat:@"%.0lf%%",percent*100.0];
    
    NSString * showString = [NSString stringWithFormat:@"%ld(%@)",(long)self.voteCount,percentString];
    [self.voteCountPesent setTextAvoidShowNull:showString];
    [self.voteCountPesent sizeToFit];
    
    CGFloat originX = CGRectGetMaxX(self.voteBar.frame) + 10;
    if (percent == 0 ) {
        originX -= 10.f;
    }
    self.voteCountPesent.frame = CGRectMake(originX,CGRectGetMinY(self.frame) - 4, CGRectGetWidth(self.voteCountPesent.bounds), CGRectGetHeight(self.voteCountPesent.bounds));
//    self.voteCountPesent.centerY = self.centerY;

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshVoteCounPersentView];
}


- (UIView *)voteBar
{
    if (_voteBar == nil) {
        _voteBar = [[UIView alloc]init];
    }
    return  _voteBar;
}
- (UILabel *)voteCountPesent
{
    if (_voteCountPesent == nil) {
        _voteCountPesent = [[UILabel alloc]init];
        _voteCountPesent.backgroundColor = [UIColor clearColor];
        _voteCountPesent.textColor = [UIColor grayColor];
        _voteCountPesent.highlightedTextColor = [UIColor whiteColor];
        _voteCountPesent.font = [UIFont systemFontOfSize:13.f];
    }
    return  _voteCountPesent;
}
@end
