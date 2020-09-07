//
//  KDVoteViewLayoutInfo.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/13/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommenMethod.h"

@interface KDVoteViewLayoutInfo : NSObject
@property(copy,nonatomic)NSString * tableViewHeadTitle;
@property(assign,nonatomic)BOOL isShowVotePercent;
@property(assign,nonatomic)BOOL isEditing;

@end
