//
//  KDServiceActionInvoker.m
//  kdweibo_common
//
//  Created by laijiandong on 12-10-24.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDServiceActionInvoker.h"
#import "KDWeiboServicesContext.h"


@implementation KDServiceActionInvoker

@synthesize sender=sender_;
@synthesize requestWrapperDelegate=requestWrapperDelegate_;

@synthesize requestURL=requestURL_;

@synthesize servicePath=servicePath_;
@synthesize query=query_;
@synthesize requestHeaders = requestHeaders_;
@synthesize mask=mask_;

@synthesize serviceIdentifier=serviceIdentifier_;
@synthesize tag=tag_;

@synthesize didCompleteBlock=didCompleteBlock_;

- (id)init {
    self = [super init];
    if (self) {
        requestWrapperDelegate_ = nil;
        
        requestURL_ = nil;
        
        mask_ = KD_INVOKER_MASK_BASE;
        
        serviceIdentifier_ = 0;
        tag_ = [KDServiceActionInvoker nextTagIndex];
        
        didCompleteBlock_ = nil;
    }
    
    return self;
}

- (id)initWithSender:(id)sender servicePath:(KDServiceActionPath *)servicePath query:(KDQuery *)query {
    self = [self init];
    if (self) {
        sender_ = sender;
        
        servicePath_ = servicePath;// retain];
        query_ = query;// retain];
    }
    
    return self;
}

- (id)initWithSender:(id)sender serviceFullyPath:(NSString *)serviceFullyPath query:(KDQuery *)query {
    self = [self init];
    if (self) {
        sender_ = sender;
        
        servicePath_ = [KDServiceActionPath serviceActionPath:serviceFullyPath];// retain];
        query_ = query;// retain];
    }
    
    return self;
}

+ (id)invokerWithSender:(id)sender serviceFullyPath:(NSString *)serviceFullyPath query:(KDQuery *)query {
    return [[KDServiceActionInvoker alloc] initWithSender:sender serviceFullyPath:serviceFullyPath query:query];// autorelease];
}

+ (void)invokeWithSender:(id)sender actionPath:(NSString *)path query:(KDQuery *)query
             configBlock:(void (^)(KDServiceActionInvoker *))configBlock
         completionBlock:(KDServiceActionDidCompleteBlock)completionBlock {
    
    KDServiceActionInvoker *invoker = [KDServiceActionInvoker invokerWithSender:sender serviceFullyPath:path query:query];
    
    // config the invoker if need
    if (configBlock != nil) {
        configBlock(invoker);
    }
    
    invoker.didCompleteBlock = completionBlock;
    
    KDServiceActionExecutor *executor = [[KDWeiboServicesContext defaultContext] serviceActionExecutor];
    [executor execute:invoker];
}

+ (void)invokeWithSender:(id)sender actionPath:(NSString *)path parameters:(NSString *)params
             configBlock:(void (^)(KDServiceActionInvoker *))configBlock
         completionBlock:(KDServiceActionDidCompleteBlock)completionBlock {
    
    KDQuery *query = nil;
    if (params != nil && [params length] > 0) {
        query = [KDQuery query];
        
        // format like: a=b&c=d&e=f
        NSArray *components = [params componentsSeparatedByString:@"&"];
        for (NSString *item in components) {
            NSArray *pair = [item componentsSeparatedByString:@"="];
            if (pair != nil && [pair count] == 2) {
                [query setParameter:pair[0] stringValue:pair[1]];
            }
        }
    }
    
    [self invokeWithSender:sender actionPath:path query:query
               configBlock:configBlock completionBlock:completionBlock];
}

+ (void)cancelInvokersWithSender:(id)sender {
    KDServiceActionExecutor *executor = [[KDWeiboServicesContext defaultContext] serviceActionExecutor];
    [executor cancelInvokerWithSender:sender];
}

+ (void)cancelInvokersWithFullyAcionPath:(NSString *)fullyActionPath {
    KDServiceActionExecutor *executor = [[KDWeiboServicesContext defaultContext] serviceActionExecutor];
    [executor cancelInvokerWithServiceFullyPath:fullyActionPath];
}


- (NSUInteger)serviceIdentifier {
    if (0 == serviceIdentifier_) {
        serviceIdentifier_ = [servicePath_ hash];
    }
    
    return serviceIdentifier_;
}

- (void)resetRequestURL:(NSString *)url {
    // release the request url if need to make call retain / relase on balance
    if (requestURL_ != nil) {
        //KD_RELEASE_SAFELY(requestURL_);
    }
    
    requestURL_ = url;// retain];
}

- (void)configWithMask:(KDInvokerMask)mask serviceURL:(NSString *)serviceURL {
    mask_ = mask;
    
    if (serviceURL != nil) {
        // initial request url
        id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
        NSString *url = [self isCommunityRequest] ? [services communityURLWithSuffix:serviceURL]
                                                    : [services baseURLWithSuffix:serviceURL];
        
        [self resetRequestURL:url];
    }
}

- (BOOL)isAuthNeed {
    return (KDInvokerMaskAuthNeed & mask_) != 0;
}

- (BOOL)isCommunityRequest {
    return (KDInvokerMaskCommunityRequest & mask_) != 0;
}

// check the action path and service name is valid
- (BOOL)isValid {
    BOOL valid = NO;
    if ((servicePath_.actionPath != nil && [servicePath_.actionPath length] > 0x02)
        && (servicePath_.serviceName != nil && [servicePath_.serviceName length] > 0x00)) {
        valid = YES;
    }
    
    return valid;
}

+ (NSInteger)nextTagIndex {
    static NSInteger tagIndex_ = 0;
    return tagIndex_++;
}


- (void)releaseBlocksOnMainThread {
    NSArray *array = nil;
    
    if(didCompleteBlock_ != nil){
        array = @[didCompleteBlock_];
        
//        [didCompleteBlock_ release];
        didCompleteBlock_ = nil;
    }
    
    if([array count] > 0) {
        [[self class] performSelectorOnMainThread:@selector(releaseBlocks:) withObject:array waitUntilDone:[NSThread isMainThread]];
    }
}

// Always release the blocks on main thread
+ (void)releaseBlocks:(NSArray *)blocks {
    // the blocks will be release when this method did finish.
}

- (void)dealloc {
    sender_ = nil;
    requestWrapperDelegate_ = nil;
    
    //KD_RELEASE_SAFELY(requestURL_);
    //KD_RELEASE_SAFELY(servicePath_);
    //KD_RELEASE_SAFELY(query_);
    
    [self releaseBlocksOnMainThread];
    
    //[super dealloc];
}

@end
