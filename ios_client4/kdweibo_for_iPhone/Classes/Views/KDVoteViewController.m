//
//  KDVoteViewController.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/30/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDVoteViewController.h"

#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"
#import "KDVoteTitleView.h"
//#import "KDVoteHasBeenDelectView.h"

#import "CommenMethod.h"

#import "KDRequestDispatcher.h"
#import "KDWeiboServicesContext.h"
#import "KDDatabaseHelper.h"
#import "KDAccountTipView.h"

@interface KDVoteViewController() {
     
}

@property(nonatomic, retain) KDVoteView * voteView;
@property(nonatomic, retain) KDVote *vote;
@property(nonatomic, retain) NSArray *tempVoteItmeIdList;
@property(nonatomic, retain) MBProgressHUD *activityIndicatorView;

@end

@implementation KDVoteViewController {
    BOOL isVoteDetailClientLoaded_;
    BOOL isVotedGetVoteResult_;
    BOOL voting_;
}

@synthesize voteView = _voteView;
@synthesize vote = vote_;
@synthesize voteId = voteId_;
@synthesize tempVoteItmeIdList = voteItmeIdList_;
@synthesize activityIndicatorView = activityIndicatorView_;

- (id)init
{
    self = [super init];
    if (self) {
           voting_ = NO;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"微博正文";
//    [self setUpVoteView];
    
    [self.view addSubview:self.voteView];
    
    [self.voteView makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(63, 0, 0, 0));
     }];
    
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
        id<KDVoteDAO> voteDAO = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
        KDVote *vote = [voteDAO queryVoteWithId:self.voteId database:fmdb];
        return vote;
    } completionBlock:^(id results){
        self.vote = results;
        if (vote_ != nil) {
            if ([self isVoteHasBeenDelect]) {
                [self showHasBeenDelectView];
                
            } else {
                [self.voteView reloadData];
            }
        }
        
        if (!isVoteDetailClientLoaded_) {
            [self getVoteInfo];
            isVoteDetailClientLoaded_ = YES;
        }
    }];
}

- (void)showHasBeenDelectView {
//    KDVoteHasBeenDelectView *voteHasBeenDelectView = [CommenMethod getMainViewFromNib:[KDVoteHasBeenDelectView class] owner:nil];
//    voteHasBeenDelectView.frame = self.view.bounds;
//    voteHasBeenDelectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleWidth;
//    
//    [self.view addSubview:voteHasBeenDelectView];
    [[[[KDAccountTipView alloc] initWithTitle:@"" message:@"投票已删除" buttonTitle:@"确定" completeBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }] autorelease] showWithType:KDAccountTipViewTypeAlert window:self.view.window];
}

- (void)voteHadBeenDelectAction {
    vote_.state = KDVoteStateDeleted;
    
    // update the state of vote
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
        id<KDVoteDAO> voteDAO = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
        [voteDAO saveVote:vote_ database:fmdb];
        
        return nil;
        
    } completionBlock:nil];
    
    [self showHasBeenDelectView];
}

- (void)alterShareVoteSuccess {
    UIAlertView *alterViewe = [[UIAlertView alloc] initWithTitle:@"投票成功"
                                                         message:@"是否分享投票结果？"
                                                        delegate:self cancelButtonTitle:@"不，谢谢" otherButtonTitles:@"分享", nil];
    [alterViewe show];
    [alterViewe release];
}

- (void)alterShareVoteHasEnd {
    UIAlertView *alterViewe = [[UIAlertView alloc] initWithTitle:@"" 
                                                         message:@"该投票已结束，参与不了了" 
                                                        delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alterViewe show];
    [alterViewe release];
}

- (void)getVoteInfo {
    if (![self isVoting]) {
        [self showHUD];
        [self disableToolbarButtonsWhenStartSharing];
        [self disableNavBarItem];
    }
 
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.voteId];
    [query setProperty:self.voteId forKey:@"voteId"];
    
    __block KDVoteViewController *vvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                KDVote *vote = [info objectForKey:@"vote"];
                int code = [info intForKey:@"code"];
                
                if (code == 500) {
                    [vvc voteHadBeenDelectAction];
                    
                } else {
                    vvc.vote = vote;
                    
                    [vvc.voteView reloadData];
                    
                    if (vvc -> isVotedGetVoteResult_) {
                        vvc -> isVotedGetVoteResult_ = NO;
                        
                        if (vvc.vote.isEnded) {
                            [vvc alterShareVoteHasEnd];
                            
                        } else {
                            [vvc alterShareVoteSuccess];
                        }
                    }
                    
                    // save vote into database
                    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
                        id<KDVoteDAO> voteDAO = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
                        [voteDAO saveVote:vote database:fmdb];
                        
                        return nil;
                        
                    } completionBlock:nil];
                }
            }
            
        } else {
            if (![response isCancelled]) {
                if (404 == [response statusCode]) {
                    [vvc voteHadBeenDelectAction];
                    
                } else {
                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                                  inView:vvc.view.window];
                }
            }
        }
        
        if ([vvc isVoting]) {
            vvc -> voting_ = NO;
        }
        
        [vvc enableNavBarItem];
        [vvc enableToolbarButtonsWhenEndSharing];
        [vvc dismissHUD];
        
        // release current view controller
        [vvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:resultById" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)disableNavBarItem {

     //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    UIBarButtonItem *leftBarButtonItem = nil;
    UIBarButtonItem *rightBarButtonItem = nil;
    //2013-12-26 song.wang
    leftBarButtonItem = [self.navigationItem.leftBarButtonItems lastObject];
    rightBarButtonItem = [self.navigationItem.rightBarButtonItems lastObject];

    leftBarButtonItem.enabled = NO;
    rightBarButtonItem.enabled = NO;
}

- (void)enableNavBarItem {
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    UIBarButtonItem *leftBarButtonItem = nil;
    UIBarButtonItem *rightBarButtonItem = nil;
    //2013-12-26 song.wang
    leftBarButtonItem = [self.navigationItem.leftBarButtonItems lastObject];
    rightBarButtonItem = [self.navigationItem.rightBarButtonItems lastObject];
    leftBarButtonItem.enabled = YES;
    rightBarButtonItem.enabled = YES;
   
}


- (void)disableToolbarButtonsWhenStartSharing {
    [self.voteView disableButtons];
}

- (void)enableToolbarButtonsWhenEndSharing {
    [self.voteView enableButtons];
}

- (void)voteAction {
    [self disableNavBarItem];
    [self disableToolbarButtonsWhenStartSharing];
    voting_ = YES;
    [self showHUD];
    
    NSString *optionIds = [CommenMethod getStringSeperaByCommaWithStrArr:self.tempVoteItmeIdList];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"id" stringValue:vote_.voteId]
            setParameter:@"optionIds" stringValue:optionIds];
    
    __block KDVoteViewController *vvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if ([(NSNumber *)results boolValue]) {
                vvc -> isVotedGetVoteResult_ = YES;
                
                [vvc getVoteInfo];
            }
            
        } else {
            if (![response isCancelled]) {
                if (404 == [response statusCode]) {
                    [vvc voteHadBeenDelectAction];
                    
                } else {
                    UIAlertView *alterViewe = [[UIAlertView alloc] initWithTitle:@""
                                                                         message:@"噢，出了点问题，投票不成功，稍后再试一下吧"
                                                                        delegate:vvc cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alterViewe show];
                    [alterViewe release];
                }
            }
        }
        
        [vvc enableNavBarItem];
        [vvc enableToolbarButtonsWhenEndSharing];
        [vvc dismissHUD];
        
        // release current view controller
        [vvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:vote" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)voteShare {
    [self disableToolbarButtonsWhenStartSharing];
    
    KDQuery *query = [KDQuery queryWithName:@"id" value:vote_.voteId];
    
    __block KDVoteViewController *vvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([(NSNumber *)results boolValue]) {
            [[[KDWeiboAppDelegate getAppDelegate] getOverlay] postFinishMessage:@"分享成功" duration:2.0 animated:YES];
        }
        
        [vvc enableToolbarButtonsWhenEndSharing];
        
        // release current view controller
        [vvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:share" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (BOOL)isVoteHasBeenDelect {
    if (vote_ == nil) {
        return NO;
    }
    
    return [vote_ isDeleted];
}

//check if is votting
- (BOOL)isVoting {
    if (voting_) {
        return YES;
    }
    
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDVoteViewDelegate 

- (KDVote *)kDVoteViewGetVoteData:(KDVoteView *)voteView {
    return vote_;
}

- (void)KDVoteViewRefreshActionWith:(KDVoteView *)voteView {
    if ([self isVoting]) {
    
    } else {
        [self getVoteInfo];
    }
}

- (void)KDVoteViewRefreshVoteActionWith:(KDVoteView*)voteView
                        voteItmeIdList:(NSArray *)voteItmeIdList {
    self.tempVoteItmeIdList = voteItmeIdList;
    [self voteAction];
}

////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self voteShare];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.voteView = nil;
}


#pragma mark  - MBProgressHUD {

- (void)showHUD {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) dismissHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



- (KDVoteView*)voteView
{
    if (_voteView == nil) {
        _voteView = [[KDVoteView alloc]init];
        _voteView.delegate = self;
        _voteView.backgroundColor = [UIColor whiteColor];
        _voteView.userInteractionEnabled = YES;
    }
    return _voteView;
}
- (void)dealloc {
    KD_RELEASE_SAFELY(_voteView);
    KD_RELEASE_SAFELY(vote_);
    KD_RELEASE_SAFELY(voteId_);
    KD_RELEASE_SAFELY(voteItmeIdList_);
    
    [super dealloc];
}

@end
