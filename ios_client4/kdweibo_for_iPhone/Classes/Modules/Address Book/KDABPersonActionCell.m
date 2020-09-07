//
//  KDABPersonActionCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-8-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDABPersonActionCell.h"
#import "KDCommon.h"

#define KD_TAG_BACKGROUND_IMAGEVIEW  1010

#define BOTTOM_BORDER_TAG   101
#define LEFT_BORDER_TAG  102
#define RIGHT_BORDER_TAG 103

@interface KDABPersonActionCell()
{
    CGSize menuOffset_;
}

@property (nonatomic, retain) NSMutableArray *views;

@end


NS_INLINE UIView *borderView(NSInteger tag) {
    UIView *v = [[UIView alloc] init];
    v.tag = tag;
    v.backgroundColor = RGBCOLOR(203, 203, 203);
    
    return v ;//autorelease];
}

@implementation KDABPersonActionCell

@synthesize titles = titles_;
@synthesize images = images_;
@synthesize invocations = invocations_;
@synthesize views = views_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        views_ = [[NSMutableArray alloc] initWithCapacity:2];
        self.backgroundColor = RGBCOLOR(250, 250, 250);
        self.backgroundView = nil;
        self.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
        
        [self addBorders];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(titles_);
    //KD_RELEASE_SAFELY(invocations_);
    //KD_RELEASE_SAFELY(views_);
    
    //[super dealloc];
}

- (void)addBorders
{
    [self addSubview:borderView(BOTTOM_BORDER_TAG)];
    [self addSubview:borderView(LEFT_BORDER_TAG)];
    [self addSubview:borderView(RIGHT_BORDER_TAG)];
}

- (UIButton *)genButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [btn setTitleColor:RGBCOLOR(93, 93, 93) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    return btn;
}

- (void)setupButtonTitles
{
    NSInteger btnCount = views_.count;
    NSInteger titlesCount = titles_.count;
    
    if(btnCount < titlesCount) {
        for(NSInteger i = 0; i < titlesCount - btnCount; i++) {
            [views_ addObject:[self genButton]];
        }
    }
    
    for(NSInteger index = 0; index < titlesCount; index++) {
        UIButton *btn = [views_ objectAtIndex:index];
        [btn setTitle:[titles_ objectAtIndex:index] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    }
}

- (void)setupButtonImages
{
    NSInteger btnCount = views_.count;
    NSInteger imagesCount = images_.count;
    
    if(btnCount < imagesCount) {
        for(NSInteger i = 0; i < imagesCount - btnCount; i++) {
            [views_ addObject:[self genButton]];
        }
    }
    
    for(NSInteger index = 0; index < imagesCount; index++) {
        UIButton *btn = [views_ objectAtIndex:index];
        [btn setImage:[images_ objectAtIndex:index] forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 8.0f)];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger btnCount = views_.count;
    CGFloat widthPerButton = CGRectGetWidth(self.frame) / btnCount;
    
    for(NSInteger index = 0; index < btnCount; index++) {
        UIButton *btn = (UIButton *)[views_ objectAtIndex:index];
        btn.frame = CGRectMake(index * widthPerButton, 0.0f, widthPerButton, CGRectGetHeight(self.frame));
    }
    
    UIView *bottom = [self viewWithTag:BOTTOM_BORDER_TAG];
    if(bottom) {
        bottom.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5f, CGRectGetWidth(self.bounds), 0.5f);
    }
    
    UIView *left = [self viewWithTag:LEFT_BORDER_TAG];
    if (left) {
        left.frame = CGRectMake(0, 0, 0.5f, CGRectGetHeight(self.bounds));
    }
    
    UIView *right = [self viewWithTag:RIGHT_BORDER_TAG];
    if(right) {
        right.frame = CGRectMake(CGRectGetWidth(self.bounds) - 0.5f, 0, 0.5f, CGRectGetHeight(self.bounds));
    }
}

- (void)buttonClicked:(UIButton *)btn
{
    NSUInteger index = [views_ indexOfObject:btn];
    
    if(index < invocations_.count) {
        NSInvocation *invocation = (NSInvocation *)[invocations_ objectAtIndex:index];
        [invocation invoke];
    }
}

#pragma mark - Public methods
- (void)setTitles:(NSArray *)titles
{
    if(titles_ != titles) {
//        [titles_ release];
        titles_ = [titles copy];
        
        [self setupButtonTitles];
    }
}

- (void)setImages:(NSArray *)images
{
    if(images_ != images) {
//        [images_ release];
        images_ = [images copy];
        
        [self setupButtonImages];
    }
}

- (void)setMenuOffset:(CGSize)menuOffset
{
    menuOffset_ = CGSizeMake(menuOffset.width, menuOffset.height);
}

@end
