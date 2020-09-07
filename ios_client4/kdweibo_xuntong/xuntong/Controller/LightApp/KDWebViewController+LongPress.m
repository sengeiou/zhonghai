//
//  KDWebViewController+LongPress.m
//  kdweibo
//
//  Created by shifking on 15/10/29.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWebViewController+LongPress.h"
#import <objc/runtime.h>
#import "MBProgressHUD+Add.h"
#import "KDWebView+WebViewAdditions.h"
#import "KDScanHelper.h"

@interface KDWebViewController ()<UIGestureRecognizerDelegate>

@property (strong , nonatomic) NSString *pictureUrl;
@property (strong , nonatomic) NSString *linkUrl;

@end

@implementation KDWebViewController (LongPress)


- (void)setupLongPressEvent {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longtapAction:)];
     gesture.minimumPressDuration = 0.4;
    gesture.delegate = self;
    [self.webView.activeView addGestureRecognizer:gesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - event response
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [MBProgressHUD showError:ASLocalizedString(@"KDVideoPickerViewController_save_fail") toView:nil];
    }
    else {
        [MBProgressHUD showSuccess:ASLocalizedString(@"SavePhoto_Success") toView:nil];
    }
}

- (void)longtapAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [gestureRecognizer locationInView:self.webView];
        
        // convert point from view to HTML coordinate system
        CGSize viewSize = [self.webView frame].size;
        CGSize windowSize = [self.webView windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [self.webView scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        
        [self openContextualMenuAt:pt];
    }
}

- (void)openContextualMenuAt:(CGPoint)pt {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"KJS_LongPress" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView stringByEvaluatingJavaScriptFromString:jsCode];
    
    // get the Tags at the touch location
    NSString *tags = [self.webView stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%ld,%ld);",(long)pt.x,(long)pt.y]];
    
    NSString *tagsHREF = [self.webView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%ld,%ld);",(long)pt.x,(long)pt.y]];
    
    NSString *tagsSRC = [self.webView stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%ld,%ld);",(long)pt.x,(long)pt.y]];
    
    UIActionSheet *_actionActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    __block NSString *selectedLinkURL = @"";
    __block NSString *selectedImageURL = @"";
    __weak __typeof(self) weakSelf = self;
    
    // If an image was touched, add image-related buttons.
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        BOOL canShare = NO;
        if(self.personDataModel)
        {
            MessageNewsEachDataModel *shareData = [self getCurrentPageShareData];
            KDPublicAccountDataModel *pubacc = [[KDPublicAccountCache sharedPublicAccountCache] pubAcctForKey:shareData.appId];
            if(!pubacc && [self.personDataModel isPublicAccount])
                pubacc = (KDPublicAccountDataModel *)(self.personDataModel);
            
            if(pubacc)
                canShare = [pubacc allowInnerShare] || [pubacc allowOuterShare];
            else
                canShare = [BOSSetting sharedSetting].allowMsgInnerMobileShare || [BOSSetting sharedSetting].allowMsgOuterMobileShare;
        }
        
        //保存图片
        if (canShare) {
            [_actionActionSheet addButtonWithTitle:ASLocalizedString(@"SavePhoto")];
        }
        selectedImageURL = tagsSRC;
        self.pictureUrl = selectedImageURL;
    }
    
    // If a link is pressed add image buttons.
    if ([tags rangeOfString:@",A,"].location != NSNotFound){
        selectedLinkURL = tagsHREF;
        
        _actionActionSheet.title = tagsHREF;
        [_actionActionSheet addButtonWithTitle:ASLocalizedString(@"KDApplicationTableViewCell_open")];
        [_actionActionSheet addButtonWithTitle:ASLocalizedString(@"Copy")];
        
        self.linkUrl = selectedLinkURL;
    }
    
    //识别二维码菜单
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:tagsSRC] options:SDWebImageLowPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                
                if (image)
                {
                    //识别图中二维码
                    if([KDScanHelper scanQRWithImage:image])
                    {
                        [_actionActionSheet addButtonWithTitle:ASLocalizedString(@"Scan_QRCode")];
                        //重新设置cancelButtonIndex
                        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_actionActionSheet.numberOfButtons > 0) {
                        [_actionActionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
                        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
                        
                        _actionActionSheet.tag = 0x90;
                        [_actionActionSheet showInView:weakSelf.view];
                    }
                });
            }];
        });
    }
}

#pragma mark - UIActionSheetDelegate

- (BOOL)longPressShareActionWithTitle:(NSString *)title actionSheet:(UIActionSheet *)actionSheet {
    if (actionSheet.tag!= 0x90) {
        return NO;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    if ([title isEqualToString:ASLocalizedString(@"SavePhoto")] || [title isEqualToString:ASLocalizedString(@"Scan_QRCode")]) {
        
        if (!self.pictureUrl || self.pictureUrl.length == 0) {
            [MBProgressHUD showError:ASLocalizedString(@"KDVideoPickerViewController_save_fail") toView:nil];
        }
        else {
            NSURL *url = [NSURL URLWithString:self.pictureUrl];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[SDWebImageManager sharedManager] downloadWithURL:url options:SDWebImageLowPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished) {
                    if (image) {
                        if([title isEqualToString:ASLocalizedString(@"SavePhoto")])
                            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                        else
                        {
                            NSString *result = [KDScanHelper scanQRWithImage:image];
                            [[KDQRAnalyse sharedManager] execute:result callbackBlock:^(QRLoginCode qrCode, NSString *qrResult) {
    
                                [[KDQRAnalyse sharedManager] gotoResultVCInTargetVC:weakSelf withQRResult:qrResult andQRCode:qrCode];
                                
                            }];
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD showError:ASLocalizedString(@"KDVideoPickerViewController_save_fail") toView:nil];
                        });
                    }
                }];
            });
        }
        
    }
    
    if ([title isEqualToString:ASLocalizedString(@"KDApplicationTableViewCell_open")]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.linkUrl]];
        [self.webView loadRequest:request];
    }
    
    if ([title isEqualToString:ASLocalizedString(@"Copy")]) {
        [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:self.linkUrl]];
    }
    return YES;
}

#pragma mark - setter & getter
- (void)setPictureUrl:(NSString *)pictureUrl {
    objc_setAssociatedObject(self, @selector(pictureUrl), pictureUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)pictureUrl {
    return objc_getAssociatedObject(self, @selector(pictureUrl));
}

- (void)setLinkUrl:(NSString *)linkUrl {
    objc_setAssociatedObject(self, @selector(linkUrl), linkUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)linkUrl {
    return objc_getAssociatedObject(self, @selector(linkUrl));
}


@end
