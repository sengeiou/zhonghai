//
//  KDSelectionView.m
//  kdweibo_common
//
//  Created by shen kuikui on 12-9-28.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDSelectionView.h"

@interface KDSelectionView ()
{
    NSInteger selectedIndex_;
}

@end


@implementation KDSelectionView

@synthesize delegate=delegate_;
@synthesize dataSource=dataSource_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        selectedIndex_ = -1;
    }
    return self;
}


- (void)dealloc {
    //[super dealloc];
}

- (void)setDataSource:(id<KDSelectionViewDataSource>)dataSource {
    dataSource_ = dataSource;
    
    //once we got datasource, begin to init views
    [self setUpView];
}

- (id<KDSelectionViewDataSource>)dataSource {
    return dataSource_;
}

- (UIView *)cursorView {
    if([self viewWithTag:88])
        return [self viewWithTag:88];
    
    //else
    if(dataSource_ && [dataSource_ respondsToSelector:@selector(cursorViewForKDSelectionView:)]) {
        return [dataSource_ cursorViewForKDSelectionView:self];
    }
    
    //else
    UIView *cursor = [[UIView alloc] initWithFrame:CGRectZero];
    [cursor setBackgroundColor:[UIColor blackColor]];
    
    return cursor;// autorelease];
}

- (NSInteger)numberOfButtons {
    if(dataSource_ && [ dataSource_ respondsToSelector:@selector(numberOfSectionsInKDSelectionView:)]) {
        return [dataSource_ numberOfSectionsInKDSelectionView:self];
    }
    
    //else
    return 0;
}

- (NSString *)titleForButtonAtIndex:(NSInteger)index {    
    if(dataSource_ && [dataSource_ respondsToSelector:@selector(kdSelectionView:titleForButtonAtIndex:)]) {
        return [dataSource_ kdSelectionView:self titleForButtonAtIndex:index];
    }
    
    return nil;
}

- (void)setUpView {
    if([self numberOfButtons] == 0) return;
    
    [self setClipsToBounds:YES];
    
    CGPoint padding = CGPointMake(5.0f, 5.0f);
    
    for(int index = 0; index < [self numberOfButtons]; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = [self titleForButtonAtIndex:index];
        UIFont *font = [UIFont systemFontOfSize:12.0f];
        CGSize titleSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(1000, self.frame.size.height - 2 * padding.y - 2.0f)];
        
        [button.titleLabel setFont:font];
        [button.titleLabel setText:title];
        
        [button setFrame:CGRectMake(padding.x, padding.y, titleSize.width, titleSize.height)];
        [button setTag:index + 100];
        
        padding.x += (titleSize.width + 5.0f);
        
        [self addSubview:button];
    }
    
    UIView *cursorView = [self cursorView];
    cursorView.tag = 88;
    [self addSubview:cursorView];

    //默认选中第一个按钮
    [self clickButtonAtIndex:0];
}

- (void)btnClicked:(id)sender {
    [self clickButtonAtIndex:[(UIView *)sender tag] - 100];
    
    if(delegate_ && [delegate_ respondsToSelector:@selector(kdselectionView:didSelectButtonAtIndex:)]) {
        [delegate_ kdselectionView:self didSelectButtonAtIndex:[(UIButton *)sender tag]];
    }
}

- (void)clickButtonAtIndex:(NSInteger)index {
    if(index == selectedIndex_) return;
    
    if(selectedIndex_ != -1) {
        UIButton *lastSelectedButton = (UIButton *)[self viewWithTag:selectedIndex_];
        [lastSelectedButton.titleLabel setTextColor:[UIColor darkTextColor]];
    }
    
    selectedIndex_ = index + 100;
    
    UIButton *currentSelectedButton = (UIButton *)[self viewWithTag:selectedIndex_];
    [currentSelectedButton.titleLabel setTextColor:[UIColor colorWithRed:17/255.0f green:127/255.0f blue:182/255.0f alpha:1.0]];
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        [[self cursorView] setFrame:CGRectMake(currentSelectedButton.frame.origin.x, self.frame.size.height - 5.0f, self.frame.size.width, 5.0f)];
    }];
}

@end
