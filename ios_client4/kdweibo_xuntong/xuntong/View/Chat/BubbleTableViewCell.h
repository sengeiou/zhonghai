//
//  BubbleTableViewCell.h
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


#import <UIKit/UIKit.h>
#import "BubbleDataInternal.h"
#import "BubbleTitleLabel.h"
#import "BubbleImageView.h"
#import "BubbleVoiceView.h"
#import "XTPersonHeaderView.h"
#import "XTNewsImage.h"
#import "ContactClient.h"
#import "XTRoundProgressView.h"
#import "UIImageView+WebCache.h"


#import  <OHAttributedLabel/OHAttributedLabel.h>
#import "KDExpressionLabel.h"
#import "KDBubbleCellNewButton.h"
#import "MWPhotoBrowser.h"
#import "FLAnimatedImageView.h"

@class XTChatViewController;
@class ContactClient;
@class XTWbClient;

@interface BubbleTableViewCell : UITableViewCell <XTPersonHeaderViewDelegate,ForwardDelegate,ASIHTTPRequestDelegate,OHAttributedLabelDelegate,KDExpressionLabelDelegate,KDBubbleCellNewButtonDelegate>
{
    ContactClient *_sendClient;
    ContactClient *_getContentClient;
    NSData *_sendData;
    NSData *_playData;
}

@property (nonatomic, strong) BubbleTitleLabel *headerLabel;//标题(时间)
@property (nonatomic, strong) XTPersonHeaderView *headerView;//头像
@property (nonatomic, strong) UILabel *personNameLabel;//人名
@property (nonatomic, strong) BubbleImageView *bubbleImage;//气泡
@property (nonatomic, strong) UIImageView *maskImageView;//图片cell边框
@property (nonatomic, strong) OHAttributedLabel *contentLabel;//其他消息内容
@property (strong, nonatomic) KDExpressionLabel *textContentLabel;//文本消息内容
@property (strong, nonatomic) KDExpressionLabel *replyContentLabel;//消息回复
@property (strong, nonatomic) UIButton *viewOriginalButton;//查看原文
@property (nonatomic, strong) UIView *replyLine; // 消息回复分割线
@property (nonatomic, strong) UIImageView *notraceImageView;//无痕消息图片
@property (nonatomic, strong) UILabel *combineTitleLabel;
@property (nonatomic, strong) NSMutableArray<UILabel *> *combineContentLabelArray;

@property (nonatomic, strong) UILabel *unreadCountLabel;//消息已读未读唯独文字
@property (nonatomic, strong) UIImageView *bubbleBackgroupdImage;//消息已读未读的气泡
@property (nonatomic, strong) UILabel *unreadWordLabel;//消息已读未读的文案
@property (nonatomic, strong) UIView *unreadBackgroudView;//消息已读未读的容器
//@property (nonatomic, strong) UILabel *fromPCLabel;//来自于桌面端


@property (nonatomic, strong) BubbleVoiceView *voiceView;//语音播放的View
@property (nonatomic, strong) UIImageView *redDotImageView;//未读标识
@property (nonatomic, strong) UIButton *sendFailueButton;//发送失败按钮
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;//发送或者请求烽火轮
@property (nonatomic, strong) FLAnimatedImageView *thumbnailImageView;//缩略图

@property (nonatomic, strong) NSString * highlightText;//需要显示高亮的字符串

//action button
@property (nonatomic, strong) UIView *eventLine;
@property (nonatomic, strong) UIButton *actionButton1;
@property (nonatomic, strong) UIButton *actionButton2;

//event button
@property (nonatomic, strong) NSMutableArray *eventButtons;
//news
@property (nonatomic, strong) UILabel *newstitle;
@property (nonatomic, strong) XTNewsImage *newsimage;
@property (nonatomic, strong) UILabel *newsdate;
@property (nonatomic, strong) UILabel *newscontent;
@property (nonatomic, strong) UIImageView *newsview;
@property (nonatomic, strong) UIView *backview;
@property (nonatomic, strong) UIView *newsbackview;
@property (nonatomic, strong) KDBubbleCellNewButton *newsbtn;
@property (nonatomic, assign) NSInteger row_index;
//shareNews
@property (nonatomic, strong) UIView *shareBackgroundView;
@property (nonatomic, strong) NSMutableArray*pic_array;
@property (nonatomic, strong) UILabel *shareTitleLabel;
@property (nonatomic, strong) UIImageView *shareThumbImageView;
//shareNews or shareText or shareImage
@property (nonatomic, strong) UIView *shareSeparatorLineBottom;
@property (nonatomic, strong) UILabel *shareSourceAppLabel;
//File
@property (nonatomic, strong) UIView *fileBackgroundView;
@property (nonatomic, strong) UILabel *fileTitleLabel;
@property (nonatomic, strong) UILabel *fileSize;
@property (nonatomic, strong) UIButton *fileButton;
@property (nonatomic, strong) XTWbClient *client;
@property (nonatomic, strong) UIButton *checkBtn;

//location
//location
@property (nonatomic, strong) UIImageView *locationBgView;
@property (nonatomic, strong) UILabel *locationInfo;

//shortVideo
@property (strong, nonatomic) UILabel *timeLabel;//时间显示 视频直接加在timelabel后面
@property (nonatomic, strong) UILabel *sizeLabel;//视频大小显示
@property (nonatomic, strong) UIButton *shortVideoBtn;

//有效期
@property (nonatomic, strong) XTRoundProgressView *roundProgressView;

@property (nonatomic, strong) BubbleDataInternal *dataInternal;
@property (nonatomic, weak) XTChatViewController *chatViewController;
@property (nonatomic, weak) id msgDeleteDelegate;

@property (nonatomic) BOOL isSpeechFirstRead;       //语音单元且尝试第一次播放

@property (nonatomic, strong) UILabel *labelName;

@property (nonatomic, strong) UILabel *departmentLabel; // 部门显示

@property (nonatomic, strong) UITapGestureRecognizer *tapRec;
@property (nonatomic, strong) UITapGestureRecognizer *bubbleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, assign) BOOL hideMenu;//隐藏弹出菜单

@property(nonatomic,strong) PersonSimpleDataModel *tempPerson;//里面只有发送者的头像，名字信息，为了调人员失败的时候不影响人员展示 706
@property(nonatomic,strong) NSString *fromUserName;//消息发送者姓名



- (void) manuStartPlayAudio;                        //程序调用播放语音
-(void)fileButtonClick:(id)sender;
- (void)openImageView;
- (void)clickTextMessage;

-(void)showCellMultiSelectAnimate;
-(void)hideCellMultiSelectAnimate;
@end
