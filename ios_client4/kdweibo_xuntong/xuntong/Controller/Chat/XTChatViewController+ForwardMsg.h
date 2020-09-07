//
//  XTChatViewController+ForwardMsg.h
//  kdweibo
//
//  Created by fang.jiaxin on 17/4/27.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "XTChatViewController.h"

@interface XTChatViewController (ForwardMsg)
//转发
-(XTForwardDataModel *)packgeRecordToForwardData:(BubbleDataInternal *)data;
-(void)forwardMsgArray:(id)data;
-(void)forwardMessagesToGroup;
-(void)startMultiForward:(UIButton *)btn;
@end
