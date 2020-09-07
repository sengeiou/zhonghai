//
//  KWIFeedbackVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/26/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIFeedbackVCtrl.h"

#import "Reachability.h"

#import "KTTextView.h"
#import "iToast.h"

#import "UIDevice+KWIExt.h"
#import "KDQuery.h"
#import "KDCommonHeader.h"

@interface KWIFeedbackVCtrl () <UINavigationControllerDelegate>

@property (retain, nonatomic) IBOutlet KTTextView *textV;

@end

@implementation KWIFeedbackVCtrl
@synthesize textV = _textV;

+ (KWIFeedbackVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:@"KWIFeedbackVCtrl" bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configTitle:@"意见反馈"];
    self.navigationItem.rightBarButtonItem = [self makeBarButtonWithLabel:@"提交" 
                                                                    image:[UIImage imageNamed:@"settingsSubmitBtn.png"]
                                                                   target:self
                                                                   action:@selector(_submit)];
    
    self.textV.placeholderText = @"你想说个啥？";
}

- (void)viewDidUnload
{
    [self setTextV:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_textV release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textV becomeFirstResponder];
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.textV resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)_submit
{
    self.textV.editable = NO;
    
    NSString *device = [UIDevice platformString];
    UIDevice *curDev = [UIDevice currentDevice];
    NSString *sys = [NSString stringWithFormat:@"%@ %@", curDev.systemName, curDev.systemVersion];    
    NSString *netEnv = @"";
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];    
    NetworkStatus status = [reachability currentReachabilityStatus];    
    if (status == ReachableViaWiFi)
    {
        netEnv = @"wifi";
    }
    else if (status == ReachableViaWWAN) 
    {
        netEnv = @"wwan";
    }
    [reachability stopNotifier];
    
    NSString *ver = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *text = [NSString stringWithFormat:@"#%@, %@, %@, ver%@# %@", device, sys, netEnv, ver, self.textV.text];
    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api post:@"users/feedback.json"
//       params:[NSDictionary dictionaryWithObject:text forKey:@"content"]
//    onSuccess:^(NSDictionary *result) {
//        [self _dismiss];
//    } 
//      onError:^(NSError *error) {
//          [self _dismiss];
//      }];
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"title" stringValue:@"iPad客户端意见反馈"]
     setParameter:@"content" stringValue:text];
    
    __block KWIFeedbackVCtrl *fbvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if ([(NSNumber *)results boolValue]) {
                [fbvc _dismiss]; 
            }
        } else {
            if (![response isCancelled]) {
//                [[response.responseDiagnosis networkErrorMessage] inView:ivc.view.window];
                [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            }
        }
       
        // release current view controller
        [fbvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:feedback" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

- (void)_dismiss
{
    [[iToast makeText:@"谢谢你的反馈 ^_^"] show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated
{
    [self.textV resignFirstResponder];
    navigationController.delegate = nil;
}

@end
