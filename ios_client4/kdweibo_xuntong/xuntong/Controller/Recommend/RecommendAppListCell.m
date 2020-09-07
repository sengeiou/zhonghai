//
//  RecommendAppListCell.m
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import "RecommendAppListCell.h"
#import "BOSImageNames.h"

@implementation RecommendAppListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _appIcon = [[UIImageView alloc] init] ;//autorelease];
        _appIcon.image = [UIImage imageNamed:IMAGE_RECOMMEND_APP_DEFAULT_ICON];
        [_appIcon setFrame:CGRectMake(18.0, 18.0, 52.0, 52.0)];
        [_appIcon setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.contentView addSubview:_appIcon];
        
        _appName = [[UILabel alloc] initWithFrame:CGRectMake(_appIcon.frame.origin.x + _appIcon.bounds.size.width + 10.0, _appIcon.frame.origin.y, 0.0, 16.0)];// autorelease];
        [_appName setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [_appName setTextColor:[UIColor blackColor]];
        [_appName setFont:[UIFont systemFontOfSize:15.0]];
        [_appName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_appName];
        
        _newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMAGE_RECOMMEND_NEW]];// autorelease];
        [_newImageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [_newImageView setHidden:YES];
        [self.contentView addSubview:_newImageView];
        
        _appDesc = [[UILabel alloc] initWithFrame:CGRectMake(_appName.frame.origin.x, _appName.frame.origin.y + _appName.bounds.size.height + 6.0, self.bounds.size.width - _appName.frame.origin.x - 68.0, 30.0)];// autorelease];
        [_appDesc setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_appDesc setNumberOfLines:2];
        [_appDesc setTextColor:BOSCOLORWITHRGBA(0x7f7f7f, 1.0)];
        [_appDesc setFont:[UIFont systemFontOfSize:12.0]];
        [_appDesc setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_appDesc];
        
        _tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tryButton setFrame:CGRectMake(self.bounds.size.width - 12.0 - 46.0, 30.0, 46.0, 27.0)];
        [_tryButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_tryButton addTarget:self action:@selector(try) forControlEvents:UIControlEventTouchUpInside];
        [_tryButton setBackgroundImage:[UIImage imageNamed:IMAGE_RECOMMEND_BUTTON_TRY] forState:UIControlStateNormal];
        [_tryButton setBackgroundImage:[UIImage imageNamed:IMAGE_RECOMMEND_BUTTON_TRY_HIGHLIGHT] forState:UIControlStateHighlighted];
        [self.contentView addSubview:_tryButton];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];// autorelease];
        _activityIndicatorView.frame = CGRectMake(88.0, 5.0, 34, 34);
        [self.contentView addSubview:_activityIndicatorView];
        _moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(132.0, 5.0, 100, 34)];// autorelease];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.text = ASLocalizedString(@"KDStatusDetailViewController_loading");
        [self.contentView addSubview:_moreLabel];
    }
    return self;
}

- (void) setAppInfo:(RecommendAppDataModel *)appInfo
{
    if (_appInfo != appInfo) {
        //BOSRELEASE_appInfo);
        _appInfo = appInfo;// retain];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (_appInfo != nil) {
        _appIcon.hidden = NO;
        _appName.hidden = NO;
        _newImageView.hidden = NO;
        _appDesc.hidden = NO;
        _tryButton.hidden = NO;
        _activityIndicatorView.hidden = YES;
        [_activityIndicatorView stopAnimating];
        _moreLabel.hidden = YES;
        
        if (_appInfo.appLogo != nil && ![@"" isEqualToString:_appInfo.appLogo]) {
            [_appIcon setImageWithURL:[NSURL URLWithString:_appInfo.appLogo]];
        }else{
            [_appIcon setImageWithURL:nil];
        }
        
        _appName.text = _appInfo.appName;
        CGRect nameRect = [_appName textRectForBounds:CGRectMake(0.0, 0.0, self.bounds.size.width - _appName.frame.origin.x - 68.0, 16) limitedToNumberOfLines:1];
        _appName.frame = CGRectMake(_appName.frame.origin.x, _appName.frame.origin.y, nameRect.size.width, 16.0);
        
        if (_appInfo.newer) {
            [_newImageView setHidden:NO];
            _newImageView.center = CGPointMake(_appName.frame.origin.x + _appName.bounds.size.width + _newImageView.bounds.size.width/2, _appName.frame.origin.y);
        }else{
            [_newImageView setHidden:YES];
        }
        
        _appDesc.text = _appInfo.appDesc;
    }else{
        _appIcon.hidden = YES;
        _appName.hidden = YES;
        _newImageView.hidden = YES;
        _appDesc.hidden = YES;
        _tryButton.hidden = YES;
        _activityIndicatorView.hidden = NO;
        [_activityIndicatorView startAnimating];
        _moreLabel.hidden = NO;
    }
    
    [super layoutSubviews];
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)try
{
    if (_appInfo.downloadURL != nil && ![@"" isEqualToString:_appInfo.downloadURL]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_appInfo.downloadURL]];
    }
}

@end
