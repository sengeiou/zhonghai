//
//  KDTaskHeaderView.m
//  kdweibo
//
//  Created by bird on 13-11-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskHeaderView.h"
#import "UIViewAdditions.h"
#import "NSDate+Additions.h"
#import "NSString+Additions.h"

#define KD_CONTENT_LEFT_MARGIN 48.f
#define KD_CONTENT_RIGHT_MARGIN 15.f
#define KD_CONTENT_TOP_MARGIN 9.f
#define KD_CONTENT_GAP_MARGIN 10.f

@implementation KDTaskHeaderView
@synthesize task =  task_;
@synthesize count = count_;
@synthesize delegate = delegate_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        backgroundView_ = [[UIImageView alloc] init];
        backgroundView_.backgroundColor = [UIColor kdBackgroundColor2];
        backgroundView_.userInteractionEnabled = YES;
        [self addSubview:backgroundView_];
        
        arrowImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        arrowImageView_.image = [UIImage imageNamed:@"task_editor_arrow"];
        [backgroundView_ addSubview:arrowImageView_];
        
        finishButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [finishButton_ setImage:[UIImage imageNamed:@"task_editor_select"] forState:UIControlStateNormal];
        [backgroundView_ addSubview:finishButton_];
        [finishButton_ addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect rect = self.bounds;
        rect.size.width -= KD_CONTENT_LEFT_MARGIN + KD_CONTENT_RIGHT_MARGIN;
        contentView_ = [[KDExpressionLabel alloc] initWithFrame:rect andType:KDExpressionLabelType_Expression urlRespondFucIfNeed:NULL];
        contentView_.backgroundColor = [UIColor clearColor];
        contentView_.font = [UIFont systemFontOfSize:16.0];
        contentView_.textColor = MESSAGE_TOPIC_COLOR;
        //contentView_.textAlignment = UITextLayoutDirectionUp;
        [backgroundView_ addSubview:contentView_];
        
        replyCountLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        replyCountLabel_.backgroundColor = [UIColor clearColor];
        replyCountLabel_.textColor = MESSAGE_DATE_COLOR;
        replyCountLabel_.font = [UIFont systemFontOfSize:14.0f];
        [backgroundView_ addSubview:replyCountLabel_];
        
        
        infoLabel_ = [[AttributedLabel alloc] initWithFrame:CGRectZero];
        infoLabel_.backgroundColor = [UIColor clearColor];
//        infoLabel_.textColor = MESSAGE_DATE_COLOR;
//        infoLabel_.font = [UIFont systemFontOfSize:14.0f];
        [backgroundView_ addSubview:infoLabel_];

    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(contentView_);
    //KD_RELEASE_SAFELY(infoLabel_);
    //KD_RELEASE_SAFELY(replyCountLabel_);
    //KD_RELEASE_SAFELY(arrowImageView_);
    //KD_RELEASE_SAFELY(task_);
    //KD_RELEASE_SAFELY(count_);
    //[super dealloc];
}
- (void)resetButtonState
{
    [finishButton_ setImage:[UIImage imageNamed:@"task_editor_select"] forState:UIControlStateNormal];
}
#pragma mark - Action
- (void)finishButtonClicked
{
    if ([task_ isOver])
    {
        if (delegate_ && [delegate_ respondsToSelector:@selector(taskCancelFinished)]) {
            [delegate_ taskCancelFinished];
        }
    }
    else
    {
        if ([task_ isCurrentUserFinish])
        {
            if (delegate_ && [delegate_ respondsToSelector:@selector(taskCancelFinished)]) {
                [delegate_ taskCancelFinished];
            }
        }
        else
        {
            if (delegate_ && [delegate_ respondsToSelector:@selector(taskFinished)]) {
                [delegate_ taskFinished];
            }
        }
        
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.origin.x = 10;
    rect.size = CGSizeMake(36, 36);
    finishButton_.frame = rect;
    
    if ([task_ isOver])
    {
        [finishButton_ setImage:[UIImage imageNamed:@"task_editor_finish"] forState:UIControlStateNormal];
        finishButton_.enabled = NO;
    }
    else
    {
        if ([task_ isCurrentUserFinish])
        {
            [finishButton_ setImage:[UIImage imageNamed:@"task_editor_finish"] forState:UIControlStateNormal];
            finishButton_.enabled = NO;
        }
        else
            [finishButton_ setImage:[UIImage imageNamed:@"task_editor_select"] forState:UIControlStateNormal];
        
    }
    
    
    NSString *contentText = [contentView_.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL overflow = [contentText textLength] > 130;
    NSString *contentSubStr = overflow ? [NSString stringWithFormat:@"%@...", [contentText substringToIndex:130]] : contentText;
    CGSize size = [KDExpressionLabel sizeWithString:contentSubStr constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - KD_CONTENT_LEFT_MARGIN - [NSNumber kdDistance1], CGFLOAT_MAX) withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionLeft textColor:FC1 textFont:FS4];
    rect.origin.x = KD_CONTENT_LEFT_MARGIN;
    rect.origin.y = [NSNumber kdDistance1];
    rect.size = CGSizeMake(CGRectGetWidth(self.bounds) - KD_CONTENT_LEFT_MARGIN - [NSNumber kdDistance1] , size.height);
    contentView_.frame = rect;
    contentView_.backgroundColor = [UIColor clearColor];
    
    rect.origin.y += rect.size.height + KD_CONTENT_GAP_MARGIN;
    rect.size.width = rect.size.width * 0.5F;
    rect.size.height = 16.f;
    
    replyCountLabel_.frame = rect;
    
    rect.origin.x += rect.size.width - 40.f;
    rect.size.width += 50.f - [NSNumber kdDistance1];
    infoLabel_.frame = rect;
    
    rect.origin.y += 17.f;
    rect.origin.x = KD_CONTENT_LEFT_MARGIN + 12.f;
    rect.size = arrowImageView_.image.size;
    
    arrowImageView_.frame = rect;
    
    rect = self.bounds;
    rect.size.height = CGRectGetMaxY(arrowImageView_.frame);
    backgroundView_.frame = rect;
    rect.origin.y = kd_StatusBarAndNaviHeight;
    self.frame = rect;
}
- (void)setTask:(KDTask *)task
{
    if (task_) {
//        [task_ release];
        task_ = nil;
    }
    
    task_ = task;// retain];
    
    contentView_.text = [KDTaskHeaderView getContentFromeString:task_.content];
    
    NSString *info = [NSString stringWithFormat:ASLocalizedString(@"KDTaskHeaderView_info"),[NSDate formatMonthOrDaySince1970WithDate:task_.createDate],task_.creator.username];
    [infoLabel_ setText:info];
    
    [infoLabel_ setFont:[UIFont systemFontOfSize:14.f] fromIndex:0 length:[info length]];
    [infoLabel_ setColor:MESSAGE_DATE_COLOR fromIndex:0 length:[[NSDate formatMonthOrDaySince1970WithDate:task_.createDate] length]];
    [infoLabel_ setColor:[UIColor colorWithRed:26/255.f green:133/255.f blue:255/255.f alpha:1.0] fromIndex:[[NSDate formatMonthOrDaySince1970WithDate:task_.createDate] length]+3 length:[task_.creator.username length]];
    [infoLabel_ setColor:MESSAGE_DATE_COLOR fromIndex:[[NSDate formatMonthOrDaySince1970WithDate:task_.createDate] length]+3+[task_.creator.username length] length:2];
    
    [self layoutSubviews];
    [self setNeedsDisplay];
}
- (void)setCount:(KDStatusCounts *)count
{
    if (count != count_) {
//        [count_ release];
        count_ = count;// retain];
        
        replyCountLabel_.text = [NSString stringWithFormat:ASLocalizedString(@"KDTaskHeaderView_replyCountLabel_text"),(long)count.commentsCount];
    }
}
+ (NSString *)getContentFromeString:(NSString *)content
{
    NSString *text = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text == nil)
        text = @"";
    
    BOOL overflow = [text textLength] > 30;
    return overflow ? [NSString stringWithFormat:@"%@...",[text substringToIndex:30]] : text;
}
+ (float)getHeightOfHeaderView:(KDTask *)task
{
    NSString *content = [KDTaskHeaderView getContentFromeString:task.content];
    
    CGSize size = [KDExpressionLabel sizeWithString:content constrainedToSize:CGSizeMake(320 - KD_CONTENT_LEFT_MARGIN - KD_CONTENT_RIGHT_MARGIN, CGFLOAT_MAX) withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionUp textColor:MESSAGE_TOPIC_COLOR textFont:[UIFont systemFontOfSize:16.0f]];
    
    size.height += KD_CONTENT_TOP_MARGIN + KD_CONTENT_GAP_MARGIN +25;
    
    return size.height;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
