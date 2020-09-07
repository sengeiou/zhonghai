//
//  KDVoteCellHeadViewViewController.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/9/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteCellHeadView.h"

#import "UIViewAdditions.h"
#import "UILableAddition.h"

#define Gap  10

@interface KDVoteCellHeadView ()
@property(retain,nonatomic) UIImageView *alter;
@property(retain,nonatomic) UIImageView *seperator;
@property(retain,nonatomic) SingleLineScaleLab * content;
@end

@implementation KDVoteCellHeadView
@synthesize alter = _alter;
@synthesize content = _content;
@synthesize alterText = _alterText;
@synthesize seperator = _seperator;

-(void)dealloc
{
    //KD_RELEASE_SAFELY(_alter);
    //KD_RELEASE_SAFELY(_content);
    //KD_RELEASE_SAFELY(_alterText);
    //KD_RELEASE_SAFELY(_seperator);
    //[super dealloc];
}

- (id)init{
    self = [super init];
    if (self) {
        [self addSubview:self.alter];
        [self.alter makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(self.mas_centerX).with.offset( -ScreenFullWidth / 3 );
             make.centerY.equalTo(self.mas_centerY);
             make.width.mas_equalTo(25);
             make.height.mas_equalTo(25);
         }];
    
        [self addSubview:self.content];
        [self.content makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.alter.mas_right).with.offset(Gap);
             make.top.and.bottom.and.right.equalTo(self).with.insets(UIEdgeInsetsMake(5, 0, 5, 30));
             make.centerY.equalTo(self);
         }];
        
        [self addSubview:self.seperator];
        [self.seperator makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.and.bottom.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 1));
             make.height.mas_equalTo(1);
         }];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.content setTextAvoidShowNull:self.alterText];
}
#pragma mark SingleLineScaleLabDelegate
-(void)singleLineScaleLab:(SingleLineScaleLab *)singleLineScaleLab
                textWidth:(CGFloat)textWidth
{
    CGFloat layoutSubViewWidth = CGRectGetWidth(self.alter.frame) + Gap + textWidth;
    
    [self.alter setLeft:(ScreenFullWidth-layoutSubViewWidth)/2];

    [self.content setLeft:CGRectGetMaxX(self.alter.frame) + Gap];
    [self.content setWidth:textWidth];
    
//    [self addSubview:self.content];
//    [self.content makeConstraints:^(MASConstraintMaker *make)
//     {
//         //             make.bottom.equalTo(self.bottomMargin).with.offset(-5);
//         make.left.equalTo(self.alter.mas_right).with.offset(Gap);
//         make.top.and.bottom.and.right.equalTo(self).with.insets(UIEdgeInsetsMake(5, 0, 5, 30));
//         make.centerY.equalTo(self);
//         //             make.width.mas_equalTo(ScreenFullWidth *2 / 3);
//     }];
//    self.alter.frame = CGRectMake(self.bounds.size.width/2 - layoutSubViewWidth/2, self.alter.frame.origin.y, self.alter.frame.size.width, self.alter.frame.size.height);
//    self.content.frame = CGRectMake(CGRectGetMaxX(self.alter.frame) + GAP_BETREENT_IMAGE_AND_TITLE, self.content.frame.origin.y, textWidth, self.content.frame.size.height);
    
    
//        [self.alter setRight:self.width/2-textWidth/2];
}

-(UIImageView *)alter
{
    if (_alter == nil) {
        _alter = [UIImageView new];
        _alter.image = [UIImage imageNamed:@"vote_tip_icon_v3.png"];
    }
    return _alter;
}

-(UIImageView *)seperator
{
    if (_seperator == nil) {
        _seperator = [UIImageView new];
        UIImage *image = [UIImage imageNamed:@"vote_seperator_v3.png"];
        image = [image stretchableImageWithLeftCapWidth:ScreenFullWidth topCapHeight:1];
        _seperator.image = image;
    }
    return _seperator;
}

-(SingleLineScaleLab*)content
{
    if (_content == nil) {
        _content = [SingleLineScaleLab new];
        _content.delegate_ = self;
        _content.textColor = [UIColor grayColor];
        _content.backgroundColor = [UIColor clearColor];
        _content.textAlignment = NSTextAlignmentCenter;
//        _content.font = [UIFont systemFontOfSize:17.f];
    }
    return _content;
}
@end
