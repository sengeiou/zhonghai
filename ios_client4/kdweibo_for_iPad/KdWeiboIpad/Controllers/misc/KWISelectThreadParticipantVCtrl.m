//
//  KWISelectThreadParticipantVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISelectThreadParticipantVCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "POAPinyin.h"


#import "KWINewThreadParticipantCell.h"

#import "KDServiceActionInvoker.h"
#import "KDCommonHeader.h"
#import "KWPaging.h"

@interface KWISelectThreadParticipantVCtrl () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (retain, nonatomic) NSArray *allPeople;
@property (retain, nonatomic) NSMutableArray *filteredPeople;
@property (retain, nonatomic) NSMutableDictionary *pyIndexedPeople;
@property (retain, nonatomic) NSArray *sortedIndex;
@property (retain, nonatomic, readonly) UIView *remoteSearchBtn;
@property (assign, nonatomic, readonly) NSUInteger PAGE_SIZE_;
@property (assign, nonatomic) BOOL ing;
@property (nonatomic, retain) NSMutableArray *contacts;

@end

@implementation KWISelectThreadParticipantVCtrl
{
    IBOutlet UIButton *_closeBtn;
    IBOutlet UIButton *_doneBtn;    
    IBOutlet UIView *_dataWrapV;
    IBOutlet UISearchBar *_searchV;
    IBOutlet UITableView *_tableView;
    IBOutlet UIImageView *_bgV;
    IBOutlet UIButton *_maskBtn;
    UIActivityIndicatorView *_ingV;
    
    BOOL _isSearchMod;
    BOOL _isRemoteMod;
    BOOL _isNomore;
    UIView *_tbFtVBak;
    
    NSMutableArray *_selected;
}

@synthesize allPeople = _allPeople, 
            filteredPeople = _filteredPeople, 
            pyIndexedPeople = _pyIndexedPeople, 
            sortedIndex = _sortedIndex,
            remoteSearchBtn = _remoteSearchBtn,
ing = _ing,contacts = contacts_;

+ (KWISelectThreadParticipantVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:self.description bundle:nil] autorelease];
}


- (void)getUsers {
    KDUserManager *userManager = [KDManagerContext globalManagerContext].userManager;
    KDUser *currentUser = userManager.currentUser;
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"user_id" stringValue:currentUser.userId]
      setParameter:@"count" stringValue:@"100"];
    
    __block KWISelectThreadParticipantVCtrl *vc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                NSArray *users = [info objectNotNSNullForKey:@"users"];
                vc.allPeople = users;
                [vc _reindexAndLoadDataFrom:vc.allPeople];
            } 
            
        }
    
        [vc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:friends" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _dataWrapV.layer.cornerRadius = 5;
    
    CALayer *inrShadowLayer = [CALayer layer];
    inrShadowLayer.contents = (id)[UIImage imageNamed: @"inrShadowMask.png"].CGImage;
    inrShadowLayer.contentsCenter = CGRectMake(10.0f/21.0f, 10.0f/21.0f, 1.0f/21.0f, 1.0f/21.0f);
    inrShadowLayer.opacity = 0.2;
    inrShadowLayer.frame = _dataWrapV.bounds;
    [_dataWrapV.layer addSublayer:inrShadowLayer];
    
    [self getUsers];
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self
            selector:@selector(_onParticipantSelected:) 
                name:@"KWINewThreadParticipantCell.selected" 
              object:nil];
    [dnc addObserver:self
            selector:@selector(_onParticipantDeselected:) 
                name:@"KWINewThreadParticipantCell.deselected" 
              object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_closeBtn release];
    [_doneBtn release];
    [_dataWrapV release];
    [_searchV release];
    [_tableView release];
    [_pyIndexedPeople release];
    [_sortedIndex release];
    [_allPeople release];
    [_filteredPeople release];
    [_selected release];
    [_bgV release];
    [_maskBtn release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [_closeBtn release];
    _closeBtn = nil;
    [_doneBtn release];
    _doneBtn = nil;
    [_dataWrapV release];
    _dataWrapV = nil;
    [_searchV release];
    _searchV = nil;
    [_tableView release];
    _tableView = nil;
    [_bgV release];
    _bgV = nil;
    [_maskBtn release];
    _maskBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sortedIndex) {
        return self.sortedIndex.count;
    }
    
    return 0;    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sortedIndex objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (10 < self.sortedIndex.count) {
        return self.sortedIndex;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.sortedIndex.count) {
        NSString *key = [self.sortedIndex objectAtIndex:section];
        NSArray *list = [self.pyIndexedPeople objectForKey:key];
        return list.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.sortedIndex objectAtIndex:indexPath.section];
    NSArray *ls=  [self.pyIndexedPeople objectForKey:key];
   // KWUser *user = [ls objectAtIndex:indexPath.row];
    KDUser *user = ls[indexPath.row];
    
    KWINewThreadParticipantCell *cell = [KWINewThreadParticipantCell cellForUser:user];
    
    if (_selected) {
        for (KDUser *selected in _selected) {
            if ([user.userId isEqualToString:selected.userId]) {
                [cell setFakeSelected];
                break;
            }
        }
    }
    
    return cell;
}

- (void)_reindexAndLoadDataFrom:(NSArray *)users {

    if (users == nil || [users count] == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        self.pyIndexedPeople = [NSMutableDictionary dictionary];
        
        for (KDUser *user in users) {
            NSString *firstChar = [user.username substringWithRange:[user.username rangeOfComposedCharacterSequenceAtIndex:0]];
            NSString *firstPinyin = [[POAPinyin quickConvert:firstChar] substringToIndex:1];
            
            if (![self.pyIndexedPeople objectForKey:firstPinyin]) {
                [self.pyIndexedPeople setObject:[NSMutableArray array] forKey:firstPinyin];
            }
            
            NSMutableArray *ls = [self.pyIndexedPeople objectForKey:firstPinyin];
            [ls addObject:user];
        }
        
        self.sortedIndex = [self.pyIndexedPeople.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        DLog(@"self.sortedIndex = %@",self.sortedIndex);
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            [_tableView reloadData];
        });
    });
    
    
}

- (void)_onParticipantSelected:(NSNotification *)note
{
    if (!_selected) {
        _selected = [[NSMutableArray array] retain];
    }
    
    KDUser *user = [note.userInfo objectForKey:@"user"];
    for (KDUser *existing in _selected) {
        if ([existing.userId isEqualToString:user.userId]) {
            return;
        }
    }
    [_selected addObject:user];
    
    _doneBtn.enabled = YES;
}

- (void)_onParticipantDeselected:(NSNotification *)note
{
    if (!_selected) {
        return;
    }
    
    KDUser *user = [note.userInfo objectForKey:@"user"];
    for (unsigned int i = 0; i < _selected.count; i++) {
        KDUser *existing = [_selected objectAtIndex:i];
        if ([existing.userId isEqualToString:user.userId]) {
            [_selected removeObjectAtIndex:i];
            break;
        }
    }
    
    if (0 == _selected.count) {
        _doneBtn.enabled = NO;
    }
}

- (IBAction)_onCloseBtnTapped:(id)sender 
{
    [self _close];
}

- (IBAction)_onDoneBtnTapped:(id)sender 
{
    // make a copy, as content of _selected will be removed later
    NSArray *participants = [[_selected copy] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWISelectThreadParticipantVCtrl.doneSelecting" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:participants forKey:@"users"]];
    [self _close];
    [_selected removeAllObjects];
    [_tableView reloadData];
}

- (void)_close
{
    [self.view removeFromSuperview];
}

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
            NSArray *theUsers = [self.allPeople filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KDUser *toEval, NSDictionary *bindings) {
                NSRange found = [toEval.username rangeOfString:searchText options:NSCaseInsensitiveSearch];
                return NSNotFound != found.location;
            }]];
//            for (KDUser *matched in [self.allPeople filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KDUser *toEval, NSDictionary *bindings) {
//                NSRange found = [toEval.username rangeOfString:searchText options:NSCaseInsensitiveSearch];
//                return NSNotFound != found.location;
//            }]]) {
//                [self.filteredPeople addObject:matched];
//            };
            [self.filteredPeople addObjectsFromArray:theUsers];
            
            [self _reindexAndLoadDataFrom:self.filteredPeople];
        }
    } else {
        [self _turnOffSearchMod];
    }    
}

- (IBAction)_onMaskBtnTapped:(id)sender
{
    [self _close];
}

- (void)_onRemoteSearchBtnTapped
{
    [self.filteredPeople removeAllObjects];
    //[self.tableView reloadData];
    
    _isRemoteMod = YES;
    _tableView.tableFooterView = nil;
    
    [self _fetchRemotePeople];
}

- (void)_fetchRemotePeople
{
    if (self.ing || _isNomore) {
        return;
    }
    self.ing = YES;    
    
    NSUInteger pageNum = ceil((self.filteredPeople.count + 0.0) / self.PAGE_SIZE_)+1;
    KDQuery *query = [[KWPaging pagingWithPage:pageNum count:self.PAGE_SIZE_] toQuery];
    [query setParameter:@"q" stringValue:[_searchV.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[KWPaging pagingWithPage:pageNum count:self.PAGE_SIZE_] toDict]];
//    [params setObject:[_searchV.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"];
    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api get:@"users/search.json" 
//      params:params 
//   onSuccess:^(NSArray *results) {
//       //NSArray *results = [result objectForKey:@"users"];       
//       if (results) {            
//           [self.filteredPeople addObjectsFromArray:[KWUser usersFromDict:results]];
//           //self.data = self.filteredPeople;
//           [self _reindexAndLoadDataFrom:self.filteredPeople];
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
    
    __block KWISelectThreadParticipantVCtrl *vc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        NSArray *users = nil;
        if([response isValidResponse]) {
            if (results != nil) {
                users = results;
              [vc.filteredPeople addObjectsFromArray:users];
              [vc _reindexAndLoadDataFrom:vc.filteredPeople];
            }else {
                  
            }
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
    _tableView.tableFooterView = self.remoteSearchBtn;
}

- (void)_turnOffSearchMod
{
    _isSearchMod = NO;
    _isRemoteMod = NO;
    _isNomore = NO;
    [self _reindexAndLoadDataFrom:self.allPeople];
    _tableView.tableFooterView = nil;
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

- (void)setIng:(BOOL)ing
{
    _ing = ing;
    if (ing) {
        if (_tableView.tableFooterView) {
            _tbFtVBak = _tableView.tableFooterView;
        }
        
        _tableView.tableFooterView = self.ingV;
        [self.ingV startAnimating];
    } else {
        if (_tableView.tableFooterView == self.ingV) {
            [self.ingV stopAnimating];
        }
        
        if (_tbFtVBak) {
            _tableView.tableFooterView = _tbFtVBak;
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
