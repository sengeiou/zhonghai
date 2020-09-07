//
//  KWISearchVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/20/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISearchVCtrl.h"

#import "EGORefreshTableHeaderView.h"


#import "KWIStatusCell.h"
#import "KWIStatusVCtrl.h"
#import "KWIPeopleCell.h"
#import "KWIPeopleVCtrl.h"
#import "KDCommonHeader.h"
#import "KWPaging.h"

@interface KWISearchVCtrl () <UITextFieldDelegate>

@property (retain, nonatomic) NSCache *cellCache;
@property (retain, nonatomic) NSString *keyword;
@property (retain, nonatomic) UIActivityIndicatorView *ingV;

@end

@implementation KWISearchVCtrl
{
    UIButton *_submitBtn;
    UIButton *_statusModBtn;
    UIButton *_peopleModBtn;
    UITextField *_searchTextV;
    NSString *_keyword;
    SEL _searchAction;
    SEL _loadmoreAction;
    SEL _cellLoader;
}

@synthesize cellCache = _cellCache, keyword = _keyword, ingV = _ingV;

+ (KWISearchVCtrl *)vctrl
{
    return [[[self alloc] init] autorelease];
}

-(void)dealloc
{    
    [_submitBtn release];
    [_statusModBtn release];
    [_peopleModBtn release];
    [_searchTextV release];    
    [_keyword release];
    [_ingV release];
    KD_RELEASE_SAFELY(_cellCache);
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    for (UIView *v in self.tableView.subviews) {
        if ([v isKindOfClass:EGORefreshTableHeaderView.class]) {
            [v removeFromSuperview];
        }
    }
    
    [self _configHeader];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)_configHeader
{
    // nib or programaticly? this is a question
    UIView *hdv = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 130)] autorelease];
    hdv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImage *bg = [UIImage imageNamed:@"mpHdBg.png"];
    UIImageView *bgv = [[[UIImageView alloc] initWithFrame:CGRectMake(-14, 0, bg.size.width, bg.size.height)] autorelease];
    bgv.image = bg;
    [hdv addSubview:bgv];
    
    UIImage *iptBg = [UIImage imageNamed:@"searchIptBg.png"];
    UIImageView *iptBgV = [[[UIImageView alloc] initWithFrame:CGRectMake(24, 17, iptBg.size.width, iptBg.size.height)] autorelease];
    iptBgV.image = iptBg;
    [hdv addSubview:iptBgV];
    
    _searchTextV = [[UITextField alloc] initWithFrame:CGRectMake(34, 28, iptBg.size.width - 60, iptBg.size.height - 18)];
    _searchTextV.returnKeyType = UIReturnKeySearch;
    _searchTextV.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchTextV.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchTextV.delegate = self;
    //_searchTextV.backgroundColor = [UIColor lightGrayColor];
    //_searchTextV.text = @"some mother fucker text";
    _searchTextV.placeholder = @"请输入搜索关键词";
    [hdv addSubview:_searchTextV];
    
    _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(402, 16, 44, 44)];
    [_submitBtn setImage:[UIImage imageNamed:@"searchBtn.png"] forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(_onSubmitBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [hdv addSubview:_submitBtn];
    
    UIImage *tabL = [UIImage imageNamed:@"searchTabL.png"];
    _statusModBtn = [[UIButton alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(iptBgV.frame)+15, tabL.size.width, tabL.size.height)];    
    [_statusModBtn setTitle:@"搜微博" forState:UIControlStateNormal];
    [_statusModBtn setBackgroundImage:tabL forState:UIControlStateNormal];
    [_statusModBtn setBackgroundImage:[UIImage imageNamed:@"searchTabLOn.png"] forState:UIControlStateSelected]; 
    [_statusModBtn addTarget:self action:@selector(_onStatusModBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *tabR = [UIImage imageNamed:@"searchTabR.png"];
    _peopleModBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_statusModBtn.frame), CGRectGetMinY(_statusModBtn.frame), tabR.size.width, tabR.size.height)];    
    [_peopleModBtn setTitle:@"找人" forState:UIControlStateNormal];
    [_peopleModBtn setBackgroundImage:tabR forState:UIControlStateNormal];
    [_peopleModBtn setBackgroundImage:[UIImage imageNamed:@"searchTabROn.png"] forState:UIControlStateSelected];
    [_peopleModBtn addTarget:self action:@selector(_onPeopleModBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *btn in [NSArray arrayWithObjects:_statusModBtn, _peopleModBtn, nil]) {
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    [hdv addSubview:_statusModBtn];
    [hdv addSubview:_peopleModBtn];
    
    UIView *bottomBorderH = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(hdv.frame) - 2, CGRectGetWidth(hdv.frame), 1)] autorelease];
    bottomBorderH.backgroundColor = [UIColor colorWithHexString:@"f3f1e9"];
    bottomBorderH.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [hdv addSubview:bottomBorderH];
    
    UIView *bottomBorderL = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(hdv.frame) - 1, CGRectGetWidth(hdv.frame), 1)] autorelease];
    bottomBorderL.backgroundColor = [UIColor colorWithHexString:@"d2cdb4"];
    bottomBorderL.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [hdv addSubview:bottomBorderL];
    
    CGRect tbFrm = self.tableView.frame;
    tbFrm.origin.y = CGRectGetHeight(hdv.frame);
    tbFrm.size.height -= tbFrm.origin.y;
    self.tableView.frame = tbFrm;
    
    [self.view addSubview:hdv];
    
    [self _onStatusModBtnTapped];
}

- (void)_onSubmitBtnTapped
{
    self.keyword = [_searchTextV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (0 == self.keyword.length) {
        [_searchTextV becomeFirstResponder];
    } else {
        [_searchTextV resignFirstResponder];
        [self _resetTableV];
        [self performSelector:_searchAction];
    }
}

- (void)_onStatusModBtnTapped
{
    _statusModBtn.selected = YES;
    _peopleModBtn.selected = NO;
    _searchAction = @selector(_searchStatus);
    _loadmoreAction = @selector(_loadmoreStatus);
    _cellLoader = @selector(_loadCellForStatus:);
    [self _resetTableV];
    
    if (_searchTextV.text.length) {
        [self _onSubmitBtnTapped];
    }
}

- (void)_onPeopleModBtnTapped
{
    _peopleModBtn.selected = YES;
    _statusModBtn.selected = NO;
    _searchAction = @selector(_searchPeople);
    _loadmoreAction = @selector(_loadmorePeople);
    _cellLoader = @selector(_loadCellForUser:);
    [self _resetTableV];
    
    if (_searchTextV.text.length) {
        [self _onSubmitBtnTapped];
    }
}

- (void)_loadmore
{
    [self performSelector:_loadmoreAction];
}


- (void)searchWithActionPath:(NSString *)actionPath {
    if(actionPath.length == 0)
        return;
    [self.ingV startAnimating];
    KWPaging *p = [KWPaging pagingWithPage:1 count:20];
    KDQuery *query = [[p toQuery] setParameter:@"q" stringValue:[self.keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    __block KWISearchVCtrl *svc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        if([response isValidResponse]) {
            if (results != nil) {
                svc.data = results;
                [svc.tableView reloadData];
                
                if (20 <= [svc.data count]) {
                    [svc _enableLoadmore];
                }
            }
        } else {
            if (![response isCancelled]) {
                //                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                //                                              inView:svc.view.window];
            }
        }
        
        // release current view controller
        [svc.ingV stopAnimating];
        [svc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];


}

- (void)loadMoreWithActionPath:(NSString *)actionPath {
    if(actionPath.length == 0)
        return;
    KWPaging *p = [KWPaging pagingWithPage:ceil(self.data.count / 20.0)+1 count:20];
    KDQuery *query = [[p toQuery] setParameter:@"q" stringValue:[self.keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    __block KWISearchVCtrl *svc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        if([response isValidResponse]) {
            if (results != nil) {
                svc.data = [svc.data arrayByAddingObjectsFromArray:(NSArray *)results];
                [svc.tableView reloadData];
                
                if (20 <= [(NSArray *)results count]) {
                    [svc _enableLoadmore];
                }
            }else {
                [svc _setNomore];
            }
        } else {
            if (![response isCancelled]) {
                //                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                //                                              inView:svc.view.window];
            }
        }
        
        [svc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];

    
}
- (void)_searchStatus{
   
    [self searchWithActionPath:@"/statuses/:search"];
}

- (void)_loadmoreStatus{
    [self loadMoreWithActionPath:@"/statuses/:search"];
}

- (void)_searchPeople {
    [self searchWithActionPath:@"/users/:search"];
}

- (void)_loadmorePeople {
    [self loadMoreWithActionPath:@"/users/:search"];
}

#pragma mark - table view stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self performSelector:_cellLoader withObject:[self.data objectAtIndex:indexPath.row]]; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return CGRectGetHeight(cell.frame);
}

- (KWIStatusCell *)_loadCellForStatus:(KDStatus *)status
{
    KWIStatusCell *cell = [self.cellCache objectForKey:status.statusId];
    if (nil == cell) {
        cell = [KWIStatusCell cell];
        cell.data = status;
        [self.cellCache setObject:cell forKey:status.id_];
    }
    
    return cell;
}

- (KWIPeopleCell *)_loadCellForUser:(KDUser *)user
{
    KWIPeopleCell *cell = [self.cellCache objectForKey:user.userId];
    if (nil == cell) {
        cell = [KWIPeopleCell cell];
        cell.data = user;
        [self.cellCache setObject:cell forKey:user.userId];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:KWIStatusCell.class]) {
        KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:[self.data objectAtIndex:indexPath.row]];
        NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [KWIStatusCell class], @"from", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];  
    } else {
        KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:[self.data objectAtIndex:indexPath.row]];
        NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [KWIStatusCell class], @"from", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];  
    }   
}

- (void)_resetTableV
{
    [self _disableLoadmore];
    self.data = [NSArray array];
    [self.tableView reloadData];
}

#pragma mark -
- (NSCache *)cellCache
{
    if (!_cellCache) {
        _cellCache = [[NSCache alloc] init];
        _cellCache.name = self.class.description;
        _cellCache.countLimit = 20;
    }
    
    return _cellCache;
}

#pragma mark
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self _onSubmitBtnTapped];
    return YES;
}

#pragma mark
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//jus an empty implemention to override super on with egoRefreshScrollViewDidScroll
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	//jus an empty implemention to override super on with egoRefreshScrollViewDidEndDragging
}

#pragma mark
- (UIActivityIndicatorView *)ingV
{
    if (!_ingV) {
        _ingV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _ingV.hidesWhenStopped = YES;
        CGRect ingFrm = _ingV.frame;
        ingFrm.origin.x = CGRectGetMidX(self.tableView.frame) - CGRectGetMidX(ingFrm);
        ingFrm.origin.y = CGRectGetMidY(self.tableView.frame) - CGRectGetMidY(ingFrm);
        _ingV.frame = ingFrm;
        
        [self.view addSubview:_ingV];
    }
    return _ingV;
}

@end
