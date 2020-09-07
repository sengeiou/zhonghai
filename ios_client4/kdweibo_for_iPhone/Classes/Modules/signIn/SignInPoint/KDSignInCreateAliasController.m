//
//  KDSignInCreateAliasController.m
//  kdweibo
//
//  Created by lichao_liu on 15/4/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSignInCreateAliasController.h"

@interface KDSignInCreateAliasController () <UITextFieldDelegate>
{
    UITextField *aliasTextField_;
}
@end

@implementation KDSignInCreateAliasController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xEFEFF4);
     self.navigationItem.title = ASLocalizedString(@"备注名称");
    
    aliasTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(0, 10.0f, CGRectGetWidth(self.view.bounds), 48.0f)];
    aliasTextField_.delegate = self;
    aliasTextField_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    aliasTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    aliasTextField_.backgroundColor = [UIColor colorWithRGB:0xffffff];//[UIColor KDWhiteColor];
    aliasTextField_.font = [UIFont systemFontOfSize:16.0f];
    aliasTextField_.textColor = UIColorFromRGB(0xAEAEAE);
    aliasTextField_.placeholder = ASLocalizedString(@"KDSignInCreateAliasController_AlertView_Title");
    
    if(self.alias && self.alias.length>0)
    {
        aliasTextField_.text = self.alias;
    }
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 48.0f)];
    aliasTextField_.leftView = left;
    aliasTextField_.leftViewMode = UITextFieldViewModeAlways;
    
    aliasTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    aliasTextField_.returnKeyType = UIReturnKeyDone;
    [aliasTextField_ becomeFirstResponder];
    
    [self.view addSubview:aliasTextField_];
    
    [self addRightBarItem];
}

- (void)addRightBarItem
{
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    updateBtn.frame = CGRectMake(0.0, 0.0, 49.0, 30.0);
    
    updateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [updateBtn setTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")forState:UIControlStateNormal];
    [updateBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [updateBtn addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:updateBtn];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:nil action:nil];
    negativeSpacer1.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer1,rightItem, nil];
}

#pragma mark - UITouch methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [aliasTextField_ resignFirstResponder];
}

#pragma mark - Private Methods
- (void)create:(id)sender {
    if ([aliasTextField_ isFirstResponder] && [aliasTextField_ canResignFirstResponder]) {
        [aliasTextField_ resignFirstResponder];
    }
    
    NSString *aliasStr = [aliasTextField_.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (aliasStr.length > 0 && ![aliasStr isEqualToString:@""]) {
        [self addAliaseFinished:aliasStr];
//    }else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDSignInCreateAliasController_AlertView_Title")message:nil delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
//        [alert show];
//    }
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *aliasStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (aliasStr.length > 0 && ![aliasStr isEqualToString:@""]) {
        [self addAliaseFinished:aliasStr];
//    }else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"KDSignInCreateAliasController_AlertView_Title")message:nil delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
//        [alert show];
//    }
    return YES;
}

- (void)addAliaseFinished:(NSString *)alias
{
    if(self.createAliasBlock)
    {
        self.createAliasBlock(alias);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end

