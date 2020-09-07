//
//  KDABPersonRecordCell.h
//  kdweibo
//
//  Created by laijiandong on 12-11-9.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTableViewCell.h"

@interface KDABPersonRecordCell : KDTableViewCell

@property(nonatomic, retain, readonly) UILabel  *subjectLabel;
@property(nonatomic, retain, readonly) UIButton *recordButton;
@property(nonatomic, retain, readonly) UIButton *indicatorButton;
@property(nonatomic, assign) BOOL showDashed;

- (void)update:(NSString *)subject value:(NSString *)value enabled:(BOOL)enabled;

- (void)setIndicatorButtonExpand:(BOOL)expand;

@end
