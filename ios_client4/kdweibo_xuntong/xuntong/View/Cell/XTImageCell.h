//
//  XTImageCell.h
//  XT
//
//  Created by Gil on 13-7-18.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTCell.h"

@interface XTImageCell : XTCell

@property (nonatomic, assign, setter = setExpand:) BOOL isExpand;
@property (nonatomic, assign) BOOL expandViewHidden;

@end
