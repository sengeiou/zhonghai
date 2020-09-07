//
//  XTSearchMultipleChoiceCell.h
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSearchCell.h"

@interface XTSearchMultipleChoiceCell : XTSearchCell

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) NSInteger pType;
@property (nonatomic, assign) BOOL showGrayStyle;
@property (nonatomic, assign) BOOL isFromTask;

- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;

@end
