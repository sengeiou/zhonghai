//
//  GroupUserController.m
//  TwitterFon
//
//  Created by  on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "GroupUserController.h"

#import "KDWeiboServicesContext.h"
#import "KDRequestDispatcher.h"

#import "KDNotificationView.h"
#import "KDErrorDisplayView.h"

#import "KDDatabaseHelper.h"
#import "NSDictionary+Additions.h"


@implementation GroupUserController

@synthesize group;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = ASLocalizedString(@"GroupInfoViewController_tips_2");
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUserData];
}

- (void)loadGroupMembersAtHead:(BOOL)atHead {
    NSInteger page = atHead ? -1 : self.currentPage;
    self.isLoadingMore = !atHead;
    KDQuery *query = [KDQuery query];
    [[[query setParameter:@"group_id" stringValue:group.groupId]
             setParameter:@"count" stringValue:@"10"]
             setParameter:@"cursor" integerValue:page];
    
    __block GroupUserController *guvc = self ;//retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                NSArray *users = [info objectForKey:@"users"];
                guvc.currentPage = [info integerForKey:@"nextCursor"];
                
                if(atHead){
                    //下拉刷新的时候，先清理掉之前所有的.
                    [guvc.contacts removeAllObjects];
                    [guvc.contacts insertObjects:users atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0, users.count}]];
                }else
                    [guvc.contacts addObjectsFromArray:users];
    
                [guvc.tableView reloadData];
                 guvc.haveFootView = (guvc.currentPage != 0);
                if ([users count] > 0) {
                    // save users into database
                    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                        [userDAO saveUsersSimple:users database:fmdb];
                        
                        return nil;
                        
                    } completionBlock:nil];
                }
            }
            
        } else {
            if (![response isCancelled]) {
                [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
                                              inView:guvc.view.window];
            }
        }
        [guvc showTipsOrNot];
        [guvc dataSourceDidFinishLoadingNewData];
       
        
        // release current view controller
//        [guvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/group/:members" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)getUserTimeline {
    [self loadGroupMembersAtHead:YES];
}

- (void)getUserTimeline_next {
    [self loadGroupMembersAtHead:NO];
}


//////////////////////////////////////////////////////////////////////

// Override (UIViewController category)
- (void)viewControllerWillDismiss {
    //[[KDRequestDispatcher globalRequestDispatcher] cancelRequestsForReceiveTypeWithDelegate:self];
    [KDServiceActionInvoker cancelInvokersWithSender:self];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(group);
    
    //[super dealloc];
}

@end
