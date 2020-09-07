//
//  KDCheckBoxAlertView.m
//  kdweibo
//
//  Created by 王 松 on 13-9-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDCheckBoxAlertView.h"

@interface KDCheckBoxAlertView ()

@property (nonatomic, retain) UIView *checkView;

@property (nonatomic, retain) UIButton *checkButton;

@end

@implementation KDCheckBoxAlertView

-(id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    return  [self initWithTitle:title message:message chkBoxMsg:nil delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message chkBoxMsg:(NSString *)chkMsg delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    //super init
    if(!(!cancelButtonTitle && !otherButtonTitles))//有button
        message = message ? [message stringByAppendingString:@"\n\n"] : @"\n";
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    
    va_list args_list;
    va_start(args_list, otherButtonTitles);
    
    NSString* anArg;
    while((anArg = va_arg(args_list, NSString*)))
    {
        [self addButtonWithTitle:anArg];
    }
    
    va_end(args_list);

    
    _checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    
    _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [_checkButton setImage:[UIImage imageNamed:@"icon_signin_unselected.png"] forState:UIControlStateNormal];
    [_checkButton setImage:[UIImage imageNamed:@"icon_signin_selected.png"] forState:UIControlStateSelected];
    _checkButton.frame = CGRectMake(0.0f, (_checkView.frame.size.height - 30.f) / 2., 150.f, 30.f);
    [_checkButton addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
    [_checkButton setTitle:chkMsg forState:UIControlStateNormal];
    [_checkButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self addSubview:_checkView];
    [_checkView addSubview:_checkButton];

    return self;
}

- (void)toggleButton:(UIButton *)btn
{
    btn.selected = !btn.selected;
    _boxChecked = btn.selected;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offset = self.bounds.size.height;
    
    if (self.numberOfButtons) {//有button
        
        for(UIView* subview in self.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UIAlertButton")]) {
                offset = MIN(offset, subview.frame.origin.y);
            }
        }
        
        offset -= 20;
    }else{//没有button
        offset -= 50;
    }
    
    self.checkView.center = CGPointMake(80, offset);
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_checkView);
    //KD_RELEASE_SAFELY(_checkButton);
    //KD_RELEASE_SAFELY(_errorMsg);
    //[super dealloc];
}

@end
