//
//  KWIProfileTrendLsVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIProfileTrendLsVCtrl.h"


#import "NSError+KWIExt.h"

#import "KWITrendCell.h"
#import "KWITrendStreamVCtrl.h"
#import "KDTopic.h"

@interface KWIProfileTrendLsVCtrl () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSArray *data;

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIImageView *topShadowV;

@end

@implementation KWIProfileTrendLsVCtrl
{
    NSCache *_cellCache;
}

@synthesize user = _user;
@synthesize data = _data;
@synthesize topShadowV = _topShadowV;
@synthesize tableView = _tableView;

+ (KWIProfileTrendLsVCtrl *)vctrlWithUser:(KDUser *)user
{
    return [[[self alloc] initWithUser_:user] autorelease];
}

- (id)initWithUser_:(KDUser *)user
{
    self = [super init];
    if (self) {
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.tableView];
        self.view.backgroundColor = [UIColor clearColor];
        
        
        _cellCache = [[NSCache alloc] init];
        
        self.user = user;
        self.data = [NSArray array];
        
//        KWEngine *api = [KWEngine sharedEngine];
//        [api get:@"trends.json"
//          params:[NSDictionary dictionaryWithObjectsAndKeys:self.user.id_, @"user_id", 
//                                                            [NSNumber numberWithInt:9999], @"count", 
//                                                            [NSNumber numberWithInt:1], @"page", nil] 
//       onSuccess:^(NSArray *result) {
//           NSMutableArray *new = [NSMutableArray arrayWithCapacity:result.count];
//           for (KWTrend *trend in [KWTrend trendsFromDict:result]) {
//               if (trend.latest_status) {
//                   [new addObject:trend];
//               }
//           }
//           
//           self.data = [NSArray arrayWithArray:new];
//           
//           [self.tableView reloadData];
//           [self.view setNeedsLayout];
//           [self.view setNeedsDisplay];
//       } 
//         onError:^(NSError *err) {
//             [err KWIGeneralProcess];
//         }];
        
        KDQuery *query = [KDQuery query];
        [query setParameter:@"user_id" stringValue:self.user.userId];
        [query setParameter:@"count" integerValue:9999];
        [query setParameter:@"page" integerValue:1];

            
          
        
        __block KWIProfileTrendLsVCtrl *tvc = [self retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if ([response isValidResponse]) {
                if (results != nil) {
                    NSArray *topics = results;
                     NSMutableArray *new = [NSMutableArray array];
                    for (KDTopic *topic in topics) {
                            if (topic.latestStatus) {
                                [new addObject:topic];
                            }
                    }
                    
                    tvc.data = [NSArray arrayWithArray:new];
                               
                    [tvc.tableView reloadData];
//                    [tvc.view setNeedsLayout];
//                    [tvc.view setNeedsDisplay];
                }else {
                    
                }
            }
//            if ([response isValidResponse]) {
//                if (results != nil) {
//                    if ([tvc isRecentlyTrends]) {
//                        tvc.recentlyTrends = results;
//                        
//                    } else {
//                        if(userId) {
//                            NSMutableArray *temp = [NSMutableArray arrayWithArray:tvc.trends];
//                            if(isLoadMore) {
//                                [temp addObjectsFromArray:(NSArray *)results];
//                            } else {
//                                for(KDTopic *topic in (NSArray *)results) {
//                                    for(KDTopic *tc in temp) {
//                                        if([tc.topicId isEqualToString:topic.topicId]) {
//                                            [temp removeObject:tc];
//                                            break;
//                                        }
//                                    }
//                                }
//                                
//                                [temp insertObjects:(NSArray *)results atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0, [(NSArray *)results count]}]];
//                            }
//                            
//                            tvc.trends = temp;
//                        } else {
//                            tvc.trends = results;
//                        }
//                    }
//                    
//                    if(userId) {
//                        [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
//                            id<KDTopicDAO> topicDAO = [[KDWeiboDAOManager globalWeiboDAOManager] topicDAO];
//                            [topicDAO saveTopics:results database:fmdb];
//                        }completionBlock:NULL];
//                    }
//                    
//                    if(isLoadMore && userId) {
//                        [tvc->tableView_ setBottomViewHidden:YES];
//                        tvc->pageCursor_ = tvc->pageCursor_ + 1;
//                    }
//                }
//            }
            
            
            // release current view controller
            [tvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/trends/:trends" query:query
                                     configBlock:nil completionBlock:completionBlock];
        
        
    }
    return self;
}

- (void)dealloc
{
    [_user release];
    [_data release];
    [_cellCache release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

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

- (KWITrendCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
    KWITrendCell *cell = [_cellCache objectForKey:key];
    
    if (!cell){
        cell = [KWITrendCell trendCellWithData:[self.data objectAtIndex:indexPath.row]];

		// cache it
		[_cellCache setObject:cell forKey:key];
	}
	
	return cell;
}

- (KWITrendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView preparedCellForIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	KWITrendCell *cell = (KWITrendCell *)[self tableView:tableView preparedCellForIndexPath:indexPath];
    
	return MAX(100, [cell requiredRowHeightInTableView:tableView]);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDTopic *topic = [self.data objectAtIndex:indexPath.row];
    KWITrendStreamVCtrl *vctrl = [KWITrendStreamVCtrl vctrlWithTopic:topic];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWITrendStreamVCtrl.show" object:self userInfo:inf];
}

- (UIImageView *)topShadowV
{
    if (!_topShadowV) {
        UIImage *shadowImg = [UIImage imageNamed:@"commentsTopShadow.png"];
        
        CGRect shadowFrame = self.view.bounds;
        shadowFrame.size = shadowImg.size;
        shadowFrame.origin.y -= 1;
        
        _topShadowV = [[UIImageView alloc] initWithFrame:shadowFrame];
        _topShadowV.image = shadowImg;
        
        _topShadowV.alpha = [self _calulateTopShadowAlpha:0];
        
        [self.view addSubview:self.topShadowV];
    }
    return _topShadowV;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.topShadowV.alpha = [self _calulateTopShadowAlpha:scrollView.contentOffset.y];
}

- (CGFloat)_calulateTopShadowAlpha:(CGFloat)scrollTop
{
    static BOOL _initialized;
    static NSUInteger MAX_Y;
    static CGFloat MIN_ALPHA;
    static CGFloat C1;
    static CGFloat C2;
    
    if (!_initialized) {
        MAX_Y = 500.0;
        MIN_ALPHA = 0.0;
        C1 = MIN_ALPHA * MAX_Y / (1 - MIN_ALPHA);
        C2 = (1 - MIN_ALPHA) / MAX_Y;
        _initialized = YES;
    }
    
    CGFloat y = MIN(scrollTop, MAX_Y);
    return C2 * (y + C1);
}

@end
