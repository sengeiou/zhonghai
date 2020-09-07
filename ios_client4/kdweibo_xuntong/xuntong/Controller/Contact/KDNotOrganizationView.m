//
//  KDNotOrganizationView.m
//  kdweibo
//
//  Created by AlanWong on 14-10-15.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDNotOrganizationView.h"
#import "XTOpenSystemClient.h"


#define kDoNotShowNotOrganizationView @"kDoNotShowNotOrganizationView"
#define kDoNotShowNotOrganizationViewNotAdmin @"kDoNotShowNotOrganizationViewNotAdmin"

@interface KDNotOrganizationView()<UIAlertViewDelegate>
@property(nonatomic, strong) XTOpenSystemClient* client;
@end
@implementation KDNotOrganizationView

-(id)initWithFrame:(CGRect)frame Style:(ContactStyle)showType isAdmin:(BOOL)isAdmin{
    

    if (showType == ContactStyleShowAll) {
//        if (isAdmin) {
            self = [self initAllTypeIsAdminViewWithFrame:frame];


//        }
//        else{
//            self = [self initAllTypeNotAdminViewWithFrame:frame];
//
//
//        }
    }
    else{
//        if (isAdmin) {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kDoNotShowNotOrganizationView]) {
                return nil;
            }
            self = [self initRecentlyTypeIsAdminViewWithFrame:frame];

//        }
//        else{
//            if ([[NSUserDefaults standardUserDefaults]boolForKey:kDoNotShowNotOrganizationViewNotAdmin]) {
//                return nil;
//            }
//            self = [self initRecentlyTypeNotAdminViewWithFrame:frame];
//
//
//        }
    }
    
    return self;
}

-(id)initAllTypeIsAdminViewWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
//        CGFloat scale = 0.8;
//        if (isAboveiPhone5) {
//            scale = 1;
//        }
//        self.backgroundColor = BOSCOLORWITHRGBA(0xEAEAEA, 1.0);
//        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_manage_blank"]];
//        imageView.center = CGPointMake(self.bounds.size.width / 2, imageView.bounds.size.height / 2 + 75 * scale);
//        [self addSubview:imageView];
//        
//        
//        UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectZero];
//        label1.text = ASLocalizedString(@"KDNotOrganizationVie_Tip_1");
//        label1.textColor = [UIColor blackColor];
//        label1.font = [UIFont systemFontOfSize:14.0f];
//        label1.textAlignment = NSTextAlignmentCenter;
//        label1.backgroundColor = [UIColor clearColor];
//        [label1 sizeToFit];
//        label1.center = CGPointMake(self.bounds.size.width / 2, CGRectGetMaxY(imageView.frame) + label1.bounds.size.height / 2 + 20 * scale);
//        [self addSubview:label1];
//        
//        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:ASLocalizedString(@"KDLeftTeamMenuViewController_setting")forState:UIControlStateNormal];
//        [button setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
//        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
//        [button.titleLabel setTextColor:[UIColor whiteColor]];
//        [button setFrame:CGRectMake(0, 0, 224, 44)];
//        [button setCenter:CGPointMake(self.center.x, CGRectGetMaxY(label1.frame) + button.bounds.size.height / 2 + 30 * scale)];
//        button.layer.cornerRadius = 4.0f;
//        [button addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:button];
        
//        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectZero];
//        label2.text = ASLocalizedString(@"后续可在“侧边栏”-“管理员助手”中设置\n也可以在电脑上登录网页\nhttp://manage.kdweibo.com\n批量导入组织架构");
//        label2.textAlignment = NSTextAlignmentCenter;
//        label2.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
//        label2.font = [UIFont systemFontOfSize:12.0f];
//        label2.backgroundColor = [UIColor clearColor];
//        label2.numberOfLines = 0;
//        [label2 sizeToFit];
//        label2.center =CGPointMake(self.center.x, CGRectGetMaxY(button.frame) + label2.bounds.size.height / 2 + 50 * scale);
//        [self addSubview:label2];
    
    }
    return self;
}

-(id)initAllTypeNotAdminViewWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
//        CGFloat scale = 0.8;
//        if (isAboveiPhone5) {
//            scale = 1;
//        }
//        self.backgroundColor = BOSCOLORWITHRGBA(0xEAEAEA, 1.0);
//        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_manage_blank"]];
//        imageView.center = CGPointMake(self.bounds.size.width / 2, imageView.bounds.size.height / 2 + 75 * scale);
//        [self addSubview:imageView];
//        
//        
//        UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectZero];
//        NSString * string = ASLocalizedString(@"KDNotOrganizationVie_Tip_3");
//        NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:string];
//        NSRange range = [string rangeOfString:ASLocalizedString(@"KDNotOrganizationVie_Tip_4")];
//
//        [attributeString addAttribute:NSForegroundColorAttributeName value:BOSCOLORWITHRGBA(0x1A85FF, 1.0) range:range];
//        label1.attributedText = attributeString;
//        label1.userInteractionEnabled = YES;
//        label1.font = [UIFont systemFontOfSize:14.0f];
//        label1.textAlignment = NSTextAlignmentCenter;
//        label1.backgroundColor = [UIColor clearColor];
//        label1.numberOfLines = 0;
//        [label1 sizeToFit];
//        label1.center = CGPointMake(self.bounds.size.width / 2, CGRectGetMaxY(imageView.frame) + label1.bounds.size.height / 2 + 20 * scale);
//        [self addSubview:label1];
//        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setFrame:CGRectMake(40, 18, 70, 15)];
//        [button addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [label1 addSubview:button];
//
//        __weak KDNotOrganizationView * weakVC = self;
//        [self setHandleBlock:^{
//            UIAlertView * alart = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDNotOrganizationVie_Tip_5")delegate:weakVC cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles: ASLocalizedString(@"Global_Cancel"),nil];
//            [alart show];
//            
//        }];
    }
    return self;
}



-(id)initRecentlyTypeIsAdminViewWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
//        CGFloat scale = 0.8;
//        if (isAboveiPhone5) {
//            scale = 1;
//        }
//        self.backgroundColor = BOSCOLORWITHRGBA(0x000000, 0.6);
//        
//        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_manage_blank"]];
//        imageView.center = CGPointMake(self.bounds.size.width / 2, imageView.bounds.size.height / 2 + 45 + 75 * scale);
//        [self addSubview:imageView];
//        
//        
//        UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectZero];
//        label1.text = ASLocalizedString(@"KDNotOrganizationVie_Tip_1");
//        label1.textColor = [UIColor whiteColor];
//        label1.font = [UIFont systemFontOfSize:14.0f];
//        label1.textAlignment = NSTextAlignmentCenter;
//        label1.backgroundColor = [UIColor clearColor];
//        [label1 sizeToFit];
//        label1.center = CGPointMake(self.bounds.size.width / 2, CGRectGetMaxY(imageView.frame) + label1.bounds.size.height / 2 + 20 * scale);
//        [self addSubview:label1];
//        
//        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:ASLocalizedString(@"KDLeftTeamMenuViewController_setting")forState:UIControlStateNormal];
//        [button setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
//        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
//        [button.titleLabel setTextColor:[UIColor whiteColor]];
//        [button setFrame:CGRectMake(0, 0, 224, 44)];
//        [button setCenter:CGPointMake(self.center.x, CGRectGetMaxY(label1.frame) + button.bounds.size.height / 2 + 30 * scale)];
//        button.layer.cornerRadius = 4.0f;
//        [button addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:button];
//        
//        
//        UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
//        label.text = ASLocalizedString(@"KDNotOrganizationVie_Tip_6");
//        label.font = [UIFont systemFontOfSize:12.0f];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = BOSCOLORWITHRGBA(0xFFFFFF, 0.6);
//        label.textAlignment = NSTextAlignmentCenter;
//        [label sizeToFit];
//        UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, label.bounds.size.height -1, label.bounds.size.width, 1)];
//        [bottomLine setBackgroundColor:BOSCOLORWITHRGBA(0xAEAEAE, 1.0)];
//        [label addSubview:bottomLine];
//        label.center = CGPointMake(self.center.x + label.bounds.size.width / 2, CGRectGetMaxY(button.frame) + label.bounds.size.height / 2 + 15 * scale);
//        [self addSubview:label];
//
//        UIButton * checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
////        [checkButton setImage:[UIImage imageNamed:@"task_checkbox_unselected"] forState:UIControlStateNormal];
////        [checkButton setImage:[UIImage imageNamed:@"task_checkbox_selected"] forState:UIControlStateSelected];
//        [checkButton sizeToFit];
//        checkButton.center = CGPointMake(CGRectGetMinX(label.frame) - checkButton.bounds.size.width / 2 -20 , label.center.y);
//        
//        checkButton.frame = label.frame;
//      //  SetBorder(checkButton, [UIColor redColor]);
//        [checkButton addTarget:self action:@selector(checkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:checkButton];
//
        
//        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectZero];
//        label2.text = ASLocalizedString(@"后续可在“侧边栏”-“管理员助手”中设置\n也可以在电脑上登录网页\nhttp://manage.kdweibo.com\n批量导入组织架构");
//        label2.textAlignment = NSTextAlignmentCenter;
//        label2.textColor = [UIColor whiteColor];
//        label2.font = [UIFont systemFontOfSize:12.0f];
//        label2.backgroundColor = [UIColor clearColor];
//        label2.numberOfLines = 0;
//        [label2 sizeToFit];
//        label2.center =CGPointMake(self.center.x, CGRectGetMaxY(button.frame) + label2.bounds.size.height / 2 + 50 * scale);
//        [self addSubview:label2];
        
    }
    return self;
}

-(id)initRecentlyTypeNotAdminViewWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
//        CGFloat scale = 0.8;
//        if (isAboveiPhone5) {
//            scale = 1;
//        }
//        self.backgroundColor = BOSCOLORWITHRGBA(0x000000, 0.6);
//        
//        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_manage_blank"]];
//        imageView.center = CGPointMake(self.bounds.size.width / 2, imageView.bounds.size.height / 2 + 45 + 75 * scale);
//        [self addSubview:imageView];
//        
//        
//        UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectZero];
//        label1.textColor = [UIColor whiteColor];
//        NSString * string = ASLocalizedString(@"KDNotOrganizationVie_Tip_3");
//        NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:string];
//        NSRange range = [string rangeOfString:ASLocalizedString(@"KDNotOrganizationVie_Tip_4")];
//        [attributeString addAttribute:NSForegroundColorAttributeName value:BOSCOLORWITHRGBA(0x1A85FF, 1.0) range:range];
//        label1.attributedText = attributeString;
//        label1.userInteractionEnabled = YES;
//        label1.font = [UIFont systemFontOfSize:14.0f];
//        label1.textAlignment = NSTextAlignmentCenter;
//        label1.backgroundColor = [UIColor clearColor];
//        label1.numberOfLines = 0;
//        [label1 sizeToFit];
//        label1.center = CGPointMake(self.bounds.size.width / 2, CGRectGetMaxY(imageView.frame) + label1.bounds.size.height / 2 + 20 * scale);
//        [self addSubview:label1];
//        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setFrame:CGRectMake(40, 18, 70, 15)];
//        [button addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [label1 addSubview:button];
//        
        
        
//        UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
//        label.text = ASLocalizedString(@"知道了，以后再说");
//        label.font = [UIFont systemFontOfSize:12.0f];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = BOSCOLORWITHRGBA(0xFFFFFF, 0.6);
//        label.textAlignment = NSTextAlignmentCenter;
//        [label sizeToFit];
//        UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, label.bounds.size.height -1, label.bounds.size.width, 1)];
//        [bottomLine setBackgroundColor:BOSCOLORWITHRGBA(0xAEAEAE, 1.0)];
//        [label addSubview:bottomLine];
//        label.center = CGPointMake(self.center.x + label.bounds.size.width / 2, CGRectGetMaxY(label1.frame) + label.bounds.size.height / 2 + 15 * scale);
//        [self addSubview:label];
//        
//        UIButton * checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
////        [checkButton setImage:[UIImage imageNamed:@"task_checkbox_unselected"] forState:UIControlStateNormal];
////        [checkButton setImage:[UIImage imageNamed:@"task_checkbox_selected"] forState:UIControlStateSelected];
////        [checkButton sizeToFit];
//        checkButton.tag = 1001;
//        checkButton.center = CGPointMake(CGRectGetMinX(label.frame) - checkButton.bounds.size.width / 2 -20 , label.center.y);
//        
//        checkButton.frame = label.frame;
//      //  SetBorder(checkButton, [UIColor blackColor]);
//        [checkButton addTarget:self action:@selector(checkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:checkButton];

        
//        UIButton * button1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button1 setTitle:ASLocalizedString(@"KDApplicationViewController_tips_i_know")forState:UIControlStateNormal];
//        [button1 setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
//        [button1.titleLabel setFont:[UIFont systemFontOfSize:16]];
//        [button1.titleLabel setTextColor:[UIColor whiteColor]];
//        [button1 setFrame:CGRectMake(0, 0, 183, 44)];
//        button1.tag = 1001;
//        [button1 setCenter:CGPointMake(self.center.x, CGRectGetMaxX(label1.frame)+40 + button.bounds.size.height / 2 + 43 * scale)];
//        button1.layer.cornerRadius = 4.0f;
//        [button1 addTarget:self action:@selector(checkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:button1];
//        
//        __weak KDNotOrganizationView * weakVC = self;
//        [self setHandleBlock:^{
//            UIAlertView * alart = [[UIAlertView alloc]initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_14")message:ASLocalizedString(@"KDNotOrganizationVie_Tip_5")delegate:weakVC cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles: ASLocalizedString(@"Global_Sure"),nil];
//            [alart show];
//            
//        }];

    }
    return self;
}
#pragma Button Method
//确定的操作，有实际操作的方法
-(void)confirmButtonClick:(UIButton *)button{
    if (_handleBlock) {
        _handleBlock();
    }
}
//不做其他操作，只是离开界面
-(void)uselessButtonClick:(UIButton *)button{
    [self removeFromSuperview];
}
//选择按钮的事件
-(void)checkButtonClick:(UIButton *)button{
    [button setSelected:!button.isSelected];
    [[NSUserDefaults standardUserDefaults]setBool:button.isSelected forKey:(button.tag == 1001 ? kDoNotShowNotOrganizationViewNotAdmin : kDoNotShowNotOrganizationView)];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self removeFromSuperview];
}
#pragma NetWork Request Method
-(void)sendAdminMessage{
    if (_client == nil) {
        _client = [[XTOpenSystemClient alloc]initWithTarget:nil action:nil];
    }
    [_client sendAdminMessageForNotOrganization];
}
#pragma UIAlartViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString * buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:ASLocalizedString(@"Global_Sure")]) {
        [self sendAdminMessage];
    }
    
}


@end
