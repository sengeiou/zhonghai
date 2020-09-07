//
//  DMPostController.m
//  TwitterFon
//
//  Created by apple on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"

#import "DMPostController.h"
#import "TwitterFonAppDelegate.h"
#import "KDDefaultViewControllerContext.h"

#import "NSString+Additions.h"

@implementation DMPostController

@synthesize postContainerView=postContainerView_;
@synthesize postBackView;
@synthesize textView=textView_;

@synthesize labelCount;
@synthesize labelRecipient;
@synthesize recipientView;
@synthesize sendButton=sendButton_;

@synthesize recipient;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"发短邮";
        
        _inputHeight = 34.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.929 alpha:1.0];
    
    // left item
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0.0, 0.0, 49.0, 30.0);
    
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"icon_button.png"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"icon_button_down.png"] forState:UIControlStateHighlighted];
    
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [leftItem release];
    
    // send button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton_.frame = CGRectMake(260.0, 8.0, 52.0, 29.0);
    sendButton_.enabled = NO;
    
    sendButton_.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton_ setTitle:@"发送" forState:UIControlStateNormal];
    
    [sendButton_ setBackgroundImage:[UIImage imageNamed:@"dm_post.png"] forState:UIControlStateNormal];
    
    [sendButton_ addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    
    sendButton_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [postContainerView_ addSubview:sendButton_];
    
    
    // Do any additional setup after loading the view from its nib.
    UIImage *image = [UIImage imageNamed:@"dmpost_background.png"];    
    postBackView.image = [image stretchableImageWithLeftCapWidth:31 topCapHeight:21];
    
    // text view
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(21.0, 4.0, 230.0, 34.0)];
    self.textView = textView;
    [textView release];
    
    textView_.delegate = self;
    textView_.scrollEnabled = NO;  
    textView_.clipsToBounds = YES;
    
    textView_.backgroundColor = [UIColor clearColor];
    textView_.textColor = [UIColor blackColor];
    textView_.font = [UIFont systemFontOfSize:14];
    
    textView_.contentInset = UIEdgeInsetsZero;
    textView_.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [postContainerView_ addSubview:textView_];
    
    [textView_ becomeFirstResponder];
    
    recipientView.image = [[UIImage imageNamed:@"收件人.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    
    if(self.recipient != nil){
        labelRecipient.text = recipient.screenName;
    }
    
    labelCount.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) dismiss {
    [[KDDefaultViewControllerContext defaultViewControllerContext] dismissDMPostViewController];
}

- (void) send {
    TwitterFonAppDelegate *app=[TwitterFonAppDelegate getAppDelegate];
    [app sendNewDirectMessage:textView_.text userID:recipient.userId];
    
    [self dismiss];
}

- (void) setChartCount {
    if(textView_.contentSize.height > 34) {
        NSInteger number =[textView_.text wordLength];
        labelCount.textColor = (number > 500) ? [UIColor redColor] : [UIColor blackColor];
        
        labelCount.text = [NSString stringWithFormat:@"%d", 500-number];
        labelCount.hidden = NO;

    } else {
        labelCount.hidden = YES; 
    } 
}

- (IBAction) choiceRecipient:(id)sender {
    DirectoryViewController *dvc = [[DirectoryViewController alloc] init];
    dvc.delegate = self;
    
    UINavigationController *rvc = [[UINavigationController alloc] initWithRootViewController:dvc];
    [dvc release];
    
    [self presentModalViewController:rvc animated:YES];
    [rvc release];
}

/////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UserSelectChange delegate method

- (void) selectedUser:(User *)selectUser {
    self.recipient = selectUser;
    labelRecipient.text = selectUser.screenName;
}

/////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITextView delegate methods

- (void)textViewDidChange:(UITextView *)textView {
    if([textView_ hasText]){
        sendButton_.enabled = (recipient != nil) ? YES : NO;
        
        CGRect frame = textView_.frame;
        _inputHeight = textView_.contentSize.height;
        if(frame.size.height != _inputHeight){
            [UIView beginAnimations:@"textViewDidChange" context:nil]; 
            [UIView setAnimationDelegate:self];         
            postContainerView_.frame = CGRectMake(0,(460-44-_keywordHeight)-(8+_inputHeight),320, 8+_inputHeight);
            textView_.frame = CGRectMake(21,4,230,_inputHeight);         
            [UIView commitAnimations];       
        } 
        
        [self setChartCount];
        
    }else {
        sendButton_.enabled = NO;
    }   
}

//////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIKeyboard notification

- (void) keyboardWillShow:(NSNotification *)notification {
     NSDictionary *userInfo = [notification userInfo]; 
     NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
     
     CGRect keyboardRect = [aValue CGRectValue];
     _keywordHeight=keyboardRect.size.height;
     
     NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];   
     NSTimeInterval animationDuration;   
     [animationDurationValue getValue:&animationDuration]; 
     [UIView beginAnimations:@"keyboardShow" context:nil];
     [UIView setAnimationDuration:animationDuration];
     postContainerView_.frame=CGRectMake(0,(460-44-_keywordHeight)-(8+_inputHeight),320, 8+_inputHeight);
     [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)notification {
     NSDictionary *userInfo = [notification userInfo]; 
     
     NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];   
     NSTimeInterval animationDuration;   
     [animationDurationValue getValue:&animationDuration]; 
     [UIView beginAnimations:@"keyboardHide" context:nil]; 
     [UIView setAnimationDuration:animationDuration];    
     postContainerView_.frame=CGRectMake(0,(460-44)-(8+_inputHeight),320, 8+_inputHeight);
     [UIView commitAnimations];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    KD_RELEASE_SAFELY(postBackView);
    KD_RELEASE_SAFELY(textView_);
    
    KD_RELEASE_SAFELY(labelCount);
    KD_RELEASE_SAFELY(labelRecipient);
    KD_RELEASE_SAFELY(recipientView);
    KD_RELEASE_SAFELY(sendButton_);
    
    KD_RELEASE_SAFELY(postContainerView_);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    KD_RELEASE_SAFELY(recipient);
    
    KD_RELEASE_SAFELY(postBackView);
    KD_RELEASE_SAFELY(textView_);
    
    KD_RELEASE_SAFELY(labelCount);
    KD_RELEASE_SAFELY(labelRecipient);
    KD_RELEASE_SAFELY(recipientView);
    KD_RELEASE_SAFELY(sendButton_);
    
    KD_RELEASE_SAFELY(postContainerView_);
    
    [super dealloc];
}

@end
