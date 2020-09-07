//
//  BubbleDataInternal.m
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "BubbleDataInternal.h"

#define BubbleLabelMaxWidth (ScreenFullWidth - (10+44+3)*2)

@implementation BubbleDataInternal
-(BubbleDataInternal *)initWithRecord:(RecordDataModel *)record andGroup:(GroupDataModel *)group andChatMode:(ChatMode)chatMode
{
    self = [super init];
    
    if(self)
    {
        self.group = group;
        self.record = record;
        
        NSString *replySourceMsgText = nil;
        NSString *msgContent = nil;
        if ([[KDChatReplyManager sharedInstance] isReplyMsg:record]) {
            replySourceMsgText = [[KDChatReplyManager sharedInstance] replyContent:record];
            msgContent = [[KDChatReplyManager sharedInstance] replyBottomContent:record];
        }
        else
            msgContent = record.content;
        
        BOOL personNameLabelHidden = NO;
        float personNameLabelHeight = 15.0;
        if ([[BOSConfig sharedConfig].user.userId isEqualToString:self.record.fromUserId])
        {
            personNameLabelHidden = YES;
            personNameLabelHeight = 0.0;
        } else {
            if (chatMode == ChatPrivateMode) {
                if (group.groupType != GroupTypeMany) {
                    personNameLabelHidden = YES;
                    personNameLabelHeight = 0.0;
                }
            } else {
                if (self.record.msgDirection == MessageDirectionLeft && group.groupType != GroupTypePublicMany) {
                    personNameLabelHidden = YES;
                    personNameLabelHeight = 0.0;
                }
            }
        }
        self.personNameLabelHidden = personNameLabelHidden;
        
        // Calculating cell height
        switch (self.record.msgType) {
            case MessageTypeSpeech:
            {
                //语音
                float width = 100.0 * (self.record.msgLen / 180.0) + 59.0;
                self.bubbleLabelSize = CGSizeMake(width, 31.0);
                self.contentLabelFrame = CGRectMake(self.record.msgDirection == MessageDirectionLeft ? 12.0 : 6.0, 8.0, self.bubbleLabelSize.width - 18.0, self.bubbleLabelSize.height - 16.0);
                self.cellHeight = 61.0 + personNameLabelHeight + 5.0;
            }
                break;
            case MessageTypeSystem:
            case MessageTypeCancel:
            {
                //其他:系统、电话等
                NSString *content = self.record.content ? self.record.content : @"";
                NSMutableAttributedString *contentString = [NSMutableAttributedString attributedStringWithString:content];
                [contentString setFont:[UIFont systemFontOfSize:12.0]];
                [contentString setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByWordWrapping];
                CGSize contentSize = [contentString sizeConstrainedToSize:CGSizeMake(300, 9999)];
                
                if (contentSize.height < 20){
                    contentSize.height = 20.0;
                }
                contentSize.width += 10.0;
                
                //无痕消息销毁
                if(content.length == 0)
                {
                    contentSize.width  = 0;
                    contentSize.height = 0;
                }
                
                self.bubbleLabelSize = CGSizeMake(contentSize.width, contentSize.height);
                self.contentLabelFrame = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
                self.cellHeight = self.bubbleLabelSize.height + 10 + 5.0;
            }
                break;
            case MessageTypePicture:
            {
                //图片
                self.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 180);
                self.contentLabelFrame = CGRectZero;
                self.cellHeight = self.bubbleLabelSize.height + 20.0;
                if (self.record.param) {
                    self.cellHeight += 20.0;
                }
            }
                break;
            case MessageTypeFile:
            {
                //文件
                MessageFileDataModel *file = (MessageFileDataModel *)self.record.param.paramObject;
                
                if ([XTFileUtils isPhotoExt:file.ext]) {
                    if (self.record.strEmojiType.length == 0) {
                        self.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 180); // 文件类型的图片
                    } else {
                        self.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 110); // 表情
                    }
                    
                    self.contentLabelFrame = CGRectZero;
                    self.cellHeight = self.bubbleLabelSize.height + 20.0;
                    if (self.record.param) {
                        self.cellHeight += 20.0;
                    }
                }
                else {
                    
                    CGSize contentSize = [(file.name ? file.name : @"") boundingRectWithSize:CGSizeMake(KDChatConstants.bubbleContentLabelMaxWidth - 12 - 55, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: FS4} context:nil].size;
                    
                    if (contentSize.height < 30) {
                        contentSize.height = 30;
                    }
                    if (contentSize.height > 18*4) {
                        contentSize.height = 18*4;
                    }
                    
                    if (contentSize.width < ScreenFullWidth-180) {
                        contentSize.width = ScreenFullWidth-180;
                    }
                    
                    self.bubbleLabelSize = CGSizeMake(BubbleLabelMaxWidth, contentSize.height + 12*2 + 8 + 15);
                    self.cellHeight = self.bubbleLabelSize.height + 10.0 + personNameLabelHeight + 15.0;
                    if (file.appName.length > 0) {
                        self.cellHeight += 20.0;
                    }
                }
                
            }
                break;
            case MessageTypeAttach:
            {
                //带操作的消息
                NSString *content = self.record.content ? self.record.content : @"";
                
                //                    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
                //                    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                //                    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                //                                                                                forKey:NSFontAttributeName];
                //                    [contentString addAttributes:attrsDictionary range:NSMakeRange(0, contentString.length)];
                CGSize contentSize = [content sizeForMaxWidth:ScreenFullWidth-48 font:FS3];
                
                float bubbleLabelSizeHeight = contentSize.height;
                CGFloat actionHeight = 0;
                MessageAttachDataModel *paramObject = self.record.param.paramObject;
                if ([paramObject.attach count] == 1)
                {
                    actionHeight = 35;
                } else if ([paramObject.attach count] == 2)
                {
                    actionHeight = 35 + 35;
                }
                bubbleLabelSizeHeight += (25 + actionHeight);
                float bubbleLabelSizeWidth = ScreenFullWidth-48;
                self.bubbleLabelSize = CGSizeMake(bubbleLabelSizeWidth, bubbleLabelSizeHeight);
                self.contentLabelFrame = CGRectMake(8.0, 8.0, ScreenFullWidth-48, contentSize.height);
                self.cellHeight = self.bubbleLabelSize.height + 10.0 + 5.0;
            }
                break;
            case MessageTypeNews:
            {
                //新闻
                MessageNewsDataModel *paramObject = self.record.param.paramObject;
                MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
                
                CGSize contentSize = [(news.text ? news.text : @"") boundingRectWithSize:CGSizeMake(174, 70) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: FS3} context:nil].size;
                //                    if (contentSize.height < 13.0)
                //                    {
                //                        contentSize.height = 13.0;
                //                    }
                
                self.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
                self.contentLabelFrame = CGRectZero;
                if (paramObject.model == 1 && !paramObject.todoNotify && paramObject.newslist.count > 0)
                {
                    MessageNewsEachDataModel *news=[paramObject.newslist   objectAtIndex:0];
                    
                    float fTitleHeight = [news.title sizeForMaxWidth:ScreenFullWidth-48 font:FS3].height;
                    //                        self.cellHeight = 68 + self.bubbleLabelSize.height + 10;
                    
                    float fContentHeight = [news.text sizeForMaxWidth:ScreenFullWidth-48 font:FS6 numberOfLines:4].height;
                    
                    if (news.date.length > 0)
                    {
                        float fDateHeight = 15;//[news.date sizeForMaxWidth:ScreenFullWidth-24 font:FS6].height;
                        
                        self.cellHeight = 15 + fTitleHeight + 12 + fDateHeight + 12 + fContentHeight + 15 + 10;
                    }
                    else
                    {
                        self.cellHeight = 15 + fTitleHeight + 12 + fContentHeight + 15 + 10;
                        
                    }
                    
                    
                }
                else if ((paramObject.model == 2 && paramObject.newslist.count > 0))
                {
                    MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                    
                    float fTitleHeight = [news.title sizeForMaxWidth:ScreenFullWidth-48 font:FS3].height;
                    
                    float fContentHeight = [news.text sizeForMaxWidth:ScreenFullWidth-48 font:FS6].height;
                    
                    if (news.date.length > 0)
                    {
                        float fDateHeight = 15;//[news.date sizeForMaxWidth:ScreenFullWidth-24 font:FS6].height;
                        
                        self.cellHeight = 15 + fTitleHeight + 12 + fDateHeight + 12 + kNewsBigPictureHeight + 12 +  fContentHeight + 15+10 +5;
                    }
                    else
                    {
                        self.cellHeight = 15 + fTitleHeight + 12 + kNewsBigPictureHeight + 12 +  fContentHeight + 15 +10 +5;
                    }
                }
                else if (paramObject.model == 3 && paramObject.newslist.count > 0)
                {
                    self.cellHeight = kNewsBigPictureHeight + 60 * paramObject.newslist.count-60 + 15+15+10;
                }
                else if (paramObject.model == 4)
                {
                    if ([[paramObject.newslist objectAtIndex:0] hasHeaderPicture])
                    {
                        self.cellHeight = 207 + self.bubbleLabelSize.height + 10;
                    }
                    else
                    {
                        MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                        
                        float fTitleHeight = 15;// [news.title sizeForMaxWidth:ScreenFullWidth-24 font:FS2].height;
                        //                        self.cellHeight = 68 + self.bubbleLabelSize.height + 10;
                        
                        float fContentHeight = [news.text sizeForMaxWidth:ScreenFullWidth-48 font:FS6].height;
                        
                        if (news.date.length > 0)
                        {
                            float fDateHeight = 15;//[news.date sizeForMaxWidth:ScreenFullWidth-24 font:FS6].height;
                            
                            self.cellHeight = 15 + fTitleHeight + 12+ fDateHeight + 12 + fContentHeight + 15 +10;
                        }
                        else
                        {
                            self.cellHeight = 15 + fTitleHeight + 12 + fContentHeight+ 15 +10;
                            
                        }
                    }
                    if ([[[paramObject.newslist objectAtIndex:0] buttons] count] > 0)
                    {
                        self.cellHeight += 23.f;
                    }
                }
                else if (paramObject.model == 1 && paramObject.todoNotify)
                {
                    if (paramObject.newslist.count > 0)
                    {
                        MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
                        if (news.date)
                        {
                            self.cellHeight = 70 + self.bubbleLabelSize.height + 10;
                        }
                        else
                        {
                            self.cellHeight = 50 + self.bubbleLabelSize.height + 10;
                        }
                    }
                }
                
            }
                break;
            case MessageTypeShareNews:
            {
                /**
                 *  增加一种新的Cell样式，用于多图文分享
                 *  alanwong
                 */
                MessageShareNewsDataModel *paramObject = self.record.param.paramObject;
                //                    if (paramObject.title.length == 0 || [paramObject.title isEqualToString:paramObject.content]) {
                //                        //多图文新闻
                //                        CGSize contentSize = CGSizeMake(194.0, 58.0);
                //                        self.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
                //                        self.contentLabelFrame = CGRectMake(72.0, 42.0, 134.0, 23.0);
                //                        self.cellHeight = self.bubbleLabelSize.height + 10.0 + 20.0 + 15;
                //                    }
                //                    else
                {
                    //单图文新闻
                    CGSize contentSize = CGSizeMake(174.0, 92.0);
                    self.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0 + 21);
                    self.contentLabelFrame = CGRectMake(72.0, 42.0, 114.0, 55.0);
                    self.cellHeight = self.bubbleLabelSize.height + 10.0 + 20.0 + 15 + 21;
                    
                }
            }
                break;
            case MessageTypeLocation:
            {
                //图片
                self.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 90.0 + 20.0);
                self.contentLabelFrame = CGRectZero;
                self.cellHeight = self.bubbleLabelSize.height + 20.0;
                if (self.record.param) {
                    self.cellHeight += 20.0;
                }
            }
                break;
            case MessageTypeShortVideo:
            {
                //图片
                self.bubbleLabelSize = CGSizeMake(ScreenFullWidth / 3, 180);
                self.contentLabelFrame = CGRectZero;
                self.cellHeight = self.bubbleLabelSize.height + 20.0;
                if (self.record.param) {
                    self.cellHeight += 20.0;
                }
            }
                break;
            case MessageTypeNotrace:
            {
                //图片
                self.bubbleLabelSize = CGSizeMake(ScreenFullWidth*0.42, ScreenFullWidth*0.42*90/165);
                self.contentLabelFrame = CGRectZero;
                self.cellHeight = self.bubbleLabelSize.height + 20.0 + (record.msgDirection == MessageDirectionLeft?20:0);
                if (self.record.param) {
                    self.cellHeight += 20.0;
                }
            }
                break;
            case MessageTypeCombineForward:
            {
                //合并转发
                double bubbleLabelWidth = ScreenFullWidth-118;
                
                MessageCombineForwardDataModel *forwardDataModel = (MessageCombineForwardDataModel *)self.record.param.paramObject;
                NSArray *contetnArray = [forwardDataModel.content componentsSeparatedByString:@"\n"];
                double contentHeight = MIN(4, contetnArray.count)*(FS6.lineHeight+5);
                self.bubbleLabelSize = CGSizeMake(bubbleLabelWidth,8+20+5+contentHeight+3);
                self.contentLabelFrame = CGRectZero;
                self.cellHeight = self.bubbleLabelSize.height + 20.0 + (record.msgDirection == MessageDirectionLeft?20:0);
            }
                break;
            default:
            {
                BOOL hasEffectiveDuration = false;
                BOOL hasAppShareLabel = false;
                if (self.record.msgType == MessageTypeText)
                {
                    MessageShareTextOrImageDataModel *paramObject = self.record.param.paramObject;
                    if (paramObject.effectiveDuration > 0)
                    {
                        hasEffectiveDuration = true;
                        
                        //失效的密码不显示
                        NSTimeInterval interval = [paramObject.clientTime timeIntervalSinceNow];
                        interval = 0 - interval;
                        if (interval > paramObject.effectiveDuration) {
                            return nil;
                        }
                    }
                    if (paramObject.appName.length > 0)
                    {
                        hasAppShareLabel = true;
                    }
                }
                
                NSString *content = replySourceMsgText?replySourceMsgText:(self.record.content ? self.record.content : @"");
                
                
                UIFont *font = hasEffectiveDuration ? [UIFont systemFontOfSize:20.0] : [UIFont systemFontOfSize:17.0];
                KDExpressionLabelType type = KDExpressionLabelType_Expression | KDExpressionLabelType_URL | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_TOPIC;
                
                CGSize contentSize = [KDExpressionLabel sizeWithString:msgContent constrainedToSize:CGSizeMake(ScreenFullWidth - 118-14, CGFLOAT_MAX) withType:type textAlignment:NSTextAlignmentLeft textColor:nil textFont:font];//原来是CGSizeMake(204, CGFLOAT_MAX)，
                
                //回复消息的原文
                CGSize replySourceContentSize = CGSizeZero;
                if(replySourceMsgText.length>0)
                {
                    //减去14是给跳转按钮
                    replySourceContentSize = [KDExpressionLabel sizeWithString:replySourceMsgText constrainedToSize:CGSizeMake(ScreenFullWidth - 118 - 14 - 14, CGFLOAT_MAX) withType:type textAlignment:NSTextAlignmentLeft textColor:nil textFont:FS7];//原来是CGSizeMake(204, CGFLOAT_MAX)，
                    
                    if(replySourceContentSize.height > 32)
                        replySourceContentSize.height = 32;
                }
                
                //加上14是给跳转按钮
                double replySourceContentSizeWidth = replySourceContentSize.width+14;
                
                if (hasEffectiveDuration) {
                    contentSize.width += content.length * 3.0;
                    //replySourceContentSize.width += replySourceMsgText.length * 3.0;
                }
                
                float bubbleLabelSizeWidth = MAX(contentSize.width, replySourceContentSizeWidth)  + 28.0;
                if (bubbleLabelSizeWidth < 60.0) {
                    bubbleLabelSizeWidth = 60.0;
                }
                
                if (bubbleLabelSizeWidth > ScreenFullWidth - 118) {
                    bubbleLabelSizeWidth = ScreenFullWidth - 118;
                }
                
                
                float bubbleLabelMiniSizeHeight = hasEffectiveDuration ? 51.0 : 31.0;
                float bubbleLabelSizeHeight = replySourceContentSize.height  + (replySourceMsgText.length>0?10:0) + contentSize.height  + 20.0;
                if (bubbleLabelSizeHeight < bubbleLabelMiniSizeHeight) {
                    bubbleLabelSizeHeight = bubbleLabelMiniSizeHeight;
                }
                self.bubbleLabelSize = CGSizeMake(bubbleLabelSizeWidth, bubbleLabelSizeHeight);
                
                
                //计算x,y
                float x = 6.0;
                if (bubbleLabelSizeWidth - MAX(contentSize.width, replySourceContentSizeWidth)  - 18.0 > 0) {
                    x += (bubbleLabelSizeWidth - MAX(contentSize.width, replySourceContentSizeWidth) - 18.0)/2;
                }
                float y = 10;//(bubbleLabelSizeHeight - bubbleLabelSizeHeight)/2;
                
                
                //计算cell高度跟内部控件frame
                self.replyContentLabelFrame = CGRectMake(x, y, replySourceContentSize.width, replySourceContentSize.height);
                self.contentLabelFrame = CGRectMake(x, CGRectGetMaxY(self.replyContentLabelFrame)+(replySourceMsgText.length>0?10:0), contentSize.width, contentSize.height);
                
                self.cellHeight = (self.bubbleLabelSize.height > 51.0 ? self.bubbleLabelSize.height + 10.0 : 61) + personNameLabelHeight + 5.0;
                
                if (hasAppShareLabel) {
                    self.cellHeight += 20.0;
                }
                
                self.replyLineFrame = CGRectMake(x, CGRectGetMaxY(self.replyContentLabelFrame)+4, self.bubbleLabelSize.width-2*x+(self.record.msgDirection == MessageDirectionLeft ? 6.0 : 0.0), 1);
                self.viewOrgBtnFrame = CGRectMake(CGRectGetMaxX(self.replyLineFrame)-12,(CGRectGetMaxY(self.replyContentLabelFrame)+CGRectGetMinY(self.replyContentLabelFrame))/2-8, 12, 12);
            }
                break;
        }
    }
    return self;
}
@end
