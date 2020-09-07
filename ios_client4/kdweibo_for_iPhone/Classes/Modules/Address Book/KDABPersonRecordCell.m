//
//  KDABPersonRecordCell.m
//  kdweibo
//
//  Created by laijiandong on 12-11-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDABPersonRecordCell.h"
#import "KDABPersonActionCell.h"

#import "MPFoldTransition.h"

#define TOP_LINE_TAG      101
#define LEFT_LINE_TAG     102
#define BOTTOM_LINE_TAG   103
#define RIGH_LINE_TAG     104

NS_INLINE UIView * borderView(NSInteger tag) {
    UIView *v = [[UIView alloc] init];
    v.tag = tag;
    v.backgroundColor = RGBCOLOR(203, 203, 203);
    
    return v;// autorelease];
}

@interface KDABPersonRecordCell ()

@property (nonatomic, retain) UIView *dashedView;
@end

@implementation KDABPersonRecordCell

@synthesize subjectLabel=subjectLabel_;
@synthesize recordButton=recordButton_;
@synthesize indicatorButton = indicatorButton_;
@synthesize showDashed = _showDashed;
@synthesize dashedView = _dashedView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupABPersonRecordCell];
        _showDashed = NO;
    }
    
    return self;
}

- (void)_setupABPersonRecordCell {
    self.backgroundView = nil;
    self.backgroundColor = RGBCOLOR(250, 250, 250);
    self.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
    
    UIImage *dashedImage = [UIImage imageNamed:@"ab_cell_dashed.png"];
    _dashedView = [[UIView alloc] initWithFrame:CGRectZero];
    _dashedView.backgroundColor = [UIColor colorWithPatternImage:dashedImage];
    _dashedView.hidden = YES;
    [super.contentView addSubview:_dashedView];
    
    // subject label
    subjectLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
	subjectLabel_.backgroundColor = [UIColor clearColor];
    subjectLabel_.font = [UIFont systemFontOfSize:15.0];
	subjectLabel_.textColor = RGBCOLOR(62, 62, 62);
	
    [super.contentView addSubview:subjectLabel_];
    
    // record button;/
    recordButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    recordButton_.titleLabel.textAlignment = NSTextAlignmentLeft;
    recordButton_.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    [recordButton_ setTitleColor:RGBCOLOR(62, 62, 62) forState:UIControlStateNormal];
    [recordButton_ setTitleColor:RGBCOLOR(34.0f, 143.0f, 218.0f) forState:UIControlStateHighlighted];
    
    [super.contentView addSubview:recordButton_];
    
    //indicator view
    indicatorButton_ = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    [indicatorButton_ setImage:[UIImage imageNamed:@"user_profile_drop_right_narrow_v3.png"] forState:UIControlStateNormal];
    [indicatorButton_ setImage:[UIImage imageNamed:@"user_profile_drop_down_narrow_v3.png"] forState:UIControlStateSelected];
    [indicatorButton_ sizeToFit];
    
    [super.contentView addSubview:indicatorButton_];
    
    //set up border
    [self addSubview:borderView(TOP_LINE_TAG)];
    [self addSubview:borderView(LEFT_LINE_TAG)];
    [self addSubview:borderView(BOTTOM_LINE_TAG)];
    [self addSubview:borderView(RIGH_LINE_TAG)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _dashedView.frame = CGRectMake(0.0f, CGRectGetHeight(self.bounds) - 2.0f, CGRectGetWidth(self.bounds), 2.0f);
    
    // subject label
    CGFloat offsetX = 12.0;
    CGRect rect = CGRectMake(offsetX, 0.0, 80.0, CGRectGetHeight(self.bounds));
    subjectLabel_.frame = rect;
    
    [self layoutRecordButton];
    
    indicatorButton_.frame = CGRectMake(CGRectGetWidth(self.bounds) - 17.0f - CGRectGetWidth(indicatorButton_.bounds), (CGRectGetHeight(self.bounds) - CGRectGetHeight(indicatorButton_.bounds)) * 0.5f, CGRectGetWidth(indicatorButton_.bounds), CGRectGetHeight(indicatorButton_.bounds));
    
    UIView *top = [self viewWithTag:TOP_LINE_TAG];
    if(top) {
        top.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5f);
    }
    
    UIView *left = [self viewWithTag:LEFT_LINE_TAG];
    if(left) {
        left.frame = CGRectMake(0, 0, 0.5f, CGRectGetHeight(self.bounds));
    }
    
    UIView *bottom = [self viewWithTag:BOTTOM_LINE_TAG];
    if(bottom) {
        bottom.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5f, CGRectGetWidth(self.bounds), 0.5f);
    }
    
    UIView *right = [self viewWithTag:RIGH_LINE_TAG];
    if(right) {
        right.frame = CGRectMake(CGRectGetWidth(self.bounds) - 0.5f, 0.0f, 0.5f, CGRectGetHeight(self.bounds));
    }
}

- (void)setShowDashed:(BOOL)showDashed {
    if(showDashed != _showDashed) {
        _showDashed = showDashed;
        
        _dashedView.hidden = !showDashed;
        
        UIView *bottom = [self viewWithTag:BOTTOM_LINE_TAG];
        if(bottom) {
            bottom.hidden = showDashed;
        }
    }
}

- (void)setIndicatorButtonExpand:(BOOL)expand
{
    indicatorButton_.selected = expand;
    
    [self setShowDashed:expand];
}

- (void)layoutRecordButton {
    CGFloat offsetX = CGRectGetMaxX(subjectLabel_.frame) + 15.0f;
    CGRect rect = CGRectMake(offsetX, 0.0, MIN(recordButton_.bounds.size.width, CGRectGetWidth(self.bounds) - offsetX - 2.0f), CGRectGetHeight(self.bounds));
    recordButton_.frame = rect;
}

- (void)update:(NSString *)subject value:(NSString *)value enabled:(BOOL)enabled {
    subjectLabel_.text = subject;
    
    [recordButton_ setTitle:value forState:UIControlStateNormal];
    [recordButton_ sizeToFit];
    recordButton_.enabled = enabled;
    
    [self layoutRecordButton];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(subjectLabel_);
    //KD_RELEASE_SAFELY(recordButton_);
    
    //[super dealloc];
}

@end
