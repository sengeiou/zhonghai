//
//  KDDMThreadAvatarView.m
//  kdweibo
//
//  Created by laijiandong on 12-9-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "KDCommon.h"
#import "KDDMThreadAvatarView.h"

#import "KDDMThread.h"
#import "KDInbox.h"
#import "KDCache.h"
#import "KDWeiboServicesContext.h"
#import "KDImageLoaderAdapter.h"


/////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDMThreadAvatarRenderView class

@interface KDDMThreadAvatarRenderView : UIView {
 @private
    UIView *maskView_;
    UIImageView *avatarView_;
}

@property(nonatomic, retain) UIView *maskView;
@property(nonatomic, retain) UIImageView *avatarView;

- (void)changeAvatar:(UIImage *)avatar isDefault:(BOOL)isDefault isCompositeMode:(BOOL)isCompositeMode;

@end


@implementation KDDMThreadAvatarRenderView

@synthesize maskView=maskView_;
@synthesize avatarView=avatarView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        // mask view
        maskView_ = [[UIView alloc] initWithFrame:CGRectZero];
//        maskView_.clipsToBounds = YES;
//        maskView_.layer.cornerRadius = 3.0;
//        maskView_.layer.borderColor = RGBCOLOR(227.0, 228.0, 229.0).CGColor;
//        maskView_.layer.borderWidth = 1.0;
        
        [self addSubview:maskView_];
        
        // avatar layer
        avatarView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [maskView_ addSubview:avatarView_];
    }
    
    return self;
}

- (void)layoutAvatarLayer {
    maskView_.frame = self.bounds;
    avatarView_.frame = maskView_.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutAvatarLayer];
}

- (void)changeMaskLayerAppearance:(BOOL)isCompositeMode {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (isCompositeMode) {
        maskView_.layer.borderColor = RGBCOLOR(227.0, 228.0, 229.0).CGColor;
        maskView_.layer.borderWidth = 1.0;
    
    } else {
        maskView_.layer.borderWidth = 0.0;
    }
    
    [CATransaction commit];
    
}

- (void)changeAvatar:(UIImage *)avatar isDefault:(BOOL)isDefault isCompositeMode:(BOOL)isCompositeMode {
    avatarView_.image = avatar;
    [avatarView_ sizeToFit];
  
    [self changeMaskLayerAppearance:isCompositeMode];

    [self setNeedsLayout];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(maskView_);
    
    //[super dealloc];
}

@end


/////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDMThreadAvatarView class

@interface KDDMThreadAvatarView ()

@property(nonatomic, retain) UIImageView *maskImageView;
@property(nonatomic, retain) UIView *stageView;
@property(nonatomic, retain) NSArray *avatarRenderViews;

@end


@implementation KDDMThreadAvatarView

@dynamic dmThread;
@dynamic dmInbox;
@dynamic loadingAvatars;
@dynamic hasUnloadAvatars;

@synthesize maskImageView=maskImageView_;
@synthesize stageView=stageView_;
@synthesize avatarRenderViews=avatarRenderViews_;

+ (KDDMThreadAvatarView *)dmThreadAvatarView {
    KDDMThreadAvatarView *avatarView = [super buttonWithType:UIButtonTypeCustom];
    if (avatarView) {
        [avatarView setupDMThreadAvatarView];
    }
    
    return avatarView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    stageView_.frame = CGRectInset(rect, 0.0, 0.0);
    maskImageView_.frame = rect;
    
    if (dmThreadAvatarViewFlags_.compositeMode == 0) {
        KDDMThreadAvatarRenderView *renderView = [avatarRenderViews_ objectAtIndex:0x00];
        renderView.frame = stageView_.bounds;
        
    } else {
        // break the stage into 4 parts
        //
        //             |
        //      2      |      1
        //             |
        //  -----------------------
        //             |
        //      3      |      4
        //             |
        //
        
        CGFloat spacing = 2.0;
        CGFloat offsetX = 1.0;
        CGFloat offsetY = 1.0;
        rect = CGRectInset(stageView_.bounds, offsetX, offsetY);
        
        CGFloat width = (rect.size.width - spacing) * 0.5;
        CGFloat height = (rect.size.height - spacing) * 0.5;
        CGRect rects[4] = {CGRectZero, CGRectZero, CGRectZero, CGRectZero};
        
        // quadrant 2
        rect = CGRectMake(offsetX, offsetY, width, height);
        rects[0x00] = rect;
        
        // quadrant 1
        rect.origin.x += width + spacing;
        rects[0x01] = rect;

        // quadrant 3
        rect.origin.x = offsetX;
        rect.origin.y += height + spacing;
        rects[0x02] = rect;

        // quadrant 4
        rect.origin.x += width + spacing;
        rects[0x03] = rect;
        
        NSUInteger idx = 0;
        for (KDDMThreadAvatarRenderView *renderView in avatarRenderViews_) {
           
            renderView.frame = rects[idx];
                idx++;
        }
    }
}


//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)reset {
    dmThreadAvatarViewFlags_.compositeMode = 1;
    loadingAvatars_ = NO;
    
    int i = 0;
    for (; i < sizeof(dmThreadAvatarViewFlags_.loadedMasks) / sizeof(unsigned int); i++) {
        dmThreadAvatarViewFlags_.loadedMasks[i] = 0;
    }
}

- (void)setupDMThreadAvatarView {
    dmThreadAvatarViewFlags_.layoutOnce = 0;
    [self reset];
    
    type_ = KdmTypeUnknow;
    // stage view
    stageView_ = [[UIView alloc] initWithFrame:CGRectZero];
    stageView_.userInteractionEnabled = NO;
    
    stageView_.clipsToBounds = NO;
    [self addSubview:stageView_];
    
    //去掉圆角效果 王松 2013-11-20
    /*
    // mask image view
    maskImageView_ = [[UIImageView alloc] initWithImage:[self defaultAvatarMaskImage]];
    maskImageView_.userInteractionEnabled = NO;
    [self addSubview:maskImageView_];
     */
    
    // avatars image view array
    avatarRenderViews_ = [[NSMutableArray alloc] initWithCapacity:KD_DM_THREAD_AVATAR_VIEW_COUNT];
    
    // initialized with placeholder render view to avoid memory alloc frequency
    KDDMThreadAvatarRenderView *renderView = nil;
    for (NSUInteger i = 0; i < KD_DM_THREAD_AVATAR_VIEW_COUNT; i++) {
        renderView = [[KDDMThreadAvatarRenderView alloc] initWithFrame:CGRectZero];
        renderView.userInteractionEnabled = NO;
        
        [avatarRenderViews_ addObject:renderView];
        [stageView_ addSubview:renderView];
//        [renderView release];
    }
}

- (BOOL)isValidAvatarViewIndex:(NSUInteger)index {
    return index <= [avatarRenderViews_ count];
}

- (BOOL)containsURL:(NSString *)url atIndex:(NSUInteger *)index {
    if (url != nil && urls_ != nil) {
        NSUInteger i = 0;
        for (NSString *item in urls_) {
            if ([item isEqualToString:url]) {
                if (index != NULL) {
                    *index = i;
                }
                
                return YES;
            }
            
            i++;
        }
    }
    
    return NO;
}

- (void)updateAvatar:(UIImage *)avatar atIndex:(NSUInteger)atIndex {
    if ([self isValidAvatarViewIndex:atIndex]) {
        unsigned int mask = 1;
        BOOL isDefault = NO;
        UIImage *image = avatar;
        if (image == nil) {
            mask = 0;
            isDefault = YES;
            image = [self defaultAvatar];
        }
        
        dmThreadAvatarViewFlags_.loadedMasks[atIndex] = mask;
        
        KDDMThreadAvatarRenderView *renderView = [avatarRenderViews_ objectAtIndex:atIndex];
        [renderView changeAvatar:image isDefault:isDefault isCompositeMode:(dmThreadAvatarViewFlags_.compositeMode == 1)];
          //2013.10.24 增加下面语句，修正多人图像错位问题  谈应奇
        [self setNeedsLayout];
    }
}

- (void)changeFirstAvatarViewAppearance {
    KDDMThreadAvatarRenderView *renderView = [avatarRenderViews_ objectAtIndex:0x00];
    renderView.layer.cornerRadius = 0.0f;// (dmThreadAvatarViewFlags_.compositeMode == 1) ? 3.0 : 0.0;
}

- (void)loadAvatarsFromNetwork:(BOOL)fromNetwork {
    if (urls_ != nil) {
        KDImageLoaderAdapter *imageLoader = [[KDWeiboServicesContext defaultContext] getImageLoaderAdapter];
        
        NSUInteger idx = 0;
        UIImage *avatar = nil;
        NSUInteger urlCount = [urls_ count];
        
        while (idx <= urls_.count) {
            avatar = [imageLoader avatarWithCompositeLoader:self atIndex:idx fromNetwork:fromNetwork];
            [self updateAvatar:avatar atIndex:idx];
            
            idx++;
        }
        
        if (!fromNetwork && urlCount < avatarCount_) {
            idx = urlCount;
            for (; idx < avatarCount_; idx++) {
                [self updateAvatar:nil atIndex:idx];
            }
        }
    }
}

- (void)reload {
    [self reset];
    
    avatarCount_ = (urls_ != nil) ? [urls_ count] : 0;
    NSInteger diff = userCount_ - avatarCount_;
    if (avatarCount_ < KD_DM_THREAD_AVATAR_VIEW_COUNT && diff > 0) {
        if (isMutil_) {
            avatarCount_ = (userCount_ > KD_DM_THREAD_AVATAR_VIEW_COUNT) ? KD_DM_THREAD_AVATAR_VIEW_COUNT
                                                                                            : userCount_;
        } else {
            avatarCount_ = 1;
        }
    }
    
    NSUInteger idx = 0;
    for (KDDMThreadAvatarRenderView *renderView in avatarRenderViews_) {
        renderView.hidden = (idx >= avatarCount_) ? YES : NO;
        idx++;
    }
    
    unsigned int flag = isMutil_ ? 1 : 0;
    BOOL needLayout = (dmThreadAvatarViewFlags_.compositeMode != flag);
    dmThreadAvatarViewFlags_.compositeMode = flag;
    
    [self changeFirstAvatarViewAppearance];
    
    // reload avatars from server
    [self loadAvatarsFromNetwork:NO];
    
    if (needLayout || dmThreadAvatarViewFlags_.layoutOnce == 0) {
        dmThreadAvatarViewFlags_.layoutOnce = 1;
        
        [self setNeedsLayout];
    }
}


//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Setter and Getter

- (void)setDmInbox:(KDInbox *)dmInbox
{
    if (type_ != KdmTypeInbox)
        type_ = KdmTypeInbox;
    
    if (dmInbox_ != dmInbox) {
//        [dmInbox_ release];
        dmInbox_ = dmInbox;// retain];
        
        urls_       = dmInbox.participantsPhoto;
        userCount_  = [dmInbox.participantsPhoto count];
        isMutil_    = [dmInbox.participantsPhoto count]>1;
        [self reload];
    }
}
- (void)setDmThread:(KDDMThread *)dmThread {
    
    if (type_ != KdmTypeThread) 
        type_ = KdmTypeThread;
    
    if (dmThread_ != dmThread) {
//        [dmThread_ release];
        dmThread_ = dmThread;// retain];
        
        urls_       = dmThread.participantAvatarURLs;
        userCount_  = dmThread.participantsCount;
        isMutil_    = dmThread.isPublic;
        
        [self reload];
    }
}
- (KDInbox *)dmInbox
{
    return dmInbox_;    
}
- (KDDMThread *)dmThread {
    return dmThread_;
}

- (void)setLoadingAvatars:(BOOL)loadingAvatars {
    if (!!loadingAvatars_ != !!loadingAvatars) {
        loadingAvatars_ = loadingAvatars;
        
        [self loadAvatarsFromNetwork:YES];
    }
}

- (BOOL)loadingAvatars {
    return loadingAvatars_;
}

- (BOOL)hasUnloadAvatars {
    BOOL exists = NO;
    int i = 0;
    for (; i < sizeof(dmThreadAvatarViewFlags_.loadedMasks) / sizeof(unsigned int); i++) {
        if (dmThreadAvatarViewFlags_.loadedMasks[i] == 0) {
            exists = YES;
            break;
        }
    }
    
    return exists;
}

////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDCompositeAvatarLoader methods

- (UIImage *)defaultAvatar {
    return [UIImage imageNamed:@"default_tiny_user_avatar.png"];
}

//- (UIImage *)defaultAvatarMaskImage {
//    return [[KDCache sharedCache] bundleImageWithName:@"profileFrame.png" leftCapAnchor:0.5 topCapAnchor:0.5 cache:YES];
//}

- (id<KDAvatarDataSource>)getAvatarDataSource {
    return nil;
}

- (id<KDCompositeAvatarDataSource>)compositeAvatarDataSource {
    if (type_ == KdmTypeThread)
        return dmThread_;
    else if(type_ == KdmTypeInbox)
        return dmInbox_;
    else
        return nil;
        
    
}

- (void)avatarDidFinishLoad:(UIImage *)avatar forURL:(NSString *)URL succeed:(BOOL)succeed {
    NSUInteger index = 0;
    if(succeed && avatar != nil && [self containsURL:URL atIndex:&index]) {
        [self updateAvatar:avatar atIndex:index];
    }
}

- (void)dealloc {
    [[[KDWeiboServicesContext defaultContext] getImageLoaderAdapter] removeAvatarLoader:self];
    
    //KD_RELEASE_SAFELY(dmThread_);
    //KD_RELEASE_SAFELY(dmInbox_);
    
    //KD_RELEASE_SAFELY(maskImageView_);
    //KD_RELEASE_SAFELY(stageView_);
    //KD_RELEASE_SAFELY(avatarRenderViews_);
    
    //[super dealloc];
}

@end
