//
//  KDActivityCell.m
//  kdweibo
//
//  Created by 陈彦安 on 15/4/22.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDActivityCell.h"

@interface KDActivityCell ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation KDActivityCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSome];
}

- (void)initSome
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.activityView = [[UIActivityIndicatorView alloc]init];
    [self.activityView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 10, 8, 20, 20)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.activityView];
}

-(void)setActivityAnimate
{
    [self.activityView startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
