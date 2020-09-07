//
//  KDGroupStatusViewController.m
//  KdWeiboIpad
//
//  Created by Tan YingQi on 13-4-21.
//
//

#import "KDGroupStatusViewController.h"
#import "KDGroupStatusDataProvider.h"
#import "KDGroupStatus.h"
#import "KWIStatusCell.h"
#import "KWIStatusVCtrl.h"
#import "KWIGroupInfVCtrl.h"
@interface KDGroupStatusViewController () {
    UIView *tableViewHeaderView_;
}

@end

@implementation KDGroupStatusViewController
@synthesize group = group_;

+(KDGroupStatusViewController *)viewControllerByGroup:(KDGroup *)group {
    KDGroupStatusViewController *vc = [[KDGroupStatusViewController alloc] init];
    vc.group = group;
    return [vc autorelease];
}

- (void)initWithDataProvider {
    KDGroupStatusDataProvider *dataProvider =  [[[KDGroupStatusDataProvider alloc] initWithViewController:self] autorelease];
    dataProvider.group = group_;
    self.dataProvider = dataProvider;
}

- (UIView *)tableHeaderView {
    if (tableViewHeaderView_ == nil) {
        tableViewHeaderView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
        tableViewHeaderView_.autoresizingMask = UIViewAutoresizingNone;
        UIGestureRecognizer *grzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableHeaderViewTapped:)];
        [tableViewHeaderView_ addGestureRecognizer:grzr];
        [grzr release];
        
        UILabel *nameV = [[[UILabel alloc] initWithFrame:CGRectMake(20, 20, 1000, 200)] autorelease];
        nameV.font = [UIFont systemFontOfSize:24];
        nameV.textColor = [UIColor colorWithHexString:@"333"];
        nameV.backgroundColor = [UIColor clearColor];
        nameV.text = self.group.name;
        [nameV sizeToFit];
        [tableViewHeaderView_ addSubview:nameV];
        
        UIButton *infBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [infBtn setImage:[UIImage imageNamed:@"groupInfBtn.png"] forState:UIControlStateNormal];
        infBtn.frame = CGRectMake(418, 10, 44, 44);
        infBtn.userInteractionEnabled = NO;
        [infBtn addTarget:self action:@selector(infoBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [tableViewHeaderView_ addSubview:infBtn];
        
        UIView *borderBtn = [[[UIView alloc] initWithFrame:CGRectMake(0, 67, self.view.frame.size.width, 1)] autorelease];
        borderBtn.autoresizingMask = UIViewAutoresizingNone;
        borderBtn.backgroundColor = [UIColor colorWithHexString:@"d5d1bc"];
        [tableViewHeaderView_ addSubview:borderBtn];

    }
    return tableViewHeaderView_;
    
}

- (void)infoBtnTapped:(id)sende {
    [self tableHeaderViewTapped:nil];
}
- (void)tableHeaderViewTapped:(UITapGestureRecognizer *)grzr {
    KWIGroupInfVCtrl *vctrl = [KWIGroupInfVCtrl vctrlWithGroup:self.group];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIGroupInfVCtrl.show" object:self userInfo:inf];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.tableHeaderView = [self tableHeaderView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    KD_RELEASE_SAFELY(tableViewHeaderView_);
    KD_RELEASE_SAFELY(group_);
    [super dealloc];
}
@end
