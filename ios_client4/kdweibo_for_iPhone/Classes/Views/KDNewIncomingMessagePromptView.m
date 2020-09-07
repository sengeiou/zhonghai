//
//  KDNewIncomingMessagePromptView.m
//  kdweibo_common
//
//  Created by Tan Yingqi on 13-12-17.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDNewIncomingMessagePromptView.h"
@interface KDNewIncomingMessagePromptView()
@property (nonatomic,retain)UILabel *label;
@end
@implementation KDNewIncomingMessagePromptView
@synthesize label = label_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bounds = CGRectMake(0, 0, ScreenFullWidth, 30);
        self.backgroundColor = RGBCOLOR(22, 22, 22);
        self.alpha = 0.76;
        label_ = [[UILabel alloc] initWithFrame:CGRectZero];
        label_.font = [UIFont systemFontOfSize:15.0f];
        label_.textColor = RGBCOLOR(49, 145, 253);
        label_.backgroundColor = [UIColor clearColor];
        [self addSubview:label_];
        
    }
    return self;
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    if (userInfo!= userInfo_) {
//        [userInfo_  release];
        userInfo_ = userInfo;// /retain];
        NSString *message = [userInfo_ objectForKey:@"message"];
        label_.text = message;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [label_ sizeToFit];
    label_.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(label_);
    //[super dealloc];
}
@end
