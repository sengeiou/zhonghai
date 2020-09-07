//
//  KDDocumentsAllListViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-26.
//
//

#import "KDDocumentsAllListViewController.h"
#import "KDDocumentCell.h"
#import "UIDevice+KWIExt.h"
#import "KDDocumentPreviewViewController.h"
#import "KWIRootVCtrl.h"
@interface KDDocumentsAllListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    BOOL _isShadowDisabled;
}
@property (retain, nonatomic) IBOutlet UITableView *mainTableView;
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)closeBtnTapped:(id)sender;
@end

@implementation KDDocumentsAllListViewController
@synthesize downloadArray = downloadArray_;
@synthesize data = data_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.data isKindOfClass:[KDStatus class]]) {
        self.titleLabel.text = @"微博文档";
    }
    else if ([self.data isKindOfClass:[KDDMMessage class]]) {
        self.titleLabel.text = @"短邮文档";
    }
}

- (void)dealloc {
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self];
    KD_RELEASE_SAFELY(downloadArray_);
    KD_RELEASE_SAFELY(data_);
    [_mainTableView release];
    [_closeBtn release];
    [_backgroundView release];
    [_titleLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMainTableView:nil];
    [self setCloseBtn:nil];
    [self setBackgroundView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (IBAction)closeBtnTapped:(id)sender {
    KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    [rootVC onRemoveViewController:self animaion:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [downloadArray_ count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        if (_isShadowDisabled) {
            self.backgroundView.image = [UIImage imageNamed:@"profileBgPNoShadow.png"];
        } else {
            self.backgroundView.image = [UIImage imageNamed:@"profileBgP.png"];
        }
    } else {
        self.backgroundView.image = [UIImage imageNamed:@"profileBg.png"];
    }
    
    CGRect frame = self.backgroundView.frame;
    frame.size = self.backgroundView.image.size;
    self.backgroundView.frame = frame;
}

- (void)_onOrientationWillChange:(NSNotification *)note {
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)_onOrientationChanged:(NSNotification *)note{
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOn {
    _isShadowDisabled = NO;
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff {
    _isShadowDisabled = YES;
    [self _configBgVForCurrentOrientation];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[[KDDocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundView = nil;
        
    }
    
    KDDownload *download = self.downloadArray[indexPath.row];
    ((KDDocumentCell *)cell).download = download;
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *vctrl = nil;
    KDDownload *download = self.downloadArray[indexPath.row];
    vctrl = [[[KDDocumentPreviewViewController  alloc] init] autorelease];
    ((KDDocumentPreviewViewController *)vctrl).download = download;
        

    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", self, @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentList.show" object:self userInfo:inf];
}
@end
