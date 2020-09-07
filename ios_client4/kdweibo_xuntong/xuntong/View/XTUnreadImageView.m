//
//  XTUnreadImageView.m
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTUnreadImageView.h"

#define UnreadImageView_Default_Frame CGRectMake(0.0, 0.0, 18.0, 18.0)

@interface XTUnreadImageView ()
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) UILabel *unreadLabel;
@end

@implementation XTUnreadImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.masksToBounds = YES;
        self.image = [XTImageUtil cellUnreadNumberImage];
        
        self.unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.5, 1.5, CGRectGetWidth(frame)-3, CGRectGetHeight(frame) - 3.0)];
        self.unreadLabel.backgroundColor = [UIColor clearColor];
        self.unreadLabel.textColor = [UIColor whiteColor];
        self.unreadLabel.textAlignment = NSTextAlignmentCenter;
        self.unreadLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:self.unreadLabel];
    }
    return self;
}

- (id)initWithParentView:(UIView *)parentView
{
    self = [self initWithFrame:UnreadImageView_Default_Frame];
    if (self) {
        self.parentView = parentView;
        
        [parentView addSubview:self];
    }
    return self;
}
- (void)setBGrey:(BOOL)bGrey
{
    _bGrey = bGrey;
    UIImage *imageGrey = [UIImage imageNamed:@"common_img_new_grey"];
    self.image = bGrey ? [imageGrey stretchableImageWithLeftCapWidth:imageGrey.size.width * 0.5 topCapHeight:imageGrey.size.height * 0.5] : [XTImageUtil cellUnreadNumberImage];
    [self layout];
}
- (id)init
{
    return [self initWithFrame:UnreadImageView_Default_Frame];
}

- (id)initWithImage:(UIImage *)image
{
    return [self initWithFrame:UnreadImageView_Default_Frame];
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    return [self initWithFrame:UnreadImageView_Default_Frame];
}

- (void)setUnreadCount:(int)unreadCount
{
    _unreadCount = unreadCount;
    [self layout];
}

- (void)layout
{
    NSString *unreadCountString = [NSString stringWithFormat:@"%d",self.unreadCount];
    if (self.unreadCount > 99) {
        unreadCountString = @"99+";
    }
    self.unreadLabel.text = unreadCountString;
    
    CGRect frame = self.unreadLabel.frame;
    //目前最多三位：99+
    if (unreadCountString.length == 1) {
        //一位数
        frame.size.width = 15.0;
    }
    else if (unreadCountString.length == 2) {
        //两位数
        frame.size.width = 19.0;
    }
    else {
        //其他
        frame.size.width = 25.0;
    }
    self.unreadLabel.frame = frame;
    
    frame = self.frame;
    frame.size.width = CGRectGetWidth(self.unreadLabel.frame) + 3.0;
    self.frame = frame;
    
    if (self.parentView != nil) {
        self.center = CGPointMake(CGRectGetWidth(self.parentView.frame) - 4, 3.5);
    }
}

@end
