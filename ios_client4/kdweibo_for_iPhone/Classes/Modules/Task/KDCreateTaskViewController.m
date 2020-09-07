//
//  KDCreateTaskViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 13-7-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDCreateTaskViewController.h"
#import "KDFrequentContactsPickViewController.h"
#import "KDUser.h"
#import "KDDatePickerViewController.h"
#import "KDTaskShareViewController.h"
#import "NSDate+Additions.h"
#import "KDGroup.h"
#import "KDDMMessage.h"
#import "KDCommentStatus.h"
#import "HPGrowingTextView.h"
#import "KDExpressionInputView.h"
#import "KDPostActionMenuView.h"
#import "KDTrendEditorViewController.h"
#import "TwitterText.h"
#import "KDWeiboServicesContext.h"
#import "KDErrorDisplayView.h"
#import "NSDictionary+Additions.h"
#import "MBProgressHUD.h"
#import "KDUtility.h"
#import "HPGrowingTextView.h"
#import "KDNotificationView.h"
#import "UIViewAdditions.h"
#import "KDTaskEditorView.h"
#import <QuartzCore/QuartzCore.h>
#import "BOSConfig.h"
#import "XTChooseContentViewController.h"


#define KD_TODOLIST_RELOAD_NOTIFICATION         @"kd_todolist_reload_notification"

@interface KDTaskItemCell : UITableViewCell
@property(nonatomic,retain)UILabel *leftLabel;
@property(nonatomic,retain)UILabel *rightLabel;
@property(nonatomic,retain)UIImageView *accessoryImageView;
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UIView  *backgroundView;
@property(nonatomic,retain)UIView  *highlightedView;
@end

@implementation KDTaskItemCell

@synthesize leftLabel = leftLabel_;
@synthesize rightLabel = rightLabel_;
@synthesize accessoryImageView = accessoryImageView_;
@synthesize iconImageView = iconImageView_;
@synthesize backgroundView = backgroundView_;
@synthesize highlightedView = highlightedView_;
- (void)dealloc {
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(leftLabel_);
    //KD_RELEASE_SAFELY(rightLabel_);
    //KD_RELEASE_SAFELY(accessoryImageView_);
    //KD_RELEASE_SAFELY(highlightedView_);
    //[super dealloc];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y > CGRectGetMaxY(self.backgroundView.frame)) {
        return NO;
    }else {
        return [super pointInside:point withEvent:event];
    }
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
//        UIImage *bgImg = [UIImage imageNamed:@"todo_bg"];
//        bgImg = [bgImg stretchableImageWithLeftCapWidth:bgImg.size.width/2.0f topCapHeight:bgImg.size.height/2.0f];
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.frame];// autorelease];
        backgroundView_.userInteractionEnabled = YES;
        [self addSubview:backgroundView_];
        
        highlightedView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:highlightedView_];

        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:iconImageView_];
        
        leftLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        leftLabel_.backgroundColor = [UIColor clearColor];
        leftLabel_.font = [UIFont systemFontOfSize:16];
        leftLabel_.textColor = FC1;
        [backgroundView_ addSubview:leftLabel_];
        
        rightLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        rightLabel_.backgroundColor = [UIColor clearColor];
        rightLabel_.font = [UIFont systemFontOfSize:14];
        rightLabel_.textColor = FC2;
        [backgroundView_ addSubview:rightLabel_];
        rightLabel_.textAlignment = NSTextAlignmentRight;
        
        accessoryImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3."]];
        [backgroundView_ addSubview: accessoryImageView_];
        
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    
    frame.origin.x = 7.0f;
    frame.size.width -= 2*7;
    backgroundView_.frame = frame;
    highlightedView_.frame = CGRectInset(backgroundView_.bounds, 0.5f, 0.5f);
    
    if (iconImageView_.image) {
        [iconImageView_ sizeToFit];
        frame = iconImageView_.bounds;
        frame.origin.x = 6.0f;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        iconImageView_.frame = frame;
       
    }
    
    if (leftLabel_.text) {
        [leftLabel_ sizeToFit];
        frame = leftLabel_.bounds;
        frame.origin.x = CGRectGetMaxX(iconImageView_.frame) + 10.0f;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        frame.size.width = 100;
        leftLabel_.frame = frame;
       
    }
    
    if (rightLabel_.text) {
        [rightLabel_ sizeToFit];
        frame = rightLabel_.bounds;
        CGFloat width = MIN(CGRectGetWidth(rightLabel_.frame), 140);
        frame.origin.x = CGRectGetWidth(self.bounds) -width- 25 - 14;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        frame.size.width = width;
        rightLabel_.frame = frame;
        
    }
    if (accessoryImageView_.image) {
        [accessoryImageView_ sizeToFit];
        frame = accessoryImageView_.bounds;
        frame.origin.x = CGRectGetWidth(self.bounds)- CGRectGetWidth(accessoryImageView_.frame) -10 - 14;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        accessoryImageView_.frame = frame;
    }
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    // Configure the view for the selected state
    highlightedView_.backgroundColor = highlighted?[UIColor colorWithRed:240/255.0 green:241/255.0 blue:242/255.f alpha:1.0f]:[UIColor clearColor];
    accessoryImageView_.image = highlighted?[UIImage imageNamed:@"smallTriangle"]:[UIImage imageNamed:@"profile_edit_narrow_v3"];
}
@end

@interface KDTaskReminadMeItemCell : KDTaskItemCell

@property(nonatomic,retain)UIButton *lastDayBtn;
@property(nonatomic,retain)UIButton *thatDayBtn;
@property(nonatomic,retain)UIButton *noneBtn;
@property(nonatomic,retain)UIImageView *horizontalSeparator;
@property(nonatomic,retain)UIImageView *verticalSeparator1;
@property(nonatomic,retain)UIImageView *verticalSeparator2;
@end

@implementation KDTaskReminadMeItemCell
@synthesize lastDayBtn = lastDayBtn_;
@synthesize thatDayBtn = thatDayBtn_;
@synthesize noneBtn = noneBtn_;


- (UIButton *)dayBtnWithTitle:(NSString *)title {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.backgroundColor = [UIColor grayColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   
    [button setImageEdgeInsets:UIEdgeInsetsMake(50, 30, 0, 0)];
    [button setImage:[UIImage imageNamed:@"icon_task_day_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_task_day_selected"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        lastDayBtn_.selected = (btn == lastDayBtn_);
        thatDayBtn_.selected = (btn == thatDayBtn_);
        noneBtn_.selected = (btn == noneBtn_);
    }
}

- (NSInteger)indexOfSelected {
    NSInteger index = NSNotFound;
    if(lastDayBtn_.selected) {
        index = 0;
    }else if(thatDayBtn_.selected) {
        index = 1;
    }else {//
        index = 2;
    }
    return index;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        lastDayBtn_ = [self dayBtnWithTitle:ASLocalizedString(@"KDCreateTaskViewController_lastday")];// retain];
         [lastDayBtn_ setTitleEdgeInsets:UIEdgeInsetsMake(-35, -25, 0, 0)];
        lastDayBtn_.backgroundColor = [UIColor redColor];
        [self addSubview:lastDayBtn_];
        
        thatDayBtn_ = [self dayBtnWithTitle:ASLocalizedString(@"KDCreateTaskViewController_today")];// retain];
        [thatDayBtn_ setTitleEdgeInsets:UIEdgeInsetsMake(-35, -28, 0, 0)];
        [self addSubview:thatDayBtn_];
        
        noneBtn_ = [self dayBtnWithTitle:ASLocalizedString(@"KDCreateTaskViewController_none")];// retain];
        [noneBtn_ setTitleEdgeInsets:UIEdgeInsetsMake(-35, -20, 0, 0)];
        [self addSubview:noneBtn_];
        
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.origin.y = 40;
    frame.size.height = CGRectGetHeight(frame)-40-10;
    frame.size.width = CGRectGetWidth(frame)*0.34;
    lastDayBtn_.frame = frame;
    
    frame.origin.x = CGRectGetMaxX(frame);
    thatDayBtn_.frame = frame;
    
    frame.origin.x = CGRectGetMaxX(frame);
    noneBtn_.frame = frame;
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(lastDayBtn_);
    //KD_RELEASE_SAFELY(thatDayBtn_);
    //KD_RELEASE_SAFELY(noneBtn_);
    //[super dealloc];
}
@end


@interface KDCreateTaskViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,KDTaskShareViewControllerDelegate,KDFrequentContactsPickViewControllerDelegate, HPGrowingTextViewDelegate,KDTrendEditorViewControllerDelegate,KDExpressionInputViewDelegate,KDPostActionMenuViewDelegate, KDUserPortraitDelegate,XTChooseContentViewControllerDelegate> {
    BOOL isExpressionViewShown;
    NSRange caret;
    NSRange textRange;
    struct {
        unsigned int isExpressionViewShow:1;
        unsigned int isViewDidUnload:1;
        unsigned int init:1;
        unsigned int isCreatingTask:1;
        unsigned int isUpdatingTask:1;
        unsigned int initInputView:1;
    }flag_;
    CGFloat textViewHeight;
}

@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)UITableViewCell *inputCell;
@property(nonatomic,retain)UITableViewCell *refrCell;
@property(nonatomic,retain)UserPortraitGroupCell *exectorCell;
@property(nonatomic,retain)KDTaskItemCell *needFinishDateCell;
@property(nonatomic,retain)KDTaskItemCell *shareRangeCell;
@property(nonatomic,retain)KDTaskReminadMeItemCell *remindCell;
@property(nonatomic,retain)UITableViewCell *remindDayCell;
@property(nonatomic,retain)HPGrowingTextView *textView;
@property(nonatomic,retain)UILabel *refrLabel;
@property(nonatomic,retain)UILabel *wordLimitLabel;

@property(nonatomic,retain)UITableViewCell *submitBtnCell;
@property(nonatomic,retain)NSArray *exectors;
@property(nonatomic,retain)NSDate *needFinishDate;
@property(nonatomic,retain)KDDatePickerViewController *datePicker;
@property(nonatomic,retain)NSDictionary *shareRangeTaskDic;
@property(nonatomic,retain)KDPostActionMenuView *actionMenuView;
@property(nonatomic,retain)KDExpressionInputView *expressionInputView;
@property(nonatomic,copy)NSString *contentBackup;

@property(nonatomic,strong)XTChooseContentViewController *exectorsContentVC;
//@property(nonatomic,retain)KDFrequentContactsPickViewController *atSomeOneVC;

@end

@implementation KDCreateTaskViewController
@synthesize tableView =  tableView_;
@synthesize inputCell = inputCell_;
@synthesize refrCell = refrCell_;
@synthesize exectorCell = exectorCell_;
@synthesize needFinishDateCell = needFinishDateCell_;
@synthesize shareRangeCell = shareRangeCell_;
@synthesize remindCell = remindCell_;
@synthesize remindDayCell =remindDayCell_;
@synthesize textView = textView_;
@synthesize refrLabel = refrLabel_;
@synthesize wordLimitLabel = wordLimitLabel_;
@synthesize submitBtnCell  = submitBtnCell_;
@synthesize exectors = exectors_;
@synthesize needFinishDate = needFinishDate_;
@synthesize datePicker = datePicker_;
@synthesize shareRangeTaskDic = shareRangeTaskDic_;
@synthesize actionMenuView = actionMenuView_;
@synthesize expressionInputView = expressionInputView_;
@synthesize contentBackup = contentBackup_;
@synthesize referObject = referObject_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:  UIKeyboardDidHideNotification
                                             object:nil];
        flag_.isExpressionViewShow = 0;
        flag_.isViewDidUnload = 0;
        flag_.init = 1;
        flag_.initInputView = 1;
        
        self.shareRangeTaskDic = @{@"range":ASLocalizedString(@"KDCreateTaskViewController_private")};
        self.needFinishDate = [NSDate date];
//        KDUser *currentUser = [[KDUtility defaultUtility] currentUser];
//        if (currentUser) {
//             self.exectors = @[currentUser];
//        }
        self.exectors = nil;
    }
    return self;
}

- (void)setReferObject:(id)referObject {
    if (referObject != referObject_) {
//        [referObject_ release];
        referObject_ = referObject;// retain];
        if ([referObject_ isKindOfClass:[KDStatus class]]) {
            self.contentBackup = ((KDStatus*)referObject_).text;
        }else if ([referObject_ isKindOfClass:[KDDMMessage class]]) {
            self.contentBackup = [(KDDMMessage *)referObject_ message];
        }
        else if ([referObject_ isKindOfClass:[RecordDataModel class]]){
            self.contentBackup = [(RecordDataModel *)referObject_ content];
        }
    }
}

- (void)loadView {
    [super loadView];
    CGRect frame = self.view.bounds;
    //frame.size.height -= 44.0f+20.f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f)
        frame.size.height += 20.f;
 
    tableView_ = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView_.separatorColor = [UIColor kdBackgroundColor1];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableView_.backgroundColor = [UIColor kdBackgroundColor2];
   
    [self.view addSubview:tableView_];
    tableView_.dataSource = self;
    tableView_.delegate = self;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
//    [recognizer release];
    

    frame.origin = CGPointMake(0, 32);
    //frame.size.width -= 2*7;
    frame.size.height = 30;
    
    textView_ = [[HPGrowingTextView alloc] initWithFrame:frame];
    textView_.contentInset = UIEdgeInsetsMake(5, 10, 5, 10);
   
	textView_.minNumberOfLines = 3;
	textView_.maxNumberOfLines = 5;
    
    if (![UIDevice isRunningOveriPhone5])
        textView_.maxNumberOfLines = 4;
    
	//textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView_.internalTextView.inputAccessoryView = [self actionMenuView];
	textView_.font = [UIFont systemFontOfSize:15.0f];
	textView_.growingDelegate = self;
    textView_.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    textView_.backgroundColor = [UIColor kdBackgroundColor2];
    textView_.internalTextView.backgroundColor = [UIColor clearColor];
    textView_.scrollEnabled = NO;
    [tableView_ addSubview:textView_];
    textViewHeight = CGRectGetHeight(textView_.bounds);

    wordLimitLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(textView_.bounds.size.width - 65, CGRectGetHeight(textView_.frame)-7+32, 80, 18)];
    wordLimitLabel_.backgroundColor = [UIColor clearColor];
    wordLimitLabel_.font = [UIFont systemFontOfSize:12.0];
    wordLimitLabel_.textAlignment = NSTextAlignmentCenter;
    wordLimitLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [textView_.superview addSubview:wordLimitLabel_];
    
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont systemFontOfSize:15];
//    label.textColor = MESSAGE_NAME_COLOR;
//    label.text = ASLocalizedString(@"KDCreateTaskViewController_content");
//    tableView_.tableHeaderView = [label autorelease];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [KDWeiboAppDelegate setExtendedLayout:self];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];

//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateNormal];
//    [cancelBtn setImage:[UIImage imageNamed:@"navigationItem_back.png"] forState:UIControlStateHighlighted];
//    [cancelBtn addTarget:self action:@selector(navigationLeftBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [cancelBtn sizeToFit];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [confirmBtn setImage:[UIImage imageNamed:@"navigationItem_title_arrow"] forState:UIControlStateNormal];
//    [confirmBtn setImage:[UIImage imageNamed:@"navigationItem_title_arrow"] forState:UIControlStateHighlighted];
    [confirmBtn addTarget:self action:@selector(submitBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [confirmBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
//    [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -35, 0, 0)];
    [confirmBtn setTitle:ASLocalizedString(@"KDCreateTaskViewController_create")forState:UIControlStateNormal];
    [confirmBtn setTitleColor:FC5 forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont fontWithName:nil size:16];
    [confirmBtn sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:confirmBtn];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer,rightItem, nil];
//    [rightItem release];
    
    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_Cancel")];
    [backBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:leftItem, nil];
//    [leftItem release];
    
//    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
//    //2013-12-26 song.wang
//    UIBarButtonItem *negativeSpacer1 = [[[UIBarButtonItem alloc]
//                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                        target:nil action:nil] autorelease];
//    negativeSpacer1.width = kLeftNegativeSpacerWidth;
//    self.navigationItem.leftBarButtonItems = [NSArray
//                                              arrayWithObjects:negativeSpacer1,leftItem, nil];
//    [leftItem release];
    
    


}

- (void)dismissSelf {
    
    
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)navigationLeftBtnTapped:(id)sender {

     [self dismissSelf]; 
}

- (void)initInputTextView {
    if(flag_.initInputView == 1 ||flag_.isViewDidUnload == 1){
        flag_.initInputView = 0;
        flag_.isViewDidUnload = 0;
        if (contentBackup_ ) {
             textView_.text = contentBackup_;
        }
        
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initInputTextView];
    [self updateWordLimitsLabel];
    [self updateExectorCell];
    [self updateNeedFinishDateCell];
    [self updateTaskshareCell];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [super viewDidUnload];
    flag_.isViewDidUnload = 1;
    if([textView_.internalTextView hasText]){
        self.contentBackup = [textView_.internalTextView text];
    }
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = nil;
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(inputCell_);
    //KD_RELEASE_SAFELY(refrCell_);
    //KD_RELEASE_SAFELY(exectorCell_);
    //KD_RELEASE_SAFELY(needFinishDateCell_);
    //KD_RELEASE_SAFELY(remindCell_);
    //KD_RELEASE_SAFELY(remindDayCell_);
    //KD_RELEASE_SAFELY(textView_);
    //KD_RELEASE_SAFELY(refrLabel_);
    //KD_RELEASE_SAFELY(datePicker_);
    //KD_RELEASE_SAFELY(actionMenuView_);
    //KD_RELEASE_SAFELY(expressionInputView_);
}
- (void)updateNeedFinishDateCell {
    if (!self.needFinishDate) {
        return;
    }
    self.needFinishDateCell.rightLabel.text = [self.needFinishDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];

    [self.needFinishDateCell setNeedsLayout];
}

- (void)updateTaskshareCell {
    if (!shareRangeTaskDic_) {
        return;
    }
    NSString *range = [shareRangeTaskDic_ objectForKey:@"range"];
    
    if (range) {
        KDGroup *group = [shareRangeTaskDic_ objectForKey:@"group"];
        if (group) {
            range = [range stringByAppendingFormat:@"(%@)",group.name];
        }
        shareRangeCell_.rightLabel.text = range;
        [shareRangeCell_ setNeedsLayout];
    }
}

#pragma mark - Private Methods 
- (NSString *)groupId {
    NSDictionary *shareDic = self.shareRangeTaskDic;
    KDGroup *group = [shareDic objectForKey:@"group"];
    return group.groupId;
}

- (NSString *)shareRange {
    NSString *resultStr = nil;
    NSDictionary *shareDic = self.shareRangeTaskDic;
    NSString *range = [shareDic objectForKey:@"range"];
    if ([range isEqualToString:ASLocalizedString(@"KDCreateTaskViewController_private")]) {
        resultStr = @"private";
    }
    return resultStr;
}

- (NSString *)executorsIds{
    
    NSUInteger count = (self.exectors != nil) ? [self.exectors count] : 0;
    if(count < 0x01) return @"";
    
    NSMutableString *IDs = [NSMutableString string];
    NSUInteger idx = 0;
    for(PersonSimpleDataModel *item in self.exectors){
        [IDs appendString:item.wbUserId];
        if(idx++ != (count - 1)){
            [IDs appendString:@","];
        }
    }
    return IDs;
}

- (BOOL)isInputValidateWithMessage:(NSString **)message {
    //self.exectors = [exectorCell_.groupView getCurrentUsers];
    int remainingCount = [TwitterText remainingCharacterCount:[self stringTobeCounted]];
    BOOL validate = YES;
    if (remainingCount == KD_MAX_WEIBO_TEXT_LENGTH) {
        validate = NO;
        *message = ASLocalizedString(@"KDCreateTaskViewController_tips_empty");
    }
    else if(remainingCount <0)
    {
        validate = NO;
        *message = ASLocalizedString(@"KDCreateTaskViewController_tips_over");
    }
    else if(!exectors_||[exectors_ count] <1) {
        validate = NO;
        *message = ASLocalizedString(@"KDCreateTaskViewController_choice_member");
        
    }else if(!self.shareRangeTaskDic) {
        validate = NO;
        *message = ASLocalizedString(@"KDCreateTaskViewController_choice_share");
        
    }else if(!self.needFinishDate) {
        validate = NO;
        *message = ASLocalizedString(@"KDCreateTaskViewController_choice_date");
    }
    return validate;
}

- (NSString *)refStr {
    NSString *returnStr = nil;
    if (referObject_) {
        if ([referObject_ isKindOfClass:[KDStatus class]]) {
            KDStatus *status = (KDStatus *)referObject_;
            returnStr =[NSString stringWithFormat:@"%@:%@",status.author.screenName,status.text];
        }else if([referObject_ isKindOfClass:[KDDMMessage class]]) {
            KDDMMessage *message = (KDDMMessage *)referObject_;
            returnStr = [NSString stringWithFormat:@"%@:%@",message.sender.screenName,message.message];
        }
        else if([referObject_ isKindOfClass:[RecordDataModel class]]){
        
            RecordDataModel *record = (RecordDataModel *)referObject_;
            returnStr = [NSString stringWithFormat:@"%@:%@",record.username,record.content];
        }
    }
    return returnStr;
}

- (void)shouldCreateTask {
    NSString *message;
    if (![self isInputValidateWithMessage:&message]) {
        if (message) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alertView show];
//            [alertView release];
        }
    }else {
        [self createTask];
    }
}

- (void)createTask {
    if(flag_.isCreatingTask == 1) {
        return;
    }
    flag_.isCreatingTask = 1;
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
   
    NSString *actionPath = nil;
    KDQuery *query = [KDQuery query];
    [query setParameter:@"content" stringValue:textView_.text];
    [query setParameter:@"needFinishDate" stringValue: [self.needFinishDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER]];
    [query setParameter:@"groupId" stringValue:[self groupId]];
    NSString *visibility = [self shareRange];
    if (visibility) {
        [query setParameter:@"visibility" stringValue:visibility];
    }
    [query setParameter:@"executors" stringValue:[self executorsIds]];
    
    if (referObject_) { //转为taskcc
        if (self.referType == KDCreateTaskReferTypeComment) { //评论
            KDCommentStatus *status = (KDCommentStatus *)referObject_;
            [query setParameter:@"commentId" stringValue:status.statusId];
            actionPath = @"/task/:convertWithComment";
        }else if(self.referType == KDCreateTaskReferTypeDMMessge) { //短邮
            KDDMMessage *message = (KDDMMessage *)referObject_;
            [query setParameter:@"messageId" stringValue:message.messageId];
            actionPath = @"/task/:convertWithDirectMessage";
            
            
        }else if(self.referType == KDCreateTaskReferTypeStatus){ //微博
            KDStatus *status = (KDStatus *)referObject_;
            [query setParameter:@"microblogId" stringValue:status.statusId];
            actionPath = @"/task/:convertWithStatus";
            
        }
        else{
            actionPath = @"/task/:create";
        }
    }else {
        actionPath = @"/task/:create";
    }
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        flag_.isCreatingTask = 0;
        [MBProgressHUD hideHUDForView:self.view.window animated:YES];
        NSString *message = nil;
        if ([response isValidResponse]) {
            NSDictionary *resultDic = results;
            BOOL success = [resultDic boolForKey:@"success"];
            if (!success) {
                message = [resultDic stringForKey:@"errormsg"];
            }else {
                //发送通知,更新界面,虽然不知道之前为什么屏蔽了这里
                [[NSNotificationCenter defaultCenter] postNotificationName:KD_TODOLIST_RELOAD_NOTIFICATION object:nil];
                [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window message: ASLocalizedString(@"KDCreateTaskViewController_tips_create_suc")type:KDNotificationViewTypeNormal];
                [self dismissSelf];
            }
        }else {
            if (![response isCancelled]) {
                message = [response.responseDiagnosis networkErrorMessage];
            }
        }
        if (message) {
            NSRange range = [message rangeOfString:ASLocalizedString(@"KDCreateTaskViewController_tips_min")];
            if (range.location != NSNotFound) {
                   [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window message: ASLocalizedString(@"KDCreateTaskViewController_tips_create_fail")type:KDNotificationViewTypeNormal];
                return ;
            }
             range = [message rangeOfString:ASLocalizedString(@"KDCreateTaskViewController_un_join")];
             if (range.location != NSNotFound) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alertView show];
//                [alertView release];
                 return ;
                
            }
            [KDErrorDisplayView showErrorMessage:message  inView:self.view.window];
        }
        
    };
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
}


#pragma mark - Property Getter
- (UITableViewCell *)inputCell {
    if (!inputCell_) {
        inputCell_ = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        inputCell_.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, inputCell_.bounds.size.width, inputCell_.bounds.size.height)];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        bgView.backgroundColor = [UIColor kdBackgroundColor2];
        bgView.layer.borderWidth = 0.5;
        bgView.layer.borderColor = [UIColor clearColor].CGColor;
        bgView.layer.cornerRadius = 2.5;
        
        [inputCell_ addSubview:bgView];
//        [bgView release];
        
    }
    return inputCell_;
}

- (UITableViewCell *)refrCell {
    if(!refrCell_) {
        refrCell_ = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView_.bounds.size.width, 60)];
        refrCell_.backgroundColor = [UIColor clearColor];
        if (referObject_) {
            CGRect frame = refrCell_.bounds;
            frame.origin.x  = 7.0f;
            frame.size.width -= 2*7.0f;
            frame.size.height = frame.size.height - 8;
            UIImage *image = [UIImage imageNamed:@"inbox_comment_bg"];
            image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
            UIImageView *background = [[UIImageView alloc] initWithImage:image];
            background.frame = frame;
            background.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [refrCell_ addSubview:background];
//            [background release];
            
            frame.size.height = 16;
            frame.origin.x = 10;
            frame.origin.y = (CGRectGetHeight(refrCell_.bounds)- 16)*0.5-3;
            frame.size.width = CGRectGetWidth(refrCell_.bounds) -20;
            refrLabel_ = [[UILabel alloc] initWithFrame:frame];
            refrLabel_.font = [UIFont systemFontOfSize:15];
            refrLabel_.backgroundColor = [UIColor clearColor];
            refrLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [refrCell_ addSubview:refrLabel_];
            refrLabel_.text = [self refStr];
        }
       
    }
    return refrCell_;
}

- (UserPortraitGroupCell *)exectorCell {
    if (!exectorCell_) {
        exectorCell_ = [[UserPortraitGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserPortraitGroupCell"];
        exectorCell_.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    exectorCell_.groupView.delegate = self;
    return exectorCell_;
}

-(KDTaskItemCell *)needFinishDateCell {
    if (!needFinishDateCell_) {
        needFinishDateCell_ = [[KDTaskItemCell alloc] initWithFrame:CGRectZero];
        needFinishDateCell_.backgroundColor = [UIColor kdBackgroundColor2];
        needFinishDateCell_.leftLabel.text = ASLocalizedString(@"KDCreateTaskViewController_end_time");
        //needFinishDateCell_.iconImageView.image = [UIImage imageNamed:@"task_icon_time"];
    }
    return needFinishDateCell_;
}

- (KDTaskItemCell *)shareRangeCell {
    if (!shareRangeCell_) {
        shareRangeCell_ = [[KDTaskItemCell alloc] initWithFrame:CGRectZero];
        shareRangeCell_.backgroundColor = [UIColor kdBackgroundColor2];
        shareRangeCell_.leftLabel.text = ASLocalizedString(@"KDCreateTaskViewController_share_scope");
        //shareRangeCell_.iconImageView.image = [UIImage imageNamed:@"task_icon_share"];
        
    }
    return shareRangeCell_;
}

- (KDTaskReminadMeItemCell *)remindCell {
    if (!remindCell_) {
        remindCell_ = [[KDTaskReminadMeItemCell alloc] initWithFrame:CGRectZero];
        remindCell_.leftLabel.text = ASLocalizedString(@"KDCreateTaskViewController_warn_me");
        
    }
    return remindCell_;
}

- (UITableViewCell *)submitBtnCell {
    if (!submitBtnCell_) {
        submitBtnCell_ = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        submitBtnCell_.backgroundColor = [UIColor clearColor];
        CGRect rect = submitBtnCell_.bounds;
        rect.origin.x = 7.f;
        rect.origin.y = 50;
        if (![UIDevice isRunningOveriPhone5])
            rect.origin.y = 18;
        rect.size.height = 42;
        rect.size.width = 320 -14;
        UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = rect;
        [btn setBackgroundColor:[UIColor colorWithRed:32/255.0 green:192/255.0 blue:0 alpha:1.0]];
        btn.layer.cornerRadius = 2.50f;
        [btn setTitle:ASLocalizedString(@"KDCreateTaskViewController_create")forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(submitBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [submitBtnCell_ addSubview:btn];
    }
    return submitBtnCell_;
}

- (NSString *)stringTobeCounted {
    return textView_.text;
}
- (void)updateWordLimitsLabel {
    
    NSInteger remainingCount = [TwitterText remainingCharacterCount:[self stringTobeCounted]];
    wordLimitLabel_.textColor = (remainingCount < 0) ? [UIColor redColor] :[UIColor colorWithRed:155.0f/255 green:155.0f/255 blue:155.0f/255 alpha:1.0f];
    wordLimitLabel_.text = [NSString stringWithFormat:@"%ld", (long)remainingCount];
}

- (KDPostActionMenuView *)actionMenuView {
    if (!actionMenuView_) {
        actionMenuView_= [[KDPostActionMenuView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height-44.0, self.view.bounds.size.width, 44.0)];
        
        actionMenuView_.delegate = self;
        actionMenuView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        actionMenuView_.align = KDPostActionMenuViewAlignLeft;
        //[self.view addSubview:actionMenuView_];
        [actionMenuView_ menuButtonItemHidden:YES atIndex:0];
        [actionMenuView_ menuButtonItemHidden:YES atIndex:1];
        [actionMenuView_ menuButtonItemHidden:YES atIndex:2];
    }
    return actionMenuView_;
}

- (KDExpressionInputView *)expressionInputView {
    if(!expressionInputView_) {
        
        expressionInputView_ = [[KDExpressionInputView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 216.0f)];
        expressionInputView_.delegate = self;
        [expressionInputView_ setSendButtonShown:NO];
        
        //[self.view addSubview:expressionInputView_];
    }
    return expressionInputView_;
}

- (void)switchExpressionView {
    if (textView_.internalTextView.isFirstResponder) {
        flag_.isExpressionViewShow = 1;
        [textView_.internalTextView resignFirstResponder];
    }
}



#pragma mark - UITable DataSource & Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 || section == 2)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView_.frame), 22)];
        view.backgroundColor = [UIColor kdSubtitleColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
        label.text = section == 0 ? ASLocalizedString(@"KDCreateTaskViewController_content2"):ASLocalizedString(@"KDCreateTaskViewController_member");
        label.font = FS7;
        label.textColor = FC1;
        label.backgroundColor = view.backgroundColor;
        [view addSubview:label];
        return view;
    }else{
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor kdSubtitleColor];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return [NSNumber kdDistance1];
    }
    else if(section == 0 || section == 2)
    {
        return 22;
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    else if(section == 1)
        return [BOSConfig sharedConfig].user.partnerType == 1?1:2;
    else if(section == 2)
        return 1;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 0)
                cell = [self inputCell];
            break;
        case 1:
            if(indexPath.row == 0)
                cell  = [self needFinishDateCell];
            else if(indexPath.row == 1)
                cell = [self shareRangeCell];
            break;
        case 2:
            cell = [self exectorCell];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    switch (indexPath.section) {
        case 0:
            height = textViewHeight + 20;
            break;
        case 1:
            height = 44;
            break;
        case 2:
            height = [KDUserPortraitGroupView heightForUserPortraitGroupView:exectors_ canbeEdit:YES];
            break;
        default:
            break;
    }
    return height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([textView_.internalTextView isFirstResponder]) {
        [textView_.internalTextView resignFirstResponder];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section!=1)
        return;
    
    if (indexPath.row == 0) {
        __weak KDCreateTaskViewController *selfInBlock = self;
        self.datePicker.leftbtnTappedEventHander = ^(void) {
            [selfInBlock dismissDatePicker];
        };
        
        self.datePicker.rightTappedEventHander = ^(void) {

            selfInBlock.needFinishDate = selfInBlock.datePicker.date;
            [selfInBlock updateNeedFinishDateCell];
            [selfInBlock dismissDatePicker];
        };
        self.datePicker.date = self.needFinishDate;
        [self displayDatePicker];
    }else if (indexPath.row == 1) {
        KDTaskShareViewController *taskShareVeiwController = [[KDTaskShareViewController alloc] init];
        taskShareVeiwController.shareRangeDic = shareRangeTaskDic_;
        taskShareVeiwController.delegate = self;
        [self.navigationController pushViewController:taskShareVeiwController animated:YES];
    }
}

#pragma mark -  DatePicker Stuff
- (KDDatePickerViewController *)datePicker {
    if (!datePicker_) {
        datePicker_ = [[KDDatePickerViewController alloc] init];
        datePicker_.datePickerMode = UIDatePickerModeDate;
    }
    return datePicker_;
}
- (void)displayDatePicker {
    [self.datePicker showInView:self.navigationController.view];
}

- (void)dismissDatePicker {

    [self.datePicker hide];
    
    //KD_RELEASE_SAFELY(datePicker_);
}


#pragma mark - GestrueRecogizer Handler
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return textView_.internalTextView.isFirstResponder;
}

- (void)tapped:(UITapGestureRecognizer *)rgzr {
    [textView_.internalTextView resignFirstResponder];
}

- (void)updateExectorCell {

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.exectors.count];
    [self.exectors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
        KDUser *user = [[KDUser alloc] init];
        user.userId = person.wbUserId;
        user.openId = person.personId;
        user.username = person.personName;
        user.screenName = person.personName;
        user.department = person.department;
        user.jobTitle = person.jobTitle;
        user.profileImageUrl = person.photoUrl;
        [array addObject:user];
    }];
    
    [exectorCell_ setUsers:array];
    [tableView_ reloadData];
}

#pragma mark - KDTaskShareDelegate 

- (void)tashShareRangeDidSelected:(NSDictionary *)dic {
    self.shareRangeTaskDic = dic;
    [self updateTaskshareCell];
    
}
/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark The keyboard notification

- (void)keyboardDidHide:(NSNotification *)notification {
    if (flag_.isExpressionViewShow == 1) {
        flag_.isExpressionViewShow = 0;
        if (((UIButton *)[actionMenuView_ menuButtonItemAtIndex:5]).selected) {
            textView_.internalTextView.inputView = [self expressionInputView];
        }else {
            textView_.internalTextView.inputView = nil;
        }
      if ([textView_.internalTextView canBecomeFirstResponder]) {
        [textView_.internalTextView becomeFirstResponder];
      }
    }
}

- (void)importPopularTopic {
    KDTrendEditorViewController *tevc = [[KDTrendEditorViewController alloc] initWithNibName:nil bundle:nil];
    tevc.delegate = self;
    
    [self.navigationController pushViewController:tevc animated:YES];
//    [tevc release];
}

- (void)atFriend {

    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.isFromConversation = NO;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self.navigationController presentViewController:contentNav animated:YES completion:nil];
}

- (void)postActionMenuView:(KDPostActionMenuView *)postActionMenuView clickOnMenuItem:(UIButton *)menuItem {
    NSUInteger idx = [postActionMenuView.menuItems indexOfObject:menuItem];
    if (0x00 == idx) {
        //
       
    }else if(0x01 == idx){
      
    }else if(0x02 == idx){
      
    }else if(0x03 == idx){
        // at friend
        [self atFriend];
        
    }else if(0x04 == idx) {
        // import popular topic
        [self importPopularTopic];
    }else if(0x05 == idx) {
        [self switchExpressionView];
    }
}

- (void)appendText:(NSString *)text {
    if(text == nil) return;
    
    // append text to current text input cursor
    NSMutableString *body = [NSMutableString string];
    BOOL tail = YES;
    NSUInteger idx = 0;
    NSUInteger location = NSNotFound;
    if([textView_.internalTextView hasText]){
        [body appendString:textView_.text];
        
        NSRange range = textView_.internalTextView.selectedRange;
        if(range.location != NSNotFound && range.location < [body length]){
            tail = NO;
            idx = location = range.location;
        }
    }
    
    if(tail){
        [body appendString:text];
        
    }else {
        [body insertString:text atIndex:idx];
        location += [text length];
    }
    
    textView_.text = body;
    if(location != NSNotFound){
        textView_.internalTextView.selectedRange = NSMakeRange(location, 0);
    }
    
    [self updateWordLimitsLabel];
}

#pragma mark - KDTrendEditorViewController delegate method

- (void)trendEditorViewController:(KDTrendEditorViewController *)tevc didPickTopicText:(NSString *)topicText {
    [self appendText:topicText];
}


#pragma mark - XTChooseContentViewControllerDelegate delegate method

//选择了一个或者多个人（仅用于XTChooseContentAdd 和 XTChooseContentJSChoose）
- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons
{
    if(controller == self.exectorsContentVC)
    {
        //添加任务执行人
        self.exectors = persons;
        [self updateExectorCell];
    }
    else
    {
        //@人
        NSMutableString *text = [NSMutableString string];
        if (persons != nil && [persons count] > 0) {
            for (PersonSimpleDataModel *item in persons) {
                [text appendFormat:@"@%@ ", item.personName];
            }
            
            [self appendText:text];
        }

    }
}

#pragma mark - KDExpressionInputViewDelegate Methods
- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpression:(NSString *)expressionCode {
    if(caret.location != NSNotFound) {
        textView_.text = [textView_.text stringByReplacingCharactersInRange:caret withString:expressionCode];
        caret.location = caret.location + expressionCode.length;
    }else {
        textView_.text = [textView_.text stringByAppendingString:expressionCode];
    }
    
    [self updateWordLimitsLabel];
}

- (void)didTapKeyBoardInExpressionInputView:(KDExpressionInputView *)inputView {
    [self switchExpressionView];
}

- (void)didTapDeleteInExpressionInputView:(KDExpressionInputView *)inputView {
    if(!textView_.text || textView_.text.length == 0 || caret.location == 0) return;
    
    NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
    
    if(caret.location != NSNotFound) {
        for(NSTextCheckingResult *result in matches) {
            NSRange range = result.range;
            if(range.location + range.length == caret.location) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                caret.location = range.location;
                [self updateWordLimitsLabel];
                return;
            }
        }
        
        textView_.text = [textView_.text stringByReplacingCharactersInRange:NSMakeRange(--caret.location, 1.0f) withString:@""];
        [self updateWordLimitsLabel];
    }else {
        NSTextCheckingResult *lastMatch = [matches lastObject];
        if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
            textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
            [self updateWordLimitsLabel];
            return;
        }else {
            textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            [self updateWordLimitsLabel];
        }
    }
}
#pragma mark -  KDUserPortraitDelegate

- (void)editorContactsWithUsers:(NSArray *)users
{    
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.isFromConversation = NO;
    contentViewController.isFromTask = YES;
    contentViewController.selectedPersons = self.exectors;
    contentViewController.blockCurrentUser = NO;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self.navigationController presentViewController:contentNav animated:YES completion:nil];
    
    self.exectorsContentVC = contentViewController;
}

#pragma mark - UITextView Delegate 
- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView {
    caret = growingTextView.internalTextView.selectedRange;
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    [self updateWordLimitsLabel];
}


- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    [[actionMenuView_ menuButtonItemAtIndex:0x04] setSelected:NO];
        return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@""]) {
        if(!growingTextView.text || growingTextView.text.length == 0 || caret.location == 0) return YES;

        caret = growingTextView.internalTextView.selectedRange;

        NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSArray *matches = [topicExpression matchesInString:growingTextView.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, growingTextView.text.length)];

        if(caret.location != NSNotFound) {
            for(NSTextCheckingResult *result in matches) {
                NSRange range = result.range;
                if(range.location + range.length == caret.location) {
                    growingTextView.text = [growingTextView.text stringByReplacingCharactersInRange:range withString:@""];
                    caret.location = range.location;
                    growingTextView.internalTextView.selectedRange = caret;
                    return NO;
                }
            }

            return YES;
        }else {
            NSTextCheckingResult *lastMatch = [matches lastObject];
            if(lastMatch.range.location + lastMatch.range.length == growingTextView.text.length) {
                growingTextView.text = [growingTextView.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
                return NO;
            }else {
                growingTextView.text = [growingTextView.text substringToIndex:growingTextView.text.length - 1];
            }
            return NO;
        }
    }
    
    return YES;
    
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    textViewHeight = height;
    wordLimitLabel_.frame = CGRectMake(textView_.bounds.size.width - 55, CGRectGetHeight(textView_.frame)-7+32, 80, 18);
    [self.tableView reloadData];
}

#pragma mark -  Button Tapped
- (void)submitBtnTapped:(id)sender {
    
    if ([textView_ isFirstResponder])
        [textView_ resignFirstResponder];
    
    [self shouldCreateTask];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(inputCell_);
    //KD_RELEASE_SAFELY(refrCell_);
    //KD_RELEASE_SAFELY(exectorCell_);
    //KD_RELEASE_SAFELY(needFinishDateCell_);
    //KD_RELEASE_SAFELY(shareRangeCell_);
    //KD_RELEASE_SAFELY(remindCell_);
    //KD_RELEASE_SAFELY(remindDayCell_);
    //KD_RELEASE_SAFELY(textView_);
    //KD_RELEASE_SAFELY(wordLimitLabel_);
    //KD_RELEASE_SAFELY(refrLabel_);
    //KD_RELEASE_SAFELY(exectors_);
    //KD_RELEASE_SAFELY(datePicker_);
    //KD_RELEASE_SAFELY(actionMenuView_);
    //KD_RELEASE_SAFELY(expressionInputView_);
    //KD_RELEASE_SAFELY(contentBackup_);
    //KD_RELEASE_SAFELY(referObject_);
    
    //KD_RELEASE_SAFELY(executorsPickerVC_);
    //KD_RELEASE_SAFELY(atSomeOneVC_);
    //[super dealloc];
}
@end
