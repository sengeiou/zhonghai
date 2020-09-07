//
//  KDBadgeIndicatorView.h
//  kdweibo
//
//  Created by Laijaindong
//

@interface KDBadgeIndicatorView : UIView {
@private    
    UIImageView *backgroundImageView_;
    UILabel *textLabel_;
    
    NSInteger badgeValue_;
    
    CGSize contentSize_;
    CGFloat textMargin_x_;
    CGFloat textMargin_y_;
}

@property(nonatomic, assign) NSUInteger badgeValue;
@property(nonatomic, retain) UIColor *badgeColor;

- (void)setBadgeBackgroundImage:(UIImage *)image;

- (CGSize)getBadgeContentSize;
- (BOOL)badgeIndicatorVisible;
- (void)setbadgeTextFont:(UIFont *)font;

+ (UIImage *)tipBadgeBackgroundImage;
+ (UIImage *)redBadgeBackgroundImage;

+ (UIImage *)smallRedGroupBackgroundImage;
+ (UIImage *)redLeftBadgeBackgroundImag;
@end

