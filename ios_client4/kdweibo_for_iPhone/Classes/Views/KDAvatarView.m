//
//  KDAvatarView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDAvatarView.h"

@interface KDAvatarView ()

@property (nonatomic, retain) UIView *maskView;
@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) UIImageView *vipBadgeView;

@end

@implementation KDAvatarView

@dynamic avatarDataSource;

@synthesize showVipBadge=showVipBadge_;
@dynamic hasAvatar;
@dynamic loadAvatar;

@synthesize maskView=maskView_;
@synthesize avatarView=avatarView_;
@synthesize vipBadgeView=vipBadgeView_;

- (void)setupAvatarView {
    avatarDataSource_ = nil;
    
    showVipBadge_ = YES;
    hasAvatar_ = NO;
    loadAvatar_ = NO;
    
    // mask view
    maskView_ = [[UIView alloc] initWithFrame:CGRectZero];
//    maskView_.clipsToBounds = YES;
//    maskView_.layer.cornerRadius = 5.0;
    maskView_.userInteractionEnabled = NO;
    
    // avatar view
    avatarView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    avatarView_.clipsToBounds = YES;
    [maskView_ addSubview:avatarView_];
    
    [self addSubview:maskView_];
    
    // vip badge view
    vipBadgeView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    vipBadgeView_.userInteractionEnabled = YES;
    [self addSubview:vipBadgeView_];
    
    [self didSetupAvatarView];
}


// sub-classes can override it
- (void)didSetupAvatarView {
    // do nothing
}

+ (id)avatarView {
    KDAvatarView *avatarView = [super buttonWithType:UIButtonTypeCustom];
    if(avatarView != nil){
        [avatarView setupAvatarView];
    }
    
    return avatarView;
}

- (void)layoutVipBadgeView {
    if (!vipBadgeView_.hidden) {
        CGRect rect = vipBadgeView_.bounds;
        rect.origin = CGPointMake(self.bounds.size.width - rect.size.width + 2.0,
                                  self.bounds.size.height - rect.size.height + 2.0);
        vipBadgeView_.frame = rect;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutAvatar];
    [self layoutVipBadgeView];
}

- (void)layoutAvatar {
    maskView_.frame = self.bounds;
    avatarView_.frame = maskView_.bounds;
    avatarView_.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(avatarView_.frame)/2):ImageViewCornerRadius);
    avatarView_.layer.masksToBounds = YES;
    avatarView_.layer.shouldRasterize = YES;
    avatarView_.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)updateAvatar:(UIImage *)avatar {
    if (avatar != nil) {
        hasAvatar_ = YES;
    }else {
        avatar = [self defaultAvatar];
    }
    
    if (avatar != nil) {
        avatarView_.image = avatar;
        [self layoutAvatar];
    }
}

- (void)updateVipBadgeWithImage:(UIImage *)image {
    vipBadgeView_.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    BOOL hidden = (image != nil) ? NO : YES;
    vipBadgeView_.image = hidden ? nil : image;
    vipBadgeView_.hidden = hidden;
    [self setNeedsLayout];
     //[self layoutVipBadgeView];
}

- (void)loadAvatarFromNetwork {
    [self _asyncLoadAvatar:YES];
}

- (void)loadAvatarFromDisk {
    [self _asyncLoadAvatar:NO];
}

- (void)_asyncLoadAvatar:(BOOL)fromNetwork {
    if (KD_IS_BLANK_STR([avatarDataSource_ getAvatarLoadURL])) {
        [self updateAvatar:nil];
        return;
    }
    NSURL *imgUrl = [NSURL URLWithString:[avatarDataSource_ getAvatarLoadURL]];
    
    avatarView_.image = [self defaultAvatar];
    
    __block KDAvatarView *avatarView = self;// retain];
    
    [[SDWebImageManager sharedManager] downloadWithURL:imgUrl options:SDWebImageRetryFailed | SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, NSURL *url, SDImageCacheType cacheType, BOOL finished){
    
        if ([imgUrl isEqual:url]) {
            [self updateAvatar:image];
        }
        
//        [avatarView release];
    }];
    
    // disable load avatar as async mode now, do it in the future if need
    /*
    [loader asyncLoadAvatarWithLoader:self fromNetwork:fromNetwork completedBlock:^(UIImage *image) {
        [self updateAvatar:image];
    }];
     */
}

- (void)setAvatarDataSource:(id<KDAvatarDataSource>)avatarDataSource {
    if(avatarDataSource_ != avatarDataSource){
//        [avatarDataSource_ release];
        avatarDataSource_ = avatarDataSource ;//retain];
        
        hasAvatar_ = NO;
        loadAvatar_ = NO;
    }
    
    if (avatarDataSource_ != nil) {
        [self loadAvatarFromDisk];
        
        [self didChangeAvatarDataSource];
    }
}

- (id<KDAvatarDataSource>)avatarDataSource {
    return avatarDataSource_;
}

// sub-class must override it
- (void) didChangeAvatarDataSource {
    // do nothing
}

- (BOOL) hasAvatar {
    return hasAvatar_;
}

- (void) setLoadAvatar:(BOOL)loadAvatar {
    if(!!loadAvatar_ != !!loadAvatar){
        loadAvatar_ = loadAvatar;
        
        if(loadAvatar_ && !hasAvatar_){
            [self loadAvatarFromNetwork];
        }
    }
}

- (BOOL) loadAvatar {
    return loadAvatar_;
}

- (void) prepareReuse {
    hasAvatar_ = NO;
    loadAvatar_ = NO;
    
    // clear avatar before reuse
    // [self updateAvatar:nil];
}

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAvatarLoader delegate methods

// The sub-classes must override it
- (UIImage *) defaultAvatar {
    return nil;
}

/////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark utility methods

+ (void) loadImageSourceForTableView:(UITableView *)tableView withAvatarView:(KDAvatarView *)avatarView {
    if(!tableView.dragging && !tableView.decelerating){
        if(!avatarView.hasAvatar && !avatarView.loadAvatar){
            [avatarView setLoadAvatar:YES];
        }
    }
}

+ (void) loadImageSourceForTableView:(UITableView *)tableView {
    if(tableView.decelerating) return;
        
    NSArray *cells = [tableView visibleCells];
	if(cells != nil && [cells count] > 0){
        SEL selector = @selector(avatarView);
        for(UITableViewCell *cell in cells){
            
            // Generally speaking, We not need check every cell can perform avatarView selector.
            // sometimes, There are exist different cells in visible area.
            
            if([cell respondsToSelector:selector]) {
                KDAvatarView *avatarView = [cell performSelector:selector];
                if(!avatarView.hasAvatar && !avatarView.loadAvatar){
                    [avatarView setLoadAvatar:YES];
                }
            }
        }
    }
}


- (void) dealloc {
    
    //KD_RELEASE_SAFELY(avatarDataSource_);
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(maskView_);
    //KD_RELEASE_SAFELY(vipBadgeView_);
    
    //[super dealloc];
}

@end
