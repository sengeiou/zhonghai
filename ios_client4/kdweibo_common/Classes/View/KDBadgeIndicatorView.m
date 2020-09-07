//
//  KDBadgeIndicatorView.m
//  kdweibo
//
//  Created by Laijiandong
//

#import "KDCommon.h"
#import "KDBadgeIndicatorView.h"


@interface KDBadgeIndicatorView ()

@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain) UILabel *textLabel;

@end


@implementation KDBadgeIndicatorView

@synthesize backgroundImageView=backgroundImageView_;
@synthesize textLabel=textLabel_;

@dynamic badgeValue;
@dynamic badgeColor;

- (void)setupBadgeIndicatorView {
    // background image layer
    backgroundImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    backgroundImageView_.hidden = YES;
    
    // set default badge image
    [self setBadgeBackgroundImage:[KDBadgeIndicatorView redBadgeBackgroundImage]];
    
    [self addSubview:backgroundImageView_];
    
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel_.hidden = YES;
    
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.font = [UIFont systemFontOfSize:12];
    textLabel_.textColor = [UIColor whiteColor];
    textLabel_.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:textLabel_];
    self.userInteractionEnabled = NO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        badgeValue_ = 0;
        
        contentSize_ = CGSizeZero;
        textMargin_x_ = 0.0;
        textMargin_y_ = 0.0f;
        [self setupBadgeIndicatorView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if([self badgeIndicatorVisible]){
        backgroundImageView_.frame = CGRectMake(0.0, 0.0, contentSize_.width, contentSize_.height);
        //修改计算坐标方法 song.wang 2014-01-14
//        textLabel_.frame = CGRectMake(textMargin_x_, textMargin_y_, contentSize_.width - 2*textMargin_x_, contentSize_.height - 2 * textMargin_y_);
        [textLabel_ sizeToFit];
        textLabel_.center = backgroundImageView_.center;
    }
}

- (void)calculateContentSize {
    NSString *badgeValueString = (badgeValue_ > 99) ? @"99+" : [NSString stringWithFormat:@"%ld", (long)badgeValue_];
    textLabel_.text = badgeValueString;

    if(badgeValue_ < 0) {
        textLabel_.text = nil;
    }
    
    CGSize size = [badgeValueString sizeWithFont:textLabel_.font constrainedToSize:CGSizeMake(600.0, 300.0)];
    
    CGFloat textPaddingWidth = 0.0;
    if(badgeValue_ > 9){
        textPaddingWidth = 8.0;
        size.width = size.width + textPaddingWidth;
    }
    
    CGSize imageSize = backgroundImageView_.image.size;
    CGFloat contentWidth = MAX(imageSize.width, size.width);
    CGFloat contentHeight = MAX(imageSize.height, size.height);
    contentSize_ = CGSizeMake(contentWidth, contentHeight);
    
    if(badgeValue_ == -1) {
        contentSize_ = [self backgroundImageView].image.size;
    }
    
    textMargin_x_ = (contentWidth - size.width) * 0.5;
    textMargin_y_ = (contentHeight - size.height) * 0.5;
}

- (void)reload {
    BOOL hidden = ([self badgeIndicatorVisible]) ? NO : YES;
    
    backgroundImageView_.hidden = hidden;
    textLabel_.hidden = hidden;
    
    if(!hidden){
        [self calculateContentSize];
        [self setNeedsLayout];
    }
}

- (CGSize)getBadgeContentSize {
    return contentSize_;
}

- (void)setBadgeValue:(NSUInteger)badgeValue {
    if(badgeValue_ != badgeValue){
        badgeValue_ = badgeValue;
        
        [self reload];
    }
}

- (NSUInteger)badgeValue {
    return badgeValue_;
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    textLabel_.textColor = badgeColor;
}

- (void)setbadgeTextFont:(UIFont *)font {
    textLabel_.font = font;
}

- (UIColor *)badgeColor {
    return textLabel_.textColor;
}

- (void)setBadgeBackgroundImage:(UIImage *)image {
    backgroundImageView_.image = image;
    [backgroundImageView_ sizeToFit];
}

- (BOOL)badgeIndicatorVisible {
    if(badgeValue_ == -1) {
        return YES;
    }else {
        return badgeValue_ > 0;
    }
}
+ (UIImage *)tipBadgeBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"common_img_new.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
+ (UIImage *)redBadgeBackgroundImage {
    UIImage *image = [UIImage imageNamed:@"common_img_new.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)redLeftBadgeBackgroundImag
{
    UIImage *image = [UIImage imageNamed:@"common_img_new.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)smallRedGroupBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"common_img_new.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(textLabel_);
    
    //[super dealloc];
}

@end


