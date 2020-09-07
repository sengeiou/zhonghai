//
//  KDLeftMenuCell.m
//  kdweibo
//
//  Created by gordon_wu on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//
#define CONTENT_LABEL_TAG 300
#define NUMBER_BTN_TAG    301
#define ROW_HEIGHT 64.f
#import "KDLeftMenuCommunityCell.h"
#import "UIImage+XT.h"

@implementation KDLeftMenuCommunityCell
@synthesize mainView            = mainView_;
@synthesize statusLabel         = statusLabel_;
@synthesize contentLabel        = contentLabel_;
@synthesize imageView           = imageView_;
@synthesize badgeIndicatorView  = badgeIndicatorView_;
@synthesize separatorView       = separatorView_;

#define kCompanyColor RGBCOLOR(27, 123, 238)
#define kCommnuityColor RGBCOLOR(45, 190, 32)
#define kTeamColor RGBCOLOR(252, 102, 32)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImage * arrowImage  = [UIImage imageNamed:@"arrow_normal"];
        
        mainView_                     = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
        mainView_.autoresizingMask    = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:mainView_];
        
        contentLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(15,(self.bounds.size.height-18)/2,self.bounds.size.width-arrowImage.size.width-160,18)];
        contentLabel_.font      = [UIFont systemFontOfSize:16];
        contentLabel_.tag       = CONTENT_LABEL_TAG;
        contentLabel_.textColor = [UIColor grayColor];
        contentLabel_.backgroundColor=[UIColor clearColor];
        [mainView_ addSubview:contentLabel_];
        
        statusLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        statusLabel_.font      = [UIFont systemFontOfSize:14];
        statusLabel_.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65f];
        statusLabel_.backgroundColor=[UIColor clearColor];
        [mainView_ addSubview:statusLabel_];
        
        // badge indicator view
        badgeIndicatorView_ = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
        [badgeIndicatorView_ setBadgeBackgroundImage:[KDBadgeIndicatorView redLeftBadgeBackgroundImag]];
        [badgeIndicatorView_ setBadgeColor:[UIColor whiteColor]];
        [badgeIndicatorView_ setbadgeTextFont:[UIFont systemFontOfSize:12]];
        [mainView_ addSubview:badgeIndicatorView_];
        
        imageView_       = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-arrowImage.size.width- 25.f, CGRectGetMidY(contentLabel_.frame) - arrowImage.size.height * 0.5, arrowImage.size.width, arrowImage.size.height)];
        imageView_.alpha = 0.5f;
        imageView_.image = arrowImage;
//        [mainView_ addSubview:imageView_];
        
        hintImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMinY(contentLabel_.frame), 5.f, ROW_HEIGHT)];
        [mainView_ addSubview:hintImageView_];
        
         separatorView_ = [[UIView alloc] init];
        separatorView_.backgroundColor = UIColorFromRGBA(0x5a6070, 0.3);
        [mainView_ addSubview:separatorView_];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rect = contentLabel_.frame;
    rect.origin.y = (CGRectGetHeight(self.bounds)-rect.size.height)*.5f;
    contentLabel_.frame = rect;
    
    rect.origin.x = CGRectGetMaxX(rect) +20.f;
    rect.size.width = 50.f;
    statusLabel_.frame = rect;
    
    rect = imageView_.frame;
    rect.origin.y = (CGRectGetHeight(self.bounds)-rect.size.height)*.5f;
    imageView_.frame = rect;
    
    CGSize size= [badgeIndicatorView_ getBadgeContentSize];
    badgeIndicatorView_.frame = CGRectMake(CGRectGetWidth(self.bounds) - 56.f - size.width, (CGRectGetHeight(self.bounds) - size.height)*0.5f, size.width, size.height);
    
    rect = hintImageView_.frame;
    rect.origin.y = (CGRectGetHeight(self.bounds)-rect.size.height)*.5f;
    hintImageView_.frame = rect;
    
    separatorView_.frame = CGRectMake(15, CGRectGetHeight(self.bounds) - 1.0f, CGRectGetWidth(self.bounds)- 15.f, 1.f);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
}

- (void)setSelectedBg:(BOOL)selected
{
    UIImage * arrowImage = [UIImage imageNamed:@"arrow_normal"];
    if (selected) {
        UIImage *img = nil;
//        img = [UIImage imageWithColor:kCompanyColor];
        img = [UIImage imageNamed:@"bg_biue"];
        [self showHintImage:img];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = UIColorFromRGBA(0xffffff, 0.1);
        arrowImage = [UIImage imageNamed:@"arrow_light"];
    }
    else {
        self.contentLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        [self showHintImage:nil];
        self.backgroundColor = [UIColor clearColor];
    }
    imageView_.image = arrowImage;
    self.accessoryView = [[UIImageView alloc] initWithImage:arrowImage];// autorelease];
}

- (void)showHintImage:(UIImage *)image
{
    hintImageView_.image = image;
}

- (void)prepareForReuse
{
}

- (void) dealloc
{
    //KD_RELEASE_SAFELY(statusLabel_);
    //KD_RELEASE_SAFELY(mainView_);
    //KD_RELEASE_SAFELY(contentLabel_);
    //KD_RELEASE_SAFELY(imageView_);
    //KD_RELEASE_SAFELY(badgeIndicatorView_);
    //KD_RELEASE_SAFELY(hintImageView_);
    //[super dealloc];
}


@end
