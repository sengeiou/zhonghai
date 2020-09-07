//
//  XTMyAccountCell.h
//  XT
//
//  Created by kingdee eas on 13-12-4.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface XTMyHeaderViewCell : UITableViewCell

@property (nonatomic, retain, readonly) UIImageView *separateLineImageView;
@property (nonatomic, assign) CGFloat separateLineSpace;
@property (nonatomic, retain) UIImageView *headImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *xtAccountLabel;
@property (nonatomic, retain) UIImageView *bgImageView;
- (id)initWithStyle:(NSString *)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
