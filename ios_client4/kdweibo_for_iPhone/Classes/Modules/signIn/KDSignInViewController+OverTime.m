//
//  KDSignInViewController+OverTime.m
//  kdweibo
//
//  Created by 张培增 on 2017/1/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDSignInViewController+OverTime.h"

#import "KDSocialsShareManager.h"

@implementation KDSignInViewController (OverTime)

- (BOOL)showOverTimeHintViewWithModel:(KDSignInOverTimeModel *)model {
    if (!model || safeString(model.alertClockInTime).length == 0) {
        return NO;
    }
    
    KDSignInOverTimeHintView *overTimeHintView = [[KDSignInOverTimeHintView alloc] initWithSignInOverTimeModel:model];
    overTimeHintView.buttonDidClickBlock = ^(NSInteger index){
        if (index == 0) {
            //[KDEventAnalysis event:event_signin_record_noshare_v2];
        }
        else if (index == 1) {
            //[KDEventAnalysis event:event_signin_record_sharewx_v2];
            [self shareOverTimeImage:model];
        }
    };
    [overTimeHintView showHintView];
    //[KDEventAnalysis event:event_signin_record_jiabanshare];
    
    return YES;
}

//分享图片
- (void)shareOverTimeImage:(KDSignInOverTimeModel *)model {
    [KDPopup showHUD:ASLocalizedString(@"分享中")];
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:model.bigPictureUrl] options:SDWebImageLowPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished){
        if (image) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = [self createShareImageData:model backgroundImage:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KDPopup hideHUD];
                    //分享到微信朋友圈
                    [SHARE_MANAGER shareToWechatWithImageData:imageData
                                                   isTimeline:YES];
                });
            });
        }
        else {
            [KDPopup showHUDToast:ASLocalizedString(@"分享失败")];
        }
    }];
}

//生成加班分享的图片
- (NSData *)createShareImageData:(KDSignInOverTimeModel *)model backgroundImage:(UIImage *)image {
    
    //宽度和高度
    CGFloat width = 750 / 2;
    CGFloat height = 1334 / 2;
    
    //最大Size
    CGSize size = CGSizeMake(width, height);
    CGSize textSize = CGSizeMake(width - 88, height);
    
    //Font
    UIFont *timeTextFont = [UIFont systemFontOfSize:36];
    UIFont *nameTextFont = [UIFont systemFontOfSize:19];
    UIFont *countTextFont = FS4;
    UIFont *extraRemarkFont = [UIFont systemFontOfSize:19];
    UIFont *extraRemarkAuthorFont = FS4;
    
    //文字段落格式
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 0;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);//opaque:NO  scale:2.0
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    //绘制时间
    NSString *timeText = safeString(model.shareClockInTime);
    CGSize timeTextSize = [timeText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:timeTextFont}context:nil].size;
    CGRect timeTextRect = CGRectMake(44, 75, timeTextSize.width, timeTextSize.height);
    [timeText drawInRect:timeTextRect withAttributes:@{NSFontAttributeName:timeTextFont, NSForegroundColorAttributeName:FC6, NSParagraphStyleAttributeName:paragraphStyle}];
    
    //绘制人名
    NSString *nameText = safeString([model.shareCeilTextArray safeObjectAtIndex:0]) ?: [NSString stringWithFormat:ASLocalizedString(@"我是%@，"), [BOSConfig sharedConfig].user.name];
    CGSize nameTextSize = [nameText boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameTextFont} context:nil].size;
    CGRect nameTextRect = CGRectMake(44, CGRectGetMaxY(timeTextRect) + 10, nameTextSize.width, nameTextSize.height);
    [nameText drawInRect:nameTextRect withAttributes:@{NSFontAttributeName:nameTextFont, NSForegroundColorAttributeName:FC6, NSParagraphStyleAttributeName:paragraphStyle}];
    
    //绘制用户数
    NSString *countText = [NSString stringWithFormat:@"%@\n%@", safeString([model.shareCeilTextArray safeObjectAtIndex:1]), safeString([model.shareCeilTextArray safeObjectAtIndex:2])];
    CGSize countTextSize = [countText boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:countTextFont} context:nil].size;
    CGRect countTextRect = CGRectMake(44, CGRectGetMaxY(nameTextRect) + 7, countTextSize.width, countTextSize.height);
    [countText drawInRect:countTextRect withAttributes:@{NSFontAttributeName:countTextFont, NSForegroundColorAttributeName:FC6, NSParagraphStyleAttributeName:paragraphStyle}];
    
    
    //绘制分割线
    UIImage *line = [UIImage imageNamed:@"signIn_overTime_line_big"];
    CGRect lineRect = CGRectMake(44, CGRectGetMaxY(countTextRect) + 28, width - 88, 5);
    [line drawInRect:lineRect];
    
    //绘制加班文案
    NSString *extraRemark = safeString(model.shareContent).length > 0 ? model.shareContent : ASLocalizedString(@"不加班的人生不完美。我加起班来我自己都害怕。");
    CGSize extraRemarkSize = [extraRemark boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:extraRemarkFont, NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    CGRect extraRemarkRect = CGRectMake(44, CGRectGetMaxY(lineRect) + 15, extraRemarkSize.width, extraRemarkSize.height);
    [extraRemark drawInRect:extraRemarkRect withAttributes:@{NSFontAttributeName:extraRemarkFont, NSForegroundColorAttributeName:FC6, NSParagraphStyleAttributeName:paragraphStyle}];
    
    //绘制加班文案作者
    NSString *extraRemarkAuthor = safeString(model.shareAuthor);
    CGSize extraRemarkAuthorSize = [extraRemarkAuthor boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:extraRemarkAuthorFont, NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    CGRect extraRemarkAuthorRect = CGRectMake(width - 44 - extraRemarkAuthorSize.width, CGRectGetMaxY(extraRemarkRect) + 12, extraRemarkAuthorSize.width, extraRemarkAuthorSize.height);
    [extraRemarkAuthor drawInRect:extraRemarkAuthorRect withAttributes:@{NSFontAttributeName:extraRemarkAuthorFont, NSForegroundColorAttributeName:FC6, NSParagraphStyleAttributeName:paragraphStyle}];
    
    //app名称
    NSString *appNameText = [NSString stringWithFormat:@"%@·%@", KD_APPNAME,ASLocalizedString(@"签到")];
    CGSize appNameTextSize = [appNameText boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:countTextFont} context:nil].size;
    CGRect appNameTextRect = CGRectMake((width-appNameTextSize.width)/2, height-35, appNameTextSize.width, appNameTextSize.height);
    [appNameText drawInRect:appNameTextRect withAttributes:@{NSFontAttributeName:FS6, NSForegroundColorAttributeName:FC6, NSParagraphStyleAttributeName:paragraphStyle}];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(newImage);
    return imageData;
}

@end
