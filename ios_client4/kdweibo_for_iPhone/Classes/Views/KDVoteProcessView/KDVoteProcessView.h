//
//  KDVoteProcessView.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/9/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#define MAX_PROCESS_LENGTH 19
#define PROCESS_BAR_HEIGHT_SMALL_THAN_BG 2

@interface KDVoteProcessView : UIView

@property(assign,nonatomic)NSInteger voteCount;
@property(assign,nonatomic)NSInteger totalVoteCount;

- (void)setSelected:(BOOL)selected;

@end
