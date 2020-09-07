//
//  KDTaskEditorViewController.m
//  kdweibo
//
//  Created by bird on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskEditorViewController.h"
#import "KDTask.h"
#import "KDTrendEditorViewController.h"
#import "KDUserPortraitGroupView.h"
#import "MBProgressHUD.h"
#import "KDWeiboServicesContext.h"
#import "KDErrorDisplayView.h"
#import "KDNotificationView.h"
#import "XTDataBaseDao.h"
#import "ContactClient.h"

#define KD_TODOLIST_RELOAD_NOTIFICATION         @"kd_todolist_reload_notification"

@interface KDTaskEditorViewController ()<KDFrequentContactsPickViewControllerDelegate, KDTrendEditorViewControllerDelegate, KDUserPortraitDelegate,XTChooseContentViewControllerDelegate>


@property(nonatomic,strong)NSArray *exectors;
@property(nonatomic,strong)XTChooseContentViewController *exectorsContentVC;
@property(nonatomic,strong)ContactClient *personClient;


//@property (nonatomic, retain) KDFrequentContactsPickViewController *executorsPickerVC;
//@property (nonatomic, retain) KDFrequentContactsPickViewController *atSomeOneVC;
@end

@implementation KDTaskEditorViewController
@synthesize delegate = delegate_;
@synthesize type = type_;
- (id)initWithTask:(KDTask *)task
{
    self = [super init];
    if (self) {
        // Custom initialization
        task_ = task;// retain];
        
        if ([KDUser isCurrentSignedUserWithId:task_.creator.userId] && ![task isOver])
        { type_ = KDTaskPageEditorType;
            self.title = ASLocalizedString(@"KDTaskEditorViewController_title");
        }
        else
        {
            type_ = KDTaskPageDetailType;
            self.title = ASLocalizedString(@"KDTaskDetailView_task_detail");
        }
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    [KDWeiboAppDelegate setExtendedLayout:self];

    NSMutableArray *wbUserids = [NSMutableArray array];
    [task_.executors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDUser *user = (KDUser *)obj;
        [wbUserids addObject:user.userId];
    }];
    
    
//    self.exectors = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllPersonWithWbPersonIds:wbUserids];
    [self.personClient getPersonsWithWBUserIds:wbUserids];
    
    
    CGRect frame = self.view.bounds;
    frame.origin.y+=64;
    editorView_ = [[KDTaskEditorView alloc] initWithFrame:frame];
    editorView_.type = type_;
    editorView_.delegate = self;
    editorView_.task  = task_;
    editorView_.status = _status;
    [self.view addSubview:editorView_];
    
    if (type_ == KDTaskPageEditorType)
        [self initItems];
    
}
- (void)initItems
{
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"KDABActionTabBar_tips_2")style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];
//    [rightItem release];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(ContactClient *)personClient
{
    if(_personClient == nil)
    {
        _personClient = [[ContactClient alloc] initWithTarget:self action:@selector(personsDidReceive:result:)];
    }
    return _personClient;
}

-(void)personsDidReceive:(ContactClient *)client result:(BOSResultDataModel *)result
{
    if (result.success)
    {
        NSMutableArray *persons = [NSMutableArray array];
        NSArray *jsonPersons = result.data[@"personInfos"];
        [jsonPersons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonSimpleDataModel *person = [[PersonSimpleDataModel alloc] initWithDictionary:obj];
            if(person)
                [persons addObject:person];
        }];
        self.exectors = persons;
    }
    else
    {
        self.exectors = nil;
    }
}

#pragma mark - items action methods

- (void)dismissSelf {
    
    if ([editorView_.textView isFirstResponder])
        [editorView_.textView resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender {

    if ([editorView_.textView isFirstResponder])
        [editorView_.textView resignFirstResponder];
    
    [self update];
    
}
#pragma mark - network update

- (void)update {
    
    if (![editorView_ checkInfo])
        return;
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    KDQuery *query = [KDQuery query];
    [query setProperty:task_.taskNewId forKey:@"id"];
    [query setParameter:@"content" stringValue:[editorView_ content]];
    [query setParameter:@"needFinishDate" stringValue: [editorView_ finishDate]];
    [query setParameter:@"executors" stringValue:[editorView_ executorsIds]];
    KDTaskEditorViewController *ctaskVC = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [MBProgressHUD hideHUDForView:self.view.window animated:YES];
        NSString *message = nil;
        BOOL success = NO;
        if ([response isValidResponse]) {
            NSDictionary *resultDic = results;
            success = [resultDic boolForKey:@"success"];
            if (!success) {
                message = [resultDic stringForKey:@"errormsg"];
            }else {
                KDTask *task = [resultDic objectForKey:@"task"];
                if (task) {
                    if (delegate_ && [delegate_ respondsToSelector:@selector(taskHasUpdated:)]) {
                        [delegate_ taskHasUpdated:task];
                    }
                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:KD_TODOLIST_RELOAD_NOTIFICATION object:nil];
                }
                [[KDNotificationView defaultMessageNotificationView] showInView:ctaskVC.view.window message: ASLocalizedString(@"KDTaskEditorViewController_Success")type:KDNotificationViewTypeNormal];
                [ctaskVC dismissSelf];
            }
        }else {
            if (![response isCancelled]) {
                message = [response.responseDiagnosis networkErrorMessage];
            }
        }
        
        if (message) {
            NSRange range = [message rangeOfString:ASLocalizedString(@"三分钟")];
            if (range.location != NSNotFound) {
                [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window message: ASLocalizedString(@"创建任务失败:三分钟之内不能创建重复的任务")type:KDNotificationViewTypeNormal];
//                [ctaskVC release];
                return ;
            }
            range = [message rangeOfString:ASLocalizedString(@"还没加入")];
            if (range.location != NSNotFound) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alertView show];
//                [alertView release];
//                [ctaskVC release];
                return ;
            }
            [KDErrorDisplayView showErrorMessage:message  inView:ctaskVC.view.window];
        }
        
//        [ctaskVC release];
        
    };
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/task/:update" query:query
                                 configBlock:nil completionBlock:completionBlock];

    
}

#pragma mark - XTChooseContentViewControllerDelegate delegate method

//选择了一个或者多个人（仅用于XTChooseContentAdd 和 XTChooseContentJSChoose）
- (void)chooseContentView:(XTChooseContentViewController *)controller persons:(NSArray *)persons
{
    if(controller == self.exectorsContentVC)
    {
        //添加任务执行人
        self.exectors = persons;
        
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
        
        [editorView_ updateExecutors:array];
    }
    else
    {
        //@人
        NSMutableString *text = [NSMutableString string];
        if (persons != nil && [persons count] > 0) {
            for (PersonSimpleDataModel *item in persons) {
                [text appendFormat:@"@%@ ", item.personName];
            }
            
            [editorView_ appendText:text];
        }
        
    }
}


#pragma mark - TaskEditorViewAction
- (void)toAtViewController
{
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.isFromConversation = NO;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self.navigationController presentViewController:contentNav animated:YES completion:nil];
}
- (void)toTopicViewController
{
    KDTrendEditorViewController *tevc = [[KDTrendEditorViewController alloc] initWithNibName:nil bundle:nil];
    tevc.delegate = self;
    
    [self.navigationController pushViewController:tevc animated:YES];
//    [tevc release];
}
#pragma mark - KDTrendEditorViewController delegate method

- (void)trendEditorViewController:(KDTrendEditorViewController *)tevc didPickTopicText:(NSString *)topicText {
    [editorView_ appendText:topicText];
}

#pragma mark -  KDUserPortraitDelegate

- (void)editorContactsWithUsers:(NSArray *)users
{
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentAdd];
    contentViewController.delegate = self;
    contentViewController.isFromConversation = NO;
    contentViewController.selectedPersons = self.exectors;
    contentViewController.blockCurrentUser = NO;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self.navigationController presentViewController:contentNav animated:YES completion:nil];
    
    self.exectorsContentVC = contentViewController;
}

@end
