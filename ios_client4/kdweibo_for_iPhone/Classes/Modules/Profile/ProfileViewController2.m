//
//  ProfileViewController2.m
//  TwitterFon
//
//  Created by apple on 11-1-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  个人设置页

#import "KDCommon.h"
#import "ProfileViewController2.h"

#import "ProfileViewDetailController.h"
#import "KDSearchViewController.h"
//#import "KDAboutViewceController.h"
#import "DraftViewController.h"
#import "KDUserProfileEditViewController.h"
#import "KDTrendsViewController.h"
#import "IssuleViewController.h"
#import "KDAllDownloadedViewController.h"
//#import "KDEnterpriseAppViewController.h"
#import "KDABPersonViewController.h"

#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "KDUser.h"
#import "KDWeiboGlobals.h"

//#import "KDUserProfileQuickLinkButton.h"
//#import "KDUserProfileQuickLinkItem.h"
#import "SettingTableViewCell.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDefaultViewControllerContext.h"
#import "UIViewController+Navigation.h"

#import "ResourceManager.h"
#import "KDWeiboAppDelegate.h"

#import "NSString+Additions.h"
#import "KDUtility.h"
#import "KDCacheUtlities.h"
#import "KDDatabaseHelper.h"
#import "KDInboxListViewController.h"

#import "KDProfileDetailTabBarController.h"

#import "ProfileViewCell.h"

#import "KDSingleInputViewController.h"

#import "KDImageOptimizationTask.h"

#import "KDImageOptimizer.h"

#import "KDCache.h"
#import "KDUserAvatarView.h"
#import "KDNotificationView.h"

#import "KDWeiboServicesContext.h"

#import "KDUtility.h"
#import "KDDatabaseHelper.h"
#import "UIImage+Additions.h"
#import "BOSConfig.h"
#import "KDBindEmailViewController.h"
#import "KDPhoneInputViewController.h"

#import "KDPhoneBindingDisplayViewController.h"
#import "KDChooseDepartmentViewController.h"

#import "XTOpenSystemClient.h"
#import "KDLoggedInUser.h"

#import "ContactClient.h"
#import "XTInitializationManager.h"
#import "KDProfileCell.h"
#import "KDContactInfo.h"
#import "UIButton+Factory.h"
#import "KDProfileTagsViewController.h"
#import "KDDatePickerViewController.h"
#import "KDImageClipViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////

#define SectionHeader 0
#define SectionCompany 1
#define SectionContact 2
#define SectionWeibo 3

#define RowUserHeader 0
#define RowUserName 1
#define RowUserGender 2

#define RowCompany 0
#define RowDepartment 1
#define RowJobTitle 2

#define RowPhone 0
//#define RowEmail 1
#define RowPhone1 1
#define RowPhone2 2
#define RowEmail 3
#define RowBrithday 4


// officePhone1:电话1, officePhone2:电话2, emails:邮箱, birthday:生日, gender:性别
typedef enum : NSUInteger {
    officePhone1,
    officePhone2,
    emails,
    birthday,
    gender
} SystemContactType;

@interface KDSettingIconCell : KDTableViewCell

@property (nonatomic, retain) UILabel *labelTitle;
@property (nonatomic, retain) UIImageView *imageViewIcon;

@end

@implementation KDSettingIconCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.labelTitle];
        [self.contentView addSubview:self.imageViewIcon];
        [self setupVFLFunction];
    }
    return self;
}

- (void)setupVFLFunction {
    
    NSDictionary *views = @{@"titleLabel" : self.labelTitle, @"headerView" : self.imageViewIcon};
    NSDictionary *metrics = @{@"kHMargin" : @12,
                              @"kMargin" : @20,
                              @"kHeightTitleLabel" : @21,
                              @"kHeightHeaderView" : @55
                              };
    NSArray *vfls = @[@"|-kHMargin-[titleLabel]-kMargin-[headerView(kHeightHeaderView)]-31-|", @"V:[titleLabel(kHeightTitleLabel)]", @"V:[headerView(kHeightHeaderView)]"];
    for (NSString *vfl in vfls) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                                                 options:nil
                                                                                 metrics:metrics
                                                                                   views:views]];
    }
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTitle
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.labelTitle.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewIcon
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.imageViewIcon.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
}

- (UIImageView *)imageViewIcon
{
    if (!_imageViewIcon)
    {
        //        _imageViewIcon = [[UIImageView alloc]initWithFrame:isAboveiOS7 ? CGRectMake(242, 10, 60, 60) : CGRectMake(232, 10, 60, 60)];
        _imageViewIcon = [[UIImageView alloc]initWithFrame: CGRectZero];
        _imageViewIcon.layer.cornerRadius = 30;
        _imageViewIcon.clipsToBounds = YES;
        _imageViewIcon.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageViewIcon;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectZero];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.font = FS2;
        _labelTitle.textColor = FC1;
        _labelTitle.textAlignment = NSTextAlignmentLeft;
        _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _labelTitle;
}

- (void)dealloc
{
    ////[super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDSettingTextCell : KDTableViewCell

@property (nonatomic, retain) UILabel *labelTitle;
@property (nonatomic, retain) UILabel *labelSubTitle;

@end

@implementation KDSettingTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.labelTitle];
        [self.contentView addSubview:self.labelSubTitle];
    }
    return self;
}

- (UILabel *)labelSubTitle
{
    if (!_labelSubTitle)
    {
        //        _labelSubTitle = [[UILabel alloc]initWithFrame:isAboveiOS7 ? CGRectMake(85, 12, 202, 21):CGRectMake(75, 12, 192, 21)];
        _labelSubTitle = [[UILabel alloc]initWithFrame: CGRectMake(ScreenFullWidth - 232, 12, 202, 21)];
        _labelSubTitle.backgroundColor = [UIColor clearColor];
        _labelSubTitle.font = [UIFont systemFontOfSize:14];
        _labelSubTitle.textColor = MESSAGE_NAME_COLOR;
        _labelSubTitle.textAlignment = NSTextAlignmentRight;
    }
    return _labelSubTitle;
}


- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(14, 12, 71, 21)];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.font = [UIFont boldSystemFontOfSize:16];
        _labelTitle.textColor = [UIColor blackColor];
    }
    return _labelTitle;
}

- (void)dealloc
{
    ////[super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////



NSString * const KDUserProfileDidChangeNotification = @"KDUserProfileDidChangeNotification";

enum {
    KDProfileMenuFollowItem = 0,
    KDProfileMenuFansItem,
    KDProfileMenuStatusItem,
    KDProfileMenuDraftItem,
    KDProfileMenuTopicItem,
    KDProfileMenuFavoriteItem,
};

@interface ProfileViewController2 () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KDImageOptimizationTaskDelegate, KDBindEmailViewControllerDelegate, KDLoginPwdConfirmDelegate, KDChooseDepartmentViewControllerDelegate,KDProfileNewlyCellDelegate,KDProfileTagsViewControllerDelegate,UITextFieldDelegate, KDImageClipDelegate>
{
    BOOL hasAvatarCompressionTask_;
    BOOL hasUnsaveChanges_;
    NSString *avatarPath_;
    KDChooseDepartmentModel *_choosenDepartment;
}
@property (nonatomic,retain)ContactClient *personInfoClient;
@property(nonatomic, retain) KDUser* currentUser;
@property(nonatomic, retain) MBProgressHUD  *activityView;

@property(nonatomic, assign) NSUInteger draftCount;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) XTOpenSystemClient *openClient;
@property (nonatomic, retain) XTOpenSystemClient *saveContactClient;
@property (nonatomic, retain) XTOpenSystemClient *saveOfficeClient;
@property (nonatomic, strong) XTOpenSystemClient *saveAttibuteClient;

@property (nonatomic, strong) PersonDataModel *person;
@property (nonatomic, strong) NSMutableArray *originalContacts;
@property (nonatomic, strong) KDProfileSectionDataModel *showData;

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *placeholders;
@property (nonatomic, strong) NSArray *tags;


@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *customTags;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) KDDatePickerViewController *datePicker;
@property (nonatomic, assign) BOOL bTeamAccount;
@end



@implementation ProfileViewController2
@synthesize personInfoClient = personInfoClient_;
@synthesize currentUser=currentUser_;

@synthesize activityView = activityView_;

- (BOOL)bTeamAccount {
    if (!_bTeamAccount) {
        if ([[BOSConfig sharedConfig].user.userId isEqualToString:[BOSConfig sharedConfig].mainUser.userId]) {
            _bTeamAccount = NO;
        } else {
            _bTeamAccount = YES;
        }
    }
    return _bTeamAccount;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        self.title = ASLocalizedString(@"ProfileViewController2_title");
        
        hasAvatarCompressionTask_ = NO;
        
        profileControllerFlags_.hasRequests = 0;
        profileControllerFlags_.userProfileDidChange = 1;
        profileControllerFlags_.pausedCalculateCacheSize = 0;
        profileControllerFlags_.isCheckingDraftCount = 0;
        
        _draftCount = NSUIntegerMax;
        
        // add user profile did change notification observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileDidChange:) name:KDUserProfileDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostDraft:) name:kKDPostViewControllerDraftSendNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAvatarUpdate:) name:KDProfileUserAvatarUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNameUpdate:) name:KDProfileUserNameUpdateNotification object:nil];
        // register unread listener
        [[KDManagerContext globalManagerContext].unreadManager addUnreadListener:self];
        
        [self addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew context:NULL];
        
    }
    
    return self;
}

- (void)viewControllerWillDismiss {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 旧样式的代码
     
     CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 186);
     
     UIView *headerView = [[[UIView alloc] initWithFrame:frame] autorelease];
     
     UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_img_bg.png"]] autorelease];
     
     [headerView addSubview:imageView];
     
     //user profile view
     [self setupAvatarAndTitle];
     
     [avatarView_ setAnimateImageViewHidden:YES];
     
     [headerView addSubview:avatarView_];
     [headerView addSubview:userNameLabel_];
     [headerView addSubview:departmentLabel_];
     [headerView addSubview:jobTitleLabel_];
     
     // user personal stuff view
     frame = CGRectMake(10.0, 148.0f, self.view.bounds.size.width - 20.0f, 155.0f);
     
     
     headerView.clipsToBounds = YES;
     
     self.view.backgroundColor = MESSAGE_BG_COLOR;
     
     //    [self.view addSubview:headerView];
     
     _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70.f)];
     _tableView.delegate = self;
     _tableView.dataSource = self;
     _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     _tableView.tableHeaderView = headerView;
     _tableView.clipsToBounds = NO;
     _tableView.backgroundColor = MESSAGE_BG_COLOR;
     _tableView.showsVerticalScrollIndicator = NO;
     
     [self.view addSubview:_tableView];
     
     */
    
    if (self.sectionTitles == nil) {
        self.sectionTitles = @[@"",ASLocalizedString(@"ProfileViewController2_Company"),ASLocalizedString(@"ProfileViewController2_Phone"),ASLocalizedString(@"KDAuthViewController_email"),ASLocalizedString(@"ProfileViewController2_Other")];
        self.placeholders = @[@"",@"",ASLocalizedString(@"ProfileViewController2_Tel"),ASLocalizedString(@"ProfileViewController2_Email"),ASLocalizedString(@"ProfileViewController2_Other")];
        self.tags = @[@[],@[],@[ASLocalizedString(@"ProfileViewController2_Phone_Usually"),ASLocalizedString(@"ProfileViewController2_Phone_Work"),ASLocalizedString(@"ProfileViewController2_Phone_Company")],@[ASLocalizedString(@"ProfileViewController2_Email_Work"),ASLocalizedString(@"ProfileViewController2_Email_person")],@[ASLocalizedString(@"KDEvent_WeChat"),@"QQ",ASLocalizedString(@"ProfileViewController2_Birth"),ASLocalizedString(@"ProfileViewController2_Address")]];
    }
    
    //设置导航栏左右按钮
//    self.navigationItem.rightBarButtonItem = [UIButton textBarButtonItemWithTitle:ASLocalizedString(@"ProfileViewController2_Edit")addTarget:self action:@selector(editButtonClick:)];
    if (self.bTeamAccount == NO) {
        [self setRightNavigationItem:NO];
    }
    
//    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
//    [btn addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    
    //    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), isAboveiOS7? CGRectGetHeight(self.view.frame) - 70.f: self.view.frame.size.height )   style:UITableViewStyleGrouped];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70.f)   style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.clipsToBounds = NO;
    _tableView.backgroundColor = [UIColor kdTableViewBackgroundColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setRightNavigationItem:(BOOL) editing {
    NSString *backTitle = ASLocalizedString(@"ProfileViewController2_Edit");
    if (editing) {
        backTitle = ASLocalizedString(@"KDCompanyChoseViewController_complete");
    }
    UIButton *btn = [UIButton normalBtnWithTile:backTitle];
    [btn addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];

    //btn.enabled = ![[BOSSetting sharedSetting] isIntergrationMode];
}

- (void)goHome {
    
}

#pragma mark - 个人信息编辑

- (void)editButtonClick:(UIButton *)btn {
    BOOL notEditing = !self.tableView.editing;
    if (notEditing) {
        [self setRightNavigationItem:notEditing];
        [self.tableView setEditing:notEditing animated:YES];
        [self edit];
    }
    else {
        if (self.textField) {
            [self.textField resignFirstResponder];
        }
        [self done];
        
        [self setRightNavigationItem:self.tableView.editing];
    }
}

- (void)edit {
    
    KDProfileRowDataModel *rowPhone = [[KDProfileRowDataModel alloc] initWithTitle:[NSString stringWithFormat:ASLocalizedString(@"ProfileViewController2_Add"), ASLocalizedString(@"ProfileViewController2_Phone")] content:nil original:kProfileRowOriginalAdd];
    rowPhone.type = KDProfileSectionTypeContactPhone;
    [self.showData.rows addObject:rowPhone];
    
    KDProfileRowDataModel *rowEmail = [[KDProfileRowDataModel alloc] initWithTitle:[NSString stringWithFormat:ASLocalizedString(@"ProfileViewController2_Add"), ASLocalizedString(@"KDAuthViewController_email")] content:nil original:kProfileRowOriginalAdd];
    rowEmail.type = KDProfileSectionTypeContactEmail;
    [self.showData.rows addObject:rowEmail];
    
    KDProfileRowDataModel *rowOther = [[KDProfileRowDataModel alloc] initWithTitle:[NSString stringWithFormat:ASLocalizedString(@"ProfileViewController2_Add"), ASLocalizedString(@"ProfileViewController2_Other")] content:nil original:kProfileRowOriginalAdd];
    rowOther.type = KDProfileSectionTypeContactOther;
    [self.showData.rows addObject:rowOther];
    
    NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:SectionContact];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if(self.showData.rows.count>3)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.showData.rows.count-3 inSection:SectionContact] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)done
{
    __block NSMutableArray *modifiedContacts = [NSMutableArray array];
    __block BOOL isAbort = NO;
    [self.showData.rows enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
        if(![obj1 isKindOfClass:[KDProfileRowDataModel class]])
            return ;
        KDProfileRowDataModel *row = obj1;
        if (row.content.length > 0 && [row isCanEdit])
        {
            [modifiedContacts addObject:[NSString stringWithFormat:@"%@-%@",row.title,row.content]];
            
            if(row.type == KDProfileSectionTypeContactPhone)
            {
                NSScanner* scan = [NSScanner scannerWithString:row.content];
                unsigned long long val;
                BOOL isAllNimber = [scan scanUnsignedLongLong:&val] && [scan isAtEnd];
                if(!isAllNimber)
                {
                    *stop1 = YES;
                    isAbort = YES;
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_tel")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                    [alert show];
                }
            }
            else if (row.type == KDProfileSectionTypeContactEmail)
            {
                //去除空格
                row.content = [row.content stringByReplacingOccurrencesOfString:@" " withString:@""];
                BOOL isVaildEmail = [self isValidateEmail:row.content];
                if(!isVaildEmail)
                {
                    *stop1 = YES;
                    isAbort = YES;
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_Email")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                    [alert show];
                }

            }
            
        }
    }];
    
    if(isAbort)
        return;
    
    
    __block BOOL hasChanged = NO;
    if ([modifiedContacts count] != [self.originalContacts count]) {
        hasChanged = YES;
    }
    else {
        [modifiedContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isEqualToString:self.originalContacts[idx]]) {
                hasChanged = YES;
                *stop = YES;
            }
        }];
    }
    
    if (!hasChanged) {//未更改任何信息
        [self finishDone];
        [self refreshData];
        return;
    }
    
    //接口调用
    [self saveMyContacts];
}

-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(BOOL)isValidatePhone:(NSString *)phone
{
    NSString *string = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"＋" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"－" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"（" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"）" withString:@""];
    NSScanner* scan = [NSScanner scannerWithString:string];
    unsigned long long val;
    BOOL isAllNimber = [scan scanUnsignedLongLong:&val] && [scan isAtEnd];
    return isAllNimber;
}

-(void)finishDone
{
    self.tableView.editing = NO;
    [self setRightNavigationItem:self.tableView.editing];
}

- (void)saveMyContacts
{
    __block NSMutableArray *modifiedContacts = [NSMutableArray array];
    
    [self.showData.rows enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
        if(![obj1 isKindOfClass:[KDProfileRowDataModel class]])
            return ;
        
        KDProfileRowDataModel *row = obj1;
        if (row.content.length == 0) {
            return;
        }
        if ([row.original isKindOfClass:[KDContactInfo class]]) {
            KDContactInfo *contactInfo = row.original;
            contactInfo.name = row.title;
            contactInfo.value = row.content;
            [modifiedContacts addObject:[contactInfo dictionary]];
            return;
        }
        if ([row.original isKindOfClass:[NSString class]] && [row.original isEqualToString:kProfileRowOriginalNewly]) {
            NSString *type = @"O";
            switch (row.type) {
                case KDProfileSectionTypeContactPhone:
                    type = @"P";
                    break;
                case KDProfileSectionTypeContactEmail:
                    type = @"E";
                    break;
                default:
                    break;
            }
            KDContactInfo *contactInfo = [[KDContactInfo alloc] initWithName:row.title type:type value:row.content];
            [modifiedContacts addObject:[contactInfo dictionary]];
        }
    }];
    
    self.saveContactClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(saveMyContacts:result:)];
    [self.saveContactClient saveMyContacts:modifiedContacts];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)saveMyContacts:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (client.hasError) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:client.errorMessage delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (!result.success) {
        if (result.error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:result.error delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
            [alert show];
        }
        return;
    }
    else
    {
        [self finishDone];
        [self loadPersonInfo];
    }
}


- (void)setupAvatarAndTitle {
#define TEXT_FONT_SIZE 13.0
    
    CGSize size = [ASLocalizedString(@"ProfileViewController2_Min")sizeWithFont:[UIFont systemFontOfSize:18.f]];
    CGSize size2 = [ASLocalizedString(@"ProfileViewController2_Min")sizeWithFont:[UIFont systemFontOfSize:14.f]];
    
    avatarView_ = [[KDAnimationAvatarView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 70.f) * 0.5, 20.0f, 70.f, 70.f) andNeedHighLight:NO];
    [avatarView_ changeAvatarImageTo:[UIImage imageNamed:@"user_default_portrait"] animation:NO];
    [avatarView_ setRingImage:[UIImage imageNamed:@"profile_user_avatar_ring_v3.png"]];
    avatarView_.avatarImageURL = [BOSConfig sharedConfig].user.photoUrl;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserProfile:)];
    [avatarView_ addGestureRecognizer:tap];
    
    userNameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 116.f) * 0.5, CGRectGetMaxY(avatarView_.frame) +25.f, 116.0f, size2.height)];
    userNameLabel_.backgroundColor = [UIColor clearColor];
    userNameLabel_.text = [BOSConfig sharedConfig].user.name;
    userNameLabel_.textAlignment = NSTextAlignmentCenter;
    userNameLabel_.textColor = [UIColor whiteColor];
    userNameLabel_.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE + 3.0f];
    
    departmentLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userNameLabel_.frame), CGRectGetWidth(self.view.frame) - 20, size.height)];
    departmentLabel_.backgroundColor = [UIColor clearColor];
    departmentLabel_.text = [BOSConfig sharedConfig].user.department;
    departmentLabel_.textAlignment = NSTextAlignmentCenter;
    departmentLabel_.textColor = [UIColor whiteColor];
    departmentLabel_.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
    
    jobTitleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 130.f) * 0.5, CGRectGetMaxY(departmentLabel_.frame), 130.0f, size.height)];
    jobTitleLabel_.backgroundColor = [UIColor clearColor];
    jobTitleLabel_.text = [BOSConfig sharedConfig].user.jobTitle;
    jobTitleLabel_.textAlignment = NSTextAlignmentCenter;
    jobTitleLabel_.textColor = [UIColor whiteColor];
    jobTitleLabel_.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
}

- (void)refreshUserInfoAndView {
    _draftCount = NSUIntegerMax;
    KDManagerContext *context = [KDManagerContext globalManagerContext];
    self.currentUser = context.userManager.currentUser;
    
    //bugid 1483,add by fang
    __block ProfileViewController2 *selfInBlock = self;
    [context.userManager updateCurrentUser:^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        selfInBlock.currentUser = context.userManager.currentUser;
        [selfInBlock.tableView reloadData];
    }];
    
    //[self shouldUpdateQuickLinkMenuTitle];
    [self updateUserProfileInfo:YES];
    
    [self loadPersonInfo];
}

-(void)loadPersonInfo
{
    if (!self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(personInfoReceive:result:)];
    }
    
    [self.openClient getPersonsCasvirByIds:@[[BOSConfig sharedConfig].user.userId]];
}

- (void)personInfoReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && [result.data isKindOfClass:[NSArray class]] && [(NSArray *)result.data count] > 0) {
        NSArray *datas = (NSArray *)result.data;
        [datas enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            PersonDataModel *person = [[PersonDataModel alloc] initWithOpenDictionary:obj];
            self.person = person;
            
            //避免后台返回空的self.person.defaultPhone
//            [BOSConfig sharedConfig].user.phone = self.person.defaultPhone;
//            [[BOSConfig sharedConfig] saveConfig];
            
            if ([person.contactArray count] > 0) {
                __weak ProfileViewController2 *selfInBlock = self;
                [person.contactArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary *contact = obj;
                    NSString *name = contact[@"name"];
                    if (name.length > 0 && ![selfInBlock.customTags containsObject:name]) {
                        [selfInBlock.customTags addObject:name];
                    }
                }];
            }
            
        }];
        
        [self refreshData];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![self.tableView isEditing])
        [self refreshUserInfoAndView];
    [self upateDownloadCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (self.textField) {
        [self.textField resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyboardEndFrame)+36, 0)];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)updateUsernameProfile:(NSString *) userName
{
    [self showUpdateProfileProgressInfo:NSLocalizedString(@"UPDATING_USER_PROFILE", @"")];
    
    KDQuery *query = [KDQuery queryWithName:@"name" value:userName];
    
    __block ProfileViewController2 *upevc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDUser *user = results;
        
        if(user){
            
            [BOSConfig sharedConfig].user.name = userName;
            [[BOSConfig sharedConfig] saveConfig];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserNameUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
        }
        
        [upevc _handleResponseUser:user message:NSLocalizedString(@"UPDATE_USER_USERNAME_DID_FAIL", @"")];
        
        // release current view controller
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfile" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_handleResponseUser:(KDUser *)user message:(NSString *)message {
    
    BOOL hasError = NO;
    if (user != nil) {
        // update user into database
        [[[KDManagerContext globalManagerContext] userManager] setCurrentUser:user];
        self.currentUser = user;
        
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            [userDAO saveUser:user database:fmdb];
            
            return nil;
            
        } completionBlock:nil];
        
    } else {
        hasError = YES;
        [self showUpdateProfileProgressInfo:message];
    }
    
}

- (void)loadTrendsCount:(NSString *)userId {
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:userId];
    
    __block ProfileViewController2 *pvc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                (pvc -> currentUser_).topicsCount = [(NSNumber *)results integerValue];
                [[KDManagerContext globalManagerContext].userManager setCurrentUser:pvc.currentUser];
                
                //[pvc shouldUpdateQuickLinkMenuTitle];
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:pvc.view.window];
            }
        }
        
        // release current view controller
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/users/:followedTopicNumber" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (KDUser *)currentUser {
    if (currentUser_ == nil) {
        currentUser_ = [[[KDManagerContext globalManagerContext] userManager] currentUser];
    }
    
    return currentUser_;
}

- (void)upateDownloadCount {
    //TODO:fetch the downloaded attachment count
}

////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)didPostDraft:(NSNotification *)notification
{
    self.draftCount = NSUIntegerMax;
    [self refreshUserInfoAndView];
    [self upateDownloadCount];
}

- (BOOL)_addressBookModuleEnabled {
    BOOL enabled = NO;
    
    KDManagerContext *context = [KDManagerContext globalManagerContext];
    if ([context.communityManager isCompanyDomain] && ![context.userManager isPublicUser]) {
        enabled = YES;
    }
    
    return enabled;
}

- (void)signOut:(UIButton *)btn {
    __block ProfileViewController2 *weakself = self;
    
    [[KDWeiboAppDelegate getAppDelegate] checkHasSetPassword:^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if ([response isValidResponse]) {
            if (results) {
                BOOL hasSetPwd = [((NSDictionary *)results) boolForKey:@"hasRestPassword"];
                if (hasSetPwd) {
                    [weakself _signOut];
                }else {
                    [weakself showPasswordView];
                }
            }
            
        }else {
            [weakself _signOut];
        }
        //[weakself release];
    }];
}

- (void)showPasswordView
{
    
}

- (void)_signOut
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //清除签到提示的标识
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kSigninHintFlag"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SigninIssueShowed"];
    //    [[KDWeiboGlobals defaultWeiboGlobals] signOut];
    [[KDWeiboAppDelegate getAppDelegate] signOut];
    
    [[KDWeiboAppDelegate getAppDelegate] showAuthViewController];
}

- (void)editUserProfile:(UIButton *)sender {
    
    if(hasAvatarCompressionTask_) return;
    
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    NSUInteger cancelIndex = 1;
    [actionSheet addButtonWithTitle:ASLocalizedString(@"KDImagePickerController_Photo")];
    
    if (hasCamera) {
        cancelIndex++;
        [actionSheet addButtonWithTitle:ASLocalizedString(@"KDDMChatInputView_tak_photo")];
    }
    
    [actionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
    actionSheet.cancelButtonIndex = cancelIndex;
    
    [actionSheet showInView:self.view];
    
    
    //    KDUserProfileEditViewController *upev = [[[KDUserProfileEditViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    //    upev.user = currentUser_;
    //
    //    [self.navigationController pushViewController:upev animated:YES];
}

- (NSInteger)getDraftsCount {
    if(profileControllerFlags_.isCheckingDraftCount == 1) {
        return 0;
    }else {
        if(self.draftCount == NSUIntegerMax) {
            profileControllerFlags_.isCheckingDraftCount = 1;
            [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
                id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
                NSUInteger draftsCount = [draftDAO queryAllDraftsCountWithType:DraftNotInSending database:fmdb];
                return @(draftsCount);
                
            } completionBlock:^(id results) {
                self.draftCount = [(NSNumber *)results unsignedIntegerValue];
            }];
            profileControllerFlags_.isCheckingDraftCount = 0;
        }
    }
    
    return self.draftCount;
}

- (void)shouldUpdateQuickLinkMenuTitle {
    ProfileViewCell * friendsCount = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    ProfileViewCell * followersCount = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    
    ProfileViewCell * statusesCount = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
    ProfileViewCell * DraftsCount = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    ProfileViewCell * topicsCount = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
    ProfileViewCell * favoritesCount = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:1]];
    
    friendsCount.infoLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.friendsCount];
    followersCount.infoLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.followersCount];
    statusesCount.infoLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.statusesCount];
    DraftsCount.infoLabel.text = [NSString stringWithFormat:@"%ld", (long)[self getDraftsCount]];
    topicsCount.infoLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.topicsCount];
    favoritesCount.infoLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.favoritesCount];
}

- (void)gotoProfileViewDetailControllerAtIndex:(NSInteger)index {
    KDProfileDetailTabBarController *pdvc = [KDProfileDetailTabBarController profileDetailViewController];
    pdvc.currentUser = currentUser_;
    [pdvc setSelectedTabIndex:index];
    
    UIViewController *vc = pdvc.viewControllers[index];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userAvatarUpdate:(NSNotification *)noti {
    // [self updateUserProfileInfo:YES];
    
    KDSettingIconCell *cell = (KDSettingIconCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.labelTitle.text = [BOSConfig sharedConfig].user.name;
    [cell.imageViewIcon setImageWithURL:[NSURL URLWithString:self.currentUser.profileImageUrl]];
    [cell setNeedsLayout];
    [self.tableView reloadData];
    
    userNameLabel_.text = [BOSConfig sharedConfig].user.name;//currentUser_.screenName;
    departmentLabel_.text = [BOSConfig sharedConfig].user.department;//currentUser_.department;
    jobTitleLabel_.text = [BOSConfig sharedConfig].user.jobTitle;//currentUser_.jobTitle;
    
}

- (void)userNameUpdate:(NSNotification *)noti {
    [self updateUserProfileInfo:NO];
}

- (void) updateUserProfileInfo:(BOOL)reloadAvatar {
    if(reloadAvatar) {
        //[avatarView_ setAvatarImageURL:currentUser_.profileImageUrl];
        
        [self updateIconCellWithText:[BOSConfig sharedConfig].user.name imageURLString:self.currentUser.profileImageUrl];
        
    }
    
    userNameLabel_.text = [BOSConfig sharedConfig].user.name;//currentUser_.screenName;
    departmentLabel_.text = [BOSConfig sharedConfig].user.department;//currentUser_.department;
    jobTitleLabel_.text = [BOSConfig sharedConfig].user.jobTitle;//currentUser_.jobTitle;
}

- (void)userProfileDidChange:(NSNotification *)notification {
    profileControllerFlags_.userProfileDidChange = 1;
}

#pragma mark -
#pragma mark KDUnreadListener methods


- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType{
    if(unreadManager.unread.followers > 0) {
        KDManagerContext *context = [KDManagerContext globalManagerContext];
        [self loadTrendsCount:context.userManager.currentUserId];
    }
}

#pragma mark table view datasource


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SectionHeader)
    {
        return 8.1f;
    }
    if (self.bTeamAccount && (section == SectionContact || section == SectionCompany)) {
        return 0.1f;
    }
    return 24.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.bTeamAccount && (section == SectionContact || section == SectionCompany)) {
        return 0.1f;
    }
    return 12.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SectionHeader && indexPath.row == RowUserHeader)
        return 80;
    else
        return 45.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(14, 0, 320, height);
    headerLabel.font = FS5;
    headerLabel.textColor = [UIColor grayColor];
    switch (section) {
        case SectionHeader:
            headerLabel.text = @"";
            break;
        case SectionCompany:
            headerLabel.text = ASLocalizedString(@"ProfileViewController2_Company_text");
            break;
        case SectionContact:
            headerLabel.text = ASLocalizedString(@"ProfileViewController2_Contact_txt");
            break;
        case SectionWeibo:
            headerLabel.text = ASLocalizedString(@"ProfileViewController2_weibo_Link");
            break;
        default:
            headerLabel.text = @"";
            break;
    }

    [view addSubview:headerLabel];

    if (self.bTeamAccount && (section == SectionContact || section == SectionCompany)) {
        headerLabel.text = @"";
    }
    return view;
}

- (void) didGenerateUserAvatar:(UIImage *)image {
    hasAvatarCompressionTask_ = NO;
    
    BOOL generated = NO;
    BOOL succeed = (image != nil) ? YES : NO;
    if (succeed) {
        CGSize size = image.size;
//        KDImageSize *tinyAvatarSize = [KDImageSize defaultUserAvatarSize];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        CGFloat wh = 640.0;
        NSData *data = nil;
        UIImage *tinyAvatar = nil;
        
        if(size.width > wh || size.height > wh){
            // fast crop the avatar on main thread
            tinyAvatar = [image fastCropToSize:CGSizeMake(wh, wh)];
            
            // store tiny avatar to local file system
            data = [tinyAvatar asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
            if (data != nil) {
                [fm createFileAtPath:[self tinyAvartarPath] contents:data attributes:nil];
            }
            
        }else {
            tinyAvatar = image;
        }
        
        // store avatar to local file system
        data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
        if (data != nil) {
            if([fm createFileAtPath:[self avatarPath] contents:data attributes:nil]){
                generated = YES;
            }
        }
        
        if(generated){
            hasUnsaveChanges_ = YES;
            //            [avatarView_ changeAvatarImageTo:tinyAvatar animation:YES];
        }
        [self updateUserAvatarProfile];
    }
    
    NSString *info = nil;
    if(generated) {
        
        
    }else {
        // if generate user avatar did fail, clear the avatar path
        self.avatarPath = nil;
        info = NSLocalizedString(@"GENERATE_AVATAR_DID_FAIL", @"");
    }
    
    [self showUpdateProfileProgressInfo:info];
}

- (void)presentImagePickerController:(BOOL)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
//    picker.allowsEditing = YES;
    
    if (takePhoto) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:^{
        if(!takePhoto)
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)setAvatarPath:(NSString *)avatarPath {
    if(avatarPath_ != avatarPath){
        //[avatarPath_ release];
        avatarPath_ = avatarPath;
    }
}

- (NSString *)avatarPath {
    if(avatarPath_ == nil){
        NSString *path = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
        
        NSString *filename = [NSString stringWithFormat:@"%@_%lu_avatar", self.currentUser.userId, (unsigned long)time(NULL)];
        path = [path stringByAppendingPathComponent:filename];
        
        avatarPath_ = path;
    }
    
    return avatarPath_;
}

- (NSString *)tinyAvartarPath {
    NSString *path = [self avatarPath];
    return [path stringByAppendingString:@"_tiny"];
}

- (UIImage *)getTinyAvatar {
    UIImage *avatar = nil;
    if (avatarPath_ != nil) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *path = [self tinyAvartarPath];
        if([fm fileExistsAtPath:path]){
            avatar = [UIImage imageWithContentsOfFile:path];
        }
        if(avatar == nil){
            path = [self avatarPath];
            if([fm fileExistsAtPath:path]){
                avatar = [UIImage imageWithContentsOfFile:path];
            }
        }
    } else {
        avatar = [[KDCache sharedCache] avatarForCacheKey:[self.currentUser getAvatarCacheKey] fromDisk:YES];
    }
    return avatar;
}

- (void)clearCachedAvatars {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // remove cached avatar
    NSString *path = [self avatarPath];
    if([fm fileExistsAtPath:path]){
        [fm removeItemAtPath:path error:NULL];
    }
    
    // remove cached tiny avatar
    path = [self tinyAvartarPath];
    if([fm fileExistsAtPath:path]){
        [fm removeItemAtPath:path error:NULL];
    }
}

- (void)showUpdateProfileProgressInfo:(NSString *)info {
    [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window
                                                            message:info
                                                               type:KDNotificationViewTypeNormal];
}

- (void)updateUserAvatarProfile {
    [self showUpdateProfileProgressInfo:NSLocalizedString(@"UPDATING_USER_PROFILE", @"")];
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"image" filePath:avatarPath_];
    
    __block ProfileViewController2 *upevc = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDUser *user = results;
        
        [upevc _handleResponseUser:user message:NSLocalizedString(@"UPDATE_USER_AVATAR_DID_FAIL", @"")];
        
        if (user != nil) {
            UIImage *image = [upevc getTinyAvatar];
            
            [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:user.profileImageUrl] imageScale:SDWebImageScaleNone] toDisk:YES];
            
            [KDLoggedInUser updateUser:[BOSSetting sharedSetting].userName url:user.profileImageUrl];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserAvatarUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:image forKey:@"avatar"]];
            [[XTDataBaseDao sharedDatabaseDaoInstance]updatePublicPersonSimpleSetPhotoUrl:[BOSConfig sharedConfig].user.wbUserId PhotoUrl:user.profileImageUrl];
        }
        
        
        // release current view controller
        //[upevc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfileImage" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageOptimizationTask delegate methods

- (void) willDropImageOptimizationTask:(KDImageOptimizationTask *)task {
    [self didGenerateUserAvatar:nil];
}

- (void) imageOptimizationTask:(KDImageOptimizationTask *)task didFinishedOptimizedImageWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:kKDImageOptimizationTaskCropedImage];
    [self didGenerateUserAvatar:image];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    KDImageClipViewController *imgCropperVC = [[KDImageClipViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    [picker pushViewController:imgCropperVC animated:NO];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - KDImageCropperDelegate
- (void)imageCropper:(KDImageClipViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    // clear cached avatar if need
    [self clearCachedAvatars];
    self.avatarPath = nil;
    
    UIImage *image = editedImage;
    if (image != nil) {
        CGSize size = image.size;
        CGFloat wh = 640.0;
        
        hasAvatarCompressionTask_ = YES;
        [self showUpdateProfileProgressInfo:NSLocalizedString(@"OPTIMIZING", @"")];
        KDImageSize *imageSize;
        if(size.width >= wh || size.height >= wh) {
            imageSize = [KDImageSize imageSize:CGSizeMake(wh, wh)];
        } else {
            imageSize = [KDImageSize imageSize:CGSizeMake(size.width, size.height)];
        }
        KDImageOptimizationTask *task = [[KDImageOptimizationTask alloc] initWithDelegate:self image:image imageSize:imageSize userInfo:nil];
        task.optimizationType = KDImageOptimizationTypeMinimumOptimal;
        
        [[KDImageOptimizer sharedImageOptimizer] addTask:task];
        
//        if(size.width >= wh || size.height >= wh){
//            hasAvatarCompressionTask_ = YES;
//            [self showUpdateProfileProgressInfo:NSLocalizedString(@"OPTIMIZING", @"")];
//
//            KDImageSize *imageSize = [KDImageSize imageSize:CGSizeMake(wh, wh)];
//            KDImageOptimizationTask *task = [[KDImageOptimizationTask alloc] initWithDelegate:self image:image imageSize:imageSize userInfo:nil];
//            task.optimizationType = KDImageOptimizationTypeMinimumOptimal;
//
//            [[KDImageOptimizer sharedImageOptimizer] addTask:task];
//            //[task release];
//
//        }else {
//            // update
//            [self updateUserAvatarProfile];
//        }
    }
    
    
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(KDImageClipViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}


//////////////////////////////////////////////////////////////////
#pragma mark KDBindEmailViewControllerDelegate and KDLoginPwdConfirmDelegate methods

- (void)finishBindEmail
{
    [self.navigationController popToViewController:self animated:YES];
    
    [_tableView reloadData];
}
- (void)authViewConfirmPwd
{
    [self.navigationController popToViewController:self animated:YES];
    
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UIActionSheet delegate method

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.cancelButtonIndex == buttonIndex) return;
    
    [KDEventAnalysis event:event_settings_personal_headpicture];
    if (0x00 == buttonIndex) {
        [self presentImagePickerController:NO];
        
    }else if(0x01 == buttonIndex){
        [self presentImagePickerController:YES];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    
    // when profile view did receive memory warning, should reload user's profile
    profileControllerFlags_.userProfileDidChange = 1;
    
    // //KD_RELEASE_SAFELY(activityView_);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"currentUser"]) {
        KDUser *user = change[@"new"];
        if ([user isKindOfClass:[NSNull class]]) {
            return;
        }
        //        ProfileViewCell *cell = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        //        cell.infoLabel.text = [BOSConfig sharedConfig].user.name;
        //        [cell setNeedsLayout];
        //        avatarView_.avatarImageURL = user.profileImageUrl;
        //        ProfileViewCell *cell1 = (ProfileViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        //        cell1.infoLabel.text = user.favoritesCount;
        //        [cell1 setNeedsLayout];
        
        [self updateIconCellWithText:[BOSConfig sharedConfig].user.name imageURLString:user.profileImageUrl];
        
        
        //        NSIndexSet *set = [[[NSIndexSet alloc]initWithIndex:0]autorelease];
        //        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (void)updateIconCellWithText:(NSString *)strText imageURLString:(NSString *)strURL
{
    KDSettingIconCell *cell = (KDSettingIconCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.labelTitle.text = strText;
    [cell.imageViewIcon setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"user_default_portrait"]];
    [cell setNeedsLayout];
    [self.tableView reloadData];
}


//#pragma mark Choose Department Delegate

- (void)didChooseDepartmentModel:(KDChooseDepartmentModel *)model longName:(NSString *)longName
{
    NSLog(@"%@",model.strName);
    _choosenDepartment = model;
    if (!self.openClient) {
        self.openClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(moveOrg:result:) ];
    }
    
    
    NSString *strEid = [BOSConfig sharedConfig].user.eid;
    NSLog(@"%@",strEid);
    
    NSString *strNonce = [self randomString];
    NSLog(@"%@",strNonce);
    
    NSString *strLongName = longName;
    NSLog(@"%@",longName);
    
    NSString *strOpenId = [BOSConfig sharedConfig].user.oId;
    NSLog(@"%@",strOpenId);
    
    [self.openClient moveOrgWithEid:strEid
                              nonce:strNonce
                           longName:strLongName
                             openId:strOpenId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)moveOrg:(XTOpenSystemClient *)client result:(NSDictionary *)result
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.openClient = nil;
    if ([result[@"success"] boolValue])
    {
        [KDEventAnalysis event:event_settings_personal_department_ok];
        [BOSConfig sharedConfig].user.department = _choosenDepartment.strName;
        [BOSConfig sharedConfig].user.orgId = _choosenDepartment.strID;
        
        [self.tableView reloadData];
        departmentLabel_.text = [BOSConfig sharedConfig].user.department;//currentUser_.department;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kKDCommunityDidChangedNotification object:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"ProfileViewController2_Try")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
        //[alert release];
    }
}

- (NSString *)randomString
{
    int NUMBER_OF_CHARS = 15;
    char data[NUMBER_OF_CHARS];
    
    for (int x=0;x<NUMBER_OF_CHARS;data[x++] = (char)('a' + (arc4random_uniform(26))));
    
    NSString *randomPath =  [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
    return randomPath;
}



- (void)dealloc {
    // remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDUserProfileDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDProfileUserAvatarUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDProfileUserNameUpdateNotification object:nil];
    
    [self removeObserver:self forKeyPath:@"currentUser"];
    // remove unread listener
    [[KDManagerContext globalManagerContext].unreadManager removeUnreadListener:self];
    
    //    //KD_RELEASE_SAFELY(currentUser_);
    //    //KD_RELEASE_SAFELY(avatarView_);
    //    //KD_RELEASE_SAFELY(userNameLabel_);
    //    //KD_RELEASE_SAFELY(departmentLabel_);
    //    //KD_RELEASE_SAFELY(editButton_);
    //
    //    //KD_RELEASE_SAFELY(menuItems_);
    //
    //    //KD_RELEASE_SAFELY(activityView_);
    //
    //    //KD_RELEASE_SAFELY(_tableView);
    //    //KD_RELEASE_SAFELY(jobTitleLabel_);
    //    //KD_RELEASE_SAFELY(personInfoClient_);
    
    
    //  //[super dealloc];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section!=SectionContact ||(indexPath.section==SectionContact &&(indexPath.row <=RowBrithday)))
    {
        KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.section == RowUserHeader && indexPath.row == RowUserHeader) ? @"IconCell" :@"TextCell"];
        cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        cell.separatorLineInset = UIEdgeInsetsMake(0, 12, 0, 0);
        cell.textLabel.textColor = FC1;
        cell.detailTextLabel.textColor = FC2;
        
        if (!cell)
        {
            if (indexPath.section == SectionHeader && indexPath.row == RowUserHeader)
            {
                cell = [[KDSettingIconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IconCell"];
                cell.textLabel.textColor = FC1;
                cell.detailTextLabel.textColor = FC2;
            }
            else
            {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TextCell"];
                cell.textLabel.textColor = FC1;
                cell.detailTextLabel.textColor = FC2;
            }
        }
        
        if (indexPath.section == SectionHeader)
        {
            if (indexPath.row == RowUserHeader)
            {
                KDSettingIconCell *iconCell = (KDSettingIconCell *)cell;
                iconCell.labelTitle.text = ASLocalizedString(@"ProfileViewController2_Avtar");
                [iconCell.imageViewIcon setImageWithURL:[NSURL URLWithString:self.currentUser.profileImageUrl] placeholderImage:[UIImage imageNamed:@"user_default_portrait"]];
                iconCell.imageViewIcon.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(iconCell.imageViewIcon.frame)/2):ImageViewCornerRadius);
                iconCell.imageViewIcon.layer.masksToBounds = YES;
                iconCell.accessoryStyle  = KDTableViewCellAccessoryStyleDisclosureIndicator;
            }
            
            if (indexPath.row == RowUserName)
            {
                KDTableViewCell *textCell = (KDTableViewCell *)cell;
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_UserName");
                textCell.detailTextLabel.text = [BOSConfig sharedConfig].user.name;
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            }
            
            if (indexPath.row == RowUserGender)
            {
                KDTableViewCell *textCell = (KDTableViewCell *)cell;
                textCell.textLabel.text = ASLocalizedString(@"性别");
                textCell.detailTextLabel.text = [self.person getGenderDescription:self.person.gender];
                cell.accessoryStyle = [self canModifyContact:gender] ? KDTableViewCellAccessoryStyleDisclosureIndicator:KDTableViewCellAccessoryStyleNone;
            }
        }
        
        
        
        if(indexPath.section == SectionCompany)
        {
            KDTableViewCell *textCell = (KDTableViewCell *)cell;
            
            if (indexPath.row == RowCompany)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_Company");
//                textCell.detailTextLabel.text = [self.person.eName length]>0?self.person.eName :ASLocalizedString(@"KDSignInViewController_NOSetting");
                textCell.detailTextLabel.text = [BOSConfig sharedConfig].mainUser.companyName;
//                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            
            if (indexPath.row == RowDepartment)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_DepartMent");
                textCell.detailTextLabel.text = [[BOSConfig sharedConfig].user.department length]>0?[BOSConfig sharedConfig].user.department :ASLocalizedString(@"ProfileViewController2_NoLink");
                //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if (indexPath.row == RowJobTitle)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_Job");
                textCell.detailTextLabel.text = [[BOSConfig sharedConfig].user.jobTitle length]>0?[BOSConfig sharedConfig].user.jobTitle :ASLocalizedString(@"ProfileViewController2_NoLink");
            }
        }
        
        
        if(indexPath.section == SectionContact)
        {
            KDTableViewCell *textCell = (KDTableViewCell *)cell;
            if (indexPath.row == RowPhone)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_Account");
                textCell.detailTextLabel.text = [[BOSConfig sharedConfig].user.phone length]>0?[BOSConfig sharedConfig].user.phone :ASLocalizedString(@"ProfileViewController2_NoLink");
                cell.accessoryStyle = [[BOSSetting sharedSetting] supportNotMobile] ? KDTableViewCellAccessoryStyleNone:KDTableViewCellAccessoryStyleDisclosureIndicator;
            }
            else if (indexPath.row == RowPhone1)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_tep1");
                textCell.detailTextLabel.text = self.person.phone1.length>0?self.person.phone1:ASLocalizedString(@"KDSignInViewController_NOSetting");
                textCell.accessoryStyle  = [self canModifyContact:officePhone1]? KDTableViewCellAccessoryStyleDisclosureIndicator:KDTableViewCellAccessoryStyleNone;
            }
            else if (indexPath.row == RowPhone2)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_tel2");
                textCell.detailTextLabel.text = self.person.phone2.length>0?self.person.phone2:ASLocalizedString(@"KDSignInViewController_NOSetting");
                textCell.accessoryStyle  = [self canModifyContact:officePhone2]? KDTableViewCellAccessoryStyleDisclosureIndicator:KDTableViewCellAccessoryStyleNone;
            }
            else if (indexPath.row == RowEmail)
            {
                textCell.textLabel.text = ASLocalizedString(@"KDAuthViewController_email");
                textCell.detailTextLabel.text = self.person.systemEmail.length>0?self.person.systemEmail:ASLocalizedString(@"KDSignInViewController_NOSetting");
                textCell.accessoryStyle  = [self canModifyContact:emails]? KDTableViewCellAccessoryStyleDisclosureIndicator:KDTableViewCellAccessoryStyleNone;
            }
            else if (indexPath.row == RowBrithday)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_Birth");
                textCell.detailTextLabel.text = self.person.birthday.length>0?self.person.birthday:ASLocalizedString(@"KDSignInViewController_NOSetting");
                textCell.accessoryStyle  = [self canModifyContact:birthday]? KDTableViewCellAccessoryStyleDisclosureIndicator:KDTableViewCellAccessoryStyleNone;
            }
            
//            if([[BOSSetting sharedSetting] isIntergrationMode])
//                textCell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        }
        
        
        if (indexPath.section == SectionWeibo)
        {
            KDTableViewCell *textCell = (KDTableViewCell *)cell;
            cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            
            // textCell.labelSubTitle.textAlignment = NSTextAlignmentLeft;
            if (indexPath.row == 0)
            {
                textCell.textLabel.text = ASLocalizedString(@"ProfileViewController2_Draft");
                textCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[self getDraftsCount]];

            }
            
            if (indexPath.row == 1)
            {
                textCell.textLabel.text = ASLocalizedString(@"KDMainTimelineViewController_follow");
                textCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.friendsCount];
            }
            
            if (indexPath.row == 2)
            {
                textCell.textLabel.text = ASLocalizedString(@"KDProfileDetailTabBarController_Fellow");
                textCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.followersCount];
            }
            
            if (indexPath.row == 3)
            {
                textCell.textLabel.text = ASLocalizedString(@"XTPersonDetailViewController_WB");
                textCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.statusesCount];
            }
            
            if (indexPath.row == 4)
            {
                textCell.textLabel.text = ASLocalizedString(@"KDDiscoveryViewController_topic");
                textCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.topicsCount];
            }
            
            if (indexPath.row == 5)
            {
                textCell.textLabel.text = ASLocalizedString(@"KDABActionTabBar_tips_1");
                textCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentUser.favoritesCount];
            }
            
            
        }
        
        
        
        return cell;
    }
    else
    {
        KDProfileRowDataModel *profile = self.showData.rows[indexPath.row];
        
        if (profile.attributeId && profile.attributeId.length > 0) {
            KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attributeCell"];
            cell.textLabel.textColor = FC1;
            cell.detailTextLabel.textColor = FC2;
            if (!cell) {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"attributeCell"];
                cell.textLabel.textColor = FC1;
                cell.detailTextLabel.textColor = FC2;
                cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
                cell.separatorLineInset = UIEdgeInsetsMake(0, 12, 0, 0);
            }
            cell.textLabel.text = profile.title;
            cell.detailTextLabel.text = profile.content.length > 0 ? profile.content : ASLocalizedString(@"KDSignInViewController_NOSetting");
            if (profile.attributeType == 1) {
                cell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            } else {
                cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
            }
            
            return cell;
        }
        
        
        NSString *reuseIdentifier = @"KDProfileTextCell";
        if (tableView.isEditing && profile.isCanEdit)
        {
            reuseIdentifier = @"KDProfileNewlyCell";
        }
        if (profile.original && [profile.original isKindOfClass:[NSString class]] && [profile.original isEqualToString:kProfileRowOriginalAdd])
        {
            reuseIdentifier = @"KDProfileTextCell";
        }
        
        KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        cell.textLabel.textColor = FC1;
        cell.detailTextLabel.textColor = FC2;
        
        if (!cell)
        {
            if([reuseIdentifier isEqualToString:@"KDProfileNewlyCell"])
            {
                cell = [[KDProfileNewlyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KDProfileNewlyCell"];
                cell.textLabel.textColor = FC1;
                cell.detailTextLabel.textColor = FC2;
            }
            else
            {
                cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"KDProfileTextCell"];
                cell.textLabel.textColor = FC1;
                cell.detailTextLabel.textColor = FC2;
            }
            
            cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
            cell.separatorLineInset = UIEdgeInsetsMake(0, 12, 0, 0);
        }
        
        if ([cell isKindOfClass:[KDProfileNewlyCell class]])
        {
            KDProfileNewlyCell *textCell = (KDProfileNewlyCell *)cell;
            textCell.titleLabel.text = profile.title;
            textCell.contentTextField.text = profile.content;
            textCell.contentTextField.placeholder = self.placeholders[profile.type];
            if (self.showData.type == KDProfileSectionTypeContactPhone) {
                textCell.contentTextField.keyboardType = UIKeyboardTypePhonePad;
            }
            else if (self.showData.type == KDProfileSectionTypeContactEmail) {
                textCell.contentTextField.keyboardType = UIKeyboardTypeEmailAddress;
            }
            else {
                textCell.contentTextField.keyboardType = UIKeyboardTypeDefault;
            }
            textCell.contentTextField.delegate = self;
            textCell.delegate = self;
            cell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
        }
        else
        {
            KDTableViewCell *textCell = (KDTableViewCell *)cell;
            textCell.textLabel.text = profile.title;
            textCell.detailTextLabel.text = profile.content;
            if(indexPath.row != RowPhone || [[BOSSetting sharedSetting] isIntergrationMode])
                textCell.accessoryStyle = KDTableViewCellAccessoryStyleNone;
            else
                textCell.accessoryStyle = KDTableViewCellAccessoryStyleDisclosureIndicator;
            
            [cell setNeedsUpdateConstraints];
        }
        
        return cell;
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case SectionHeader:
        {
            switch (indexPath.row) {
                case RowUserHeader:
                {
                    [self editUserProfile:nil];
                }
                    break;
                case RowUserName:
                {
                    if (![[[BOSSetting sharedSetting] hasInvitePermission] isEqualToString:@"2"]) {
                        
                        [KDEventAnalysis event:event_settings_personal_name];
                        KDSingleInputViewController *single = [[KDSingleInputViewController alloc] init];
                        single.content = [BOSConfig sharedConfig].user.name;
                        single.contentType = KDSingleInputContentTypeUsername;
                        single.block = ^(NSString *username) {
                            [self updateUsernameProfile:username];
                        };
                        [self.navigationController pushViewController:single animated:YES];
                    }
                    else{
                        //                        if ([[BOSSetting sharedSetting] isIntergrationMode]) {
                        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"ProfileViewController2_Alert_NoSuport")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                        [alertView show];
                        //[alertView release];
                        return ;
                        
                        //                        }
                    }
                }
                    break;
                case RowUserGender:
                {
                    if (![self canModifyContact:gender]) {
                        return;
                    }
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    UIAlertAction *maleAction = [UIAlertAction actionWithTitle:[self.person getGenderDescription:1] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self saveGender:1];
                    }];
                    [alert addAction:maleAction];
                    UIAlertAction *femaleAction = [UIAlertAction actionWithTitle:[self.person getGenderDescription:2] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self saveGender:2];
                    }];
                    [alert addAction:femaleAction];
                    UIAlertAction *undefineAction = [UIAlertAction actionWithTitle:[self.person getGenderDescription:0] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self saveGender:0];
                    }];
                    [alert addAction:undefineAction];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ASLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:cancelAction];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SectionContact:
        {
            //开启了集成，不允许修改
            if([[BOSSetting sharedSetting] isIntergrationMode])
                return;
            
            KDProfileRowDataModel *profile = self.showData.rows[indexPath.row];
            if (profile && [profile isKindOfClass:[KDProfileRowDataModel class]]) {
                if (profile.attributeType == 1 && profile.attributeId.length > 0) {
                    if (isAboveiOS8) {
                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:profile.title preferredStyle:UIAlertControllerStyleAlert];
                        
                       __block  UITextField * valueTextField = [UITextField new];
                        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            if (profile.content.length > 0) {
                                textField.text = profile.content;
                            }
                            valueTextField = textField;
                        }];
                        
                        __weak __typeof(self) weakSelf = self;
                        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            if (valueTextField.text.length > 0) {
                                if (!weakSelf.saveAttibuteClient) {
                                    weakSelf.saveAttibuteClient = [[XTOpenSystemClient alloc] initWithTarget:weakSelf action:@selector(savePersonAttributeDidReceive:result:)];
                                }
                                [weakSelf.saveAttibuteClient savePersonAttributeWithAttributeId:profile.attributeId value:valueTextField.text];
                            }
                            
                        }];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
                        [alertVC addAction:actionSure];
                        [alertVC addAction:cancel];
                        [self presentViewController:alertVC animated:YES completion:nil];
                        
                        
                    } else {
                        
                    }
                    return;
                }
            }
            
            
            switch (indexPath.row) {
                case RowPhone:
                {
                    if(![[BOSSetting sharedSetting] supportNotMobile]){
                        // Modified by Darren in 6.30
                        if ([[BOSConfig sharedConfig].user.phone length] == 0) {
                            KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
                            ctr.delegate = self;
                            ctr.type = KDPhoneInputTypeBind;
                            [self.navigationController pushViewController:ctr animated:YES];
                            //[ctr release];
                        } else {
                            KDPhoneBindingDisplayViewController *displayVC = [KDPhoneBindingDisplayViewController new];
                            displayVC.delegate = self;
                            [self.navigationController pushViewController:displayVC animated:YES];
                            // [displayVC release];
                        }
                    }
                    
                }
                    break;
                case RowPhone1:
                {
                    if (![self canModifyContact:officePhone1]) {
                        return;
                    }
                    
                    
                    if (isAboveiOS8) {
                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:ASLocalizedString(@"ProfileViewController2_tep1") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        
                        __weak __typeof(self) weakSelf = self;
                        __block  UITextField * valueTextField = [UITextField new];
                        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.text = weakSelf.person.phone1;
                            valueTextField = textField;
                        }];
                        
                        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            if([weakSelf isValidatePhone:valueTextField.text] || valueTextField.text.length == 0)
                                [weakSelf.saveOfficeClient saveOfficeWithName:@"phone1" AndValue:valueTextField.text];
                            else
                            {
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_tel")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                                [alert show];
                            }
                            
                        }];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
                        [alertVC addAction:actionSure];
                        [alertVC addAction:cancel];
                        [self presentViewController:alertVC animated:YES completion:nil];
                        
                        
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"ProfileViewController2_tep1")message:nil delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        UITextField *textField = [alertView textFieldAtIndex:0];
                        textField.text = self.person.phone1;
                        alertView.tag = 1001;
                        [alertView show];
                    }
                    
                    
                }
                    break;
                case RowPhone2:
                {
                    if (![self canModifyContact:officePhone2]) {
                        return;
                    }
                    
                    
                    if (isAboveiOS8) {
                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:ASLocalizedString(@"ProfileViewController2_tel2") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        
                        __weak __typeof(self) weakSelf = self;
                        __block  UITextField * valueTextField = [UITextField new];
                        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.text = weakSelf.person.phone2;
                            valueTextField = textField;
                        }];
                        
                        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            if([weakSelf isValidatePhone:valueTextField.text] || valueTextField.text.length == 0)
                                [weakSelf.saveOfficeClient saveOfficeWithName:@"phone2" AndValue:valueTextField.text];
                            else
                            {
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_tel")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                                [alert show];
                            }
                            
                        }];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
                        [alertVC addAction:actionSure];
                        [alertVC addAction:cancel];
                        [self presentViewController:alertVC animated:YES completion:nil];
                        
                        
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"ProfileViewController2_tel2")message:nil delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        UITextField *textField = [alertView textFieldAtIndex:0];
                        textField.text = self.person.phone2;
                        alertView.tag = 1002;
                        [alertView show];
                    }
                    
                }
                    break;
                case RowEmail:
                {
                    if (![self canModifyContact:emails]) {
                        return;
                    }
                    
                    if (isAboveiOS8) {
                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:ASLocalizedString(@"KDAuthViewController_email") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        
                        __weak __typeof(self) weakSelf = self;
                        __block  UITextField * valueTextField = [UITextField new];
                        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.text = weakSelf.person.systemEmail;
                            valueTextField = textField;
                        }];
                        
                        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            BOOL isVaildEmail = [weakSelf isValidateEmail:valueTextField.text];
                            if(!isVaildEmail  && valueTextField.text.length != 0)
                            {
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_Email")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                                [alert show];
                                
                                return;
                            }
                            
                            [self.saveOfficeClient saveOfficeWithName:@"email" AndValue:valueTextField.text];
                            
                        }];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
                        [alertVC addAction:actionSure];
                        [alertVC addAction:cancel];
                        [self presentViewController:alertVC animated:YES completion:nil];
                        
                        
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDAuthViewController_email")message:nil delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        UITextField *textField = [alertView textFieldAtIndex:0];
                        textField.text = self.person.systemEmail;
                        alertView.tag = 1003;
                        [alertView show];
                    }
                    
                    
                }
                    break;
                case RowBrithday:
                {
                    if (![self canModifyContact:birthday]) {
                        return;
                    }
                    __weak ProfileViewController2 *selfInBlock = self;
                    self.datePicker.leftbtnTappedEventHander = ^(void) {
                        [selfInBlock dismissDatePicker];
                    };
                    
                    self.datePicker.rightTappedEventHander = ^(void) {
                        [selfInBlock dismissDatePicker];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSString *birthday = [dateFormatter stringFromDate:selfInBlock.datePicker.date];
                        
                        [selfInBlock.saveOfficeClient saveOfficeWithName:@"birthday" AndValue:birthday];
                    };
                    
                    NSDate *date = [NSDate date];
                    if(self.person.birthday.length>0)
                    {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        date = [dateFormatter dateFromString:self.person.birthday];
                    }
                    self.datePicker.date = date;
                    [self displayDatePicker];
                }
                    break;
                    /*case 1:
                     {
                     if ([[BOSConfig sharedConfig].user.email length] == 0) {
                     
                     KDBindEmailViewController *ctr = [[KDBindEmailViewController alloc] init];
                     ctr.delegate = self;
                     ctr.fromType = 1;
                     [self.navigationController pushViewController:ctr animated:YES];
                     [ctr release];
                     }
                     }
                     break; */
                    /*case 2:
                     {
                     if (![[BOSSetting sharedSetting] isIntergrationMode]) {
                     
                     [KDEventAnalysis event:event_settings_personal_department_open];
                     KDChooseDepartmentViewController *vc = [[KDChooseDepartmentViewController alloc] init];
                     vc.delegate = self;
                     [self.navigationController pushViewController:vc animated:YES];
                     [vc release];
                     }
                     else{
                     if ([[BOSSetting sharedSetting] isIntergrationMode]) {
                     UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"温馨提示")message:ASLocalizedString(@"ProfileViewController2_Alert_NoFix")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: nil];
                     [alertView show];
                     [alertView release];
                     return ;
                     
                     }
                     }
                     
                     }
                     break;*/
            }
            
        }
            break;
        case SectionCompany:
        {
            switch (indexPath.row)
            {
            }
            
        }
            break;

        case SectionWeibo:
        {
            switch (indexPath.row) {
                    
                case 0:
                {
                    DraftViewController *dvc = [[DraftViewController alloc] initWithNibName:nil bundle:nil];
                    [[self navigationController] pushViewController:dvc animated:YES];
                    //[dvc release];
                }
                    break;
                case 1:
                {
                    [self gotoProfileViewDetailControllerAtIndex:0];
                }
                    break;
                case 2:
                {
                    [[KDManagerContext globalManagerContext].unreadManager changeFollowersBadgeValue:YES];
                    [self gotoProfileViewDetailControllerAtIndex:1];
                }
                    break;
                case 3:
                {
                    [self gotoProfileViewDetailControllerAtIndex:2];
                }
                    break;
                case 4:
                {
                    [self gotoProfileViewDetailControllerAtIndex:3];
                }
                    break;
                case 5:
                {
                    [self gotoProfileViewDetailControllerAtIndex:4];
                }
                    break;
                    
            }
        }
            
    }
    
}

- (void)savePersonAttributeDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (result.success) {
        [self loadPersonInfo];
    } else {
        [KDPopup showHUDToast:ASLocalizedString(@"修改失败，请稍后再试") inView:self.view];
    }
}

-(void)saveGender:(int)gender
{
    [KDPopup showHUDInView:self.view];
    self.person.gender = gender;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:RowUserGender inSection:SectionHeader]] withRowAnimation:UITableViewRowAnimationNone];
    [self.saveOfficeClient saveOfficeWithName:@"gender" AndValue:@(gender).description];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //外部员工不能看微博
    if([BOSConfig sharedConfig].user.partnerType == 1)
        return 3;
    return 4;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SectionHeader:
            return @"";
            break;
        case SectionCompany:
            return ASLocalizedString(@"ProfileViewController2_Company_text");
            break;
        case SectionContact:
            return ASLocalizedString(@"ProfileViewController2_Contact_txt");
            break;
        case SectionWeibo:
            return ASLocalizedString(@"ProfileViewController2_weibo_Link");
            break;
        default:
            return @"";
            break;
    }
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 1;
    
    if(section == SectionHeader)
        rows = (self.bTeamAccount?2:3);
    
    if(section == SectionCompany)
        rows = 3;
    
    if(section == SectionContact)
        rows = self.showData.rows.count;
    
    if(section == SectionWeibo)
        rows = 6;
    
    if (self.bTeamAccount && (section == SectionContact || section == SectionCompany)) {
        rows = 0;
    }
    return rows;
}


- (void)refreshData
{
    //    NSMutableArray *sectionFlags = [NSMutableArray array];
    //    NSMutableArray *sections = [NSMutableArray array];
    
    if (self.person)
    {
        if(!self.originalContacts)
            self.originalContacts = [[NSMutableArray alloc] initWithCapacity:self.person.contact.count+4];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:self.person.contact.count+4];
        [tempArray removeAllObjects];
        
        [self.originalContacts removeAllObjects];
        
        KDProfileSectionDataModel *phoneSection = [self buildContact:self.person.phoneArray type:KDProfileSectionTypeContactPhone];
        KDProfileSectionDataModel *emailSection = [self buildContact:self.person.emailArray type:KDProfileSectionTypeContactEmail];
        KDProfileSectionDataModel *otherSection = [self buildContact:self.person.otherArray type:KDProfileSectionTypeContactOther];
        
        [tempArray addObject:ASLocalizedString(@"ProfileViewController2_Account_hu")];//加这个拿来占位的而已
        [tempArray addObject:ASLocalizedString(@"ProfileViewController2_tel2")];//加这个拿来占位的而已
        [tempArray addObject:ASLocalizedString(@"ProfileViewController2_tel2")];//加这个拿来占位的而已
        [tempArray addObject:ASLocalizedString(@"KDAuthViewController_email")];//加这个拿来占位的而已
        [tempArray addObject:ASLocalizedString(@"ProfileViewController2_Birth")];//加这个拿来占位的而已
        [tempArray addObjectsFromArray:phoneSection.rows];
        [tempArray addObjectsFromArray:emailSection.rows];
        [tempArray addObjectsFromArray:otherSection.rows];
        
        // 自定义字段
        KDProfileSectionDataModel *attributesSection = [self buildContactAttribute:self.person.attributesArray];
        [tempArray addObjectsFromArray:attributesSection.rows];
        
        KDProfileSectionDataModel *contactSection = [[KDProfileSectionDataModel alloc] initWithTitle:ASLocalizedString(@"ProfileViewController2_Contact_txt")type:KDProfileSectionTypeContactAllContact rows:tempArray];
        
        //        if (contactSection)
        //        {
        //            [sectionFlags addObject:@(1)];
        //            [sections addObject:contactSection];
        //        }
        //        else {
        //            [sectionFlags addObject:@(0)];
        //        }
        
        self.showData = contactSection;
    }
    
    [self.tableView reloadData];
//    NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:SectionContact];
//    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (KDProfileSectionDataModel *)buildContactAttribute:(NSArray *)array {
    NSMutableArray *data = [NSMutableArray array];
    if (array.count > 0) {
        for (KDContactAttributeInfo *contact in array) {
            KDProfileRowDataModel *row = [KDProfileRowDataModel new];
            row.attributeId = contact.attributeId;
            row.title = contact.name;
            row.content = contact.value;
            row.attributeType = contact.type;
            [data addObject:row];
            [self.originalContacts addObject:[NSString stringWithFormat:@"%@-%@",contact.name,contact.value]];
        }
    }
    
    if ([data count] > 0) {
        return [[KDProfileSectionDataModel alloc] initWithTitle:ASLocalizedString(@"ProfileViewController2_Contact_txt")type:KDProfileSectionTypeContactOther rows:data];
    }
    
    return nil;
}

- (KDProfileSectionDataModel *)buildContact:(NSArray *)array type:(KDProfileSectionType)type {
    
    __block NSMutableArray *data = [NSMutableArray array];
    if ([array count] > 0) {
        [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            KDContactInfo *contactInfo = (KDContactInfo *)obj;
            if (contactInfo.name.length > 0 && contactInfo.value.length > 0) {
                KDProfileRowDataModel *row = [[KDProfileRowDataModel alloc] initWithTitle:contactInfo.name content:contactInfo.value original:contactInfo];
                row.type = type;
                [data addObject:row];
                [self.originalContacts addObject:[NSString stringWithFormat:@"%@-%@",contactInfo.name,contactInfo.value]];
            }
        }];
    }
    
    if ([data count] > 0) {
        return [[KDProfileSectionDataModel alloc] initWithTitle:ASLocalizedString(@"ProfileViewController2_Contact_txt")type:type rows:data];
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == SectionContact && indexPath.row > RowBrithday)
    {
        KDProfileRowDataModel *profile = ((KDProfileRowDataModel *)self.showData.rows[indexPath.row]);
        return profile.isCanEdit;
    }
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == SectionContact && indexPath.row > RowBrithday)
    {
        KDProfileRowDataModel *profile = ((KDProfileRowDataModel *)self.showData.rows[indexPath.row]);
        return profile.style;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCell:indexPath];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert){
        [self addCell:indexPath];
    }
}

- (void)deleteCell:(NSIndexPath *)indexPath
{
    //KDProfileRowDataModel *profile = ((KDProfileRowDataModel *)self.showData.rows[indexPath.row]);
    [self.showData.rows removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addCell:(NSIndexPath *)indexPath
{
    KDProfileRowDataModel *addProfile = ((KDProfileRowDataModel *)self.showData.rows[indexPath.row]);
    int index = (int)self.showData.rows.count-3;
    KDProfileRowDataModel *profile = [[KDProfileRowDataModel alloc] initWithTitle:[self.tags[addProfile.type] firstObject]  content:nil original:kProfileRowOriginalNewly];
    profile.type = addProfile.type;
    
    [self.showData.rows insertObject:profile atIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self performSelector:@selector(contentTextFieldBecomeFirstResponder:) withObject:(KDProfileNewlyCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexPath.section]] afterDelay:0.25];
    
}

- (void)contentTextFieldBecomeFirstResponder:(KDProfileNewlyCell *)cell
{
    if([cell isKindOfClass:[KDProfileNewlyCell class]])
        [cell.contentTextField becomeFirstResponder];
}

#pragma mark KDProfileNewlyCellDelegate
- (void)titleLabelDidClick:(KDProfileNewlyCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.selectedIndexPath = indexPath;
    
    KDProfileRowDataModel *profile = ((KDProfileRowDataModel *)self.showData.rows[indexPath.row]);
    
    KDProfileTagsViewController *tagsViewController = [[KDProfileTagsViewController alloc] initWithTags:self.tags[profile.type] customTags:self.customTags currentTag:cell.titleLabel.text];
    tagsViewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagsViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.textField && self.textField != textField) {
        [self.textField resignFirstResponder];
    }
    
    self.textField = textField;
    if ([textField.superview.superview isKindOfClass:[KDProfileNewlyCell class]]) {
        KDProfileNewlyCell *cell = (KDProfileNewlyCell *)textField.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField.superview.superview isKindOfClass:[KDProfileNewlyCell class]]) {
        KDProfileNewlyCell *cell = (KDProfileNewlyCell *)textField.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        KDProfileRowDataModel *row = self.showData.rows[indexPath.row];
        row.content = textField.text;
    }
}

- (NSMutableArray *)customTags {
    if (_customTags == nil) {
        _customTags = [NSMutableArray array];
    }
    return _customTags;
}

#pragma mark KDProfileTagsViewControllerDelegate
- (void)didSelect:(KDProfileTagsViewController *)controller tag:(NSString *)tag {
    if (tag.length == 0) {
        return;
    }
    
    if (![self.customTags containsObject:tag]) {
        [self.customTags addObject:tag];
    }
    KDProfileNewlyCell *cell = (KDProfileNewlyCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    cell.titleLabel.text = tag;
    KDProfileRowDataModel *row = (KDProfileRowDataModel *)(self.showData.rows[self.selectedIndexPath.row]);
    row.title = tag;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
    
        if(alertView.tag == 1001)
        {
            if([self isValidatePhone:textField.text] || textField.text.length == 0)
                [self.saveOfficeClient saveOfficeWithName:@"phone1" AndValue:textField.text];
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_tel")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
            }
        }
        else if(alertView.tag == 1002)
        {
            if([self isValidatePhone:textField.text] || textField.text.length == 0)
                [self.saveOfficeClient saveOfficeWithName:@"phone2" AndValue:textField.text];
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_tel")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
            }
        }
        else if(alertView.tag == 1003)
        {
            BOOL isVaildEmail = [self isValidateEmail:textField.text];
            if(!isVaildEmail  && textField.text.length != 0)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Alert_Email")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
                
                return;
            }

            [self.saveOfficeClient saveOfficeWithName:@"email" AndValue:textField.text];
        }
    }
}

-(XTOpenSystemClient *)saveOfficeClient
{
    if (!_saveOfficeClient) {
        _saveOfficeClient = [[XTOpenSystemClient alloc] initWithTarget:self action:@selector(saveOffice:result:)];
    }
    return _saveOfficeClient;
}

- (void)saveOffice:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [KDPopup hideHUDInView:self.view];
    if (result.success)
    {
        [self loadPersonInfo];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ASLocalizedString(@"ProfileViewController2_Setting_Fail")delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -  DatePicker Stuff
- (KDDatePickerViewController *)datePicker
{
    if (!_datePicker)
    {
        _datePicker = [[KDDatePickerViewController alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return _datePicker;
}

- (void)displayDatePicker
{
    [self.datePicker showInView:self.navigationController.view];
}

- (void)dismissDatePicker
{
    [self.datePicker hide];
}

- (BOOL)canModifyContact:(SystemContactType)contactType {
    if (self.person.mutableArray.count == 0) {
        return NO;
    }
    
    NSString *contactStr = @"";
    switch (contactType) {
        case officePhone1:
            contactStr = @"officePhone1";
            break;
        case officePhone2:
            contactStr = @"officePhone2";
            break;
        case emails:
            contactStr = @"emails";
            break;
        case birthday:
            contactStr = @"birthday";
            break;
        case gender:
            contactStr = @"gender";
            break;
            
        default:
            break;
    }
    
    BOOL flag = NO;
    for (NSString *str in self.person.mutableArray) {
        if ([str isEqualToString:contactStr]) {
            flag = YES;
            break;
        }
    }
    return flag;
}


@end
