//
//  KDProfileTabItem.h
//  kdweibo
//
//  Created by shen kuikui on 13-11-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDProfileTabItem : UIView
{
    UILabel *tabValueLabel_;
    UILabel *tabNameLabel_;
    
    BOOL selected_;
    BOOL valueAboveName_;
}
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL valueAboveName;

- (void)setSelected:(BOOL)selected;

@end
