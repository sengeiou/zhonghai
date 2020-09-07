//
//  KDApplicationTableViewCell.m
//  kdweibo
//
//  Created by 郑学明 on 14-4-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDApplicationTableViewCell.h"
#import "BOSImageNames.h"
#import "BaseAppDataModel.h"
#import "UIImageView+WebCache.h"

#import "KDAppDataModel.h"

#define kImageDefaultIcon           @"app_default_icon.png"

@interface KDApplicationTableViewCell ()
{
    UIImageView *appIconImageView;
    UILabel *appNameLabel;
    UILabel *appDescLabel;
    UIButton *viewDetailButton;
    UIImageView *separateLineImageView;
    BOOL hasDetail;  //是否显示详情
}
@end

@implementation KDApplicationTableViewCell

- (id)initWithStyleDetail:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self.appInfo.appDesc.length > 0) {
        hasDetail = YES;
    } else {
        hasDetail = NO;
    }
    if (self)
    {
        // Initialization code
        appIconImageView = [[UIImageView alloc] init];// autorelease];
        appIconImageView.image = [UIImage imageNamed:kImageDefaultIcon];
        [appIconImageView setFrame:CGRectMake(20.0, 9.0, 48.0, 48.0)];
        [appIconImageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
//        appIconImageView.layer.cornerRadius = (AppImageViewCornerRadius==-1?(CGRectGetHeight(appIconImageView.frame)/2):KApplicationCornerRadius(CGRectGetHeight(appIconImageView.frame)));
//        appIconImageView.layer.masksToBounds = YES;
//        appIconImageView.layer.shouldRasterize = YES;
//        appIconImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [appIconImageView roundMask];
        [self.contentView addSubview:appIconImageView];
        
        appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(appIconImageView.frame.origin.x + appIconImageView.bounds.size.width + 20.0,
                                                                 appIconImageView.frame.origin.y, 0.0, 20.0)] ;//autorelease];
        [appNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [appNameLabel setTextColor:[UIColor blackColor]];
        [appNameLabel setFont:[UIFont systemFontOfSize:15.0]];
        [appNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:appNameLabel];
        
        appDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(appNameLabel.frame.origin.x, appNameLabel.frame.origin.y + appNameLabel.bounds.size.height + 10.0,
                                                                  self.bounds.size.width - 24.0 - 70.0 -appNameLabel.frame.origin.x -5, 30.0)];// autorelease];
        [appDescLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [appDescLabel setNumberOfLines:2];
        [appDescLabel setTextColor:UIColorFromRGB(0x9a9a9a)];
        [appDescLabel setFont:[UIFont systemFontOfSize:12.0]];
        [appDescLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:appDescLabel];
        
        viewDetailButton = [UIButton whiteBtnWithTitle:ASLocalizedString(@"KDApplicationTableViewCell_check")];
        [viewDetailButton setTitleColor:FC5 forState:UIControlStateNormal];
        viewDetailButton.layer.borderWidth=1;
        viewDetailButton.layer.borderColor =FC5.CGColor;
        viewDetailButton.layer.cornerRadius = 12.5;
        viewDetailButton.layer.masksToBounds =YES;
        viewDetailButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [viewDetailButton setFrame:CGRectMake(self.bounds.size.width - 24.0 - 55.0, 10.0, 55.0, 25.0)];
        [viewDetailButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [viewDetailButton addTarget:self action:@selector(viewDetail) forControlEvents:UIControlEventTouchUpInside];
//        [viewDetailButton setBackgroundImage:
//         [[UIImage imageNamed:@"app_btn_view_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 21, 9)]
//                               forState:UIControlStateNormal];
//        [viewDetailButton setBackgroundImage:
//         [[UIImage imageNamed:@"app_btn_view_press"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 21, 9)]
//                               forState:UIControlStateHighlighted];
        [self.contentView addSubview:viewDetailButton];
        
        separateLineImageView = [[UIImageView alloc] init];// autorelease];
        separateLineImageView.backgroundColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0);
        [self.contentView addSubview:separateLineImageView];
        
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;//BOSCOLORWITHRGBA(0xEDEDED, 1.0);
        self.separatorLineSpace = 49 + 2*20.0;
    }
    
    return self;
}

- (id)initWithStyleSimple:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    hasDetail = NO;
    if (self)
    {
        // Initialization code
        appIconImageView = [[UIImageView alloc] init] ;//autorelease];
        appIconImageView.image = [UIImage imageNamed:kImageDefaultIcon];
        [appIconImageView setFrame:CGRectMake(20.0, 8.0, 49.0, 49.0)];
        [appIconImageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        appIconImageView.layer.cornerRadius = (AppImageViewCornerRadius==-1?(CGRectGetHeight(appIconImageView.frame)/2):KApplicationCornerRadius(CGRectGetHeight(appIconImageView.frame)));
        appIconImageView.layer.masksToBounds = YES;
        appIconImageView.layer.shouldRasterize = YES;
        appIconImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:appIconImageView];
        
        appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(appIconImageView.frame.origin.x + appIconImageView.bounds.size.width + 12.0, CGRectGetMinX(appIconImageView.frame), 0.0, 20.0)];// autorelease];
        [appNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [appNameLabel setTextColor:[UIColor blackColor]];
        [appNameLabel setFont:[UIFont systemFontOfSize:16.0]];
        [appNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:appNameLabel];
        
        viewDetailButton = [UIButton whiteBtnWithTitle:ASLocalizedString(@"KDApplicationTableViewCell_check")];
        [viewDetailButton setTitleColor:FC5 forState:UIControlStateNormal];
        viewDetailButton.layer.borderWidth=1;
        viewDetailButton.layer.borderColor =FC5.CGColor;
        viewDetailButton.layer.cornerRadius = 12.5;
        viewDetailButton.layer.masksToBounds =YES;
        viewDetailButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [viewDetailButton setFrame:CGRectMake(self.bounds.size.width - 12.0 - 55.0, 21.0, 55.0, 25.0)];
        [viewDetailButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [viewDetailButton addTarget:self action:@selector(viewDetail) forControlEvents:UIControlEventTouchUpInside];
        //[viewDetailButton setBackgroundImage:[[UIImage imageNamed:@"app_btn_addapp_normal"]  resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 20, 10)] forState:UIControlStateNormal];
        //[viewDetailButton setBackgroundImage:[[UIImage imageNamed:@"app_btn_addapp_press"]   resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 20, 10)] forState:UIControlStateHighlighted];
        [viewDetailButton setBackgroundImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
        [viewDetailButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
        viewDetailButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:viewDetailButton];
        
        separateLineImageView = [[UIImageView alloc] init];// autorelease];
        separateLineImageView.backgroundColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0);
        [self.contentView addSubview:separateLineImageView];
        
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;;//BOSCOLORWITHRGBA(0xFAFAFA, 1.0);
    }
    return self;
}

- (void) setAppInfo:(KDAppDataModel *)appInfo
{
    if (_appInfo != appInfo)
    {
        //BOSRELEASE_appInfo);
        _appInfo = appInfo;// retain];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (_appInfo != nil)
    {
        appIconImageView.hidden = NO;
        appNameLabel.hidden = NO;
        viewDetailButton.hidden = NO;
        if([self isEmpty:_appInfo.appLogo])
        {
            appIconImageView.image = [UIImage imageNamed:kImageDefaultIcon];
        }
        else
        {
            [appIconImageView setImageWithURL:[NSURL URLWithString:_appInfo.appLogo] placeholderImage:[UIImage imageNamed:kImageDefaultIcon]];
        }
        appIconImageView.center = CGPointMake(appIconImageView.center.x,self.frame.size.height/2);
        appNameLabel.text = _appInfo.appName;
        CGRect nameRect = [appNameLabel textRectForBounds:CGRectMake(0.0, 0.0, self.bounds.size.width - appNameLabel.frame.origin.x - 68.0, 16) limitedToNumberOfLines:1];
        appNameLabel.frame = CGRectMake(appNameLabel.frame.origin.x, appIconImageView.frame.origin.y, nameRect.size.width, 16.0);
        if(hasDetail)
        {
            appDescLabel.hidden = NO;
            appDescLabel.text = _appInfo.appDesc;
        }
        else
            appNameLabel.center = CGPointMake(appNameLabel.center.x,self.frame.size.height/2);
        
        
        viewDetailButton.center = CGPointMake(viewDetailButton.center.x,self.frame.size.height/2);
    }
    else
    {
        appIconImageView.hidden = YES;
        appNameLabel.hidden = YES;
        if(hasDetail)
            appDescLabel.hidden = YES;
        viewDetailButton.hidden = YES;
    }
    
    separateLineImageView.frame = CGRectMake(self.separatorLineSpace, CGRectGetHeight(self.bounds) - 1, ScreenFullWidth - self.separatorLineSpace, 0.5);
    
    [super layoutSubviews];
}

- (BOOL) isEmpty:(id)obj
{
    return obj == nil ||  [obj isKindOfClass:[NSNull class]]
    || [@"" isEqualToString:obj];
}

- (void)dealloc
{
    self.delegate = nil;
    //[super dealloc];
}

- (void)viewDetail
{
    if(self.delegate)
    {
        if(self.isExist)
        {
            if([self.delegate respondsToSelector:@selector(openApp:)])
               [_delegate openApp:_appInfo];
        }
        else
           [_delegate viewDetail:_appInfo];
    }
}

-(void)setIsExist:(BOOL)isExist
{
    _isExist = isExist;
    if(isExist)
    {
        [viewDetailButton setTitle:ASLocalizedString(@"KDApplicationTableViewCell_open")forState:UIControlStateNormal];
        [viewDetailButton setTitleColor:[UIColor colorWithRGB:0x9E9EA0] forState:UIControlStateNormal];
        [viewDetailButton setTitleColor:[UIColor colorWithRGB:0x9E9EA0] forState:UIControlStateHighlighted];
        viewDetailButton.layer.borderWidth=1;
        viewDetailButton.layer.borderColor =[UIColor colorWithRGB:0xDCE1E8].CGColor;
        viewDetailButton.layer.cornerRadius = 12.5;
        viewDetailButton.layer.masksToBounds =YES;
        [viewDetailButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:0xDCE1E8]] forState:UIControlStateNormal];
        [viewDetailButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:0xB8BEC6]] forState:UIControlStateHighlighted];
        [viewDetailButton setFrame:CGRectMake(self.bounds.size.width - 12.0 - 55.0, 21.0, 55.0, 25.0)];
    }
    else
    {
        [viewDetailButton setTitle:ASLocalizedString(@"KDApplicationTableViewCell_check")forState:UIControlStateNormal];
        [viewDetailButton setTitleColor:FC5 forState:UIControlStateNormal];
        viewDetailButton.layer.borderWidth=1;
        viewDetailButton.layer.borderColor =FC5.CGColor;
        viewDetailButton.layer.cornerRadius = 12.5;
        viewDetailButton.layer.masksToBounds =YES;
        [viewDetailButton setBackgroundImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
        [viewDetailButton setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
        [viewDetailButton setFrame:CGRectMake(self.bounds.size.width - 12.0 - 55.0, 21.0, 55.0, 25.0)];
    }
}
@end
