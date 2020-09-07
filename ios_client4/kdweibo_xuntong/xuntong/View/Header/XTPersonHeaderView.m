//
//  XTPersonHeaderView.m
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonHeaderView.h"
#import "PersonSimpleDataModel.h"

@interface XTPersonHeaderView ()
@property (nonatomic, strong) XTPersonHeaderImageView *personHeaderImageView;
@property (nonatomic, strong) UIImageView *partnerImageVIew;
@property (nonatomic, strong) UILabel *personNameLabel;
@end

@implementation XTPersonHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderView)];
        [self addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHeaderView:)];
        [self addGestureRecognizer:longPress];

        float personNameLabelHeight = 16.0 * frame.size.width/frame.size.height;
        self.personHeaderImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.width) checkStatus:YES];
        [self addSubview:self.personHeaderImageView];
        
        self.partnerImageVIew= [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - personNameLabelHeight, personNameLabelHeight, personNameLabelHeight)];
        self.partnerImageVIew.image = [UIImage imageNamed:@"message_tip_shang_small"];
        //self.partnerImageVIew.backgroundColor = [UIColor blueColor];
        self.partnerImageVIew.hidden = YES;
        [self addSubview:self.partnerImageVIew];

        
        self.personNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.partnerImageVIew.frame), frame.size.height - personNameLabelHeight, frame.size.width, personNameLabelHeight)];
        self.personNameLabel.font = FS7;
        self.personNameLabel.textColor = FC1;
        self.personNameLabel.textAlignment = NSTextAlignmentCenter;
        self.personNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.personNameLabel];
        
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectMake(0.0, 0.0, 44.0, 68)];
}

- (void)setPerson:(PersonSimpleDataModel *)person
{
    if (_person != person) {
        _person = person;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
   // self.personHeaderImageView.person = self.person;
   // self.personNameLabel.text = self.person.personName;
   // if (_personDetail) {
   //     self.personNameLabel.hidden = NO;
   // }
    //else
    //    self.personNameLabel.hidden = YES;
    //if (self.tag == 1 || self.tag == 2) {
     //   self.personNameLabel.textColor = [UIColor blackColor];
     //   self.personNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
     //   CGRect frame = self.personNameLabel.frame;
    //    frame.origin.y += 4;
    //    self.personNameLabel.frame = frame;
   // }
    
   // [super layoutSubviews];
    self.personHeaderImageView.person = self.person;
//    CGRect headerFrame = self.personHeaderImageView.unActivatedLabel.frame;
    self.personHeaderImageView.unActivatedLabel.center = self.personHeaderImageView.center;
    self.personNameLabel.text = self.person.personName;
    
    float personNameLabelHeight = 16.0 * self.frame.size.width/self.frame.size.height;
    if(self.person && ![self.person isEmployee])
    {
        if(!self.hidePartnerImageView)
        {
            self.partnerImageVIew.hidden = NO;
            self.partnerImageVIew.frame = CGRectMake(0, self.frame.size.height - personNameLabelHeight, personNameLabelHeight, personNameLabelHeight);
        }
    }
    else
    {
        self.partnerImageVIew.hidden = YES;
        self.partnerImageVIew.frame = CGRectZero;
    }
    
    CGRect frame = self.personNameLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.partnerImageVIew.frame);
    frame.size.width = self.frame.size.width - frame.origin.x;
    self.personNameLabel.frame = frame;
    self.partnerImageVIew.center = CGPointMake(self.partnerImageVIew.center.x, self.personNameLabel.center.y);
    
    [super layoutSubviews];
}

- (void)tapHeaderView
{
    //帐号已注销
    if (![self.person accountAvailable]) {
        return;
    }
//    //公共帐号
//    if ([self.person isPublicAccount]) {
//        return;
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(personHeaderClicked:person:)]) {
        [self.delegate personHeaderClicked:self person:self.person];
    }
}

- (void)longPressHeaderView:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        //帐号已注销
        if (![self.person accountAvailable]) {
            return;
        }
        //公共帐号
        if ([self.person isPublicAccount]) {
            return;
        }
        if (self.longPressdelegate && [self.longPressdelegate respondsToSelector:@selector(personHeaderLongPressed:person:)]) {
            [self.longPressdelegate personHeaderLongPressed:self person:self.person];
        }
    }
}

@end
