//
//  KDMentionPickerSectionView.h
//  kdweibo
//
//  Created by laijiandong on 12-11-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDMentionPickerSectionView : UIView {
@private
    UIImageView *backgroundImageView_;
    UILabel *sectionLabel_;
}

@property(nonatomic, retain, readonly) UIImageView *backgroundImageView;
@property(nonatomic, retain, readonly) UILabel *sectionLabel;

@end
