//
//  KDDMParticipantGridCellView.h
//  kdweibo
//
//  Created by Tan yingqi on 12-11-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDGridCellView.h"
#import "KDUser.h"

@interface KDDMParticipantGridCellView : KDGridCellView

@property(nonatomic,retain) KDUser *user;

@end
