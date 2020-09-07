//
//  KWISettingsVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/26/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISettingsVCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"
#import "iToast.h"

#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"

#import "KWISigninVCtrl.h"
#import "KWIAboutVCtrl.h"
#import "KWIFeedbackVCtrl.h"
#import "KWIRateVCtrl.h"
#import "SCPLocalKVStorage.h"
#import "KWIAppDelegate.h"
#import "KDCommonHeader.h"

@interface KWISettingsVCtrl () <UIAlertViewDelegate, UITableViewDataSource, 
                                UITableViewDelegate, UITextFieldDelegate, 
                                UIActionSheetDelegate, 
                                UIImagePickerControllerDelegate, 
                                UINavigationControllerDelegate,
                                UIPopoverControllerDelegate>

@property (nonatomic, readonly) NSArray *staticData;
@property (nonatomic, readonly) UIActionSheet *avatarActionSheet;

@end

@implementation KWISettingsVCtrl
{
    IBOutlet UIImageView *_avatarV;
    IBOutlet UIButton *_changeAvatarBtn;
    IBOutlet UITextField *_nameIpt;
    IBOutlet UITextField *_deptIpt;
    IBOutlet UITextField *_jobtitleIpt;
    IBOutlet UILabel *_followingCountV;
    IBOutlet UILabel *_followerCountV;
    IBOutlet UILabel *_statusCountV;
    IBOutlet UILabel *_topicCountV;    
    IBOutlet UITableView *_tbV;
    
    UIActionSheet *_avatarActionSheet;
    unsigned int _galleryBtnIdx;
    unsigned int _cameraBtnIdx;
    UIImagePickerController *_imgPkrVCtrl;
    UIPopoverController *_poper;
}

@synthesize staticData = _staticData;

+ (KWISettingsVCtrl *)vctrl
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super initWithNibName:self.class.description bundle:nil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [self makeBarButtonWithLabel:@"完成" 
                                                                   image:[UIImage imageNamed:@"settingsCloseBtn.png"]
                                                                  target:self 
                                                                  action:@selector(_closeSettings)];
    [self configTitle:@"设置"];
    
    _avatarV.layer.cornerRadius = 8;
    _avatarV.layer.borderColor = [[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1] CGColor];
    _avatarV.layer.borderWidth = 1;
    _avatarV.clipsToBounds = YES;
    
//    KWEngine *api = [KWEngine sharedEngine];
//    KWUser *user = api.user;
    KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
    KDUser *user = [userManager currentUser];
 
    
    if (user) {
        if (user.profileImageUrl) {
            [_avatarV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&spec=180", user.profileImageUrl]]];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] || 
                [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                 _changeAvatarBtn.enabled = YES;
            }
            KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext] communityManager];
            KDCommunity *community = [communityManager currentCommunity];
            if (![user isPublicUser] &&  ![community isCompany]) {
                _changeAvatarBtn.hidden = YES;
                _nameIpt.enabled = NO;
                _deptIpt.enabled = NO;
                _jobtitleIpt.enabled = NO;
            }else {
                _changeAvatarBtn.hidden = NO;
                _nameIpt.enabled = YES;
                _deptIpt.enabled = YES;
                _jobtitleIpt.enabled = YES;
            }
        }        
        
        _nameIpt.text = user.screenName;
        _deptIpt.text = user.department;
        _jobtitleIpt.text = user.jobTitle;
        
    }
    else {
        DLog(@"no user .....");
    }
    
    _tbV.delegate = self;
    _tbV.dataSource = self;  
    _tbV.backgroundView = nil;
    if (5 > [UIDevice curSysVer]) {
        _tbV.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidUnload
{
    [_avatarV release];
    _avatarV = nil;
    [_nameIpt release];
    _nameIpt = nil;
    [_followingCountV release];
    _followingCountV = nil;
    [_followerCountV release];
    _followerCountV = nil;
    [_statusCountV release];
    _statusCountV = nil;
    [_topicCountV release];
    _topicCountV = nil;
    [_tbV release];
    _tbV = nil;
    [_changeAvatarBtn release];
    _changeAvatarBtn = nil;
    [_deptIpt release];
    _deptIpt = nil;
    [_jobtitleIpt release];
    _jobtitleIpt = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [_staticData release];
    [_avatarV release];
    [_nameIpt release];
    [_followingCountV release];
    [_followerCountV release];
    [_statusCountV release];
    [_topicCountV release];
    [_tbV release];
    [_changeAvatarBtn release];
    [_deptIpt release];
    [_jobtitleIpt release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSArray *)staticData
{
    if (nil == _staticData) {
        
        NSMutableArray *section0 = [NSMutableArray array];
        [section0 addObject:[self _makeCell:@"评价一把" action:@"_onRate"]];
        [section0 addObject:[self _makeCell:@"意见反馈" action:@"_onFeedback"]];
        [section0 addObject:[self _makeCell:@"关于" action:@"_onAbout"]];
        
        NSMutableArray *section1 = [NSMutableArray array];
        UITableViewCell *signoutCell = [self _makeCell:@"退出当前账号" action:@"_onSignout"];
        signoutCell.accessoryType = UITableViewCellAccessoryNone;
        [section1 addObject:signoutCell];
        
        _staticData = [[NSArray arrayWithObjects:[NSArray arrayWithArray:section0],
                [NSArray arrayWithArray:section1],
                nil] retain]; 
    }
    
    return _staticData;  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ 
    // Return the number of sections.
    return self.staticData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *cells = [self.staticData objectAtIndex:section];
    return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section = [self.staticData objectAtIndex:indexPath.section];
    if (section && section.count) {
        return [section objectAtIndex:indexPath.row];
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    SEL action = NSSelectorFromString(cell.reuseIdentifier);
    if ([self respondsToSelector:action]) {
        cell.selected = NO;
        [self performSelector:action];
    }
}

- (void)_closeSettings
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (UITableViewCell *)_makeCell:(NSString *)text action:(NSString *)action
{
    UITableViewCell *cell;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:action] autorelease];
    cell.textLabel.text = text;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = [self makeBarButtonWithLabel:@"提交"
                                                                    image:[UIImage imageNamed:@"settingsSubmitBtn.png"]
                                                                   target:self
                                                                   action:@selector(_updateProfile)];
    textField.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_nameIpt == textField) {
        [_deptIpt becomeFirstResponder];
    } else if (_deptIpt == textField) {
        [_jobtitleIpt becomeFirstResponder];
    } else if (_jobtitleIpt == textField) {
        [self _updateProfile];
        [_jobtitleIpt resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = nil;
    textField.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
}

- (void)_updateProfile
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _nameIpt.enabled = NO;
    
    void(^_unlockUI)() = ^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        _nameIpt.enabled = YES;
    };
    
    NSString *name = _nameIpt.text;    
    unsigned int nameLen = [self _calcUnicodeStrLen:name];    
    if (4 > nameLen) {
        [[iToast makeText:@"用户名不能少于4个英文字母或2个汉字"] show];
        _unlockUI();
        return;
    } else if (20 < nameLen) {
        [[iToast makeText:@"用户名不能多于20个英文字母或10个汉字"] show];
        _unlockUI();
        return;
    }
    
    NSRange space = [name rangeOfString:@" "];
    if (space.length) {
        [[iToast makeText:@"用户名不能包含空格"] show];
        _unlockUI();
        return;
    }
    
    NSString *dept = _deptIpt.text;
    unsigned int deptLen = [self _calcUnicodeStrLen:dept];
    if (120 < deptLen) {
        [[iToast makeText:@"职位不能多于120个英文字母或60个汉字"] show];
        _unlockUI();
        return;
    }
    
    NSString *jobtitle = _jobtitleIpt.text;
    unsigned int jobLen = [self _calcUnicodeStrLen:jobtitle];
    if (40 < jobLen) {
        [[iToast makeText:@"职位不能多于40个英文字母或20个汉字"] show];
        _unlockUI();
        return;
    }
    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api post:@"account/update_profile.json"
//       params:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", dept, @"department", jobtitle, @"job_title", nil] 
//    onSuccess:^(NSDictionary *result) {
//        api.user = [KWUser userFromDict:result];
//        [[iToast makeText:@"账号信息已更新"] show];
//        _unlockUI();
//    } 
//      onError:^(NSError *err) {
//          if ([@"ResponseWithError" isEqualToString:err.domain] && 400 == err.code) {
//              [[iToast makeText:@"用户名只允许中英文、数字、下划线（_）和点号（.）"] show];
//          } else {
//              [err KWIGeneralProcess];
//          }
//          
//          _unlockUI();
//      }];
    
    
    KDQuery *query = [KDQuery queryWithName:@"name" value:name];
    [[query setParameter:@"department" stringValue:dept]
     setParameter:@"job_title" stringValue:jobtitle];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results) {
                KDUser *user = results;
                 //svc.
                KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
                userManager.currentUser = user;
                [[iToast makeText:@"账号信息已更新"] show];
                     _unlockUI();
                  [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    [userDAO saveUser:user database:fmdb];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
        }else {
            if (![response isCancelled]) {
                if (response.statusCode == 400) {
                    [[iToast makeText:@"用户名只允许中英文、数字、下划线（_）和点号（.）"] show];
                }else {
                    [[iToast makeText:[[response responseDiagnosis]networkErrorMessage]] show];
                }
            }
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfile" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (unsigned int)_calcUnicodeStrLen:(NSString *)str
{
    unsigned int len = 0;
    for (unsigned int i = 0; i < str.length; i++) {
        len += (128 > [str characterAtIndex:i])?1:2;
    }
    return len;
}

- (void)_onRate
{
    NSString *urlString = [(KWIAppDelegate *)[UIApplication sharedApplication].delegate commentURL];
    
    if(!urlString || [urlString isEqualToString:@""])
        urlString = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=664477775";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)_onFeedback
{
    KWIFeedbackVCtrl *vctrl = [KWIFeedbackVCtrl vctrl];
    [self.navigationController pushViewController:vctrl animated:YES];
}

- (void)_onAbout
{
    KWIAboutVCtrl *vctrl = [KWIAboutVCtrl vctrl];
    [self.navigationController pushViewController:vctrl animated:YES];
}

- (void)_onSignout
{
    UIAlertView *alertV = [[[UIAlertView alloc] initWithTitle:@"退出当前账号"
                                                      message:@"确认退出吗？"
                                                     delegate:self 
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"退出", nil] autorelease];
    [alertV show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1: 
        {

            
            [[KDWeiboGlobals defaultWeiboGlobals] signOut]; 
             KWIAppDelegate *appDelegate =  (KWIAppDelegate *)[UIApplication.sharedApplication delegate];
            
            if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [appDelegate showSingInViewController] ;
                }];
            } else {
                [self.navigationController dismissModalViewControllerAnimated:YES];
                [appDelegate performSelector:@selector(showSingInViewController) withObject:nil afterDelay:0.3];
            }
            
            UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
        }
            break;
    }
}

- (UIActionSheet *)avatarActionSheet
{
    if (nil == _avatarActionSheet) {
        _avatarActionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            _galleryBtnIdx = [_avatarActionSheet addButtonWithTitle:@"本地照片"];
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _cameraBtnIdx = [_avatarActionSheet addButtonWithTitle:@"拍照"];
        }
    }
    return _avatarActionSheet;
}

- (IBAction)_onChangeAvatarBtnTapped:(id)sender
{
    [self.avatarActionSheet showFromRect:_changeAvatarBtn.frame inView:_changeAvatarBtn.superview animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_galleryBtnIdx == buttonIndex) {
        [self _onGalleryBtnTapped];
    } else if (_cameraBtnIdx == buttonIndex) {
        [self _onCameraBtnTapped];
    }
}

- (void)_onGalleryBtnTapped
{
    _imgPkrVCtrl = [[[UIImagePickerController alloc] init] autorelease];
    _imgPkrVCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPkrVCtrl.allowsEditing = YES;
    _imgPkrVCtrl.delegate = self;
    
    _poper = [[UIPopoverController alloc] initWithContentViewController:_imgPkrVCtrl];
    _poper.delegate = self;
    [_poper presentPopoverFromRect:_changeAvatarBtn.frame
                                inView:_changeAvatarBtn.superview 
              permittedArrowDirections:UIPopoverArrowDirectionAny 
                              animated:YES];
}

- (void)_onCameraBtnTapped
{
    _imgPkrVCtrl = [[[UIImagePickerController alloc] init] autorelease];
    _imgPkrVCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPkrVCtrl.allowsEditing = YES;
    _imgPkrVCtrl.delegate = self;
    _imgPkrVCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:_imgPkrVCtrl 
                           animated:YES 
                         completion:nil];
    } else {
        [self presentModalViewController:_imgPkrVCtrl animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [_poper release];
    _poper = nil;
    
    //[_imgPkrVCtrl release];
    _imgPkrVCtrl = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _changeAvatarBtn.enabled = NO;
    NSValue *rv = [info objectForKey:UIImagePickerControllerCropRect];
    CGRect cropRect = [rv CGRectValue];
    
    // ensure square
    if (cropRect.size.width > cropRect.size.height) {
        cropRect.size.width = cropRect.size.height;
    } else if (cropRect.size.height > cropRect.size.width) {
        cropRect.size.height = cropRect.size.width;
    }
    
    UIImage *ori;
    ori = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGImageRef cropped = CGImageCreateWithImageInRect(ori.CGImage, cropRect);
    
    UIImage *img;
    CGFloat minEdgeLen = MIN(cropRect.size.width, cropRect.size.height);
    CGFloat targetLen = 240;
    if (minEdgeLen < targetLen) {
        CGFloat scale = targetLen / minEdgeLen;
        img = [UIImage imageWithCGImage:cropped scale:scale orientation:ori.imageOrientation];        
    } else {
        img = [UIImage imageWithCGImage:cropped];
    }
    CGImageRelease(cropped);
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:UIImageJPEGRepresentation(img, 0.9), @"data", 
//                          @"image", @"key", nil];
//    KWEngine *api = [KWEngine sharedEngine];
//    [api post:@"account/update_profile_image.json"
//       params:nil
//         data:[NSArray arrayWithObject:data]
//    onSuccess:^(NSDictionary *result) {
//        api.user = [KWUser userFromDict:result];
//        [_avatarV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&spec=180", api.user.profile_image_url]]];
//        [[iToast makeText:@"头像换好了"] show];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWUser.avatarChanged" object:self]; 
//        _changeAvatarBtn.enabled = YES;
//    }
//      onError:^(NSError *err) {
//          [err KWIGeneralProcess];
//          _changeAvatarBtn.enabled = YES;
//    }];
    
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"image" fileData:UIImageJPEGRepresentation(img, 0.9)];
    
  
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results) {
                KDUser *user = results;
                //svc.
                
                [_avatarV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&spec=180", user.profileImageUrl]]];
             
                KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
                userManager.currentUser = user;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KWUser.avatarChanged" object:self];
                
                [[iToast makeText:@"头像换好了"] show];
                _changeAvatarBtn.enabled = YES;
            }
        }else {
            if (![response isCancelled]) {
                 [[iToast makeText:[[response responseDiagnosis] networkErrorMessage]] show];
               _changeAvatarBtn.enabled = YES; 
            }
        }

        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfileImage" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
    if (nil != _poper) {
        [_poper dismissPopoverAnimated:YES];
    } else {
        if ([_imgPkrVCtrl respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [_imgPkrVCtrl dismissViewControllerAnimated:YES 
                                             completion:^{
                                                 // a hack to trigger orientation rotate
                                                 UIInterfaceOrientation o =[[UIApplication sharedApplication] keyWindow].rootViewController.interfaceOrientation;
                                                 [UIApplication sharedApplication].statusBarOrientation = o;
                                                 //[_imgPkrVCtrl release];
                                                 _imgPkrVCtrl = nil;
                                             }];
        } else {
            [_imgPkrVCtrl dismissModalViewControllerAnimated:YES];
            // TODO
        }
    }
}

@end
