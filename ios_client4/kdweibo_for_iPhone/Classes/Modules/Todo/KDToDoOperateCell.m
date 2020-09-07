//
//  KDToDoOperateCell.m
//  kdweibo
//
//  Created by 陈彦安 on 15/4/8.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDToDoOperateCell.h"
#import "KDToDoMessageDataModel.h"
#import "UIImageView+WebCache.h"
#import "ContactUtils.h"

#define BOSCOLORWITHRGBA(rgbValue, alphaValue)		[UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0 \
blue:((float)((rgbValue) & 0x0000FF))/255.0 \
alpha:(alphaValue)]

@interface KDToDoOperateCell ()
@property (nonatomic, strong) UIImageView *actionImageView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *headLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *textView;
@property (nonatomic, strong) UIView *containorView;
@property (nonatomic, strong) UIView *buttonContainorView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *middleButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) NSDictionary *leftDic;
@property (nonatomic, strong) NSDictionary *middleDic;
@property (nonatomic, strong) NSDictionary *rightDic;

@property (nonatomic, strong) KDToDoMessageDataModel *model;

@property (nonatomic, strong) NSLayoutConstraint *containorHeightConstraint;
@property (nonatomic, strong) NSMutableArray *constraintsArray;

@property (nonatomic, strong) UIImageView *redDot;
@end

@implementation KDToDoOperateCell
-(NSMutableArray *)constraintsArray
{
    if (!_constraintsArray)
    {
        _constraintsArray = [NSMutableArray array];
    }
    return _constraintsArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)initSome
{
    //    CGRect contaionorFrame = CGRectMake(8, 8, 304, 154);
    //    CGRect headImageViewFrame = CGRectMake(8, 8, 50, 50);
    //    CGRect headLabelFrame = CGRectMake(66, 22, 200, 21);
    //    CGRect timeLabelFrame = CGRectMake(196, 3, 100, 21);
    //    CGRect textViewFrame = CGRectMake(8, 66, 278, 80);
    //    CGRect actionImageViewFrame = CGRectMake(288, 72, 12, 12);
    
    [self setBackgroundColor:BOSCOLORWITHRGBA(0xf2f4f8, 1.0)];
    [self.contentView setBackgroundColor:BOSCOLORWITHRGBA(0xf2f4f8, 1.0)];
    [self setSelectionStyle:UITableViewCellEditingStyleNone];
    
    
    
    CGRect contaionorFrame = CGRectMake(8, 8, [UIScreen mainScreen].bounds.size.width - 16, 154);
    CGRect headImageViewFrame = CGRectMake(8, 8, 40, 40);
    CGRect headLabelFrame = CGRectMake(56, 8, [UIScreen mainScreen].bounds.size.width - 96, 21);
    CGRect timeLabelFrame = CGRectMake(57, 25, 56, 21);
    CGRect textViewFrame = CGRectMake(8, 56, [UIScreen mainScreen].bounds.size.width - 42, 80);
    CGRect redDotFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 32, 14, 8, 8);
    
    self.containorView = [[UIView alloc]initWithFrame:contaionorFrame];
    [self.containorView setBackgroundColor:[UIColor whiteColor]];
    [self.containorView.layer setBorderWidth:0.5];
    [self.containorView.layer setBorderColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor];
    [self.containorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:self.containorView];
    
    self.headImageView = [[UIImageView alloc]initWithFrame:headImageViewFrame];
    [self.headImageView setBackgroundColor:[UIColor clearColor]];
    [self.headImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.headImageView];
    
    self.headLabel = [[UILabel alloc]initWithFrame:headLabelFrame];
    [self.headLabel setBackgroundColor:[UIColor clearColor]];
    [self.headLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.headLabel];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:timeLabelFrame];
    [self.timeLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentLeft];
    [self.timeLabel setTextColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0)];
    [self.timeLabel setFont:[UIFont systemFontOfSize:10]];
    [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.timeLabel];
    
    self.textView = [[UILabel alloc]initWithFrame:textViewFrame];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setFont:[UIFont systemFontOfSize:14]];
    [self.textView setTextColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0)];
    [self.textView setNumberOfLines:4];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.textView];
    
    self.redDot = [[UIImageView alloc]initWithFrame:redDotFrame];
    [self.redDot setBackgroundColor:[UIColor clearColor]];
    [self.redDot setContentMode:UIViewContentModeScaleAspectFit];
    [self.redDot setImage:[UIImage imageNamed:@"common_img_new"]];
    
    NSLayoutConstraint *constraint = nil;
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:8];
    [self.contentView addConstraint:constraint];
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:8];
    [self.contentView addConstraint:constraint];
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    self.containorHeightConstraint = constraint;
    [self.contentView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:8];
    [self.containorView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:8];
    [self.containorView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:40];
    [self.headImageView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:40];
    [self.headImageView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:56];
    [self.containorView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:8];
    [self.containorView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-24];
    [self.containorView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:21];
    [self.headLabel addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:25];
    [self.containorView addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:57];
    [self.containorView addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:21];
    [self.timeLabel addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:56];
    [self.timeLabel addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:8];
    [self.containorView addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:56];
    [self.containorView addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-8];
    [self.containorView addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    [self.containorView addConstraint:constraint];
}

- (void)anotherSetCellInformation:(KDToDoMessageDataModel *)model
{
    [self.containorView setBackgroundColor:[UIColor whiteColor]];
    
    [self setModel:model];
    
    [self setTwoButtonOrThreeButtonWithModel:model];
    
    self.headImageView.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(self.headImageView.frame)/2):ImageViewCornerRadius);
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.shouldRasterize = YES;
    self.headImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self.headLabel setText:model.title];
    [self.timeLabel setText:[self xtDateFormatter:model.sendTime]];
    [self.textView setText:model.text];
    [self.textView setNumberOfLines:[self caculateLabelRow:model.text]];
    
    [self setReadState:model];
    [self setPhotoImage:model];
    [self switchCellType:model];
}

#pragma mark - caculateLabelRow
-(NSInteger)caculateLabelRow:(NSString *)string
{
    CGSize textSize = {[UIScreen mainScreen].bounds.size.width - 24 ,10000.0};
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    return size.height / 10 + 1;
}

#pragma mark - switch celltype
-(void)switchCellType:(KDToDoMessageDataModel *)model
{
    if (model.shouldChangeToCellTypeShow)
    {
        self.containorHeightConstraint.constant = -46;
    }
    else
    {
        self.containorHeightConstraint.constant = -8;
    }
}

#pragma mark - twoButton threeButton
-(void)setTwoButtonOrThreeButtonWithModel:(KDToDoMessageDataModel *)model
{
    NSDictionary *tempDic = model.list.firstObject;
    NSArray *tempArray = [tempDic objectForKey:@"button"];
    
    if (tempArray.count == 2)
    {
        [self setTwoButtonWithArray:tempArray];
    }
    else if(tempArray.count == 3)
    {
        [self setThreeButtonWithArray:tempArray];
    }
}

-(void)setTwoButtonWithArray:(NSArray *)array
{
    self.leftDic = nil;
    self.middleDic = nil;
    self.rightDic = nil;
    [self.leftButton removeFromSuperview];
    [self.middleButton removeFromSuperview];
    [self.rightButton removeFromSuperview];
    [self.contentView removeConstraints:self.constraintsArray];
    [self.constraintsArray removeAllObjects];
    
    self.leftDic = [array objectAtIndex:0];
    self.rightDic = [array objectAtIndex:1];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.leftButton setFrame:CGRectMake(8, 5, 96, 30)];
    [self.leftButton setBackgroundColor:[UIColor whiteColor]];
    [self.leftButton setTitle:[self.leftDic objectForKey:@"title"] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.leftButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.leftButton.layer setCornerRadius:0.5];
    [self.leftButton.layer setBorderWidth:0.5];
    [self.leftButton.layer setBorderColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor];
    [self.leftButton.layer setMasksToBounds:YES];
    [self.leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.leftButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:self.leftButton atIndex:0];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.rightButton setFrame:CGRectMake(216, 5, 96, 30)];
    [self.rightButton setBackgroundColor:[UIColor whiteColor]];
    [self.rightButton setTitle:[self.rightDic objectForKey:@"title"] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.rightButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.rightButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.rightButton.layer setCornerRadius:0.5];
    [self.rightButton.layer setBorderWidth:0.5];
    [self.rightButton.layer setBorderColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor];
    [self.rightButton.layer setMasksToBounds:YES];
    [self.rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:self.rightButton atIndex:0];
    
    NSLayoutConstraint *constraint = nil;
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:30];
    [self.leftButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:([UIScreen mainScreen].bounds.size.width - 24) / 2];
    [self.leftButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:30];
    [self.rightButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:([UIScreen mainScreen].bounds.size.width - 24) / 2];
    [self.rightButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
}

-(void)setThreeButtonWithArray:(NSArray *)array
{
    self.leftDic = nil;
    self.middleDic = nil;
    self.rightDic = nil;
    [self.leftButton removeFromSuperview];
    [self.middleButton removeFromSuperview];
    [self.rightButton removeFromSuperview];
    [self.contentView removeConstraints:self.constraintsArray];
    [self.constraintsArray removeAllObjects];
    
    self.leftDic = [array objectAtIndex:0];
    self.middleDic = [array objectAtIndex:1];
    self.rightDic = [array objectAtIndex:2];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.leftButton setFrame:CGRectMake(8, 5, 96, 30)];
    [self.leftButton setBackgroundColor:[UIColor whiteColor]];
    [self.leftButton setTitle:[self.leftDic objectForKey:@"title"] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.leftButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.leftButton.layer setCornerRadius:0.5];
    [self.leftButton.layer setBorderWidth:0.5];
    [self.leftButton.layer setBorderColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor];
    [self.leftButton.layer setMasksToBounds:YES];
    [self.leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.leftButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:self.leftButton atIndex:0];
    
    self.middleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.middleButton setFrame:CGRectMake(112, 5, 96, 30)];
    [self.middleButton setBackgroundColor:[UIColor whiteColor]];
    [self.middleButton setTitle:[self.middleDic objectForKey:@"title"] forState:UIControlStateNormal];
    [self.middleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.middleButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.middleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.middleButton.layer setCornerRadius:0.5];
    [self.middleButton.layer setBorderWidth:0.5];
    [self.middleButton.layer setBorderColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor];
    [self.middleButton.layer setMasksToBounds:YES];
    [self.middleButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.middleButton addTarget:self action:@selector(middleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:self.middleButton atIndex:0];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.rightButton setFrame:CGRectMake(216, 5, 96, 30)];
    [self.rightButton setBackgroundColor:[UIColor whiteColor]];
    [self.rightButton setTitle:[self.rightDic objectForKey:@"title"] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.rightButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.rightButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.rightButton.layer setCornerRadius:0.5];
    [self.rightButton.layer setBorderWidth:0.5];
    [self.rightButton.layer setBorderColor:BOSCOLORWITHRGBA(0xCFCFCF, 1.0).CGColor];
    [self.rightButton.layer setMasksToBounds:YES];
    [self.rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:self.rightButton atIndex:0];
    
    NSLayoutConstraint *constraint = nil;
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:30];
    [self.leftButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //leftbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:([UIScreen mainScreen].bounds.size.width - 32) / 3];
    [self.leftButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:30];
    [self.rightButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //rightbutton
    constraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:([UIScreen mainScreen].bounds.size.width - 32) / 3];
    [self.rightButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //middlebutton
    constraint = [NSLayoutConstraint constraintWithItem:self.middleButton
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:30];
    [self.middleButton addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //middlebutton
    constraint = [NSLayoutConstraint constraintWithItem:self.middleButton
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //middlebutton
    constraint = [NSLayoutConstraint constraintWithItem:self.middleButton
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.leftButton
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
    
    //middlebutton
    constraint = [NSLayoutConstraint constraintWithItem:self.middleButton
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.rightButton
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:-8];
    [self.contentView addConstraint:constraint];
    [self.constraintsArray addObject:constraint];
}

#pragma mark - setTime setReadstate setPhoto
- (NSString *)xtDateFormatter:(NSString *)fullDateString
{
    if (fullDateString == nil || [@"" isEqualToString:fullDateString])
    {
        return @"";
    }
    
    if (fullDateFormatter == nil)
    {
        fullDateFormatter = [[NSDateFormatter alloc] init];
    }
    [fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fullDate = [fullDateFormatter dateFromString:fullDateString];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSYearCalendarUnit;
    comps = [calendar components:unitFlags fromDate:fullDate];
    int fullDateYear = (int)[comps year];
    comps = [calendar components:unitFlags fromDate:[NSDate date]];
    int nowDateYear = (int)[comps year];
    
    NSString *fullShortString = [fullDateString substringToIndex:10];
    if (fullDateYear != nowDateYear) {
        return fullShortString;
    }
    
    if (shortDateFormatter == nil) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
    }
    [shortDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fullShortDate = [shortDateFormatter dateFromString:fullShortString];
    
    NSInteger dayDiff = (int)[fullShortDate timeIntervalSinceNow] / (60*60*24);
    
    if (lastDateFormatter == nil) {
        lastDateFormatter = [[NSDateFormatter alloc] init];
    }
    
    switch (dayDiff)
    {
        case 0:
            [lastDateFormatter setDateFormat:@"HH:mm"];
            break;
        case -1:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"KDToDoOperateCell_Yesterday")];
            break;
        case -2:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"KDToDoOperateCell_TheDayBeforeYesterday")];
            break;
        default:
            [lastDateFormatter setDateFormat:@"MM-dd"];
            break;
    }
    return [lastDateFormatter stringFromDate:fullDate];
}

-(void)setReadState:(KDToDoMessageDataModel *)model;
{
    [self.redDot removeFromSuperview];
    
    if (model.status == MessageStatusRead)
    {
        [self.redDot removeFromSuperview];
    }
    else
    {
        [self.containorView addSubview:self.redDot];
    }
}

-(void)setPhotoImage:(KDToDoMessageDataModel *)model
{
    NSURL *imageURL = nil;
    if (model.name.length > 0)
    {
        NSString *url = model.name;
        if ([url rangeOfString:@"?"].location != NSNotFound)
        {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else
        {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
    }
    [self.headImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"todo"]];
}

#pragma mark - buttonAction
- (void)leftButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(leftButtonWithcell:Dic:Model:)])
    {
        [self.delegate leftButtonWithcell:self Dic:self.leftDic Model:self.model];
    }
}

- (void)middleButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(middleButtonWithcell:Dic:Model:)])
    {
        [self.delegate middleButtonWithcell:self Dic:self.middleDic Model:self.model];
    }
}

- (void)rightButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightButtonWithcell:Dic:Model:)])
    {
        [self.delegate rightButtonWithcell:self Dic:self.rightDic Model:self.model];
    }
}
@end
