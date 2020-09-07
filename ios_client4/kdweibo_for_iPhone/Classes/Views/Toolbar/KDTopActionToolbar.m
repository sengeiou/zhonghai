//
//  KDTopActionToolbar.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-19.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTopActionToolbar.h"
#import <QuartzCore/QuartzCore.h>
#import "KDNavigationMenuItem.h"

#define KD_TITLE_PARTITION @"!@#$%^&*"

@interface KDTopActionToolbar()
@property(nonatomic,retain)NSMutableArray *toolbarItems;

@end

@implementation KDTopActionToolbar
@synthesize dataSource = dataSource_;
@synthesize delegate = delgate_;
@synthesize toolbarItems = toolbarItems_;
@synthesize selectedIndex = selectedIndex_;

- (void)dealloc {
  
    //KD_RELEASE_SAFELY(dataSource_);
    //KD_RELEASE_SAFELY(toolbarItems_);
    //[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        CALayer * layer = [self layer];
        [layer setShadowOffset: CGSizeMake(0, 1)];
        [layer setShadowColor:[[UIColor grayColor] CGColor]];
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 1.0;
        selectedIndex_ = 0;
     
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (toolbarItems_) {
        //
        NSInteger count = [toolbarItems_ count];
        CGFloat width = CGRectGetWidth(self.bounds)/count;
        CGFloat offsetX = 0;
        CGFloat offsetY = 0;
        UIView *view = nil;
        for (NSInteger i = 0; i< count; i++) {
            view = toolbarItems_[i];
            offsetX = i*width+width*0.5;
            offsetY = CGRectGetHeight(self.bounds) *0.5;
            view.center = CGPointMake(offsetX, offsetY);
        }
    }
}

- (void)setDataSource:(NSArray *)dataSource {
//    if (dataSource_) {
//        [dataSource_ release];
//    }
    dataSource_ = dataSource;// retain];
    UIButton *button;
    for (KDNavigationMenuItem *item in dataSource) {
        button = [self normalToolBarItemsWithImageName:item.imageName highlightImageName:item.selectedImageName text:item.title];
       
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        if (!toolbarItems_) {
            toolbarItems_ = [[NSMutableArray alloc] init];
        }
         [toolbarItems_ addObject:button];
    }
}
- (void)updateTitleColor
{
    NSArray *colors = @[UIColorFromRGB(0x9196a4),UIColorFromRGB(0x1a85ff),UIColorFromRGB(0xff6600),UIColorFromRGB(0x20c000)];
    for (int i=0; i< [toolbarItems_ count]; i++) {
        
        UIButton *button = [toolbarItems_ objectAtIndex:i];
        
        if (i< [colors count])
            [button setTitleColor:[colors objectAtIndex:i] forState:UIControlStateSelected];
    }
}

- (void)show:(void(^)(void))completionBlock {
    [self updateBtnState];
    __block CGRect frame = self.bounds;
    frame.origin = CGPointMake(0, -CGRectGetHeight(frame));
    self.frame = frame;

    [UIView animateWithDuration:0.3f animations:^(void) {
                frame.origin = CGPointMake(0, 0);
                self.frame = frame;
        
    } completion:^(BOOL finish) {
        if (finish && completionBlock) {
             completionBlock();
        }
    }];
    
}

- (void)hide:(void(^)(void))completionBlock  {
        __block CGRect frame = self.bounds;
        
        [UIView animateWithDuration:0.3f animations:^(void) {
            frame.origin = CGPointMake(0, -CGRectGetHeight(frame)-2);
            self.frame = frame;
            
        } completion:^(BOOL finish) {
            if (finish && completionBlock) {
                completionBlock();
            }
        }];
}

- (void)updateBtnState {
    for (UIButton * btn in toolbarItems_) {
        btn.selected = ([toolbarItems_ indexOfObject:btn] == selectedIndex_);
    }
}
- (void)buttonTapped:(id)sender {
    NSInteger index = [toolbarItems_ indexOfObject:sender];
    selectedIndex_ = index;
    [self updateBtnState];
    if (delgate_ && [delgate_ respondsToSelector:@selector(topActionToolBar:didSelectAtIndex:)]) {
        [delgate_ topActionToolBar:self didSelectAtIndex:index];
    }
}


-(UIButton *)normalToolBarItemsWithImageName:(NSString *)imageName highlightImageName:(NSString *)highlightImageName text:(NSString *)text{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds= CGRectMake(0, 0, 52, 60);
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *hightImage = [UIImage imageNamed:highlightImageName];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:hightImage forState:UIControlStateSelected];
    [button setImageEdgeInsets:UIEdgeInsetsMake(-9, 4, 0, 0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(56, -42, 0, 0)];
    [button  setTitleColor:[UIColor colorWithRed:18/255.0f green:110/255.0f blue:254/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [button  setTitleColor:[UIColor colorWithRed:97/255.0f green:97/255.0f blue:97/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    NSArray *titles = [text componentsSeparatedByString:KD_TITLE_PARTITION];
    if ([titles count]>1)
        [button setTitle:[titles objectAtIndex:1] forState:UIControlStateNormal];
    else
        [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11.5f];
    //[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    return button;
}

@end
