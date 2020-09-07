//
//  KDLeftNavBadgeIndicatorView.m
//  kdweibo_common
//
//  Created by Tan yingqi on 12-12-18.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDLeftNavBadgeIndicatorView.h"

@interface KDLeftNavBadgeIndicatorView ()

@property(nonatomic,retain)UIImageView *bgImageView;
@property(nonatomic,retain)UILabel *textLabel;
@end

@implementation KDLeftNavBadgeIndicatorView
@synthesize bgImageView = bgImageView_;
@synthesize textLabel = textLabel_;
@synthesize count = count_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:imageView];
        imageView.contentMode = UIViewContentModeCenter;
        self.bgImageView = imageView;
//        [imageView release];
        
        //self.backgroundColor = [UIColor yellowColor];
        //CGRect frame = self.frame;
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.backgroundColor = [UIColor clearColor];
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont boldSystemFontOfSize:13];
        lable.adjustsFontSizeToFitWidth = YES;
        [self addSubview:lable];
        self.textLabel = lable;
//        [lable release];
        
        self.autoresizesSubviews = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgImageView.frame = self.bounds;
    CGRect frame = self.textLabel.frame;
    frame.origin.y= 2;
    frame.origin.x = (self.bounds.size.width - frame.size.width)*0.5;
    self.textLabel.frame = frame;

}

- (void)setCount:(NSInteger)count type:(NSInteger)type {
    if (type == 0) {
        [self setCount:count];
    }else if(type == 1) {
        self.textLabel.text = nil;
        if (count > 0) {
            self.bgImageView.image = [UIImage imageNamed:@"green_point_v2"];
        }else {
            self.bgImageView.image = nil;
        }
    }else if(type == -1) {
        self.textLabel.text = nil;
        self.bgImageView.image = [UIImage imageNamed:@"dm_thread_cell_unsend_audio_cell_v2"];
    }
    
}

- (void)setCount:(NSInteger)count {
        count_ = count;
        if (count_ == 0) {
            self.textLabel.text = nil;
            self.bgImageView.image = nil;
        }else {
            NSString *text = count_ >99?@"99+":[NSString stringWithFormat:@"%ld",(long)count_];
            textLabel_.text = text;
            [textLabel_ sizeToFit];
             self.bgImageView.image = [UIImage imageNamed:@"left_nav_dialogue_badge_bg"];
        }
    [self setNeedsLayout];
}

- (void)dealloc {
//    [bgImageView_ release];
    bgImageView_ = nil;
    
//    [textLabel_ release];
    textLabel_ = nil;
    
    //[super dealloc];
   
}

@end
