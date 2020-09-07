//
//  XTCell.h
//  XT
//
//  Created by Gil on 13-7-18.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  XTCellNormal = 0,
  XTCellContactFirst = 1,
  XTCellContactSecond = 2,
  XTCellSetting = 3
} XTCellStyle;

@interface XTCell : KDTableViewCell

@property (nonatomic, strong, readonly) UIImageView *separateLineImageView;
@property (nonatomic, assign) CGFloat separateLineSpace;
@property (nonatomic, assign) XTCellStyle XTCellStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier xtCellStyle:(XTCellStyle)XTCellStyle;

@end
