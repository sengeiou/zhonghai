//
//  KDMockImageContext.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDImageLoaderAdapter.h"

#import "KDWeiboServicesContext.h"
#import "KDImageSize.h"


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDMockLoader class

// this class is a wrapper class for KDImageSourceLoader protocol, Then the implementation class of
// KDAvatarLoader / KDCompositeAvatarLoader / KDImageSourceLoader can be use in weak reference,

@interface KDMockLoader : NSObject {
 @private
//    id loader_; // weak reference
}

@property(nonatomic, assign, readonly) id loader;

- (id)initWithLoader:(id)loader;
+ (id)mockLoader:(id)loader;

@end

@implementation KDMockLoader

@synthesize loader=loader_;

- (id)initWithLoader:(id)loader {
    self = [super init];
    if(self){
        loader_ = loader;
    }
    
    return self;
}

+ (id)mockLoader:(id)loader {
    return [[KDMockLoader alloc] initWithLoader:loader];// autorelease];
}

- (void)dealloc {
    loader_ = nil;
    
    //[super dealloc];
}

@end


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDImageLoaderAdapter class

@interface KDImageLoaderAdapter ()

@property (nonatomic, retain) NSMutableDictionary *avatarLoaders;
@property (nonatomic, retain) NSMutableDictionary *imagesLoaders;

@end


@implementation KDImageLoaderAdapter

@synthesize avatarLoaders=avatarLoaders_;
@synthesize imagesLoaders=imagesLoaders_;

- (id)init {
    self = [super init];
    if(self){
        avatarLoaders_ = [[NSMutableDictionary alloc] init];
        imagesLoaders_ = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (KDMockLoader *)mockLoader:(id)loader {
    return [KDMockLoader mockLoader:loader];
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark load avatar methods

- (BOOL)isRequestAvatarURL:(NSString *)URL {
    return ([avatarLoaders_ objectForKey:URL] != nil) ? YES : NO;
}

- (void)removeAvatarLoader:(id<KDAvatarLoader>)avatarLoader exceptKey:(NSString *)exceptKey {
    if([avatarLoaders_ count] < 0x01) return;
    
    NSMutableArray *keys = [NSMutableArray array];
    
    id key = nil;
    id obj = nil;
    NSEnumerator *enumerator = [avatarLoaders_ keyEnumerator];
    while ((key = [enumerator nextObject]) != nil) {
        obj = [avatarLoaders_ objectForKey:key];
        
        if([obj isKindOfClass:[NSArray class]]){
            NSMutableArray *array = (NSMutableArray *)obj;
            
            NSUInteger idx = 0;
            BOOL found = NO;
            for(KDMockLoader *mockLoader in array){
                if(mockLoader.loader == avatarLoader) {
                    found = YES;
                    break;
                }
                
                idx++;
            }
            
            if (found) {
                [array removeObjectAtIndex:idx];
                
                if([array count] == 0){
                    [keys addObject:key];
                }
            }
            
        }else {
            if(((KDMockLoader *)obj).loader == avatarLoader){
                [keys addObject:key];
                continue;
            }
        }
    }
    
    if ([keys count] > 0) {
        // remove the except URL
        if(exceptKey != nil) {
            // The keys always unique
            NSString *mappedKey = nil;
            for(NSString *item in keys){
                if([item isEqualToString:exceptKey]){
                    mappedKey = item;
                    break;
                }
            }
            
            if(mappedKey != nil) {
                [keys removeObject:mappedKey];
            }
        }
        
        for (id cacheKey in keys) {
            [avatarLoaders_ removeObjectForKey:cacheKey];
        }
    }
}

// If the exclusive is set as true, Then a avatar loader only monitor one url
- (void)storeAvatarLoader:(id<KDAvatarLoader>)avatarLoader forKey:(NSString *)key exclusive:(BOOL)exclusive {
    if (avatarLoader != nil && key != nil){
        if (exclusive) {
            // cancel the same delegate for the others key
            [self removeAvatarLoader:avatarLoader exceptKey:key];
        }
        
        id obj = [avatarLoaders_ objectForKey:key];
        if (obj != nil){
            if([obj isKindOfClass:[NSArray class]]){
                NSMutableArray *array = (NSMutableArray *)obj;
                for(KDMockLoader *mockLoader in array){
                    if(mockLoader.loader == avatarLoader){
                        return; // don't add any same avatar loader into list
                    }
                }
                
                [array addObject:[self mockLoader:avatarLoader]];
                
            } else {
                if(((KDMockLoader *)obj).loader == avatarLoader) return; // don't add any same delegate into list
                
                NSMutableArray *array = [NSMutableArray arrayWithObjects:obj, [self mockLoader:avatarLoader], nil];
                [avatarLoaders_ setObject:array forKey:key];
            }
            
        } else {
            [avatarLoaders_ setObject:[self mockLoader:avatarLoader] forKey:key];
        }
    }
}

- (UIImage *)avatarWithLoader:(id<KDAvatarLoader>)loader fromNetwork:(BOOL)fromNetwork {
    id<KDAvatarDataSource> dataSource = [loader getAvatarDataSource];
    
    NSString *avatarURL = [dataSource getAvatarLoadURL];
    if(avatarURL == nil || [avatarURL length] == 0){
        return nil;
    }
    
    NSString *cacheKey = [dataSource getAvatarCacheKey];
    UIImage *image = [[KDCache sharedCache] avatarForCacheKey:cacheKey fromDisk:YES];
    if (image == nil && fromNetwork) {
        [self loadAvatarWithLoader:loader dataSource:dataSource url:avatarURL exclusive:YES];
    }
    
    return image;
}

- (void)asyncLoadAvatarWithLoader:(id<KDAvatarLoader>)loader fromNetwork:(BOOL)fromNetwork
                   completedBlock:(KDImageLoaderCompletedBlock)block {
    
    id<KDAvatarDataSource> dataSource = [loader getAvatarDataSource];
    NSString *avatarURL = [dataSource getAvatarLoadURL];
    if (avatarURL == nil || [avatarURL length] == 0) {
        if (block != nil) {
            block(nil);
        }
        
        return;
    }
    
    NSString *cacheKey = [dataSource getAvatarCacheKey];
    [[KDCache sharedCache] avatarForCacheKey:cacheKey fromDisk:YES completedBlock:^(UIImage *image) {
        if (block != nil) {
            block(image);
        }
        
        if (image == nil && fromNetwork) {
            [self loadAvatarWithLoader:loader dataSource:dataSource url:avatarURL exclusive:YES];
        }
    }];
}

- (UIImage *)avatarWithCompositeLoader:(id<KDCompositeAvatarLoader>)loader atIndex:(NSUInteger)atIndex fromNetwork:(BOOL)fromNetwork {
    id<KDCompositeAvatarDataSource> dataSource = [loader compositeAvatarDataSource];
    
    NSString *avatarURL = [dataSource avatarLoadURLAtIndex:atIndex];
    if (avatarURL == nil || [avatarURL length] == 0) {
        return nil;
    }
    
    NSString *cacheKey = [dataSource avatarCacheKeyAtIndex:atIndex];
    UIImage *image = [[KDCache sharedCache] avatarForCacheKey:cacheKey fromDisk:YES];
    if (image == nil && fromNetwork) {
        [self loadAvatarWithLoader:loader dataSource:dataSource url:avatarURL exclusive:NO];
    }
    
    return image;
}

- (void)asyncLoadAvatarWithCompositeLoader:(id<KDCompositeAvatarLoader>)loader atIndex:(NSUInteger)atIndex
                               fromNetwork:(BOOL)fromNetwork completedBlock:(KDImageLoaderCompletedBlock)block {
    
    id<KDCompositeAvatarDataSource> dataSource = [loader compositeAvatarDataSource];
    NSString *avatarURL = [dataSource avatarLoadURLAtIndex:atIndex];
    if (avatarURL == nil || [avatarURL length] == 0) {
        if (block != nil) {
            block(nil);
        }
        
        return;
    }
    
    NSString *cacheKey = [dataSource avatarCacheKeyAtIndex:atIndex];
    
    [[KDCache sharedCache] avatarForCacheKey:cacheKey fromDisk:YES completedBlock:^(UIImage *image) {
        if (block != nil) {
            block(image);
        }
        
        if (image == nil && fromNetwork) {
            [self loadAvatarWithLoader:loader dataSource:dataSource url:avatarURL exclusive:NO];
        }
    }];
}

- (void)loadAvatarWithLoader:(id<KDAvatarLoader>)loader
                  dataSource:(id<KDAvatarDataSource>)dataSource
                         url:(NSString *)url
                   exclusive:(BOOL)exclusive {
    [self storeAvatarLoader:loader forKey:url exclusive:exclusive];
    
    // check the request is on going
    BOOL onQueue = [[KDRequestDispatcher globalRequestDispatcher] isOnRequestQueueWithTransferURL:url updatePriority:YES];
    if (!onQueue) {
        id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
        
        switch ([dataSource getAvatarType]) {
            case KDAvatarTypeUser:
            case KDAvatarTypeDMThread:
                [services accountAvatar:self url:url scaleToSize:[dataSource avatarScaleToSize]];
                break;
                
            case KDAvatarTypeGroup:
                [services groupAvatar:self url:url scaleToSize:[dataSource avatarScaleToSize]];
                break;
                
            default:
                break;
        }
    }
}


// Because the table view cell will be reuse, So one delegate may be map to many keys.
- (void)removeAvatarLoader:(id<KDAvatarLoader>)avatarLoader {
    [self removeAvatarLoader:avatarLoader exceptKey:nil];
}

- (void)clearAllAvatarLoaders {
    if ([avatarLoaders_ count] > 0x00) {
        [avatarLoaders_ removeAllObjects];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark image source loader methods

- (BOOL)isRequestImageSourceURL:(NSString *)URL {
    return ([imagesLoaders_ objectForKey:URL] != nil) ? YES : NO;
}

- (void)storeImageSourceLoader:(id<KDImageSourceLoader>)loader forKey:(NSString *)key {
    if(loader != nil && key != nil) {
        // If there is the other image source loader for same URL, just do replace
        [imagesLoaders_ setObject:[self mockLoader:loader] forKey:key];
    }
}

- (NSData *)imageDataWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                      cacheType:(KDCacheImageType)cacheType
                    fromNetwork:(BOOL)fromNetwork
{
    if(URL == nil || [URL length] == 0){
        // DLog(@"The request image URL can not be nil.");
        return nil;
    }
    
    //未发送的图片
    if([URL rangeOfString:@"Unsend"].location != NSNotFound) {
        return [NSData dataWithContentsOfFile:URL];
    }
    
    id<KDImageDataSource> imageDataSource = [imageSourceLoader getImageDataSource];
    
    NSString *cacheKey = [imageDataSource cacheKeyForImageSourceURL:URL];
    NSData *data = [[KDCache sharedCache] imageDataForCacheKey:cacheKey imageType:cacheType];
    if(data == nil && fromNetwork) {
        // update image source laoder if need
        [self storeImageSourceLoader:imageSourceLoader forKey:cacheKey];
        
        
        
        // check the request is on going
        BOOL onQueue = [[KDRequestDispatcher globalRequestDispatcher] isOnRequestQueueWithTransferURL:URL updatePriority:YES];
        if(!onQueue) {
            NSArray *userInfo = [NSArray arrayWithObjects:[NSNumber numberWithInteger:cacheType], cacheKey,[NSNumber numberWithInteger:KDLoadImageTypeGif], nil];
            
            id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
            [services statusesImageSource:self url:URL cacheType:cacheType
                              scaleToSize:[imageSourceLoader optimalImageSize] userInfo:userInfo];
        }
    }
    
    return data;
}


- (void)asyncLoadImageWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                       cacheType:(KDCacheImageType)cacheType
                       imageType:(KDLoadImageType)imageType
                     fromNetwork:(BOOL)fromNetwork
                  completedBlock:(KDImageLoaderCompletedBlock)block
{
    
    if (URL == nil || [URL length] == 0) {
        if (block != nil) {
            block(nil);
        }
        
        return;
    }
    
    id<KDImageDataSource> imageDataSource = [imageSourceLoader getImageDataSource];
    
    NSString *cacheKey = [imageDataSource cacheKeyForImageSourceURL:URL];
    [[KDCache sharedCache] imageForCacheKey:cacheKey imageType:cacheType completedBlock:^(UIImage *image) {
        if (block != nil) {
            block(image);
        }
        
        if (image == nil && fromNetwork) {
            // update image source laoder if need
            [self storeImageSourceLoader:imageSourceLoader forKey:cacheKey];
            
            
            // check the request is on going
            BOOL onQueue = [[KDRequestDispatcher globalRequestDispatcher] isOnRequestQueueWithTransferURL:URL updatePriority:YES];
            if (!onQueue) {
                NSArray *userInfo = [NSArray arrayWithObjects:[NSNumber numberWithInteger:cacheType], cacheKey,[NSNumber numberWithInteger:imageType], nil];
                
                id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
                [services statusesImageSource:self url:URL cacheType:cacheType
                                  scaleToSize:[imageSourceLoader optimalImageSize] userInfo:userInfo];
            }
        }
    }];
}
- (UIImage *)imageWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                   cacheType:(KDCacheImageType)cacheType fromNetwork:(BOOL)fromNetwork
{
    if(URL == nil || [URL length] == 0){
        // DLog(@"The request image URL can not be nil.");
        return nil;
    }
    
    id<KDImageDataSource> imageDataSource = [imageSourceLoader getImageDataSource];
    
    NSString *cacheKey = [imageDataSource cacheKeyForImageSourceURL:URL];
    UIImage *image = [[KDCache sharedCache] imageForCacheKey:cacheKey imageType:cacheType];
    if(image == nil && fromNetwork) {
        // update image source laoder if need
        [self storeImageSourceLoader:imageSourceLoader forKey:cacheKey];
        
        // check the request is on going
        BOOL onQueue = [[KDRequestDispatcher globalRequestDispatcher] isOnRequestQueueWithTransferURL:URL updatePriority:YES];
        if(!onQueue) {
            NSArray *userInfo = [NSArray arrayWithObjects:[NSNumber numberWithInteger:cacheType], cacheKey,[NSNumber numberWithInteger:KDLoadImageTypeDefault], nil];
            
            id<KDWeiboServices> services = [[KDWeiboServicesContext defaultContext] getKDWeiboServices];
            [services statusesImageSource:self url:URL cacheType:cacheType
                              scaleToSize:[imageSourceLoader optimalImageSize] userInfo:userInfo];
        }
    }
    
    return image;
}

- (void)asyncLoadImageWithLoader:(id<KDImageSourceLoader>)imageSourceLoader forURL:(NSString *)URL
                       cacheType:(KDCacheImageType)cacheType fromNetwork:(BOOL)fromNetwork
                  completedBlock:(KDImageLoaderCompletedBlock)block
{
    return [self asyncLoadImageWithLoader:imageSourceLoader
                                   forURL:URL
                                cacheType:cacheType
                                imageType:KDLoadImageTypeDefault
                              fromNetwork:fromNetwork
                           completedBlock:block];
}
- (void)cancelRequestForLoader:(id<KDImageSourceLoader>)loader url:(NSString *)url
{
    id<KDImageDataSource> imageDataSource = [loader getImageDataSource];

    NSString *cacheKey = [imageDataSource cacheKeyForImageSourceURL:url];

    KDMockLoader *mockLoader = [imagesLoaders_ objectForKey:cacheKey];
    
    if (mockLoader && mockLoader.loader == loader) {
        
        if (![self imageSourceDownLoadFinishedForLoader:loader url:url]) {
            [imagesLoaders_ removeObjectForKey:cacheKey];
            [[KDRequestDispatcher globalRequestDispatcher] cancelTransferingRequestWithURLPrefix:cacheKey];
        }
    }
    
}
- (BOOL)imageSourceDownLoadFinishedForLoader:(id<KDImageSourceLoader>)loader url:(NSString *)url
{
    id<KDImageDataSource> imageDataSource = [loader getImageDataSource];
    
    NSString *cacheKey = [imageDataSource cacheKeyForImageSourceURL:url];
    
    KDMockLoader *mockLoader = [imagesLoaders_ objectForKey:cacheKey];
    
    if (mockLoader && mockLoader.loader == loader) {
        return [[KDRequestDispatcher globalRequestDispatcher] imageSourceTransferFinishedWithURLPrefix:url];
    }
    return YES;
}
- (void)removeImageSourceLoader:(id<KDImageSourceLoader>)loader cancelRequest:(BOOL)cancel {
    if(loader != nil && [imagesLoaders_ count] > 0){
        NSMutableArray *keys = [NSMutableArray array];
        
        NSEnumerator *enumerator = [imagesLoaders_ keyEnumerator];
        id key = nil;
        KDMockLoader *mockLoader = nil;
        while((key = [enumerator nextObject]) != nil){
            mockLoader = [imagesLoaders_ objectForKey:key];
            if(mockLoader.loader == loader) {
                [keys addObject:key];
            }
        }
        
        if([keys count] > 0) {
            [imagesLoaders_ removeObjectsForKeys:keys];
            
            if(cancel) {
                for (NSString *url in keys) {
                    [[KDRequestDispatcher globalRequestDispatcher] cancelTransferingRequestWithURLPrefix:url];
                }
            }
        }
    }
}

- (void)clearAllImageSourceLoaders {
    if([imagesLoaders_ count] > 0) [imagesLoaders_ removeAllObjects];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)callbackAvatarLoader:(id<KDAvatarLoader>)delegate avatar:(UIImage *)avatar URL:(NSString *)URL {
    if([delegate respondsToSelector:@selector(avatarDidFinishLoad:forURL:succeed:)]){
        [delegate avatarDidFinishLoad:avatar forURL:URL succeed:YES];
    }
}

- (void)avatarRequestDidFinish:(NSString *)URL dropped:(BOOL)dropped succeed:(BOOL)succeed {
    if(!dropped && succeed){
        id obj = [avatarLoaders_ objectForKey:URL];
        if (obj != nil) {
            UIImage *avatar = [[KDCache sharedCache] avatarForURL:URL fromDisk:YES];
            
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *array = (NSArray *)obj;
                for (KDMockLoader *mockLoader in array) {
                    [self callbackAvatarLoader:mockLoader.loader avatar:avatar URL:URL];
                }
                
            }else {
                [self callbackAvatarLoader:((KDMockLoader *)obj).loader avatar:avatar URL:URL];
            }
        }
    }
    
    [avatarLoaders_ removeObjectForKey:URL];
}

- (void)imageResourceRequestDidFinish:(NSArray *)userInfo dropped:(BOOL)dropped succeed:(BOOL)succeed {
    NSInteger cacheType = [[userInfo objectAtIndex:0x00] integerValue];
    NSString *cacheKey = [userInfo objectAtIndex:0x01];
    NSInteger imageType = [[userInfo objectAtIndex:0x02] integerValue];
    
    if(!dropped){
        KDMockLoader *mockLoader = [imagesLoaders_ objectForKey:cacheKey];
        id<KDImageSourceLoader> imageSourceLoader = (id<KDImageSourceLoader>)mockLoader.loader;
        
        if (imageType == KDLoadImageTypeDefault) {
            
            if (imageSourceLoader != nil && [imageSourceLoader respondsToSelector:@selector(imageSourceLoaderDidFinishLoad:cacheKey:succeed:)]) {
                UIImage *image = nil;
                if(succeed){
                    DLog(@"cacheKey = %@",cacheKey);
                    image = [[KDCache sharedCache] imageForCacheKey:cacheKey imageType:cacheType];
                }
                
                [imageSourceLoader imageSourceLoaderDidFinishLoad:image cacheKey:cacheKey succeed:succeed];
            }
        }
        else if(imageType == KDLoadImageTypeGif)
        {
            if (imageSourceLoader != nil && [imageSourceLoader respondsToSelector:@selector(imageDataSourceLoaderDidFinishLoad:cacheKey:succeed:)]) {
                NSData *data = nil;
                if(succeed){
                    data = [[KDCache sharedCache] imageDataForCacheKey:cacheKey imageType:cacheType];
                }
                
                [imageSourceLoader imageDataSourceLoaderDidFinishLoad:data cacheKey:cacheKey succeed:succeed];
            }
        }
    }
    
    [imagesLoaders_ removeObjectForKey:cacheKey];
}

- (BOOL)isImageSourceRequestWrapper:(KDRequestWrapper *)requestWrapper {
    return [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey] != nil;
}

//////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDRequestWrapper delegate methods

- (void)didDropRequestWrapper:(KDRequestWrapper *)requestWrapper error:(NSError *)error {
    if([self isImageSourceRequestWrapper:requestWrapper]) {
        NSArray *userInfo = [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey];
        [self imageResourceRequestDidFinish:userInfo dropped:YES succeed:NO];
        
    }else {
        [self avatarRequestDidFinish:requestWrapper.url dropped:YES succeed:NO];
    }
}

- (void)requestWrapper:(KDRequestWrapper *)requestWrapper responseWrapper:(KDResponseWrapper *)responseWrapper requestDidFinish:(ASIHTTPRequest *)request {
    BOOL succeed = [responseWrapper isValidResponse];
    
    if ([self isImageSourceRequestWrapper:requestWrapper]) {
        NSArray *userInfo = [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey];
        [self imageResourceRequestDidFinish:userInfo dropped:NO succeed:succeed];
        
    } else {
        [self avatarRequestDidFinish:requestWrapper.url dropped:NO succeed:succeed];
    }
}

- (void)requestWrapper:(KDRequestWrapper *)requestWrapper request:(ASIHTTPRequest *)request progressMonitor:(KDRequestProgressMonitor *)progressMonitor {
    if([self isImageSourceRequestWrapper:requestWrapper]){
        NSArray *userInfo = [[requestWrapper userInfo] objectForKey:kKDCustomUserInfoKey];
        
        NSString *cacheKey = [userInfo objectAtIndex:0x01];
        NSInteger imageType = [[userInfo objectAtIndex:0x02] integerValue];
        KDMockLoader *mockLoader = [imagesLoaders_ objectForKey:cacheKey];
        id<KDImageSourceLoader> imageSourceLoader = (id<KDImageSourceLoader>)mockLoader.loader;
        
        if (imageType == KDLoadImageTypeDefault) {
            
            if([imageSourceLoader respondsToSelector:@selector(imageSourceLoaderWithCacheKey:progressMonitor:)]){
                [imageSourceLoader imageSourceLoaderWithCacheKey:cacheKey progressMonitor:progressMonitor];
            }
        }
        else if(imageType == KDLoadImageTypeGif)
        {
            if([imageSourceLoader respondsToSelector:@selector(imageDataSourceLoaderWithCacheKey:progressMonitor:)]){
                [imageSourceLoader imageDataSourceLoaderWithCacheKey:cacheKey progressMonitor:progressMonitor];
            }
        }
        
   
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(avatarLoaders_);
    //KD_RELEASE_SAFELY(imagesLoaders_);
    
    //[super dealloc];
}

@end

