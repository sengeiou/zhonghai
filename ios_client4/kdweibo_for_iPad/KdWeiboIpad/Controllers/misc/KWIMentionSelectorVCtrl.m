//
//  KWIMentionSelectorVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/23/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMentionSelectorVCtrl.h"

#import "iToast.h"

#import "KDManagerContext.h"
#import "KWPaging.h"
@interface KWIMentionSelectorVCtrl () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (assign, nonatomic) NSArray *data;
@property (retain, nonatomic) NSArray *allPeople;
@property (retain, nonatomic) NSMutableArray *filteredPeople;
@property (retain, nonatomic, readonly) UIView *remoteSearchBtn;
@property (assign, nonatomic, readonly) NSUInteger PAGE_SIZE_;
@property (assign, nonatomic) BOOL ing;

@end

@implementation KWIMentionSelectorVCtrl
{
    UISearchBar *_searchBar;
    UIActivityIndicatorView *_ingV;
    
    BOOL _isSearchMod;
    BOOL _isRemoteMod;
    BOOL _isNomore;
    UIView *_tbFtVBak;
}

@synthesize tableView = _tableView;
@synthesize data = _data;
@synthesize allPeople = _allPeople;
@synthesize filteredPeople = _filteredPeople;
@synthesize remoteSearchBtn = _remoteSearchBtn;
@synthesize ing = _ing;

+ (KWIMentionSelectorVCtrl *)vctrl
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.data = self.allPeople;
        
        CGRect barFrm = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
        _searchBar = [[[UISearchBar alloc] initWithFrame:barFrm] autorelease];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
        
        CGRect tbFrm = self.view.bounds;
        tbFrm.origin.y = CGRectGetHeight(_searchBar.frame);
        tbFrm.size.height -= CGRectGetHeight(_searchBar.frame);
        self.tableView = [[[UITableView alloc] initWithFrame:tbFrm style:UITableViewStylePlain] autorelease];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self _fetchData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    // a chance to retry if failed before
    if (0 == self.allPeople.count) {
        [self _fetchData];
    }
}

- (void)dealloc
{
    [_allPeople release];
    [_filteredPeople release];
    [_ingV release];
    [_remoteSearchBtn release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - tableview stuff
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KWISimpleFollowingsVCtrlCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    KDUser *user = [self.data objectAtIndex:indexPath.row];
    cell.textLabel.text = user.screenName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWISimpleFollowingsSelected" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:[self.data objectAtIndex:indexPath.row] 
                                                                                           forKey:@"user"]];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    //[self _turnOffSearchMod];    
}

#pragma mark - searchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length) {
        if (!_isSearchMod) {
            [self _turnOnSearchMod];
        }
        
        [self.filteredPeople removeAllObjects];
        _isNomore = NO;
        
        if (_isRemoteMod) {
            [self _fetchRemotePeople];
        } else {
            for (KDUser *mathced in [self.allPeople filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KDUser *toEval, NSDictionary *bindings) {
                NSRange found = [toEval.screenName rangeOfString:searchText options:NSCaseInsensitiveSearch];
                return NSNotFound != found.location;
            }]]) {
                [self.filteredPeople addObject:mathced];
            };
            
            [self.tableView reloadData];
        }
    } else {
        [self _turnOffSearchMod]; 
    } 
}

#pragma mark -
- (void)_fetchData
{
    if (self.ing) {
        return;
    }
    
    self.ing = YES;
//    KWEngine *api = [KWEngine sharedEngine];
//    [api get:@"statuses/friends.json" 
//      params:[NSDictionary dictionaryWithObject:@"100" forKey:@"count"] 
//   onSuccess:^(NSArray *results) {
//       //NSArray *results = [result objectForKey:@"users"];       
//       if (results && results.count) {            
//           self.allPeople = [KWUser usersFromDict:results];
//           self.data = self.allPeople;
//           [self.tableView reloadData];
//       } else {
//           //[self.tableView removeFromSuperview];
//       }
//       
//       self.ing = NO;
//   } 
//     onError:^(NSError *error) {
//         self.ing = NO;
//     }];
    /*[api get:@"users/members.json"
      params:[NSDictionary dictionaryWithObject:@"9999" forKey:@"count"] 
   onSuccess:^(NSDictionary *result) {
       NSArray *results = [result objectForKey:@"users"];
       
       if (results && results.count) {            
           self.allPeople = [KWUser usersFromDict:results];
           self.data = self.allPeople;
           [self.tableView reloadData];
       } else {
           //[self.tableView removeFromSuperview];
       }
       
       [self.ingV stopAnimating];
   } 
     onError:^(NSError *error) {
         [self.ingV startAnimating];
     }];*/
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    KDUser *currentUser = userManager.currentUser;
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"user_id" stringValue:currentUser.userId]
     setParameter:@"count" stringValue:@"100"];
    
    __block KWIMentionSelectorVCtrl *vc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                NSArray *users = [info objectNotNSNullForKey:@"users"];
                vc.allPeople = users;
                vc.data = self.allPeople;
                [vc.tableView reloadData];
            }
            
        }
        vc.ing = NO;
        [vc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:friends" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

#pragma mark -
- (UIActivityIndicatorView *)ingV
{
    if (!_ingV) {
        _ingV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect frame = _ingV.frame;
        _ingV.hidesWhenStopped = YES;
        //_ingV.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidX(_ingV.bounds)+20);
        frame.size.height += 20;
        _ingV.frame = frame;
        
        //frame.origin.x = CGRectGetMidX(self.tableView.frame) - CGRectGetMidX(_ingV.bounds);
        //frame.origin.y = CGRectGetMidY(self.tableView.frame) - CGRectGetMidY(_ingV.bounds);
        //_ingV.frame = frame;
        _ingV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        //[self.view addSubview:_ingV];
    }
    
    return _ingV;
}

- (UIView *)remoteSearchBtn
{
    if (!_remoteSearchBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 200, 50);
        [btn setTitleColor:[UIColor colorWithHexString:@"08c"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"005580"] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"通过网络搜索" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(_onRemoteSearchBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        _remoteSearchBtn = [btn retain];
    }
    
    return _remoteSearchBtn;
}

- (void)_onRemoteSearchBtnTapped
{
    [self.filteredPeople removeAllObjects];
    //[self.tableView reloadData];
    
    _isRemoteMod = YES;
    self.tableView.tableFooterView = nil;
    
    [self _fetchRemotePeople];
}

- (void)_fetchRemotePeople
{
    if (self.ing || _isNomore) {
        return;
    }
    self.ing = YES;    
    
    NSUInteger pageNum = ceil((self.filteredPeople.count + 0.0) / self.PAGE_SIZE_)+1;
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[KWPaging pagingWithPage:pageNum count:self.PAGE_SIZE_] toDict]];
//    [params setObject:[_searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"];
//    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api get:@"users/search.json" 
//      params:params 
//   onSuccess:^(NSArray *results) {
//       //NSArray *results = [result objectForKey:@"users"];       
//       if (results) {            
//           [self.filteredPeople addObjectsFromArray:[KWUser usersFromDict:results]];
//           //self.data = self.filteredPeople;
//           [self.tableView reloadData];
//       } else {
//           //[self.tableView removeFromSuperview];
//       }
//       
//       self.ing = NO;
//       
//       if (results.count < self.PAGE_SIZE_) {
//           _isNomore = YES;
//       }
//   } 
//     onError:^(NSError *error) {
//         self.ing = NO;
//     }];
    KDQuery *query = [[KWPaging pagingWithPage:pageNum count:self.PAGE_SIZE_] toQuery];
    [query setParameter:@"q" stringValue:[_searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    __block KWIMentionSelectorVCtrl *vc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            NSArray *users = results;
            if (users != nil) {
                   [vc.filteredPeople addObjectsFromArray:users];
                           //self.data = self.filteredPeople;
                    [vc.tableView reloadData];
            } 
                
            vc.ing = NO;
                       
            if (users.count < vc.PAGE_SIZE_) {
                vc->_isNomore = YES;
        }

            
        }
        else {
            if(![response isCancelled]) {
                vc.ing = NO;
            }
        }
        [vc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:search" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (NSUInteger)PAGE_SIZE_
{
    return 20;
}

- (void)_turnOnSearchMod
{
    _isSearchMod = YES;
    self.data = self.filteredPeople;
    //[self.tableView reloadData];
    self.tableView.tableFooterView = self.remoteSearchBtn;
}

- (void)_turnOffSearchMod
{
    _isSearchMod = NO;
    _isRemoteMod = NO;
    _isNomore = NO;
    self.data = self.allPeople;
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
}

- (NSArray *)allPeople
{
    if (!_allPeople) {
        _allPeople = [[NSArray array] retain];
    }
    return _allPeople;
}

- (NSMutableArray *)filteredPeople
{
    if (!_filteredPeople) {
        _filteredPeople = [[NSMutableArray arrayWithCapacity:20] retain];
    }
    return _filteredPeople;
}

- (void)setIng:(BOOL)ing
{
    _ing = ing;
    if (ing) {
        if (self.tableView.tableFooterView) {
            _tbFtVBak = self.tableView.tableFooterView;
        }
        
        self.tableView.tableFooterView = self.ingV;
        [self.ingV startAnimating];
    } else {
        if (self.tableView.tableFooterView == self.ingV) {
            [self.ingV stopAnimating];
        }
        
        if (_tbFtVBak) {
            self.tableView.tableFooterView = _tbFtVBak;
            _tbFtVBak = nil;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // duplicate self.ing && _isNomore here for performance consideration
    if (_isRemoteMod && !self.ing && !_isNomore) {
        if (300 > (scrollView.contentSize.height - scrollView.contentOffset.y)) {
            [self _fetchRemotePeople];
        }
    }
}

@end
