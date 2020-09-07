//
//  KDServiceActionDispatcher.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDServiceActionDispatcher.h"

#import "KDServiceAuthActionHander.h"
#import "KDServiceAccountActionHander.h"
#import "KDServiceABActionHander.h"
#import "KDServiceAdminActionHander.h"
#import "KDServiceClientActionHander.h"
#import "KDServiceDMActionHander.h"
#import "KDServiceEventActionHander.h"
#import "KDServiceFriendshipsActionHander.h"
#import "KDServiceFavoritesActionHander.h"
#import "KDServiceHotBlogActionHander.h"
#import "KDServiceLikeActionHander.h"
#import "KDServiceStatusesActionHander.h"
#import "KDServiceGroupActionHander.h"
#import "KDServiceGroupStatusesActionHander.h"
#import "KDServiceShareActionHander.h"
#import "KDServiceTrendsActionHander.h"
#import "KDServiceUsersActionHander.h"
#import "KDServiceNetworkActionHander.h"
#import "KDServiceVoteActionHander.h"
#import "KDUploadActionHander.h"

#import "KDTaskActionHander.h"
#import "KDSeriveSignInActionHander.h"
#import "KDServiceTodoActionHander.h"
#import "KDServiceInboxActionHander.h"
#import "KDActionPathsConfigurator.h"
#import "KDEmailConfigureActionHander.h"
#import "KDServiceCollectionActionHander.h"


#import "KDRequestWrapper.h"

@interface KDServiceActionDispatcher ()

@property(nonatomic, retain) KDActionPathsConfigurator *actionPathsConfigurator;
@property(nonatomic, retain) NSMutableDictionary *serviceHandlersMapping;

@end

@implementation KDServiceActionDispatcher

@synthesize actionPathsConfigurator=actionPathsConfigurator_;
@synthesize serviceHandlersMapping=serviceHandlersMapping_;

- (id)init {
    self = [super init];
    if (self) {
        actionPathsConfigurator_ = [[KDActionPathsConfigurator alloc] init];
        serviceHandlersMapping_ = [[NSMutableDictionary alloc] init];
        
        [self _registerServiceActionHandlers];
    }
    
    return self;
}

// register the specificed service action handers
- (void)_registerServiceActionHandlers {
    NSArray *actionPaths = [actionPathsConfigurator_ allAllowedActionPaths];
    if (actionPaths != nil && [actionPaths count] > 0) {
        NSArray *classes = @[[KDServiceAccountActionHander class], [KDServiceABActionHander class], [KDServiceAdminActionHander class],
                                [KDServiceAuthActionHander class], [KDServiceClientActionHander class],[KDServiceInboxActionHander class],
                                [KDServiceDMActionHander class], [KDServiceEventActionHander class],
                                [KDServiceFavoritesActionHander class], [KDServiceFriendshipsActionHander class],
                                [KDServiceGroupActionHander class], [KDServiceGroupStatusesActionHander class],
                                [KDServiceHotBlogActionHander class], [KDServiceLikeActionHander class],
                                [KDServiceNetworkActionHander class], [KDServiceShareActionHander class],
                                [KDServiceStatusesActionHander class], [KDServiceTrendsActionHander class],
                                [KDServiceUsersActionHander class], [KDServiceVoteActionHander class],
                                [KDUploadActionHander class], [KDServiceTodoActionHander class],
                                [KDTaskActionHander class],[KDSeriveSignInActionHander class],[KDEmailConfigureActionHander class],[KDServiceCollectionActionHander class]];

        
        NSString *supportedPath = nil;
        for (Class clazz in classes) {
            supportedPath = [clazz supportedServiceActionPath];
            if (supportedPath != nil && (NSNotFound != [actionPaths indexOfObject:supportedPath])) {
                [self _addServiceActionHandlerWithClass:clazz forActionPath:supportedPath];
            }
        }
    }
}

- (void)_addServiceActionHandlerWithClass:(Class)clazz forActionPath:(NSString *)actionPath {
    if (clazz != Nil) {
        KDServiceActionHander *actionHandler = [[clazz alloc] init];// autorelease];
        [self _addServiceActionHandler:actionHandler forActionPath:actionPath];
    }
}

- (void)_addServiceActionHandler:(KDServiceActionHander *)actionHandler forActionPath:(NSString *)actionPath {
    if (actionHandler != nil && actionPath != nil) {
        [serviceHandlersMapping_ setObject:actionHandler forKey:actionPath];
    }
}

- (BOOL)isValidServiceActionInvoker:(KDServiceActionInvoker *)invoker {
    BOOL valid = NO;
    // step 1, check request action path and service name which them were defined in configuration file
    if ([actionPathsConfigurator_ isValidServiceName:invoker.servicePath.serviceName
                                       forActionPath:invoker.servicePath.actionPath]) {
        
        // step 2, check does exists relative action handler mapping for request action path
        KDServiceActionHander *actionHandler = [serviceHandlersMapping_ objectForKey:invoker.servicePath.actionPath];
        if (actionHandler != nil) {
            // step 3, check the relative action handler can responds to service name
            if ([actionHandler canRespondsToServiceName:invoker.servicePath.serviceName]) {
                valid = YES;
            }
        } 
    }
    
    return valid;
}

- (void)dispatch:(KDServiceActionInvoker *)invoker {
    KDServiceActionHander *actionHandler = [serviceHandlersMapping_ objectForKey:invoker.servicePath.actionPath];
    [actionHandler handle:invoker];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(actionPathsConfigurator_);
    //KD_RELEASE_SAFELY(serviceHandlersMapping_);
    
    //[super dealloc];
}

@end
