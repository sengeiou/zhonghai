//
//  ChatViewController.h
//  ContactsLite
//
//  Created by Gil on 12-11-27.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BOSAudioRecorder.h"
#import "MBProgressHUD.h"
#import "BubbleImageView.h"
#import "XTRecorderView.h"
#import "XTMyFilesViewController.h"
#import "XTForwardDataModel.h"
#import "MBProgressHUD.h"
#import "XTChooseContentViewController.h"
#import "XTPersonHeaderView.h"
#import "KDCommunityShareView.h"
#import "SZTextView.h"
#import "XTDataBaseDao.h"


//位置相关
#import "KDLocationView.h"
#import "KDLocationOptionViewController.h"
#import "KDLocationManager.h"
#import "KDLocationData.h"
#import "UIImage+Additions.h"
#import "KDPicturePickedPreviewViewController.h"

#import "XTCloudClient.h"
#import "KDAttachment.h"
#import "XTQRScanViewController.h"


// 系统相册最近一张照片，用来判断是否有照片更新
#define kMostRecentPhoto @"kMostRecentPhoto"
// 聊天加号面板加号上的红点
#define kChatPlusMenuRedFlag @"kChatPlusMenuRedFlag"

#define NUMBER_OF_RECORDS_PER_PAGE 20 // 分页页数
#define TEMP_NUMBER_OF_RECORDS_PER_PAGE 50 // 临时分页页数, 在跳转中使用

typedef enum _ChatMode{
    ChatPrivateMode = 1,//私人模式
    ChatPublicMode = 2,//公共帐号模式
    KDChatModeMultiCall = 3//多方通话
}ChatMode;

// 特殊消息发送模式
typedef enum : NSUInteger {
    KDChatMessageModeNone,          // 正常模式
    KDChatMessageModeImportant,     // 重要消息
    KDChatMessageModeReply,         // 回复消息
    KDChatMessageModeNotrace,       // 无痕消息
} KDChatMessageMode;

@class MJPhotoBrowser;
@class ContactClient;
@class PersonSimpleDataModel;
@class GroupDataModel;
@class PubAccountDataModel;
@class MessageTypeNewsEventsModel;
@protocol SendFileDelegate;
@class BubbleTableViewCell;
@class KDNoticeController;
static NSInteger const KDstartGroupTalkAlertTag = 30001;

@interface XTChatViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,BOSAudioRecorderDelegate,UIAlertViewDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,BubbleImageViewDelegate,SendFileDelegate,MBProgressHUDDelegate,XTChooseContentViewControllerDelegate,UIScrollViewDelegate,XTPersonHeaderViewLongPressDelegate,KDCommunityShareViewDelegate,KDLocationOptionViewControllerDelegate,KDCloudAPIDelegate>
{
    BOSAudioRecorder *_audioRecoder;
    int _recordSeconds;
    float _realRecordSeconds;
    NSTimeInterval _recordStartTime;
    BOOL _isRecording;
    BOOL _isCancelRecording;
    
    ContactClient *_requestClient;
    
    ContactClient *_inviteClient;
    
}

@property(nonatomic, strong) XTShareDataModel *shareDataModel;

//用来判断要不要改变输入框的位置  --- alanwong
@property(nonatomic,assign) BOOL shouldChangeTextField;

//初始化数据
@property (nonatomic,strong) GroupDataModel *group;
@property (nonatomic,strong) PubAccountDataModel *pubAccount;
@property (nonatomic,strong) PersonSimpleDataModel *detailPerson;
@property (nonatomic,assign) ChatMode chatMode;

//UI
//ToolBar
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UIImageView *toolbarImageView;
@property (nonatomic, assign) CGFloat toolbarImageViewStartY;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) SZTextView *contentView;
@property (nonatomic, assign) BOOL keyboardShow;
//Input
@property (nonatomic, strong) UIImageView *inputBoardBGView;
@property (nonatomic, assign) CGFloat inputBoardStartY;
@property (nonatomic, assign) BOOL inputBoardShow;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *fileButton;
@property (nonatomic, strong) UIButton *emojiButton;
@property (nonatomic, strong) UIButton *voiceButton;
//Emoji
//@property (nonatomic, strong) UIImageView *emojiBoardBGView;
//@property (nonatomic, assign) CGFloat emojiBoardStartY;
@property (nonatomic, assign) BOOL emojiBoardShow;
//@property (nonatomic, strong) UIScrollView *emojiScrollView;
//@property (nonatomic, strong) UIPageControl *pageControl;
//@property (nonatomic, strong) UIImageView *buttomSendBarView;
//@property (nonatomic, strong) UIButton *sendButton;
//Table
@property (nonatomic, assign) CGFloat bubbleTableStartHeight;
@property (nonatomic, strong) UITableView *bubbleTable;
//录音视图
@property (nonatomic, strong) MBProgressHUD *recordingHud;
@property (nonatomic, strong) XTRecorderView *recordingView;
@property (nonatomic, assign) BOOL isRecordCancel;
//文件
@property (nonatomic, assign) BOOL isSendingFile;
@property (nonatomic, assign) BOOL isForward;  //是否转发
@property (nonatomic, strong) id forwardDM;

@property (nonatomic, strong) UIButton *getPasswordButton;
//menu
@property (nonatomic, strong) UIImageView *toolbarMenuview;
@property (nonatomic, strong) UIImageView *personimage;
@property (nonatomic, strong) UIImageView *itimage;
@property (nonatomic, strong) UIImageView *otherimage;
@property (nonatomic, strong) UIButton*keyBoardBtn;
@property (nonatomic, assign) BOOL menukeyboard;
@property (nonatomic, assign) BOOL ispublic;
//判断有木有配置菜单
@property (nonatomic, assign) BOOL ismenushow;
//事件发送中
@property (nonatomic, assign) BOOL issending;
@property (nonatomic, strong) NSMutableArray*menuarray;
@property (nonatomic, strong) NSMutableArray*menufirst;
@property (nonatomic, strong) NSMutableArray*menusecond;
@property (nonatomic, strong) NSMutableArray*menuthird;
@property (nonatomic, strong) UIView*noticeview;

@property (assign, nonatomic) BOOL isHistory;

@property (nonatomic, strong) NSMutableArray *mArrayNotifyRecords;
@property (nonatomic, strong) MJPhotoBrowser *browser;

@property (strong, nonatomic) NSString *strScrollToMsgId; // if not null, scroll to the cell
@property (assign, nonatomic) BOOL multiselecting; // 表示是否处于多选模式
@property (strong, nonatomic) NSIndexPath *selectMenuCellIndexPath; //弹出菜单的按钮索引
@property (nonatomic, strong) UIImageView *multiselectActionView;//多选模式操作菜单
@property (nonatomic, strong) UIButton *cancelMultiselectBtn;//取消多选按钮
@property (nonatomic, strong) UIButton *multiselectActionBtn;//发送多选按钮
@property (nonatomic, strong) UIButton *combinForwardActionBtn;//合并转发按钮
@property (nonatomic, strong) NSMutableArray *multiselectArray;//多选模式操作数组
@property (nonatomic, assign) int multiseSelctMode;//多选模式,0为删除，1为转发
// 重要消息
@property(nonatomic, assign) BOOL bImportantMessageMode;

// 自动进入搜索页面
@property(nonatomic, assign) BOOL bSearchingMode;

// 为了recordTimeline多次调用时，不再提示未读消息提醒按钮
@property(nonatomic, assign) int iUnreadMessageCount;
@property(nonatomic, strong) NSString *strFirstUnreadMessageMsgId;
// 未读消息提醒， xxx条新消息 按钮
@property(nonatomic, strong) UIButton *buttonUnreadMessage;



//位置相关
@property (nonatomic, strong)NSArray *locationDataArray;
@property (nonatomic, strong) KDLocationData *currentLocationData;


@property (nonatomic, assign) KDChatMessageMode messageMode;//发送消息模式
@property (nonatomic, strong) RecordDataModel *replyRecord; // 要回复的msg
@property (nonatomic, strong) NSMutableArray *mArrayRecordsFromMsgList;
@property (nonatomic, strong) NSMutableArray *mArrayRecordsFromMsgListRaw;

//表格数据
@property(nonatomic, strong) NSMutableArray *recordsList;
@property(nonatomic, strong) NSMutableArray *bubbleArray;

//代办跳转进来的
@property(nonatomic, strong) BubbleDataInternal *todoBdi;

@property (nonatomic,strong) XTCloudClient *client;

@property (nonatomic, copy) NSString *cancelMsgId ;//为保存消息回撤请求完成后删除本地消息使用
@property (nonatomic, strong) BubbleTableViewCell *cancelMsgCell ;//为保存消息回撤请求完成后刷新页面

// XTChooseContentCreate创建组后是否立刻唤起语音会议
@property(nonatomic, assign) BOOL bGoMultiVoiceAfterCreateGroup;

//图片
@property (nonatomic, assign) BOOL isSendingImage;

@property(nonatomic, strong) UITapGestureRecognizer *noticeBoxTapGesture;
@property(nonatomic, strong) KDNoticeController *noticeController;
@property(nonatomic, weak) KDSheet *socialShareSheet;

//埋点 发送到电脑不统计加号
@property (nonatomic, assign) BOOL fromTimeLie;

//从会话列表中进入使用此方法进行初始化
//pubAccount（私人模式下传入nil）
-(id)initWithGroup:(GroupDataModel *)group pubAccount:(PubAccountDataModel *)pubAccount mode:(ChatMode)mode;
//从搜索列表进入,使用此方法进行初始化（私人模式）
-(id)initWithParticipant:(PersonSimpleDataModel *)participant;
//直接与公共帐号对话,使用此方法进行初始化（私人模式）
-(id)initWithPubAccount:(PubAccountDataModel *)pubAccount;
-(id)initWithParticipant2:(PersonSimpleDataModel *)participant;
- (void)sendWithRecord:(RecordDataModel *)record;
- (void)sendWithRecord:(RecordDataModel *)record image:(UIImage *)image;

- (void)handleEventModel:(MessageTypeNewsEventsModel *)event;
-(void)scrollRowByRecord:(RecordDataModel *)recordData;
- (void)hideInputBoard;
- (void)changeMessageModeTo:(KDChatMessageMode)mode;
- (NSString * _Nullable)personNameWithGroup:(GroupDataModel * _Nullable)group record:(RecordDataModel * _Nullable)record;
- (void)scrollReplyWithMsg:(NSString *)messageID replyFlag:(BOOL)flag;

-(void)reloadData;

- (void)getOnePageFromDBWithMsgId:(NSString *)msgId
               recordCountPerPage:(int)recordCountPerPage
                        direction:(MessagePagingDirection)direction
                       completion:(void(^)(NSArray *records))completionBlock;


- (NSInteger)getMutiChatGroupParticipantCount;
- (void)fetchDataFromNet:(NSString *)msgId;

- (void)playVideo:(NSString *) file;

- (void)showMarkBanner ;
-(RecordDataModel *)findMsgId:(NSString *)msgId inRecords:(NSMutableArray *)records;
- (void)deleteCancelCell;

- (void)goToMultiVoice;
- (void)goToImageEditorWithImage:(UIImage *)image;
- (void)handleImage:(UIImage *)image savedPhotosAlbum:(BOOL)savedPhotosAlbum withLibUrl:(NSString *)libUrl;


- (void)hideNoticeView; //隐藏[消息收取中]
- (void)setupRightNavigationItem;


-(NSMutableArray *)getMultiselectArray;//获得多选数组
@end
