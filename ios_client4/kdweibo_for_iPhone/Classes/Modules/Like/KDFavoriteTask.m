//
//  KDFavoriteTask.m
//  kdweibo
//
//  Created by shen kuikui on 13-7-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDFavoriteTask.h"
#import "KDServiceActionInvoker.h"
#import "KDResponseWrapper.h"
#import "KDGroupStatus.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"
#import "KDErrorDisplayView.h"
#import "KDWeiboAppDelegate.h"
#import "KDNotificationView.h"

@interface KDFavoriteTask ()
@property (nonatomic, copy) NSString *message;
@end

@implementation KDFavoriteTask
@synthesize message = _message;
@dynamic status;


- (void)setStatus:(KDStatus *)status {
    self.entity = status;
}

- (KDStatus *)status {
    return (KDStatus *)(self.entity);
}

- (void)createFavorite {
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.status.statusId];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        
        NSDictionary *info = results;
        BOOL success = [[info objectForKey:@"success"] boolValue];
        BOOL favorited = [[info objectForKey:@"favorited"] boolValue];
    
        if (success) {
            self.message = ASLocalizedString(@"FAVORITES_CREATED_SUCCESS");
            self.status.favorited = YES;
            
            [self taskDidSuccess];
        } else {
            self.message = favorited ? ASLocalizedString(@"FAVORITES_FAVORITED_YET")
            : ASLocalizedString(@"FAVORITES_CREATED_FAIL");
            self.status.favorited = favorited;
            
            [self taskDisFailed];
        }
        
        [self save];
        
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/favorites/:create" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)cancelFavorite {
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.status.statusId];
    [query setProperty:self.status.statusId forKey:@"entityId"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if([results boolValue]) {
                self.status.favorited = NO;
                self.message = ASLocalizedString(@"FAVORITES_DESTORYED_SUCCESS");
            } else {
                self.message = NSLocalizedString(@"FAVORITES_DESTORYED_FAIL", @"");
            }
            
            [self save];
            [self taskDidSuccess];
        }else {
            [self taskDisFailed];
        }
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/favorites/:destoryById" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)save {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDStatusAttributionShouledUpdated object:nil userInfo:@{@"status":self.status }];

    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
        id<KDStatusDAO> dao = [KDWeiboDAOManager globalWeiboDAOManager].statusDAO;
        if([self.status isKindOfClass:[KDGroupStatus class]]) {
            [dao updateGroupStatusFavorite:self.status.favorited groupStatusId:self.status.statusId database:fmdb];
        }else {
            [dao updateFavorite:self.status.favorited statusId:self.status.statusId database:fmdb];
        }
        
        return nil;
    }completionBlock:NULL];
}

-(void)main {
    if (!self.status.statusId||[self.status.statusId isEqualToString:@"-1"]) {
        [self taskDisFailed];
        return;
    }
    if (self.status.favorited) {
        [self cancelFavorite];
    }else {
        [self createFavorite];
    }
    
}

- (void)taskDisFailed {
//    [KDErrorDisplayView showErrorMessage:self.message inView:[[KDWeiboAppDelegate getAppDelegate] window]];
    [[KDNotificationView defaultMessageNotificationView] showInView:[KDWeiboAppDelegate getAppDelegate].window
                                                            message:self.message
                                                               type:KDNotificationViewTypeNormal];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskFinished" object:nil userInfo:@{@"entity": self.status}];
    
    [super taskDisFailed];
}
- (void)taskDidSuccess {
//    [KDErrorDisplayView showErrorMessage:self.message inView:[KDWeiboAppDelegate getAppDelegate].window];
    [[KDNotificationView defaultMessageNotificationView] showInView:[KDWeiboAppDelegate getAppDelegate].window
                                                            message:self.message
                                                               type:KDNotificationViewTypeNormal];
    [super taskDidSuccess];
}

@end
