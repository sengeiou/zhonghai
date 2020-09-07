//
//  XTShareView.m
//  XT
//
//  Created by Gil on 13-9-26.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTShareView.h"
#import "UIImage+XT.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDataAdditions.h"

@interface XTShareView ()
@property (nonatomic, strong) XTShareDataModel *shareData;
@property (nonatomic, assign) int cancelButtonIndex;
@property (nonatomic, strong) UITextField *shareTextField;
@end

@implementation XTShareView

- (id)initWithShareData:(XTShareDataModel *)shareData
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, ShareViewSize.width, ShareViewSize.height)];
    if (self) {
        
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6.0;
        
        self.shareData = shareData;
    }
    return self;
}

@end

@interface XTShareStartView ()

//shareType = ShareMessageText
@property (nonatomic, strong) UILabel *shareTextLabel;

//shareType = ShareMessageImage
@property (nonatomic, strong) UIImageView *shareImageView;

//shareType = ShareMessageNews
@property (nonatomic, strong) UILabel *shareTitleLabel;
@property (nonatomic, strong) UILabel *shareContentLabel;
@property (nonatomic, strong) UIImageView *shareThumbImageView;
@property (nonatomic, strong) UILabel *shareSourceAppLabel;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation XTShareStartView

- (id)initWithShareData:(XTShareDataModel *)shareData
{
    self = [super initWithShareData:shareData];
    
    if (self) {
        
        CGFloat startX = 10.0;
        CGFloat startY = 10.0;
        CGFloat x = startX;
        CGFloat y = startY;
        
        switch (shareData.shareType) {
            case ShareMessageText:
            {
                XTShareTextDataModel *textDM = shareData.mediaObject;
                
                UILabel *shareTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, ShareViewSize.width - 24.0, 88.0)];
                shareTextLabel.backgroundColor = self.backgroundColor;
                shareTextLabel.textColor = FC1;
                shareTextLabel.font = FS4;
                shareTextLabel.numberOfLines = 0;
                shareTextLabel.text = textDM.text;
                [self addSubview:shareTextLabel];
                self.shareTextLabel = shareTextLabel;
                
                y += (self.shareTextLabel.bounds.size.height + 5);
                UILabel *shareSourceAppLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, ShareViewSize.width - 24.0, 15.0)];
                shareSourceAppLabel.backgroundColor = self.backgroundColor;
                shareSourceAppLabel.textColor = FC2;
                shareSourceAppLabel.font = FS8;
                shareSourceAppLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTShareView_From"),shareData.appName];
                shareSourceAppLabel.textAlignment = NSTextAlignmentRight;
                [self addSubview:shareSourceAppLabel];
                self.shareSourceAppLabel = shareSourceAppLabel;
            }
                break;
            case ShareMessageImage:
            {
                XTShareImageDataModel *imageDM = shareData.mediaObject;
                
                UIImageView *shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ShareViewSize.width-88.0)/2, startY, 88.0, 88.0)];
                shareImageView.contentMode = UIViewContentModeScaleAspectFit;
                shareImageView.image = [UIImage imageWithData:[NSData base64DataFromString:imageDM.imageData]];
                [self addSubview:shareImageView];
                self.shareImageView = shareImageView;
                
                y += (self.shareImageView.bounds.size.height + 5);
                UILabel *shareSourceAppLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, ShareViewSize.width - 24.0, 15.0)];
                shareSourceAppLabel.backgroundColor = self.backgroundColor;
                shareSourceAppLabel.textColor = FC2;
                shareSourceAppLabel.font = FS8;
                shareSourceAppLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTShareView_From"),shareData.appName];
                shareSourceAppLabel.textAlignment = NSTextAlignmentRight;
                [self addSubview:shareSourceAppLabel];
                self.shareSourceAppLabel = shareSourceAppLabel;
            }
                break;
            case ShareMessageNews:
            case ShareMessageApplication:
            {
                XTShareNewsDataModel *news = shareData.mediaObject;
                UILabel *shareTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, ShareViewSize.width - 24.0, 16.0)];
                shareTitleLabel.backgroundColor = self.backgroundColor;
                shareTitleLabel.textColor = FC1;
                shareTitleLabel.font = FS3;
                shareTitleLabel.numberOfLines = 1;
                shareTitleLabel.text = news.title;
                [self addSubview:shareTitleLabel];
                self.shareTitleLabel = shareTitleLabel;
                
                y = CGRectGetMaxY(self.shareTitleLabel.frame) + [NSNumber kdDistance1];
                UIImageView *shareThumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(startX, y, 50.0, 50.0)];
                shareThumbImageView.layer.masksToBounds = YES;
                shareThumbImageView.layer.cornerRadius = 6;
                if(news.thumbData.length > 0) {
                    shareThumbImageView.image = [UIImage imageWithData:[NSData base64DataFromString:news.thumbData]];
                }else {
                    [shareThumbImageView setImageWithURL:[NSURL URLWithString:news.thumbURL] placeholderImage:[XTImageUtil cellThumbnailImageWithType:2]];
                }
                [self addSubview:shareThumbImageView];
                self.shareThumbImageView = shareThumbImageView;
                
                //来自信息
                y = CGRectGetMaxY(self.shareThumbImageView.frame) + [NSNumber kdDistance2];
                UILabel *shareSourceAppLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, y, 80.0, 15.0)];
                shareSourceAppLabel.backgroundColor = self.backgroundColor;
                shareSourceAppLabel.textColor = FC2;
                shareSourceAppLabel.font = FS8;
                shareSourceAppLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTShareView_From"),shareData.appName];
                [self addSubview:shareSourceAppLabel];
                self.shareSourceAppLabel = shareSourceAppLabel;
                
                x = (CGRectGetMaxX(self.shareThumbImageView.frame) + [NSNumber kdDistance1]);
                y = self.shareThumbImageView.frame.origin.y;
                UILabel *shareContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                shareContentLabel.backgroundColor = self.backgroundColor;
                shareContentLabel.textColor = FC1;
                shareContentLabel.font = FS4;
                shareContentLabel.numberOfLines = 0;
                shareContentLabel.text = news.content;
                
                CGSize titleSize = [news.content boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame) - x - [NSNumber kdDistance1], 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: FS4} context:nil].size;
                shareContentLabel.frame = CGRectMake(x, y + (CGRectGetHeight(self.shareThumbImageView.frame) - titleSize.height) / 2, titleSize.width, titleSize.height);
                [self addSubview:shareContentLabel];
                self.shareContentLabel = shareContentLabel;
                
                //调整当前的 y 的高度
                y += shareContentLabel.frame.size.height;
                if(y < self.shareThumbImageView.bounds.size.height + 35.0 + 5.0)
                {
                    y = self.shareThumbImageView.bounds.size.height + 35.0 + 5.0;
                }
            }
                break;
            default:
                break;
        }
        
        CGFloat space = 0;
        if (shareData.shareType != ShareMessageApplication) {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(startX, 138.0, ShareViewSize.width - 24.0, 34.0)];
            textField.placeholder = ASLocalizedString(@"XTShareView_Say");
            textField.layer.cornerRadius = 5.0;
            textField.backgroundColor = [UIColor whiteColor];
            textField.layer.borderColor = BOSCOLORWITHRGBA(0xB9B9B9, 1.0).CGColor;
            textField.layer.borderWidth = 1.0;
            textField.font = [UIFont systemFontOfSize:14.0];
            textField.returnKeyType = UIReturnKeyDone;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, textField.bounds.size.height)];
            leftView.backgroundColor = textField.backgroundColor;
            textField.leftView = leftView;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.delegate = self;
            [self addSubview:textField];
            self.shareTextField = textField;
            
            space = 48.0;
        }
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [cancelBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [cancelBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        if (shareData.shareType == ShareMessageApplication || shareData.shareType == ShareMessageNews) {
            [cancelBtn setFrame:CGRectMake(0, y + 30.0 + space, ShareViewSize.width / 2, 44.0)];
        } else {
            [cancelBtn setFrame:CGRectMake(0, 136.0 + space, ShareViewSize.width / 2, 44.0)];
        }
        
        [cancelBtn setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
        [cancelBtn setTitleColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        //添加上边框
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ShareViewSize.width / 2, 1)];
        topLine.backgroundColor = BOSCOLORWITHRGBA(0xE6E6E6, 1.0);
        [cancelBtn addSubview:topLine];
        //添加右侧边框
        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(ShareViewSize.width / 2 - 1, 0, 1, 44.0)];
        rightLine.backgroundColor = BOSCOLORWITHRGBA(0xE6E6E6, 1.0);
        [cancelBtn addSubview:rightLine];
        
        [cancelBtn setTag:1];
        [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setCancelButtonIndex:(int)cancelBtn.tag];
        [self addSubview:cancelBtn];
        self.cancelButton = cancelBtn;
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [sendBtn setTitle:ASLocalizedString(@"Global_Send")forState:UIControlStateNormal];
        [sendBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [sendBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        if (shareData.shareType == ShareMessageApplication|| shareData.shareType == ShareMessageNews) {
            [sendBtn setFrame:CGRectMake(cancelBtn.frame.size.width, y + 30.0 + space, ShareViewSize.width / 2, 44.0)];
        } else {
            [sendBtn setFrame:CGRectMake(cancelBtn.frame.size.width, 136.0 + space, ShareViewSize.width / 2, 44.0)];
        }
        [sendBtn setTitleColor:BOSCOLORWITHRGBA(0x248eff, 1.0) forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        //添加上边框
        UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ShareViewSize.width / 2, 1)];
        topLine2.backgroundColor = BOSCOLORWITHRGBA(0xE6E6E6, 1.0);
        [sendBtn addSubview:topLine2];
        [sendBtn setTag:2];
        [sendBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBtn];
        self.sendButton = sendBtn;
        
        if (shareData.shareType == ShareMessageApplication || shareData.shareType == ShareMessageNews) {
            CGRect rect = self.frame;
            rect.size.height = sendBtn.frame.origin.y + sendBtn.frame.size.height;
            self.frame = rect;
        }
    }
    return self;
}

- (void)btnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:clickedButtonAtIndex:)]) {
        [self.delegate shareView:self clickedButtonAtIndex:btn.tag];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"])
        [textField resignFirstResponder];
    return YES;
}

@end

@interface XTShareFinishView ()

@property (nonatomic, strong) UIImageView *doneImageView;
@property (nonatomic, strong) UILabel *doneLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *stayButton;

@end

@implementation XTShareFinishView

- (id)initWithShareData:(XTShareDataModel *)shareData
{
    self = [super initWithShareData:shareData];
    if (self) {
        
        CGFloat y = 12.0;
        
        UIImageView *doneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 84.0, 84.0)];
        doneImageView.image = [XTImageUtil shareOKImage];
        doneImageView.center = CGPointMake(ShareViewSize.width/2, doneImageView.center.y);
        [self addSubview:doneImageView];
        self.doneImageView = doneImageView;
        
        y += (self.doneImageView.bounds.size.height + 7);
        UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, ShareViewSize.width, 16.0)];
        doneLabel.center = CGPointMake(ShareViewSize.width/2, doneLabel.center.y);
        doneLabel.backgroundColor = self.backgroundColor;
        doneLabel.textColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
        doneLabel.font = [UIFont systemFontOfSize:16.0];
        doneLabel.text = ASLocalizedString(@"XTShareView_Send");
        doneLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:doneLabel];
        self.doneLabel = doneLabel;
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setFrame:CGRectMake(12.0, 138.0, ShareViewSize.width - 24.0, 34.0)];
        [backBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [backBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [backBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [backBtn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xF0F0F0, 1.0)] forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x00AAF0, 1.0)] forState:UIControlStateHighlighted];
        [backBtn.layer setBorderWidth:1.0];
        [backBtn.layer setBorderColor:BOSCOLORWITHRGBA(0x06A3EC, 1.0).CGColor];
        [backBtn.layer setCornerRadius:3.0];
        [backBtn setTitleColor:BOSCOLORWITHRGBA(0x06A3EC, 1.0) forState:UIControlStateNormal];
        [backBtn setTitleColor:BOSCOLORWITHRGBA(0xD1EAFB, 1.0) forState:UIControlStateHighlighted];
        [backBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTShareView_GoBack"),shareData.appName] forState:UIControlStateNormal];
        [backBtn setTag:1];
        [backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setCancelButtonIndex:(int)backBtn.tag];
        [self addSubview:backBtn];
        self.backButton = backBtn;
        
        UIButton *stayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [stayBtn setFrame:CGRectMake(12.0, 179.0, ShareViewSize.width - 24.0, 34.0)];
        [stayBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [stayBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [stayBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [stayBtn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xF0F0F0, 1.0)] forState:UIControlStateNormal];
        [stayBtn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x00AAF0, 1.0)] forState:UIControlStateHighlighted];
        [stayBtn.layer setBorderWidth:1.0];
        [stayBtn.layer setBorderColor:BOSCOLORWITHRGBA(0x06A3EC, 1.0).CGColor];
        [stayBtn.layer setCornerRadius:3.0];
        [stayBtn setTitleColor:BOSCOLORWITHRGBA(0x06A3EC, 1.0) forState:UIControlStateNormal];
        [stayBtn setTitleColor:BOSCOLORWITHRGBA(0xD1EAFB, 1.0) forState:UIControlStateHighlighted];
        [stayBtn setTitle:[NSString stringWithFormat:ASLocalizedString(@"XTShareView_Stay"),KD_APPNAME]forState:UIControlStateNormal];
        [stayBtn setTag:2];
        [stayBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stayBtn];
        self.stayButton = stayBtn;
    }
    return self;
}

- (void)btnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:clickedButtonAtIndex:)]) {
        [self.delegate shareView:self clickedButtonAtIndex:btn.tag];
    }
}

@end
