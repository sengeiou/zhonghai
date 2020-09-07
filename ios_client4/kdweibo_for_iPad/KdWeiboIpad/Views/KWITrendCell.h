//
//  KWITrendCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/3/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTAttributedTextCell.h"

@class KDTopic;

@interface KWITrendCell : DTAttributedTextCell

@property (retain, nonatomic) KDTopic *data;

+ (KWITrendCell *)trendCellWithData:(KDTopic *)data;

@end
