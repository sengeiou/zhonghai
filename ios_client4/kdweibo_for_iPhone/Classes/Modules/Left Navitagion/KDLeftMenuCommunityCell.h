//
//  KDLeftMenuCell.h
//  kdweibo
//
//  Created by gordon_wu on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDBadgeIndicatorView.h"
@interface KDLeftMenuCommunityCell : UITableViewCell
{
    UIImageView *hintImageView_;
}

@property (nonatomic,retain ) UILabel     * statusLabel;
@property (nonatomic,retain ) UILabel     * contentLabel;
@property (nonatomic,retain ) UIView      * mainView;
@property (nonatomic,retain ) UIImageView * imageView;
@property (nonatomic,retain ) KDBadgeIndicatorView * badgeIndicatorView;
@property (nonatomic, retain) UIView *separatorView;
- (void)setSelectedBg:(BOOL)selected;
@end
