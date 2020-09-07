//
//  XTCompanyCell.h
//  XT
//
//  Created by Ad on 14-3-31.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTCompanyCell : UITableViewCell

@property (nonatomic,assign) BOOL checked;
@property (nonatomic,copy) NSString *companyName;

- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;

@end
