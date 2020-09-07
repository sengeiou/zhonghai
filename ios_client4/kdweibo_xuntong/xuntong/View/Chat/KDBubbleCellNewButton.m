//
//  KDBubbleCellNewButton.m
//  kdweibo
//
//  Created by AlanWong on 14-7-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDBubbleCellNewButton.h"

@implementation KDBubbleCellNewButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:)){
        return NO;
    }
    else if (action == @selector(delete:)) {
        return NO;
    }
    else if(action == @selector(cut:)){
        return NO;
    }
    else if(action == @selector(paste:)){
        return NO;
    }
    else if(action == @selector(select:)){
        return NO;
    }
    else if(action == @selector(selectAll:)){
        return NO;
    }
    else if (action == @selector(forwardNew:)) {
        return  YES;
    }
    else if (action == @selector(collect:)) {
        return  NO;
    }
    else if (action == @selector(deleteNews:)) {
        return YES;
    }
    else if (action == @selector(shareNewsToCommunity:)) {
        return NO;
    }
    else if(action == @selector(shareToOther:)){
        return YES;
    }
    
    else
    {
        return [super canPerformAction:action withSender:sender];
    }

}
- (void)forwardNew:(id)sender{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forwardNew:)]) {
        [_forwardDelegate performSelector:@selector(forwardNew:) withObject:sender];
    }
}

- (void)deleteNews:(id)sender{
    [KDEventAnalysis event:event_msg_del];
    if ([[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:_record.msgId]) {
        if (_deleteDelegate && [_deleteDelegate respondsToSelector:@selector(bubbleDidDeleteMsg:cell:)]) {
            [_deleteDelegate bubbleDidDeleteMsg:_bubbleImageView cell:self.cell];
        }
    }

}
- (void)shareNewsToCommunity:(id)sender{
    [KDEventAnalysis event:event_msg_sharetoweibo];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(shareNewsToCommunity:)]) {
        [_forwardDelegate performSelector:@selector(shareNewsToCommunity:) withObject:sender];
    }
}

- (void)shareToOther:(id)sender{
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(shareToOther:)]) {
        [_forwardDelegate performSelector:@selector(shareToOther:) withObject:sender];
    }
}

@end
