//
//  XTUnreadImageView.h
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTUnreadImageView : UIImageView

- (id)initWithParentView:(UIView *)parentView;

@property (nonatomic, assign) int unreadCount;
@property (nonatomic, assign) BOOL bGrey; // KSSP-23046【ios】移动端消息群组中选择关闭推送消息后，在消息首页该组的消息提示

@end
