//
//  KDImageSize.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDImageSize.h"
#import "KDUtility.h"

static KDImageSize *defaultUserAvatarSize_ = nil;
static KDImageSize *defaultUserProfileSize_ = nil;
static KDImageSize *defaultGroupAvatarSize_ = nil;
static KDImageSize *defaultPreviewImageSize_ = nil;
static KDImageSize *defaultOriginViewImageSize_ = nil;
static KDImageSize *defaultMiddleImageSize_ = nil; // image size for status

static KDImageSize *defaultThumbnailImageSize_ = nil; // image size for thumbnail in direct message
static KDImageSize *defaultDMThreadAvatarSize_ = nil;

static KDImageSize *defaultMapRenderImageSize_ = nil;//
static KDImageSize *defaultGifImageSize_ = nil;

static KDImageSize *defaultCommunityLogoImageSize_ = nil;

@implementation KDImageSize

@synthesize size=size_;

@dynamic width;
@dynamic height;

- (id) init {
    self = [super init];
    if(self){
        size_ = CGSizeZero;
    }
    
    return self;
}

- (id) initWithSize:(CGSize)size {
    self = [self init];
    if(self){
        size_ = size;
    }
    
    return self;
}

- (id) initWithWidth:(CGFloat)width height:(CGFloat)height {
    self = [self initWithSize:CGSizeMake(width, height)];
    if(self){
        
    }
    
    return self;
}

+ (KDImageSize *) imageSize:(CGSize)size {
    return [[KDImageSize alloc] initWithSize:size];// autorelease];
}

+ (KDImageSize *) imageSizeWithWidth:(CGFloat)width height:(CGFloat)height {
    return [[KDImageSize alloc] initWithSize:CGSizeMake(width, height)];// autorelease];
}

+ (KDImageSize *) defaultUserAvatarSize {
    if(defaultUserAvatarSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(76.0, 76.0) : CGSizeMake(38.0, 38.0);
        defaultUserAvatarSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultUserAvatarSize_;
}

+ (KDImageSize *) defaultUserProfileImageSize {
    if(defaultUserProfileSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(640.0, 960.0) : CGSizeMake(320.0, 480.0);
        defaultUserProfileSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultUserProfileSize_;
}

+ (KDImageSize *) defaultGroupAvatarSize {
    if(defaultGroupAvatarSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(76.0, 76.0) : CGSizeMake(38.0, 38.0);
        defaultGroupAvatarSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultGroupAvatarSize_;
}


+ (KDImageSize *) defaultPreviewImageSize {
    if(defaultPreviewImageSize_ == nil){
//        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(MAXFLOAT, MAXFLOAT) : CGSizeMake(MAXFLOAT, MAXFLOAT);
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(640.0, 960.0) : CGSizeMake(320.0, 480.0);
        defaultPreviewImageSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultPreviewImageSize_;
}

+ (KDImageSize *) defaultOriginViewImageSize {
    if(defaultOriginViewImageSize_ == nil) {
        defaultOriginViewImageSize_ = [[KDImageSize alloc] initWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    }
    
    return defaultOriginViewImageSize_;
}

+ (KDImageSize *) defaultMiddleImageSize {
    if(defaultMiddleImageSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(480.0, 360.0) : CGSizeMake(240.0, 180.0);
        defaultMiddleImageSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultMiddleImageSize_;
}

+ (KDImageSize *) defaultThumbnailImageSize {
    if(defaultThumbnailImageSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(201.0, 201.0) : CGSizeMake(100.0, 100.0);
        defaultThumbnailImageSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultThumbnailImageSize_;
}

+ (KDImageSize *)defaultDMThreadAvatarSize {
    if(defaultDMThreadAvatarSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(50.0, 50.0) : CGSizeMake(25.0, 25.0);
        defaultDMThreadAvatarSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultDMThreadAvatarSize_;
}

+ (KDImageSize *)defaultMapRenderImageSize {
    if(defaultMapRenderImageSize_ == nil){
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(600.0, 100.0) : CGSizeMake(300.0, 50.0);
        defaultMapRenderImageSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultMapRenderImageSize_;
}
+ (KDImageSize *)defaultGifImageSize
{
    if (defaultGifImageSize_== nil) {
     
        CGSize bounds = [UIScreen mainScreen].bounds.size;
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(bounds.width/3*2, bounds.height/3*2): CGSizeMake(bounds.width/3,bounds.height/3);
        defaultGifImageSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    return defaultGifImageSize_;
}

+ (KDImageSize *)defaultCommunityImageSize
{
    if(defaultCommunityLogoImageSize_ == nil) {
        CGSize size = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(80.0f, 80.0f) : CGSizeMake(40.0f, 40.0f);
        defaultCommunityLogoImageSize_ = [[KDImageSize alloc] initWithSize:size];
    }
    
    return defaultCommunityLogoImageSize_;
}

- (CGFloat) width {
    return size_.width;
}

- (void) setWidth:(CGFloat)width {
    size_.width = width;
}

- (void) setHeight:(CGFloat)height {
    size_.height = height;
}

- (CGFloat) height {
    return size_.height;
}

- (void) dealloc {
    //[super dealloc];
}

@end
