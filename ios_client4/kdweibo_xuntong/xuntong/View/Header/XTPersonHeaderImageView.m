//
//  XTPersonHeaderImageView.m
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonHeaderImageView.h"
#import "PersonSimpleDataModel.h"

#define PersonHeader_Default_Frame CGRectMake(0.0, 0.0, 35.0, 35.0)

@interface XTPersonHeaderImageView ()
@end

@implementation XTPersonHeaderImageView

//- (id)initWithFrame:(CGRect)frame checkStatus:(BOOL)checkStatus withPublic:(BOOL)pub
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.contentMode = UIViewContentModeScaleAspectFit;
//        self.clipsToBounds = YES;
//        self.backgroundColor = BOSCOLORWITHRGBA(0xD9D7D7, 1.0);
//
//        self.checkStatus = checkStatus;
//        self.isPublic = pub;
//
//        CGSize headerMaxSize = CGSizeMake(35.0, 35.0);
//
//        if (pub) {
//            self.accountAvailableImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
//            self.accountAvailableImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
//            [self addSubview:self.accountAvailableImageView];
//        }
//        else {
//            self.accountAvailableImageView = [[UIImageView alloc] initWithImage:[XTImageUtil headerAccountAvailableImage]];
//            self.accountAvailableImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
//            [self addSubview:self.accountAvailableImageView];
//        }
//
//        if (checkStatus) {
//            self.xtAvailableImageView = [[UIImageView alloc] initWithImage:[XTImageUtil headerXTAvailableImage]];
//            CGFloat imageWidth = CGRectGetWidth(frame) >= headerMaxSize.width ? CGRectGetWidth(self.xtAvailableImageView.bounds) : CGRectGetWidth(self.xtAvailableImageView.bounds) * (CGRectGetWidth(frame) / headerMaxSize.width);
//            CGFloat imageHeight = CGRectGetHeight(frame) >= headerMaxSize.height ? CGRectGetHeight(self.xtAvailableImageView.bounds) : CGRectGetHeight(self.xtAvailableImageView.bounds) * (CGRectGetHeight(frame) / headerMaxSize.height);
//            self.xtAvailableImageView.frame = CGRectMake(0.0, CGRectGetHeight(frame) - imageHeight, imageWidth, imageHeight);
//            [self addSubview:self.xtAvailableImageView];
//        }
//
//    }
//    return self;
//
//}

- (id)initWithFrame:(CGRect)frame checkStatus:(BOOL)checkStatus
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor kdBackgroundColor2];
        
        self.checkStatus = checkStatus;
        
        CGSize headerMaxSize = CGSizeMake(35.0, 35.0);
        
//        self.accountAvailableImageView = [[UIImageView alloc] initWithImage:[XTImageUtil headerAccountAvailableImage]];
//        self.accountAvailableImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
//        [self addSubview:self.accountAvailableImageView];
        
        if (checkStatus) {
            /*
            self.xtAvailableImageView = [[UIImageView alloc] initWithImage:[XTImageUtil headerXTAvailableImage]];
            self.xtAvailableImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
            CGFloat imageWidth = CGRectGetWidth(frame) >= headerMaxSize.width ? CGRectGetWidth(self.xtAvailableImageView.bounds) : CGRectGetWidth(self.xtAvailableImageView.bounds) * (CGRectGetWidth(frame) / headerMaxSize.width);
            CGFloat imageHeight = CGRectGetHeight(frame) >= headerMaxSize.height ? CGRectGetHeight(self.xtAvailableImageView.bounds) : CGRectGetHeight(self.xtAvailableImageView.bounds) * (CGRectGetHeight(frame) / headerMaxSize.height);
            self.xtAvailableImageView.frame = CGRectMake(CGRectGetWidth(frame) - imageWidth, CGRectGetHeight(frame) - imageHeight, imageWidth, imageHeight);
            */
            self.xtAvailableImageView = [[UIImageView alloc] initWithImage:[XTImageUtil headerXTAvailableImage]];
            self.xtAvailableImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            [self addSubview:self.xtAvailableImageView];
            
            UILabel *unactivatedLabel = [[UILabel alloc] init];
            unactivatedLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            unactivatedLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_un_active");
            unactivatedLabel.textAlignment = NSTextAlignmentCenter;
            unactivatedLabel.textColor = [UIColor colorWithRed:77/256.0 green:94/256.0 blue:105/256.0 alpha:1];
            
            unactivatedLabel.font = [UIFont systemFontOfSize:10];
            [unactivatedLabel sizeToFit];
            CGRect unactivatedFrame = unactivatedLabel.frame;
            unactivatedFrame.origin.x -= unactivatedFrame.size.width/2;
            unactivatedFrame.origin.y -= unactivatedFrame.size.height/2;
            unactivatedLabel.frame = unactivatedFrame;
            
            self.unActivatedLabel = unactivatedLabel;
            
            [self addSubview:unactivatedLabel];
        }
        
    }
    return self;
}

//- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
//{
//    UIImage *tempImage = nil;
//    CGSize targetSize = size;
//    UIGraphicsBeginImageContext(targetSize);
//    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
//    thumbnailRect.origin = CGPointMake(0.0,0.0);
//    thumbnailRect.size.width  = targetSize.width;
//    thumbnailRect.size.height = targetSize.height;
//    [image drawInRect:thumbnailRect];
//    tempImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return tempImage;
//}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame checkStatus:YES];
}

- (id)init
{
    return [self initWithFrame:PersonHeader_Default_Frame];
}

- (void)setPerson:(PersonSimpleDataModel *)person
{
    if (_person != person) {
        _person = person;
    }
    [self layout];
}
- (void)layout
{
    NSURL *imageURL = nil;
    
    [self updateLabelText];
    
    if (self.person == nil) {
        //self.accountAvailableImageView.hidden = YES;
        self.xtAvailableImageView.hidden = YES;
        self.unActivatedLabel.hidden = YES;
    } else {
        
        if ([self.person isPublicAccount]) {
            imageURL = [self.person hasHeaderPicture] ? [NSURL URLWithString:self.person.photoUrl] : nil;
        } else {
            if ([self.person hasHeaderPicture]) {
                NSString *url = self.person.photoUrl;
                if ([url rangeOfString:@"?"].location != NSNotFound) {
                    url = [url stringByAppendingFormat:@"&spec=180"];
                }
                else {
                    url = [url stringByAppendingFormat:@"?spec=180"];
                }
                imageURL = [NSURL URLWithString:url];
            }
            else {
                imageURL = nil;
            }
        }
        
        if (self.checkStatus && ![self.person isPublicAccount]) {
            //self.accountAvailableImageView.hidden = [self.person accountAvailable];
            if([self.person accountAvailable])
            {
                self.xtAvailableImageView.hidden = [self.person accountAvailable] && [self.person xtAvailable];
                self.unActivatedLabel.hidden = [self.person accountAvailable] && [self.person xtAvailable];
            }
            else
            {
                self.xtAvailableImageView.hidden = NO;
                self.unActivatedLabel.hidden = NO;
            }
        } else {
            //self.accountAvailableImageView.hidden = YES;
            self.xtAvailableImageView.hidden = YES;
            self.unActivatedLabel.hidden = YES;
        }
        
    }
    
    if (self.bSouldCompress)
    {
        [self setImageWithURL:imageURL placeholderImage:[XTImageUtil headerDefaultImage] scale:SDWebImageScaleAvatar];
    }
    else
    {
        [self setImageWithURL:imageURL placeholderImage:[XTImageUtil headerDefaultImage] scale:SDWebImageScaleThumbnail];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetWidth(self.frame)/2):ImageViewCornerRadius);
    self.layer.masksToBounds = YES;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.unActivatedLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

-(void)updateLabelText
{
    if([self.person accountAvailable])
    {
        if(![self.person xtAvailable])
            self.unActivatedLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_un_active");
    }
    else
    {
        self.unActivatedLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_canceled");
    }
    [self.unActivatedLabel sizeToFit];
    self.unActivatedLabel.center = CGPointMake(self.frame.size.width/2, self.unActivatedLabel.center.y);
}

@end
