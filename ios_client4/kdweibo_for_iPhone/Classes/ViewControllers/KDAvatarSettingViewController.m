//
//  KDAvatarSettingViewController.m
//  kdweibo
//
//  Created by shen kuikui on 14-5-9.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDAvatarSettingViewController.h"
#import "KDAvatarView.h"
#import "KDManagerContext.h"
#import "KDImageOptimizationTask.h"
#import "KDDatabaseHelper.h"
#import "KDImageOptimizer.h"
#import "KDNotificationView.h"
#import "KDWeiboServicesContext.h"

@interface KDAvatarSettingViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, KDImageOptimizationTaskDelegate, UINavigationControllerDelegate>
{
    NSString *avatarPath_;
    BOOL hasAvatarCompressionTask_;
}

@property (nonatomic, retain) KDAvatarView *avatarView;
@property (nonatomic, retain) UILabel      *nameLabel;
@property (nonatomic, retain) UIButton     *uploadAvatarButton;
@property (nonatomic, retain) UIImage      *generatedImage;

@property (nonatomic, retain) KDUser       *currentUser;

@end

@implementation KDAvatarSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = ASLocalizedString(@"KDAvatarSettingViewController_avatar");
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_avatarView);
    //KD_RELEASE_SAFELY(_nameLabel);
    //KD_RELEASE_SAFELY(_uploadAvatarButton);
    //KD_RELEASE_SAFELY(avatarPath_);
    //KD_RELEASE_SAFELY(_currentUser);
    //KD_RELEASE_SAFELY(_generatedImage);
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(237, 237, 237);
    
    KDUser *currentUser = [[KDManagerContext globalManagerContext].userManager currentUser];
    self.currentUser = currentUser;
    // Do any additional setup after loading the view.
    self.avatarView = [KDAvatarView avatarView];
    self.avatarView.frame = CGRectMake(127.0f, 23.0f, 66.0f, 66.0f);
    self.avatarView.avatarDataSource = currentUser;
    self.avatarView.layer.cornerRadius = 3.0f;
    self.avatarView.layer.masksToBounds = YES;
    
    [self.view addSubview:_avatarView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;//autorelease];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.text = currentUser.screenName;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.nameLabel.bounds)) * 0.5f, CGRectGetMaxY(self.avatarView.frame) + 12.0f, CGRectGetWidth(self.nameLabel.bounds), CGRectGetHeight(self.nameLabel.bounds));
    [self.view addSubview:self.nameLabel];
    
    self.uploadAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.uploadAvatarButton.frame = CGRectMake(6.5f, CGRectGetMaxY(self.nameLabel.frame) + 23.0f, 307.0f, 42.0f);
    [self.uploadAvatarButton setTitle:ASLocalizedString(@"KDAvatarSettingViewController_upload_photo")forState:UIControlStateNormal];
    [self.uploadAvatarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.uploadAvatarButton setBackgroundColor:RGBCOLOR(32, 192, 0)];
    [self.uploadAvatarButton addTarget:self action:@selector(uploadAvatar:) forControlEvents:UIControlEventTouchUpInside];
    self.uploadAvatarButton.layer.cornerRadius = 3.0f;
    self.uploadAvatarButton.layer.masksToBounds = YES;
    [self.view addSubview:self.uploadAvatarButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.avatarView loadAvatar];
}

- (void)uploadAvatar:(UIButton *)sender
{
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
//    [actionSheet release];
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
        
        self.generatedImage = image;
        
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

- (void)showUpdateProfileProgressInfo:(NSString *)info {
    [[KDNotificationView defaultMessageNotificationView] showInView:self.view.window
                                                            message:info
                                                               type:KDNotificationViewTypeNormal];
}

- (void)updateUserAvatarProfile {
    [self showUpdateProfileProgressInfo:NSLocalizedString(@"UPDATING_USER_PROFILE", @"")];
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"image" filePath:avatarPath_];
    
    __block KDAvatarSettingViewController *upevc = self;// retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        KDUser *user = results;
        
        [upevc _handleResponseUser:user message:NSLocalizedString(@"UPDATE_USER_AVATAR_DID_FAIL", @"")];
        
        if (user != nil) {
            upevc.currentUser = user;
            upevc.avatarView.avatarDataSource = upevc.currentUser;
            [upevc.avatarView updateAvatar:upevc.generatedImage];
            
            UIImage *image = [upevc getTinyAvatar];
            [[KDCache sharedCache] storeAvatarWithImage:image forCacheKey:[upevc.currentUser getAvatarCacheKey] writeToDisk:YES];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KDProfileUserAvatarUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:image forKey:@"avatar"]];
        }
        
        // release current view controller
//        [upevc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/account/:updateProfileImage" query:query
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

- (void)presentImagePickerController:(BOOL)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (takePhoto) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
//    [picker release];
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
        
        NSString *filename = [NSString stringWithFormat:@"%@_%lu_avatar", self.currentUser.userId, (unsigned long)time(NULL)];
        path = [path stringByAppendingPathComponent:filename];
        
        avatarPath_ = path;// retain];
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

#pragma mark -
#pragma mark KDImageOptimizationTask delegate methods

- (void) willDropImageOptimizationTask:(KDImageOptimizationTask *)task {
    [self didGenerateUserAvatar:nil];
}

- (void) imageOptimizationTask:(KDImageOptimizationTask *)task didFinishedOptimizedImageWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:kKDImageOptimizationTaskCropedImage];
    [self didGenerateUserAvatar:image];
}

#pragma mark - UIActionSheet delegate method

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
