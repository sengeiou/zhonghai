//
//  KWITrendStreamVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWITrendStreamVCtrl.h"
#import "KDTopic.h"
#import "iToast.h"

#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"

#import "KWITrendStatusCell.h"
#import "KWILoadMoreVCtrl.h"
#import "KWIStatusVCtrl.h"
#import "KDCommonHeader.h"
#import "KWPaging.h"

@interface KWITrendStreamVCtrl () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSMutableArray *data;
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSCache *cellCache;
@property (retain, nonatomic) KWILoadMoreVCtrl *loadmoreVCtrl;

@end

@implementation KWITrendStreamVCtrl
{
    BOOL _isLoading;
    UIImageView *_bgV;
    BOOL _isShadowDisabled;
}

@synthesize topic = topic_;
@synthesize data = _data;
@synthesize tableView = _tableView;
@synthesize cellCache = _cellCache;
@synthesize loadmoreVCtrl = _loadmoreVCtrl;

+ (KWITrendStreamVCtrl *)vctrlWithTopic:(KDTopic *)topic
{
    return [[[self alloc] initWithTrend:topic] autorelease];
}

- (id)initWithTrend:(KDTopic *)topic {
    self = [super init];
    if (self) {
        self.topic = topic;
        self.data = [NSMutableArray array];
        self.cellCache = [[[NSCache alloc] init] autorelease];
        self.cellCache.countLimit = 20;
        
              
              
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [topic_ release];
    [_data release];
    [_bgV release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect bgFrame = self.view.bounds;
    bgFrame.origin = CGPointMake(-9, -9);
    _bgV = [[UIImageView alloc] initWithFrame:bgFrame];
    [self.view addSubview:_bgV];
    [self _configBgVForCurrentOrientation];
    
    UIImageView *hdv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trendCardHd.png"]] autorelease];
    [self.view addSubview:hdv];
    
    UILabel *namePrefixV = [[[UILabel alloc] initWithFrame:CGRectMake(0, 13, 1000, 200)] autorelease];
    namePrefixV.backgroundColor = [UIColor clearColor];
    namePrefixV.textColor = [UIColor colorWithHexString:@"666"];
    namePrefixV.font = [UIFont systemFontOfSize:16];
    namePrefixV.text = @"话题:  ";
    [namePrefixV sizeToFit];
    [self.view addSubview:namePrefixV];
    
    UILabel *nameV = [[[UILabel alloc] initWithFrame:CGRectMake(0, 13, 1000, 200)] autorelease];
    nameV.backgroundColor = [UIColor clearColor];
    nameV.textColor = [UIColor colorWithHexString:@"000"];
    nameV.font = [UIFont systemFontOfSize:16];
    nameV.text = topic_.name;
    [nameV sizeToFit];
    [self.view addSubview:nameV];
    
    CGRect namePrefixFrame = namePrefixV.frame;
    CGRect nameFrame = nameV.frame;
    CGFloat totalWidth = namePrefixFrame.size.width + nameFrame.size.width;
    namePrefixFrame.origin.x = (hdv.frame.size.width - totalWidth) / 2;
    nameFrame.origin.x = namePrefixFrame.origin.x + namePrefixFrame.size.width;
    
    namePrefixV.frame = namePrefixFrame;
    nameV.frame = nameFrame;
    
    CGRect tbFrame = self.view.bounds;
    tbFrame.origin.y = CGRectGetHeight(hdv.frame) - 2;
    tbFrame.size.height -= CGRectGetHeight(hdv.frame) + 5;
    UITableView *tbv = [[UITableView alloc] initWithFrame:tbFrame style:UITableViewStylePlain];
    tbv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tbv.delegate = self;
    tbv.dataSource = self;
    tbv.backgroundColor = [UIColor clearColor];
    tbv.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tbv];
    self.tableView = tbv;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    KWEngine *api = [KWEngine sharedEngine];
//    [api get:@"trends/statuses.json"
//      params:[NSDictionary dictionaryWithObjectsAndKeys:trend.encoded_name, @"trend_name", @"20", @"count", nil]
//   onSuccess:^(NSArray *results) {
//       self.data = [KWStatus statusesFromDict:results];
//       [self.tableView reloadData];
//       
//       if (20 <= results.count) {
//           [self _configLoadMore];
//       }
//   }
//     onError:^(NSError *err) {
//         [err KWIGeneralProcess];
//     }];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"trend_name" stringValue:topic_.name]
     setParameter:@"count" stringValue:@"20"];

    __block KWITrendStreamVCtrl *tsvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                NSArray *statuses = results;
                [self.data addObjectsFromArray:statuses];
                [self.tableView reloadData];
                
            }
            if (20 <= self.data.count) {
             [self _configLoadMore];
        }
            
        }else {
            
        }
        // release current view controller
        [tsvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/trends/:statuses" query:query
                                 configBlock:nil completionBlock:completionBlock];

}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]];
    
    return CGRectGetHeight(cell.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]]; 
}

- (KWITrendStatusCell *)_loadCellForStatus:(KDStatus *)status
{
    KWITrendStatusCell *cell = [self.cellCache objectForKey:status.id_];
    if (nil == cell) {
        cell = [KWITrendStatusCell cellWithStatus:status];
        [self.cellCache setObject:cell forKey:status.id_];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:[self.data objectAtIndex:indexPath.row]];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf]; 
}

#pragma mark -
- (void)_loadmore
{
    if (_isLoading) {
        return;
    }    
    _isLoading = YES;    
    
    KWPaging *p;  
    if (self.data.count) {
        p = [KWPaging pagingWithPage:ceil(self.data.count / 20.0)+1 count:20];
    } else {
        p = [KWPaging pagingWithPage:1 count:20];
    }
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[p toDict]];
//    [params setObject:self.trend.encoded_name forKey:@"trend_name"];
//    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api get:@"trends/statuses.json"
//      params:params 
//   onSuccess:^(NSArray *results){
//       if (results.count) {
//           NSUInteger from = self.data.count;
//           NSArray *to_append = [KWStatus statusesFromDict:results];
//           self.data = [self.data arrayByAddingObjectsFromArray:to_append];
//
//           NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:to_append.count];
//           for (NSUInteger i = from; i < self.data.count; i++) {
//               [indexpaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//           }
//           
//           [self.tableView beginUpdates];
//           [self.tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationNone];
//           [self.tableView endUpdates];
//           [self.loadmoreVCtrl setStateDefault];
//       } else {
//           [self.loadmoreVCtrl setStateNoMore];
//       }
//
//       _isLoading = NO;
//   } 
//     onError:^(NSError *error) {
//         [[iToast makeText:@"加载更多话题微博失败"] show];
//     }];
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"trend_name" stringValue:topic_.name]
     setParameter:@"count" stringValue:@"20"];
    query = [query queryByAddQuery:[p toQuery]];
    
    
    
//    if (topicStatus_ != nil && topicStatus_.groupId != nil) {
//        [query setParameter:@"group_id" stringValue:topicStatus_.groupId];
//    }
    
    __block KWITrendStreamVCtrl *tsvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                NSArray *statuses = results;
                [tsvc.data addObjectsFromArray:statuses];
                [tsvc.tableView reloadData];
                [tsvc.loadmoreVCtrl setStateDefault];
                
            }else {
                 [tsvc.loadmoreVCtrl setStateNoMore];
            }
        }else {
            if(![response isCancelled]) {
                [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            }
        }
       
         tsvc->_isLoading = NO;
        // release current view controller
        [tsvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/trends/:statuses" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_configLoadMore
{
    if (nil == self.loadmoreVCtrl) {
        self.loadmoreVCtrl = [KWILoadMoreVCtrl vctrl];
        self.tableView.tableFooterView = self.loadmoreVCtrl.view;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadmore) name:@"KWILoadMoreVCtrl.load" object:self.loadmoreVCtrl];
    }
}

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        if (_isShadowDisabled) {
            _bgV.image = [UIImage imageNamed:@"cardBgPNoShadow.png"];
        } else {
            _bgV.image = [UIImage imageNamed:@"cardBgP.png"];
        }
    } else {
        _bgV.image = [UIImage imageNamed:@"cardBg.png"];
    }
    
    CGRect frame = _bgV.frame;
    frame.size = _bgV.image.size;
    _bgV.frame = frame;
}

- (void)_onOrientationWillChange:(NSNotification *)note
{
    _bgV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_onOrientationChanged:(NSNotification *)note
{
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOn
{
    _isShadowDisabled = NO;
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff
{
    _isShadowDisabled = YES;
    [self _configBgVForCurrentOrientation];
}

@end
