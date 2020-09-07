//
//  KDSingleInputViewController.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDSingleInputViewController.h"
#import "KDUserProfileEditViewController.h"

#import "NSDictionary+Additions.h"

@interface KDSingleInputViewController ()

@property(nonatomic, retain) UITextField *inputTextField;
@property(nonatomic, strong) KDInputView *inputViewMain;
@property(nonatomic, strong) UIButton *saveButton;

@end


@implementation KDSingleInputViewController

@synthesize baseViewController=baseViewController_;

@synthesize content=content_;
@synthesize contentType=contentType_;

@synthesize inputTextField=inputTextField_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        baseViewController_ = nil;
        
        content_ = nil;
        contentType_ = KDSingleInputContentTypeAny;
        
        inputTextField_ = nil;
    }
    
    return self;
}

- (id) initWithBaseViewController:(UIViewController *)baseViewController content:(NSString *)content type:(KDSingleInputContentType)type {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        baseViewController_ = baseViewController;
        
        content_ = [content copy];
        contentType_ = type;
    }
    
    return self;
}

- (UIBarButtonItem *) barButtonItemWithTitle:(NSString *)title selector:(SEL)selector enabled:(BOOL)enabled isLeft:(BOOL)isLeft{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = CGRectMake(0.0, 0.0, 61.0, 32.0);
    
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    btn.enabled = enabled;
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];// autorelease];
}


- (void) loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = aView;
    self.view.backgroundColor = RGBCOLOR(236, 236, 236);
//    [aView release];
    
    if (self.contentType == KDSingleInputContentTypeDMThreadSubject) {
        self.title = ASLocalizedString(@"KDSingleInputViewController_KDSingleInputContentTypeDMThreadSubject");
    }else if (self.contentType == KDSingleInputContentTypeUsername){
        self.title = ASLocalizedString(@"KDSingleInputViewController_KDSingleInputContentTypeUsername");
    }
    
    [self.view addSubview:self.inputViewMain];
    [self.inputViewMain makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(32);
         make.right.equalTo(self.view.right).with.offset(-32);
         make.top.equalTo(self.view.top).with.offset(100);
         make.height.mas_equalTo(45);
         make.centerX.equalTo(self.view.centerX);
     }];
    self.saveButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")];
    //        _saveButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"完成")];
    self.saveButton.titleLabel.font = FS2;
    [self.saveButton addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    [self.saveButton makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.view.left).with.offset(12);
         make.right.equalTo(self.view.right).with.offset(-12);
         make.top.equalTo(_inputViewMain.bottom).with.offset(20);
         make.height.mas_equalTo(44);
         make.centerX.equalTo(self.view.centerX);
     }];
    
    [self.saveButton setCircle];
    // text field
//    CGRect frame = CGRectMake((self.view.bounds.size.width - 280.0) * 0.5, 30.0, 280.0, 35.0);
//    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
//    self.inputTextField = textField;
//    [textField release];
//    
//    inputTextField_.delegate = self;
//    
//    inputTextField_.borderStyle = UITextBorderStyleRoundedRect;
//    inputTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    inputTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
//    
//    inputTextField_.font = [UIFont systemFontOfSize:14.0];
//    inputTextField_.adjustsFontSizeToFitWidth = YES;
//    inputTextField_.contentScaleFactor = 12.0;
//    
//    inputTextField_.returnKeyType = UIReturnKeyDone;
//    inputTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    inputTextField_.autocorrectionType = UITextAutocorrectionTypeNo;
//    
//    inputTextField_.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
//    
//    inputTextField_.text = content_;
//    
//    [self.view addSubview:inputTextField_];
}

- (KDInputView *)inputViewMain
{
    if (!_inputViewMain)
    {
        _inputViewMain = [[KDInputView alloc] initWithElement:KDInputViewElementNone];
        _inputViewMain.textFieldMain.delegate = self;
        _inputViewMain.textFieldMain.placeholder = ASLocalizedString(@"KDSingleInputViewController_textFieldMain_placeholder");
        self.inputTextField = _inputViewMain.textFieldMain;
        _inputViewMain.textFieldMain.delegate = self;
        _inputViewMain.textFieldMain.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputViewMain.textFieldMain.text = content_;
    }
    return _inputViewMain;
}


//-(UIButton *)saveButton
//{
//    if(!_saveButton){
//        _saveButton = [UIButton blueBtnWithTitle:ASLocalizedString(@"完成")];
//        _saveButton.titleLabel.font = FS2;
//        [_saveButton addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    return _saveButton;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton backBtnInWhiteNavWithTitle:ASLocalizedString(@"Global_GoBack")];
    [btn addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:btn]];
//    self.navigationItem.leftBarButtonItems = [KDCommon leftNavigationItemWithTarget:self action:@selector(doCancel:)];
//    self.navigationItem.rightBarButtonItems = [KDCommon rightNavigationItemWithTitle:NSLocalizedString(@"OKAY", nil) target:self action:@selector(doSave)];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self.inputViewMain.textFieldMain canBecomeFirstResponder]){
        [self.inputViewMain.textFieldMain becomeFirstResponder];
    }
}

- (void) dismissInputViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) doCancel:(UIButton *)btn {
    [self dismissInputViewController];
}

- (void) showMessage:(NSString *)message title:(NSString *)title {
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OKAY", @"") otherButtonTitles:nil];
    
    [alterView show];
//    [alterView release];
}

static const NSString * kKDUsernameRegex = @"^[\u4e00-\u9fa5_.a-zA-Z0-9]*$";

- (int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return (int)[da length];
}

- (void) doSave {
    NSString *text = self.inputViewMain.textFieldMain.text;
    //内容未修改时，不提交服务器，直接返回 王松 2013-12-28
    if ([content_ isEqual:text]) {
        [self dismissInputViewController];
        return;
    }
    if (contentType_ == KDSingleInputContentTypeUsername) {
        // check the username has whitespace
        NSRange range = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if (range.location != NSNotFound) {
            // username with whitespace
            [self showMessage:NSLocalizedString(@"USERNAME_CAN_NOT_WITH_WHITESPACE", @"") title:NSLocalizedString(@"INVALID_USERNAME", @"")];
            return;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kKDUsernameRegex];
        int inputLength = [self getToInt:self.inputViewMain.textFieldMain.text];
        if(![predicate evaluateWithObject:self.inputViewMain.textFieldMain.text] || inputLength < 4 || inputLength > 20){
            [self showMessage:NSLocalizedString(@"USERNAME_INPUT_TIPS", @"") title:NSLocalizedString(@"INVALID_USERNAME", @"")];
            return;
        }
        
        if(baseViewController_ != nil) {
            [(KDUserProfileEditViewController *)baseViewController_ updateUsername:text];
        }
        
        if (_block) {
            _block(text);
        }
        
        [self dismissInputViewController];
    
    } else if (contentType_ == KDSingleInputContentTypeDMThreadSubject) {
        if (text.length == 0 ) {
            // username with whitespace
            [self showMessage:ASLocalizedString(@"KDSingleInputViewController_alter_msg_invalid")title:ASLocalizedString(@"KDSingleInputViewController_alter_title_invalid")];
            
            return;
        }
        
        if ([baseViewController_ respondsToSelector:@selector(updateDMThreadSubject:completedBlock:)]) {
            [baseViewController_ performSelector:@selector(updateDMThreadSubject:completedBlock:)
                                      withObject:text
                                       withObject:^(BOOL success, BOOL isCancelled) {
                                           if (success) {
                                               [self dismissInputViewController];
                                           
                                           } else {
                                               if (!isCancelled) {
                                                   [self showMessage:ASLocalizedString(@"KDSingleInputViewController_alter_msg_err")title:ASLocalizedString(@"KDSingleInputViewController_alter_title_err")];
                                               }
                                           }
                                       }];
        }
    }
}


//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self doSave];
    
    return NO;
}


//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlterView delegate methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([inputTextField_ canBecomeFirstResponder]){
        [inputTextField_ becomeFirstResponder];
    }
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    //KD_RELEASE_SAFELY(inputTextField_);
}

- (void) dealloc {
    baseViewController_ = nil;
    
//    Block_release(_block);
    
    //KD_RELEASE_SAFELY(content_);
    //KD_RELEASE_SAFELY(inputTextField_);
    //KD_RELEASE_SAFELY(_inputViewMain);
    //KD_RELEASE_SAFELY(_saveButton);
    
    //[super dealloc];
}

@end
