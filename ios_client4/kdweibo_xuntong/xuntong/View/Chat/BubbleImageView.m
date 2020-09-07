//
//  BubbleImageView.m
//  ContactsLite
//
//  Created by Gil on 13-3-8.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "BubbleImageView.h"
#import "RecordDataModel.h"
#import "BubbleTableViewCell.h"

@implementation BubbleImageView

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
    //多选模式下不允许弹出菜单
    if(self.cell.dataInternal.checkMode!=-1)
        return NO;
    
    //这个时候是公共号历史消息
    if(_record.fromUserId && _record.groupId.length == 0)
        return NO;
    
    if (action == @selector(cancelMsg:)) {
        return YES;
    }
    if (_record.msgType == MessageTypeText) {
        if (action == @selector(copyText:)){
            return YES;
        }
        else if (action == @selector(forwardNew:)){
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
        else if (action == @selector(forward:)) {
            return  NO;
        }
        else if(action == @selector(forwardText:)){
            return YES;
        }
        else if (action == @selector(collect:)) {
            return  NO;
        }
        else if (action == @selector(deleteBubbleCell:)) {
            return YES;
        }
        else if(action == @selector(shareToCommunity:)){
            return NO;
        }
        else if (action == @selector(forwardPicture:)){
            return NO;
        }
        else if (action == @selector(changeToTask:)){
            return YES;
        }
        else if (action == @selector(shareToOther:)){
            return YES;
        }
        else
        {
            return [super canPerformAction:action withSender:sender];
        }
    }
    else if (_record.msgType == MessageTypeFile) {
        if (action == @selector(copyText:)){
            return NO;
        }
        else if (action == @selector(forwardNew:)){
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
        else if (action == @selector(forward:)) {
            return  YES;
        }
        else if (action == @selector(collect:)) {
            return  YES;
        }
        else if (action == @selector(deleteBubbleCell:)) {
            return YES;
        }
        else if(action == @selector(shareToCommunity:)){
            return YES;
        }
        else if(action == @selector(forwardText:)){
            return NO;
        }
        else if (action == @selector(forwardPicture:)){
            return NO;
        }
        else if (action == @selector(changeToTask:)){
            return NO;
        }
        else if (action == @selector(shareToOther:)){
            return NO;
        }
        else
        {
            return [super canPerformAction:action withSender:sender];
        }
    }
    else if (_record.msgType == MessageTypePicture) {
        if (action == @selector(copyText:)){
            return NO;
        }
        else if (action == @selector(forwardNew:)){
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
        else if (action == @selector(forward:)) {
            return  NO;
        }
        else if (action == @selector(collect:)) {
            return  YES;
        }
        else if (action == @selector(forwardPicture:)){
            return YES;
        }
        else if (action == @selector(deleteBubbleCell:)) {
            return YES;
        }
        else if(action == @selector(shareToCommunity:)){
            return NO;
        }
        else if(action == @selector(forwardText:)){
            return NO;
        }
        else if (action == @selector(changeToTask:)){
            return NO;
        }
        else if (action == @selector(shareToOther:)){
            return NO;
        }
        else
        {
            return [super canPerformAction:action withSender:sender];
        }
    }
    
    else if (_record.msgType == MessageTypeNews || _record.msgType == MessageTypeAttach) {
        if (action == @selector(copyText:)){
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
        else if (action == @selector(deleteBubbleCell:)) {
            return YES;
        }
        else if (action == @selector(forward:)) {
            return  NO;
        }
        else if (action == @selector(collect:)) {
            return  NO;
        }
        else if(action == @selector(forwardText:)){
            return NO;
        }
        
        else if(action == @selector(shareToCommunity:)){
            return NO;
        }
        else if (action == @selector(forwardPicture:)){
            return NO;
        }
        else if (action == @selector(forwardNew:)){
            return YES;
        }
        else if (action == @selector(changeToTask:)){
            return NO;
        }
        else if (action == @selector(shareToOther:)){
            return YES;
        }
        else
        {
            return [super canPerformAction:action withSender:sender];
        }
    }
    else if(_record.msgType == MessageTypeSystem || _record.msgType == MessageTypeCancel)
    {
        return NO;
    }
    else if(_record.msgType == MessageTypeShareNews)
    {
        if (action == @selector(deleteBubbleCell:)) {
            return YES;
        }
        return  NO;
    }
    else if (_record.msgType == MessageTypeLocation)
    {
        if (action == @selector(deleteBubbleCell:)){
            return YES;
        }
        else if (action == @selector(forwardLocation:)){
            return YES;
        }
        else if (action == @selector(mark:)){
            return NO;
        }
        else{
            return NO;
        }
    }
    else if (_record.msgType == MessageTypeShortVideo)
    {
        if (action == @selector(deleteBubbleCell:)){
            return YES;
        }
        else if (action == @selector(forwardShortVideo:)){
            return YES;
        }
        else if (action == @selector(collect:)){
            return YES;
        }
        else{
            return NO;
        }
    }
    else {
        if (action == @selector(copyText:)){
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
        else if (action == @selector(forward:)) {
            return  NO;
        }
        else if (action == @selector(collect:)) {
            return  NO;
        }
        else if (action == @selector(deleteBubbleCell:)) {
            return YES;
        }
        else if(action == @selector(shareToCommunity:)){
            return NO;
        }
        else if(action == @selector(forwardText:)){
            return NO;
        }
        else if (action == @selector(forwardPicture:)){
            return NO;
        }
        else if (action == @selector(forwardNew:)){
            return NO;
        }
        else if (action == @selector(changeToTask:)){
            return NO;
        }
        else if (action == @selector(shareToOther:)){
            return NO;
        }
        else
        {
            return [super canPerformAction:action withSender:sender];
        }
    }
}

- (MCloudClient *)mCloudClient
{
    if (_mCloudClient == nil) {
        _mCloudClient = [[MCloudClient alloc] initWithTarget:self action:@selector(getLightAppURLDidReceived:result:)];
    }
    return _mCloudClient;
}

- (void)getLightAppURLDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = (NSDictionary *)result.data;
        //必达任务,该链接
        NSString *url = [NSString stringWithFormat:@"https://iwork.coli688.com:8010/web/task/add?ticket=%@&content=%@", data[@"ticket"], _record.content];
        //去除中文字符
        url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (CFStringRef)url,
                                                                                    (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                    NULL,
                                                                                    kCFStringEncodingUTF8));
        NSLog(@"%@", url);
        KDWebViewController *bidaTaskWebViewController = [[KDWebViewController alloc] initWithUrlString:url appId:@""];
        [[KDDefaultViewControllerContext defaultViewControllerContext] showBidaTaskViewController:bidaTaskWebViewController];
    }
}

- (void)copyText:(id)sender
{
    [KDEventAnalysis event:event_msg_copy];
    if (_record.content) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:_record.content];
    }
}

- (void)changeToTask:(id)sender
{
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(changeToTask:)]) {
        [_forwardDelegate performSelector:@selector(changeToTask:) withObject:sender];
    }
}

- (void)changeToBidaTask:(id)sender
{
    NSLog(@"转为必达任务2");
    NSArray *workArry = [[BOSSetting sharedSetting].openWorkWithID componentsSeparatedByString:@","];
    NSString *appId = [workArry firstObject];
    [self.mCloudClient getLightAppURLWithMid:[BOSConfig sharedConfig].user.eid appid:appId openToken:[BOSConfig sharedConfig].user.token groupId:@"" userId:@"" msgId:@"" urlParam:@"" todoStatus:@""];
}

- (void)forward:(id)sender
{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forward:)]) {
        [_forwardDelegate performSelector:@selector(forward:) withObject:sender];
    }
}

- (void)forwardText:(id)sender
{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forwardText:)]) {
        [_forwardDelegate performSelector:@selector(forwardText:) withObject:sender];
    }
    
}

- (void)forwardPicture:(id)sender
{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forwardPicture:)]) {
        [_forwardDelegate performSelector:@selector(forwardPicture:) withObject:sender];
    }
    
}

- (void)forwardNew:(id)sender
{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forwardNew:)]) {
        [_forwardDelegate performSelector:@selector(forwardNew:) withObject:sender];
    }
    
}

- (void)forwardLocation:(id)sender
{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forwardLocation:)]) {
        [_forwardDelegate performSelector:@selector(forwardLocation:) withObject:sender];
    }
    
}

- (void)forwardShortVideo:(id)sender
{
    [KDEventAnalysis event:event_msg_forward];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(forwardShortVideo:)]) {
        [_forwardDelegate performSelector:@selector(forwardShortVideo:) withObject:sender];
    }
    
}

- (void)shareToCommunity:(id)sender
{
    [KDEventAnalysis event:event_msg_sharetoweibo];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(shareToCommunity:)]) {
        [_forwardDelegate performSelector:@selector(shareToCommunity:) withObject:sender];
    }
    
}
- (void)shareToOther:(id)sender
{
    [KDEventAnalysis event:event_msg_sharetoweibo];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(shareToOther:)]) {
        [_forwardDelegate performSelector:@selector(shareToOther:) withObject:sender];
    }
    
}
- (void)collect:(id)sender
{
    [KDEventAnalysis event:event_msg_collect];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(collect:)]) {
        [_forwardDelegate performSelector:@selector(collect:) withObject:sender];
    }
}

- (void)reply:(id)sender
{
    [KDEventAnalysis event:event_msg_reply];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(reply:)]) {
        [_forwardDelegate performSelector:@selector(reply:) withObject:sender];
    }
}

- (void)deleteBubbleCell:(id)sender
{
    [KDEventAnalysis event:event_msg_del];
    //if ([[XTDataBaseDao sharedDatabaseDaoInstance] deleteRecordWithMsgId:_record.msgId]) {
    if (_delegate && [_delegate respondsToSelector:@selector(bubbleDidDeleteMsg:cell:)]) {
        [_delegate bubbleDidDeleteMsg:self cell:self.cell];
    }
    //}
}
- (void)cancelMsg:(id)sender
{
    [KDEventAnalysis event:event_msg_cancel];
    if (_delegate && [_delegate respondsToSelector:@selector(cancelMsg:cell:)]) {
        [_delegate cancelMsg:self cell:self.cell];
    }
}
- (void)mark:(id)sender
{
    //    [KDEventAnalysis event:event_msg_cancel];
    if (_forwardDelegate && [_forwardDelegate respondsToSelector:@selector(mark:)]) {
        [_forwardDelegate performSelector:@selector(mark:) withObject:sender];
    }}
#pragma mark - XTRoundProgressViewDelegate

- (void)progressFinished:(XTRoundProgressView *)roundProgressView
{
    [self deleteBubbleCell:nil];
}

@end

