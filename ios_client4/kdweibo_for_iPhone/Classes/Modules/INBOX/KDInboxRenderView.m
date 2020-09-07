//
//  KDInboxRenderView.m
//  kdweibo
//
//  Created by bird on 13-7-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDInboxRenderView.h"
#import "KDManagerContext.h"
#import "NSString+Additions.h"
#import "KDDefaultViewControllerContext.h"

#define KD_RENDER_INTERACTIVE_MARGIN_H 12.f

#define KD_RENDER_BOTTOM_MARGIN_H  10.f
#define KD_RENDER_LR_MARGIN_H  10.f

@implementation KDInboxRenderView
@synthesize inbox = inbox_;
@synthesize type=type_;

- (void)setupMessageInteractiveRenderView {
    
    UIImage *image = [UIImage imageNamed:@"inbox_comment_bg"];
    image = [image stretchableImageWithLeftCapWidth:30 topCapHeight:10];
    backgroundView_ = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundView_.image = image;
    backgroundView_.userInteractionEnabled = YES;
    [self addSubview:backgroundView_];
    
    // subject label
    contentLabel_ = [[KDStatusExpressionLabel alloc] initWithFrame:self.bounds andType:KDExpressionLabelType_Expression|KDExpressionLabelType_URL|KDExpressionLabelType_USERNAME|KDExpressionLabelType_TOPIC urlRespondFucIfNeed:NULL];
    contentLabel_.backgroundColor = [UIColor clearColor];
    contentLabel_.font = [UIFont systemFontOfSize:16.0];
    contentLabel_.textColor = MESSAGE_TOPIC_COLOR;
    //contentLabel_.textAlignment = UITextLayoutDirectionUp;
    contentLabel_.delegate = self;
    [self addSubview:contentLabel_];
    
    // content label
    replyLabel_ = [[KDStatusExpressionLabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-2*KD_RENDER_LR_MARGIN_H, self.bounds.size.height) andType:KDExpressionLabelType_Expression|KDExpressionLabelType_URL|KDExpressionLabelType_USERNAME|KDExpressionLabelType_TOPIC urlRespondFucIfNeed:NULL];
    replyLabel_.backgroundColor = [UIColor clearColor];
    replyLabel_.font = [UIFont systemFontOfSize:15.0];
    replyLabel_.textColor = MESSAGE_NAME_COLOR;
    //replyLabel_.textAlignment = UITextLayoutDirectionUp;
    replyLabel_.delegate = self;
    [backgroundView_ addSubview:replyLabel_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMessageInteractiveRenderView];
    }
    
    return self;
}

- (void)layout {
    CGSize size =  [contentLabel_ sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)];
    
    CGFloat offsetY = 0.0;
    CGRect rect = CGRectMake(0.0, offsetY, self.bounds.size.width, size.height);
    contentLabel_.frame = rect;
    
    CGFloat frameHeight = CGRectGetMaxY(rect) ;
    backgroundView_.hidden = replyNeedHiden_;
    if (!replyNeedHiden_) {
        
        size = [replyLabel_ sizeThatFits:CGSizeMake(self.bounds.size.width-2*KD_RENDER_LR_MARGIN_H, MAXFLOAT)];
        rect.origin.y = offsetY+rect.size.height;
        rect.size.height = size.height + KD_RENDER_INTERACTIVE_MARGIN_H + KD_RENDER_BOTTOM_MARGIN_H;
       
        backgroundView_.frame = rect;
        
        rect.origin.x = KD_RENDER_LR_MARGIN_H;
        rect.origin.y = KD_RENDER_INTERACTIVE_MARGIN_H;
        rect.size = size;
        
        replyLabel_.frame = rect;
        frameHeight = CGRectGetMaxY(backgroundView_.frame);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, frameHeight);
}

- (void)setInbox:(KDInbox *)inbox {
    if(inbox_ != inbox){
//        [inbox_ release];
        inbox_ = inbox;// retain];
        
        NSString    *content = [KDInboxRenderView contentText:inbox];
        NSString    *reply   = [KDInboxRenderView replyText:inbox];
        
        contentLabel_.text = content?content:@"";
        replyLabel_.text = reply?reply:@"";
        replyNeedHiden_=[reply length]==0;
        replyLabel_.hidden = replyNeedHiden_;
        type_ = [KDInboxRenderView setupType:inbox];
        
        [self layout];
    }
}
+ (KDInboxInteractiveType)setupType:(KDInbox *)inbox
{
    KDInboxInteractiveType type;
    if([inbox.type isEqual:@"Comment"])
        type = KDInboxInteractiveTypeComment;
    else if([inbox.type isEqual:@"Metion"])
        type = KDInboxInteractiveTypeMetion;
    else
        type = KDInboxInteractiveTypeUnknown;
    return type;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
+ (NSString *)contentText:(KDInbox *)inbox
{
    NSString *text = [inbox.latestFeed.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text == nil)    return @"";
    BOOL overflow = [text textLength] > 60;
    NSString *content = overflow ? [text substringToIndex:60] : text;
    
    return [NSString stringWithFormat:@"%@%@", content, overflow ? @"..." : @""];

}
+ (NSString *)replyText:(KDInbox *)inbox {
    
    NSString *text = [inbox.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text == nil)    return @"";
    
    BOOL overflow = [text textLength] > 60;
    NSString *content = overflow ? [text substringToIndex:60] : text;
    
    return [NSString stringWithFormat:@"%@：%@%@",(inbox.refUserName?inbox.refUserName:@""), content, overflow ? @"..." : @""];
}

+ (CGFloat)calculateInboxDisplaySize:(KDInbox *)inbox constrainedToSize:(CGSize)size {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    CGFloat height = 0.0;
    
    NSString *text = [KDInboxRenderView contentText:inbox];
    CGSize displaySize = [KDExpressionLabel sizeWithString:text constrainedToSize:size withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionUp textColor:MESSAGE_TOPIC_COLOR textFont:font];

    text = [KDInboxRenderView replyText:inbox];
    if ([text length]!=0) {
        font = [UIFont systemFontOfSize:15.0];
        height = displaySize.height + KD_RENDER_INTERACTIVE_MARGIN_H + KD_RENDER_BOTTOM_MARGIN_H;
        displaySize = [KDExpressionLabel sizeWithString:text constrainedToSize:CGSizeMake(size.width-2*KD_RENDER_LR_MARGIN_H, size.height) withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionUp textColor:MESSAGE_NAME_COLOR textFont:font];
    }
    
    height += displaySize.height;
    
    return height;
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickUserWithName:(NSString *)userName {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewControllerByName:userName sender:self];
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickTopicWithName:(NSString *)topicName {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showTopicViewControllerByName:topicName andStatue:inbox_ sender:self];
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickUrl:(NSString *)urlString {
    //[[KDWeiboAppDelegate getAppDelegate] openWebView:urlString];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showWebViewControllerByUrl:urlString sender:self];
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(backgroundView_);
    //KD_RELEASE_SAFELY(inbox_);
    //KD_RELEASE_SAFELY(contentLabel_);
    //KD_RELEASE_SAFELY(replyLabel_);
    //[super dealloc];
}
@end
