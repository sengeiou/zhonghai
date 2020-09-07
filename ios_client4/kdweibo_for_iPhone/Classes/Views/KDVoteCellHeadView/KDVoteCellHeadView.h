//
//  KDVoteCellHeadViewViewController.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/9/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "SingleLineScaleLab.h"
#define GAP_BETREENT_IMAGE_AND_TITLE 7.0


@interface KDVoteCellHeadView : UIView<SingleLineScaleLabDelegate>
@property(retain,nonatomic)NSString * alterText;
@end
