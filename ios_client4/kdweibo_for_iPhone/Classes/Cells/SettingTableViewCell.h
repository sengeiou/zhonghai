//
//  SettingTableViewCell.h
//  TwitterFon
//
//  Created by apple on 11-6-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDCellAdjustForSeven.h"

typedef enum {
    FirstRow          = 0,
    MiddleRow        = 1,
    LastRow         = 2,
    FullRow  = 3,
    Logout=4,
    User_Image
} RowType;

@interface SettingTableViewCell : UITableViewCell {
    RowType   rowType;
    UIImageView *customImageView;
    
    UIImageView *narrowImageView_;
    
    CALayer *topLine_;
    CALayer *leftLine_;
    CALayer *bottomLine_;
    CALayer *rightLine_;
}

@property RowType   rowType;
@property(nonatomic,retain)UIImageView *customImageView;

-(void) applyRowType;
@end
