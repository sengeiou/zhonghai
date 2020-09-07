//
//  KDChooseInviteHintVIew.m
//  kdweibo
//
//  Created by AlanWong on 14-10-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseInviteHintView.h"

@implementation KDChooseInviteHintView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat scale = 0.8;
        if (isAboveiPhone5) {
            scale = 1;
        }
        self.backgroundColor = BOSCOLORWITHRGBA(0x000000, 0.7);
        
        UIButton * bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bgButton setFrame:self.bounds];
        [bgButton addTarget:self action:@selector(bgButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgButton];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:ASLocalizedString(@"KDChooseInviteHintView_InVite")forState:UIControlStateNormal];
        [button setBackgroundColor:BOSCOLORWITHRGBA(0x1A85FF,1.0)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        [button setFrame:CGRectMake(0, 0, 224, 44)];
        [button setCenter:CGPointMake(self.center.x, + button.bounds.size.height / 2 + 130 * scale)];
        button.layer.cornerRadius = 4.0f;
        [button addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cm_img_word_normal"]];
        imageView.center = CGPointMake(self.center.x, CGRectGetMaxY(button.frame) + imageView.bounds.size.height + 75 * scale);
        [self addSubview:imageView];
        

    }
    return  self;
}

-(void)confirmButtonClick:(UIButton *)button{
    if (_handleBlock) {
        _handleBlock();
    }
    
    [self.delegate buttonPressedWithView:self];
}

-(void)bgButtonTap:(UIButton *)button{
    [self removeFromSuperview];
}
@end
