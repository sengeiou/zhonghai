//
//  KDToDoFilterViewCell.m
//  kdweibo
//
//  Created by janon on 15/4/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDToDoFilterViewCell.h"
#import "UIImageView+WebCache.h"


@interface KDToDoFilterViewCell ()
@property (nonatomic, strong) UIImageView *checkedView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *logoNameLabel;
@end

@implementation KDToDoFilterViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSome];
    }
    return self;
}

-(void)initSome
{
    [self setBackgroundColor:[UIColor whiteColor]];

    self.logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 55, 55)];
    [self.logoImageView setBackgroundColor:[UIColor clearColor]];
    self.logoImageView.userInteractionEnabled = YES;
    self.logoImageView.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(self.logoImageView.frame)/2):ImageViewCornerRadius);
    self.logoImageView.layer.masksToBounds = YES;
    [self addSubview:self.logoImageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoImageTap:)];
    [self.logoImageView addGestureRecognizer:tap];
    
    
    self.logoNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 73, 75, 30)];
    [self.logoNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.logoNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.logoNameLabel setFont:FS6];
    [self.logoNameLabel setTextColor:FC1];
    [self.logoNameLabel setNumberOfLines:2];
    [self addSubview:self.logoNameLabel];
    
    self.checkedView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, 20, 20)];
    [self.checkedView setContentMode:UIViewContentModeScaleAspectFit];
    [self.checkedView setBackgroundColor:[UIColor clearColor]];
    [self.checkedView setImage:[UIImage imageNamed:@"ic_select_nor"]];
//    [self addSubview:self.checkedView];]
}

-(void)setCellInformation:(KDToDoMessageDataModel *)model checkWithArray:(NSMutableArray *)array
{
    [self.checkedView removeFromSuperview];
    if (self.logoImageView.superview == nil)
    {
        [self addSubview:self.logoImageView];
    }
    if (self.logoImageView.superview == nil) {
        [self addSubview:self.logoImageView];
    }
    
    NSString *title = model.title;
    if ([model.title isEqualToString:@"@提及"]) {
        title = ASLocalizedString(@"KDToDoContainorViewController_model_title");
    }
    self.logoNameLabel.text = title;
    if([model.title isEqualToString:@"@提及"])
    {
        self.logoImageView.image = [UIImage imageNamed:@"chat_plus_menu_at"];
    }else
    {
       [self.logoImageView setImageWithURL:[NSURL URLWithString:model.name] placeholderImage:[UIImage imageNamed:@"app_default_icon.png"]];
    }


//    self.logoNameLabel.text = model.title;
//    [self.logoImageView setImageWithURL:[NSURL URLWithString:model.name] placeholderImage:[UIImage imageNamed:@"app_default_icon.png"]];
//    
//    if ([self sizeBeyondOneLine:model.title fontSize:12])
//    {
//        [self.logoNameLabel setFrame:CGRectMake(0, 70, 70, 30)];
//        [self.logoNameLabel setNumberOfLines:2];
//    }
//    else
//    {
//        [self.logoNameLabel setFrame:CGRectMake(0, 70, 70, 15)];
//        [self.logoNameLabel setNumberOfLines:1];
//    }
    
    if ([array containsObject:model])
    {
        [self addSubview:self.checkedView];
    }
    else
    {
        [self.checkedView removeFromSuperview];
    }
}

-(void)setAtInformation:(KDToDoMessageDataModel *)model checkWithArray:(NSMutableArray *)array
{
    [self.checkedView removeFromSuperview];
    
    [self.logoNameLabel setFrame:CGRectMake(0, 73, 75, 30)];
    [self.logoNameLabel setNumberOfLines:1];
    self.logoNameLabel.text = ASLocalizedString(@"KDToDoContainorViewController_model_title");

    [self.logoImageView setImage:[UIImage imageNamed:@"app_btn_at_nor"]];
    
    if ([array containsObject:model])
    {
        [self addSubview:self.checkedView];
    }
    else
    {
        [self.checkedView removeFromSuperview];
    }
}

-(void)setUndoInformation:(KDToDoMessageDataModel *)model checkWithArray:(NSMutableArray *)array
{
    [self.checkedView removeFromSuperview];
    
    [self.logoNameLabel setFrame:CGRectMake(0, 73, 75, 30)];
    [self.logoNameLabel setNumberOfLines:1];
    self.logoNameLabel.text = ASLocalizedString(@"KDToDoContainorViewController_undoModel_title");
    
    [self.logoImageView setImage:[UIImage imageNamed:@"app_btn_undo_nor"]];
    
    if ([array containsObject:model])
    {
        [self addSubview:self.checkedView];
    }
    else
    {
        [self.checkedView removeFromSuperview];
    }
}

- (BOOL) sizeBeyondOneLine:(NSString*)str fontSize:(int)fontSize
{
    //计算一下文本的行数，如果超出一行，将标签高度变成2行。
    CGSize textSize = {70.0 ,1000.0};
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    if(size.height > 15.0)
        return YES;
    else
        return NO;
}
- (void)logoImageTap:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickedWithCell:)]) {
        [_delegate clickedWithCell:self];
    }
}
@end
