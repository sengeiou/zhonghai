//
//  KDPostActionMenuView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-22.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDPostActionMenuView.h"
#import "KDSession.h"

#import "QBAnimationSequence.h"
#import "QBAnimationGroup.h"
#import "QBAnimationItem.h"

@interface KDPostActionMenuView ()

@property (nonatomic, retain) CALayer *backgroundLayer;
@property (nonatomic, retain) NSArray *menuItems;


@property (nonatomic, retain) CALayer *thumbnailBGLayer;
@property (nonatomic, retain) CALayer *thumbnailLayer;
@property (nonatomic, retain) UIImageView *locationAnimationView;
@property (nonatomic, retain) QBAnimationSequence *sequence;
@property (nonatomic, assign) BOOL isLocationAnimating;

@end

@implementation KDPostActionMenuView

@synthesize delegate=delegate_;

@synthesize backgroundLayer=backgroundLayer_;
@synthesize menuItems=menuItems_;

@synthesize thumbnailBGLayer=thumbnailBGLayer_;
@synthesize thumbnailLayer=thumbnailLayer_;

@synthesize userInfo=userInfo_;

@synthesize locationAnimationView = vedioAnimationView_;
@synthesize sequence = sequence_;
@synthesize isLocationAnimating = isVedioAnimating_;

- (UIButton *)actionMenuButtonItemWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    
    button.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    image = [UIImage imageNamed:highlightedImageName];
    [button setImage:image forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(menuButtonItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIButton *)actionMenuButtonItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    
    button.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    image = [UIImage imageNamed:selectedImageName];
    [button setImage:image forState:UIControlStateSelected];
    
    [button addTarget:self action:@selector(menuButtonItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
- (void)setupPostActionMenuView {
    self.backgroundColor = [UIColor kdBackgroundColor1];
    
    // background image layer
    backgroundLayer_ = [CALayer layer] ;//retain];
    backgroundLayer_.contentsScale = [UIScreen mainScreen].scale;
    backgroundLayer_.backgroundColor = [UIColor kdBackgroundColor1].CGColor;
    [self.layer addSublayer:backgroundLayer_];
    UIImage *lineImage = [UIImage imageNamed:@"post_menu_line_v2.png"];
    lineImage = [lineImage stretchableImageWithLeftCapWidth:2 topCapHeight:1];
    UIImageView *separatorIV = [[UIImageView alloc] initWithImage:lineImage];
    separatorIV.frame = CGRectMake(0.0, 0.0f, self.frame.size.width, 1);
    [self addSubview:separatorIV];
//    [separatorIV release];
    // action menu items
    // and now, just use UIButton as menu item.
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:0x04];
    
    UIButton *actionBtn = [self actionMenuButtonItemWithImageName:@"post_menu_icon_locate.png" selectedImageName:@"post_menu_icon_locate_hl.png"];
    actionBtn.tag = KDPostActionMenuViewLocate;
    [self addSubview:actionBtn];
    [menuItems addObject:actionBtn];
    
    actionBtn = [self actionMenuButtonItemWithImageName:@"post_menu_icon_pic.png" highlightedImageName:@"post_menu_icon_pic_hl.png"];
    [actionBtn setImage:[UIImage imageNamed:@"post_menu_icon_pic_hl.png"] forState:UIControlStateSelected];
    actionBtn.tag = KDPostActionMenuViewPic;
    [self addSubview:actionBtn];
    [menuItems addObject:actionBtn];
    
    actionBtn = [self actionMenuButtonItemWithImageName:@"post_menu_icon_video.png" highlightedImageName:@"post_menu_icon_video_hl.png"];
    actionBtn.tag = KDPostActionMenuViewVideo;
    [actionBtn setImage:[UIImage imageNamed:@"post_menu_icon_video_hl.png"] forState:UIControlStateSelected];
    [self addSubview:actionBtn];
    [menuItems addObject:actionBtn];
    
    // at somebody
    actionBtn = [self actionMenuButtonItemWithImageName:@"post_menu_icon_at.png" highlightedImageName:@"post_menu_icon_at_hl.png"];
    actionBtn.tag = KDPostActionMenuViewAt;
    [self addSubview:actionBtn];
    [menuItems addObject:actionBtn];
    

    actionBtn = [self actionMenuButtonItemWithImageName:@"post_menu_icon_topic.png" highlightedImageName:@"post_menu_icon_topic_hl.png"];
    actionBtn.tag = KDPostActionMenuViewTopic;
    [self addSubview:actionBtn];
    [menuItems addObject:actionBtn];
    
    actionBtn = [self actionMenuButtonItemWithImageName:@"post_expression_btn.png" highlightedImageName:@"post_expression_btn.png"];
    actionBtn.tag = KDPostActionMenuViewExpression;
    [actionBtn setImage:[UIImage imageNamed:@"post_expression_btn_s.png"] forState:UIControlStateSelected];
    [self addSubview:actionBtn];
    [menuItems addObject:actionBtn];
    
    self.menuItems = menuItems;
//    [menuItems release];
    
//    // word limits label
   
    
    //[self setUpLocationAnimationView];
    
}


- (void)setUpVedioAnimationView {
    if (vedioAnimationView_ == nil) {
        isVedioAnimating_ = NO;
        vedioAnimationView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"post_menu_icon_video_hl_v2.png"]];
        vedioAnimationView_.userInteractionEnabled = NO;
        [self addSubview:vedioAnimationView_];
        UIButton *vedioBtn = [menuItems_ objectAtIndex:2];
        if (!vedioBtn.hidden) {
            vedioAnimationView_.center = vedioBtn.center;
        }
        vedioAnimationView_.hidden = YES;
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(VedioAnimationViewTapped:)];
        [vedioAnimationView_ addGestureRecognizer:rgzr];
//        [rgzr release];
    }
    
}

- (void)startVedioAnimation {
    UIButton *locationBtn =  (UIButton *)[self viewWithTag:KDPostActionMenuViewLocate];
    if (!locationBtn || locationBtn.hidden) {
      
        return;
    }
   
    id obj = [[KDSession globalSession] getPropertyForKey:KD_VEDIO_KEY fromMemoryCache:YES];
    if (!obj) {
        [[KDSession globalSession] saveProperty:@(YES) forKey:KD_VEDIO_KEY storeToMemoryCache:YES];
    }
      
    if ([[[KDSession globalSession] getPropertyForKey:KD_VEDIO_KEY
                                      fromMemoryCache:NO] boolValue]) {
    
        [self setUpVedioAnimationView];
        if (!isVedioAnimating_) {
            isVedioAnimating_ = YES;
            [self hiddeVedioBtn];
            vedioAnimationView_.hidden = NO;
            vedioAnimationView_.userInteractionEnabled = YES;
            if (sequence_ == nil) {
                QBAnimationItem *item1 = [QBAnimationItem itemWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                    vedioAnimationView_.transform = CGAffineTransformMakeScale(1.4, 1.4);
                }];
                
                QBAnimationItem *item2 = [QBAnimationItem itemWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^ {
                    vedioAnimationView_.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
                QBAnimationGroup *group1 = [QBAnimationGroup groupWithItems:@[item1]];
                QBAnimationGroup *group2 = [QBAnimationGroup groupWithItems:@[item2]];
                sequence_ = [[QBAnimationSequence alloc] initWithAnimationGroups:@[group1, group2] repeat:YES];
            }
            [sequence_ start];
        }
    }
}

//手动停止
- (void)explicitlyStopVedioAnimation {
    if (vedioAnimationView_ && isVedioAnimating_ && sequence_) {
          [[KDSession globalSession] saveProperty:@(NO) forKey:KD_VEDIO_KEY storeToMemoryCache:YES];
    }
       
    [self stopVedioAnimation];
    
}
- (void)stopVedioAnimation {
    if (vedioAnimationView_ && isVedioAnimating_ && sequence_) {
        DLog(@"stopLocatingAnimation....");
        isVedioAnimating_ = NO;
        [sequence_ stop];
        vedioAnimationView_.hidden = YES;
        [self showVedioBtn];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        delegate_ = nil;
        userInfo_ = nil;
        
        thumbnailBGLayer_ = nil;
        thumbnailLayer_ = nil;
        
        [self setupPostActionMenuView];
    }
    
    return self;
}

- (void)menuButtonItemAction:(UIButton *)button {
    button.selected = !button.selected;
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(postActionMenuView:clickOnMenuItem:)]){
        [delegate_ postActionMenuView:self clickOnMenuItem:button];
    }
}

- (UIButton *)menuButtonItemAtIndex:(NSUInteger)index {
    // check index is valid or not
    return (index >= [menuItems_ count]) ? nil : [menuItems_ objectAtIndex:index];
}

- (void)menuButtonWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage atIndex:(NSUInteger)index {
    UIButton *btn = [self menuButtonItemAtIndex:index];
    if(btn != nil){
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:highlightedImage forState:UIControlStateHighlighted];
    }
}

- (void)menuButtonItemEnabled:(BOOL)enabled atIndex:(NSUInteger)index {
    UIButton *btn = [self menuButtonItemAtIndex:index];
    if(btn != nil){
        btn.enabled = enabled;
    }
}

// chnage the visibility of menu item and need layout if need 
- (void)menuButtonItemHidden:(BOOL)hidden atIndex:(NSUInteger)index {
    UIButton *btn = [self menuButtonItemAtIndex:index];
    if(btn != nil){
        BOOL previous = btn.hidden;
        if (!!previous != !!hidden) {
            btn.hidden = hidden;
            
            [self setNeedsLayout];
        }
    }
}

- (NSUInteger)_numberOfVisibleMenuItems {
    NSUInteger count = 0;
    for (UIButton *btn in menuItems_) {
        if (btn.hidden) continue;
        
        count++;
    }
    
    return count;
}


//不用hidden = YES 是因为会影响布局，见layoutsubview
- (void)hideLocationBtn {
    UIButton *btn = [menuItems_ objectAtIndex:0];
    [btn setImage:nil forState:UIControlStateNormal];
    [btn setImage:nil forState:UIControlStateHighlighted];
}

- (void)showLocatonBtn {
    UIButton *btn = [menuItems_ objectAtIndex:0];
    [btn setImage:[UIImage imageNamed:@"post_menu_icon_locate_v2"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"post_menu_icon_locate_hl_v2"] forState:UIControlStateHighlighted];
}

- (void)hiddeVedioBtn {
    UIButton *btn = [menuItems_ objectAtIndex:2];
    [btn setImage:nil forState:UIControlStateNormal];
    [btn setImage:nil forState:UIControlStateHighlighted];
}

- (void)showVedioBtn {
    UIButton *btn = [menuItems_ objectAtIndex:2];
    [btn setImage:[UIImage imageNamed:@"post_menu_icon_video_v2"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"post_menu_icon_video_hl_v2"] forState:UIControlStateHighlighted];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    backgroundLayer_.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    
    [CATransaction commit];
    
    // action menu button items
    NSUInteger count = [self _numberOfVisibleMenuItems];
    CGFloat leftWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat separatWidth = 20;
    
    // if the menu items less than or equals 2, the make the menu align center
    CGFloat offsetX = 0.0;
    
    
    if (self.align == KDPostActionMenuViewAlignLeft) {
        CGFloat tempWidth = count * [(UIView *)[menuItems_ objectAtIndex:0] bounds].size.width+ separatWidth *(count -1);
        leftWidth = MIN(tempWidth, leftWidth);
        offsetX = 10;
    }
    else {
        
        if (count <= 0x02) {
            CGFloat adjustWidth = MIN(leftWidth, 200.0);
            offsetX = (leftWidth - adjustWidth) * 0.5;
            leftWidth = adjustWidth;
        }
    }
   
    CGFloat pw = leftWidth / count;
    
    NSInteger idx = 0;
    CGRect rect = CGRectZero;

    for (UIButton *btn in menuItems_) {
        if (btn.hidden) continue;
        
        rect = btn.bounds;
        rect.origin.x = offsetX + (pw * idx) + (pw - rect.size.width) * 0.5;
        
        btn.frame = rect;
        btn.center = CGPointMake(btn.center.x, self.bounds.size.height * 0.5f);
        idx++;
    }
    
    // word limits label
   
    
}

- (void)adjustPickedImageThunbmailFrame {
	if(thumbnailLayer_.contents != nil){
		thumbnailLayer_.frame = scaleRectToFitStage(thumbnailLayer_.bounds, thumbnailBGLayer_.bounds.size);
	}
}

- (void)pickedImageThumbnailVisible:(BOOL)visible content:(UIImage *)image {
    if(visible){
        UIButton *picBtn =  (UIButton *)[self viewWithTag:KDPostActionMenuViewPic];
        if (!picBtn||picBtn.hidden) {
            return;
        }

        if(thumbnailLayer_ == nil){
            // background layer
            thumbnailBGLayer_ = [CALayer layer];// retain];
            thumbnailBGLayer_.masksToBounds = YES;
            
            //CGFloat leftWidth = self.bounds.size.width - 40.0;
           // CGFloat pw = leftWidth / [menuItems_ count];
            CGRect rect = CGRectMake(picBtn.frame.origin.x-20, (self.bounds.size.height - 35.0)*0.5, 60.0, 35.0);

            thumbnailBGLayer_.frame = rect;
            thumbnailLayer_ = [CALayer layer] ;//retain];
            thumbnailLayer_.contentsScale = [UIScreen mainScreen].scale;
            
            [thumbnailBGLayer_ addSublayer:thumbnailLayer_];
            
            [self.layer addSublayer:thumbnailBGLayer_];
        }
        
        if(image != nil){
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            
            CGSize size = CGSizeMake(image.size.width, image.size.height);
            if(thumbnailLayer_.contentsScale+0.01 > 2.0){
                size.width = floorf(image.size.width*0.5);
                size.height = floorf(image.size.height*0.5);
            }
            thumbnailLayer_.bounds = CGRectMake(0.0, 0.0, size.width, size.height);
            thumbnailLayer_.contents = (id)image.CGImage;
            
            [self adjustPickedImageThunbmailFrame];
            
            [CATransaction commit];
        }
        
    }
    else {
        if(thumbnailLayer_ != nil){
            //KD_RELEASE_SAFELY(thumbnailLayer_);
        }
        
        if(thumbnailBGLayer_ != nil){
            if(thumbnailBGLayer_.superlayer != nil){
                [thumbnailBGLayer_ removeFromSuperlayer];
            }
            
            //KD_RELEASE_SAFELY(thumbnailBGLayer_);
        }
    }
}

- (void)VedioAnimationViewTapped:(UITapGestureRecognizer *)rgzr {
    [self explicitlyStopVedioAnimation];
    if(delegate_ && [delegate_ respondsToSelector:@selector(postActionMenuView:clickOnMenuItem:)]) {
        UIButton *btn = [menuItems_ objectAtIndex:2];
        [delegate_ postActionMenuView:self clickOnMenuItem:btn];
    }
   
}

- (void)setImageButtonHighlighted:(BOOL)highlighted
{
    UIButton *btn = (UIButton *)[self viewWithTag:KDPostActionMenuViewPic];
    btn.selected = highlighted;
}
- (void)setVideoHighlighted:(BOOL)highlighted
{
    UIButton *btn = (UIButton *)[self viewWithTag:KDPostActionMenuViewVideo];
    btn.selected = highlighted;
}
- (void)setExpressButtonHighlighted:(BOOL)highlighted
{
    UIButton *btn = (UIButton *)[self viewWithTag:KDPostActionMenuViewExpression];
    btn.selected = highlighted;
}
- (void)dealloc {
    delegate_ = nil;
    
    //KD_RELEASE_SAFELY(userInfo_);
    
    //KD_RELEASE_SAFELY(backgroundLayer_);
    //KD_RELEASE_SAFELY(menuItems_);

    //KD_RELEASE_SAFELY(thumbnailLayer_);
    //KD_RELEASE_SAFELY(thumbnailBGLayer_);
    
    //KD_RELEASE_SAFELY(vedioAnimationView_);
    [sequence_ stop];
    //KD_RELEASE_SAFELY(sequence_);
    
    //[super dealloc];
}

@end
