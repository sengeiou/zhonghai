//
//  KWIPeoplelsVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIRelationsVCtrl.h"


#import "KWIPeopleVCtrl.h"
#import "KWIPeopleCell.h"
#import "KWILoadMoreVCtrl.h"

static const unsigned int PAGE_SIZE_ = 20;

@interface KWIRelationsVCtrl () <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIView *container;
@property (retain, nonatomic) UITableView *tableView;
@property (nonatomic) CGRect frame;
@property (retain, nonatomic) KDUser *user;

@property (retain, nonatomic) NSArray *data;

@property (retain, nonatomic) UIImageView *topShadowV;
@property (retain, nonatomic) KWILoadMoreVCtrl *loadmoreVCtrl;
@property (assign, nonatomic) NSInteger nextCursor;
 
@end

@implementation KWIRelationsVCtrl
{
    BOOL _isLoading;
    
}

@synthesize container = _container;
@synthesize frame = _frame;
@synthesize user = _user;
@synthesize data = _data;
@synthesize tableView = _tableView;
@synthesize loadmoreVCtrl = _loadmoreVCtrl;
@synthesize topShadowV = _topShadowV;
@synthesize nextCursor = nextCursor;

+ (KWIRelationsVCtrl *)vctrlForUser:(KDUser *)user
                          container:(UIView *)container 
                              frame:(CGRect)frame
{
//    return [[[self alloc] initWithUser:user container:container frame:frame] autorelease];
    KWIRelationsVCtrl * ret = [[self alloc] init];
    
    [ret configUser:user container:container frame:frame];
    
    return [ret autorelease];
}

- (void)configUser:(KDUser *)user container:(UIView *)container frame:(CGRect)frame
{
    self.container = container;
    self.user = user;
    self.frame = frame;
    self.view.frame = frame;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.data = [NSArray array];
    //[self setNextCursor:nil];
    [self setNextCursor:0];
    
    [self.container addSubview:self.view];
    
   // KWEngine *api = [KWEngine sharedEngine];
    
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"cursor", [NSNumber numberWithInt:PAGE_SIZE_], @"count", self.user.id_, @"user_id", nil];
//    
//    //NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:[[KWPaging pagingWithPage:0 count:PAGE_SIZE_] toDict]];
//    //[_params setObject:self.user.id_ forKey:@"user_id"];
//    
//    [api get:[self _getApiName]
//      params:params
//   onSuccess:^(NSDictionary *result) {
//       NSArray *results = [result objectForKey:@"users"];
////       _nextCursor = [result objectForKey:@"next_cursor"];
//       [self setNextCursor:[result objectForKey:@"next_cursor"]];
//       if (results.count) {
//           self.data = [KWUser usersFromDict:results];
//           
//           NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:self.data.count];
//           for (NSUInteger i = 0; i < self.data.count; i++) {
//               [indexpaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//           }
//           
//           [self.tableView beginUpdates];
//           [self.tableView insertRowsAtIndexPaths:indexpaths
//                                 withRowAnimation:UITableViewRowAnimationTop];
//           [self.tableView endUpdates];
//           
//           // trigger shadow view init after tableview init
//           [self scrollViewDidScroll:self.tableView];
//           
//           if (PAGE_SIZE_ <= results.count) {
//               [self _configLoadMore];
//           }
//       } else {
//           [self.tableView removeFromSuperview];
//       }
//   }
//     onError:^(NSError *error) {
//         // TODO
//     }];

    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"cursor" integerValue:0]
      setParameter:@"count" integerValue:PAGE_SIZE_]
       setParameter:@"user_id" stringValue:self.user.userId];
    
    __block KWIRelationsVCtrl *rvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                rvc.data = [(NSDictionary*)results objectNotNSNullForKey:@"users"];
                rvc.nextCursor = [[(NSDictionary*)results objectNotNSNullForKey:@"nextCursor"] integerValue];
                 NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:rvc.data.count];
                  for (NSUInteger i = 0; i < self.data.count; i++) {
                        [indexpaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                  }
                
                           [rvc.tableView beginUpdates];
                           [rvc.tableView insertRowsAtIndexPaths:indexpaths
                                                 withRowAnimation:UITableViewRowAnimationTop];
                           [rvc.tableView endUpdates];
                
                           // trigger shadow view init after tableview init
                           [rvc scrollViewDidScroll:rvc.tableView];
                           
                           if (PAGE_SIZE_ <= rvc.data.count) {
                              [rvc _configLoadMore];
                        }

             }else {
                   [rvc.tableView removeFromSuperview];
              }
         }
          else {
             if (![response isCancelled]) {
              
              }
        }
          [rvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:[self _getApiName] query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (KWIRelationsVCtrl *)initWithUser:(KDUser *)user
                          container:(UIView *)container
                              frame:(CGRect)frame
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [_container release];
    [_tableView release];
    [_user release];
    [_data release];
    [_topShadowV release];
    
    [super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)_loadmore
{
    if (_isLoading) {
        return;
    }    
    _isLoading = YES;    
    
    //KWPaging *p = [KWPaging pagingWithPage:ceil((self.data.count + 1.0) / PAGE_SIZE_) + 1 count:PAGE_SIZE_];
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_nextCursor, @"cursor", [NSNumber numberWithInt:PAGE_SIZE_], @"count", self.user.id_, @"user_id", nil];
//    //[params setObject:self.user.id_ forKey:@"user_id"];
//    
//    KWEngine *api = [KWEngine sharedEngine]; 
//    [api get:[self _getApiName] 
//      params:params 
//   onSuccess:^(NSDictionary *result) {
//       NSArray *results = [result objectForKey:@"users"];
////       _nextCursor = [result objectForKey:@"next_cursor"];
//       [self setNextCursor:[result objectForKey:@"next_cursor"]];
//       
//       if (results.count) {  
//           self.data = [self.data arrayByAddingObjectsFromArray:[KWUser usersFromDict:results]];           
//           [self.tableView reloadData];
//           
//           // trigger shadow view init after tableview init
//           [self scrollViewDidScroll:self.tableView];
//           
//           if (PAGE_SIZE_ <= results.count) {
//               [self.loadmoreVCtrl setStateDefault];
//           } else {
//               [self.loadmoreVCtrl setStateNoMore];
//           }
//       } else {
//           [self.tableView removeFromSuperview];
//       }
//       _isLoading = NO;
//   } 
//     onError:^(NSError *error) {
//         // TODO
//         [self.loadmoreVCtrl setStateDefault];
//         _isLoading = NO;
//     }];
    
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"cursor" integerValue:self.nextCursor]
      setParameter:@"count" integerValue:PAGE_SIZE_] setParameter:@"user_id" stringValue:self.user.userId];
    
    __block KWIRelationsVCtrl *rvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSArray *users = [(NSDictionary*)results objectNotNSNullForKey:@"users"];
                rvc.data =[rvc.data arrayByAddingObjectsFromArray:users];
                rvc.nextCursor = [[(NSDictionary*)results objectNotNSNullForKey:@"nextCursor"] integerValue];
                [rvc.tableView reloadData];
                
                           // trigger shadow view init after tableview init
                [rvc scrollViewDidScroll:rvc.tableView];
                if (PAGE_SIZE_ <= users.count) {
                    [rvc.loadmoreVCtrl setStateDefault];
                } else {
                   [rvc.loadmoreVCtrl setStateNoMore];
                }
                
            }else {
                [rvc.tableView removeFromSuperview];
            }
            rvc->_isLoading = NO;
        }
        else {
            if (![response isCancelled]) {
                [rvc.loadmoreVCtrl setStateDefault];
                       rvc->_isLoading = NO;
            }
        }
        [rvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:[self _getApiName] query:query
                                 configBlock:nil completionBlock:completionBlock];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"KWIPeopleCell";
    KWIPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (nil == cell) {
        cell = [KWIPeopleCell cell];
    }
    
    cell.data = [self.data objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:_tableView atIndex:0];
    }
    return _tableView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:[self.data objectAtIndex:indexPath.row]];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

#pragma mark -
- (NSString *)_getApiName
{
    @throw [NSException exceptionWithName:@"NotImplemented" 
                                   reason:@"subclass must override [KWIRelationsVCtrl _getApiName] to provide a api method name" 
                                 userInfo:nil];
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

- (void)_configLoadMore
{
    if (nil == self.loadmoreVCtrl) {
        self.loadmoreVCtrl = [KWILoadMoreVCtrl vctrl];
        self.tableView.tableFooterView = self.loadmoreVCtrl.view;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadmore) name:@"KWILoadMoreVCtrl.load" object:self.loadmoreVCtrl];
    }
}

@end
