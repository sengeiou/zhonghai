//
//  KDTaskDetailView.h
//  kdweibo
//
//  Created by Tan yingqi on 13-7-8.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTask.h"
#import  "KDStatusExtraMessage.h"


@interface KDTaskDetailView : UIView
@property(nonatomic,retain)KDTask *task;
@property(nonatomic,retain)KDStatusExtraMessage *extraMessage;
@property(nonatomic,assign)id nocationSender;
-(CGFloat)height;

@end
