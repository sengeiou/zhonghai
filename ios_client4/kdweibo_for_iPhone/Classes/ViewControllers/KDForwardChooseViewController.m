//
//  KDForwardChooseViewController.m
//  kdweibo
//
//  Created by kyle on 16/8/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDForwardChooseViewController.h"
#import "KDSignInViewController.h"
#import "XTContactContentTopViewCell.h"
#import "KDContactGroupDataModel.h"
#import "XTSearchMultipleChoiceCell.h"
#import "KDImportantGroupCell.h"
//#import "XTContactHelper.h"
#import "XTContactPersonViewCell.h"
#import "UIAlertView+Blocks.h"
//#import "KDAddColleaguesManager.h"
#import "XTContactGroupViewController.h"
#import "NSData+Base64.h"
#import "ASIHTTPRequest+OAuth.h"
#import "KDConfigurationContext.h"
#import "UIAlertView+Blocks.h"
//#import "KDChooseManager.h"
#import "KDTableViewHeaderFooterView.h"
#import "UIBarButtonItem+Custom.h"
#import "KDImageAlertView.h"
#import "XTForwardDataModel.h"
#import "KDImageEditorViewController.h"

#define XTContactContentCellIdentifier		@"XTContactContentTopCellIdentifier"
#define XTContactPersonViewCellIdentifier	@"XTContactPersonViewCellIdentifier"
#define XTContactSearchCellIdentifier		@"XTContactSearchCellIdentifier"

@interface KDForwardChooseViewController ()<KKImageEditorDelegate, UISearchBarDelegate, XTGroupTimelineViewControllerDelegate, /*XTContactGroupViewControllerDelegate,*/XTShareViewDelegate,UITextFieldDelegate,XTChooseContentViewControllerDelegate/*, KDChooseManagerDelegate*/>

@property (nonatomic, strong) NSMutableArray *recentContactGroups;
@property (nonatomic, strong) NSMutableArray *topSectionNames;
@property (nonatomic, strong) NSMutableArray *topSectionImageNames;

@property (nonatomic, strong) NSMutableArray *groupSearchResults;
@property (nonatomic, strong) NSString *searchText;

@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) XTShareStartView *shareView;

@property (nonatomic, strong) ContactClient *sendMessageClient;

@property (nonatomic, strong) NSString *strDefaultGroupId;
@property (nonatomic, strong) NSString *strDefaultPersonId;

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) BOOL needSendLeaveMessage;

@property (nonatomic, assign) BOOL isMultChooseGroup;
@property (nonatomic, strong) PersonSimpleDataModel *newsFowardPerson;
@end

@implementation KDForwardChooseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.groupSearchResults = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCreateExtenalGroup:(BOOL)isExternalGroup {
    self = [self init];
    if (self) {
        self.bCreateExtenalGroup = isExternalGroup;
    }
    
    return self;
}

- (NSMutableArray *)getRecentGroups {
    NSMutableArray *groups = [[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupListWithLimit:100 offset:0] mutableCopy];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (GroupDataModel *model in groups) {
        
        if(model.groupType == GroupTypeDouble && model.participant.count>0 && (![((PersonSimpleDataModel *)[model.participant firstObject]) accountAvailable]))
            continue;
        else if (model.groupType == GroupTypeDouble || model.groupType == GroupTypeMany) {
            if (![model isExternalGroup]) {
                [tempArr addObject:model];
            }else{
                if (self.bCreateExtenalGroup) {
                    [tempArr addObject:model];
                }
            }
        }
    }
    
    return tempArr;
}

- (NSMutableArray *)topSectionNames {
    if (!_topSectionNames) {
        _topSectionNames = [[NSMutableArray alloc]init];
    }
    [_topSectionNames setArray:@[ASLocalizedString(@"KDForward_New_Chat"), ASLocalizedString(@"XTChooseContentViewController_Chat"),ASLocalizedString(@"XTPubAccHistoryViewController_File_transfer")]];
    
    return _topSectionNames;
}

- (NSMutableArray *)topSectionImageNames {
    if (!_topSectionImageNames) {
        _topSectionImageNames = [[NSMutableArray alloc]init];
    }
    [_topSectionImageNames setArray:@[@"contacts_tip_create", @"contacts_tip_session",@"file_tip_folder"]];
    return _topSectionImageNames;
}

- (void)setShareData:(XTShareDataModel *)shareData {
    _shareData = shareData;
    
    id groupId = [shareData.params objectForKey:@"groupId"];
    if (![groupId isKindOfClass:[NSNull class]] && groupId) {
        self.strDefaultGroupId = (NSString *)groupId;
    }
    id personId = [shareData.params objectForKey:@"personId"];
    if (![personId isKindOfClass:[NSNull class]] && personId) {
        self.strDefaultPersonId = (NSString *)personId;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (self.strDefaultGroupId.length > 0) {
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:self.strDefaultGroupId];
        
        if (group) {
            self.shareView.group = group;
            self.shareView.person = nil;
            [self showShareStartView:YES image:self.shareData.params[@"screenimage"]];
        }
    } else if (self.strDefaultPersonId.length > 0) {
        GroupDataModel *group = nil;//[[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPersonId:self.strDefaultPersonId];
        if (group) {
            self.shareView.group = group;
            self.shareView.person = nil;
            [self showShareStartView:YES image:self.shareData.params[@"screenimage"]];
        } else {
            PersonSimpleDataModel *person = [KDCacheHelper personForKey:self.strDefaultPersonId];
            if (person) {
                self.shareView.group = nil;
                self.shareView.person = person;
                [self showShareStartView:YES image:self.shareData.params[@"screenimage"]];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ASLocalizedString(@"KDForward_Select");

    needsToLayoutTableView_ = 0;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem kd_makeLeftItemWithTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close") color:FC5 target:self action:@selector(cancel:)];
    self.leftBarItems = self.navigationItem.leftBarButtonItems;
    if(self.isMulti)
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem kd_makeRightItemWithTitle:ASLocalizedString(@"KDForward_Multiple") color:FC5 target:self action:@selector(inEditModel)];
    
    //[self.kdSearchBar setCustomPlaceholder:@"搜索"];
    
    self.tableView.frame = CGRectMake(0.0, CGRectGetMaxY(self.kdSearchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.kdSearchBar.frame) - 44.0);
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.kdSearchBar.bottom);
        make.bottom.equalTo(self.view.bottom);
    }];
    
    __weak KDForwardChooseViewController *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakself.recentContactGroups = [weakself getRecentGroups];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    });
    // Do any additional setup after loading the view.
}

- (void)inEditModel {
    
    XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentForwardMulti];
    contentViewController.createByType = self.type;
    contentViewController.isFromConversation = YES;
    contentViewController.delegate = self;
    contentViewController.forwardData = self.forwardData;
    contentViewController.shareData = self.shareData;
    [self.navigationController pushViewController:contentViewController animated:YES];

    
//    KDChooseConfigModel *model = [KDChooseConfigModel new];
//    model.isMultChooseGroup = YES;
//    self.isMultChooseGroup = YES;
//    __weak __typeof(self) weakSelf = self;
//    [[KDChooseManager shareKDChooseManager] startChoosePersonsOrGroupWithGroup:nil viewController:self configModel:model isNeedPersons:YES isPush:YES delegate:nil complition:^(NSArray *persons, GroupDataModel *newGroup, BOOL isCreateNew) {
//        if (persons.count > 0) {
//            for (PersonSimpleDataModel *person in persons) {
//                if (person.isGroupIdOrPersonId) {
//                    GroupDataModel *group = [[GroupDataModel alloc] init];
//                    group.groupId = person.personId;
//                    group.groupName = person.personName;
//                    [weakSelf multChooseFinishWithGroup:group person:nil];
//                } else {
//                    [weakSelf multChooseFinishWithGroup:nil person:person];
//                }
//            }
//        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf dismissViewControllerAnimated:YES completion:^{
//                [KDPopup showHUDToast:@"转发完成"];
//            }];
//        });
//    }];
}

- (void)multChooseFinishWithGroup:(GroupDataModel *)group person:(PersonSimpleDataModel *)person {
    if (self.type == XTChooseContentForward) {
        [self forwardMessageWithGroup:group person:person];
    } else if (self.type == XTChooseContentShare) {
        [self applicationSharedWithGroup:group person:person];
    } else if (self.type == XTChooseContentShareStatus) {
        [self completeShareStatusWithGroup:group person:person];
    }
}

- (void)cancel:(UIButton *)btn {
    BOOL animated = !(self.shareData.params && self.shareData.params[@"screenimage"]);
    [self dismissViewControllerAnimated:animated completion:nil];
}

- (MBProgressHUD *)progressHud {
    if (_progressHud == nil) {
        _progressHud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        _progressHud.delegate = self;
        _progressHud.removeFromSuperViewOnHide = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:_progressHud];    }
    return _progressHud;
}

- (XTShareStartView *)shareView {
    if (_shareView == nil) {
        _shareView = [[XTShareStartView alloc] initWithShareData:self.shareData];
    }
    _shareView.delegate = self;
    //_shareView.shareTextField.delegate = self;
    return _shareView;
}

#pragma UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (state_ == KDContactViewStateNormal) {
        if (section == 0) {
            return [self.topSectionNames count];
        }else if (section == 1) {
            return [self.recentContactGroups count];
        }
    }else if (state_ == KDContactViewStateSearch) {
        if (section == 0) {
            return [self.displayContacts count];
        }else if (section == 1) {
            return [self.groupSearchResults count];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (state_ == KDContactViewStateNormal) {
        if (section == 0 ) {
            XTContactContentTopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactContentCellIdentifier];
            
            if (!cell) {
                cell = [[XTContactContentTopViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactContentCellIdentifier];
            }
            
            cell.discoveryLabel.text = self.topSectionNames[row];
            [cell.avatarImageView setImage:[UIImage imageNamed:self.topSectionImageNames[row]]];
            cell.separatorLineStyle = (indexPath.row == [self.topSectionNames count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
            
            return cell;
        }
        if (section == 1 ) {
            static NSString *CellIdentifier = @"CellIdentifier";
            KDImportantGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[KDImportantGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            GroupDataModel *groupDM = [self.recentContactGroups safeObjectAtIndex:indexPath.row];
            cell.group = groupDM;
            cell.isExtenal = groupDM.isExternalGroup;
            
            return cell;
        }
    } else if (state_ == KDContactViewStateSearch) {
        if (section == 0) {
            PersonSimpleDataModel *person = self.displayContacts[indexPath.row];
            XTContactPersonViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XTContactPersonViewCellIdentifier];
            if (!cell) {
                cell = [[XTContactPersonViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XTContactPersonViewCellIdentifier];
            }
            cell.person = person;
            [cell setDisplayDepartment:YES];
            //[cell setupCellData:person hidenDepartment:YES];
            cell.separatorLineStyle = (indexPath.row == [self.displayContacts count] - 1) ? KDTableViewCellSeparatorLineNone : KDTableViewCellSeparatorLineSpace;
            
            return cell;
        }else if (section == 1) {
            static NSString *CellIdentifier = @"CellIdentifier";
            KDImportantGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[KDImportantGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            GroupDataModel *groupDM = [self.groupSearchResults safeObjectAtIndex:indexPath.row];
            cell.group = groupDM;
            cell.isExtenal = groupDM.isExternalGroup;
            
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (state_ == KDContactViewStateSearch) {
            if ([self.displayContacts count] < 1) {
                return 0.1;
            }
            return [KDTableViewHeaderFooterView heightWithStyle:KDTableViewHeaderFooterViewStyleWhite];
        }else{
            return 0.1;
        }
    }
    if (section == 1) {
        if (state_ == KDContactViewStateSearch && [self.groupSearchResults count] < 1) {
            return 0.1;
        }
        return [KDTableViewHeaderFooterView heightWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (state_ == KDContactViewStateNormal) {
        if (section == 1) {
            KDTableViewHeaderFooterView *view = [[KDTableViewHeaderFooterView alloc] initWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
            view.title = ASLocalizedString(@"KDForward_Recent_Chat");
            return view;
        }
        else {
            return nil;
        }
    } else if (state_ == KDContactViewStateSearch){
        if (section == 0) {
            if ([self.displayContacts count] < 1) {
                return nil;
            }
            KDTableViewHeaderFooterView *view = [[KDTableViewHeaderFooterView alloc] initWithStyle:KDTableViewHeaderFooterViewStyleWhite];
            view.title = ASLocalizedString(@"联系人");
            return view;
        }else if (section == 1) {
            if ([self.groupSearchResults count] < 1) {
                return nil;
            }
            KDTableViewHeaderFooterView *view = [[KDTableViewHeaderFooterView alloc] initWithStyle:KDTableViewHeaderFooterViewStyleGrayWhite];
            view.title = ASLocalizedString(@"群组");
            return view;
        }
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ 
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (state_ == KDContactViewStateNormal) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                
                XTChooseContentViewController *contentViewController = [[XTChooseContentViewController alloc] initWithType:XTChooseContentCreate];
                contentViewController.createByType = self.type;
                contentViewController.isFromConversation = YES;
                contentViewController.delegate = self;
                contentViewController.forwardData = self.forwardData;
                [self.navigationController pushViewController:contentViewController animated:YES];
                
//                __weak KDForwardChooseViewController *weakself = self;
//                KDChooseConfigModel *configModel = [[KDChooseConfigModel alloc] init];
//                configModel.topGroupIsExtenalGroup = self.bCreateExtenalGroup;
//                configModel.dataSources = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:KDChoosePersonTopItemTypeOrganization], [NSNumber numberWithInteger:KDChoosePersonTopItemTypeGroup], nil];
//                if (self.bCreateExtenalGroup) {
//                    [configModel.dataSources addObject:[NSNumber numberWithInteger:KDChoosePersonTopItemTypeExternalFriend]];
//                }
//                [[KDChooseManager shareKDChooseManager] startChoosePersonsOrGroupWithGroup:self.group
//                                                                            viewController:self
//                                                                               configModel:configModel
//                                                                             isNeedPersons:NO
//                                                                                    isPush:YES
//                                                                                  delegate:self
//                                                                                complition:^(NSArray *persons, GroupDataModel *newGroup, BOOL isCreateNew) {
//                        [weakself finishSelectWithGroup:newGroup person:[persons firstObject] isShowSelf:NO];
//                }];
            } else if (indexPath.row == 1) {
                //已有会话
                XTGroupTimelineViewController *groupTimeline = [[XTGroupTimelineViewController alloc] init];
                groupTimeline.delegate = self;
                [self.navigationController pushViewController:groupTimeline animated:YES];
                return;

                
////                if (self.isMultChooseGroup) {
//                    XTGroupTimelineViewController *groupTimeline = [[XTGroupTimelineViewController alloc] initWithisExtenalGroup:self.bCreateExtenalGroup];
//                    groupTimeline.delegate = self;
//                    [self.navigationController pushViewController:groupTimeline animated:YES];
////                } else {
////                    XTContactGroupViewController *vc = [[XTContactGroupViewController alloc] initWithIsExternGroup:self.bCreateExtenalGroup];
////                    vc.delegate = self;
////                    [KDEventAnalysis event:event_forward_important_group];
////                    [self.navigationController pushViewController:vc animated:YES];
////                }
            } else if (indexPath.row == 2) {
                PersonDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicPersonSimple:kFilePersonId];
                
                KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:person.personId];
                person.status = pubacc.status;
                person.state = pubacc.state;
                person.reply = pubacc.reply;
                
                //[KDEventAnalysis event:event_forward_file];
                GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
//                if(group == nil)
//                {
//                    group = [[GroupDataModel alloc] initWithParticipant:person];
//                    group.groupType = GroupTypePublic;
//                    group.groupName = person.personName;
//                    group.menu = person.menu;
//                    
//                    //强制给它赋值
//                    if (person.menu.length > 0 && !(group.menu.length > 0)) {
//                        group.menu = person.menu;
//                    }
//                }
                
                if (group) {
                    [self finishSelectWithGroup:group person:nil isShowSelf:YES];
                } else {
                    if (!person) {
                        person = [[PersonDataModel alloc] init];
                        person.personId = kFilePersonId;
                        person.status = 11;
                    }
                    [self finishSelectWithGroup:nil person:person isShowSelf:YES];
                }
                
                
            }
        } else if (indexPath.section == 1) {
            GroupDataModel *model = [self.recentContactGroups safeObjectAtIndex:indexPath.row];
            //[KDEventAnalysis event:event_forward_recentchat];
            [self finishSelectWithGroup:model person:nil isShowSelf:YES];
        }
    } else if (state_ == KDContactViewStateSearch) {
        if (indexPath.section == 0) {
            PersonSimpleDataModel *person= self.displayContacts[indexPath.row];
            [self finishSelectWithGroup:nil person:person isShowSelf:YES];
        } else if (indexPath.section == 1) {
            GroupDataModel *groupDM = [self.groupSearchResults safeObjectAtIndex:indexPath.row];
            GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithGroupId:groupDM.groupId];
            if(group)
                [self finishSelectWithGroup:group person:nil isShowSelf:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (void)finishSelectWithGroup:(GroupDataModel *)group person:(PersonSimpleDataModel *)person isShowSelf:(BOOL)isShowSelf{
    
    //未激活人不给转发,手机账号环境才需要过滤未激活人员
    if(!group && person)
    {
        if(![person xtAvailable] && ![BOSSetting sharedSetting].supportNotMobile)
        {
            [KDPopup showHUDToast:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27")];
            return;
        }
    }
    
    if (group && [group.participantIds count] > 0) {
        self.group = group;
        
        if(![self.group isManager] && [self.group slienceOpened])
        {
            NSString *msg = ASLocalizedString(@"该群组已全员禁言,\n无法转发消息到此群");
            if (self.type == XTChooseContentShare || self.type == XTChooseContentShareStatus)
                msg = ASLocalizedString(@"该群组已全员禁言,\n无法分享消息到此群");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:ASLocalizedString(@"KDApplicationQueryAppsHelper_no") otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    
    if (self.type == XTChooseContentForward) {
        if (group && group.groupName) {
            [self finishSelectGroup:group isShowSelf:isShowSelf];
            return;
        }
        if (person && person.personName) {
            [self finishSelectPerson:person isShowSelf:isShowSelf];
        }
    } else if (self.type == XTChooseContentShare) {
        
        if(group == nil && person)
            group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
        
        if (!isShowSelf) {
            self.shareView.group = group;
            self.shareView.person = person;
            [self completeChooseShare];
            return;
        }
        //分享
        self.shareView.group = group;
        self.shareView.person = person;
        [self showShareStartView:YES];
    } else if (self.type == XTChooseContentShareStatus) {
        if (!isShowSelf) {
            [self completeShareStatusWithGroup:group person:person];
            return;
        }
        NSMutableString *content = [NSMutableString string];
        if (group) {
            if (group.groupType == GroupTypeDouble) {
                [content appendFormat:ASLocalizedString(@"XTChatViewController_Tip_5"), group.groupName];
            } else {
                [content appendFormat:[NSString stringWithFormat:@"%@%@",ASLocalizedString(@"XTChatViewController_Tip_5"),@"(%lu)"], group.groupName, group.participant.count];
            }
        } else if (person) {
            [content appendFormat:ASLocalizedString(@"XTChatViewController_Tip_5"), person.personName];
        }
        
        __weak KDForwardChooseViewController *weakSelf = self;
        if ([self canEditImage]) {
            XTForwardDataModel *forwardData = [self getImageForwardData];
            if (forwardData && forwardData.originalUrl.description.length > 0) {
            }
            
            [[SDWebImageManager sharedManager] downloadWithURL:forwardData.originalUrl options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    KDImageAlertView *alert = [[KDImageAlertView alloc] initWithTitle:content Image:image];
                    alert.clickConfirmBlock = ^{
                        [weakSelf completeShareStatusWithGroup:group person:person];
                    };
                    alert.editImageBlock = ^{
                        [weakSelf goToImageEditorWithImage:image];
                    };
                    [alert showImageAlert];
                } else {
                    [KDPopup showHUD:ASLocalizedString(@"图片加载失败")];
                }
            }];
        } else {
            [UIAlertView showWithTitle:content message:@"" cancelButtonTitle:ASLocalizedString(@"KDAgoraSDKManager_Tip_9") otherButtonTitles:@[ASLocalizedString(@"KDAgoraSDKManager_Tip_10")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex != alertView.cancelButtonIndex) {
                    [self completeShareStatusWithGroup:group person:person];
                }
            }];
        }
        
    }
}

- (void)completeShareStatusWithGroup:(GroupDataModel *)group person:(PersonSimpleDataModel *)person {
    if (group) {
        [self sendShareStatusWithGroupId:group.groupId orUserId:nil];
    } else if (person) {
        GroupDataModel *group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
        self.newsFowardPerson = person;
        [self sendShareStatusWithGroupId:group.groupId orUserId:person.personId];
    }
}

- (void)finishSelectGroup:(GroupDataModel *)group {
    [self dismissViewControllerAnimated:NO completion:^{
        if (group != nil) {
            
            if (!_delegate || ![_delegate respondsToSelector:@selector(popViewController)])
                [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
            
            if (_type == XTChooseContentForward) {
                if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                    [_delegate popViewController];
                }
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:group, @"group", _forwardData, @"forwardDM", nil];
                if (self.fileDetailDictionary) {
                    dict[@"orginGroupDetail"] = self.fileDetailDictionary;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"forwardGroupMessage" object:nil userInfo:dict];
            }
            else {
                if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                    [_delegate popViewController];
                }
            }
        }
    }];
}

- (void)finishSelectGroup:(GroupDataModel *)group isShowSelf:(BOOL)isShowSelf{
    NSString *title = @"";
    if (!isShowSelf) {
        [self finishSelectGroup:group];
        return;
    }
    if (self.type == XTChooseContentForward) {
        if (group.groupType == GroupTypeDouble || (group.participant.count>0 && [((PersonSimpleDataModel *)(group.participant.firstObject)).personId isEqualToString:kFilePersonId]) ) {
            title = [NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_5"), group.groupName];
        } else {
            title = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@",ASLocalizedString(@"XTChatViewController_Tip_5"),ASLocalizedString(@"XTChatViewController_Tip_61")], group.groupName, group.participantIds.count+1];
//            if ([group isExternalGroup] && ![self.group isExternalGroup]) {
//                title = [title stringByAppendingString:@"\n该群组含非同事成员,请注意隐私安全"];
//            }
        }
        
        __weak KDForwardChooseViewController *weakSelf = self;
        if ([self canEditImage]) {
            
            XTForwardDataModel *forwardData = [self getImageForwardData];
            
            [[SDWebImageManager sharedManager] downloadWithURL:forwardData.originalUrl options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    KDImageAlertView *alert = [[KDImageAlertView alloc] initWithTitle:title Image:image];
                    alert.clickConfirmBlock = ^{
                        [weakSelf finishSelectGroup:group];
                    };
                    alert.editImageBlock = ^{
                        [weakSelf goToImageEditorWithImage:image];
                    };
                    [alert showImageAlert];
                } else {
                    [KDPopup showHUDToast:ASLocalizedString(@"图片加载失败") inView:self.view];
                }
            }];
        } else {
            [UIAlertView showWithTitle:title message:nil cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:@[ASLocalizedString(@"Global_Sure")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex != alertView.cancelButtonIndex) {
                    [self finishSelectGroup:group];
                }
            }];
        }
        
    }else{
        [self finishSelectGroup:group];
    }
}

- (void)finishSelectPerson:(PersonSimpleDataModel *)person isShowSelf:(BOOL)isShowSelf{
    //__weak __typeof(self) weakSelf = self;
    
    [self operateAfterFinishSelectPerson:person isShowSelf:isShowSelf];
//    if (person.unVerifiedUser) {
//        [KDPopup showHUD];
//        [[KDAddColleaguesManager sharedAddColleaguesManager] getExContactWithPhone:[person.defaultPhone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
//                                                                              name:[person.personName  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
//                                                                             extid:person.personId
//                                                                           groupId:@""
//                                                                        inviteType:@""
//                                                                     completeBlock:^(BOOL success,NSString *userId,NSString *error) {
//            if (success) {
//                [KDPopup hideHUD];
//                [weakSelf operateAfterFinishSelectPerson:person isShowSelf:isShowSelf];
//            } else {
//                [KDPopup hideHUD];
//            }
//        }];
//    } else {
//        [self operateAfterFinishSelectPerson:person isShowSelf:isShowSelf];
//    }
}

- (void)operateAfterFinishSelectPerson:(PersonSimpleDataModel *)person {
    [self dismissViewControllerAnimated:NO completion:^{
        if (person != nil) {
            if (_type == XTChooseContentForward) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:person, @"person", _forwardData, @"forwardDM", nil];
                if (self.fileDetailDictionary) {
                    dict[@"orginGroupDetail"] = self.fileDetailDictionary;
                }
                if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                    [_delegate popViewController];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"forwardPersonMessage" object:nil userInfo:dict];
            }
            else {
                if (_delegate && [_delegate respondsToSelector:@selector(popViewController)]) {
                    [_delegate popViewController];
                }
            }
            
            [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
        }
    }];
}

- (void)operateAfterFinishSelectPerson:(PersonSimpleDataModel *)person isShowSelf:(BOOL)isShowSelf{
    
    if (!isShowSelf) {
        [self operateAfterFinishSelectPerson:person];
        return;
    }
    
    self.newsFowardPerson = person;
    NSString *title = @"";
    title = [NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_5"), person.personName];
    
    __weak KDForwardChooseViewController *weakSelf = self;
    if ([self canEditImage]) {
        
        XTForwardDataModel *forwardData = [self getImageForwardData];
        
        [[SDWebImageManager sharedManager] downloadWithURL:forwardData.originalUrl options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
            if (image) {
                KDImageAlertView *alert = [[KDImageAlertView alloc] initWithTitle:title Image:image];
                alert.clickConfirmBlock = ^{
                    [self operateAfterFinishSelectPerson:person];
                };
                alert.editImageBlock = ^{
                    [weakSelf goToImageEditorWithImage:image];
                };
                [alert showImageAlert];
            } else {
                [KDPopup showHUDToast:ASLocalizedString(@"图片加载失败") inView:self.view];
            }
        }];
    } else {
        [UIAlertView showWithTitle:title message:nil cancelButtonTitle:ASLocalizedString(@"Global_Cancel") otherButtonTitles:@[ASLocalizedString(@"Global_Sure")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [self operateAfterFinishSelectPerson:person];
            }
        }];
    }
}

#pragma mark - 发送消息

- (void)sendShareStatusWithGroupId:(NSString *)groupId orUserId:(NSString *)userId {
    XTShareNewsDataModel *news = self.shareData.mediaObject;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:self.shareData.appName forKey:@"appName"];
    [param setObject:@(self.shareData.unreadMonitor) forKey:@"unreadMonitor"];
    [param setObject:news.title forKey:@"title"];
    [param setObject:news.content forKey:@"content"];
    if (news.thumbURL) {
        [param setObject:news.thumbURL forKey:@"thumbUrl"];
    }
    
    if (news.thumbData) {
        [param setObject:news.thumbData forKey:@"thumbData"];
    }
    [param setObject:news.webpageUrl forKey:@"webpageUrl"];
    
    if (self.shareData.appId.length > 0) {
        [param setObject:self.shareData.appId forKey:@"appId"];
    }
    
    NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    
    if (paramJsonData) {
        NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
        [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:userId msgType:MessageTypeShareNews content:news.title msgLent:(int)news.title.length param:paramJsonString clientMsgId:[ContactUtils uuid]];
    }
}

- (void)showShareStartView:(BOOL)show {
    //打开分享界面
    if (state_ == KDContactViewStateSearch)
    {
        [self.view endEditing:YES];
    }
    [self showShareStartView:show image:nil];
}

- (void)showShareStartView:(BOOL)show image:(UIImage *)image {
    //打开分享界面
    if (show && image) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
        CGRect frame = self.view.bounds;
        SetHeight(frame, frame.size.height);
        [backgroundView setFrame:frame];
        [self.rt_navigationController.view addSubview:backgroundView];
    }
    
    //如果是分享红包，则自动跳过确认界面
//    if (self.type == XTChooseContentShare && (self.shareData.shareType == ShareMessageRedPacket || self.shareData.shareType == ShareMessageCombineForward)) {
//        if (self.shareView) {
//            if (self.strDefaultGroupId.length > 0 || self.strDefaultPersonId.length > 0) {
//                //[self shareView:self.shareView clickedButtonAtIndex:self.shareView.sendButtonIndex];
//            }
//            else {
//                NSString *title = @"确定发送";
//                
//                GroupDataModel *group = self.shareView.group;
//                if (group) {
//                    if (group.groupType == GroupTypeDouble) {
//                        title = [NSString stringWithFormat:@"确定发送给：%@", group.groupName];
//                    } else {
//                        title = [NSString stringWithFormat:@"确定发送给：%@(%lu人)", group.groupName, group.participant.count];
//                    }
//                }
//                else if ([self.wantCreateChatPersons count] > 0) {
//                    NSString *name = ((PersonSimpleDataModel *)[self.wantCreateChatPersons firstObject]).personName;
//                    for (int i = 1; i < [self.wantCreateChatPersons count] && i < 3; i++) {
//                        name = [name stringByAppendingFormat:@"、%@", ((PersonSimpleDataModel *)self.wantCreateChatPersons[i]).personName];
//                    }
//                    title = [NSString stringWithFormat:@"确定发送给：%@等(%lu人)", name, (unsigned long)[self.wantCreateChatPersons count]];
//                }
//                
//                [UIAlertView showWithTitle:title message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    if (buttonIndex == !alertView.cancelButtonIndex) {
//                        if (self.shareView) {
//                            //[self shareView:self.shareView clickedButtonAtIndex:self.shareView.sendButtonIndex];
//                        }
//                    }
//                }];
//            }
//            return;
//        }
//    }
    if (show) {
        [KDPopup showHUDCustomView:self.shareView desc:@"" inView:self.navigationController.view].dimBackground = YES;
    }
}

#pragma  XTContactGroupViewControllerDelegate

- (void)contactGroupForwardWithGroup:(GroupDataModel *)group {
    [self finishSelectWithGroup:group person:nil isShowSelf:YES];
}

#pragma mark - XTGroupTimelineViewControllerDelegate

- (void)groupTimeline:(XTGroupTimelineViewController *)controller group:(GroupDataModel *)group {
    [self finishSelectWithGroup:group person:nil isShowSelf:YES];
}

#pragma mark - UISearchBarDelegate -

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [super searchBarTextDidBeginEditing:searchBar];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [super searchBarTextDidEndEditing:searchBar];
    if(self.isMulti)
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem kd_makeRightItemWithTitle:ASLocalizedString(@"KDForward_Multiple") color:FC5 target:self action:@selector(inEditModel)];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    [super searchBar:searchBar textDidChange:searchText];
}

- (void)processSearchResultsBeforeReload {
    if ([self shouldBlockCurrentUser]) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.displayContacts];
 
        for (PersonSimpleDataModel *person in self.displayContacts) {
            if ([person.personId isEqualToString:[BOSConfig sharedConfig].user.userId]) {
                [tempArr removeObject:person];
            }
        }
        
        [self.displayContacts removeAllObjects];
        [self.displayContacts addObjectsFromArray:tempArr];
    }
    
    if (self.blackList.count > 0) {
        __block BOOL hasCurrentUserOrNot = NO;
        [self.blackList enumerateObjectsUsingBlock:^(NSString *str, NSUInteger i, BOOL *stop)
         {
             if ([str isEqualToString:[BOSConfig sharedConfig].user.oId]) {
                 hasCurrentUserOrNot = YES;
                 stop = YES;
             }
         }];
        
        if (hasCurrentUserOrNot == YES) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.displayContacts];
            for (PersonSimpleDataModel *person in self.displayContacts) {
                if ([person.personId isEqualToString:[BOSConfig sharedConfig].user.userId]) {
                    [tempArr removeObject:person];
                }
            }
                
            [self.displayContacts removeAllObjects];
            [self.displayContacts addObjectsFromArray:tempArr];
        }
        
        NSArray *oidArray = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithOids:self.blackList];
        
        for (NSInteger i = 0; i < oidArray.count; i++) {
            PersonSimpleDataModel *person = oidArray[i];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId != %d", person.personId];
            [self.displayContacts filterUsingPredicate:predicate];
        }
    }
    
    [self searchGroupWithSearchText:self.searchText contact:self.displayContacts];
    [self.tableView reloadData];
}

- (BOOL)shouldBlockCurrentUser {
    return (self.type != XTChooseContentJSBridgeSelectPerson) && (self.type != XTChooseContentJSBridgeSelectPersons);
}

// 搜索群组
- (void)searchGroupWithSearchText:(NSString *)text contact:(NSArray *)contact{
//    NSMutableArray *groups = [[NSMutableArray alloc] init];
//    NSArray *groupsWithName = nil;
//    if (self.bCreateExtenalGroup) {
//        groupsWithName = [[XTDataBaseDao sharedDatabaseDaoInstance] queryGroupsWithLikeGroupName:text isNotShowCancel:YES];
//    } else {
//        groupsWithName = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithLikeGroupName:text isNotShowCancel:YES];
//    }
    
    //会话搜索(只搜索双人会话和多人会话)
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    NSArray *groupsWithName = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithLikeGroupName:text];
    NSArray *groupsWithIds = nil;
    if ([contact count] > 0) {
        __block NSString *ids = [[NSString alloc] init];
        [contact enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
            ids = [ids stringByAppendingFormat:@"'%@',",person.personId];
        }];
        ids = [ids substringToIndex:ids.length - 1];
        if (ids.length > 0) {
            groupsWithIds = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithIds:ids isPersonId:YES];
        }
    }
    
    //检索群组名称结果
    if ([groupsWithName count] > 0) {
        [groups addObjectsFromArray:groupsWithName];
    }
    
    //检索群组成员结果
    if ([groupsWithIds count] > 0)
    {
        //去重，GroupDataModal重写了isEquals
        [groupsWithIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             GroupDataModel *gdm = (GroupDataModel *)obj;
             if(![groups containsObject:gdm])
                 [groups addObject:gdm];
             else
             {
                 //替换高亮信息
                 int index = (int)[groups indexOfObject:gdm];
                 if(index>=0 && index<groups.count)
                 {
                     GroupDataModel *gdm1 = groups[index];
                     gdm1.highlightMessage = [gdm.highlightMessage copy];
                 }
             }
             
         }];
    }

    
//    NSArray *privateGroupsWithIds = nil;
//    if ([contact count] > 0) {
//        privateGroupsWithIds = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupsWithPersons:contact];
//    }
    
//    if ([groupsWithName count] > 0) {
//        [groups addObjectsFromArray:groupsWithName];
//        
//    }
//    if ([privateGroupsWithIds count] > 0) {
//        // 去重
//        NSMutableArray *tempArr = privateGroupsWithIds.mutableCopy;
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", groupsWithName];
//        [tempArr filterUsingPredicate:predicate];
//        [groups addObjectsFromArray:tempArr];
//    }
    
    NSArray *resultGroups = [self sortGroups:groups];
    [self.groupSearchResults removeAllObjects];
    [self.groupSearchResults addObjectsFromArray:resultGroups];
}

- (NSArray *)sortGroups:(NSArray *)groups {
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"groupType == %d",GroupTypeDouble];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"groupType == %d",GroupTypeMany];
    NSMutableArray *groupDouble = [groups filteredArrayUsingPredicate:pred1].mutableCopy;
    NSMutableArray *groupMany = [groups filteredArrayUsingPredicate:pred2].mutableCopy;
    NSMutableArray *result = [NSMutableArray array];
    
    NSSortDescriptor *sorterTime = [[NSSortDescriptor alloc] initWithKey:@"lastMsgSendTime" ascending:NO];
    NSSortDescriptor *sorterExt = [[NSSortDescriptor alloc] initWithKey:@"isExternalGroup" ascending:YES];
    
    NSArray *resultDouble = [groupDouble sortedArrayUsingDescriptors:@[sorterExt,sorterTime]];
    NSArray *resultMany = [groupMany sortedArrayUsingDescriptors:@[sorterTime]];
    [result addObjectsFromArray:resultDouble];
    [result addObjectsFromArray:resultMany];
    
    return result;
}

#pragma mark - application share

- (void)applicationShared {
    [self applicationShared:nil];
}
- (void)applicationShared:(NSString *)webpageUrl {
    NSString *groupId = self.shareView.group.groupId;
    NSString *personId = self.shareView.person.personId;
    NSString *uuid = [ContactUtils uuid];
    
    switch (self.shareView.shareData.shareType) {
        case ShareMessageText:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                XTShareTextDataModel *textDM = self.shareView.shareData.mediaObject;
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeText content:textDM.text msgLent:(int)textDM.text.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
            
        case ShareMessageImage:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                XTShareImageDataModel *imageDM = self.shareView.shareData.mediaObject;
                NSData *imageData = [NSData dataFromBase64String:imageDM.imageData];
                NSData *sendData = [ContactUtils XOR80:imageData];
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient sendFileWithGroupId:groupId toUserId:personId msgType:MessageTypePicture msgLen:(int)imageData.length upload:sendData fileExt:@"jpg" param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
            
        case ShareMessageNews:
        {
            XTShareNewsDataModel *news = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:news.title forKey:@"title"];
            [param setObject:news.content forKey:@"content"];
            [param setObject:news.thumbData forKey:@"thumbData"];
            [param setObject:news.webpageUrl forKey:@"webpageUrl"];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:news.title msgLent:(int)news.title.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
            
        case ShareMessageApplication:
        {
            XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(application.title)  forKey:@"title"];
            [param setObject:safeString(self.shareView.shareData.appName) forKey:@"appName"];
            [param setObject:safeString(application.cellContent) forKey:@"content"];
            [param setObject:safeString(application.thumbData) forKey:@"thumbData"];
            [param setObject:safeString(application.thumbURL) forKey:@"thumbUrl"];
            
            if (webpageUrl) {
                [param setObject:webpageUrl forKey:@"webpageUrl"];
            } else {
                [param setObject:application.webpageUrl forKey:@"webpageUrl"];
            }
            
            [param setObject:application.lightAppId forKey:@"lightAppId"];
            [param setObject:self.shareView.shareData.appId forKey:@"pubAccId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:application.title msgLent:(int)application.title.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageRedPacket:
        {
            XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
            NSDictionary *shareParams = self.shareView.shareData.params;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(self.shareView.shareData.appId) forKey:@"appId"];
            [param setObject:safeString(self.shareView.shareData.appName) forKey:@"appName"];
            [param setObject:safeString(application.title)  forKey:@"title"];
            [param setObject:safeString(application.cellContent) forKey:@"content"];
            
            [param setObject:webpageUrl ? : application.webpageUrl forKey:@"webpageUrl"];
            NSString *appGroupId = shareParams[@"groupId"];
            NSString *redpkgExtType = shareParams[@"redpkgExtType"];
            NSArray *userArr = shareParams[@"users"];
            NSString *currGroupId = appGroupId ? : @"";
            if (currGroupId.length < 1) {
                currGroupId = groupId ? : @"";
            }

            if (redpkgExtType && redpkgExtType.length > 0) {
                [param setObject:redpkgExtType forKey:@"redpkgExtType"];
            }
            if (userArr && userArr.count > 0) {
                [param setObject:userArr forKey:@"users"];
            }
            
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                NSString *content = [NSString stringWithFormat:@"[红包]%@", application.title];
//                [self.sendMessageClient toSendMsgWithGroupID:currGroupId toUserID:personId msgType:MessageTypeRedEnvelope content:content msgLent:(int)content.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageCombineForward:
        {
            XTShareCombineForwardDataModel *model = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(self.shareView.shareData.appId) forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            [param setObject:safeString(model.content) forKey:@"content"];
            [param setObject:safeString(model.mergeId) forKey:@"mergeId"];
            [param setObject:safeString(model.title) forKey:@"title"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                NSString *content = [NSString stringWithFormat:@"[聊天记录]"];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeCombineForward content:content msgLent:(int)content.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        default:
            break;
    }
}

- (void)applicationSharedWithGroup:(GroupDataModel *)group person:(PersonSimpleDataModel *)person {
    NSString *uuid = [ContactUtils uuid];
    NSString *groupId = group.groupId;
    NSString *personId = person.personId;
    
    switch (self.shareView.shareData.shareType) {
        case ShareMessageText:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                XTShareTextDataModel *textDM = self.shareView.shareData.mediaObject;
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeText content:textDM.text msgLent:(int)textDM.text.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
            
        case ShareMessageImage:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                XTShareImageDataModel *imageDM = self.shareView.shareData.mediaObject;
                NSData *imageData = [NSData dataFromBase64String:imageDM.imageData];
                NSData *sendData = [ContactUtils XOR80:imageData];
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient sendFileWithGroupId:groupId toUserId:personId msgType:MessageTypePicture msgLen:(int)imageData.length upload:sendData fileExt:@"jpg" param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
            
        case ShareMessageNews:
        {
            XTShareNewsDataModel *news = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:news.title forKey:@"title"];
            [param setObject:news.content forKey:@"content"];
            [param setObject:news.thumbData forKey:@"thumbData"];
            [param setObject:news.webpageUrl forKey:@"webpageUrl"];
            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:news.title msgLent:(int)news.title.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
            
        case ShareMessageApplication:
        {
            XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(application.title)  forKey:@"title"];
            [param setObject:safeString(self.shareView.shareData.appName) forKey:@"appName"];
            [param setObject:safeString(application.cellContent) forKey:@"content"];
            [param setObject:safeString(application.thumbData) forKey:@"thumbData"];
            [param setObject:safeString(application.thumbURL) forKey:@"thumbUrl"];
            [param setObject:safeString(application.webpageUrl) forKey:@"webpageUrl"];
            
            [param setObject:safeString(application.lightAppId) forKey:@"lightAppId"];
            [param setObject:self.shareView.shareData.appId forKey:@"pubAccId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:application.title msgLent:(int)application.title.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageRedPacket:
        {
            XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
            NSDictionary *shareParams = self.shareView.shareData.params;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(self.shareView.shareData.appId) forKey:@"appId"];
            [param setObject:safeString(self.shareView.shareData.appName) forKey:@"appName"];
            [param setObject:safeString(application.title)  forKey:@"title"];
            [param setObject:safeString(application.cellContent) forKey:@"content"];
            
            [param setObject:safeString(application.webpageUrl) forKey:@"webpageUrl"];
            NSString *appGroupId = shareParams[@"groupId"];
            NSString *redpkgExtType = shareParams[@"redpkgExtType"];
            NSArray *userArr = shareParams[@"users"];
            NSString *currGroupId = appGroupId ? : @"";
            if (currGroupId.length < 1) {
                currGroupId = groupId ? : @"";
            }
            if (redpkgExtType && redpkgExtType.length > 0) {
                [param setObject:redpkgExtType forKey:@"redpkgExtType"];
            }
            if (userArr && userArr.count > 0) {
                [param setObject:userArr forKey:@"users"];
            }
            
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                NSString *content = [NSString stringWithFormat:@"[红包]%@", application.title];
//                [self.sendMessageClient toSendMsgWithGroupID:currGroupId toUserID:personId msgType:MessageTypeRedEnvelope content:content msgLent:(int)content.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        case ShareMessageCombineForward:
        {
            XTShareCombineForwardDataModel *model = self.shareView.shareData.mediaObject;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:safeString(self.shareView.shareData.appId) forKey:@"appId"];
            [param setObject:@(self.shareView.shareData.unreadMonitor) forKey:@"unreadMonitor"];
            [param setObject:safeString(model.content) forKey:@"content"];
            [param setObject:safeString(model.mergeId) forKey:@"mergeId"];
            [param setObject:safeString(model.title) forKey:@"title"];
            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
            if (paramJsonData) {
                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
                NSString *content = [NSString stringWithFormat:@"[聊天记录]"];
                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeCombineForward content:content msgLent:(int)content.length param:paramJsonString clientMsgId:uuid];
            }
        }
            break;
        default:
            break;
    }
}

- (void)forwardMessageWithGroup:(GroupDataModel *)group person:(PersonSimpleDataModel *)person {
//    NSString *uuid = [ContactUtils uuid];
//    NSString *groupId = group.groupId;
//    NSString *personId = person.personId;
//    
//    switch (self.forwardData.forwardType) {
//        case ForwardMessageText:
//        {
//            [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeText content:self.forwardData.contentString msgLent:(int)self.forwardData.contentString.length param:nil clientMsgId:uuid];
//        }
//            break;
//        case ForwardMessageFile:
//        case ForwardMessagePicture:
//        {
//            if ([self.forwardData.paramObject isKindOfClass:[NSNull class]] || self.forwardData.paramObject == nil) return;
//            NSDictionary *dict = [(MessageFileDataModel *) self.forwardData.paramObject dictionaryFromMessageFileDataModel];
//            id emojiType = [dict objectForKey:@"emojiType"];
//            
//            NSString *content = [NSString stringWithFormat:@"[分享文件]:%@", [dict objectForKey:@"name"]];
//            MessageType type = MessageTypeFile;
//            
//            if (emojiType && [emojiType isKindOfClass:[NSString class]] && [emojiType isEqualToString:@"original"]) {
//                content = @"[图片]";
//            }
//            
//            id isEncryped = dict[@"isEncrypted"];
//            if(![isEncryped isKindOfClass:[NSNull class]] && isEncryped){
//                if([isEncryped boolValue]){
//                    //type = MessageTypeEncrypedFile;
//                    content = [NSString stringWithFormat:@"[机密文件]:%@", [dict objectForKey:@"name"]];
//                }
//            }
//            
//            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//            if (paramJsonData) {
//                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
//
//            [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:type content:content msgLent:(int)content.length param:paramJsonString clientMsgId:uuid];
//            }
//        }
//            break;
//        case ForwardMessageNew:
//        {
//            NSMutableDictionary *param = [NSMutableDictionary dictionary];
//            [param setObject:self.forwardData.title forKey:@"title"];
//            [param setObject:self.forwardData.text forKey:@"content"];
//            [param setObject:self.forwardData.imageUrl forKey:@"thumbData"];
//            [param setObject:self.forwardData.webUrl forKey:@"webpageUrl"];
//            [param setObject:self.shareView.shareData.appId forKey:@"appId"];
//            [param setObject:@(0) forKey:@"unreadMonitor"];
//            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
//            
//            if (paramJsonData) {
//                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
//                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeShareNews content:self.forwardData.title msgLent:(int)self.forwardData.title.length param:paramJsonString clientMsgId:uuid];
//            }
//        }
//            break;
//            
//        case ForwardMessageCombine:
//        {
//            NSMutableDictionary *param = [NSMutableDictionary dictionary];
//            [param setObject:safeString(self.forwardData.mergeId) forKey:@"mergeId"];
//            //  title
//            NSMutableString *title = [NSMutableString new];
//            if (self.forwardData.sourceGroup.groupType == GroupTypeDouble) {
//                NSString *otherName = self.forwardData.sourceGroup.firstParticipant.personName;
//                NSString *myName = [[BOSConfig sharedConfig] user].name;
//                [title appendFormat:@"%@和%@的聊天记录", myName, otherName];
//            } else {
//                NSString *groupName = self.forwardData.sourceGroup.groupName;
//                [title appendFormat:@"%@的聊天记录", groupName];
//            }
//            [param setObject:safeString(title) forKey:@"title"];
//            NSMutableString *content = [NSMutableString new];
//            int contentCount = 0;
//            NSMutableArray *array = self.forwardData.mergeRecords.mutableCopy;
//            [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//                RecordDataModel *record1 = (RecordDataModel *)obj1;
//                RecordDataModel *record2 = (RecordDataModel *)obj2;
//                return [record1.sendTime compare:record2.sendTime];
//            }];
//            for (RecordDataModel *r in array) {
//                [content appendFormat:@"%@: %@", [self personNameWithGroup:self.forwardData.sourceGroup record:r], [r.content stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
//                contentCount += 1;
//                if (contentCount == 4) {
//                    break;
//                }
//                if (contentCount < 4) {
//                    [content appendFormat:@"\n"];
//                }
//                
//            }
//            [param setObject:safeString(content) forKey:@"content"];
//            NSData *paramJsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
//            if (paramJsonData) {
//                NSString *paramJsonString = [[NSString alloc] initWithData:paramJsonData encoding:NSUTF8StringEncoding];
//                NSString *content = [NSString stringWithFormat:@"[聊天记录]"];
//                [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeCombineForward content:content msgLent:(int)content.length param:paramJsonString clientMsgId:uuid];
//            }
//        }
//            break;
//        default:
//            break;
//    }
}

- (NSString * )personNameWithGroup:(GroupDataModel *)group record:(RecordDataModel *)record {
    NSString *name;
    PersonSimpleDataModel *person = [KDCacheHelper personForKey:record.fromUserId];
    if (person == nil) {
        person = [group.participant firstObject];
    }
    if (record.nickname && record.nickname.length > 0) {
        name = record.nickname;
    } else {
        name = person.personName;
    }
    
    return name;
}

- (void)applicationCallback {
    XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", application.callbackUrl]]];
    
    if (self.shareView.group.groupId.length > 0) {
        [request setPostValue:self.shareView.group.groupId forKey:@"groupId"];
    }
    else if (self.shareView.person.personId.length > 0) {
        [request setPostValue:self.shareView.person.personId forKey:@"groupId"];
        //[request setPostValue:self.shareView.person.personId forKey:@"personId"];
    }
    [request setPostValue:[BOSConfig sharedConfig].user.eid forKey:@"eId"];
    [request setPostValue:[BOSConfig sharedConfig].user.oId forKey:@"openId"];
    
    if (application.content.length > 0) {
        [request setPostValue:application.content forKey:@"content"];
    }
    
    id <KDConfiguration> conf = [[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance];
    [request signRequestWithClientIdentifier:[conf getOAuthConsumerKey]
                                      secret:[conf getOAuthConsumerSecret]
                             tokenIdentifier:[BOSConfig sharedConfig].user.oauthToken
                                      secret:[BOSConfig sharedConfig].user.oauthTokenSecret
                                 usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(applicationCallbackFinished:)];
    [request setDidFailSelector:@selector(applicationCallbackFailed:)];
    [request setShouldAttemptPersistentConnection:YES];
    [request startAsynchronous];
}

- (void)applicationCallbackFailed:(ASIFormDataRequest *)theRequest {
    [KDPopup showHUDToast:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27")];
}

- (void)applicationCallbackFinished:(ASIFormDataRequest *)theRequest {
    if (theRequest.responseString.length > 0) {
        id result = [NSJSONSerialization JSONObjectWithData:[theRequest.responseString dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([[result objectForKey:@"success"] boolValue]) {
            NSString *data = [result objectForKey:@"data"];
            
            NSString *webpageUrl = nil;
            if (data.length > 0) {
                XTShareApplicationDataModel *application = self.shareView.shareData.mediaObject;
                webpageUrl = [application.webpageUrl stringByAppendingString:data];
            }
            [self applicationShared:webpageUrl];
            return;
        }
        else
        {
            NSString *errorMessage = [result objectForKey:@"errorMessage"];
            if(errorMessage.length>0)
            {
                [KDPopup showHUDToast:errorMessage];
                return;
            }
        }
    }
    
    [KDPopup showHUDToast:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27")];
}

#pragma mark - XTShareViewDelegate

- (void)completeChooseShare {
    [KDPopup showHUD:@"发送中..."];
    
    if (self.shareData.shareType == ShareMessageApplication) {
        XTShareApplicationDataModel *application = self.shareData.mediaObject;
        
        if (application.callbackUrl.length > 0) {
            [self applicationCallback];
        } else {
            [self applicationShared];
        }
    } else {
        [self applicationShared];
    }
}

- (void)shareView:(XTShareView *)shareView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [KDPopup hideHUDInView:self.navigationController.view];
        if ([shareView isKindOfClass:[XTShareFinishView class]]) {
            //跳转回第三方应用
            [KDPopup hideHUDInView:self.navigationController.view];
            [self dismissViewControllerAnimated:NO completion:^{
                if (buttonIndex == shareView.cancelButtonIndex && (self.shareData.shareType != ShareMessageApplication && self.shareData.shareType != ShareMessageRedPacket) && shareView.shareData.appId.length > 0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"cloudhub%@://", shareView.shareData.appId]]];
                }
            }];
            
            return;
        }

        //[self cancel:nil];
        return;
    }
    if ([shareView isKindOfClass:[XTShareFinishView class]]) {
        //跳转回第三方应用
        [KDPopup hideHUD];

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.shareView.group, @"group", nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareGroupMessage" object:nil userInfo:dict];
        
        return;
    }
    
    if ([shareView isKindOfClass:[XTShareStartView class]]) {
        [shareView.shareTextField resignFirstResponder];
        
        if (buttonIndex == shareView.cancelButtonIndex) {
            if (self.strDefaultGroupId.length > 0 || self.strDefaultPersonId.length > 0)
            {
                [KDPopup hideHUD];
                [self dismissViewControllerAnimated:NO completion:nil];
                return;
            }
            [KDPopup hideHUD];;
            return;
        }
    }

    
    [KDPopup hideHUD];
    [KDPopup showHUD:@"发送中..."];
    
    self.needSendLeaveMessage = (shareView.shareTextField.text.length > 0);
    
    if (shareView.shareData.shareType == ShareMessageApplication) {
        XTShareApplicationDataModel *application = shareView.shareData.mediaObject;
        
        if (application.callbackUrl.length > 0) {
            [self applicationCallback];
        } else {
            [self applicationShared];
        }
    } else {
        [self applicationShared];
    }
}

#pragma mark - send message

- (ContactClient *)sendMessageClient {
    if (!_sendMessageClient) {
        _sendMessageClient = [[ContactClient alloc] initWithTarget:self action:@selector(sendMessageDidReceived:result:)];
    }
    return _sendMessageClient;
}

- (void)sendMessageDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    
    [KDPopup hideHUD];
    if (client.hasError || !result.success || result == nil) {
        
        if(result.error.length > 0)
            [KDPopup showHUDToast:result.error inView:self.navigationController.view];
        else
            [KDPopup showHUDToast:ASLocalizedString(@"KDAddOrUpdateSignInPointController_tips_27") inView:self.navigationController.view];
        
        self.group = nil;
        
        if (self.strDefaultGroupId.length > 0 || self.strDefaultPersonId.length > 0) {
            [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:1.0];
        }
        
        return;
    }
    
    if (self.isMultChooseGroup) {
        return;
    }
    
    if (self.shareData.shareType == ShareMessageApplication || self.shareData.shareType == ShareMessageRedPacket || self.shareData.shareType == ShareMessageCombineForward) {
        
        if (!self.shareView.group) {
            GroupDataModel *group = nil;
            PersonSimpleDataModel *person = nil;
            if (self.wantCreateChatPersons.count == 1) {
                person = (PersonSimpleDataModel *)[self.wantCreateChatPersons firstObject];
                group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
            }
            else if (self.shareView.person) {
                person = self.shareView.person;
                group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
            }
            
            if (!group) {
                group = [[GroupDataModel alloc] init];
                group.groupId = [result.data objectForKey:@"groupId"];
                group.groupType = GroupTypeDouble;
                if (person) {
                    group.groupName = person.personName;
                    group.participantIds = [NSMutableArray arrayWithArray:@[person.personId]];
                }
            }
            self.shareView.group = group;
            self.group = group;
        }
        
        //跳入相应的聊天界面
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.shareView.group, @"group", nil];
        
        [KDPopup hideHUD];
        [self dismissViewControllerAnimated:NO completion:^{
            [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shareGroupMessage" object:nil userInfo:dict];
        }];
        return;
    }
    
    if (self.type == XTChooseContentShareStatus) {
        if (!self.group) {
            GroupDataModel *group = nil;
            PersonSimpleDataModel *person = nil;
            if (self.wantCreateChatPersons.count == 1) {
                person = (PersonSimpleDataModel *)[self.wantCreateChatPersons firstObject];
                group = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPrivateGroupWithPerson:person];
            }
            
            if (!group) {
                group = [[GroupDataModel alloc] init];
                group.groupId = [result.data objectForKey:@"groupId"];
                group.groupType = GroupTypeDouble;
                if (person) {
                    group.groupName = person.personName;
                    group.participantIds = [NSMutableArray arrayWithArray:@[person.personId]];
                }
            }
            if (group.groupName.length == 0) {
                group.groupName = self.newsFowardPerson.personName;
            }
            
            self.shareView.group = group;
            self.group = group;
        }
        
        [KDPopup hideHUD];
        [self dismissViewControllerAnimated:NO completion:^{
            [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
            [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedIndex = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shareStatus" object:nil userInfo:@{@"group" : self.group}];
        }];
        
        return;
    }
    
    [KDPopup hideHUD];
    if (self.needSendLeaveMessage) {
        self.needSendLeaveMessage = NO;
        NSString *shareLeaveMessage = self.shareView.shareTextField.text;
        NSString *groupId = self.shareView.group.groupId;
        NSString *personId = self.shareView.person.personId;
        NSString *uuid = [ContactUtils uuid];
        [self.sendMessageClient toSendMsgWithGroupID:groupId toUserID:personId msgType:MessageTypeText content:shareLeaveMessage msgLent:(int)shareLeaveMessage.length param:nil clientMsgId:uuid];
    }
    else {
        XTShareFinishView *finishView = [[XTShareFinishView alloc] initWithShareData:self.shareView.shareData];
        finishView.group = self.shareView.group;
        finishView.person = self.shareView.person;
        finishView.delegate = self;
        
        [KDPopup showHUDCustomView:finishView desc:@"" inView:self.navigationController.view].dimBackground = YES;
    }
}

#pragma mark - KDChooseManagerDelegate
- (BOOL)chooseManagerIsNeedAlert {
    return YES;
}

- (XTShareDataModel *)chooseManagerShareDataModel {
    if (self.type == XTChooseContentShare && self.shareData.shareType != ShareMessageRedPacket && self.shareData.shareType != ShareMessageCombineForward) {
        return self.shareData;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - XTChooseContentViewControllerDelegate

//选择了一个组
- (void)chooseContentView:(XTChooseContentViewController *)controller group:(GroupDataModel *)group
{
    [self finishSelectWithGroup:group person:nil isShowSelf:NO];
}

- (void)chooseContentView:(XTChooseContentViewController *)controller person:(PersonSimpleDataModel *)person
{
    [self finishSelectWithGroup:nil person:person isShowSelf:NO];
}

- (BOOL)canEditImage {
    XTForwardDataModel *forwardData = [self getImageForwardData];
    if (forwardData && forwardData.originalUrl.description.length > 0 && forwardData.bCanEditImage == YES) {
        return YES;
    }
    
    return NO;
}

- (XTForwardDataModel *)getImageForwardData {
    
    XTForwardDataModel *forwardData = [[XTForwardDataModel alloc] init];
    
    if ([self.forwardData isKindOfClass:[NSArray class]] && self.forwardData.count == 1) {
        forwardData = [self.forwardData firstObject];
    }
    
    if ([self.forwardData isKindOfClass:[XTForwardDataModel class]]) {
        forwardData = (XTForwardDataModel *)self.forwardData;
    }
    
    return forwardData;
}

- (void)goToImageEditorWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    KDImageEditorViewController *editor = [[KDImageEditorViewController alloc] initWithImage:image delegate:self];
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:editor animated:YES completion:nil];
}

#pragma mark- KKImageEditorDelegate

- (void)imageDidFinishEdittingWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    // 将编辑后的图片发送到相应的会话组
    [self dismissViewControllerAnimated:NO completion:^{
        [(UINavigationController *) [KDWeiboAppDelegate getAppDelegate].tabBarController.selectedViewController popToRootViewControllerAnimated:NO];
    }];
    [KDWeiboAppDelegate getAppDelegate].timelineViewController.editImage = image;
    if (self.group) {
        [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithGroup:self.group withMsgId:@""];
    } else {
        [[KDWeiboAppDelegate getAppDelegate].timelineViewController toChatViewControllerWithPerson:self.newsFowardPerson];
    }
}

@end
