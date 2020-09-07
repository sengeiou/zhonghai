//
//  KDImageGridCell.h
//  kdweibo
//
//  Created by Tan yingqi on 13-5-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridViewCell.h"
#import "KDImageSource.h"
@interface KDImageGridCell: UIGridViewCell
@property(nonatomic,retain)UIImageView *imageView;
@property(nonatomic,retain)KDImageSource *imageSource;
@property(nonatomic,retain)UIImageView *checkImageView;
@end
