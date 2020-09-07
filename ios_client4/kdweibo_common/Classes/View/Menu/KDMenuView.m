//
//  KDMenuView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDMenuView.h"

#import "KDLeftNavBadgeIndicatorView.h"
#define MAX_NUM_IN_TOOLBAR 5
@interface KDMenuView()<UIActionSheetDelegate>

@property(nonatomic, retain) NSMutableArray *dividers;
@property(nonatomic, retain) NSMutableArray *badgeViews;

@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain) NSMutableArray *itemsInToolBar;
@property(nonatomic, retain) NSMutableArray *itemsInActionSheet;

@property(nonatomic, retain) KDMenuItem *moreMenuItem;

- (void)removeDeprecatedMenuItems;
- (void)resetMenuItems:(NSArray *)menuItems;

@end

@implementation KDMenuView

@synthesize delegate=delegate_;

@synthesize backgroundImageView=backgroundImageView_;

@dynamic menuItems;

@synthesize dividers=dividers_;
@dynamic dividerImage;

@synthesize badgeViews=badgeViews_;
@synthesize eachBadgeViewTROffset=eachBadgeViewTROffset_;

@synthesize drawRectBlock=drawRectBlock_;

@synthesize itemsInActionSheet = itemsInActionSheet_;
@synthesize itemsInToolBar = itemsInToolBar_;
@synthesize moreMenuItem = moreMenuItem_;

- (UIButton *) buttonWithTitle:(NSString *)title image:(UIImage *)image atIndex:(NSUInteger)index {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(title != nil){
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btn setTitle:title forState:UIControlStateNormal];
    }
    
    if(image != nil){
        [btn setImage:image forState:UIControlStateNormal];
        
    }
    
    if(delegate_ != nil && [delegate_ respondsToSelector:@selector(menuView:configMenuButton:atIndex:)]){
        [delegate_ menuView:self configMenuButton:btn atIndex:index];
    }
    
    [btn addTarget:self action:@selector(menuButtonFire:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)setupWithDataSource:(NSArray *)dataSource {
    if(dataSource != nil && [dataSource count] > 0){
        NSUInteger count = [dataSource count];
        
        NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:count];
        
        NSString *str = nil;
        UIImage *image = nil;
        KDMenuItem *menuItem = nil;
        
        NSInteger idx = 0;
        for(id obj in dataSource){
            str = nil;
            image = nil;
            
            if([obj isKindOfClass:[NSString class]]){
                str = (NSString *)obj;
                
            }else if([obj isKindOfClass:[UIImage class]]){
                image = (UIImage *)obj;
            }
            if ([obj isKindOfClass:[NSDictionary class]]) {
                str = [(NSDictionary *)obj  objectForKey:@"title"];
                image = [(NSDictionary *)obj objectForKey:@"image"];
            }

             UIButton *btn = [self buttonWithTitle:str image:image atIndex:idx++];
             btn.hidden = NO;
             menuItem = [[KDMenuItem alloc] initWithCustomView:btn];
             [menuItem setProperty:str forKey:@"title"];
             menuItem.menuView = self;
            
            [menuItems addObject:menuItem];
//            [menuItem release];
        }
        
        // remove deprecate menu items if need
        [self removeDeprecatedMenuItems];
        
        menuItems_ = [[NSArray alloc] initWithArray:menuItems];
       
    }
}

- (void)didMoveToSuperview {
     [self updateVisible];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        eachBadgeViewTROffset_ = CGPointZero;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<KDMenuViewDelegate>)delegate titles:(NSArray *)titles {
    self = [self initWithFrame:frame];
    if(self){
        delegate_ = delegate;
        [self setupWithDataSource:titles];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<KDMenuViewDelegate>)delegate images:(NSArray *)images {
    self = [self initWithFrame:frame];
    if(self){
        delegate_ = delegate;
        [self setupWithDataSource:images];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems {
    self = [self initWithFrame:frame];
    if(self){
        [self resetMenuItems:menuItems];
    }
    
    return self;
}

- (void)layoutBackgroundImageView {
    CGFloat height = backgroundImageView_.bounds.size.height;
    backgroundImageView_.frame = CGRectMake(0.0, self.bounds.size.height - height, self.bounds.size.width, height);
}  
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(backgroundImageView_ != nil){
        [self layoutBackgroundImageView];
    }
    
    /*
    if(menuItems_ != nil){
        // calculate how many buttons not hide now
        NSUInteger count = 0;
        for(KDMenuItem *item in menuItems_){
            if(!item.customView.hidden){
                count++;
            }
        }
        
        if(count > 0){
            BOOL hasDividers = (count > 1 && (dividers_ != nil && [dividers_ count] > 0)) ? YES : NO;
            
            CGFloat pw = self.bounds.size.width / count;
            NSInteger idx = 0;
            CGRect rect = CGRectZero;
            for(KDMenuItem *item in menuItems_){
                // skip the menu item that it's hidden now
                if(item.customView.hidden) continue;
                
                rect = CGRectMake(pw * idx, 0.0, pw, self.bounds.size.height);
                item.customView.frame = rect;
                
                // dividers
                if(hasDividers && (idx != count - 1)) {
                    UIImageView *imageView = [dividers_ objectAtIndex:idx];
                    imageView.frame = CGRectMake(idx * pw + pw, 0.0, imageView.bounds.size.width, self.bounds.size.height);
                }
                
                idx++;
            }
            
            // badge views
            if(badgeViews_ != nil && [badgeViews_ count] > 0){
                idx = 0;
                KDLeftNavBadgeIndicatorView *badgeView = nil;
                for(id obj in badgeViews_){
                    idx++;
                    if(obj == [NSNull null]) continue;
                    
                    badgeView = (KDLeftNavBadgeIndicatorView *)obj;
                    if([badgeView count] > 0){
                        CGSize size = badgeView.frame.size;
                        rect = CGRectMake((idx - 1) * pw + pw - size.width - eachBadgeViewTROffset_.x,
                                          0.0 + eachBadgeViewTROffset_.y, size.width, size.height);
                        badgeView.frame = rect;
                        badgeView.center = CGPointMake(self.bounds.size.width * 0.5f, badgeView.center.y);
                    }
                }
            }
            
        }
    }
     */
    
    if ([self.itemsInToolBar count] >0) {
        //
        
      //  BOOL hasDividers = (dividers_ != nil && [dividers_ count] > 0) ? YES : NO;
        CGFloat pw = self.bounds.size.width / [self.itemsInToolBar count];
        NSInteger idx = 0;
        NSInteger idx2 = 0;
        CGRect rect = CGRectZero;
        UIImageView *divider = nil;
        id obj = nil;
        KDLeftNavBadgeIndicatorView *badge = nil;
        for (KDMenuItem *item in self.itemsInToolBar) {
            rect = CGRectMake(pw * idx, self.offSetY, pw, self.bounds.size.height - self.offSetY);
            item.customView.frame = rect;
    
            divider = [self dividerAtIndex:idx];
            rect = CGRectMake(idx * pw + pw, 0.0, divider.bounds.size.width, self.bounds.size.height);
            divider.frame = rect;
            if ([badgeViews_ count] >0) {
                idx2 = [menuItems_ indexOfObject:item];
                if (idx2 != NSNotFound) {
                     obj = [badgeViews_ objectAtIndex:idx2];
                    if (![obj isKindOfClass:[NSNull class]]) {
                        badge = obj;
                        rect = CGRectMake(idx * pw + pw - badge.bounds.size.width - eachBadgeViewTROffset_.x,
                                          0.0 + eachBadgeViewTROffset_.y, badge.bounds.size.width, badge.bounds.size.height);
                        [badge setFrame:rect];
                    }
                }
            }
          
            
            idx++;
        }
    }
}

- (void)drawRect:(CGRect)rect {
    if(drawRectBlock_ != nil){
        drawRectBlock_(UIGraphicsGetCurrentContext(), rect);
    }
}

- (void)setMenuItems:(NSArray *)menuItems {
    if(menuItems_ != menuItems){
        // remove deprecated menu items from menu view
       // [self removeDeprecatedMenuItems];
        
        BOOL isMenuItemInstance = NO;
        if(menuItems != nil && [menuItems count] > 0){
            id obj = [menuItems objectAtIndex:0x00];
            if([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[UIImage class]]|| [obj isKindOfClass:[NSDictionary class]]){
                [self setupWithDataSource:menuItems];
            
            }else {
                isMenuItemInstance = YES;
            }
            
        }else {
            isMenuItemInstance = YES;
        }
        
        // The KDMenuItem instance
        if(isMenuItemInstance){
            [self resetMenuItems:menuItems];
        }
    }
}

- (NSArray *)menuItems {
    return menuItems_;
}

- (void)removeDeprecatedMenuItems {
    if(menuItems_ != nil){
        // remove old menu items from menu view
        for(KDMenuItem *item in menuItems_){
            if(item.customView.superview != nil){
                [item.customView removeFromSuperview];
            }
        }
        
//        [menuItems_ release];
    }
}

- (void)resetMenuItems:(NSArray *)menuItems {
    DLog(@"resetMenuItems");
    menuItems_ = menuItems ;//retain];
    
    if(menuItems_ != nil){
        for(KDMenuItem *item in menuItems_){
            item.menuView = self;
        }
    }
    //[self updateVisible];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if(backgroundImage != nil){
        // change background image
        if(backgroundImageView_ == nil){
            backgroundImageView_ = [[UIImageView alloc] initWithImage:backgroundImage];
            [backgroundImageView_ sizeToFit];
            
            
            [self insertSubview:backgroundImageView_ atIndex:0x00];
        }
        
        if(self.superview != nil){
            [self layoutBackgroundImageView];
        }
        
    }else {
        // remove background image
        if(backgroundImageView_ != nil){
            if(backgroundImageView_.superview != nil){
                [backgroundImageView_ removeFromSuperview];
            }
            
            //KD_RELEASE_SAFELY(backgroundImageView_);
        }
    }
}

- (void)setDividerImage:(UIImage *)dividerImage {
    if(dividerImage_ != dividerImage){
//        [dividerImage_ release];
        dividerImage_ = dividerImage;// retain];
        if ([self.dividers count]>0) {
            [self.dividers removeAllObjects];
            [self.dividers makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
       
       
        
        
      /*
        // setup dividers if need
        if(dividerImage_ != nil){
            // dividers
            NSUInteger count = [menuItems_ count];
            if (count > 1) {
                if(dividers_ == nil) {
                    dividers_ = [[NSMutableArray alloc] initWithCapacity:count - 1];
                }
                
                NSInteger idx = 0;
                UIImageView *imageView = nil;
                for(; idx < count - 1; idx++){
                    imageView = [[UIImageView alloc] initWithImage:dividerImage_];
                    imageView.bounds = CGRectMake(0.0, 0.0, dividerImage_.size.width, dividerImage_.size.height);
                    
                    [self addSubview:imageView];
                    [dividers_ addObject:imageView];
                    [imageView release];
                }
            }
            if([self.itemsInToolBar count] >0) {
              
            }
        }else {
            // remove dividers from super view
            [dividers_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            //KD_RELEASE_SAFELY(dividers_);
        }
        */
        
//        if ([self.dividers count] >0) {
//            [self.dividers removeAllObjects];
//            [dividers_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        }
//        if (dividerImage_) {
//            if ([self.itemsInToolBar count] >0) {
//                <#statements#>
//            }
//        }
//        
//        [self setNeedsLayout];
    }
}

- (UIImageView *)dividerAtIndex:(NSUInteger)indx {
    if (!dividerImage_) {
        return nil;
    }
    UIImageView *imageView = nil;
    if (indx >= [self.dividers count]){
            imageView = [[UIImageView alloc] initWithImage:dividerImage_];
            imageView.bounds = CGRectMake(0.0, 0.0, dividerImage_.size.width, dividerImage_.size.height);
            [self addSubview:imageView];
            [dividers_ addObject:imageView];
//            [imageView release];

    }else {
        imageView = [dividers_ objectAtIndex:indx];
    }
    return imageView;
}

- (UIImage *)dividerImage {
    return dividerImage_;
}

- (BOOL)isValidMenuIndex:(NSUInteger)index {
    return (menuItems_ != nil && index < [menuItems_ count]) ? YES : NO;
}

- (void)setMenuVisibility:(BOOL)visibility atIndex:(NSUInteger)index {
    if([self isValidMenuIndex:index]){
        KDMenuItem *menuItem = [menuItems_ objectAtIndex:index];
        
        // check the attribute is same as before, If YES, do nothing
        menuItem.customView.hidden = visibility ? NO : YES;
        
       // [self setNeedsLayout];
        //[self updateVisible];
        //[self setNeedsDisplay];
    }
}

- (void)setMenuEnabled:(BOOL)enabled atIndex:(NSUInteger)index {
    if([self isValidMenuIndex:index]){
        KDMenuItem *menuItem = [menuItems_ objectAtIndex:index];
        if([menuItem.customView isKindOfClass:[UIControl class]]){
             ((UIControl *)menuItem.customView).enabled = enabled;
        }
    }
}

- (void)showBadgeValue:(NSUInteger)badgeValue atIndex:(NSUInteger)index {
    if([self isValidMenuIndex:index]){
        // setup badge view placeholder if need
        if(badgeViews_ == nil){
            NSUInteger count = [menuItems_ count];
            badgeViews_ = [[NSMutableArray alloc] initWithCapacity:count];
            NSInteger idx = 0;
            for(; idx < count; idx++){
                [badgeViews_ addObject:[NSNull null]];
            } 
        }
        
        KDLeftNavBadgeIndicatorView *badgeIndicatorView = nil;
        
        id obj = [badgeViews_ objectAtIndex:index];
        if(obj == [NSNull null]){
            badgeIndicatorView = [[KDLeftNavBadgeIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 28)];
            badgeIndicatorView.userInteractionEnabled = NO;
            
            [self addSubview:badgeIndicatorView];
            
            [badgeViews_ replaceObjectAtIndex:index withObject:badgeIndicatorView];
//            [badgeIndicatorView release];
            
        }else {
            badgeIndicatorView = (KDLeftNavBadgeIndicatorView *)obj;
        }
        
        [self bringSubviewToFront:badgeIndicatorView];
        badgeIndicatorView.count = badgeValue;
        
        [self setNeedsLayout];
    }
}

- (KDMenuItem *)menuItemAtIndex:(NSUInteger)index {
    KDMenuItem *menuItem = nil;
    if([self isValidMenuIndex:index]){
        menuItem = [menuItems_ objectAtIndex:index];
    }
    
    return menuItem;
}

- (KDMenuItem *)menuItembyTitle:(NSString *)title {
    __block KDMenuItem *menuItem = nil;
    [self.menuItems enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop) {
        if ([[obj propertyForKey:@"title"] isEqualToString:title]) {
            menuItem = obj;
            *stop = YES;
        }
    }];
    return menuItem;
}
- (void)menuButtonFire:(UIButton *)btn {
    NSInteger idx = NSNotFound; // initialized as invalid index
    KDMenuItem *targetItem = nil;
    for(KDMenuItem *item in menuItems_){
        if(item.customView == btn){
            idx = [menuItems_ indexOfObject:item];
            targetItem = item;
            
            break;
        }
    }
    
    if(NSNotFound != idx){
        if(delegate_ != nil && [delegate_ respondsToSelector:@selector(menuView:clickedMenuItemAtIndex:)]){
            [delegate_ menuView:self clickedMenuItemAtIndex:idx];
        }
        
        [self didClickAtMenuItem:targetItem atIndex:idx];
    }
}

// do nothing, it should override by sub-classes
- (void)didClickAtMenuItem:(KDMenuItem *)menuItem atIndex:(NSUInteger)index {
    
}

- (NSMutableArray *)itemsInToolBar {
    if (!itemsInToolBar_) {
        itemsInToolBar_ = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return itemsInToolBar_;
}

- (NSMutableArray*)itemsInActionSheet {
    if(!itemsInActionSheet_) {
        itemsInActionSheet_ = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return itemsInActionSheet_;
}

- (NSMutableArray *)dividers {
    if(!dividers_) {
        dividers_ = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return dividers_;
}

- (void)updateVisible {
    NSMutableArray *visibles = [[NSMutableArray alloc] initWithCapacity:0];// autorelease];
    for (KDMenuItem *item in menuItems_) {
        if (!((UIButton *)(item.customView)).hidden) {
            [visibles addObject:item];
        }
    }
    if ([visibles count] < 1) {
        return;
    }
    [self.itemsInToolBar removeAllObjects];
    [self.itemsInActionSheet removeAllObjects];
    if (self.enableMoreButton) {
        if ([visibles count] > MAX_NUM_IN_TOOLBAR) {
            [self.itemsInToolBar addObjectsFromArray:[visibles subarrayWithRange:NSMakeRange(0, MAX_NUM_IN_TOOLBAR-1)]];
            [self.itemsInToolBar addObject:self.moreMenuItem];
           
            [self.itemsInActionSheet addObjectsFromArray:[visibles subarrayWithRange:NSMakeRange(MAX_NUM_IN_TOOLBAR-1, [visibles count] -MAX_NUM_IN_TOOLBAR+1)]];
            
        }else {
            [self.itemsInToolBar addObjectsFromArray:visibles];
        }
    }else {
        [self.itemsInToolBar addObjectsFromArray:visibles];
    }
   // [self setUpActionSheet];
    //[self setNeedsLayout];
    
}

- (void)setUpActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_choice")delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    NSString *title = nil;
    for (KDMenuItem *item in self.itemsInActionSheet) {
        title = [item propertyForKey:@"title"];
        [actionSheet addButtonWithTitle:title];
        if ([title isEqualToString:ASLocalizedString(@"KDCommentCell_delete")]) {
            NSUInteger indx = [self.itemsInActionSheet indexOfObject:item];
            NSLog(@"delete index = %lu",(unsigned long)indx);
            [actionSheet setDestructiveButtonIndex:indx];
        }
    }
    [actionSheet addButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
    actionSheet.cancelButtonIndex = [self.itemsInActionSheet count];
    [actionSheet showInView:self];
//    [actionSheet release];
}

- (KDMenuItem *)moreMenuItem {
    if (!moreMenuItem_) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 40, self.bounds.size.height);
        [btn addTarget:self action:@selector(setUpActionSheet) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"tool_bar_more"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"tool_bar_more_hl"] forState:UIControlStateHighlighted];
        [self addSubview:btn];
        moreMenuItem_ = [[KDMenuItem alloc] initWithCustomView:btn];
        //[self addSubview:moreMenuItem_];
    }
    return moreMenuItem_;
}
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger indexInAction = buttonIndex;  // 0 for cancle btn
    if (indexInAction>=0 && indexInAction < [itemsInActionSheet_ count]) {
        KDMenuItem *item = [itemsInActionSheet_ objectAtIndex:indexInAction];
        if (item) {
            UIButton *btn = (UIButton *)[item customView];
            [self menuButtonFire:btn];
        }
    }
}

- (BOOL)isMenuItemInMore:(NSInteger)index {
    BOOL is = NO;
    KDMenuItem *item = nil;
    if ( menuItems_ && [menuItems_ count] >0&& index >=0 &&index < [menuItems_ count] ) {
        item = [menuItems_ objectAtIndex:index];
        if (item) {
            is = [self.itemsInActionSheet containsObject:item];
        }
    }
    return is;
   
}

- (BOOL)isMenuItemInToolBar:(NSInteger)index {
    BOOL is = NO;
    KDMenuItem *item = nil;
    if ( menuItems_ && [menuItems_ count] >0&& index >=0 &&index < [menuItems_ count] ) {
        item = [menuItems_ objectAtIndex:index];
        if (item) {
            is = [self.itemsInToolBar containsObject:item];
        }
    }
    return is;
}

- (void)dealloc {
    delegate_ = nil;
    //KD_RELEASE_SAFELY(drawRectBlock_);
    
    //KD_RELEASE_SAFELY(backgroundImageView_);
    
    //KD_RELEASE_SAFELY(menuItems_);
    
    //KD_RELEASE_SAFELY(dividers_);
    //KD_RELEASE_SAFELY(dividerImage_);
    
    //KD_RELEASE_SAFELY(badgeViews_);
    
    //KD_RELEASE_SAFELY(itemsInToolBar_);
    //KD_RELEASE_SAFELY(itemsInActionSheet_);
    //KD_RELEASE_SAFELY(moreMenuItem_);
    //[super dealloc];
}

@end
