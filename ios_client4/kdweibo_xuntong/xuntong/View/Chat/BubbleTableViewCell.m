//
//  BubbleTableViewCell.m
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


#import "BubbleTableViewCell.h"
#import "BOSAudioPlayer.h"
#import "amrFileCodec.h"
#import "ContactUtils.h"
#import "ContactConfig.h"
#import "PersonDataModel.h"
#import "XTChatViewController.h"
#import "ContactLoginDataModel.h"
#import "NSDataAdditions.h"
#import "SendDataModel.h"
#import "ContactClient.h"
#import "XTPersonDetailViewController.h"
#import "UIImage+XT.h"
#import "KDWebViewController.h"
#import "XTFileUtils.h"
#import "XTFileDetailViewController.h"

#import "XTTELHandle.h"
#import "XTMAILHandle.h"
#import "XTChooseContentViewController.h"
#import "BOSConfig.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "NSString+Scheme.h"
#import "TrendStatusViewController.h"
#import "KDStatusDetailViewController.h"
#import "KDTaskDiscussViewController.h"
#import "XTShareManager.h"
#import "KDCommunityShareView.h"
#import "KDTodoListViewController.h"
#import "KDExpressionManager.h"
#import "KDAvatarSettingViewController.h"
#import "XTWbClient.h"
#import "KDCreateTaskViewController.h"
#import "KDSheet.h"
#import "KDDefaultViewControllerContext.h"
#import "NSString+DZCategory.h"
#import "KDPubAccDetailViewController.h"
#import "XTChatUnreadCollectionView.h"
#import "KDApplicationQueryAppsHelper.h"
#import "XTSetting.h"
#import "KDMapViewController.h"
#import "KDErrorDisplayView.h"
#import "MBProgressHUD.h"
#import "KDDownload.h"
#import "KDDownloadManager.h"
#import "XTCloudClient.h"
#import "KDAttachment.h"
#import "KDMediaMessageHandler.h"
#import  <OHAttributedLabel/NSAttributedString+Attributes.h>
#import "URL+MCloud.h"
#import "UIViewController+DZCategory.h"
#import "XTChatViewController+ForwardMsg.h"
#import "KDUserHelper.h"

#define personNameHeight  15
#define personNameWidth    100

#define leftImageName  ASLocalizedString(@"message_bg_traceless_left_normal")
#define leftPressImageName  ASLocalizedString(@"message_bg_traceless_left_press")
#define rightImageName  ASLocalizedString(@"message_bg_traceless_right_normal")
#define rightPressImageName  ASLocalizedString(@"message_bg_traceless_right_press")

@interface BubbleTableViewCell ()<UIActionSheetDelegate,KDPopoverDataSource,KDCloudAPIDelegate,MJPhotoBrowserDelegate>
{
     KDDownload *download;
}

@property (nonatomic, strong) NSString *totaskSource;

@property (nonatomic, assign) NSUInteger currentButtonIndex; //在多图新闻里面，记录当前选择是那一条新闻
@property (nonatomic, strong) KDSheet *shareSheet;
@property (nonatomic, strong) UITapGestureRecognizer *unreadTap;

@property (nonatomic, strong) KDPopover *popoverMain;
@property (nonatomic, strong) KDPopover *popoverPublic;
@property (nonatomic, strong) NSMutableArray *popoverPublicItemArray;
@property (nonatomic, strong) KDPopover *popoverTask; // 单击

@property (nonatomic, strong) KDMarkModel *markModel;
@property (nonatomic, strong) MCloudClient *mCloudClient;
@property (nonatomic, strong) NSArray *msgToLightAppArray;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (nonatomic,strong) FileModel *file;

@property (nonatomic,strong) XTCloudClient *xtCloudclient;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) UITapGestureRecognizer *tapGes;

@property (nonatomic, assign) NSUInteger rowIndex;

@property (nonatomic, strong) KDUserHelper *userHelper;


-(void)setupInternalData;

-(void)play:(NSString *)filePath;
-(void)play:(NSData *)fileData identifier:(NSString *)identifier cell:(BubbleTableViewCell *)cell;
-(void)getContent;
-(void)getContentSuccess:(NSData *)content;
-(void)getContentFailue;
@end

@implementation BubbleTableViewCell
static NSDateFormatter *formatter = nil;
- (void) dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
     self.roundProgressView.delegate = nil;
     [self setMsgDeleteDelegate:nil];
     
     _chatViewController = nil;
     
     [[BOSAudioPlayer sharedAudioPlayer] stopPlay];
     
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
     self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
     if (self) {
          self.selectionStyle = UITableViewCellSelectionStyleNone;
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideEditMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
          _currentButtonIndex = 0 ;
          self.backgroundColor = [UIColor kdBackgroundColor1];
          
          self.pic_array=[[NSMutableArray alloc]init];
          //标题（时间）
          self.headerLabel = [[BubbleTitleLabel alloc] initWithFrame:CGRectMake(0.0, 21.0, CGRectGetWidth(self.frame), 12.0)];
          self.headerLabel.backgroundColor = [UIColor clearColor];
          [self.contentView addSubview:self.headerLabel];
          
          //消息未读标签
          self.unreadBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(5, 10, 50, 40)];
          [self.unreadBackgroudView setUserInteractionEnabled:YES];
          [self.unreadBackgroudView setBackgroundColor:[UIColor clearColor]];
          [self.contentView addSubview:self.unreadBackgroudView];
          self.unreadCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, 50, 15)];
          [self.unreadCountLabel setUserInteractionEnabled:YES];
          [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
          [self.unreadCountLabel setFont:[UIFont systemFontOfSize:10]];
          [self.unreadCountLabel setTextColor:[UIColor blackColor]];
          [self.unreadCountLabel setBackgroundColor:[UIColor clearColor]];
          [self.unreadBackgroudView addSubview:self.unreadCountLabel];
          
          self.bubbleBackgroupdImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 22)];
          [self.bubbleBackgroupdImage setBackgroundColor:[UIColor yellowColor]];
          [self.bubbleBackgroupdImage setContentMode:UIViewContentModeScaleAspectFit];
          [self.bubbleBackgroupdImage setBackgroundColor:[UIColor clearColor]];
          [self.unreadBackgroudView addSubview:self.bubbleBackgroupdImage];
          [self.bubbleBackgroupdImage setImage:[UIImage imageNamed:@"messageUnreadBubble"]];
          
          self.unreadWordLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -2, 50, 22)];
          [self.unreadWordLabel setBackgroundColor:[UIColor clearColor]];
          [self.unreadWordLabel setTextColor:[UIColor blackColor]];
          [self.unreadWordLabel setTextAlignment:NSTextAlignmentCenter];
          [self.unreadWordLabel setFont:[UIFont systemFontOfSize:9]];
          [self.unreadWordLabel setText:ASLocalizedString(@"BubbleTableViewCell_Tip_1")];
          [self.unreadWordLabel setTextColor:FC5];
          [self.unreadBackgroudView addSubview:self.unreadWordLabel];
          
          //消息未读点击
          self.unreadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(unreadTap:)];
          [self.unreadBackgroudView addGestureRecognizer:self.unreadTap];
          
          //头像
          self.headerView = [[XTPersonHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44, 44)];
          self.headerView.delegate = self;
          self.headerView.layer.cornerRadius = 6;
          [self.contentView addSubview:self.headerView];
          
          self.personNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
          self.personNameLabel.font = [UIFont systemFontOfSize:12.0];
          self.personNameLabel.textColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
          self.personNameLabel.textAlignment = NSTextAlignmentLeft;
          self.personNameLabel.backgroundColor = [UIColor clearColor];
          [self.contentView addSubview:self.personNameLabel];
          
          
          //气泡
          self.bubbleImage = [[BubbleImageView alloc] initWithFrame:CGRectZero];
          self.bubbleImage.userInteractionEnabled = YES;
          self.bubbleImage.forwardDelegate = self;
          self.bubbleImage.cell = self;
          
          
          
          UITapGestureRecognizer *bubbleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleBtnTapPressed:)];
          [self.bubbleImage addGestureRecognizer:bubbleTapGesture];
          UILongPressGestureRecognizer *bubbleLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleBtnLongPressed:)];
          //        [self.bubbleImage addGestureRecognizer:bubbleLongPressGesture];
          [self.contentView addGestureRecognizer:bubbleLongPressGesture];
          [self.contentView addSubview:self.bubbleImage];
          self.bubbleTapGesture = bubbleTapGesture;
          
          //内容
          self.contentLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
          self.contentLabel.numberOfLines = 0;
          self.contentLabel.delegate = self;
          self.contentLabel.font = [UIFont systemFontOfSize:16];
          self.contentLabel.textColor = self.dataInternal.record.msgDirection == MessageDirectionLeft ? BOSCOLORWITHRGBA(0x2e343d, 1.0) : [UIColor whiteColor];
          [self.bubbleImage addSubview:self.contentLabel];
          //文本消息内容
          KDExpressionLabelType type = KDExpressionLabelType_Expression | KDExpressionLabelType_URL | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_TOPIC | KDExpressionLabelType_Keyword|KDExpressionLabelType_USERNAME;
          self.textContentLabel = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:type urlRespondFucIfNeed:nil];
          self.textContentLabel.delegate = self;
          self.textContentLabel.font = FS4;
          self.textContentLabel.textColor =  self.dataInternal.record.msgDirection == MessageDirectionLeft ? FC1 : [UIColor whiteColor];
          [self.bubbleImage addSubview:self.textContentLabel];
          
          
          
          KDExpressionLabelType typeReply = KDExpressionLabelType_Expression;
          self.replyContentLabel = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:typeReply urlRespondFucIfNeed:nil];
          self.replyContentLabel.delegate = self;
          //self.replyContentLabel.bShouldShowUnderscore = YES;
          self.replyContentLabel.font = FS7;
          self.replyContentLabel.textColor =  self.dataInternal.record.msgDirection == MessageDirectionLeft ? FC1 : [UIColor whiteColor];
          self.replyContentLabel.hidden = YES;
          [self.bubbleImage addSubview:self.replyContentLabel];
          
          self.viewOriginalButton = [[UIButton alloc] initWithFrame:CGRectZero];
          self.viewOriginalButton.hidden = YES;
          [self.bubbleImage addSubview:self.viewOriginalButton];
          
          self.replyLine = [UIView new];
          self.replyLine.backgroundColor = [UIColor grayColor];
          [self.bubbleImage addSubview:self.replyLine];
          self.replyLine.hidden = YES;
          
          
          
          
          self.voiceView = [[BubbleVoiceView alloc] init];
          self.voiceView.hidden = YES;
          [self.bubbleImage addSubview:self.voiceView];
          
          //图片（缩略图）
          self.thumbnailImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
          [self.thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
          self.thumbnailImageView.clipsToBounds = YES;
          self.thumbnailImageView.hidden = YES;
          self.thumbnailImageView.layer.cornerRadius = 3;
          self.thumbnailImageView.layer.masksToBounds = YES;
          self.thumbnailImageView.userInteractionEnabled = YES;
          [self.bubbleImage addSubview:self.thumbnailImageView];
          
          
          //除了图片跟location，其他都是隐藏的
          self.maskImageView = [UIImageView new];
          self.maskImageView.hidden = YES;
          [self.bubbleImage addSubview:self.maskImageView];
          
          //地址信息
          self.locationBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
          [self.locationBgView setContentMode:UIViewContentModeScaleToFill];
          self.locationBgView.hidden = YES;
          self.locationBgView.layer.cornerRadius = 3;
          self.locationBgView.layer.masksToBounds = YES;
          [self.bubbleImage addSubview:self.locationBgView];
          
          self.locationInfo = [[UILabel alloc]initWithFrame:CGRectZero];
          self.locationInfo.textAlignment = NSTextAlignmentLeft;
          self.locationInfo.font = FS7;
          self.locationInfo.textColor = FC6;
          self.locationInfo.layer.cornerRadius = 3;
          self.locationInfo.layer.masksToBounds = YES;
          [self.locationBgView addSubview:self.locationInfo];
          
          
          //小视频
          self.timeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
          self.timeLabel.textAlignment = NSTextAlignmentLeft;
          self.timeLabel.font = FS7;
          self.timeLabel.textColor = FC6;
          self.timeLabel.backgroundColor = [UIColor clearColor];
          [self.locationBgView addSubview:self.timeLabel];
          
          self.sizeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
          self.sizeLabel.textAlignment = NSTextAlignmentRight;
          self.sizeLabel.font = FS7;
          self.sizeLabel.textColor = FC6;
          self.sizeLabel.backgroundColor = [UIColor clearColor];
          [self.locationBgView addSubview:self.sizeLabel];
          
          self.shortVideoBtn = [[UIButton alloc]initWithFrame:CGRectZero];
          self.shortVideoBtn.backgroundColor = [UIColor clearColor];
          self.shortVideoBtn.hidden = YES;
          [self.shortVideoBtn addTarget:self action:@selector(loadAndPlayVideo) forControlEvents:UIControlEventTouchUpInside];
          [self.thumbnailImageView addSubview:self.shortVideoBtn];
          
          //无痕消息
          self.notraceImageView = [[UIImageView alloc] init];
          self.notraceImageView.userInteractionEnabled = YES;
          [self.bubbleImage addSubview:self.notraceImageView];
          [self.notraceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.edges.equalTo(self.notraceImageView.superview).with.insets(UIEdgeInsetsZero);
          }];
          
          //合并记录
          self.combineTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
          self.combineTitleLabel.textAlignment = NSTextAlignmentLeft;
          self.combineTitleLabel.font = FS3;
          self.combineTitleLabel.textColor = FC1;
          self.combineTitleLabel.backgroundColor = [UIColor clearColor];
          [self.bubbleImage addSubview:self.combineTitleLabel];
          
          self.combineContentLabelArray = [NSMutableArray new];
          for(int i = 0;i<4;i++)
          {
               UILabel *combineContentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
               combineContentLabel.textAlignment = NSTextAlignmentLeft;
               combineContentLabel.font = FS6;
               combineContentLabel.textColor = FC2;
               combineContentLabel.backgroundColor = [UIColor clearColor];
               [self.bubbleImage addSubview:combineContentLabel];
               [self.combineContentLabelArray addObject:combineContentLabel];
          }
          
          
          //其他
          self.redDotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_img_new"]];
          self.redDotImageView.frame = CGRectMake(0,0,7,7);
          self.redDotImageView.hidden = YES;
          [self.contentView addSubview:self.redDotImageView];
          
          self.sendFailueButton = [UIButton buttonWithType:UIButtonTypeCustom];
          [self.sendFailueButton setFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
          [self.sendFailueButton setBackgroundImage:[XTImageUtil chatSendFailueImage] forState:UIControlStateNormal];
          [self.sendFailueButton addTarget:self action:@selector(reSend:) forControlEvents:UIControlEventTouchUpInside];
          self.sendFailueButton.hidden = YES;
          [self.contentView addSubview:self.sendFailueButton];
          
          self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
          self.activityIndicatorView.hidden = NO;
          [self.contentView addSubview:self.activityIndicatorView];
          
          self.roundProgressView = [[XTRoundProgressView alloc] init];
          self.roundProgressView.hidden = YES;
          [self.contentView addSubview:self.roundProgressView];
          
          UIButton *actionButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
          [actionButton1 setFrame:CGRectMake(0.0, 0.0, ScreenFullWidth - 20, 31.0)];
          actionButton1.tag = 0;
          [actionButton1 addTarget:self action:@selector(actionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
          self.actionButton1 = actionButton1;
          [self.bubbleImage addSubview:actionButton1];
          
          UIButton *actionButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
          [actionButton2 setFrame:CGRectMake(0.0, 0.0,  ScreenFullWidth - 20, 31.0)];
          actionButton2.tag = 1;
          [actionButton2 addTarget:self action:@selector(actionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
          self.actionButton2 = actionButton2;
          [self.bubbleImage addSubview:actionButton2];
          
          //news
          self.newsview=[[UIImageView alloc]init];
          [self.contentView addSubview:self.newsview];
          
          self.newsimage=[[XTNewsImage alloc]init];
          self.newsimage.contentMode = UIViewContentModeTop;
          [self.newsview addSubview:self.newsimage];
          
          self.backview=[[UIView alloc]init];
          [self.newsimage addSubview:self.backview];
          self.backview.backgroundColor=[UIColor colorWithRGB:0x0C203F];
          self.backview.alpha=0.8;
          
          self.newsbackview=[[UIView alloc]init];
          [self.newsview addSubview:self.newsbackview];
          
          self.newstitle=[[UILabel alloc]init];
          [self.newsview addSubview:self.newstitle];
          self.newstitle.font=[UIFont systemFontOfSize:15.0];
          self.newstitle.backgroundColor=[UIColor clearColor];
          self.newstitle.textColor=BOSCOLORWITHRGBA(0x202020, 1.0);
          
          self.newscontent=[[UILabel alloc]init];
          [self.newsview addSubview:self.newscontent];
          self.newscontent.font=[UIFont systemFontOfSize:13.0];
          self.newscontent.backgroundColor=[UIColor clearColor];
          self.newscontent.textColor=BOSCOLORWITHRGBA(0x4D4D4D, 1.0);
          
          self.newsdate=[[UILabel alloc]init];
          [self.newsview addSubview:self.newsdate];
          self.newsdate.font=[UIFont systemFontOfSize:10.0];
          self.newsdate.backgroundColor=[UIColor clearColor];
          self.newsdate.textColor=BOSCOLORWITHRGBA(0x202020, 1.0);
          
          self.newsbtn=[KDBubbleCellNewButton buttonWithType:UIButtonTypeCustom];
          [self.newsbtn addTarget:self action:@selector(newsclick:) forControlEvents:UIControlEventTouchUpInside];
          self.newsbtn.tag=0;
          [self.newsview addSubview:self.newsbtn];
          
          self.shareBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
          self.shareBackgroundView.backgroundColor = [UIColor whiteColor];
          [self.bubbleImage insertSubview:self.shareBackgroundView belowSubview:self.contentLabel];
          
          self.shareTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
          self.shareTitleLabel.font = [UIFont systemFontOfSize:14.0];
          self.shareTitleLabel.backgroundColor = [UIColor clearColor];
          self.shareTitleLabel.numberOfLines = 2;
          self.shareTitleLabel.textColor = BOSCOLORWITHRGBA(0x202020, 1.0);
          [self.bubbleImage addSubview:self.shareTitleLabel];
          
          self.shareThumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 55.0, 55.0)];
          [self.bubbleImage addSubview:self.shareThumbImageView];
          
          self.shareSeparatorLineBottom = [[UIView alloc] initWithFrame:CGRectZero];
          self.shareSeparatorLineBottom.backgroundColor = [UIColor kdDividingLineColor];
          [self.bubbleImage addSubview:self.shareSeparatorLineBottom];
          
          self.shareSourceAppLabel = [[UILabel alloc] initWithFrame:CGRectZero];
          self.shareSourceAppLabel.backgroundColor = [UIColor clearColor];
          self.shareSourceAppLabel.font = [UIFont systemFontOfSize:10.0];
          self.shareSourceAppLabel.textColor = BOSCOLORWITHRGBA(0xB5B5B5, 1.0);
          [self.bubbleImage addSubview:self.shareSourceAppLabel];
          
          
          
          //event buttons
          self.eventButtons = [NSMutableArray array];
          for (int i=0; i<3; i++) {
               UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
               button.tag = i;
               [button addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
               [button setTitleColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0) forState:UIControlStateNormal];
               [button setTitleColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0) forState:UIControlStateHighlighted];
               [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
               [self.newsview addSubview:button];
               [_eventButtons addObject:button];
          }
          self.eventLine = [[UIView alloc] initWithFrame:CGRectZero];
          self.eventLine.backgroundColor = [UIColor kdDividingLineColor];
          [self.newsview addSubview:_eventLine];
          
          //文件
          self.fileBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
          self.fileBackgroundView.backgroundColor = [UIColor clearColor];
          [self.bubbleImage insertSubview:self.fileBackgroundView belowSubview:self.contentLabel];
          
          self.fileTitleLabel = [UILabel new];
          self.fileTitleLabel.backgroundColor = [UIColor clearColor];
          self.fileTitleLabel.textColor = FC1;
          self.fileTitleLabel.font = FS4;
          self.fileTitleLabel.textAlignment = NSTextAlignmentLeft;
          self.fileTitleLabel.numberOfLines = 4;
          self.fileTitleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
          self.fileTitleLabel.hidden = YES;
          [self.bubbleImage addSubview:self.fileTitleLabel];
          
          self.fileSize = [[UILabel alloc] init];
          self.fileSize.backgroundColor = [UIColor clearColor];
          self.fileSize.textColor = BOSCOLORWITHRGBA(0x4D4D4D, 1.0);
          self.fileSize.font = [UIFont fontWithName:@"Arial" size:10.0];
          self.fileSize.hidden = YES;
          [self.bubbleImage addSubview:self.fileSize];
          
          self.fileButton = [UIButton buttonWithType:UIButtonTypeCustom];
          UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileButtonClick:)];
          self.fileButton.hidden = YES;
          self.tapRec = tapRec;
          [self.fileButton addGestureRecognizer:tapRec];
          [self.bubbleImage addSubview:self.fileButton];
          
          self.labelName = [UILabel new];
          self.labelName.font = FS6;
          self.labelName.textColor = FC1;
          [self.contentView addSubview:self.labelName];
          
          self.departmentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
          self.departmentLabel.font = FS6;
          self.departmentLabel.textColor = FC2;
          [self.contentView addSubview:self.departmentLabel];
     }
     return self;
}




- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender {
     if (sender.state == UIGestureRecognizerStateRecognized) {
          MessageType msgType = self.dataInternal.record.msgType;
          if (msgType == MessageTypeText || msgType == MessageTypeFile || msgType == MessageTypeShareNews || msgType == MessageTypePicture) {
               if ( msgType != MessageTypeSpeech && (![self.chatViewController.group isPublicGroup] && self.chatViewController.chatMode != ChatPublicMode) && ![self.dataInternal.record.strEmojiType isEqualToString:@"original"]) {
                    [self.bubbleImage mark:nil];
               }
          }
     }
}
- (void)manuStartPlayAudio
{
     [self performSelector:@selector(bubbleBtnTapPressed:) withObject:nil afterDelay:0.0];
}

- (void)setFrame:(CGRect)frame
{
     [super setFrame:frame];
     [self setupInternalData];
}
- (void)setChatViewController:(XTChatViewController *)chatViewController
{
     _chatViewController = chatViewController;
     self.headerView.longPressdelegate = chatViewController;
}

- (void)setMsgDeleteDelegate:(id)msgDeleteDelegate
{
     _msgDeleteDelegate = msgDeleteDelegate;
     _bubbleImage.delegate = msgDeleteDelegate;
}

- (void)setDataInternal:(BubbleDataInternal *)value
{
     if (_dataInternal != value) {
          _dataInternal = value;
          if (_playData) {
               _playData = nil;
          }
          
          [_bubbleImage setRecord:_dataInternal.record];
     }
     [self setupInternalData];
}

- (void)setUIComponentHidden:(RecordDataModel *)record
{
     MessageType type = record.msgType;
     
     self.contentLabel.hidden = (type == MessageTypePicture || type == MessageTypeNews || type == MessageTypeText);
     
     self.textContentLabel.hidden = (type != MessageTypeText);
     //    self.bubbleImage.hidden = (type == MessageTypeNews);
     
     self.thumbnailImageView.hidden = (type != MessageTypePicture && type != MessageTypeFile && type != MessageTypeLocation && type != MessageTypeShortVideo);
     
     self.actionButton1.hidden = YES;
     self.actionButton2.hidden = YES;
     
     for (UIButton *btn in _eventButtons) {
          [btn setHidden:YES];
     }
     self.eventLine.hidden = YES;
     
     self.newsimage.hidden = (type != MessageTypeNews);
     self.newstitle.hidden = self.newsimage.hidden;
     self.newsdate.hidden = self.newsimage.hidden;
     self.newscontent.hidden = self.newsimage.hidden;
     self.newsview.hidden = self.newsimage.hidden;
     
     self.shareBackgroundView.hidden = (type != MessageTypeShareNews);
     self.shareTitleLabel.hidden = self.shareBackgroundView.hidden;
     self.shareThumbImageView.hidden = self.shareBackgroundView.hidden;
     self.shareSourceAppLabel.hidden = self.shareBackgroundView.hidden;
     if (type == MessageTypeText || type == MessageTypePicture) {
          MessageShareTextOrImageDataModel *param = record.param.paramObject;
          self.shareSourceAppLabel.hidden = (param.appName.length == 0);
     }
     self.roundProgressView.hidden = YES;
     if (type == MessageTypeText) {
          MessageShareTextOrImageDataModel *param = record.param.paramObject;
          self.roundProgressView.hidden = (param.effectiveDuration == 0);
     }
     
     self.fileBackgroundView.hidden = !(type == MessageTypeFile && ![XTFileUtils isPhotoExt:((MessageFileDataModel *)record.param.paramObject).ext]);
     self.fileTitleLabel.hidden = self.fileBackgroundView.hidden;
     self.fileSize.hidden = self.fileBackgroundView.hidden;
     self.fileButton.hidden = self.fileBackgroundView.hidden;
     if (type == MessageTypeFile) {
          MessageFileDataModel *paramObject = record.param.paramObject;
          self.shareSourceAppLabel.hidden = self.fileBackgroundView.hidden || paramObject.appName.length == 0;
     }
     
     
     self.notraceImageView.hidden = YES;
}

- (void) setupInternalData
{
     RecordDataModel *record = self.dataInternal.record;
     MessageType type = record.msgType;
     MessageDirection direction = record.msgDirection;
     
     //双击标记，其它功能暂不知
     if (type != MessageTypeSystem) {
          //          self.bubbleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleBtnTapPressed:)];
          //          self.bubbleTapGesture.numberOfTapsRequired = 1;
          //          [self.bubbleImage addGestureRecognizer:self.bubbleTapGesture];
          
          self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
          //        doubleTapGesture.delegate = self;
          self.doubleTapGesture.numberOfTapsRequired = 2;
          [self.bubbleImage addGestureRecognizer:self.doubleTapGesture];
          [self.bubbleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
          [self.tapRec requireGestureRecognizerToFail:self.doubleTapGesture];
          [self.unreadTap requireGestureRecognizerToFail:self.doubleTapGesture];
     }
     
     
     //时间-标题
     if (self.dataInternal.header)
     {
          self.headerLabel.hidden = NO;
          self.headerLabel.text = self.dataInternal.header;
          if (self.dataInternal.group.groupType == 8)
          {
               self.headerLabel.bHideLines = YES;
               self.headerLabel.textColor =  RGBCOLOR(0, 108, 255);
               self.headerLabel.font = [UIFont systemFontOfSize:16];
               self.headerLabel.frame = CGRectMake(15, 2, 200, 24);
          }else if([self.dataInternal.header isEqualToString:ASLocalizedString(@"BubbleTableViewCell_Tip_2")])
          {
               self.headerLabel.textColor =  FC2;
               self.headerLabel.font = FS6;
               self.headerLabel.backgroundColor = [UIColor clearColor];
               self.headerLabel.layer.cornerRadius = 0;
               self.headerLabel.layer.masksToBounds = NO;
               self.headerLabel.bHideLines = NO;
               CGRect labelRect = [self.dataInternal.header
                                   boundingRectWithSize:self.headerLabel.frame.size
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{
                                                NSFontAttributeName : FS6
                                                }
                                   context:nil];
               self.headerLabel.frame = CGRectMake((ScreenFullWidth - (labelRect.size.width+140))/2, self.headerLabel.frame.origin.y, labelRect.size.width+140, 22);
               
          }
          else
          {
               self.headerLabel.bHideLines = YES;
               self.headerLabel.textColor = FC6;
               self.headerLabel.font = FS8;
               
               CGRect labelRect = [self.dataInternal.header
                                   boundingRectWithSize:self.headerLabel.frame.size
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{
                                                NSFontAttributeName : FS8
                                                }
                                   context:nil];
               self.headerLabel.frame = CGRectMake(0, self.headerLabel.frame.origin.y, labelRect.size.width+14, 22);
               
               SetCenterX(self.headerLabel.center, ScreenFullWidth/2.0);
               
               self.headerLabel.backgroundColor = UIColorFromRGB(0xcfd6e2);
               self.headerLabel.layer.cornerRadius = 6;
               self.headerLabel.layer.masksToBounds = YES;
               self.headerLabel.textAlignment = NSTextAlignmentCenter;
          }
     }
     else
     {
          self.headerLabel.hidden = YES;
          self.headerLabel.text = nil;
     }
     
     float startY = self.dataInternal.header ? 46 : 10;
     
     //头像
     if (type == MessageTypeSystem || type == MessageTypeCall || type == MessageTypeAttach || type == MessageTypeNews || type == MessageTypeCancel) {
          self.headerView.hidden = YES;
     }else{
          self.headerView.hidden = NO;
     }
     if (!self.headerView.hidden) {
          
          __block   PersonSimpleDataModel *person = nil;
          //         if(self.chatViewController.group.participant && record)
          //         {
          //              PersonSimpleDataModel *tempPerson = [[PersonSimpleDataModel alloc] init];
          //              tempPerson.personId = record.fromUserId;
          //              NSInteger index = [self.chatViewController.group.participant indexOfObject:tempPerson];
          //              if(index>=0 && index < self.chatViewController.group.participant.count)
          //                   person = self.chatViewController.group.participant[index];
          //         }
          
          if(person == nil && record)
               person =[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:record.fromUserId];
          
          if (person == nil) {
               PersonSimpleDataModel *person1 = [self.chatViewController.group.participant firstObject];
               if ([person1.personId isEqualToString:record.fromUserId]) {
                    person = person1;
               }
          }
          // 解决聊天界面自己看自己头像显示异常问题 by lee
          NSString *userID = [BOSConfig sharedConfig].user.userId;
          if ([person.personId isEqualToString:userID]) {
               if(person.status != 3)
               {
                    person.status = 3;
               }
          }
          //组装一个tempperson 主要是为了在人员拉取失败的的时候能够展示出名字和头像 706
          
          if (person != nil) {
               self.headerView.person = person;
               //同部门的不显示部门名称
               if(![person.orgId isEqualToString:[BOSConfig sharedConfig].user.orgId])
                    self.departmentLabel.text = person.department;
               self.labelName.text = person.personName;
               
          }else
          {
               //              如果为空 则先展示头像和部门，其他的先不管 706
               //              self.headerView.person = self.tempPerson;
               //              self.labelName.text = self.tempPerson.personName;
               if (record) {
                    __weak __typeof(self) weakSelf = self;
                    [self.userHelper  getPersonInfoWithPersonId:record.fromUserId
                                                     completion:^(BOOL success, NSArray *persons, NSString *error) {
                                                          if (success) {
                                                               PersonSimpleDataModel *localPerson = [[XTDataBaseDao sharedDatabaseDaoInstance]queryPersonWithPersonId:record.fromUserId];
                                                               person = localPerson;
                                                          }else
                                                          {
                                                               person = weakSelf.tempPerson;
                                                          }
                                                          weakSelf.headerView.person = person;
                                                          //同部门的不显示部门名称
                                                          if(![person.orgId isEqualToString:[BOSConfig sharedConfig].user.orgId])
                                                               weakSelf.departmentLabel.text = person.department;
                                                          weakSelf.labelName.text = person.personName;
                                                     }
                     ];
                    
               }
          }
          
          
          
          
          //        if (record.nickname.length > 0 && record.nickname.intValue != 0)
          //        {
          //            //            self.headerView.personNameLabel.text = record.nickname;
          //            self.labelName.text = record.nickname;
          //        }
          //        else
          //        {
          
          
          //        }
          self.headerView.hidePartnerImageView = YES;
          self.headerView.personNameLabel.hidden = YES;
          self.labelName.hidden= self.dataInternal.personNameLabelHidden;
          
          self.headerView.personHeaderImageView.frame = CGRectMake(0, 0, 44, 44);
          float headerViewHeight = 44;
          
          if (direction == MessageDirectionLeft)
          {
               self.labelName.frame = CGRectMake(66, Y(self.headerView.frame)-1, ScreenFullWidth-2*(12+44+5+5+8), 15);
               [self.labelName sizeToFit];
               
               self.headerView.frame = CGRectMake(10.0, startY, 44, headerViewHeight);
          }
          else
          {
               self.labelName.frame = CGRectMake(ScreenFullWidth - 10.0 - 66 - 28, Y(self.headerView.frame)-1, ScreenFullWidth-2*(12+44+5+5+8), 15);
               
               self.headerView.frame = CGRectMake(ScreenFullWidth - 10.0 - 44, startY, 44, headerViewHeight);
          }
          if (!self.dataInternal.personNameLabelHidden)
          {
               startY += 18;
          }
     }
     
     [self setUIComponentHidden:record];
     switch (type) {
          case MessageTypeSpeech:
          {
               float bubbleWidth = self.dataInternal.bubbleLabelSize.width ;
               float bubbleHeight = self.dataInternal.bubbleLabelSize.height;
               float bubbleX = direction == MessageDirectionLeft ? MaxX(self.headerView.frame) + 5 : self.headerView.frame.origin.x - bubbleWidth - 5;
               float bubbleY = startY;
               self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
               self.bubbleImage.image = [XTImageUtil chatDialogBackgroundImageWithDirection:direction state:UIControlStateNormal];
               self.contentLabel.font = [UIFont systemFontOfSize:12];
               self.contentLabel.text = [NSString stringWithFormat:@"%d\"",record.msgLen];
               self.contentLabel.textColor = direction == MessageDirectionLeft ? [UIColor blackColor] : [UIColor whiteColor];
               self.contentLabel.backgroundColor = [UIColor clearColor];
               self.contentLabel.frame = self.dataInternal.contentLabelFrame;
               self.contentLabel.textAlignment =  direction == MessageDirectionLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
          }
               break;
          case MessageTypeSystem:
          case MessageTypeCancel:
          {
               float contentWidth = self.dataInternal.bubbleLabelSize.width;
               float contentHeight = self.dataInternal.bubbleLabelSize.height;
               float contentX = (self.bounds.size.width - contentWidth)/2;
               float contentY = startY;
               self.bubbleImage.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);
               self.bubbleImage.image = nil;
               self.bubbleImage.highlightedImage = nil;
               self.contentLabel.text = self.dataInternal.record.content;
               self.contentLabel.frame = self.dataInternal.contentLabelFrame;
               self.contentLabel.backgroundColor = [UIColor clearColor];
               self.contentLabel.textAlignment = NSTextAlignmentCenter;
               self.contentLabel.backgroundColor = UIColorFromRGB(0xcfd6e2);
               self.contentLabel.layer.cornerRadius = 6;
               self.contentLabel.centerVertically = YES;
               self.contentLabel.extendBottomToFit = NO;
               self.contentLabel.layer.masksToBounds = YES;
               self.contentLabel.textColor = FC6;
               self.contentLabel.font = FS8;
          }
               break;
          case MessageTypePicture:
          {
               [self setupPictureWithY:startY];
          }
               break;
          case MessageTypeAttach:
          {
               self.bubbleImage.frame = CGRectMake(12, startY, ScreenFullWidth - 24, self.dataInternal.bubbleLabelSize.height);
               self.bubbleImage.image = [XTImageUtil newsBackgroundImage];
               
               MessageAttachDataModel *paramObject = record.param.paramObject;
               int paramsCount = (int)[paramObject.attach count];
               
               self.contentLabel.text = record.content;
               self.contentLabel.textColor = FC1;
               self.contentLabel.font = FS3;
               self.contentLabel.backgroundColor = [UIColor clearColor];
               self.contentLabel.textAlignment = NSTextAlignmentLeft;
               self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
               self.contentLabel.frame = CGRectMake(12, 12, ScreenFullWidth-48, [record.content sizeForMaxWidth:ScreenFullWidth-48 font:FS3].height);
               
               UIView *viewLineMiddle = [UIView new];
               viewLineMiddle.frame = CGRectMake(12, MaxY(self.contentLabel.frame) + 7, ScreenFullWidth-48, 0.5);
               viewLineMiddle.backgroundColor = [UIColor kdDividingLineColor];
               [self.bubbleImage addSubview:viewLineMiddle];
               
               [self.actionButton1 setTitleColor:FC1 forState:UIControlStateNormal];
               [self.actionButton2 setTitleColor:FC1 forState:UIControlStateNormal];
               [self.actionButton1.titleLabel setFont:FS5];
               [self.actionButton2.titleLabel setFont:FS5];
               
               
               if (paramsCount == 1)
               {
                    self.actionButton1.hidden = NO;
                    self.actionButton2.hidden = YES;
                    
                    MessageAttachEachDataModel *attach = [paramObject.attach objectAtIndex:0];
                    [self.actionButton1 setTitle:attach.name forState:UIControlStateNormal];
                    
               } else if (paramsCount == 2)
               {
                    self.actionButton1.hidden = NO;
                    self.actionButton2.hidden = NO;
                    
                    
                    MessageAttachEachDataModel *attach1 = [paramObject.attach objectAtIndex:0];
                    [self.actionButton1 setTitle:attach1.name forState:UIControlStateNormal];
                    
                    MessageAttachEachDataModel *attach2 = [paramObject.attach objectAtIndex:1];
                    [self.actionButton2 setTitle:attach2.name forState:UIControlStateNormal];
                    
               }
               else
               {
                    self.actionButton1.hidden = YES;
                    self.actionButton2.hidden = YES;
               }
               self.actionButton1.frame = CGRectMake(12, viewLineMiddle.frame.origin.y + viewLineMiddle.frame.size.height , ScreenFullWidth-48, 35);
               self.actionButton2.frame = CGRectMake(12, self.actionButton1.frame.origin.y + self.actionButton1.frame.size.height - 1, ScreenFullWidth-48, 35);
               
               [self.actionButton1 setImage:[XTImageUtil cellAccessoryDisclosureIndicatorImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
               [self.actionButton1 setImage:[XTImageUtil cellAccessoryDisclosureIndicatorImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
               self.actionButton1.imageEdgeInsets = UIEdgeInsetsMake(0, Width(self.actionButton1.frame)-12, 0, 0);
               
               self.actionButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
               self.actionButton1.contentEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
               
               [self.actionButton2 setImage:[XTImageUtil cellAccessoryDisclosureIndicatorImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
               [self.actionButton2 setImage:[XTImageUtil cellAccessoryDisclosureIndicatorImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
               self.actionButton2.imageEdgeInsets = UIEdgeInsetsMake(0, Width(self.actionButton1.frame)-12, 0, 0);
               self.actionButton2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
               self.actionButton2.contentEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
          }
               break;
          case MessageTypeNews:
          {
               //判断有没有时间线
               self.newsview.userInteractionEnabled = YES;
               
               MessageNewsDataModel *paramObject = record.param.paramObject;
               if (self.dataInternal.header && paramObject.newslist.count > 0)
               {
                    self.newsview.frame=CGRectMake(12, 36+20, ScreenFullWidth-24, self.dataInternal.cellHeight-36-20);
               }
               else
               {
                    self.newsview.frame=CGRectMake(12, 15, ScreenFullWidth-24, self.dataInternal.cellHeight-10);
               }
               self.bubbleImage.frame = self.newsview.frame;
               self.newsview.image=[XTImageUtil newsBackgroundImage];
               if (paramObject.model==3)
               {
                    
                    /*
                     newsview:大背景
                     backview：蒙层
                     newsimage：图片
                     newsbackview: 下面列表的背景
                     */
                    
                    
                    // 多图文
                    self.bubbleImage.userInteractionEnabled = NO;
                    
                    
                    self.newscontent.hidden=YES;
                    self.newsbackview.hidden=NO;
                    self.backview.hidden=NO;
                    
                    MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                    [self.newsimage setFrame:CGRectMake(12, 10, Width(self.newsview.frame)-12*2, kNewsBigPictureHeight)];
                    
                    self.newsimage.imagev = news;
                    self.newsimage.contentMode = UIViewContentModeScaleAspectFill;
                    
                    //                self.backview.frame=CGRectMake(-9, 80, 310, 50);
                    //                self.backview.backgroundColor = [UIColor kdPopupColor];
                    
                    //                [self.newsdate setFrame:CGRectMake(15, 120, 270, 10)];
                    //                self.newsdate.textColor=BOSCOLORWITHRGBA(0xFFFFFF, 1.0);
                    //                self.newsdate.text=news.date;
                    
                    //////////////////////////////////////////////////////////////////////////////////
                    // hide news date 20150119
                    self.newsdate.hidden = YES;
                    
                    // 设置上方标题的多行控制
                    [self.newstitle setFrame:CGRectMake(12+5, 95, Width(self.newsview.frame)-12*2-5*2, 20)];
                    self.newstitle.text=news.title;
                    self.newstitle.textColor= FC6;
                    self.newstitle.font = FS5;
                    self.newstitle.numberOfLines = 0;
                    // 计算按这个宽度，字体，产生的高度（因上面设置的行数限制是2，其实这里只是在动态获取1行或2行的高度值）
                    //                CGSize labelSize = [self.newstitle.text sizeWithFont:self.newstitle.font
                    //                                                   constrainedToSize:CGSizeMake(self.newstitle.frame.size.width, CGFLOAT_MAX)
                    //                                                       lineBreakMode:NSLineBreakByWordWrapping];
                    CGSize labelSize = [self.newstitle.text sizeForMaxWidth:Width(self.newstitle.frame) font:self.newstitle.font];
                    CGFloat labelHeight = labelSize.height+2;
                    // 用换算的动态高度设置标题和灰度蒙层背景
                    SetHeight(self.newstitle.frame, labelHeight);
                    // 调整标题的y值，通过大view高度-下方view高度-偏移量
                    SetY(self.newstitle.frame, MaxY(self.newsimage.frame)-Height(self.newstitle.frame)-5);
                    // 设置灰度蒙层背景frame
                    SetFrame(self.backview.frame, 0,  Y(self.newstitle.frame) - 15, self.newsimage.frame.size.width, self.newstitle.frame.size.height + 10);
                    
                    self.newsbackview.frame=CGRectMake(12, MaxY(self.newsimage.frame) , Width(self.newsimage.frame), 60*paramObject.newslist.count);
                    self.newsbtn.frame=CGRectMake(0, 0, self.newsview.frame.size.width, kNewsBigPictureHeight);
                    //给第一个newsBtn添加长点击事件
                    UILongPressGestureRecognizer * newbtnGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(newButtonLongPressed:)];
                    [self.newsbtn addGestureRecognizer:newbtnGesture];
                    self.newsbtn.forwardDelegate = self;
                    self.newsbtn.deleteDelegate = self.chatViewController;
                    self.newsbtn.cell = self;
                    self.newsbtn.bubbleImageView = _bubbleImage;
                    self.newsbtn.record = record;
                    
                    for (UIView* view in self.newsbackview.subviews) {
                         [view removeFromSuperview];
                    }
                    
                    // 下面新闻列表的第一条线
                    UIView *viewLineMiddle = [UIView new];
                    viewLineMiddle.backgroundColor = [UIColor kdDividingLineColor];
                    viewLineMiddle.frame = CGRectMake(0, 0, Width(self.newsbackview.frame), .5);
                    [self.newsbackview addSubview:viewLineMiddle];
                    
                    for (int i=1; i<paramObject.newslist.count; i++) {
                         MessageNewsEachDataModel*newsaaa=[paramObject.newslist objectAtIndex:i];
                         
                         if (i > 0 && i != paramObject.newslist.count-1)
                         {
                              UILabel*line=[[UILabel alloc]initWithFrame:CGRectMake(0, i*60, Width(self.newsbackview.frame), .5)];
                              [self.newsbackview addSubview:line];
                              line.backgroundColor= [UIColor kdDividingLineColor];
                         }
                         
                         UILabel*titlelabel=[[UILabel alloc]init];
                         [self.newsbackview addSubview:titlelabel];
                         titlelabel.backgroundColor=[UIColor clearColor];
                         titlelabel.text=newsaaa.text;
                         titlelabel.lineBreakMode = NSLineBreakByTruncatingTail;
                         titlelabel.numberOfLines = 0;
                         titlelabel.textColor = FC1;
                         titlelabel.font= FS5;
                         if (newsaaa.name.length > 0)
                         {
                              XTNewsImage*listimage=[[XTNewsImage alloc]initWithFrame:CGRectMake(Width(self.newsbackview.frame)-50, 60*(i-1)+5, 50, 50)];
                              listimage.imagev=[paramObject.newslist objectAtIndex:i];
                              listimage.contentMode = UIViewContentModeScaleAspectFit;
                              [self.newsbackview addSubview:listimage];
                              titlelabel.frame=CGRectMake(0, 60*(i-1), Width(self.newsbackview.frame)-12-50, 60);
                         }
                         else
                         {
                              titlelabel.frame=CGRectMake(0, 60*(i-1), Width(self.newsbackview.frame)-12, 60);
                         }
                         
                         //                    UILabel*datelabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 74*i-25, 260, 10)];
                         //                    [self.newsbackview addSubview:datelabel];
                         //                    datelabel.backgroundColor=[UIColor clearColor];
                         //                    datelabel.font=[UIFont systemFontOfSize:13.0];
                         //                    datelabel.text=newsaaa.date;
                         //
                         //                    //////////////////////////////////////////////////////////////
                         //                    // hide news date 20150119
                         //                    datelabel.hidden = YES;
                         //
                         //                    //////////////////////////////////////////////////////////////
                         
                         //初始KDBubbleCellNewButton
                         KDBubbleCellNewButton *btn = [KDBubbleCellNewButton buttonWithType:UIButtonTypeCustom];
                         btn.forwardDelegate =self;
                         btn.deleteDelegate = self.chatViewController;
                         btn.bubbleImageView = _bubbleImage;
                         btn.record = record;
                         btn.cell = self;
                         //给下面小图的btn添加长按点击事件
                         UILongPressGestureRecognizer * newbtnGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(newButtonLongPressed:)];
                         [btn addGestureRecognizer:newbtnGesture];
                         
                         btn.frame=CGRectMake(0, 60*(i-1), Width(self.newsbackview.frame), 60);
                         [self.newsbackview addSubview:btn];
                         [btn addTarget:self action:@selector(newsclick:) forControlEvents:UIControlEventTouchUpInside];
                         btn.tag=i;
                    }
               }
               else if (paramObject.model==2 || (paramObject.model == 4 && [[paramObject.newslist objectAtIndex:0] hasHeaderPicture])) {
                    // 单图文新闻
                    
                    self.backview.hidden=YES;
                    self.newsbackview.hidden=YES;
                    self.newstitle.textColor=FC1;
                    self.newstitle.font = FS3;
                    self.newsdate.textColor=FC2;
                    self.newsdate.font = FS8;
                    self.newscontent.font = FS6;
                    self.newscontent.textColor = FC1;
                    MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                    
                    [self.newstitle setFrame:CGRectMake(12, 15, ScreenFullWidth-24*2, [news.title sizeForMaxWidth:ScreenFullWidth-24*2 font:FS3].height)];
                    self.newstitle.text=news.title;
                    self.newstitle.numberOfLines = 0;
                    
                    if (news.date.length > 0)
                    {
                         [self.newsdate setFrame:CGRectMake(12, MaxY(self.newstitle.frame)+12, Width(self.newstitle.frame), 15)];
                         self.newsdate.text=news.date;
                         [self.newsimage setFrame:CGRectMake(12, MaxY(self.newsdate.frame)+12, Width(self.newsview.frame)-12*2, kNewsBigPictureHeight)];
                    }
                    else
                    {
                         [self.newsimage setFrame:CGRectMake(12, MaxY(self.newstitle.frame)+12, Width(self.newsview.frame)-12*2, kNewsBigPictureHeight)];
                    }
                    
                    self.newsimage.imagev=[paramObject.newslist objectAtIndex:0];
                    [self.newscontent setFrame:CGRectMake(12, MaxY(self.newsimage.frame)+12, ScreenFullWidth-12*2-12*2, [news.text sizeForMaxWidth:ScreenFullWidth-12*2-12*2 font:FS6].height)];
                    self.newscontent.text=news.text;
                    self.newscontent.numberOfLines = 0;
                    self.newsbtn.frame=CGRectMake(0, 0, self.newsview.frame.size.width, self.newsview.frame.size.width);
                    self.newsimage.contentMode = UIViewContentModeScaleAspectFill;
                    if ([news.buttons count]>0)
                    {
                         
                         _eventLine.hidden = NO;
                         _eventLine.frame = CGRectMake(1, self.newscontent.frame.origin.y + self.newscontent.frame.size.height + 5.0, CGRectGetWidth(self.newsview.frame) -2, 0.5f);
                         
                         NSInteger count = news.buttons.count;
                         if (count>3) {
                              count = 3;
                         }
                         for (int i=0; i< count; i++) {
                              UIButton *button = [_eventButtons objectAtIndex:i];
                              button.hidden = NO;
                              MessageTypeNewsEventsModel *model = [news.buttons objectAtIndex:i];
                              [button setTitle:model.title forState:UIControlStateNormal];
                              
                              CGFloat bgWidth = CGRectGetWidth(self.newsview.bounds);
                              CGFloat width = bgWidth*0.3333333f;
                              
                              button.frame = CGRectMake(bgWidth - count*width + i*width, self.newscontent.frame.origin.y + self.newscontent.frame.size.height + 10.0, width, 23.f);
                         }
                    }
                    
               }
               else if ((paramObject.model==1 && !paramObject.todoNotify) || (paramObject.model == 4 && ![[paramObject.newslist objectAtIndex:0] hasHeaderPicture])) {
                    // 纯文本新闻, 单图文但没有图 (包括：任务助手)
                    
                    self.newsbackview.hidden=YES;
                    self.newsimage.hidden=YES;
                    self.backview.hidden=YES;
                    self.newstitle.textColor=FC1;
                    self.newstitle.font = FS3;
                    self.newsdate.textColor=FC2;
                    self.newsdate.font = FS8;
                    
                    
                    MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                    
                    [self.newstitle setFrame:CGRectMake(12, 15, ScreenFullWidth-24*2, [news.title sizeForMaxWidth:ScreenFullWidth-24*2 font:FS3].height)];
                    self.newstitle.text=news.title;
                    self.newstitle.numberOfLines = 0;
                    self.newscontent.text=news.text;
                    self.newscontent.numberOfLines = 4;
                    self.newsbtn.frame=CGRectMake(0, 0, self.newsview.frame.size.width, self.newsview.frame.size.width);
                    self.newscontent.textColor = FC2;
                    self.newscontent.font = FS6;
                    if (news.date.length > 0)
                    {
                         [self.newsdate setFrame:CGRectMake(12, MaxY(self.newstitle.frame) + 12, ScreenFullWidth-24*2, 15)];
                         self.newsdate.text=news.date;
                         
                         [self.newscontent setFrame:CGRectMake(12, MaxY(self.newsdate.frame) + 12, ScreenFullWidth-24*2,  [news.text sizeForMaxWidth:ScreenFullWidth-24*2 font:FS6 numberOfLines:4].height)];
                    }
                    else
                    {
                         [self.newscontent setFrame:CGRectMake(12, MaxY(self.newstitle.frame) + 12, ScreenFullWidth-24*2, [news.text sizeForMaxWidth:ScreenFullWidth-24*2 font:FS6 numberOfLines:4].height)];
                    }
                    
                    if ([news.buttons count]>0)
                    {
                         
                         _eventLine.hidden = NO;
                         _eventLine.frame = CGRectMake(1, self.newscontent.frame.origin.y + self.newscontent.frame.size.height + 5.0, CGRectGetWidth(self.newsview.frame) -2, 0.5f);
                         
                         NSInteger count = news.buttons.count;
                         if (count>3)
                         {
                              count = 3;
                         }
                         for (int i=0; i< count; i++)
                         {
                              UIButton *button = [_eventButtons objectAtIndex:i];
                              button.hidden = NO;
                              MessageTypeNewsEventsModel *model = [news.buttons objectAtIndex:i];
                              [button setTitle:model.title forState:UIControlStateNormal];
                              
                              CGFloat bgWidth = CGRectGetWidth(self.newsview.bounds);
                              CGFloat width = bgWidth*0.3333333f;
                              
                              button.frame = CGRectMake(bgWidth - count*width + i*width, self.newscontent.frame.origin.y + self.newscontent.frame.size.height + 10.0, width, 23.f);
                         }
                    }
               }
               
               
               
               if (paramObject.model==1 && paramObject.todoNotify)
               {
                    // TODO: KSSP-17393-iOS_时间线上增加待办消息分类
                    
                    /////////////////////////////////////////////////////////////////////////////////////////////////
                    
                    self.backview.hidden=YES;
                    self.newsbackview.hidden=YES;
                    
                    MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                    self.newstitle.textColor=BOSCOLORWITHRGBA(0x202020, 1.0);
                    self.newstitle.font = [UIFont boldSystemFontOfSize:16];
                    self.newstitle.text=news.title;
                    [self.newstitle setFrame:CGRectMake(CGRectGetMaxX(self.newsimage.frame) + 10, 15, 200, 15)];
                    
                    [self.newsimage setFrame:CGRectMake(10, 10, 40, 40)];
                    self.newsimage.imagev=[paramObject.newslist objectAtIndex:0];
                    self.newsimage.layer.cornerRadius = 2;
                    
                    self.newsdate.textColor= MESSAGE_NAME_COLOR;
                    
                    // 只留时间, 去掉日期
                    if (!formatter)
                    {
                         formatter = [[NSDateFormatter alloc]init];
                    }
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *date = [formatter dateFromString:news.date];
                    [formatter setDateFormat:@"HH:mm:ss"];
                    self.newsdate.text = [formatter stringFromDate:date];
                    
                    [self.newsdate setFrame:CGRectMake(CGRectGetMaxX(self.newsimage.frame) + 10, CGRectGetMaxY(self.newstitle.frame)+7, 200, 15)];
                    
                    // content
                    [self.newscontent setFrame:CGRectMake(CGRectGetMaxX(self.newsimage.frame) + 10, CGRectGetMaxY(self.newstitle.frame)+5, 200, self.dataInternal.bubbleLabelSize.height)];
                    
                    self.newscontent.numberOfLines = 0;
                    self.newscontent.font = [UIFont systemFontOfSize:14];
                    self.newsbtn.frame=CGRectMake(0, 0, self.newsview.frame.size.width, self.newsview.frame.size.width);
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentJustified;
                    NSDictionary *attributes = @{ NSParagraphStyleAttributeName : paragraph,
                                                  NSFontAttributeName : self.newscontent.font,
                                                  NSBaselineOffsetAttributeName : [NSNumber numberWithFloat:0] };
                    NSAttributedString *str = [[NSAttributedString alloc] initWithString:news.text
                                                                              attributes:attributes];
                    self.newscontent.attributedText = str;
                    
                    // date
                    if(news.date)
                    {
                         
                         SetY(self.newscontent.frame, CGRectGetMaxY(self.newsdate.frame)+5);
                    }
                    else
                    {
                         self.newsdate.hidden = YES;
                    }
                    
                    UIImageView *imageViewAccessory = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3"]];
                    imageViewAccessory.contentMode = UIViewContentModeScaleAspectFit;
                    SetSize(imageViewAccessory.frame, 10, 10);
                    SetOrigin(imageViewAccessory.frame,  CGRectGetWidth(self.newsview.bounds) - 10 - CGRectGetWidth(imageViewAccessory.bounds), CGRectGetHeight(self.newsview.bounds)/2 - CGRectGetHeight(imageViewAccessory.frame)/2);
                    [self.newsview addSubview:imageViewAccessory];
                    
                    if ([news.buttons count]>0)
                    {
                         _eventLine.hidden = NO;
                         _eventLine.frame = CGRectMake(1, self.newscontent.frame.origin.y + self.newscontent.frame.size.height + 5.0, CGRectGetWidth(self.newsview.frame) -2, 0.5f);
                         
                         NSInteger count = news.buttons.count;
                         if (count>3)
                         {
                              count = 3;
                         }
                         for (int i=0; i< count; i++)
                         {
                              UIButton *button = [_eventButtons objectAtIndex:i];
                              button.hidden = NO;
                              MessageTypeNewsEventsModel *model = [news.buttons objectAtIndex:i];
                              [button setTitle:model.title forState:UIControlStateNormal];
                              
                              CGFloat bgWidth = CGRectGetWidth(self.newsview.bounds);
                              CGFloat width = bgWidth*0.3333333f;
                              
                              button.frame = CGRectMake(bgWidth - count*width + i*width, self.newscontent.frame.origin.y + self.newscontent.frame.size.height + 10.0, width, 23.f);
                         }
                    }
               }
          }
               break;
          case MessageTypeShareNews:
          {
               MessageShareNewsDataModel *paramObject = record.param.paramObject;
               float bubbleHeight = self.dataInternal.bubbleLabelSize.height;
               float bubbleX = 10+3+44;
               float bubbleY = startY;
               self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, ScreenFullWidth - (10+3+44)*2, bubbleHeight);
               self.bubbleImage.image = [XTImageUtil chatPictureBackgroundImageWithDirection:direction state:UIControlStateNormal];
               
               self.shareBackgroundView.frame = CGRectMake(7, 2.0, self.bubbleImage.frame.size.width-14, bubbleHeight-4.0);
               
               self.shareTitleLabel.frame = CGRectMake(12, 12, ScreenFullWidth - (12+3+44+12)*2, 20);
               self.shareTitleLabel.text = paramObject.title;
               self.shareTitleLabel.font = FS4;
               self.shareTitleLabel.textColor = FC1;
               
               self.contentLabel.text = paramObject.content;
               self.contentLabel.font = FS6;
               self.contentLabel.textColor = FC2;
               self.contentLabel.textAlignment = NSTextAlignmentLeft;
               self.contentLabel.numberOfLines = 3;
               self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
               self.contentLabel.backgroundColor = [UIColor clearColor];
               self.contentLabel.frame = CGRectMake(12, MaxY(self.shareTitleLabel.frame)+8, ScreenFullWidth - (10+44+3+12)*2-8-55, self.shareThumbImageView.frame.size.height);
               
               self.shareThumbImageView.frame = CGRectMake(MaxX(self.contentLabel.frame)+8, MaxY(self.shareTitleLabel.frame)+8, self.shareThumbImageView.bounds.size.width, self.shareThumbImageView.bounds.size.height);
               self.shareThumbImageView.layer.cornerRadius = 6;
               self.shareThumbImageView.layer.masksToBounds = YES;
               [self.shareThumbImageView setImageWithURL:[NSURL URLWithString:paramObject.thumbUrl] placeholderImage:[UIImage imageNamed:@"mark_tip_link"]];
               
               [self.shareSeparatorLineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.contentLabel.bottom).offset(8);
                    make.left.equalTo(self.shareSeparatorLineBottom.superview.left).offset(0.5);
                    make.right.equalTo(self.shareSeparatorLineBottom.superview.right).offset(-0.5);
                    make.height.mas_equalTo(1);
                    //                 make.width.mas_equalTo(self.shareSeparatorLineBottom.superview.frame.size.width);
               }];
               
               [self.shareSourceAppLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.shareSeparatorLineBottom.bottom).offset(5);
                    make.left.equalTo(self.shareSourceAppLabel.superview.left).offset(12);
                    make.right.equalTo(self.shareSourceAppLabel.superview.right).offset(-12);
                    make.height.mas_equalTo(10);
                    
                    
               }];
               
               self.shareSourceAppLabel.attributedText = [self attributedstringWithImageName:@"message_from_app_triangle" content:[NSString stringWithFormat:(ASLocalizedString(@"BubbleTableViewCell_Tip_3")),paramObject.appName] textColor:FC2];
               
          }
               break;
          case MessageTypeFile:
          {
               [self setupFileDataWithY:startY];
          }
               break;
          case MessageTypeLocation:
          {
               [self setupLocationPictureWithY:startY];
          }
               break;
          case MessageTypeShortVideo:
          {
               [self setupShortVideoPictureWithY:startY];
          }
               break;
               
          case MessageTypeNotrace:
          {
               float bubbleWidth = _dataInternal.bubbleLabelSize.width;
               float bubbleHeight = _dataInternal.bubbleLabelSize.height;
               float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 5.0 : self.headerView.frame.origin.x - bubbleWidth - 5;
               float bubbleY = startY;
               self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
               
               self.notraceImageView.hidden = NO;
               self.notraceImageView.image = (_dataInternal.record.msgDirection == MessageDirectionLeft ?[UIImage imageNamed:leftImageName] : [UIImage imageNamed:rightImageName]);
               self.notraceImageView.highlightedImage = _dataInternal.record.msgDirection == MessageDirectionLeft ?[UIImage imageNamed:leftPressImageName] : [UIImage imageNamed:rightPressImageName];
          }
               break;
          case MessageTypeCombineForward:
          {
               self.bubbleImage.image = [XTImageUtil chatPictureBackgroundImageWithDirection:direction state:UIControlStateNormal];
               
               float bubbleWidth = _dataInternal.bubbleLabelSize.width;
               float bubbleHeight = _dataInternal.bubbleLabelSize.height;
               float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 5.0 : self.headerView.frame.origin.x - bubbleWidth - 5;
               float bubbleY = startY;
               self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
               self.combineTitleLabel.frame = CGRectMake(8, 8, bubbleWidth-16, 20);
               
               MessageCombineForwardDataModel *forwardDataModel = (MessageCombineForwardDataModel *)self.dataInternal.record.param.paramObject;
               
               
               self.combineTitleLabel.text = forwardDataModel.title;
               
               NSArray *contetnArray = [forwardDataModel.content componentsSeparatedByString:@"\n"];
               __block CGRect contentLabelFrame = CGRectMake(CGRectGetMinX(self.combineTitleLabel.frame), CGRectGetMaxY(self.combineTitleLabel.frame)+5, CGRectGetWidth(self.combineTitleLabel.frame), FS6.lineHeight);
               [self.combineContentLabelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(idx < contetnArray.count)
                    {
                         obj.frame = contentLabelFrame;
                         obj.text = contetnArray[idx];
                         obj.hidden = NO;
                         contentLabelFrame.origin.y += FS6.lineHeight+5;
                    }
                    else
                         obj.hidden = YES;
               }];
          }
               break;
          default:
          {
               BOOL hasEffectiveDuration = false;
               BOOL hasAppShareLabel = false;
               if (self.dataInternal.record.msgType == MessageTypeText)
               {
                    MessageShareTextOrImageDataModel *paramObject = self.dataInternal.record.param.paramObject;
                    if (paramObject.effectiveDuration > 0)
                    {
                         hasEffectiveDuration = true;
                    }
                    if (paramObject.appName.length > 0)
                    {
                         hasAppShareLabel = true;
                    }
               }
               
               NSString *msgContent = @"";
               if([[KDChatReplyManager sharedInstance] isReplyMsg:record])
                    msgContent = [[KDChatReplyManager sharedInstance] replyBottomContent:record];
               else
                    msgContent = record.content;
               
               float bubbleWidth = self.dataInternal.bubbleLabelSize.width + 4;
               float bubbleHeight = self.dataInternal.bubbleLabelSize.height;
               float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 3.0 : self.headerView.frame.origin.x - bubbleWidth - 3.0;
               float bubbleY = startY;
               self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
               self.bubbleImage.image = [XTImageUtil chatDialogBackgroundImageWithDirection:direction state:UIControlStateNormal];
               
               self.textContentLabel.font = hasEffectiveDuration ? FS2 : FS2;
               self.textContentLabel.textColor =  self.dataInternal.record.msgDirection == MessageDirectionLeft ? [UIColor blackColor] : [UIColor whiteColor];
               self.textContentLabel.textAlignment = NSTextAlignmentLeft;
               self.textContentLabel.highlightText = self.highlightText;
               self.textContentLabel.text = msgContent;
               self.textContentLabel.backgroundColor = [UIColor clearColor];
               self.textContentLabel.frame = self.dataInternal.contentLabelFrame;
               
               //回复消息
               if ([[KDChatReplyManager sharedInstance] isReplyMsg:self.dataInternal.record]) {
                    self.replyContentLabel.hidden = NO;
                    self.replyContentLabel.font = FS7;
                    self.replyContentLabel.textColor = self.dataInternal.record.msgDirection == MessageDirectionLeft ? [[KDChatReplyManager sharedInstance] replyTextColorLeft] : [[KDChatReplyManager sharedInstance] replyTextColorRight];
                    self.replyContentLabel.textAlignment = NSTextAlignmentLeft;
                    self.replyContentLabel.highlightText = self.highlightText;
                    NSString *replyContent = [[KDChatReplyManager sharedInstance] replyContent:record];
                    
                    if (replyContent.length > 0) {
                         self.replyContentLabel.text = [replyContent stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                         self.replyContentLabel.contentView.layoutFrame.numberOfLines = 2;
                         self.replyContentLabel.contentView.layoutFrame.lineBreakMode = NSLineBreakByTruncatingTail;
                         [self.replyContentLabel.contentView relayoutText];
                    }
                    
                    self.replyContentLabel.backgroundColor = [UIColor clearColor];
                    self.replyContentLabel.frame = self.dataInternal.replyContentLabelFrame;
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewOriginalMsg)];
                    [self.replyContentLabel addGestureRecognizer:tapGesture];
                    
                    self.viewOriginalButton.hidden = NO;
                    self.viewOriginalButton.frame = self.dataInternal.viewOrgBtnFrame;
                    UIImage *originalBtnImage = self.dataInternal.record.msgDirection == MessageDirectionLeft ? [UIImage imageNamed:@"message_left_original"] :[UIImage imageNamed:@"message_rigiht_original"];
                    [self.viewOriginalButton setImage:originalBtnImage forState:UIControlStateNormal];
                    [self.viewOriginalButton addTarget:self action:@selector(viewOriginalMsg) forControlEvents:UIControlEventTouchUpInside];
                    
                    self.replyLine.hidden = NO;
                    self.replyLine.frame = self.dataInternal.replyLineFrame;
                    self.replyLine.backgroundColor = self.dataInternal.record.msgDirection == MessageDirectionLeft ? [[KDChatReplyManager  sharedInstance] lineColorLeft] : [[KDChatReplyManager sharedInstance] lineColorRight];
               } else {
                    self.replyContentLabel.hidden = YES;
                    self.replyLine.hidden = YES;
               }
               
               
               
               
               if (hasEffectiveDuration) {
                    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textContentLabel.contentView.attributedString];
                    long number = 2;
                    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
                    [contentAttributedString addAttribute:(__bridge id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[contentAttributedString length])];
                    CFRelease(num);
                    self.textContentLabel.contentView.attributedString = contentAttributedString;
               }
               
               if (!self.shareSourceAppLabel.hidden) {
                    MessageShareTextOrImageDataModel *paramObject = record.param.paramObject;
                    self.shareSourceAppLabel.frame = CGRectMake(bubbleX, bubbleY+bubbleHeight+5.0, bubbleWidth, 10.0);
                    self.shareSourceAppLabel.text = [NSString stringWithFormat:ASLocalizedString(@"BubbleTableViewCell_Tip_3"),paramObject.appName];
                    self.shareSourceAppLabel.textAlignment = direction == MessageDirectionLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
               }
               
               if (!self.roundProgressView.hidden)
               {
                    if (direction == MessageDirectionLeft)
                    {
                         self.roundProgressView.center = CGPointMake(self.bubbleImage.frame.origin.x + self.bubbleImage.frame.size.width + self.roundProgressView.frame.size.width/2 + 8.0, self.bubbleImage.center.y);
                    }
                    else {
                         self.roundProgressView.center = CGPointMake(self.bubbleImage.frame.origin.x - self.roundProgressView.frame.size.width/2 -  8.0, self.bubbleImage.center.y);
                    }
                    MessageShareTextOrImageDataModel *paramObject = record.param.paramObject;
                    self.roundProgressView.progressStartTime = paramObject.clientTime;
                    self.roundProgressView.effectiveDuration = paramObject.effectiveDuration;
                    self.roundProgressView.delegate = self.bubbleImage;
                    self.roundProgressView.groupId = _chatViewController.group.groupId;
                    self.roundProgressView.personPublicId = _chatViewController.pubAccount.publicId;
                    self.roundProgressView.msgId = record.msgId;
                    [self.roundProgressView startTimer];
               }
               else
               {
                    self.roundProgressView.delegate = nil;
               }
               
          }
               break;
     }
     
     //播放动画的图片
     if (type == MessageTypeSpeech) {
          self.voiceView.hidden = NO;
          self.voiceView.messageDirection = direction;
          if (direction == MessageDirectionLeft)
          {
               [self.voiceView setFrame:CGRectMake(12.0, (self.bubbleImage.bounds.size.height - self.voiceView.bounds.size.height)/2, self.voiceView.bounds.size.width, self.voiceView.bounds.size.height)];
          }else{
               [self.voiceView setFrame:CGRectMake(self.bubbleImage.bounds.size.width - 12.0 - self.voiceView.bounds.size.width, (self.bubbleImage.bounds.size.height - self.voiceView.bounds.size.height)/2, self.voiceView.bounds.size.width, self.voiceView.bounds.size.height)];
          }
     }else{
          self.voiceView.hidden = YES;
     }
     
     //未读标识
     if (type == MessageTypeSpeech)
     {
          if (direction == MessageDirectionLeft)
          {
               self.redDotImageView.frame = CGRectMake(self.bubbleImage.frame.origin.x + self.bubbleImage.frame.size.width + 8.0, startY + Height(self.bubbleImage.frame)/2.0-Height(self.redDotImageView.frame)/2.0, self.redDotImageView.frame.size.width, self.redDotImageView.frame.size.height);
          }
          else
          {
               self.redDotImageView.frame = CGRectMake(self.bubbleImage.frame.origin.x - self.redDotImageView.frame.size.width - 8.0, startY+ Height(self.bubbleImage.frame)/2.0-Height(self.redDotImageView.frame)/2.0, self.redDotImageView.frame.size.width, self.redDotImageView.frame.size.height);
          }
          if (self.dataInternal.record.status == MessageStatusUnread)
          {
               self.redDotImageView.hidden = NO;
          }
          else
          {
               self.redDotImageView.hidden = YES;
          }
     }
     else
     {
          self.redDotImageView.hidden = YES;
     }
     
     //发送、风火轮
     if (direction == MessageDirectionLeft)
     {
          self.sendFailueButton.center = CGPointMake(self.bubbleImage.frame.origin.x + self.bubbleImage.frame.size.width + self.sendFailueButton.frame.size.width/2 + 8.0, self.bubbleImage.center.y);
          self.activityIndicatorView.center = CGPointMake(self.bubbleImage.frame.origin.x + self.bubbleImage.frame.size.width + self.activityIndicatorView.frame.size.width/2 + 8.0, self.bubbleImage.center.y);
     }
     else {
          
          self.sendFailueButton.center = CGPointMake(self.bubbleImage.frame.origin.x - self.sendFailueButton.frame.size.width/2 -  8.0, self.bubbleImage.center.y);
          
          self.activityIndicatorView.center = CGPointMake(self.bubbleImage.frame.origin.x - self.activityIndicatorView.frame.size.width/2 - 8.0, self.bubbleImage.center.y);
     }
     
     if (record.msgRequestState == MessageRequestStateSuccess) {
          self.activityIndicatorView.hidden = YES;
          [self.activityIndicatorView stopAnimating];
     }else if (record.msgRequestState == MessageRequestStateFailue){
          self.activityIndicatorView.hidden = YES;
          [self.activityIndicatorView stopAnimating];
     }
     else{
          self.activityIndicatorView.hidden = NO;
          [self.activityIndicatorView startAnimating];
     }
     
     
     if (record.msgRequestState == MessageRequestStateFailue || record.msgPlayType == MessagePlayTypeFailue) {
          self.sendFailueButton.hidden = NO;
     }
     else {
          self.sendFailueButton.hidden = YES;
     }
     
     if (self.dataInternal.record.msgUnreadCount > 0 && (self.dataInternal.record.msgType == MessageTypeText || self.dataInternal.record.msgType == MessageTypeShareNews || self.dataInternal.record.msgType == MessageTypePicture || self.dataInternal.record.msgType == MessageTypeFile || self.dataInternal.record.msgType == MessageTypeSpeech || self.dataInternal.record.msgType == MessageTypeLocation || self.dataInternal.record.msgType == MessageTypeShortVideo || self.dataInternal.record.msgType == MessageTypeNotrace || self.dataInternal.record.msgType == MessageTypeCombineForward))
     {
          
          float unreadX = 0.0;
          float unreadY = self.bubbleImage.center.y - self.unreadBackgroudView.frame.size.height/2;
          if (direction == MessageDirectionRight)
          {
               unreadX = self.bubbleImage.frame.origin.x - self.unreadCountLabel.frame.size.width;
          }
          else
          {
               unreadX = CGRectGetMaxX(self.bubbleImage.frame) + 5;
          }
          
          CGRect unreadBackgroupdViewFrame = CGRectMake(unreadX, unreadY, 50, 40);
          if ([XTSetting sharedSetting].pressMsgUnreadTipsOrNot == NO)   //tips从来没有被点击过
          {
               if (self.dataInternal.group.groupType == GroupTypeDouble)   //双人组
               {
                    [self.bubbleBackgroupdImage setHidden:YES];
                    [self.unreadWordLabel setHidden:YES];
                    [self.unreadBackgroudView setHidden:NO];
                    [self.unreadBackgroudView setFrame:unreadBackgroupdViewFrame];
                    [self.unreadCountLabel setText:ASLocalizedString(@"BubbleTableViewCell_Tip_4")];
                    [self.unreadCountLabel setTextAlignment:NSTextAlignmentLeft];
                    [self.unreadBackgroudView addGestureRecognizer:self.unreadTap];
                    [self.unreadCountLabel setTextColor:FC5];
                    [self.unreadCountLabel setFont:FS8];
               }
               else if (self.dataInternal.group.groupType == GroupTypeMany)   //多人组
               {
                    [self.bubbleBackgroupdImage setHidden:NO];
                    [self.unreadWordLabel setHidden:NO];
                    [self.unreadBackgroudView setHidden:NO];
                    [self.unreadBackgroudView setFrame:unreadBackgroupdViewFrame];
                    [self.unreadCountLabel setText:[NSString stringWithFormat:ASLocalizedString(@"BubbleTableViewCell_Tip_5"), (long)self.dataInternal.record.msgUnreadCount]];
                    [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
                    [self.unreadBackgroudView addGestureRecognizer:self.unreadTap];
                    [self.unreadCountLabel setTextColor:FC5];
                    [self.unreadCountLabel setFont:FS8];
               }
          }
          else   //tips被点击过
          {
               if (self.dataInternal.group.groupType == GroupTypeDouble)   //双人组
               {
                    [self.bubbleBackgroupdImage setHidden:YES];
                    [self.unreadWordLabel setHidden:YES];
                    [self.unreadBackgroudView setHidden:NO];
                    [self.unreadBackgroudView setFrame:unreadBackgroupdViewFrame];
                    [self.unreadCountLabel setText:ASLocalizedString(@"BubbleTableViewCell_Tip_4")];
                    [self.unreadCountLabel setTextAlignment:NSTextAlignmentLeft];
                    [self.unreadBackgroudView addGestureRecognizer:self.unreadTap];
                    [self.unreadCountLabel setTextColor:FC5];
                    [self.unreadCountLabel setFont:FS8];
                    
               }
               else if (self.dataInternal.group.groupType == GroupTypeMany)   //多人组
               {
                    [self.bubbleBackgroupdImage setHidden:YES];
                    [self.unreadWordLabel setHidden:YES];
                    [self.unreadBackgroudView setHidden:NO];
                    [self.unreadBackgroudView setFrame:unreadBackgroupdViewFrame];
                    [self.unreadCountLabel setText:[NSString stringWithFormat:ASLocalizedString(@"BubbleTableViewCell_Tip_5"), (long)self.dataInternal.record.msgUnreadCount]];
                    [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
                    [self.unreadBackgroudView addGestureRecognizer:self.unreadTap];
                    [self.unreadCountLabel setTextColor:FC5];
                    [self.unreadCountLabel setFont:FS8];
                    
               }
          }
          [self.unreadBackgroudView setHidden:![self.dataInternal.group chatAvailable]];
          
     }
     else   //没有未读数不显示 不是文本消息等不显示
     {
          [self.unreadBackgroudView setHidden:YES];
     }
     
     if (direction == MessageDirectionLeft && self.labelName.hidden == NO)
     {
          self.departmentLabel.frame = CGRectMake(CGRectGetMaxX(self.labelName.frame) + 5, self.labelName.frame.origin.y, 200, self.labelName.frame.size.height);
     }
}


- (void)setupPictureWithY:(CGFloat)startY
{
     RecordDataModel *record = self.dataInternal.record;
     MessageDirection direction = record.msgDirection;
     
     //    float startY = self.dataInternal.header ? 46 : 10;
     
     if (!isAboveiOS8) {
          self.dataInternal.bubbleLabelSize = CGSizeMake(87.0, 80.0);
          self.dataInternal.cellHeight = self.dataInternal.bubbleLabelSize.height > self.headerView.frame.size.height ? self.dataInternal.bubbleLabelSize.height + 15.0 : self.headerView.frame.size.height + 15.0;
     }
     
     
     UIImage *maskImage = [[UIImage imageNamed:(direction == MessageDirectionLeft?@"left1":@"right1")] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];;
     self.maskImageView.image = maskImage;
     self.maskImageView.hidden = NO;
     
     
     float bubbleWidth = self.dataInternal.bubbleLabelSize.width;
     float bubbleHeight = self.dataInternal.bubbleLabelSize.height;
     float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 5.0 : self.headerView.frame.origin.x - bubbleWidth - 5.0;
     float bubbleY = startY;
     self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
     self.bubbleImage.image = nil;
     self.thumbnailImageView.frame = CGRectMake(direction == MessageDirectionLeft ? 0 :0, 0, self.dataInternal.bubbleLabelSize.width , self.dataInternal.bubbleLabelSize.height);
     self.maskImageView.frame = self.thumbnailImageView.frame;
     
     
     if (!self.shareSourceAppLabel.hidden) {
          MessageShareTextOrImageDataModel *paramObject = record.param.paramObject;
          self.shareSourceAppLabel.text = [NSString stringWithFormat:ASLocalizedString(@"BubbleTableViewCell_Tip_3"),paramObject.appName];
          self.shareSourceAppLabel.frame = CGRectMake(bubbleX, bubbleY+bubbleHeight+5.0, bubbleWidth, 10.0);
          self.shareSourceAppLabel.textAlignment = direction == MessageDirectionLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
     }
     
     __weak BubbleTableViewCell *selfInBlock = self;
     BOOL bIsEmoji = NO;
     if (selfInBlock.dataInternal.record.strEmojiType) {
          bIsEmoji = [selfInBlock.dataInternal.record.strEmojiType isEqualToString:@"original"];
     }
     // 大表情根据file id查找本地
     //    NSURL *fileURL = nil;
     NSString *fileName;
     if([selfInBlock.dataInternal.record.param.paramObject isKindOfClass:[MessageFileDataModel class]] && bIsEmoji)
     {
          MessageFileDataModel *file = (MessageFileDataModel *)selfInBlock.dataInternal.record.param.paramObject;
          fileName = [KDExpressionManager fileNameOfFileId:file.file_id];
          //        fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
     }
     
     
     if (fileName)
     {
          //大图表情
          BOOL isAnimatedImage = YES;
          id image = [FLAnimatedImage animatedImageWithFileName:fileName];
          if(image == nil)
          {
               isAnimatedImage = NO;
               image = [UIImage imageNamed:fileName];
          }
          if (image)
          {
               CGSize contentLabelSize;
               if(isAnimatedImage)
                    contentLabelSize = ((FLAnimatedImage *)image).size;
               else
                    contentLabelSize = ((UIImage *)image).size;
               contentLabelSize.width = 110 * (contentLabelSize.width / contentLabelSize.height);
               
               float width = 60;
               
               if (contentLabelSize.width < width) {
                    contentLabelSize.width = width;
               }
               contentLabelSize.height = 110;
               selfInBlock.dataInternal.bubbleLabelSize = CGSizeMake(contentLabelSize.width, contentLabelSize.height);
               selfInBlock.thumbnailImageView.frame = CGRectMake(0, 0, self.dataInternal.bubbleLabelSize.width, self.dataInternal.bubbleLabelSize.height);
               selfInBlock.maskImageView.frame = self.thumbnailImageView.frame;
               
          }
          if(isAnimatedImage)
               selfInBlock.thumbnailImageView.animatedImage = image;
          else
               self.thumbnailImageView.image = image;
          selfInBlock.maskImageView.hidden = YES;
     }
     else
     {
          [self.thumbnailImageView setImageWithURL:[record thumbnailPictureUrl] placeholderImage:[UIImage imageNamed:@"message_img_picture"] completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType) {
               
               if (image) {
                    CGSize contentLabelSize = image.size;
                    contentLabelSize.width = 180 * (contentLabelSize.width / contentLabelSize.height);
                    float width = 80;
                    if (contentLabelSize.width < width) {
                         contentLabelSize.width = width;
                    }
                    
                    if (contentLabelSize.width > ScreenFullWidth-(12+44+5+5+3)*2) {
                         contentLabelSize.width = ScreenFullWidth-(12+44+5+5+3)*2;
                    }
                    contentLabelSize.height = 180;
                    selfInBlock.dataInternal.bubbleLabelSize = CGSizeMake(contentLabelSize.width , contentLabelSize.height);
                    
                    if (!isAboveiOS8) {
                         selfInBlock.dataInternal.cellHeight = selfInBlock.dataInternal.bubbleLabelSize.height > selfInBlock.headerView.frame.size.height ? selfInBlock.dataInternal.bubbleLabelSize.height + 15.0 : selfInBlock.headerView.frame.size.height + 15.0;
                    }
                    
                    
                    float bubbleWidth = selfInBlock.dataInternal.bubbleLabelSize.width;
                    float bubbleHeight = selfInBlock.dataInternal.bubbleLabelSize.height;
                    float bubbleX = direction == MessageDirectionLeft ? selfInBlock.headerView.frame.origin.x + selfInBlock.headerView.frame.size.width + 5.0 : selfInBlock.headerView.frame.origin.x - bubbleWidth - 5.0;
                    float bubbleY = startY;
                    selfInBlock.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
                    selfInBlock.thumbnailImageView.frame = CGRectMake(direction == MessageDirectionLeft ? 0 : 0, 0, selfInBlock.dataInternal.bubbleLabelSize.width, selfInBlock.dataInternal.bubbleLabelSize.height);
                    selfInBlock.maskImageView.frame = selfInBlock.thumbnailImageView.frame;
                    
                    if (!selfInBlock.shareSourceAppLabel.hidden) {
                         MessageShareTextOrImageDataModel *paramObject = record.param.paramObject;
                         selfInBlock.shareSourceAppLabel.text = [NSString stringWithFormat:ASLocalizedString(@"BubbleTableViewCell_Tip_3"), paramObject.appName];
                         selfInBlock.shareSourceAppLabel.frame = CGRectMake(bubbleX, bubbleY + bubbleHeight + 5.0, bubbleWidth, 10.0);
                         selfInBlock.shareSourceAppLabel.textAlignment = direction == MessageDirectionLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
                    }
                    
                    
                    if (bIsEmoji)
                    {
                         selfInBlock.maskImageView.hidden = YES;
                    }
                    
               }
               
          }];
     }
}

- (void)setupShortVideoPictureWithY:(CGFloat)startY
{
     RecordDataModel *record = self.dataInternal.record;
     MessageDirection direction = record.msgDirection;
     MessageTypeShortVideoDataModel *shortVideoInfo = (MessageTypeShortVideoDataModel *)record.param.paramObject;
     
     __weak BubbleTableViewCell *selfInBlock = self;
     
     NSString *path =[NSString stringWithFormat:@"%@/microblog/filesvr/%@",[[KDWeiboServicesContext defaultContext] serverBaseURL],shortVideoInfo.videoThumbnail];
     
     if (shortVideoInfo.file_id.length > 0) {
          
          [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"message_video_placeholder"] completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType) {
               if (image) {
                    [[SDImageCache sharedImageCache] removeImageForKey:record.msgId];
                    selfInBlock.thumbnailImageView.image  = image;
                    selfInBlock.shortVideoBtn.frame = CGRectMake(0, 0, 100, 100);
                    [selfInBlock.shortVideoBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                    selfInBlock.shortVideoBtn.center = selfInBlock.thumbnailImageView.center;
                    selfInBlock.shortVideoBtn.hidden = NO;
               }
          }];
     }else
     {
          UIImage *image = [[SDImageCache sharedImageCache]imageFromMemoryCacheForKey:record.msgId];
          if (image) {
               self.thumbnailImageView.image  = image;
               self.shortVideoBtn.frame = CGRectMake(0, 0, 100, 100);
               [self.shortVideoBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
               self.shortVideoBtn.center = selfInBlock.thumbnailImageView.center;
               self.shortVideoBtn.hidden = NO;
          }
     }
     
     float bubbleHeight = 180;
     float bubbleWidth = ScreenFullWidth / 3;
     //     float bubbleWidth = MAX(180 * (self.thumbnailImageView.image.size.width/self.thumbnailImageView.image.size.height),90);
     //     bubbleWidth = MIN(bubbleWidth, ScreenFullWidth - (10+44+3)*2);
     float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 5.0 : self.headerView.frame.origin.x - bubbleWidth - 5.0;
     float bubbleY = startY;
     self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
     self.thumbnailImageView.frame = CGRectMake(0 , 0, bubbleWidth,bubbleHeight);
     self.bubbleImage.image = [XTImageUtil chatPictureBackgroundImageWithDirection:direction state:UIControlStateNormal];
     
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadAndPlayVideo)];
     [self.thumbnailImageView addGestureRecognizer:tap];
     
     self.locationBgView.hidden = NO;
     self.locationBgView.frame = CGRectMake(0, bubbleHeight - 30 , bubbleWidth, 30);
     self.locationBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
     
     
     self.timeLabel.frame = CGRectMake(5, 0 , bubbleWidth / 2, 30);
     self.timeLabel.text  = [NSString stringWithFormat:@"0:%02ld",[shortVideoInfo.videoTimeLength integerValue]];
     self.sizeLabel.frame = CGRectMake(bubbleWidth / 2,0, bubbleWidth / 2 - 10, 30);
     self.sizeLabel.text =[self videoSize:shortVideoInfo.size];
     
     
}

- (void)loadAndPlayVideo
{
     NSLog(@"loadAndPlayVideo");
     
     MessageTypeShortVideoDataModel *paramObject = self.dataInternal.record.param.paramObject;
     
     FileModel *file = [[FileModel alloc]init];
     file.fileId = paramObject.file_id;
     file.ext = paramObject.ext;
     
     
     if (paramObject.videoUrl.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:paramObject.videoUrl]) {
          [self.chatViewController playVideo:paramObject.videoUrl];
     }else
     {
          //如果存在  则直接播放 否则请求服务器
          NSString *path = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", file.fileId,file.ext];
          if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
               [self.chatViewController playVideo:path];
          }else
          {
               self.shortVideoBtn.hidden = YES;
               self.hud = [[MBProgressHUD alloc]initWithView:self.thumbnailImageView];
               self.hud.color = [UIColor clearColor];
               self.hud.mode = MBProgressHUDModeDeterminate;
               [self.hud show:YES];
               [self.thumbnailImageView addSubview:self.hud];
               
               [[KDMediaMessageHandler sharedHandler] setProgressDelegate:self];
               [[KDMediaMessageHandler sharedHandler] downLoadFileByFile:file finishBlock:^(NSString *downLoadUrl, BOOL success) {
                    if (success) {
                         [self.hud hide:YES];
                         self.shortVideoBtn.hidden = NO;
                         //                         [self.chatViewController playVideo:downLoadUrl];
                    } else {
                         //                         [self.hud hide:YES];
                         
                    }
               }];
          }
          
     }
}

- (void)setProgress:(float)progress{
     
     NSLog(@"#####################_______________%f___________",progress);
     self.hud.progress = progress;
}
- (void)setupLocationPictureWithY:(CGFloat)startY
{
     RecordDataModel *record = self.dataInternal.record;
     MessageDirection direction = record.msgDirection;
     MessageTypeLocationDataModel *locationInfo = (MessageTypeLocationDataModel *)record.param.paramObject;
     
     
     UIImage *maskImage = [[UIImage imageNamed:(direction == MessageDirectionLeft?@"left1":@"right1")] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];;
     self.maskImageView.image = maskImage;
     self.maskImageView.hidden = NO;
     
     
     float bubbleWidth = 220 - 5;
     float bubbleHeight = 120;
     float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 5.0 : self.headerView.frame.origin.x - bubbleWidth;
     float bubbleY = startY;
     self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
     self.thumbnailImageView.frame = CGRectMake(direction == MessageDirectionLeft ? 5:1 , 1, bubbleWidth -6,bubbleHeight - 2 );
     self.maskImageView.frame = self.thumbnailImageView.frame;
     self.locationBgView.hidden = NO;
     self.locationBgView.frame = CGRectMake(direction == MessageDirectionLeft ? 7:2, bubbleHeight - 31 , bubbleWidth - 8, 30);
     self.locationBgView.image = [UIImage imageNamed:@"locationBg"];
     self.locationInfo.frame = CGRectMake(15, 0 , bubbleWidth - 32, 30);
     self.locationInfo.text = locationInfo.address;
     self.bubbleImage.image = nil;
     [self.bubbleImage bringSubviewToFront:self.maskImageView];
     
     __weak BubbleTableViewCell *selfInBlock = self;
     [self.thumbnailImageView setImageWithURL:[record thumbnailPictureUrl] placeholderImage:[UIImage imageNamed:@"message_img_picture"] completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType) {
          if (image) {
               selfInBlock.locationInfo.hidden = NO;
          }
     }];
}


- (void)setupFileDataWithY:(CGFloat)startY
{
     RecordDataModel *record = self.dataInternal.record;
     MessageDirection direction = record.msgDirection;
     MessageFileDataModel *file = (MessageFileDataModel *)record.param.paramObject;
     
     if([XTFileUtils isPhotoExt:file.ext])
     {
          [self setupPictureWithY:startY];
          return;
     }
     
     //默认部分
     //    float startY = self.dataInternal.header ? 46 : 10;
     self.bubbleImage.image = [XTImageUtil chatPictureBackgroundImageWithDirection:direction state:UIControlStateNormal];
     //背景按钮
     self.fileButton.frame = CGRectMake(0.0, 0.0, self.bubbleImage.frame.size.width, self.bubbleImage.frame.size.height);
     
     float bubbleWidth = self.dataInternal.bubbleLabelSize.width;
     float bubbleHeight = self.dataInternal.bubbleLabelSize.height;
     float bubbleX = direction == MessageDirectionLeft ? self.headerView.frame.origin.x + self.headerView.frame.size.width + 3.0 : self.headerView.frame.origin.x - bubbleWidth - 3.0;
     float bubbleY = startY;
     self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
     self.fileBackgroundView.frame = CGRectMake(2.0, 2.0, bubbleWidth-10.0, bubbleHeight-4.0);
     
     self.contentLabel.hidden = YES;
     self.textContentLabel.hidden = YES;//NO;
     //     self.textContentLabel.font = FS4;
     //     self.textContentLabel.backgroundColor = [UIColor clearColor];
     //     self.textContentLabel.textAlignment = NSTextAlignmentLeft;
     //     self.textContentLabel.textColor = FC1;
     //     self.textContentLabel.text = file.name;
     //     self.textContentLabel.contentView.layoutFrame.numberOfLines = 4;
     //     self.textContentLabel.contentView.layoutFrame.lineBreakMode = NSLineBreakByTruncatingTail;
     //     [self.textContentLabel.contentView relayoutText];
     //     [self.textContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
     //          make.left.equalTo(self.textContentLabel.superview.left).offset(12);
     //          make.right.equalTo(self.thumbnailImageView.left).offset(-12);
     //          make.top.equalTo(self.textContentLabel.superview.top).offset(12);
     //          make.width.mas_equalTo(KDChatConstants.bubbleContentLabelMaxWidth - 12 - 55);
     //     }];
     
     
     self.fileTitleLabel.text = file.name;
     [self.fileTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.fileTitleLabel.superview.left).offset(12);
          make.right.equalTo(self.thumbnailImageView.left).offset(-12);
          make.top.equalTo(self.fileTitleLabel.superview.top).offset(12);
          make.width.mas_equalTo(KDChatConstants.bubbleContentLabelMaxWidth - 12 - 55);
     }];
     
     
     //预览图
     [self.thumbnailImageView setImageWithURL:nil placeholderImage:[UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:file.ext]]];
     [self.thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.width.mas_equalTo(55);
          make.height.mas_equalTo(55);
          make.top.equalTo(self.thumbnailImageView.superview.top).offset(12);
          make.bottom.lessThanOrEqualTo(self.thumbnailImageView.superview.bottom).offset(-12);
          make.right.equalTo(self.thumbnailImageView.superview.right).offset(-12);
     }];
     
     //文件大小
     self.fileSize.textColor = FC2;
     NSString *size = [XTFileUtils fileSize:file.size];
     self.fileSize.text = size;
     self.fileSize.font = FS6;
     [self.fileSize mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.fileTitleLabel.bottom).offset(8);
          make.left.equalTo(self.fileSize.superview.left).offset(12);
          make.right.equalTo(self.thumbnailImageView.left).offset(-12);
          make.bottom.equalTo(self.fileSize.superview.bottom).offset(-12);
     }];
     
     [self.fileSize setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
     
     if (!self.shareSourceAppLabel.hidden) {
          self.shareSourceAppLabel.frame = CGRectMake(bubbleX, bubbleY+bubbleHeight+5.0, bubbleWidth, 10.0);
          self.shareSourceAppLabel.text = file.appName;
          self.shareSourceAppLabel.textAlignment = direction == MessageDirectionLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
     }
}

#pragma mark - btn action
- (void)eventClick:(UIButton*)btn{
     MessageNewsDataModel *paramObject = self.dataInternal.record.param.paramObject;
     MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
     if ([news.buttons count] > btn.tag) {
          MessageTypeNewsEventsModel *model = [news.buttons objectAtIndex:btn.tag];
          [self.chatViewController handleEventModel:model];
     }
}
-(void)newsclick:(UIButton*)btn
{
     MessageNewsDataModel *paramObject = self.dataInternal.record.param.paramObject;
     MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:btn.tag];
     self.rowIndex = btn.tag;
     NSString *finalyURL = @"";
     if (news.url.length > 0) {
          if ([news.url rangeOfString:@"?"].location != NSNotFound) {
               finalyURL = [NSString stringWithFormat:@"%@&msgRow=%@&msgId=%@",news.url, news.row, self.dataInternal.record.msgId];
          } else {
               finalyURL = [NSString stringWithFormat:@"%@?msgRow=%@&msgId=%@",news.url, news.row, self.dataInternal.record.msgId];
          }
     }
     [self openWithUrl:finalyURL appId:news.appId title:self.chatViewController.group.groupName share:news];
}


- (void)openWithUrl:(NSString *)url appId:(NSString *)appId title:(NSString *)title share:(MessageNewsEachDataModel *)share
{
     if (url.length > 0) {
          KDSchemeHostType t;
          NSDictionary *dic = [url schemeInfoWithType:&t shouldDecoded:NO];
          if (t == KDSchemeHostType_Todo) {
               NSString *taskId = [dic stringForKey:@"id"];
               KDTaskDiscussViewController *ctr = [[KDTaskDiscussViewController alloc] initWithTaskId:taskId];
               [self.chatViewController.navigationController pushViewController:ctr animated:YES];
          }
          else if (t == KDSchemeHostType_Todolist) {
               KDTodoListViewController *ctr = [[KDTodoListViewController alloc] initWithTodoType:kTodoTypeUndo];
               [self.chatViewController.navigationController pushViewController:ctr animated:YES];
          }
          else if (t == KDSchemeHostType_Chat) {
               if ([dic objectNotNSNullForKey:@"groupId"] && [dic objectNotNSNullForKey:@"msgId"])
               {
                    GroupDataModel *gdm = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:[dic objectNotNSNullForKey:@"groupId"]];
                    if (gdm) {
                         XTChatViewController *chatViewController = [[XTChatViewController alloc] initWithGroup:gdm pubAccount:nil mode:ChatPrivateMode];
                         chatViewController.hidesBottomBarWhenPushed = YES;
                         chatViewController.strScrollToMsgId = [dic objectNotNSNullForKey:@"msgId"];
                         [self.chatViewController.navigationController pushViewController:chatViewController animated:YES];
                    }
               }
          }
          else if (t == KDSchemeHostType_PersonalSetting) {
               KDAvatarSettingViewController *as = [[KDAvatarSettingViewController alloc] initWithNibName:nil bundle:nil];
               [self.chatViewController.navigationController pushViewController:as animated:YES];
               [BOSSetting sharedSetting].showAvatarFlag = 1;
               [[BOSSetting sharedSetting] saveSetting];
          }
          else if(t == KDSchemeHostType_Status) {
               if ([BOSConfig sharedConfig].user.partnerType == 1) {
                    [KDPopup showHUDToast:ASLocalizedString(@"NO_Privilege")];
                    return;
               }
               NSString *statusId = [dic objectForKey:@"id"];
               if(![statusId isKindOfClass:[NSNull class]] && statusId.length > 0) {
                    KDStatusDetailViewController *sdvc = [[KDStatusDetailViewController alloc] initWithStatusID:statusId];
                    [self.chatViewController.navigationController pushViewController:sdvc animated:YES];
               }
          }
          else if (t == KDSchemeHostType_HTTP || t == KDSchemeHostType_HTTPS || t == KDSchemeHostType_NOTURI) {
               //可能是轻应用
               [self openLightAppWithUrl:url appId:appId title:title share:share];
          }
          else if (t == KDSchemeHostType_Unknow) {
               NSURL *realUrl = [NSURL URLWithString:url];
               if (!isAboveiOS9) {
                    if ([[UIApplication sharedApplication] canOpenURL:realUrl]) {
                         [[UIApplication sharedApplication] openURL:realUrl];
                    }
               }else
               {
                    [[UIApplication sharedApplication] openURL:realUrl];
               }
               
          }
     }
     else {
          //可能是轻应用
          [self openLightAppWithUrl:@"" appId:appId title:title share:share];
     }
}

- (void)openLightAppWithUrl:(NSString *)url appId:(NSString *)appId title:(NSString *)title share:(MessageNewsEachDataModel *)share
{
     if (url.length == 0 && appId.length == 0) {
          return;
     }
     
     KDWebViewController *webVC = nil;
     if (appId.length > 0) {
          webVC = [[KDWebViewController alloc] initWithUrlString:url appId:appId];
     }
     else {
          if (self.chatViewController.ispublic && [self.chatViewController.group.participant count] == 1) {
               PersonSimpleDataModel *person = [self.chatViewController.group.participant firstObject];
               webVC = [[KDWebViewController alloc] initWithUrlString:url pubAccId:person.personId menuId:@"pubmessagelink"];
          }else{
               webVC = [[KDWebViewController alloc] initWithUrlString:url];
          }
     }
     
     if (webVC) {
          GroupDataModel *group = self.chatViewController.group;
          PersonSimpleDataModel *person = [group.participant firstObject];
          if ([group allowInnerShare] || [group allowOuterShare]) {
               webVC.personDataModel = person;
               //传入数据，用于分享
               if (share == nil && self.dataInternal.record.msgType == MessageTypeAttach) {
                    RecordDataModel *record = self.dataInternal.record;
                    MessageAttachDataModel *paramObject = record.param.paramObject;
                    MessageAttachEachDataModel * attach = [paramObject.attach firstObject];
                    
                    NSDictionary *dic = @{@"date" : record.sendTime,
                                          @"text" : record.content,
                                          @"title" :attach.name,
                                          @"url" : attach.value,
                                          @"appid" : person.personId};
                    share = [[MessageNewsEachDataModel alloc] initWithDictionary:dic];
               }
               else if(share == nil && self.dataInternal.record.msgType == MessageTypeShareNews)
               {
                    RecordDataModel *record = self.dataInternal.record;
                    MessageShareNewsDataModel *paramObject = record.param.paramObject;
                    
                    NSDictionary *dic = @{@"date" : record.sendTime,
                                          @"text" : paramObject.content,
                                          @"title" :paramObject.title,
                                          @"url" : paramObject.webpageUrl,
                                          @"name" : paramObject.thumbUrl,
                                          @"appid" : paramObject.appId};
                    share = [[MessageNewsEachDataModel alloc] initWithDictionary:dic];
                    
                    //需要设置来自appname
                    webVC.fromAppName = paramObject.appName;
               }
               webVC.shareNewsDataModel = share;
          }
          webVC.title = title;
          webVC.hidesBottomBarWhenPushed = YES;
          
          
          if (appId.length > 0)
          {
               __weak __typeof(webVC) weak_webvc = webVC;
               __weak __typeof(self) weak_controller = self;
               webVC.getLightAppBlock = ^() {
                    if(weak_webvc && !weak_webvc.bPushed){
                         [weak_controller.chatViewController.navigationController pushViewController:weak_webvc animated:YES];
                    }
               };
          }
          else
          {
               [self.chatViewController.navigationController pushViewController:webVC animated:YES];
          }
     }
     
     if([self.dataInternal.group isPublicGroup])
     {
          if(self.dataInternal.group.participant.firstObject)
          {
               //打开公共号消息统计埋点
               PersonSimpleDataModel *person = self.dataInternal.group.participant.firstObject;
               KDQuery *query = [KDQuery query];
               [query setParameter:@"pub_id" stringValue:person.personId];
               [query setParameter:@"msg_id" stringValue:self.dataInternal.record.msgId];
               [query setParameter:@"msg_row" stringValue:[NSString stringWithFormat:@"%ld",self.rowIndex]];
               [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/event/:msgRead" query:query
                                            configBlock:nil completionBlock:^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
                                                 if(results)
                                                 {
                                                 }
                                            }];
          }
     }
}

//
-(void)fileButtonClick:(id)sender
{
     MessageFileDataModel *file = (MessageFileDataModel *)self.dataInternal.record.param.paramObject;
     NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:file.file_id,@"id", file.name,@"fileName", file.uploadDate,@"uploadDate", file.ext,@"fileExt", file.size, @"length",nil];
     FileModel *fileModel = [[FileModel alloc] initWithDictionary:dict];
     XTFileDetailViewController *filePreviewVC = [[XTFileDetailViewController alloc] initWithFile:fileModel];
     PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:self.dataInternal.record.fromUserId];
     filePreviewVC.fileDetailFunctionType = XTFileDetailFunctionType_count;
     filePreviewVC.threadId = self.chatViewController.group.groupId;
     filePreviewVC.dedicatorId = person.wbUserId;
     filePreviewVC.dedicator = person;
     filePreviewVC.pubAccId = (self.chatViewController.pubAccount?self.chatViewController.pubAccount.publicId:((PersonSimpleDataModel *)(self.chatViewController.group.participant.firstObject)).personId);
     filePreviewVC.bShouldNotPopToRootVC = YES;
     filePreviewVC.hidesBottomBarWhenPushed = YES;
     [self.chatViewController.navigationController pushViewController:filePreviewVC animated:YES];
}

//语音:点击播放
-(void)bubbleBtnTapPressed:(UITapGestureRecognizer *)gestureRecognizer
{
     //高亮
     [_bubbleImage setHighlighted:YES];
     [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(cancelBubbleImageHighlighted) userInfo:nil repeats:NO];
     
     //发送中或者接收中，不可点
     if (self.dataInternal.record.msgRequestState == MessageRequestStateRequesting || [self.dataInternal.record.strEmojiType isEqualToString:@"original"]) {
          return;
     }
     
     //服务器数据
     if (self.dataInternal.record.msgType == MessageTypeSpeech) {
          //当前是未读，下面立即进行播放，所以，我们认为当前是第一次尝试播放
          _isSpeechFirstRead = (self.dataInternal.record.status == MessageStatusUnread);
          NSString *filePath = [self.dataInternal.record xtFilePath];
          if (filePath != nil) {//存在文件，播放
               [self play:filePath];
          }else{
               //不存在文件，去请求
               self.dataInternal.record.msgRequestState = MessageRequestStateRequesting;
               [self setupInternalData];
               [self getContent];
          }
     }
     else if (self.dataInternal.record.msgType == MessageTypeShareNews)
     {
          MessageShareNewsDataModel *paramObject = self.dataInternal.record.param.paramObject;
          NSString *title = nil;
          if (paramObject.title.length == 0 || [paramObject.title isEqualToString:paramObject.content]) {
               title = paramObject.content;
          }
          else{
               title = paramObject.title;
          }
          [self openWithUrl:paramObject.webpageUrl appId:paramObject.lightAppId.length>0?paramObject.lightAppId:paramObject.appId title:title share:nil];
     }
     else if (self.dataInternal.record.msgType == MessageTypePicture) {
          [self openImageView];
     }
     else if (self.dataInternal.record.msgType == MessageTypeFile) {
          MessageFileDataModel *file = (MessageFileDataModel *)self.dataInternal.record.param.paramObject;
          if ([XTFileUtils isPhotoExt:file.ext]) {
               [self openImageView];
          }
     }else if(self.dataInternal.record.msgType == MessageTypeLocation)
     {
          [self openMapViewWithData:self.dataInternal.record.param.paramObject];
     }
     else if(self.dataInternal.record.msgType == MessageTypeCombineForward)
     {
          KDChatCombineDetailVC *detailVC = [[KDChatCombineDetailVC alloc] init];
          detailVC.record = _dataInternal.record;
          detailVC.dataSource = self;
          [self.chatViewController.navigationController pushViewController:detailVC animated:YES];
     }
     else if (self.dataInternal.record.msgType == MessageTypeText) {
          [self clickTextMessage];
     }
     
}
- (void)clickTextMessage {
     
}

- (void)openImageView
{
     NSString *index = nil;
     NSArray *messages = _chatViewController.recordsList;//[[XTDataBaseDao sharedDatabaseDaoInstance] queryAllPicturesWithGroupId:self.dataInternal.group.groupId toUserId:@"" msgId:self.dataInternal.record.msgId sendTime:self.dataInternal.record.sendTime index:&index];
     
     NSMutableArray *photos = [NSMutableArray array];
     
     for (int i = 0; i < messages.count; i++)
     {
          RecordDataModel *message = [messages objectAtIndex:i];
          
          if(message.msgType == MessageTypeFile)
          {
               if(![XTFileUtils isPhotoExt:((MessageFileDataModel *)message.param.paramObject).ext])
                    continue;
               if([message.strEmojiType isEqualToString:@"original"])
                    continue;
          }
          else if(message.msgType != MessageTypePicture )
               continue;
          
          MJPhoto *photo = [[MJPhoto alloc] init];
          //保存该尺寸用于显示原图的缩略图 by lee
          photo.midPictureUrl = [message midPictureUrl];
          photo.url = ([message.isOriginalPic boolValue]?[message bigPictureUrl]:[message originalPictureUrl]);
          photo.originUrl = [message originalPictureUrl];
          
#pragma mark modified by Darren in 2014.6.12
          photo.thumbnailPictureUrl = [message thumbnailPictureUrl];
          photo.photoLength = [self transformedValue:message.msgLen];
          photo.direction = message.msgDirection;
          photo.isOriginalPic = message.isOriginalPic;
          photo.tempData = message;
          
          [photos addObject:photo];
          
          if([message.msgId isEqualToString:self.dataInternal.record.msgId])
               index = [NSString stringWithFormat:@"%zi",photos.count-1];
     }
     
     if ([photos count] > 0 && [index intValue] < [photos count]) {
          MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
          browser.delegate = self;
          browser.photos = photos;
          
          
          {
               //转发
               BOOL canForward = YES;
               if (self.dataInternal.record.msgType == MessageTypeNews) {
                    MessageNewsDataModel *paramObject = self.dataInternal.record.param.paramObject;
                    // 如果是代办 则只能删除
                    if(paramObject.model==1 && paramObject.todoNotify)
                         canForward = NO;
               }
               
               /**
                *  判断公共号的内容是不是可以分享
                */
               if(self.chatViewController.pubAccount)
               {
                    GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupWithPublicPersonId:self.chatViewController.pubAccount.publicId];
                    browser.bCanTransmit = [group allowInnerShare];
               }
               else
                    browser.bCanTransmit = [self.chatViewController.group allowInnerShare];
          }
          
          //         {
          //              // 收藏
          //              BOOL canCollect = NO;
          //              if (![self.dataInternal.record.strEmojiType isEqualToString:@"original"]) {
          //                   if([self.bubbleImage canPerformAction:@selector(collect:) withSender:self.bubbleImage])
          //                   {
          //                        if (self.dataInternal.record.msgType == MessageTypePicture)
          //                        {
          //                             MessageShareTextOrImageDataModel *paramObject = self.dataInternal.record.param.paramObject;
          //                             if(paramObject.fileId.length>0)
          //                                  canCollect = YES;
          //                        }
          //                   }
          //              }
          browser.bCanCollect = YES;//canCollect;
          //         }
          
          browser.bCanEdit = YES;
          browser.currentPhotoIndex = [index intValue];
          
          if ([self.dataInternal.group isPublicGroup]) {
               PersonSimpleDataModel *pubPerson = [self.dataInternal.group firstParticipant];
               if (!pubPerson.share) {
                    browser.bHideSavePhotoBtn = YES;
               }
          }
          [browser show];
          
          _chatViewController.browser = browser;
          
          //点开大图，如果存在键盘，则收起
          if (self.chatViewController) {
               [self.chatViewController scrollViewWillBeginDragging:self.chatViewController.bubbleTable];
          }
     }
}


//识别二维码
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser scanWithresult:(NSString *)result
{
     [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
          
          [photoBrowser hide];
          [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:_chatViewController withQRResult:qrResult andQRCode:qrCode];
          
     }];
}


//收藏
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser collectWithPhoto:(MJPhoto *)photo
{
     RecordDataModel *record = (RecordDataModel *)(photo.tempData);
     id obj = record.param.paramObject;
     if([obj isKindOfClass:[MessageFileDataModel class]])
     {
          MessageFileDataModel *file = (MessageFileDataModel *)obj;
          self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
          [self.client stowFile:file.file_id networkId:[BOSConfig sharedConfig].user.eid];
     }
     else if([obj isKindOfClass:[MessageShareTextOrImageDataModel class]])
     {
          MessageShareTextOrImageDataModel *picture = (MessageShareTextOrImageDataModel *)obj;
          self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
          [self.client stowFile:picture.fileId networkId:[BOSConfig sharedConfig].user.eid];
     }
     else if ([obj isKindOfClass:[MessageTypeShortVideoDataModel class]]) {
          MessageTypeShortVideoDataModel *shortVideo = obj;
          self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
          [self.client stowFile:shortVideo.file_id networkId:[BOSConfig sharedConfig].user.eid];
     }
}

//转发图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser transmitWithPhoto:(MJPhoto *)photo
{
     [photoBrowser hide];
     RecordDataModel *record = (RecordDataModel *)(photo.tempData);
     NSMutableArray *dataArray = self.chatViewController.bubbleArray;
     for(NSInteger i = 0;i<dataArray.count;i++)
     {
          BubbleDataInternal *data = dataArray[i];
          if([record.msgId isEqualToString:data.record.msgId])
          {
               XTForwardDataModel *forwardData = [self.chatViewController packgeRecordToForwardData:data];
               if(forwardData) {
                    forwardData.bCanEditImage = YES;
                    [self.chatViewController forwardMsgArray:forwardData];
               }
          }
     }
}

// 编辑图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser sendAgainWithPhoto:(MJPhoto *)photo {
     [photoBrowser hide];
     [self.chatViewController goToImageEditorWithImage:photo.image];
     
     //     __weak BubbleTableViewCell *weakSelf = self;
     //     [[SDWebImageManager sharedManager] downloadWithURL:photo.originUrl options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
     //
     //          if (image) {
     //
     //          }
     //
     //     }];
     
}

- (void)openMapViewWithData:(id)dataModel
{
     
     KDMapViewController *mvc = [[KDMapViewController alloc]init];
     mvc.obj = dataModel;
     mvc.data = dataModel;
     //     mvc.mapView = [[KDWeiboAppDelegate getAppDelegate] mapView];
     [self.chatViewController.navigationController pushViewController:mvc animated:YES];
}

- (id)transformedValue:(double)value
{
     double convertedValue = value;
     int multiplyFactor = 0;
     
     NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
     
     while (convertedValue > 1024) {
          convertedValue /= 1024;
          multiplyFactor++;
     }
     
     return [NSString stringWithFormat:@"%.f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}
#pragma mark -
#pragma mark LongPressed Methods

- (void)longPressLogic
{
     if(self.hideMenu)
          return;
     
     //发送中或者接收中，不可点
     if (self.dataInternal.record.msgRequestState == MessageRequestStateRequesting
         || self.dataInternal.record.msgType == MessageTypeSystem) {
          return;
     }
     
     [self.chatViewController.view endEditing:false];
     [self.chatViewController hideInputBoard];
     
     [self.popoverMain showAt:self.bubbleImage containView:self.chatViewController.view];
     self.totaskSource = label_msg_totask_source_longpress;
}

-(int)getUTCFormateDate:(NSString *)newsDate
{
     //    newsDate = @"2013-08-09 17:01:00";
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     if(newsDate.length>19)
          [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
     else
          [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     
     NSDate *newsDateFormatted = [dateFormatter dateFromString:newsDate];
     NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
     [dateFormatter setTimeZone:timeZone];
     
     NSDate* current_date = [[NSDate alloc] init];
     
     NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数
     //    int month=((int)time)/(3600*24*30);
     //    int days=((int)time)/(3600*24);
     //    int hours=((int)time)%(3600*24)/3600;
     int minute=((int)time)%(3600*24)/60;
     
     return minute;
}
-(void)bubbleBtnLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
     if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
     {
          // 无痕消息，长按被截取
          if (self.dataInternal.record.msgType == MessageTypeNotrace) {
               [[KDChatNotraceManager sharedInstance] onLongPress:self];
               return;
          }
          [self longPressLogic];
     }
     else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
     {
          if (_dataInternal.record.msgType == MessageTypeNotrace)
          {
               [[KDChatNotraceManager sharedInstance] onAllFingersLeave];
               return;
          }
     }
}

-(void)newButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
     if(self.hideMenu)
          return;
     
     __weak __typeof(self) weakSelf = self;
     
     if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
          KDBubbleCellNewButton * button = (KDBubbleCellNewButton *)[gestureRecognizer view];
          _currentButtonIndex = button.tag;
          
          //发送中或者接收中, 系统消息，不可点
          if (self.dataInternal.record.msgRequestState == MessageRequestStateRequesting || self.dataInternal.record.msgType == MessageTypeSystem) {
               return;
          }
          [self.chatViewController.view endEditing:false];
          [self.chatViewController hideInputBoard];
          
          
          //直接在这里就生成菜单列表
          {
               //发送中或者接收中，不可点
               if (self.dataInternal.record.msgRequestState == MessageRequestStateRequesting) {
                    return;
               }
               BOOL canForward = YES;
               BOOL canShare = YES;
               /**
                *  判断是不是包含有url的新闻
                */
               //               RecordDataModel *record = self.dataInternal.record;
               //               MessageType type = record.msgType;
               //               if (type == MessageTypeNews) {
               //                    MessageNewsDataModel *paramObject = self.dataInternal.record.param.paramObject;
               //                    MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:_currentButtonIndex];
               //                    if ([news.url length] == 0) {
               //                         canForward = NO;
               //                         canShare = NO;
               //                    }
               //
               //               }
               /**
                *  判断公共号的内容是不是可以分享
                */
               GroupDataModel *group = self.chatViewController.group;
               PersonSimpleDataModel *person = [group.participant firstObject];
               canForward = [group allowInnerShare];
               canShare = [group allowOuterShare];
               
               
               
               NSMutableArray *menuArray = [NSMutableArray array];
               
               if (canForward) {
                    
                    if([self.newsbtn canPerformAction:@selector(forwardNew:) withSender:self.newsbtn])
                    {
                         KDItem *forwardItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_7")
                                                                    subtitle:nil
                                                                       image:[UIImage imageNamed:@"message_popup_forward"]
                                                            highlightedImage:nil
                                                                     onPress:^(NSObject *sender){
                                                                          [weakSelf.newsbtn forwardNew:nil];
                                                                     }];
                         [menuArray addObject:forwardItem];
                    }
               }
               
               
               if (canShare || canForward) {
                    
                    if([self.newsbtn canPerformAction:@selector(shareToOther:) withSender:self.newsbtn])
                    {
                         KDItem *shareToOtherItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_11")
                                                                         subtitle:nil
                                                                            image:[UIImage imageNamed:@"message_popup_share"]
                                                                 highlightedImage:nil
                                                                          onPress:^(NSObject *sender){
                                                                               [weakSelf.newsbtn shareToOther:nil];
                                                                          }];
                         
                         [menuArray addObject:shareToOtherItem];
                    }
                    
                    
                    if([BOSConfig sharedConfig].user.partnerType != 1)
                    {
                         
                         if([self.newsbtn canPerformAction:@selector(shareNewsToCommunity:) withSender:self.newsbtn])
                         {
                              KDItem *shareItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_12")
                                                                       subtitle:nil
                                                                          image:[UIImage imageNamed:@"message_popup_share"]
                                                               highlightedImage:nil
                                                                        onPress:^(NSObject *sender){
                                                                             [weakSelf.newsbtn shareNewsToCommunity:nil];
                                                                        }];
                              
                              [menuArray addObject:shareItem];
                         }
                    }
                    
               }
               
               
               if([self.newsbtn canPerformAction:@selector(deleteNews:) withSender:self.newsbtn])
               {
                    KDItem *deleteItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_13")
                                                              subtitle:nil
                                                                 image:[UIImage imageNamed:@"message_popup_delete"]
                                                      highlightedImage:nil
                                                               onPress:^(NSObject *sender){
                                                                    [weakSelf.newsbtn deleteNews:nil];
                                                               }];
                    
                    [menuArray addObject:deleteItem];
               }
               
               
               
               
               [button becomeFirstResponder];
               
               CGRect bubbleFrame = button.frame;
               CGRect newFrame = CGRectZero;
               if (button.tag == 0) {
                    newFrame = [self.newsview convertRect:bubbleFrame toView:self];
               }
               else{
                    newFrame = [self.newsbackview convertRect:bubbleFrame toView:self];
               }
               bubbleFrame.origin.y += 5.0;
               
               //直接在这里就生成菜单列表
               self.popoverPublicItemArray = menuArray;
          }
          
          
          [self.popoverPublic showAt: button containView:self.chatViewController.view];
          self.totaskSource = label_msg_totask_source_longpress;
     }
}

#pragma mark -
#pragma mark Forward Methods

- (void)forward:(id)sender
{
     MessageFileDataModel *file = (MessageFileDataModel *)self.dataInternal.record.param.paramObject;
     NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[file.name,[NSString stringWithFormat:@"%d",ForwardMessageFile],file] forKeys:@[@"message",@"forwardType",@"messageFileDM"]];
     XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:dict];
     forwardDM.dataInternal = self.dataInternal;
     [[NSNotificationCenter defaultCenter] postNotificationName:Notify_ForwardMessage object:forwardDM];
}
- (void)forwardText:(id)sender{
     XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
     forwardDM.forwardType = ForwardMessageText;
     forwardDM.contentString = self.dataInternal.record.content;
     forwardDM.dataInternal = self.dataInternal;
     [[NSNotificationCenter defaultCenter]postNotificationName:Notify_ForwardMessage object:forwardDM];
}

- (void)forwardPicture:(id)sender{
     NSURL * thumbnailUrl = [self.dataInternal.record thumbnailPictureUrl];
     NSURL * originalUrl = [self.dataInternal.record canTransmitUrl];
     BOOL isThumbnailExists = [[SDWebImageManager sharedManager] diskImageExistsForURL:thumbnailUrl];
     BOOL isOriginalExists = (originalUrl!=nil);
     
     
     MessageShareTextOrImageDataModel *paramObj = self.dataInternal.record.param.paramObject;
     
     if ((isThumbnailExists && isOriginalExists) || paramObj.fileId.length>0) {
          XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
          forwardDM.forwardType = ForwardMessagePicture;
          forwardDM.thumbnailUrl = thumbnailUrl;
          forwardDM.originalUrl = originalUrl;
          //         forwardDM.bCanEditImage = YES;
          forwardDM.paramObject = self.dataInternal.record.param;
          forwardDM.dataInternal = self.dataInternal;
          [[NSNotificationCenter defaultCenter]  postNotificationName:Notify_ForwardMessage object:forwardDM];
     }
     else{
          UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"BubbleTableViewCell_Tip_15")delegate:nil cancelButtonTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_16")otherButtonTitles: nil];
          [alertView show];
     }
}

- (void)forwardNew:(id)sender{
     if (self.chatViewController.group == nil || !self.chatViewController.ispublic) {
          return;
     }
     
     [self forwardShareNews:nil];
     //     RecordDataModel *record = self.dataInternal.record;
     //     GroupDataModel *group = self.chatViewController.group;
     //     PersonSimpleDataModel *person = [group.participant firstObject];
     //
     //     if (record.msgType == MessageTypeAttach) {
     //          MessageAttachDataModel *paramObject = record.param.paramObject;
     //          MessageAttachEachDataModel * attach = [paramObject.attach firstObject];
     //          NSLog(@"%@",person);
     //
     //          NSString *photoURL = [NSString new];
     //          if (person.photoUrl && person.photoUrl.length > 0) {
     //               photoURL = person.photoUrl;
     //          } else {
     //               photoURL = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
     //          }
     //
     //          NSDictionary *dic = @{@"shareType" : @(3),
     //                                @"appName" : person.personName,
     //                                @"title" : record.content,
     //                                @"content" :attach.name,
     //                                @"thumbUrl" : photoURL,
     //                                @"webpageUrl" : attach.value};
     //          [XTShareManager shareWithDictionary:dic andChooseContentType:XTChooseContentShareStatus];
     //     }
     //
     //     else if (record.msgType == MessageTypeNews) {
     ////          MessageNewsDataModel *paramObject = record.param.paramObject;
     ////          MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:_currentButtonIndex];
     ////          // bug 4033
     ////          NSString *photoURL = [NSString new];
     ////          if (news.name && news.name.length > 0) {
     ////               photoURL = news.name;
     ////          } else if (person.photoUrl && person.photoUrl.length > 0) {
     ////               photoURL = person.photoUrl;
     ////          } else {
     ////               photoURL = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
     ////          }
     ////
     ////          NSDictionary *dic = @{@"shareType" : @(3),
     ////                                @"appName" : person.personName,
     ////                                @"title" : news.title,
     ////                                   @"content" :[news.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]],
     ////                                @"thumbUrl" : photoURL,
     ////                                @"webpageUrl" : news.url};
     ////          [XTShareManager shareWithDictionary:dic andChooseContentType:XTChooseContentShareStatus];
     //          [self forwardShareNews:nil];
     //     }
}

- (void)forwardLocation:(id)sender {
     MessageTypeLocationDataModel *paramObject = self.dataInternal.record.param.paramObject;
     XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
     forwardDM.forwardType = ForwardMessageLocation;
     forwardDM.file_id = paramObject.file_id;
     forwardDM.address = paramObject.address;
     forwardDM.latitude = paramObject.latitude;
     forwardDM.longitude = paramObject.longitude;
     forwardDM.dataInternal = self.dataInternal;
     [[NSNotificationCenter defaultCenter]postNotificationName:Notify_ForwardMessage object:forwardDM];
}

- (void)forwardShortVideo:(id)sender {
     MessageTypeShortVideoDataModel *paramObject = self.dataInternal.record.param.paramObject;
     XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
     forwardDM.forwardType = ForwardMessageShortVideo;
     forwardDM.file_id = paramObject.file_id;
     forwardDM.ext = paramObject.ext;
     forwardDM.videoThumbnail = paramObject.videoThumbnail;
     forwardDM.size = paramObject.size;
     forwardDM.mtime = paramObject.mtime;
     forwardDM.name = paramObject.name;
     forwardDM.videoTimeLength = paramObject.videoTimeLength;
     forwardDM.videoUrl = paramObject.videoUrl;
     forwardDM.dataInternal = self.dataInternal;
     [[NSNotificationCenter defaultCenter]postNotificationName:Notify_ForwardMessage object:forwardDM];
}

-(void)forwardShareNews:(id)sender
{
     XTForwardDataModel *forwardDM = [self.chatViewController packgeRecordToForwardData:self.dataInternal];
     [[NSNotificationCenter defaultCenter]postNotificationName:Notify_ForwardMessage object:forwardDM];
}

- (void)reply:(id)sender {
     self.chatViewController.replyRecord = self.dataInternal.record;
     [self.chatViewController changeMessageModeTo: KDChatMessageModeReply];
     NSString *strPersonName = [self.chatViewController personNameWithGroup:self.chatViewController.group record:self.dataInternal.record];
     if (strPersonName.length > 0) {
          self.chatViewController.contentView.placeholder = [NSString stringWithFormat:@"回复@%@", strPersonName];
     } else {
          self.chatViewController.contentView.placeholder = [NSString stringWithFormat:@"回复@**"];
     }
     //     if (self.blockReplyDidPressed) {
     //          self.blockReplyDidPressed(self.dataInternal.record);
     //     }
}


#pragma mark -
#pragma mark ShareToCommunity Methods
- (void)shareToCommunity:(id)sender{
     //    KDCommunityShareView * shareView = nil;
     //    switch (self.dataInternal.record.msgType) {
     //        case MessageTypeText:{
     //            shareView = [[KDCommunityShareView alloc]initWithFrame:self.chatViewController.view.bounds type:KDCommunityShareTypeText isForIPhone5:isAboveiPhone5];
     //            shareView.contentText = self.dataInternal.record.content;
     //        }
     //            break;
     //        case MessageTypePicture:{
     //            NSURL * originalUrl = [self.dataInternal.record originalPictureUrl];
     //            BOOL isOriginalExists = [[SDWebImageManager sharedManager]diskImageExistsForURL:originalUrl imageScale:SDWebImageScalePreView];
     //
     //            MessageShareTextOrImageDataModel *paramObj = self.dataInternal.record.param.paramObject;
     //            if (isOriginalExists || paramObj.fileId.length>0 ) {
     //                shareView = [[KDCommunityShareView alloc]initWithFrame:self.chatViewController.view.bounds type:KDCommunityShareTypeImage isForIPhone5:isAboveiPhone5];
     //                shareView.imagePath = [[SDWebImageManager sharedManager]diskImagePathForURL:originalUrl imageScale:SDWebImageScalePreView];
     //            }
     //            else{
     //                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"BubbleTableViewCell_Tip_17")delegate:nil cancelButtonTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_16")otherButtonTitles: nil];
     //                [alertView show];
     //                return ;
     //            }
     //        }
     //            break;
     //        case MessageTypeNews:{
     //            RecordDataModel *record = self.dataInternal.record;
     //            MessageNewsDataModel *paramObject = record.param.paramObject;
     //
     //            MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:_currentButtonIndex];
     //            GroupDataModel *group = self.chatViewController.group;
     //            PersonSimpleDataModel *person = [group.participant firstObject];
     //            shareView = [[KDCommunityShareView alloc]initWithFrame:self.chatViewController.view.bounds type:KDCommunityShareTypeNew isForIPhone5:isAboveiPhone5];
     //            shareView.personUrl = person.photoUrl;
     //            shareView.theNewDataMedel = news;
     //
     //
     //
     //
     //
     //        }
     //            break;
     //        case MessageTypeFile:{
     //            shareView = [[KDCommunityShareView alloc]initWithFrame:self.chatViewController.view.bounds type:KDCommunityShareTypeFile isForIPhone5:isAboveiPhone5];
     //            RecordDataModel *record = self.dataInternal.record;
     //            MessageFileDataModel *file = (MessageFileDataModel *)record.param.paramObject;
     //            shareView.fileDataModel = file;
     //        }
     //            break;
     //
     //
     //        default:
     //            return ;
     //            break;
     //    }
     //    self.chatViewController.shouldChangeTextField = NO;
     //    shareView.delegate = self.chatViewController;
     //    [self.chatViewController.view addSubview:shareView];
     //    [shareView becomeFirstResponderShareView];
     
     KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
     PostViewController *pvc = [factory getPostViewController];
     pvc.isSelectRange = YES;
     KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
     
     RecordDataModel *record = self.dataInternal.record;
     switch (record.msgType) {
          case MessageTypeText:{
               draft.content = record.content;
          }
               break;
          case MessageTypeAttach: {
               MessageAttachDataModel *paramObject = record.param.paramObject;
               MessageAttachEachDataModel * attach = [paramObject.attach firstObject];
               draft.content =  [NSString stringWithFormat:@"%@\n%@",record.content,attach.value];
          }
               break;
          case MessageTypeNews:{
               MessageNewsDataModel *paramObject = record.param.paramObject;
               MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:_currentButtonIndex];
               
               if ([news.title isEqualToString:news.text] || news.title.length == 0) {//多图新闻类型
                    draft.content = [NSString stringWithFormat:@"%@\n%@",news.text,news.url];
                    
               }
               else{//单图新闻类型
                    
                    int totalLenght = (int)(news.title.length + news.text.length + news.url.length);
                    if (totalLenght < 990) {
                         draft.content = [NSString stringWithFormat:@"%@\n%@\n%@",news.title,news.text,news.url];
                    }
                    else{
                         NSString *  string = [news.text substringToIndex:(1000 - news.url.length - news.title.length - 10)];
                         draft.content = [NSString stringWithFormat:@"%@\n%@\n%@",news.title,string,news.url];
                         
                    }
                    
               }
               
               NSArray * imageArray = nil;
               NSString *imagePath = [NSString new];
               NSURL * url = [NSURL URLWithString:news.name];
               BOOL isImageExists = [[SDWebImageManager sharedManager]diskImageExistsForURL:url];
               if (isImageExists) {
                    imagePath = [[SDWebImageManager sharedManager] diskImagePathForURL:url imageScale:SDWebImageScaleNone];
               }
               
               if ([imagePath length] > 0) {
                    imageArray = @[imagePath];
               }
               [pvc setPickedImage:imageArray];
          }
               break;
          case MessageTypeFile:{
               draft.content = ASLocalizedString(@"KDCommunityShareView_ShareFile");
               MessageFileDataModel *fileDataModel = (MessageFileDataModel *)record.param.paramObject;
               
               NSString * baseURL = [NSString stringWithFormat:@"%@/%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL, [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId];
               KDStatus *status = [draft sendingStatus:nil videoPath:nil];
               KDAttachment * attachment = [[KDAttachment alloc]init];
               attachment.fileId = fileDataModel.file_id;
               attachment.filename = fileDataModel.name;
               attachment.fileSize = [fileDataModel.size integerValue];
               attachment.url = [NSString stringWithFormat:@"%@/filesvr/%@",baseURL,fileDataModel.file_id];
               attachment.objectId = status.statusId;
               attachment.attachmentType = KDAttachmentTypeStatus;
               attachment.contentType = fileDataModel.ext;
               
               pvc.attachment = attachment;
               pvc.fileDataModel = fileDataModel;
          }
               break;
               
          default:
               return ;
               break;
     }
     
     pvc.draft = draft;
     [KDWeiboAppDelegate setExtendedLayout:pvc];
     [[KDDefaultViewControllerContext defaultViewControllerContext] showPostViewController:pvc];
}

- (void)shareNewsToCommunity:(id)sender{
     KDCommunityShareView * shareView = nil;
     
     RecordDataModel *record = self.dataInternal.record;
     MessageNewsDataModel *paramObject = record.param.paramObject;
     
     MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:_currentButtonIndex];
     GroupDataModel *group = self.chatViewController.group;
     PersonSimpleDataModel *person = [group.participant firstObject];
     shareView = [[KDCommunityShareView alloc]initWithFrame:self.chatViewController.view.bounds type:KDCommunityShareTypeNew isForIPhone5:isAboveiPhone5];
     shareView.theNewDataMedel = news;
     shareView.personUrl = person.photoUrl;
     self.chatViewController.shouldChangeTextField = NO;
     shareView.delegate = self.chatViewController;
     [self.chatViewController.view addSubview:shareView];
}

- (void)shareToOther:(id)sender{
     
     GroupDataModel *group = self.chatViewController.group;
     if(self.chatViewController.pubAccount)
          group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupWithPublicPersonId:self.chatViewController.pubAccount.publicId];
     
     
     UIActionSheet * actionSheet = nil;
     if([BOSConfig sharedConfig].user.partnerType != 1 && [group allowInnerShare])
     {
          if([group allowOuterShare])
          {
               //zgbin:屏蔽分享到其他
               actionSheet = [[UIActionSheet alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_11")delegate:self cancelButtonTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_18")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"BubbleTableViewCell_Tip_share_dynamic"),/*ASLocalizedString(@"BubbleTableViewCell_Tip_19"),*/ nil];
               //zgbin:end
          }
          else
          {
               actionSheet = [[UIActionSheet alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_11")delegate:self cancelButtonTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_18")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"BubbleTableViewCell_Tip_share_dynamic"), nil];
          }
     }
     else
     {
          actionSheet = [[UIActionSheet alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_11")delegate:self cancelButtonTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_18")destructiveButtonTitle:nil otherButtonTitles:/*ASLocalizedString(@"BubbleTableViewCell_Tip_19"),*/nil];
     }
     [actionSheet showInView:self.chatViewController.view];
}

- (void)collect:(id)sender
{
     id obj = self.dataInternal.record.param.paramObject;
     if([obj isKindOfClass:[MessageFileDataModel class]])
     {
          MessageFileDataModel *file = (MessageFileDataModel *)obj;
          self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
          [self.client stowFile:file.file_id networkId:[BOSConfig sharedConfig].user.eid];
     }
     else if([obj isKindOfClass:[MessageShareTextOrImageDataModel class]])
     {
          MessageShareTextOrImageDataModel *picture = (MessageShareTextOrImageDataModel *)obj;
          self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
          [self.client stowFile:picture.fileId networkId:[BOSConfig sharedConfig].user.eid];
     }
     else if ([obj isKindOfClass:[MessageTypeShortVideoDataModel class]]) {
          MessageTypeShortVideoDataModel *shortVideo = obj;
          self.client = [[XTWbClient alloc] initWithTarget:self action:@selector(stowFileDidReceived:result:)];
          [self.client stowFile:shortVideo.file_id networkId:[BOSConfig sharedConfig].user.eid];
     }
}
- (void)stowFileDidReceived:(XTWbClient *)client result:(BOSResultDataModel *)result{
     
     if (client.hasError || !result.success) {
          
          [[NSNotificationCenter defaultCenter] postNotificationName:Notify_CollectFile object:Result_Fail];
          return;
     }
     
     [[NSNotificationCenter defaultCenter] postNotificationName:Notify_CollectFile object:Result_Success];
}

- (void)changeToTask:(id)sender{
     
     [KDEventAnalysis event:event_msg_totask attributes:@{label_msg_totask_source: self.totaskSource}];
     
     KDCreateTaskViewController *ctr = [[KDCreateTaskViewController alloc] init];
     ctr.title = ASLocalizedString(@"BubbleTableViewCell_Tip_9");
     ctr.referObject = self.dataInternal.record;
     ctr.referType = KDCreateTaskReferTypeChatMessage;
     
     [[KDDefaultViewControllerContext defaultViewControllerContext] showCreateTaskViewControllerController:ctr];
}

-(void)shareToSocial{
     KDSheet * sheet = nil;
     KDSheetShareWay shareWay = KDSheetShareWayQQ |  KDSheetShareWayWeibo | KDSheetShareWayWechat |KDSheetShareWayMoment;
     switch (self.dataInternal.record.msgType) {
          case MessageTypeText:{
               sheet = [[KDSheet alloc]initTextWithShareWay:shareWay text:self.dataInternal.record.content viewController:self.chatViewController];
          }
               break;
          case MessageTypeAttach:{
               RecordDataModel *record = self.dataInternal.record;
               MessageAttachDataModel *paramObject = record.param.paramObject;
               MessageAttachEachDataModel * attach = [paramObject.attach firstObject];
               PersonSimpleDataModel *person = [self.chatViewController.group.participant firstObject];
               NSString *photoURL = [NSString new];
               if (person.photoUrl && person.photoUrl.length > 0) {
                    photoURL = person.photoUrl;
               } else {
                    photoURL = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
               }
               NSData * imageData = UIImageJPEGRepresentation([[SDWebImageManager sharedManager]diskImageForURL:[NSURL URLWithString:photoURL]], 0.5);
               
               NSString * title = record.content;
               
               KDSheet * sheel = [[KDSheet alloc]initMediaWithShareWay:shareWay title:title description:@"" thumbData:imageData webpageUrl:attach.value viewController:self.chatViewController];
               _shareSheet = sheel;
               [sheel share];
          }
               break;
          case MessageTypeNews:{
               RecordDataModel *record = self.dataInternal.record;
               MessageNewsDataModel *paramObject = record.param.paramObject;
               
               MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:_currentButtonIndex];
               GroupDataModel *group = self.chatViewController.group;
               PersonSimpleDataModel *person = [group.participant firstObject];
               
               NSData * imageData = UIImageJPEGRepresentation([[SDWebImageManager sharedManager]diskImageForURL:[NSURL URLWithString:person.photoUrl]], 0.5);
               
               NSString * title = news.title;
               if ([news isSubNews]) {
                    title = news.text;
               }
               KDSheet * sheel = [[KDSheet alloc]initMediaWithShareWay:shareWay title:title description:@"" thumbData:imageData webpageUrl:news.url viewController:self.chatViewController];
               _shareSheet = sheel;
               [sheel share];
          }
               break;
               
          default:
               return ;
               break;
     }
     
     if (sheet) {
          _shareSheet =sheet;
          [sheet share];
     }
     self.chatViewController.socialShareSheet = _shareSheet;
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
     if(actionSheet.tag == 999)
     {
          if(buttonIndex == 0)
               return;
          
          NSUInteger index = buttonIndex -1;
          if(index < self.msgToLightAppArray.count)
          {
               NSString *url = [self.msgToLightAppArray[index] objectForKey:@"url"];
               NSString *titleBgColor = [self.msgToLightAppArray[index] objectForKey:@"titleBgColor"];
               NSString *titlePbColor = [self.msgToLightAppArray[index] objectForKey:@"titlePbColor"];
               url = [url stringByAppendingString:[NSString stringWithFormat:@"&msgId=%@&fromUserId=%@",self.dataInternal.record.msgId,self.dataInternal.record.fromUserId]];
               
               KDWebViewController *applightWebVC = [[KDWebViewController alloc] initWithUrlString:url];
               applightWebVC.hidesBottomBarWhenPushed = YES;
               applightWebVC.isLightApp = YES;
               __weak __typeof(applightWebVC) weak_webvc = applightWebVC;
               __weak __typeof(self.chatViewController) weak_controller = self.chatViewController;
               
               if(titleBgColor.length == 0)
               {
                    [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
               }
               else
               {
                    applightWebVC.getLightAppBlock = ^() {
                         if(weak_webvc && !weak_webvc.bPushed){
                              weak_webvc.color4NavBg = titleBgColor;
                              weak_webvc.color4processBg = titlePbColor;
                              [weak_controller.navigationController pushViewController:weak_webvc animated:YES];
                         }
                    };
               }
          }
     }
     else
     {
          NSString * buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
          if ([buttonTitle isEqualToString:ASLocalizedString(@"BubbleTableViewCell_Tip_share_dynamic")]) {
               [self shareToCommunity:nil];
          }
          else if([buttonTitle isEqualToString:ASLocalizedString(@"BubbleTableViewCell_Tip_19")]){
               [self shareToSocial];
          }
     }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
     
     UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
     [keyWindow makeKeyAndVisible];
     
}
- (void)cancelBubbleImageHighlighted
{
     [_bubbleImage setHighlighted:NO];
}

- (void)willHideEditMenu
{
     if (_bubbleImage.highlighted) {
          [self cancelBubbleImageHighlighted];
     }
}

- (void)actionBtnPressed:(UIButton *)btn
{
     int index = (int)btn.tag;
     
     MessageAttachDataModel *paramObject = self.dataInternal.record.param.paramObject;
     MessageAttachEachDataModel *attach = [paramObject.attach objectAtIndex:index];
     
     [self openWithUrl:attach.value appId:attach.appId title:self.chatViewController.group.groupName share:nil];
}

- (void)reSend:(UIButton *)btn
{
     if (self.dataInternal.record.msgPlayType == MessagePlayTypeFailue) {
          return;
     }
     
     if (self.dataInternal.record.msgRequestState == MessageRequestStateFailue) {
          
          if(![self.dataInternal.group isManager] && [self.dataInternal.group slienceOpened])
          {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"该群组已全员禁言,\n无法发送消息") delegate:nil cancelButtonTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_no") otherButtonTitles:nil];
               [alertView show];
               return;
          }
          
          if (self.dataInternal.record.msgType == MessageTypeSpeech && [self.dataInternal.record xtFilePath] == nil) {
               return;
          }
          self.dataInternal.record.msgRequestState = MessageRequestStateRequesting;
          [self setupInternalData];
          //         //地理位置特殊需要带图片
          //         if (self.dataInternal.record.msgType == MessageTypeLocation ) {
          //
          //              [self.chatViewController sendWithRecord:self.dataInternal.record image:];
          //         }
          //         else
          //         {
          //发送或者重发
          [self.chatViewController sendWithRecord:self.dataInternal.record];
          
          //         }
          
          [KDEventAnalysis event:event_msg_resend];
     }
}

-(void)getContent
{
     if (_getContentClient == nil) {
          _getContentClient = [[ContactClient alloc] initWithTarget:self action:@selector(getContentDidReceived:result:)];
     }
     
     if (self.dataInternal.record.msgType == MessageTypeSpeech) {
          if (self.chatViewController.chatMode == ChatPrivateMode) {
               [_getContentClient getFileWithMsgId:self.dataInternal.record.msgId groupId:self.dataInternal.record.groupId];
          }else{
               [_getContentClient publicGetFileWithPublicId:self.chatViewController.pubAccount.publicId msgId:self.dataInternal.record.msgId];
          }
     }
}

-(void)getContentDidReceived:(ContactClient *)client result:(id)result
{
     if (!client.hasError && result && [result isKindOfClass:[NSData class]]) {
          [self getContentSuccess:result];
          return;
     }
     [self getContentFailue];
}

-(void)getContentSuccess:(NSData *)content
{
     NSString *filePath = nil;
     if (self.dataInternal.record.msgType == MessageTypeSpeech){
          filePath = [[ContactUtils recordFilePathWithGroupId:self.dataInternal.group.groupId] stringByAppendingFormat:@"/%@%@",self.dataInternal.record.msgId,XTFileExt];
     }
     
     //写入数据
     [content writeToFile:filePath atomically:YES];
     
     //刷新界面
     [self.dataInternal.record setStatus:MessageStatusRead];
     [self.dataInternal.record setMsgRequestState:MessageRequestStateSuccess];
     [self setupInternalData];
     [[XTDataBaseDao sharedDatabaseDaoInstance] insertRecord:self.dataInternal.record toUserId:@"" needUpdateGroup:NO publicId:self.chatViewController.chatMode == ChatPrivateMode ? nil : self.chatViewController.pubAccount.publicId];
     
     if (self.dataInternal.record.msgType == MessageTypeSpeech) {
          [self play:filePath];
     }
}

-(void)getContentFailue
{
     //刷新界面
     [self.dataInternal.record setMsgRequestState:MessageRequestStateFailue];
     [self setupInternalData];
}

#pragma mark - play

-(void)play:(NSData *)fileData identifier:(NSString *)identifier cell:(BubbleTableViewCell *)cell
{
     [[BOSAudioPlayer sharedAudioPlayer] createPlayerWithData:fileData identifier:identifier cell:cell];
     if ([BOSAudioPlayer sharedAudioPlayer].isPlaying) {
          [[BOSAudioPlayer sharedAudioPlayer] stopPlay];
     }else{
          [[BOSAudioPlayer sharedAudioPlayer] startPlay];
     }
}

-(void)play:(NSString *)filePath
{
     if (_playData == nil) {
          NSData *sourceData = [NSData dataWithContentsOfFile:filePath];
          _playData = DecodeAMRToWAVE([ContactUtils XOR80:sourceData]);
          if(_playData == nil)
          {
               [self.dataInternal.record setMsgPlayType:MessagePlayTypeFailue];
               [self setupInternalData];
          }
     }
     [self play:_playData identifier:self.dataInternal.record.msgId cell:self];
}

#pragma mark - XTPersonHeaderViewDelegate

- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
     //     if (self.chatViewController.bSearchingMode) {
     //          return;
     //     }
     
     //意见反馈的左侧不能点击
     if (self.dataInternal.group.groupType == GroupTypePublicMany && self.dataInternal.record.msgDirection == MessageDirectionLeft) {
          return;
     }
     
     if ([person isPublicAccount]) {
          KDPubAccDetailViewController *pubAccDetail = [[KDPubAccDetailViewController alloc] initWithPubAcct:person];
          pubAccDetail.hidesBottomBarWhenPushed = YES;
          [self.chatViewController.navigationController pushViewController:pubAccDetail animated:YES];
          //        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:YES];
          //        personDetail.hidesBottomBarWhenPushed = YES;
          //        [self.chatViewController.navigationController pushViewController:personDetail animated:YES];
          
     } else {
          XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO];
          personDetail.hidesBottomBarWhenPushed = YES;
          [self.chatViewController.navigationController pushViewController:personDetail animated:YES];
     }
     
}

#pragma mark - OHAttributedLabelDelegate

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
     switch (linkInfo.resultType) {
          case NSTextCheckingTypeLink:
          {
               NSString *url = linkInfo.extendedURL.absoluteString;
               if ([url hasPrefix:@"mailto:"])
               {
                    [XTMAILHandle sharedMAILHandle].controller = self.chatViewController;
                    [[XTMAILHandle sharedMAILHandle] mailWithEmailAddress:[url stringByReplacingOccurrencesOfString:@"mailto:" withString:@""]];
               }
               else
               {
                    if (url.length > 0) {
                         KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:url];
                         webVC.title = self.chatViewController.group.groupName;
                         webVC.hidesBottomBarWhenPushed = YES;
                         [self.chatViewController.navigationController pushViewController:webVC animated:YES];
                    }
               }
          }
               break;
          case NSTextCheckingTypePhoneNumber:
               [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:linkInfo.phoneNumber];
               break;
          default: {
               break;
          }
     }
     return NO;
}

#pragma mark - KDExpressionLabelDelegate

- (void)expressionLabel:(KDExpressionLabel *)label didClickUserWithName:(NSString *)userName
{
     __weak __typeof(self) weakSelf= self;
     __block PersonSimpleDataModel *currentPerson = nil;
     NSMutableArray *personArray = self.chatViewController.group.participant;
     [personArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          PersonSimpleDataModel *person = obj;
          if([person.personName isEqualToString:userName])
          {
               currentPerson = person;
               *stop = YES;
          }
     }];
     
     if(currentPerson == nil)
     {
          if([[BOSConfig sharedConfig].currentUser.personName isEqualToString:userName])
               currentPerson = [BOSConfig sharedConfig].currentUser;
     }
     
     if(currentPerson == nil)
          return;
     
     XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:currentPerson with:NO];
     personDetail.hidesBottomBarWhenPushed = YES;
     [weakSelf.chatViewController.navigationController pushViewController:personDetail animated:YES];
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickUrl:(NSString *)urlString
{
     if (urlString.length > 0) {
          KDWebViewController *webVC = [[KDWebViewController alloc] initWithUrlString:urlString];
          webVC.title = self.chatViewController.group.groupName;
          webVC.hidesBottomBarWhenPushed = YES;
          [self.chatViewController.navigationController pushViewController:webVC animated:YES];
     }
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickPhoneNumber:(NSString *)phoneNumber
{
     if (phoneNumber.length > 0) {
          [[XTTELHandle sharedTELHandle] telWithPhoneNumbel:phoneNumber];
     }
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickEmail:(NSString *)email
{
     if (email.length > 0) {
          [XTMAILHandle sharedMAILHandle].controller = self.chatViewController;
          [[XTMAILHandle sharedMAILHandle] mailWithEmailAddress:email];
     }
}


- (void)expressionLabel:(KDExpressionLabel *)label didClickKeyword:(NSString *)keyword
{
     //发送中或者接收中，不可点
     if (self.dataInternal.record.msgRequestState == MessageRequestStateRequesting) {
          return;
     }
     
     //高亮
     [_bubbleImage setHighlighted:YES];
     NSMutableArray * items = [NSMutableArray array];
     
     UIMenuItem * task = [[UIMenuItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_9")action:@selector(changeToTask:)];
     [items addObject:task];
     
     UIMenuController *menu = [UIMenuController sharedMenuController];
     [menu setMenuItems:items];
     
     [_bubbleImage becomeFirstResponder];
     CGRect bubbleFrame = _bubbleImage.frame;
     bubbleFrame.origin.y += 5.0;
     [menu setTargetRect:bubbleFrame inView:self];
     [menu setMenuVisible:YES animated:YES];
     
     self.totaskSource = label_msg_totask_source_keyclick;
}


- (void)expressionLabel:(KDExpressionLabel *)label didClickTopicWithName:(NSString *)topicName
{
     if (topicName.length > 0) {
          KDTopic *topic = [[KDTopic alloc] init];
          topic.name = topicName;
          
          TrendStatusViewController *tsvc = [[TrendStatusViewController alloc] initWithTopic:topic];
          [self.chatViewController.navigationController pushViewController:tsvc animated:YES];
     }
}



-(void)layoutSubviews
{
     [super layoutSubviews];
     self.contentView.clipsToBounds = YES;
     int checkMode = self.dataInternal.checkMode;
     if(checkMode!=-1 && (self.dataInternal.record.msgType != MessageTypeSystem && self.dataInternal.record.msgType!=MessageTypeCancel))
     {
          CGRect contentFrame = self.contentView.frame;
          if(!self.checkBtn)
          {
               self.checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
               self.checkBtn.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.personHeaderImageView.frame.origin.y, 25, 25);
               self.checkBtn.center = CGPointMake(self.frame.size.width-25, self.checkBtn.center.y);
               [self.checkBtn setImage:[UIImage imageNamed:@"choose-circle-o"] forState:UIControlStateNormal];
               [self.checkBtn setImage:[UIImage imageNamed:@"choose_circle_n"] forState:UIControlStateSelected];
               [self.checkBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
               self.checkBtn.hidden = YES;
               [self addSubview:self.checkBtn];
          }
          
          if(checkMode == 0)
               self.checkBtn.selected = NO;
          else
               self.checkBtn.selected = YES;
          
          
          BOOL isCanMultiSelect = NO;
          if(self.dataInternal.muliteSelectMode == 1)
          {
               //转发时未下载的图片以及文件不支持转发
               //            if(self.dataInternal.record.msgType == MessageTypePicture)
               //            {
               //                NSURL * thumbnailUrl = [self.dataInternal.record thumbnailPictureUrl];
               //                NSURL * originalUrl = [self.dataInternal.record originalPictureUrl];
               //                BOOL isThumbnailExists = [[SDWebImageManager sharedManager] diskImageExistsForURL:thumbnailUrl];
               //                BOOL isOriginalExists = [[SDWebImageManager sharedManager]diskImageExistsForURL:originalUrl imageScale:SDWebImageScalePreView];
               //                if (self.dataInternal.muliteSelectMode !=1)
               //                    isCanMultiSelect = YES;
               //                else if(isThumbnailExists && isOriginalExists)
               //                    isCanMultiSelect = YES;
               //                else
               //                    isCanMultiSelect = NO;
               //            }
               //            else
               //            {
               //只有图片、文件、文字支持多选转发
               if(self.dataInternal.record.msgType == MessageTypeFile
                  ||self.dataInternal.record.msgType == MessageTypeText
                  ||self.dataInternal.record.msgType == MessageTypePicture
                  ||self.dataInternal.record.msgType == MessageTypeLocation
                  ||self.dataInternal.record.msgType == MessageTypeShortVideo
                  ||self.dataInternal.record.msgType == MessageTypeCombineForward
                  ||self.dataInternal.record.msgType == MessageTypeNews
                  ||self.dataInternal.record.msgType == MessageTypeShareNews
                  ||self.dataInternal.record.msgType == MessageTypeAttach)
                    isCanMultiSelect = YES;
               else
                    isCanMultiSelect = NO;
               //}
          }
          else
          {
               //都可以删除
               isCanMultiSelect = YES;
          }
          
          if(self.dataInternal.record.msgDirection == MessageDirectionLeft)
               contentFrame.size.width -= 40;
          else
               contentFrame.origin.x -= 40;
          
          self.contentView.frame = contentFrame;
          
          self.checkBtn.hidden = !isCanMultiSelect;
          
          //多选模式下不允许操作
          self.contentView.userInteractionEnabled = NO;
          
          //添加多选点击事件
          if(!self.tapGes)
          {
               UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkBtnClick:)];
               tapGes.numberOfTapsRequired = 1;
               tapGes.numberOfTouchesRequired = 1;
               [self addGestureRecognizer:tapGes];
               self.tapGes = tapGes;
          }
     }
     else
     {
          CGRect contentFrame = self.contentView.frame;
          
          if(self.checkBtn)
          {
               [self.checkBtn removeFromSuperview];
               self.checkBtn = nil;
               
               
               if(self.dataInternal.record.msgDirection == MessageDirectionLeft)
                    contentFrame.size.width += 40;
               else
                    contentFrame.origin.x = 0;
               
               self.contentView.frame = contentFrame;
          }
          else
          {
               if(self.dataInternal.record.msgDirection == MessageDirectionLeft)
                    contentFrame.size.width += 40;
               else
                    contentFrame.origin.x = 0;
               
               self.contentView.frame = contentFrame;
          }
          
          //非多选模式下允许操作
          self.contentView.userInteractionEnabled = YES;
          
          //移除点击事件
          if(self.tapGes)
               [self removeGestureRecognizer:self.tapGes];
          self.tapGes = nil;
     }
}

-(void)checkBtnClick:(UIButton *)btn
{
     if(self.dataInternal.checkMode == 0)
     {
          self.dataInternal.checkMode = 1;
          self.checkBtn.selected = YES;
     }
     else
     {
          self.dataInternal.checkMode = 0;
          self.checkBtn.selected = NO;
     }
     
     if(self.bubbleImage.delegate && [self.bubbleImage.delegate respondsToSelector:@selector(bubbleDidCheckInMultiSelect:cell:isCheck:)])
     {
          [self.bubbleImage.delegate bubbleDidCheckInMultiSelect:self.bubbleImage cell:self isCheck:self.checkBtn.selected];
     }
}


-(void)showCellMultiSelectAnimate
{
     //动画效果
     CGRect contentFrame = self.contentView.frame;
     contentFrame.origin.x = -40;
     BubbleTableViewCell *selfInBlock = self;
     [UIView animateWithDuration:0.5f animations:^{
          //只有自己发的消息才需要左移挪出位置
          if(selfInBlock.dataInternal.record.msgDirection == MessageDirectionRight)
               selfInBlock.contentView.frame = contentFrame;
     } completion:^(BOOL finished) {
          [selfInBlock layoutSubviews];
     }];
}

-(void)hideCellMultiSelectAnimate
{
     //动画效果
     BubbleTableViewCell *selfInBlock = self;
     [UIView animateWithDuration:0.5f animations:^{
          [selfInBlock layoutSubviews];
     } completion:^(BOOL finished) {
     }];
}


#pragma mark - unreadTap
-(void)unreadTap:(UITapGestureRecognizer *)sender
{
     //友盟点击小气泡埋点
     //    [KDEventAnalysis event:event_unreadMessage_tipsPress];
     //跟新库小气泡已经被点击
     [XTSetting sharedSetting].pressMsgUnreadTipsOrNot = YES;
     [[XTSetting sharedSetting] saveSetting];
     //更新库小气泡已经被点击
     [[XTDataBaseDao sharedDatabaseDaoInstance] updateMsgPressStateWithMsgId:self.dataInternal.record.msgId
                                                                  PressState:@"Yes"];
     //获取每条消息详细的已读未读信息
     [[KDApplicationQueryAppsHelper shareHelper] getUnreadCountDetailWithGroupId:self.dataInternal.record.groupId
                                                                           MsgId:self.dataInternal.record.msgId];
}



#pragma mark - popover -

- (KDPopover *)popoverMain
{
     if (!_popoverMain) {
          _popoverMain = [KDPopover new];
          _popoverMain.dataSource = self;
     }
     return _popoverMain;
}

- (KDPopover *)popoverPublic
{
     if (!_popoverPublic) {
          _popoverPublic = [KDPopover new];
          _popoverPublic.dataSource = self;
     }
     return _popoverPublic;
}

//- (KDPopover *)popoverTask
//{
//     if (!_popoverTask) {
//          _popoverTask = [KDPopover new];
//          _popoverTask.dataSource = self;
//     }
//     return _popoverTask;
//}

- (NSInteger)itemCountForRow {
     if (isAboveiPhone6) {
          return 5;
     } else {
          return 4;
     }
}

- (NSArray<KDItem *> *)itemModels:(KDPopover *)popover
{
     __weak __typeof(self) weakSelf = self;
     
     if (popover == self.popoverMain) {
          
          NSMutableArray *menuArray = [NSMutableArray array];
          BOOL canForward = YES;
          BOOL canShare = YES;
          RecordDataModel *record = self.dataInternal.record;
          MessageType type = record.msgType;
          
          /**
           *  判断是不是包含有url的新闻
           */
          if (type == MessageTypeNews) {
               MessageNewsDataModel *paramObject = self.dataInternal.record.param.paramObject;
               //               MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:_currentButtonIndex];
               //               if ([news.url length] == 0) {
               //                    canForward = NO;
               //                    canShare = NO;
               //               }
               
               // 如果是代办 则只能删除
               if(paramObject.model==1 && paramObject.todoNotify)
               {
                    canForward = NO;
                    canShare = NO;
               }
          }
          /**
           *  判断公共号的内容是不是可以分享
           */
          GroupDataModel *group = self.chatViewController.group;
          //PersonSimpleDataModel *person = [group.participant firstObject];
          if(self.chatViewController.pubAccount)
               group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicGroupWithPublicPersonId:self.chatViewController.pubAccount.publicId];
          
          canForward = [group allowInnerShare];
          canShare = [group allowOuterShare];
          
          //根据后台参数判断是否可分享
          if (canForward || canShare)
          {    // 复制（后台可分享，且是文本消息）
               if([self.bubbleImage canPerformAction:@selector(copyText:) withSender:self.bubbleImage])
               {
                    KDItem *copyItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_6")
                                                            subtitle:nil
                                                               image:[UIImage imageNamed:@"message_popup_copy"]
                                                    highlightedImage:nil
                                                             onPress:^(NSObject *sender){
                                                                  [weakSelf.bubbleImage copyText:nil];
                                                             }];
                    [menuArray addObject:copyItem];
               }
          }
          
          //根据后台参数判断是否可撤回
          NSInteger min = [[BOSSetting sharedSetting] canCancelMessage];
          //判断自己的消息且mcloud返回的参数不为 －1
          if ([self.dataInternal.record.fromUserId isEqualToString:[BOSConfig sharedConfig].currentUser.personId] && min >= 0 && self.dataInternal.group.groupType < 3 && self.dataInternal.record.msgDirection == MessageDirectionRight && type != MessageTypeCancel && type != MessageTypeSystem)
          {
               //判断消息发送时间是否在设定的min范围内
               if ([self getUTCFormateDate:self.dataInternal.record.sendTime] <= min || min == 0) {
                    
                    if([self.bubbleImage canPerformAction:@selector(cancelMsg:) withSender:self.bubbleImage])
                    {
                         KDItem *withDrawItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_8")
                                                                     subtitle:nil
                                                                        image:[UIImage imageNamed:@"message_popup_withdraw"]
                                                             highlightedImage:nil
                                                                      onPress:^(NSObject *sender){
                                                                           [weakSelf.bubbleImage cancelMsg:nil];
                                                                      }];
                         
                         [menuArray addObject:withDrawItem];
                    }
               }
          }
          
          //回复
          GroupDataModel *pubGroup = self.chatViewController.group;
          if(record.msgDirection == MessageDirectionLeft && record.msgType == MessageTypeText && ![pubGroup isPublicGroup] && self.chatViewController.chatMode != ChatPublicMode && ([pubGroup isManager] || ![pubGroup slienceOpened]))
          {
               KDItem *replytem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_reply")
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"message_popup_reply"]
                                               highlightedImage:nil
                                                        onPress:^(NSObject *sender){
                                                             [weakSelf.bubbleImage reply:nil];
                                                        }];
               [menuArray addObject:replytem];
          }
          
          //标记
          if (![record.strEmojiType isEqualToString:@"original"]) {
               if (type != MessageTypeCancel && type != MessageTypeSpeech && type != MessageTypeLocation && type != MessageTypeShortVideo && type != MessageTypeCombineForward && ![pubGroup isPublicGroup] && self.chatViewController.chatMode != ChatPublicMode) {
                    KDItem *marktem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_mark")
                                                           subtitle:nil
                                                              image:[UIImage imageNamed:@"message_popup_mark"]
                                                   highlightedImage:nil
                                                            onPress:^(NSObject *sender){
                                                                 [weakSelf.bubbleImage mark:nil];
                                                                 
                                                            }];
                    [menuArray addObject:marktem];
               }
          }
          
          
          //根据后台参数判断是否可分享
          if ([group allowInnerShare] && [BOSConfig sharedConfig].user.partnerType != 1)
          {    // 转为任务
               if([self.bubbleImage canPerformAction:@selector(changeToTask:) withSender:self.bubbleImage])
               {
                    KDItem *changeToTaskItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_9")
                                                                    subtitle:nil
                                                                       image:[UIImage imageNamed:@"message_popup_task"]
                                                            highlightedImage:nil
                                                                     onPress:^(NSObject *sender){
                                                                          [weakSelf.bubbleImage changeToTask:nil];
                                                                     }];
                    
                    [menuArray addObject:changeToTaskItem];
               }
          }
          
          //zgbin:固定添加转为必达任务
          KDItem *changeToTaskItem = [[KDItem alloc] initWithTitle:@"转为必达任务"
                                                          subtitle:nil
                                                             image:[UIImage imageNamed:@"message_popup_task"]
                                                  highlightedImage:nil
                                                           onPress:^(NSObject *sender){
                                                                [weakSelf.bubbleImage changeToBidaTask:nil];
                                                                NSLog(@"%@", @"转为必达任务");
                                                           }];
          [menuArray addObject:changeToTaskItem];
          
          // 收藏
          if (![record.strEmojiType isEqualToString:@"original"]) {
               
               
               if([self.bubbleImage canPerformAction:@selector(collect:) withSender:self.bubbleImage])
               {
                    KDItem *collectItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_10")
                                                               subtitle:nil
                                                                  image:[UIImage imageNamed:@"message_popup_fav"]
                                                       highlightedImage:nil
                                                                onPress:^(NSObject *sender){
                                                                     [weakSelf.bubbleImage collect:nil];
                                                                }];
                    
                    if (type == MessageTypePicture)
                    {
                         MessageShareTextOrImageDataModel *paramObject = self.dataInternal.record.param.paramObject;
                         if(paramObject.fileId.length>0)
                         {
                              [menuArray addObject:collectItem];
                         }
                    }
                    else
                    {
                         [menuArray addObject:collectItem];
                    }
               }
          }
          
          // 转发
          {
               if (canForward)
               {
                    KDItem *forwardItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_7")
                                                               subtitle:nil
                                                                  image:[UIImage imageNamed:@"message_popup_forward"]
                                                       highlightedImage:nil
                                                                onPress:^(NSObject *sender){
                                                                     if (weakSelf.dataInternal.record.msgType == MessageTypeFile) {
                                                                          [weakSelf.bubbleImage forward:nil];
                                                                     }
                                                                     
                                                                     if (weakSelf.dataInternal.record.msgType == MessageTypeText
                                                                         || weakSelf.dataInternal.record.msgType == MessageTypeCombineForward) {
                                                                          [weakSelf.bubbleImage forwardText:nil];
                                                                     }
                                                                     
                                                                     if (weakSelf.dataInternal.record.msgType == MessageTypePicture) {
                                                                          [weakSelf.bubbleImage forwardPicture:nil];
                                                                     }
                                                                     
                                                                     if (weakSelf.dataInternal.record.msgType == MessageTypeNews || weakSelf.dataInternal.record.msgType == MessageTypeAttach) {
                                                                          [weakSelf.bubbleImage forwardNew:nil];
                                                                     }
                                                                     
                                                                     if (weakSelf.dataInternal.record.msgType == MessageTypeLocation) {
                                                                          [weakSelf.bubbleImage forwardLocation:nil];
                                                                     }
                                                                     
                                                                     if ( weakSelf.dataInternal.record.msgType == MessageTypeShortVideo) {
                                                                          [weakSelf.bubbleImage forwardShortVideo:nil];
                                                                     }
                                                                     
                                                                     if(weakSelf.dataInternal.record.msgType == MessageTypeShareNews)
                                                                     {
                                                                          [weakSelf forwardShareNews:nil];
                                                                     }
                                                                }];
                    
                    if (weakSelf.dataInternal.record.msgType == MessageTypeFile) {
                         if([self.bubbleImage canPerformAction:@selector(forward:) withSender:self.bubbleImage])
                              [menuArray addObject:forwardItem];
                    }
                    
                    if (weakSelf.dataInternal.record.msgType == MessageTypeText) {
                         if([self.bubbleImage canPerformAction:@selector(forwardText:) withSender:self.bubbleImage])
                              [menuArray addObject:forwardItem];
                    }
                    
                    if (weakSelf.dataInternal.record.msgType == MessageTypePicture) {
                         if([self.bubbleImage canPerformAction:@selector(forwardPicture:) withSender:self.bubbleImage])
                              [menuArray addObject:forwardItem];
                    }
                    
                    if (weakSelf.dataInternal.record.msgType == MessageTypeNews || weakSelf.dataInternal.record.msgType == MessageTypeAttach) {
                         if([self.bubbleImage canPerformAction:@selector(forwardNew:) withSender:self.bubbleImage])
                              [menuArray addObject:forwardItem];
                    }
                    if (weakSelf.dataInternal.record.msgType == MessageTypeLocation) {
                         if([self.bubbleImage canPerformAction:@selector(forwardLocation:) withSender:self.bubbleImage])
                              [menuArray addObject:forwardItem];
                    }
                    if (weakSelf.dataInternal.record.msgType == MessageTypeShortVideo) {
                         if([self.bubbleImage canPerformAction:@selector(forwardShortVideo:) withSender:self.bubbleImage])
                              [menuArray addObject:forwardItem];
                    }
                    
                    if(weakSelf.dataInternal.record.msgType == MessageTypeCombineForward
                       || weakSelf.dataInternal.record.msgType == MessageTypeShareNews)
                         [menuArray addObject:forwardItem];
                    
               }
          }
          
          
          // 分享
          if (![record.strEmojiType isEqualToString:@"original"]) {
               if ((canShare || canForward) && type != MessageTypePicture)
               {
                    //                    UIMenuItem *shareTo = [[UIMenuItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_11")action:@selector(shareToOther:)];
                    //                    [items addObject:shareTo];
                    
                    if([self.bubbleImage canPerformAction:@selector(shareToOther:) withSender:self.bubbleImage])
                    {
                         // 分享到
                         KDItem *shareToOtherItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_11")
                                                                         subtitle:nil
                                                                            image:[UIImage imageNamed:@"message_popup_share"]
                                                                 highlightedImage:nil
                                                                          onPress:^(NSObject *sender){
                                                                               [weakSelf.bubbleImage shareToOther:nil];
                                                                          }];
                         
                         [menuArray addObject:shareToOtherItem];
                    }
                    
                    if([BOSConfig sharedConfig].user.partnerType != 1 && canForward)
                    {
                         if([self.bubbleImage canPerformAction:@selector(shareToCommunity:) withSender:self.bubbleImage] && canForward)
                         {    // 分享到动态
                              KDItem *shareToCommunityItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_12")
                                                                                  subtitle:nil
                                                                                     image:[UIImage imageNamed:@"message_popup_share"]
                                                                          highlightedImage:nil
                                                                                   onPress:^(NSObject *sender){
                                                                                        [weakSelf.bubbleImage shareToCommunity:nil];
                                                                                   }];
                              
                              [menuArray addObject:shareToCommunityItem];
                         }
                    }
               }
          }
          
          //转发到轻应用
          if(self.dataInternal.record.msgType == MessageTypeText || self.dataInternal.record.msgType == MessageTypePicture)
          {
               if([[BOSSetting sharedSetting] msgMenuAppId])
               {
                    KDItem *forwardToLightAppItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_toLightApp")
                                                                         subtitle:nil
                                                                            image:[UIImage imageNamed:@"toApp"]
                                                                 highlightedImage:nil
                                                                          onPress:^(NSObject *sender){
                                                                               
                                                                               [MBProgressHUD showHUDAddedTo:weakSelf.chatViewController.view animated:YES];
                                                                               
                                                                               [weakSelf.mCloudClient getLightAppParamWithMid:[BOSConfig sharedConfig].user.eid appids:[[BOSSetting sharedSetting] msgMenuAppId] openToken:[BOSConfig sharedConfig].user.token urlParam:@""];
                                                                          }];
                    
                    [menuArray addObject:forwardToLightAppItem];
               }
          }
          
          //发送失败的消息只有删除菜单
          if(self.dataInternal.record.msgRequestState == MessageRequestStateFailue)
               [menuArray removeAllObjects];
          
          // 删除
          if([self.bubbleImage canPerformAction:@selector(deleteBubbleCell:) withSender:self.bubbleImage] || self.dataInternal.record.msgRequestState == MessageRequestStateFailue)
          {
               KDItem *deleteItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_13")
                                                         subtitle:nil
                                                            image:[UIImage imageNamed:@"message_popup_delete"]
                                                 highlightedImage:nil
                                                          onPress:^(NSObject *sender){
                                                               [weakSelf.bubbleImage deleteBubbleCell:nil];
                                                          }];
               
               [menuArray addObject:deleteItem];
          }
          
          //高亮
          [_bubbleImage setHighlighted:YES];
          //NSMutableArray * items = [NSMutableArray array];
          
          //          [_bubbleImage becomeFirstResponder];
          //          CGRect bubbleFrame = _bubbleImage.frame;
          //          bubbleFrame.origin.y += 5.0;
          
          return menuArray;
     }
     else if(popover == self.popoverPublic)
     {
          return self.popoverPublicItemArray;
     }
     
     return nil;
}


#define MARK_ALERT_TAG 12312389
- (void)mark:(id)sender {
     
     NSString *fileId = nil;
     if (self.dataInternal.record.msgType == MessageTypePicture) {
          MessageShareTextOrImageDataModel *paramObject = self.dataInternal.record.param.paramObject;
          fileId = paramObject.fileId;
     }
     
     __weak __typeof(self) weakSelf = self;
     
     [KDAlert showLoading];
     [[KDOpenAPIClientWrapper sharedInstance] createMark:1 messageId:self.dataInternal.record.msgId todoId:nil groupId:self.dataInternal.group.groupId appId:nil title: nil text:self.dataInternal.record.content url:nil fileId:fileId icon:nil completion:^(BOOL succ, NSString * error, id data) {
          [KDAlert hideLoading];
          if (succ) {
               [[KDUserDefaults sharedInstance] consumeFlag:kMarkUsed];
               if ([data isKindOfClass:[NSDictionary class]]) {
                    self.markModel = [[KDMarkModel alloc] initWithDict:data];
               }
               [self.chatViewController showMarkBanner];
               //               [KDAlert showAlert:MARK_ALERT_TAG title:@"已标记" message:@"是否需要提醒" delegate:self buttonTitles:@[@"否", @"是"]];
          } else {
               [KDAlert showToastInView:weakSelf.chatViewController.view text:error];
          }
     }];
}
- (void)viewOriginalMsg{
     NSString *messageID = [[KDChatReplyManager sharedInstance] paramModel:self.dataInternal.record].replyMsgId;
     if (!messageID)
          return;
     if (_chatViewController && [_chatViewController respondsToSelector:@selector(scrollReplyWithMsg:replyFlag:)]) {
          [_chatViewController scrollReplyWithMsg:messageID replyFlag:YES];
     }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     
     if (alertView.tag == MARK_ALERT_TAG) {
          
          if (buttonIndex == 0) {
               [KDMarkModel gotoH5Guide:self.chatViewController];
               return;
          }
          [KDMarkModel onSetEvent:self.chatViewController model:self.markModel];
     }
}

- (MCloudClient *)mCloudClient
{
     if (_mCloudClient == nil) {
          _mCloudClient = [[MCloudClient alloc] initWithTarget:self action:@selector(getLightAppParamDidReceived:result:)];
     }
     return _mCloudClient;
}

- (void)getLightAppParamDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
     [MBProgressHUD hideHUDForView:self.chatViewController.view animated:YES];
     
     if (result.success && result.data && [result.data isKindOfClass:[NSArray class]])
     {
          NSArray *data = (NSArray *)result.data;
          self.msgToLightAppArray = data;
          
          //显示转到应用菜单
          [self showMsgToLightAppActionSheet];
          return;
     }
     [KDErrorDisplayView showErrorMessage:result.error inView:self.chatViewController.view];
}

-(void)showMsgToLightAppActionSheet
{
     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_toLightApp") delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") destructiveButtonTitle:nil otherButtonTitles:nil];
     for(NSUInteger i = 0;i < self.msgToLightAppArray.count;i++)
     {
          NSString *name = [self.msgToLightAppArray[i] objectForKey:@"name"];
          if(name)
               [actionSheet addButtonWithTitle:name];
     }
     actionSheet.tag = 999;
     actionSheet.delegate = self;
     [actionSheet showInView:self.chatViewController.view];
}

- (XTCloudClient *)xtCloudclient
{
     if (_xtCloudclient == nil) {
          _xtCloudclient = [[XTCloudClient alloc]init];
          //          _xtCloudclient.delegate = self;
     }
     return _xtCloudclient;
}

- (NSString *)videoSize:(NSString *)size
{
     NSString *result = @"";
     if (size.intValue / 1024 >= 1024) {
          result = [NSString stringWithFormat:@"%.2fMB", size.floatValue / 1024 / 1024];
     }else {
          result = [NSString stringWithFormat:@"%dKB", (int)size.intValue / 1024];
     }
     return result;
}

- (NSAttributedString *)attributedstringWithImageName:(NSString *)imageName content:(NSString *)content textColor:(UIColor*)textColor{
     NSMutableAttributedString *attri = [NSMutableAttributedString attributedStringWithString:content];
     [attri dz_setFont:[UIFont systemFontOfSize:8]];
     [attri dz_setTextColor:textColor];
     
     if ([KDString isSolidString:imageName]) {
          [attri dz_insertImageWithName:imageName location:0 bounds:CGRectMake(0, -2, 10, 10)];
     }
     
     return attri;
}

- (void)setTempPerson:(PersonSimpleDataModel *)tempPerson
{
     //     if (!tempPerson) {
     _tempPerson = tempPerson;
     //     }
}

- (KDUserHelper *)userHelper
{
     if (_userHelper == nil) {
          _userHelper = [[KDUserHelper alloc]init];
     }
     return _userHelper;
}
@end

