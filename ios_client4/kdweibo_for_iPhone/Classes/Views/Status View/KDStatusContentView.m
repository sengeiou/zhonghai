//
//  KDStatusContentView.m
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusContentView.h"

#define KD_TIMELNNE_STATUS_CONTENT_TOP_MARGIN    12.0
#define KD_TIMELNNE_STATUS_CONTENT_BOTTOM_MARGIN    8.0
#define KD_TIMELNNE_STATUS_CONTENT_SPACING    7.0


@interface KDStatusContentView ()

@property(nonatomic, retain) KDStatusHeaderView *headerView;
@property(nonatomic, retain) KDStatusBodyView *bodyView;
@property(nonatomic, retain) KDStatusFooterView *footerView;

@end


@implementation KDStatusContentView

@synthesize headerView=headerView_;
@synthesize bodyView=bodyView_;
@synthesize footerView=footerView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStatusContentView];
    }
    
    return self;
}

- (void)setupStatusContentView {
    // header
    headerView_ = [[KDStatusHeaderView alloc] initWithFrame:CGRectZero];
    [self addSubview:headerView_];
    
    // body
    bodyView_ = [[KDStatusBodyView alloc] initWithFrame:CGRectZero];
    [self addSubview:bodyView_];
    
    // footer
    footerView_ = [[KDStatusFooterView alloc] initWithFrame:CGRectZero];
    [self addSubview:footerView_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 0.0;
    CGFloat offsetY = KD_TIMELNNE_STATUS_CONTENT_TOP_MARGIN;
    CGFloat width = self.bounds.size.width;
    CGRect rect = CGRectZero;
    
    CGFloat headerHeight = [KDStatusHeaderView optimalStatusHeaderHeight];
    CGFloat footerHeight = [KDStatusFooterView optimalStatusFooterHeight];
    
    // header
    rect = CGRectMake(offsetX, offsetY, width, headerHeight);
    headerView_.frame = rect;
    offsetY += rect.size.height;
    
    // spacing
    offsetY += KD_TIMELNNE_STATUS_CONTENT_SPACING;
    
    // body
    CGFloat bottomDistance = KD_TIMELNNE_STATUS_CONTENT_SPACING + footerHeight + KD_TIMELNNE_STATUS_CONTENT_BOTTOM_MARGIN;
    CGFloat height = self.bounds.size.height - offsetY - bottomDistance;
    rect = CGRectMake(offsetX, offsetY, width, height);
    bodyView_.frame = rect;
    
    // footer
    offsetY = self.bounds.size.height - footerHeight - KD_TIMELNNE_STATUS_CONTENT_BOTTOM_MARGIN;
    footerView_.frame = CGRectMake(offsetX, offsetY, width, footerHeight);
}

- (void)updateWithStatus:(KDStatus *)status {
    [headerView_ updateWithStatus:status];
    bodyView_.status = status;
    [footerView_ updateWithStatus:status];
    
    [self setNeedsLayout];
}

#define KD_TIMELINE_STATUS_CONTENT_HEIGHT   @"timeline_status_height"
+ (CGFloat)calculateStatusContentHeight:(KDStatus *)status bodyViewPosition:(KDStatusBodyViewDisplayPosition)p {
    CGFloat height = 0.0;
    NSNumber *obj = [status propertyForKey:KD_TIMELINE_STATUS_CONTENT_HEIGHT];
    if (obj == nil) {
        // margin top
        height += KD_TIMELNNE_STATUS_CONTENT_TOP_MARGIN;
        
        // header height
        height += [KDStatusHeaderView optimalStatusHeaderHeight];
        
        // spacing
        height += KD_TIMELNNE_STATUS_CONTENT_SPACING;
        
        // body height (excepted thumbnail)
        height += [KDStatusBodyView calculateStatusBodyHeight:status bodyViewPosition:p];
        
        // spacing
        height += KD_TIMELNNE_STATUS_CONTENT_SPACING;
        
        // footer height
        height += [KDStatusFooterView optimalStatusFooterHeight];
        
        // margin bottom
        height += KD_TIMELNNE_STATUS_CONTENT_BOTTOM_MARGIN;
        
        height = MAX(height, 67.0); // the minimal limits (67) means the avatar height with top and bottom margin
        
        obj = [NSNumber numberWithFloat:height];
        [status setProperty:obj forKey:KD_TIMELINE_STATUS_CONTENT_HEIGHT];
        
    } else {
        height = [obj floatValue];
    }
    
    if ((KDTimelinePresentationPatternImagePreview == [KDSession globalSession].timelinePresentationPattern)
        && [status hasExtraImageSource] && status.extendStatus == nil) {
        // thumbnail height
        height += [KDStatusBodyView calculateStatusBodyThumbnailHeight:status];
    } else if ((KDTimelinePresentationPatternImagePreview == [KDSession globalSession].timelinePresentationPattern)
                 && [status hasExtraImageSource] && status.extendStatus != nil) { //从新浪转过来的差了20像素
        // thumbnail height
        height += [KDStatusBodyView calculateStatusBodyThumbnailHeight:status] + 20.f;
    }
    
    return height;
}

+ (CGFloat)calculateStatusContentHeight:(KDStatus *)status {
    return [self calculateStatusContentHeight:status bodyViewPosition:KDStatusBodyViewDisplayPositionNormal];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(headerView_);
    //KD_RELEASE_SAFELY(bodyView_);
    //KD_RELEASE_SAFELY(footerView_);
    
    //[super dealloc];
}

@end
