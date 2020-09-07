//
//  XTContactPersonMultipleChoiceCell.h
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContactPersonCell.h"
#import "XTSelectStateView.h"

@interface XTContactPersonMultipleChoiceCell : XTContactPersonCell

@property (nonatomic, assign) BOOL hideCheckView;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, readonly) XTSelectStateView *selectStateView;
@property (nonatomic, assign) NSInteger pType;
@property (nonatomic, assign) BOOL showGrayStyle;//是否显示置灰样式
@property (nonatomic, assign) BOOL isFromTask;

//语音会议显示样式
@property (nonatomic, assign) BOOL agoraSelected;

- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;

@end
