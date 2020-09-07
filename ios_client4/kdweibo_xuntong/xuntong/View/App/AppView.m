//
//  AppView.m
//  MobileFamily
//
//  Created by kingdee eas on 13-5-16.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "AppView.h"

#define APPVIEWWIDTH 107
#define DEFUALTLOGOURL @"http://mcloud.kingdee.com//3gol/portal/app/logo/0.png"
@interface AppView()
@property(nonatomic, strong)  UITapGestureRecognizer *tapGesture ;
@end
@implementation AppView
@synthesize appNameLabel,delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (id)initWithpersonDataModel:(PersonSimpleDataModel *)dataModel frame:(CGRect)initFrame
{
    self = [super initWithFrame:initFrame];
    if (self) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(publicphotoBtnPressed:)];
        [self addGestureRecognizer:_tapGesture];
        self.viewDM = dataModel;
        
        //应用logo
        appImageView = [[UIImageView alloc] init];
        appImageView.frame = CGRectMake((initFrame.size.width - 50) / 2, 10, 50, 50);
        appImageView.backgroundColor = [UIColor clearColor];
        appImageView.layer.cornerRadius = 5.0f;
        [self addSubview:appImageView];
        
        if ([_viewDM.photoUrl isEqual:[NSNull null]] || [_viewDM.photoUrl isEqual:@""]) {
            appImageView.image = [UIImage imageNamed:@"app_default_icon.png"];
        } else {
            [appImageView setImageWithURL:[NSURL URLWithString:_viewDM.photoUrl] placeholderImage:[UIImage imageNamed:@"app_default_icon.png"]];
        }
        
        appNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, initFrame.size.width, 40)];
        appNameLabel.backgroundColor = [UIColor clearColor];
        appNameLabel.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        appNameLabel.text = _viewDM.personName;
        appNameLabel.font = [UIFont systemFontOfSize:10];
        appNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:appNameLabel];
        
    }
    return self;
    
}


-(void)publicphotoBtnPressed:(id)sender
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(photoclick:)]) {
            [delegate photoclick:self.viewDM];
        }
    }
}


@end
