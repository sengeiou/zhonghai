//
//  ProfileViewCell.h
//  kdweibo
//
//  Created by 王 松 on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ProfileViewCellLayout)
{
    ProfileViewCellLayout_InfoLeft = 0,
    ProfileViewCellLayout_InfoRight
};

typedef NS_ENUM(NSUInteger, ProfileViewCellPlace)
{
    ProfileViewCellPlace_Top,
    ProfileViewCellPlace_Middle,
    ProfileViewCellPlace_Bottom
};



@interface ProfileViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *mainLabel;

@property (nonatomic, retain) UILabel *infoLabel;

@property (nonatomic, assign) ProfileViewCellLayout layout;

@property (nonatomic, assign) ProfileViewCellPlace cellPlace;

@property (nonatomic, assign) BOOL hideNarrow;

@property(nonatomic,assign) BOOL shouldHideNarrow; //新属性用于控制是否显示Narrow图片
@end
