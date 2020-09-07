 //
//  KDCommon.m
//  TwitterFon
//
//  Created by apple apple on 12-3-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDVersion.h"
#import "KDAppVersionUpdates.h"

#import "KDWeiboServicesContext.h"
#import "KDConfigurationContext.h"
#import "KDManagerContext.h"
#import "UIColor+KDV6.h"

//notificationDMPaticipantGridCellAvatar

NSString * const KDDMThreadSubjectDidChangeNofication = @"dmThreadSubjectDidChanged";

NSString * const KDDMPaticipantGridCellAvatarDidTouched = @"dmPaticipantGridCellAvatarDidTouched";

NSString * const KDDMThreadHasBeenDeleted = @"dmThreadHasBeenDeleted";

NSString * const KDDMThreadHasBeenToped   = @"dmThreadHasBeenToped";

NSString * const KDDMParticipantShouldDeleted   = @"KDDMParticipantShouldDeleted";

NSString * const KDDMThreadHasBeenCancelTope = @"KDDMThreadHasBeenCancelTope";

NSString * const KDGridCellAddingViewTouched = @"kdGridCellAddingViewTouched";

NSString * const KDGridCellDeltingViewTouched = @"kdGridCellDeltingViewTouched";

NSString * const KDNewFunctionContacts = @"contacts";

NSString * const KDProfileUserAvatarUpdateNotification = @"kd_user_avatar_modified";

NSString * const KDProfileUserNameUpdateNotification = @"kd_user_name_modified";

NSString * const KDWeiboSendErrorNotification = @"kd_weibo_send_error";

NSString * const kKDPostViewControllerDraftSendNotification = @"KDPostViewControllerDraftSendNotification";

NSString * const kKDModalViewShowNotification = @"KDModalViewShowNotification";

NSString * const kKDModalViewHideNotification = @"KDModalViewHideNotification";

NSString* chineseWeek[]={@"一",@"二",@"三",@"四",@"五",@"六",@"日"};

NSString * const kKDCommunityDidChangedNotification = @"kKDCommunityDidChanged";

NSString * const kKDStatusDetailShouldFresh = @"kKDStatusDetailShouldFresh";

NSString * const kKDStatusShouldDeleted = @"kKDStatusShouldDeleted";

NSString * const kKDStatusOnPosting = @"kKDStatusOnPosting";

NSString * const kKDStatusAttributionShouledUpdated = @"kKDStatusAttributionShouledUpdated";

NSString * const KDTeamTipsViewDidTapNotification = @"com.kingdee.notification.did_tap_team_tips_view";

NSString * const kKDTokenExpiredNotification = @"com.kingdee.notification.token_did_expired";

NSString * const kKDMessageNoticeNumChangeNotification = @"com.kingdee.notification.notice_num_change";

@implementation KDCommon

- (id)init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

static NSString *version = nil;
+ (NSString *)visibleClientVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)buildNo
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BuildNo"];
}
+ (NSString *)getProjectCode
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ProjectCode"];
}
+ (NSString *)getCountly_Server
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Countly_Server"];
}


+ (NSString *)clientVersion {
    
    if (version == nil) {
        
        NSArray *array = [[self visibleClientVersion] componentsSeparatedByString:@"."];
        __block NSString *versionString = @"";
        for (int i = 0; i < 3; i++) {
            if (i < [array count]) {
                NSString *v = array[i];
                if (v.length > 0) {
                    versionString = [versionString stringByAppendingFormat:@"%@.",v];
                    continue;
                }
            }
            versionString = [versionString stringByAppendingFormat:@"%@.",@"0"];
        }
        versionString = [versionString substringToIndex:versionString.length - 1];
        
        version = versionString;
    }
    
    return version;
}
+ (NSString *) readForceUpdateNo
{
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
//    NSString *path=[paths objectAtIndex:0];
    NSString *Json_path=[resourcePath stringByAppendingPathComponent:@"iphone.json"];
    //==Json数据
    NSData *data=[NSData dataWithContentsOfFile:Json_path];
    //==JsonObject
    NSError *error= nil;
    NSDictionary *JsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:&error];
//    NSLog (@"%@",JsonObject);//打印json字典
    return [JsonObject valueForKey:@"forceUpdateNo"];
}
+ (NSInteger)versionLastBit {
    NSString *version = [KDCommon clientVersion];
    NSArray *array = [version componentsSeparatedByString:@"."];
    return [[array objectAtIndex:2] integerValue];
}

+ (NSInteger)lastBitOfVersion:(NSString *)versionString {
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    return [[versionComponents objectAtIndex:2] integerValue];
}

// format like kdweibo1.8.2 (iPhone Simulator; iPhone OS 5.1)
+ (NSString *) userAgent {
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; %@ %@)", @"kdweibo", [KDCommon clientVersion], 
                           [[UIDevice currentDevice] model],
                           [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    
    return userAgent;
}

+ (BOOL)hasNewClientVersion {
    BOOL hasNewVersion = NO;
    
        KDAppVersionUpdates *versionUpdates = [KDAppVersionUpdates retrieveLatestVersionUpdates];
        if(versionUpdates.version != nil){
            NSString *currentVersionString = [KDCommon clientVersion];
            
            NSComparisonResult result = 0;
            if([KDVersion quickCompareVersionA:versionUpdates.version versionB:currentVersionString results:&result]){
                if(result == NSOrderedDescending){
                    hasNewVersion = YES;
                }
            }
        }

    
    return hasNewVersion;
}

+ (BOOL)needShowAppTutorials {
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSString *previousClientVersion = [userDefaultAdapter stringForKey:KDWEIBO_USER_DEFAULTS_PREV_CLIENT_VERSION_KEY];
    if(previousClientVersion == nil) {
        return YES;
    }
    
    BOOL show = NO;
    NSString *currentVersionString = [KDCommon clientVersion];
    
    NSComparisonResult result = NSOrderedSame;
    if([KDVersion quickCompareVersionA:currentVersionString versionB:previousClientVersion results:&result]){
        if(result == NSOrderedDescending){
            // upgrade
            show = YES;
        }
    }
    
    if (show) {
        // check the application does exist app tutorials afer upgraded app
        BOOL hasAppTutorials = [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] hasAppTutorials];
        show = hasAppTutorials;
    }
    
    return show;
}

+ (void)openURLInApplication:(NSString *)appURL {
    if(appURL != nil){
        NSURL *target = [NSURL URLWithString:appURL];
        if([[UIApplication sharedApplication] canOpenURL:target]){
            [[UIApplication sharedApplication] openURL:target];
        }
    }
}


+ (BOOL) isNewFunction:(NSString *)function {
    
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    NSArray *newFunctions = [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getNewFunctions];
    return [userDefaultAdapter boolForKey:function]&& [newFunctions containsObject:function];
}

+ (void)setNewFuctionflag:(NSString *)function isNew:(BOOL)isNew {
    KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
    [userDefaultAdapter storeBool:isNew forKey:function];
    
}

+ (NSArray *)leftNavigationItemWithTarget:(id)target action:(SEL)selector {
    UIImage *image = [UIImage imageNamed:@"navigationItem_back"];
    UIImage *highlightImage = [UIImage imageNamed:@"navigationItem_back"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    [button sizeToFit];
    
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];// autorelease];
//    if(isAboveiOS7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                            target:nil action:nil];// autorelease];
        negativeSpacer.width = kLeftNegativeSpacerWidth;
        return @[negativeSpacer, leftBarButtonItem];
//    }else {
//        return @[leftBarButtonItem];
//    }
}

+ (NSArray *)rightNavigationItemWithTitle:(NSString *)title target:(id)target action:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *image = [UIImage imageNamed:@"navigationItem_title_arrow"];
//    UIImage *hlImage = [UIImage imageNamed:@"navigationItem_title_arrow"];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor kdTextColor5] forState:UIControlStateNormal];
    [btn setTitleColor:RGBCOLOR(161.f, 205.f, 255.f) forState:UIControlStateDisabled];
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setImage:hlImage forState:UIControlStateHighlighted];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
//    CGFloat titltWidth = CGRectGetWidth(btn.titleLabel.frame) - 5.f;
//    CGFloat imageWidth = CGRectGetWidth(btn.imageView.frame) + 6.f;
//    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 31, 0, -titltWidth)];
//    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn] ;//autorelease];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
//    if(isAboveiOS7) {
//        UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc]
//                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                            target:nil action:nil] autorelease];
//        negativeSpacer.width = kRightNegativeSpacerWidth;
        return @[rightItem];
//    }else {
//        return @[rightItem];
//    }
}


+ (BOOL)_addressBookModuleEnabled {
    BOOL enabled = NO;
    
    KDManagerContext *context = [KDManagerContext globalManagerContext];
    if ([context.communityManager isCompanyDomain] && ![context.userManager isPublicUser]) {
        enabled = YES;
    }
    
    return enabled;
}

+ (NSInteger) initNewFunctionFlag {
    NSInteger count = 0;
    if ([self _addressBookModuleEnabled]) {
        NSArray *newFunctions = [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getNewFunctions];
        KDAppUserDefaultsAdapter *userDefaultAdapter = [[KDWeiboServicesContext defaultContext] userDefaultsAdapter];
        for(NSString *function in  newFunctions) {
            if([userDefaultAdapter objectForKey:function] == nil){
                [self setNewFuctionflag:function isNew:YES];
                count ++;
            }else {
                if ([userDefaultAdapter boolForKey:function]) {
                    count ++;
                }
            }
            
        }

    }
       return count;
}




- (void) dealloc {
    //[super dealloc];
}
+ (BOOL)hasChinese:(NSString *)string
{
    BOOL hasChineseOrNot = NO;
    for(NSInteger i=0; i< [string length];i++){
        NSInteger a = [string characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            hasChineseOrNot = YES;
            break;
        }
    }
    return hasChineseOrNot;
}

//利用不越狱的机器没有这个权限来判定
+ (BOOL)isJailBreak
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return true;
    }
    NSLog(@"The device is NOT jail broken!");
    return false;
}
@end


CGRect scaleRectToFitStage(CGRect contentRect, CGSize stageSize) {
    CGFloat width = contentRect.size.width;
    CGFloat height = contentRect.size.height;
    
    CGRect scaleRect = contentRect;
    
    if((width < stageSize.width || width > stageSize.width) 
       || (height < stageSize.height || height > stageSize.height)) {
        
        CGFloat factor1 = width/stageSize.width;
        CGFloat factor2 = height/stageSize.height;
        
        if(factor1 < 1.0 && factor2 < 1.0){
            if(factor1 < factor2){
                height = floorf(height * stageSize.width/width);
                width = stageSize.width;
                
            }else{
                width = floorf(width * stageSize.height/height);
                height = stageSize.height;
            }
            
        }else if(factor1 > 1.0 && factor2 < 1.0){
            width = floorf(width * stageSize.height/height);
            height = stageSize.height;
            
        }else if(factor1 < 1.0 && factor2 > 1.0){
            height = floorf(height * stageSize.width/width);
            width = stageSize.width;
        }
        
        scaleRect = CGRectMake(floor((stageSize.width - width)*0.5), floor((stageSize.height - height)*0.5), width, height);
    }
    
    return scaleRect;
}

CGSize aspectScaleConstrainedSize(CGSize originalSize, CGSize constrainedSize) {
    if(originalSize.width <= constrainedSize.width && originalSize.height <= constrainedSize.height) return (originalSize);
    
    CGFloat hRatio = constrainedSize.height / originalSize.height;
    CGFloat wRatio = constrainedSize.width / originalSize.width;
    
    originalSize.height *= MIN(hRatio, wRatio);
    originalSize.width  *= MIN(hRatio, wRatio);
    
    return originalSize;
}

CGRect textboundsByContrainedWidth(CGFloat width ,UIFont *font ,NSString *text) {
    CGSize size = CGSizeMake(width, MAXFLOAT);
    size =  [text sizeWithFont:font constrainedToSize:size lineBreakMode:1];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    return rect;
}
