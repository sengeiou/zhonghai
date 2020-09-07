//
//  KDLikeTask.m
//  kdweibo
//
//  Created by Tan yingqi on 13-6-5.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLikeTask.h"
#import "KDServiceActionInvoker.h"
#import "KDResponseWrapper.h"
#import "KDGroupStatus.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "KDErrorDisplayView.h"
#import "KDWeiboAppDelegate.h"
#import "MBProgressHUD.h"

@implementation KDLikeTask
@dynamic status;

- (void)setStatus:(KDStatus *)status {
    self.entity = status;
}

- (KDStatus *)status {
    return (KDStatus *)(self.entity);
}

- (void)showHUD {
    [MBProgressHUD showHUDAddedTo:[KDWeiboAppDelegate getAppDelegate].window animated:YES];
    UIView *mask = [[UIView alloc]initWithFrame:[KDWeiboAppDelegate getAppDelegate].window.bounds];// autorelease];
    mask.tag = 1548;
    mask.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *gzr = [[UITapGestureRecognizer alloc] init];// autorelease];
    [gzr addTarget:self action:@selector(maskTapped:)];
    [mask addGestureRecognizer:gzr];
    [[KDWeiboAppDelegate getAppDelegate].window addSubview:mask];
}

- (void)hideHUD {
    UIView *view = [[KDWeiboAppDelegate getAppDelegate].window viewWithTag:1548];
    [view removeFromSuperview];
    
    [MBProgressHUD hideHUDForView:[KDWeiboAppDelegate getAppDelegate].window animated:NO];
}

- (void)maskTapped:(UIGestureRecognizer *)gzr {
    [self cancel];
    UIView *view = gzr.view;
    [view removeFromSuperview];
    [self hideHUD];
}

- (void)createLike {
    [self showHUD];
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.status.statusId];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        [self hideHUD];
        if([response isValidResponse]) {
          if(results) {
              NSNumber *number = (NSNumber *)results;
              if ([number boolValue]) {
                [self taskDidSuccess];
              }else {
                  [self taskDisFailed];
              }
            
          }else {
              [self taskDisFailed];
          }
        }else{
            [self taskDidCanceled];
        }
    };
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/like/:create" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
};

- (void)save {
    BOOL isGroup = [self.status isKindOfClass:[KDGroupStatus class]];

    [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusAttributionShouledUpdated object:nil userInfo:@{@"status":self.status }];
    
    [KDDatabaseHelper asyncInDeferredTransaction:(id)^(FMDatabase *fmdb, BOOL *rollback){
        id<KDStatusDAO> statusDAO = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        if (isGroup) {
            [statusDAO saveGroupStatus:(KDGroupStatus*)self.status database:fmdb];
        }else {
           
            [statusDAO updateLiked:self.status.liked statusId:self.status.statusId database:fmdb];
        }
        return nil;
        
    } completionBlock:nil];
}
- (void)destroyLike {
    [self showHUD];
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.status.statusId];
    [query setProperty:self.status.statusId forKey:@"entityId"];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
         [self hideHUD];
        if([response isValidResponse]) {
           
            NSNumber *number = (NSNumber *)results;
            if ([number boolValue]) {
                [self taskDidSuccess];
            }else {
                [self taskDisFailed];
            }
        }else{
            [self taskDidCanceled];
        }
    };
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/like/:destoryById" query:query
                                 configBlock:nil completionBlock:completionBlock];
    

}
-(void)main {
    if (!self.status.statusId||[self.status.statusId isEqualToString:@"-1"]) {
        [self taskDisFailed];
        return;
    }
    if (self.status.liked) {
        [self destroyLike];
    }else {
        [self createLike];
    }
 
}

- (void)cancel {
    [KDServiceActionInvoker cancelInvokersWithSender:self];
    [self taskDidCanceled];
}

- (void)taskDisFailed {
    if (![self isFailed] && ![self isSuccess]) {
        [KDErrorDisplayView showErrorMessage:@"\"赞\"操作失败" inView:[[KDWeiboAppDelegate getAppDelegate] window]];
        [super taskDisFailed];
    }
}

- (void)taskDidSuccess {
    if ([self isCanceled] || [self isFailed]) {
        return;
    }
    
    if (self.status.liked) {
        self.status.liked = NO;
        self.status.likedCount --;
    }else {
        self.status.liked = YES;
        self.status.likedCount ++;
    }
    [self save];
    [super taskDidSuccess];
}
- (void)dealloc {
    //[super dealloc];
}
@end
