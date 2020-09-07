//
//  KDGetCellHeight.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/9/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommenMethod.h"
#import "KDVoteCell.h"

@interface KDGetCellHeight : NSObject
//get vote detail cell height
+(CGFloat)getVoteCellHeightWithText:(NSString *)text isIncludProcessView:(BOOL)isIncludProcessView;
@end
