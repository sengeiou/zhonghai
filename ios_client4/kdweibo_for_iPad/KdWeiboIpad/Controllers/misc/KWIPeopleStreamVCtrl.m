//
//  KWIPeopleStreamVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIPeopleStreamVCtrl.h"


#import "KWISimpleStatusCell.h"
#import "KWIStatusVCtrl.h"
#import "KWILoadMoreVCtrl.h"
#import "KWIStatusCell.h"
#import "KDUser.h"
#import "KWPaging.h"
@interface KWIPeopleStreamVCtrl () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UIView *container;
@property (nonatomic) CGRect frame;
@property (retain, nonatomic) KDUser *user;
@property (retain, nonatomic) UITableView *tableView;

@property (retain, nonatomic) NSArray *data;

@property (retain, nonatomic) UIImageView *topShadowV;
@property (retain, nonatomic) KWILoadMoreVCtrl *loadmoreVCtrl;

@property (retain, nonatomic) NSCache *cellCache;

@end

@implementation KWIPeopleStreamVCtrl
{
    BOOL _isLoading;
    BOOL _isProfileMod;
}

@synthesize container = _container;
@synthesize tableView = _tableView;
@synthesize frame = _frame;
@synthesize user = _user;
@synthesize data = _data;

@synthesize topShadowV = _topShadowV;
@synthesize loadmoreVCtrl = _loadmoreVCtrl;
@synthesize cellCache = _cellCache;

+ (KWIPeopleStreamVCtrl *)vctrlForUser:(KDUser *)user
                             container:(UIView *)container 
                                 frame:(CGRect)frame
{
    return [[[self alloc] initWithUser:user container:container frame:frame] autorelease];
}

- (KWIPeopleStreamVCtrl *)initWithUser:(KDUser *)user
                             container:(UIView *)container 
                                 frame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.container = container;
        self.user = user;
        self.frame = frame;
        self.view.frame = frame;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.data = [NSArray array];
        self.cellCache = [[[NSCache alloc] init] autorelease];
        self.cellCache.countLimit = 20;
        
        [self.container addSubview:self.view];
        
       // KWEngine *api = [KWEngine sharedEngine];
        
       // NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:[[KWPaging pagingWithPage:0] toDict]];
        //[_params setObject:self.user.id_ forKey:@"user_id"];
        
//        [api get:@"statuses/user_timeline.json" 
//          params:_params 
//       onSuccess:^(NSArray *results) {
//           if (results.count) {
//               self.data = [KWStatus statusesFromDict:results];
//               
//               NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:self.data.count];
//               for (NSUInteger i = 0; i < self.data.count; i++) {
//                   [indexpaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//               }
//               
//               [self.tableView beginUpdates];
//               [self.tableView insertRowsAtIndexPaths:indexpaths
//                                     withRowAnimation:UITableViewRowAnimationNone];
//               [self.tableView endUpdates];
//               
//               if (20 <= results.count) {
//                   [self _configLoadMore];
//               }
//               
//               // trigger shadow view init after tableview init
//               [self scrollViewDidScroll:self.tableView];
//           } else {
//               [self.tableView removeFromSuperview];
//           }
//       } 
//         onError:^(NSError *error) {
//             // TODO
//         }];
        
   
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_container release];
    [_user release];
    [_data release];
    [_topShadowV release];
    [_loadmoreVCtrl release];
    [_tableView release];
    KD_RELEASE_SAFELY(_cellCache);
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KDQuery *query = [[KWPaging pagingWithPage:0] toQuery];
    [query setParameter:@"user_id" stringValue:self.user.userId];
    
    __block KWIPeopleStreamVCtrl *psvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results) {
                NSArray *status = [(NSDictionary *)results objectNotNSNullForKey:@"statuses"];
                if(status) {
                    psvc.data = status;
                    NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:psvc.data.count];
                    for (NSUInteger i = 0; i < psvc.data.count; i++) {
                        [indexpaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [psvc.tableView beginUpdates];
                    [psvc.tableView insertRowsAtIndexPaths:indexpaths
                                          withRowAnimation:UITableViewRowAnimationNone];
                    [psvc.tableView endUpdates];
                    
                    if (20 <= status.count) {
                        [psvc _configLoadMore];
                    }
                }else {
                  [psvc.tableView removeFromSuperview];  
                }
            }
            else {
                 [psvc.tableView removeFromSuperview];
            }
        }else {
            if ([response isCancelled]) {
                
            }
        }
        [psvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:userTimeline" query:query
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]];
    
    return CGRectGetHeight(cell.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]]; 
}

- (KWISimpleStatusCell *)_loadCellForStatus:(KDStatus *)status
{
    KWISimpleStatusCell *cell = [self.cellCache objectForKey:status.id_];
    if (nil == cell) {
        cell = [KWISimpleStatusCell cell];
        cell.data = status;
        [self.cellCache setObject:cell forKey:status.id_];
    }
    
    return cell;
}

- (void)_loadmore
{
    if (_isLoading) {
        return;
    }    
    _isLoading = YES;    
    
    KWPaging *p;    
    if (self.data.count) {
        KDStatus *oldestStatus = [self.data lastObject];
        p = [KWPaging pagingWithMaxId:oldestStatus.id_];
    } else {
        p = [KWPaging pagingWithPage:1];
    } 
    
    KDQuery *query = [p toQuery];
    [query setParameter:@"user_id" stringValue:self.user.userId];
//    KWEngine *api = [KWEngine sharedEngine];
//    [api get:@"statuses/user_timeline.json" 
//      params: params
//   onSuccess:^(NSArray *dictAr){
//       if (dictAr.count) {
//           NSUInteger from = self.data.count;
//           NSArray *statuses = [KWStatus statusesFromDict:dictAr];
//           self.data = [self.data arrayByAddingObjectsFromArray:statuses];
//           
//           NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:statuses.count];
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
//         // TODO
//     }];
    
    __block KWIPeopleStreamVCtrl *psvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results) {
                NSUInteger from = psvc.data.count;
                NSArray *statuses = [(NSDictionary *)results objectNotNSNullForKey:@"statuses"];
                if (statuses) {
                    psvc.data = [psvc.data arrayByAddingObjectsFromArray:statuses];
                    NSMutableArray *indexpaths = [NSMutableArray arrayWithCapacity:statuses.count];
                    for (NSUInteger i = from; i < psvc.data.count; i++) {
                        [indexpaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [psvc.tableView beginUpdates];
                    [psvc.tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationNone];
                    [psvc.tableView endUpdates];
                    [psvc.loadmoreVCtrl setStateDefault];
                }else {
                   [psvc.loadmoreVCtrl setStateNoMore]; 
                }
            }
            else {
                [psvc.loadmoreVCtrl setStateNoMore]; 
            }
            psvc->_isLoading = NO;
        }else {
            if ([response isCancelled]) {
                
            }
        }
        [psvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:userTimeline" query:query
                                 configBlock:nil completionBlock:completionBlock];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
- (void)setProfileMod
{
    _isProfileMod = TRUE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:[self.data objectAtIndex:indexPath.row]];
    // ugly hack to make RootVCtrl replace RPanelVCtrl
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", _isProfileMod?[KWIStatusCell class]:[self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];
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
