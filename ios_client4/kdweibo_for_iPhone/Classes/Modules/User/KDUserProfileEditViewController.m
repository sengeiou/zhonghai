//
//  KDUserProfileEditViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDUserProfileEditViewController.h"
#import "KDSingleInputViewController.h"
#import "ProfileViewController2.h"

#import "KDImageOptimizer.h"

#import "KDCache.h"
#import "KDUserAvatarView.h"
#import "KDNotificationView.h"

#import "KDWeiboServicesContext.h"

#import "KDUtility.h"
#import "KDDatabaseHelper.h"
#import "UIImage+Additions.h"
#import "KDTableViewCell.h"
#import "KDLoggedInUser.h"
#import "BOSConfig.h"
#import "BOSSetting.h"

@interface KDUserProfileEditViewController ()

@property(nonatomic, copy) NSString *username;
@property(nonatomic, retain) NSString *avatarPath;

@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) KDAvatarView *avatarView;


- (void)setSaveButtonEnabled:(BOOL)enabled;
- (void)updateSaveState;
- (NSString *)displayUsername;

- (void)showUpdateProfileProgressInfo:(NSString *)info;

- (UIImage *)getTinyAvatar;

@end

@implementation KDUserProfileEditViewController
@synthesize user=user_;
@synthesize username=username_;

@dynamic avatarPath;

@synthesize tableView=tableView_;
@synthesize avatarView=avatarView_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        user_ = nil;
        avatarPath_ = nil;
        username_ = nil;
        
        requestsCount_ = 0;
        finishedCount_ = 0;
        validResponsesCount_ = 0;
        
        hasAvatarCompressionTask_ = NO;
        hasUnsaveChanges_ = NO;
        
        didDismiss_ = NO;
        
        self.navigationItem.title = NSLocalizedString(@"EDIT_USER_PROFILE", @"");
    }
    
    return self;
}

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
    self.view.backgroundColor = RGBCOLOR(237, 237, 237);
//    [aView release];
    
    //begin iOS7 适配 王松
    [KDWeiboAppDelegate setExtendedLayout:self];
    //end iOS7 适配 王松
    
    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(doCancel:)];
    self.navigationItem.rightBarButtonItems = [KDCommon rightNavigationItemWithTitle:NSLocalizedString(@"SAVE", nil) target:self action:@selector(doSave:)];
    [self setSaveButtonEnabled:hasUnsaveChanges_];
    
    // table view
    CGRect rect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView = tableView;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [tableView release];
    
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.scrollEnabled = NO;
    
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark - UITableViewCellDatasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0x01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0x02;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
    KDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[KDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.textColor = RGBCOLOR(62, 62, 62);
        cell.detailTextLabel.textColor = RGBCOLOR(109, 109, 109);
        
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        // cell background view
        if(0x00 == indexPath.row){
            if(avatarView_ == nil) {
                avatarView_ = [KDUserAvatarView avatarView] ;//retain];
                [avatarView_ updateAvatar:[self getTinyAvatar]];
                avatarView_.frame = CGRectMake(5.0, 5.0, 40.0, 40.0);
            }
            
            if(NSNotFound == [cell.contentView.subviews indexOfObject:avatarView_]){
                [cell.contentView addSubview:avatarView_];
            }
        }
        
//        cell.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        
        cell.backgroundColor = RGBCOLOR(250, 250, 250);
        cell.backgroundView = nil;
        cell.contentView.backgroundColor = RGBCOLOR(250, 250, 250);
        cell.accessoryView.backgroundColor = RGBCOLOR(250, 250, 250);
        cell.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
        cell.layer.borderWidth = 0.5f;
        
        UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
        selectBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selectBgView.backgroundColor = RGBCOLOR(240, 241, 242);
        cell.selectedBackgroundView = selectBgView;
    }
    
    NSString *detailText = nil;
    if (0x00 == indexPath.row) {
        cell.textLabel.text = nil;
        detailText = NSLocalizedString(@"UPLOAD_USER_PROFILE_IMAGE", @"");
        
    } else {
        cell.textLabel.text = NSLocalizedString(@"USERNAME", @"");
        detailText = [self displayUsername];
    }
    
    cell.detailTextLabel.text = detailText;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = RGBCOLOR(250, 250, 250);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // if there are exist requests on running, can not change the settings now
    if(requestsCount_ > 0) return;
    
    if(indexPath.row == 0x00){
        if(hasAvatarCompressionTask_) return;
        
        BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        
        NSUInteger cancelIndex = 1;
        [actionSheet addButtonWithTitle:ASLocalizedString(@"KDImagePickerController_Photo")];
        
        if (hasCamera) {
            cancelIndex++;
            [actionSheet addButtonWithTitle:NSLocalizedString(@"TAKE_PHOTO", @"")];
        }
        
        [actionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
        actionSheet.cancelButtonIndex = cancelIndex;
        
        [actionSheet showInView:self.view];
//        [actionSheet release];
        
    }else {
        KDSingleInputViewController* sivc = [[KDSingleInputViewController alloc] initWithBaseViewController:self content:[self displayUsername] type:KDSingleInputContentTypeUsername];
        sivc.baseViewController = self;
        
        [self.navigationController pushViewController:sivc animated:YES];
//        [sivc release];
    }
}

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Custom action

- (void)dismissUserProfileEditViewController {
    didDismiss_ = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doCancel:(UIButton *)btn {
    if(hasUnsaveChanges_){
        // ask save settings if need before exist
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PROMPT_TITLE", @"") 
                                                            message:NSLocalizedString(@"ASK_DISCARD_PROFILE_CHANGES", @"") 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OKAY", @"") 
                                                  otherButtonTitles:ASLocalizedString(@"Global_Cancel"), nil];
        
        [alertView show];
//        [alertView release];
        
    }else {
        [self dismissUserProfileEditViewController];
    }
}

- (void)_handleResponseUser:(KDUser *)user message:(NSString *)message {
    finishedCount_--;
    
    BOOL hasError = NO;
    if (user != nil) {
        // update user into database
        [[[KDManagerContext globalManagerContext] userManager] setCurrentUser:user];
        self.user = user;
        
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            [userDAO saveUser:user database:fmdb];
            
            return nil;
            
        } completionBlock:nil];
        
    } else {
        hasError = YES;
        [self showUpdateProfileProgressInfo:message];
    }
    
    if (finishedCount_ == 0) {
        if (!hasError) {
            [self showUpdateProfileProgressInfo:NSLocalizedString(@"UPDATE_USER_PROFILE_DONE", @"")];
        }
        
        // unblock save button when requests did finish
        [self setSaveButtonEnabled:YES];
    }
}

- (void)dismissProfileViewControllerIfNeed {
    if(requestsCount_ == validResponsesCount_ && !didDismiss_){
        [self dismissUserProfileEditViewController];
    }
}

- (void)updateUserAvatarProfile {
    [self showUpdateProfileProgressInfo:NSLocalizedString(@"UPDATING_USER_PROFILE", @"")];
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"image" filePath:avatarPath_];
    
    __block KDUserProfileEditViewController *upevc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDUser *user = results;
        if (user != nil) {
            upevc -> validResponsesCount_++;
        }
        
        [upevc _handleResponseUser:user message:NSLocalizedString(@"UPDATE_USER_AVATAR_DID_FAIL", @"")];
        
        if (user != nil) {
            UIImage *image = [upevc getTinyAvatar];

            [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:user.profileImageUrl] imageScale:SDWebImageScaleNone] toDisk:YES];
            
            [KDLoggedInUser updateUser:[BOSSetting sharedSetting].userName url:user.profileImageUrl];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserAvatarUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:image forKey:@"avatar"]];
        }
        
        [upevc dismissProfileViewControllerIfNeed];
        // release current view controller
//        [upevc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfileImage" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)updateUsernameProfile {
    [self showUpdateProfileProgressInfo:NSLocalizedString(@"UPDATING_USER_PROFILE", @"")];
    
    KDQuery *query = [KDQuery queryWithName:@"name" value:username_];
    
    __block KDUserProfileEditViewController *upevc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDUser *user = results;
        if (user != nil) {
            upevc -> validResponsesCount_++;
        }
        
        [upevc _handleResponseUser:user message:NSLocalizedString(@"UPDATE_USER_USERNAME_DID_FAIL", @"")];
        upevc.username = nil;
        
//        if(upevc.avatarPath != nil){
//            [upevc updateUserAvatarProfile];
//        }
        
        if(user){
            
            [BOSConfig sharedConfig].user.name = user.username;
            [[BOSConfig sharedConfig] saveConfig];

            
            [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserNameUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
        }
        [upevc dismissProfileViewControllerIfNeed];
        
        // release current view controller
//        [upevc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfile" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)doSave:(UIButton *)btn {
    requestsCount_ = 0;
    validResponsesCount_ = 0;
    
    BOOL flags[] = {NO, NO};
    if (username_ != nil && ![username_ isEqualToString:user_.screenName]) {
        requestsCount_++;
        flags[0] = YES;
    }
    
    if (avatarPath_ != nil) {
        requestsCount_++;
        flags[1] = YES;
    }
    
    finishedCount_ = requestsCount_;
    
    if (requestsCount_ > 0) {
        hasUnsaveChanges_ = NO;
    }
    
    if (flags[0]) {
        [self updateUsernameProfile];
    
    } else {
        if (flags[1]) {
            [self updateUserAvatarProfile];
        }
    }
}

- (void)setSaveButtonEnabled:(BOOL)enabled {
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    UIBarButtonItem *rightBarButtonItem = nil;
//    if (isAboveiOS7) {
        rightBarButtonItem = (self.navigationItem.rightBarButtonItems)[1];
//    }else {
//        rightBarButtonItem = self.navigationItem.rightBarButtonItem;
//    }
    
    UIButton *btn = (UIButton *)rightBarButtonItem.customView;
    btn.enabled = enabled;
}

- (void)updateSaveState {
    [self setSaveButtonEnabled:(avatarPath_ != nil || username_ != nil) ? YES : NO];
}

- (NSString *)displayUsername {
    return (username_ != nil) ? username_ : user_.screenName;
}

- (void)updateUsername:(NSString *)username {
    self.username = username;
    if(username != nil) {
        hasUnsaveChanges_ = YES;
    }
    
    [self updateSaveState];
    
    // If current view controller did receive memory warning. The table view was unload.
    if(tableView_ != nil){
        UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0x01 inSection:0x00]];
        cell.detailTextLabel.text = [self displayUsername];
    }
}

- (void)setAvatarPath:(NSString *)avatarPath {
    if(avatarPath_ != avatarPath){
//        [avatarPath_ release];
        avatarPath_ = avatarPath;// retain];
    }
}

- (NSString *)avatarPath {
    if(avatarPath_ == nil){
        NSString *path = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
        
        NSString *filename = [NSString stringWithFormat:@"%@_%lu_avatar", user_.userId, (unsigned long)time(NULL)];
        path = [path stringByAppendingPathComponent:filename];
        
        avatarPath_ = path ;//retain];
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
        avatar = [[KDCache sharedCache] avatarForCacheKey:[user_ getAvatarCacheKey] fromDisk:YES];
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

- (void) didGenerateUserAvatar:(UIImage *)image {
    hasAvatarCompressionTask_ = NO;
    
    BOOL generated = NO;
    BOOL succeed = (image != nil) ? YES : NO;
    if (succeed) {
        CGSize size = image.size;
        KDImageSize *tinyAvatarSize = [KDImageSize defaultUserAvatarSize];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSData *data = nil;
        UIImage *tinyAvatar = nil;
        if(size.width > tinyAvatarSize.width || size.height > tinyAvatarSize.height){
            // fast crop the avatar on main thread
            tinyAvatar = [image fastCropToSize:tinyAvatarSize.size];
            
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
            [avatarView_ updateAvatar:tinyAvatar];
        }
    }
    
    NSString *info = nil;
    if(generated) {
        [self updateSaveState];
        
    }else {
        // if generate user avatar did fail, clear the avatar path
        self.avatarPath = nil;
        info = NSLocalizedString(@"GENERATE_AVATAR_DID_FAIL", @"");
    }
    
    [self showUpdateProfileProgressInfo:info];
}

- (void) presentImagePickerController:(BOOL)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (takePhoto) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
//    [picker release];
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
    // clear cached avatar if need
    [self clearCachedAvatars];
    self.avatarPath = nil;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(image == nil){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image != nil) {
        CGSize size = image.size;
        CGFloat wh = 240.0;
        if(size.width > wh || size.height > wh){
            hasAvatarCompressionTask_ = YES;
            [self showUpdateProfileProgressInfo:NSLocalizedString(@"OPTIMIZING", @"")];
            
            KDImageSize *imageSize = [KDImageSize imageSize:CGSizeMake(wh, wh)];
            KDImageOptimizationTask *task = [[KDImageOptimizationTask alloc] initWithDelegate:self image:image imageSize:imageSize userInfo:nil];
            task.optimizationType = KDImageOptimizationTypeMinimumOptimal;
            
            [[KDImageOptimizer sharedImageOptimizer] addTask:task];
//            [task release];
//
        }else {
            // update
            [self didGenerateUserAvatar:image];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];  
}


//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIActionSheet delegate method

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.cancelButtonIndex == buttonIndex) return;
    
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

//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
        [self dismissUserProfileEditViewController];
    }
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(tableView_);
}

- (void) dealloc {
    // clear cached avatar if need
    [self clearCachedAvatars];
    
    //KD_RELEASE_SAFELY(user_);
    //KD_RELEASE_SAFELY(username_);
    //KD_RELEASE_SAFELY(avatarPath_);
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //[super dealloc];
}

@end


