//
//  DraftViewController.m
//  TwitterFon
//
//  Created by kingdee on 11-6-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "DraftViewController.h"
#import "PostViewController.h"

#import "DraftTableViewCell.h"
#import "KDWeiboAppDelegate.h"
#import "ResourceManager.h"

#import "KDDraft.h"

#import "KDDefaultViewControllerContext.h"
#import "KDWeiboDAOManager.h"
#import "KDDatabaseHelper.h"
#import "KDManagerContext.h"
#import "KDDraftManager.h"

#define ALERT_VIEW_EMPTY_TAG   10
#define ALERT_VIEW_DELETE_SINGLE_TAG 11

@interface DraftViewController ()

@property (nonatomic, retain) NSMutableArray *drafts;
@property (nonatomic, retain)UITableView *tableView;

@end


@implementation DraftViewController

@synthesize drafts=drafts_;
@synthesize tableView = tableView_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        drafts_ = nil;
        selectedIndex_ = NSNotFound;
        
        draftViewControllerFlags_.viewDidDisappear = 0;
        
        self.navigationItem.title = ASLocalizedString(@"ProfileViewController2_Draft");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostDraft:) name:kKDPostViewControllerDraftSendNotification object:nil];
    }
    
    return self;
}

- (void) loadView {
    [super loadView];
    
    //读取未发送微博
    //[self reloadDB];
    
    
    self.navigationItem.rightBarButtonItems = [KDCommon rightNavigationItemWithTitle:ASLocalizedString(@"EMPTY")target:self action:@selector(emptyBtnTapped:)];

    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView = tableView;
//    [tableView release];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGBCOLOR(237, 237, 237);
    self.tableView.backgroundView = nil;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void) reloadData {
    [self reloadDB];
    [self.tableView reloadData];
    UIBarButtonItem *barButtonItem = nil;
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
//         barButtonItem = self.navigationItem.rightBarButtonItem;
//    }else {
//        barButtonItem = (self.navigationItem.rightBarButtonItems)[1];
//    }
    if(drafts_ && [drafts_ count] > 0) {
        barButtonItem.enabled = YES;
    }
    else {
        barButtonItem.enabled = NO;
    }
}

- (void)reloadDB {
    NSString *userId = [KDManagerContext globalManagerContext].userManager.currentUserId;
    
    // TODO: change to async mode in the future please.
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        NSArray *drafts = [draftDAO queryAllDraftsWithAuthorId:userId type:DraftNotInSending database:fmdb];
        
        return drafts;
        
    } completionBlock:^(id results) {
        self.drafts = (NSMutableArray *)results;
    }];
}

- (void) reloadDraftAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (DraftTableViewCell *) draftCellAtIndex:(NSInteger)index {
    DraftTableViewCell* cell = nil;
    if(NSNotFound != index){
        NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
        if(visibleIndexPaths != nil) {
            BOOL found = NO;
            for(NSIndexPath *indexPath in visibleIndexPaths){
                if(index == indexPath.row) {
                    found = YES;
                    break;
                }
            }
            
            if(found) {
                cell = (DraftTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0x00]];
            }
        }
    }
    
    return cell;
}

- (void) didSaveDraftToDatabase:(KDDraft *)draft {
    if(drafts_ != nil) {
        NSUInteger index = [drafts_ indexOfObject:draft];
        DraftTableViewCell* cell = [self draftCellAtIndex:index];
        if(cell != nil){
            [cell refresh];
        }
    }
}

- (void)draftIsSending:(KDDraft *)draft
{
    NSUInteger index = [self indexOfDraft:draft.draftId];
    if(NSNotFound != index){
        DraftTableViewCell* cell = [self draftCellAtIndex:index];
        if(cell != nil){
            cell.isSending = YES;
            [cell refresh];
        }
    }
}

- (void)didPostDraft:(NSNotification *)notification
{
    NSDictionary *info = (NSDictionary *)notification.object;
    KDDraft *draft = [info objectForKey:@"draft"];
    BOOL isPost = [[info objectForKey:@"isPost"] boolValue];
    draftViewControllerFlags_.viewDidDisappear = 1;
    [self didPostDraft:draft succeed:isPost];
}

- (void) didPostDraft:(KDDraft *)draft succeed:(BOOL)succeed {
    if (draftViewControllerFlags_.viewDidDisappear == 1) {
        [self reloadDB];
        [self.tableView reloadData];
    }
}

- (void)updateSendingProgress:(NSNotification *)nofitifation
{
    NSDictionary *info = nofitifation.object;
    NSNumber *progress = [info objectForKey:@"progress"];
    NSString *draftId = [[[info objectForKey:@"statusId"] componentsSeparatedByString:@"_"] lastObject];
    NSInteger iDraftId = [draftId integerValue];
    DraftTableViewCell *cell = [self draftCellAtIndex:[self indexOfDraft:iDraftId]];
    if (cell.sendingProgress.hidden) {
        cell.sendingProgress.hidden = NO;
    }
    [cell.sendingProgress setAvtivityIndicatorStartAnimation:YES];
    [cell.sendingProgress setProgressPercent:[progress floatValue] info:nil];
}


- (NSUInteger)indexOfDraft:(NSInteger)draftId
{
    for (KDDraft *temp in self.drafts) {
        if (temp.draftId == draftId) {
            return [self.drafts indexOfObject:temp];
        }
    }
    return NSNotFound;
}

- (void)deleteDraftAtIndex:(NSInteger)index {
    KDDraft *draft = [drafts_ objectAtIndex:index];
    [self deleteDrafts:@[draft]];
//    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
//        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
//        BOOL success = [draftDAO removeDraftWithId:draft.draftId database:fmdb];
//        return @(success);
//        
//    } completionBlock:^(id results) {
//        BOOL succeed = [(NSNumber *)results boolValue];
//        
//        if (succeed) {
//            [drafts_ removeObject:draft];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
//            
//        } else {
//            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"DELETE_DRAFT_DID_FAIL", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
//            
//            [alterView show];
//            [alterView release];
//        }
//    }];
}

- (void)editDraftAtIndex:(NSInteger)index {
    KDDraft *draft = [drafts_ objectAtIndex:index];
    if([draft propertyForKey:kKDDraftBlockedPropertyKey] != nil){
        // If current draft was blocked, It's not allow to open the editor
        return;
    }
    
    [draft setProperty:[NSNumber numberWithBool:YES] forKey:kKDDraftBlockedPropertyKey];
    
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    __block PostViewController *pvc = [factory getPostViewController];
    
    if ([draft hasVideo]) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
            id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
            NSData *data = [draftDAO queryDraftImageDataWithId:draft.draftId database:fmdb];
            return data;
            
        } completionBlock:^(id results) {
            if (results != nil) {
                NSArray *imagePath = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:results];
                [pvc setVideoThumbnail:imagePath];
            }
        }];
    }else if ([draft hasImages]) {
        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
            id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
            NSData *data = [draftDAO queryDraftImageDataWithId:draft.draftId database:fmdb];
            return data;
            
        } completionBlock:^(id results) {
            if (results != nil) {
                NSArray *imagePath = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:results];
                [pvc setPickedImage:imagePath];
            }
        }];
    }
    pvc.draft = draft;
    pvc.draftViewController = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];// autorelease];
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        [self presentViewController:nav animated:YES completion:nil];
     }
}


- (void)deleteDrafts:(NSArray *)draftArray {
    if (!draftArray || [draftArray count] == 0) {
        return;
    }
    [[KDDraftManager shareDraftManager] deleteDrafts:draftArray completionBlock:^(id results) {
        BOOL succeed = [(NSNumber *)results boolValue];
        
        if (succeed) {
            // [drafts_ removeObject:draft];
            NSMutableArray *indexPaths = [NSMutableArray array];
            
            NSMutableArray *deleteStatusInTimeline = nil; //在timeline 中对应的草稿也要被清除
            for (KDDraft *draft in draftArray) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:[drafts_  indexOfObject:draft] inSection:0]];
                
                //发送通知，

//                [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusShouldDeleted object:self userInfo:@{@"status": status}];
                if (!deleteStatusInTimeline) {
                    deleteStatusInTimeline = [NSMutableArray array];
                }
                KDStatus *status = [[KDStatus alloc] init];// autorelease];
                status.statusId = [NSString stringWithFormat:@"%ld",(long)draft.draftId];
                status.groupId = draft.groupId;
                [deleteStatusInTimeline addObject:status];
                [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusShouldDeleted object:self userInfo:@{@"status": deleteStatusInTimeline}];
            }
            
            [drafts_ removeObjectsInArray:draftArray];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            
        } else {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"DELETE_DRAFT_DID_FAIL", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
            
            [alterView show];
//            [alterView release];
        }
        
    }];
    /*
    [KDDatabaseHelper asyncInTransaction:(id)^(FMDatabase *fmdb, BOOL *rollBack) {
        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        __block BOOL success = YES;
        __block KDDraft * draft = nil;
        [self.drafts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           draft = obj;
           success =  [draftDAO removeDraftWithId:[draft draftId] database:fmdb];
            if (!success) {
                *stop = YES;
            }
            if (!draft.groupId) { // 删除在数据库中对应的微博
               [statusDAO removeStatusWithId:[NSString stringWithFormat:@"%d",draft.draftId] database:fmdb];
            }else {
               [statusDAO removeGroupStatusWithId:[NSString stringWithFormat:@"%d",draft.draftId] database:fmdb];
            }
            
        }];
        *rollBack = !success;
        return @(success);
    } completionBlock:^(id results) {
        BOOL succeed = [(NSNumber *)results boolValue];
        
        if (succeed) {
           // [drafts_ removeObject:draft];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (KDDraft *draft in draftArray) {
               [indexPaths addObject:[NSIndexPath indexPathForRow:[drafts_  indexOfObject:draft] inSection:0]];
            }
            [drafts_ removeObjectsInArray:draftArray];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            
        } else {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"DELETE_DRAFT_DID_FAIL", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
            
            [alterView show];
            [alterView release];
        }
    }];
*/
}


- (void) emptyAllDrafts {
    
    NSArray *array = [NSArray arrayWithArray:drafts_];
    [self deleteDrafts:array];
    
    // TODO: change to async mode in the future please.
//    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb) {
//        id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
//        BOOL success = [draftDAO removeAllDraftsInDatabase:fmdb];
//        return @(success);
//        
//    } completionBlock:^(id results) {
//        BOOL success = [(NSNumber *)results boolValue];
//        
//        if (success) {
//            NSInteger count = [self.drafts count];
//            [self.drafts removeAllObjects];
//            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];
//            for (NSInteger i = 0; i<count; i++) {
//                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//            }
//            
//            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
//            
//        } else {
//            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"DELETE_DRAFT_DID_FAIL", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
//            
//            [alterView show];
//            [alterView release];
//        }
//    }];
}


////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (drafts_ != nil) ? [drafts_ count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DraftCell";
    DraftTableViewCell* cell = (DraftTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DraftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        // 长按手势
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [cell addGestureRecognizer:longPressGesture];
//        [longPressGesture release];

    }
    
    cell.draft = [drafts_ objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDDraft *draft = [drafts_ objectAtIndex:indexPath.row];
    return [draft getRowHeight];
}



//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//   // KDDraft *draft = [drafts_ objectAtIndex:indexPath.row];
//  }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex_ = indexPath.row;
    [self editDraftAtIndex:selectedIndex_];
}
#pragma mark - event handler
- (void) emptyBtnTapped:(id)sender {
    if ([self.drafts count] > 0) {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"EMPTY_DRAFTS_WARNING", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OKAY", @"")
                                                  otherButtonTitles:ASLocalizedString(@"Global_Cancel"),nil];
        alterView.tag = ALERT_VIEW_EMPTY_TAG;
        [alterView show];
//        [alterView release];
    }
   
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *cellIndexPath = [self.tableView indexPathForRowAtPoint:[longPressGesture locationInView:self.tableView]];
        selectedIndex_ = cellIndexPath.row;
        
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:ASLocalizedString(@"Global_Cancel") destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"EDIT_DRAFT",@"" ), NSLocalizedString(@"DELETE_DRAFT",@"" ) ,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        actionSheet.destructiveButtonIndex = 1;
        [actionSheet showInView:self.view];
//        [actionSheet release];
//     
    }
}

#pragma mark - UIAlertView Delegate Methods 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_VIEW_EMPTY_TAG) {
       if (buttonIndex == 0) { //点击确定
           [self emptyAllDrafts];
        }

    } else if (alertView.tag == ALERT_VIEW_DELETE_SINGLE_TAG) {
        [self deleteDraftAtIndex:selectedIndex_];
    }
    
}

#pragma mark - UIActionSheet Delegate Methods 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { //进入编辑
        
        [self editDraftAtIndex:selectedIndex_];
        
    } else if (buttonIndex == 1) {//删除草稿
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"DELETE_DRAFT_WARNING", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OKAY", @"")
                                                  otherButtonTitles:ASLocalizedString(@"Global_Cancel"),nil];
        alterView.tag = ALERT_VIEW_DELETE_SINGLE_TAG;
        [alterView show];
//        [alterView release];
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
#pragma mark - view life cycle
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    draftViewControllerFlags_.viewDidDisappear = 1;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(drafts_);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

@end
