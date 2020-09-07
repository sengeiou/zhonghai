//
//  KDAttachmentIndicatorView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDAttachmentIndicatorView.h"

@interface KDAttachmentIndicatorView ()

@property(nonatomic, retain) UIImageView *backroundImageView;
@property(nonatomic, retain) UIImageView *dividerImageView;
@property(nonatomic, retain) UIButton *indicatorButton;
@property(nonatomic, retain) UILabel *infoLabel;

@end

@implementation KDAttachmentIndicatorView

@dynamic contentEdgeInsets;
@dynamic attachmentsCount;

@synthesize backroundImageView=backroundImageView_;
@synthesize dividerImageView=dividerImageView_;
@synthesize indicatorButton=indicatorButton_;
@synthesize infoLabel=infoLabel_;
@synthesize iconName = iconName_;

- (void)setupAttachmentIndicatorView {
    attachmentsCount_ = 0;
    contentEdgeInsets_ = UIEdgeInsetsZero;
    
    // indicator button
    indicatorButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    indicatorButton_.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [indicatorButton_ setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    [self addSubview:indicatorButton_];
    
    // info label
    infoLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    
    infoLabel_.backgroundColor = [UIColor clearColor];
    infoLabel_.textColor = MESSAGE_NAME_COLOR;
    infoLabel_.font = [UIFont systemFontOfSize:15.0];
    
    [self addSubview:infoLabel_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setupAttachmentIndicatorView];
        delegate_ = nil;
        iconName_ = @"document_btn_bg.png";
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    if(backroundImageView_ != nil){
        backroundImageView_.frame = self.bounds;
    }
    
    if(dividerImageView_ != nil){
        rect = self.bounds;
        rect.size.height = dividerImageView_.bounds.size.height;
        dividerImageView_.frame = rect;
    }
    
    rect = self.bounds;
    
    CGFloat x = rect.origin.x + contentEdgeInsets_.left;
    CGFloat y = rect.origin.y + contentEdgeInsets_.top;
    CGFloat w = rect.size.width - (contentEdgeInsets_.left + contentEdgeInsets_.right);
    CGFloat h = rect.size.height - (contentEdgeInsets_.top + contentEdgeInsets_.bottom);
    CGRect stageRect = CGRectMake(x, y, w, h);
    
    rect = indicatorButton_.bounds;
    rect.origin = CGPointMake(stageRect.origin.x, (stageRect.size.height - rect.size.height) * 0.5);
    indicatorButton_.frame = rect;
    
    CGFloat offsetX = rect.origin.x + rect.size.width + 12.0;
    CGFloat offsetY = CGRectGetMaxY(indicatorButton_.frame) - 28.f;
    rect = CGRectMake(offsetX, offsetY, stageRect.size.width - (offsetX - stageRect.origin.x), 30.0);
    infoLabel_.frame = rect;
}

- (void)setDefaultBackgroundImageStyle {
    UIImage *image = [UIImage imageNamed:@"repost_frame.png"];
    image = [image stretchableImageWithLeftCapWidth:(image.size.width * 0.5) topCapHeight:image.size.height * 0.5];
    
    [self setBackgroundImage:image];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if(backgroundImage != nil){
        if(backroundImageView_ == nil){
            backroundImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero]; 
            [self insertSubview:backroundImageView_ atIndex:0x00];
        }
        
        backroundImageView_.image = backgroundImage;
        [self setNeedsLayout];
        
    }else {
        if(backroundImageView_ != nil){
            if(backroundImageView_.superview != nil){
                [backroundImageView_ removeFromSuperview]; 
            }
            
            //KD_RELEASE_SAFELY(backroundImageView_);
        }
    }
}

- (void)setDividerImage:(UIImage *)dividerImage {
    if(dividerImage != nil){
        if(dividerImageView_ == nil){
            dividerImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero]; 
            [self addSubview:dividerImageView_];
        }
        
        dividerImageView_.image = dividerImage;
        [dividerImageView_ sizeToFit];
        
        [self setNeedsLayout];
    
    }else {
        if(dividerImageView_ != nil){
            if(dividerImageView_.superview != nil){
                [dividerImageView_ removeFromSuperview]; 
            }
            
            //KD_RELEASE_SAFELY(dividerImageView_);
        }
    }
    dividerImageView_.alpha = 0.f;
}

- (void)update {
    if(attachmentsCount_ > 0){
        [indicatorButton_ setImage:[UIImage imageNamed:iconName_] forState:UIControlStateNormal];
        [indicatorButton_ sizeToFit];
        
        infoLabel_.text = [NSString stringWithFormat:NSLocalizedString(@"%d_ATTACHMENTS", @""), attachmentsCount_];
        
    }else {
        [indicatorButton_ setImage:nil forState:UIControlStateNormal];
        infoLabel_.text = nil;
    }
    
    [self setNeedsLayout];
}

- (void)setAttachmentsCount:(NSUInteger)attachmentsCount {
    attachmentsCount_ = attachmentsCount;
    
    // update
    [self update];
}

- (NSUInteger)attachmentsCount {
    return attachmentsCount_;
}

- (UIEdgeInsets)contentEdgeInsets {
    return contentEdgeInsets_;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    if(!UIEdgeInsetsEqualToEdgeInsets(contentEdgeInsets_, contentEdgeInsets)){
        contentEdgeInsets_ = contentEdgeInsets;
        [self setNeedsLayout];
    }
}

+ (CGFloat)defaultAttachmentIndicatorViewHeight {
    return 56.0;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backroundImageView_);
    //KD_RELEASE_SAFELY(dividerImageView_);
    //KD_RELEASE_SAFELY(indicatorButton_);
    //KD_RELEASE_SAFELY(infoLabel_);
    
    //[super dealloc];
}

#pragma - mark  Touch Event handle
- (void)addTaget:(id)target selector:(SEL)selector {
    delegate_ = target;
    eventHandleSelector = selector;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (delegate_ && [delegate_ respondsToSelector:eventHandleSelector]) {
        [delegate_ performSelector:eventHandleSelector withObject:nil];
    }
}

@end
