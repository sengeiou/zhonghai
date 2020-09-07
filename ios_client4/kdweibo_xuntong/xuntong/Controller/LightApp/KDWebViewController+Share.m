//
//  KDWebViewController+Share.m
//  kdweibo
//
//  Created by Gil on 14-10-20.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController+Share.h"
#import "XTShareManager.h"
#import "KDSheet.h"
#import "BOSConfig.h"
#import "URL+MCloud.h"

#include <objc/runtime.h>

@interface KDWebViewController ()
//@property (nonatomic, strong) KDSheet *sheet;
@end


@implementation KDWebViewController (Share)

- (KDSheet *)sheet {
	return objc_getAssociatedObject(self, @selector(sheet));
}

- (void)setSheet:(KDSheet *)sheet {
	objc_setAssociatedObject(self, @selector(sheet), sheet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canOpenUrl
{
    return [[UIApplication sharedApplication] canOpenURL:self.webUrl];
}


- (void)geturltoweb
{
    if ([self canOpenUrl]) {
        [[UIApplication sharedApplication] openURL:self.webUrl];
    }
}

- (void)showShareActionSheet
{
    UIActionSheet *actionSheet;
    
    if([BOSConfig sharedConfig].user.partnerType != 1)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_choice")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDStatusDetailViewController_Forward"),ASLocalizedString(@"BubbleTableViewCell_Tip_12"),/*ASLocalizedString(@"BubbleTableViewCell_Tip_19"),*/ASLocalizedString(@"KDWebViewController_Open"),nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_choice")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"KDStatusDetailViewController_Forward"),/*ASLocalizedString(@"BubbleTableViewCell_Tip_19"),*/ASLocalizedString(@"KDWebViewController_Open"),nil];
    }
	[actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (BOOL)shareActionWithTitle:(NSString *)title
{
    BOOL result = YES;
    if ([title isEqualToString:ASLocalizedString(@"KDStatusDetailViewController_Forward")]) {
		[self forwardToCnversation];
	}
	else if ([title isEqualToString:ASLocalizedString(@"BubbleTableViewCell_Tip_12")]) {
		[self shareToCommunity];
	}
	else if ([title isEqualToString:ASLocalizedString(@"BubbleTableViewCell_Tip_19")]) {
		[self shareToSocial];
	}
	else if ([title isEqualToString:ASLocalizedString(@"KDWebViewController_Open")]) {
		[self geturltoweb];
	}
    else {
        result = NO;
    }
    return result;
}

/**
 *  转发内容到会话，只有打开公共号内容的时候，才会有
 *  alanwong
 */
- (void)forwardToCnversation {
	NSString *content =  nil;
	if ([self.shareNewsDataModel.text length] < 40) {
		content = self.shareNewsDataModel.text;
	}
	else {
		content = [NSString stringWithFormat:@"%@...", [self.shareNewsDataModel.text substringToIndex:38]];
	}
    
    // bug 4033
    NSString *photoURL = [NSString new];
    MessageNewsEachDataModel *news = self.shareNewsDataModel;
    PersonSimpleDataModel *person = self.personDataModel;
    if (news.name && news.name.length > 0) {
        photoURL = news.name;
    } else if (person.photoUrl && person.photoUrl.length > 0) {
        photoURL = person.photoUrl;
    } else {
        photoURL = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
    }
    
	NSDictionary *dic = @{ @"shareType" : @(3),
                           @"appName" :self.fromAppName?self.fromAppName:person.personName,
                           @"title" : news.title,
                           @"content" :content,
		                   @"thumbUrl" : photoURL,
                           @"webpageUrl" : news.url };
    
    
    // bug 12147
    if(news.appId.length != 0)
    {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [tempDic setObject:news.appId forKey:@"appId"];
        dic = tempDic;
    }
    
	[XTShareManager shareWithDictionary:dic andChooseContentType:XTChooseContentShareStatus];
}

/**
 *  分享内容到动态，只有打开公共号内容的时候，才会有
 *  alanwong
 */
- (void)shareToCommunity {
//	KDCommunityShareView *shareView = nil;
//	shareView = [[KDCommunityShareView alloc]initWithFrame:self.view.bounds type:KDCommunityShareTypeNew isForIPhone5:isAboveiPhone5];
//	shareView.theNewDataMedel = self.shareNewsDataModel;
//	shareView.personUrl = self.personDataModel.photoUrl;
//	[self.view addSubview:shareView];
    
    KDDefaultViewControllerFactory *factory = [KDDefaultViewControllerContext defaultViewControllerContext].defaultViewControllerFactory;
    PostViewController *pvc = [factory getPostViewController];
    pvc.isSelectRange = YES;
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    
    MessageNewsEachDataModel *news=self.shareNewsDataModel;
    
    if ([news.title isEqualToString:news.text] || news.title.length == 0) {//多图新闻类型
        draft.content = [NSString stringWithFormat:@"%@\n%@",news.text,news.url];
        
    }
    else{//单图新闻类型
        
        int totalLenght = (int)(news.title.length + news.text.length + news.url.length);
        if (totalLenght < 990) {
            draft.content = [NSString stringWithFormat:@"%@\n%@\n%@",news.title,news.text,news.url];
        }
        else{
            NSString *  string = [news.text substringToIndex:(1000 - news.url.length - news.title.length - 10)];
            draft.content = [NSString stringWithFormat:@"%@\n%@\n%@",news.title,string,news.url];
            
        }
        
    }
    
    NSArray * imageArray = nil;
    NSString *imagePath = [NSString new];
    NSURL * url = [NSURL URLWithString:news.name];
    BOOL isImageExists = [[SDWebImageManager sharedManager]diskImageExistsForURL:url];
    if (isImageExists) {
        imagePath = [[SDWebImageManager sharedManager] diskImagePathForURL:url imageScale:SDWebImageScaleNone];
    }
    
    if ([imagePath length] > 0) {
        imageArray = @[imagePath];
    }
    [pvc setPickedImage:imageArray];
    
    pvc.draft = draft;
    [KDWeiboAppDelegate setExtendedLayout:pvc];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showPostViewController:pvc];
}

/**
 *  分享内容到其他平台，只有打开公共号内容的时候，才会有
 *  alanwong
 */
- (void)shareToSocial {
    NSData *imageData = nil;
    MessageNewsEachDataModel *shareData = [self getCurrentPageShareData];
    if (!shareData) {
        return ;
    }
    
    if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:shareData.name]]) {
        imageData = UIImageJPEGRepresentation([[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:shareData.name] imageScale:SDWebImageScaleNone]],0.5);
//        imageData = UIImageJPEGRepresentation([[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:shareData.url]] imageScale:0.5]);
        
    }
    else {
        imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"icon-small"], 0.5);
    }
    
    NSString *title = shareData.title;
    NSString *description = shareData.text;
    if ([shareData.title isEqualToString:shareData.text] || self.title.length == 0) {
        title = shareData.text;
        description =  @"";
    }
    
    //分享当前界面的网址
    NSString *requestString = shareData.url;
    
    KDSheetShareWay shareType = (KDSheetShareWayQQ | KDSheetShareWayWeibo | KDSheetShareWayWechat );
    KDSheet *sheet = [[KDSheet alloc] initMediaWithShareWay:shareType title:title description:description thumbData:imageData webpageUrl:requestString viewController:self];
    self.sheet = sheet;
    [sheet share];
}

- (void)shareToSocialWithTitle:(NSString *)title image:(UIImage *)image detail:(NSString *)detail {
    MessageNewsEachDataModel *shareData = [self getCurrentPageShareData];
    NSString *requestString = shareData.name;
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!detail) {
        detail = @"";
    }
    KDSheetShareWay shareType = (KDSheetShareWayQQ | KDSheetShareWayWeibo | KDSheetShareWayWechat );
    
    KDSheet *sheet = [[KDSheet alloc] initMediaWithShareWay:shareType title:title description:detail thumbData:imageData webpageUrl:requestString viewController:self];
    self.sheet = sheet;
    [sheet share];
}

@end
