//
//  LeveyTabBar.m
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import "LeveyTabBar.h"

@class BtnView;

@protocol BtnViewDelegate <NSObject>
- (void)singleTapBegin:(BtnView *)view;
- (void)singleTapFire:(BtnView *)view;
- (void)doubleTapFire:(BtnView *)view;
@end

@interface BtnView : UIView
@property (nonatomic, assign) id <BtnViewDelegate> delegate;
@property (nonatomic, assign) BOOL bShouldSingleTapFire;
@end

@implementation BtnView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2)
    {
        //This will cancel the singleTap action
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1)
    {
        [self.delegate singleTapBegin:self];
        if(self.bShouldSingleTapFire)
            [self performSelector:@selector(onSingleTap) withObject:nil afterDelay:0.2];

    }
    else if (touch.tapCount == 2)
    {
        [self.delegate doubleTapFire:self];
    }
}

- (void)onSingleTap
{
    [self.delegate singleTapFire:self];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////


@interface LeveyTabBar () <BtnViewDelegate>
{
    int iCurrentIndex;
}
@end


@implementation LeveyTabBar
@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize buttons = _buttons;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray
{
    return  [self initWithFrame:frame buttonImages:imageArray titles:nil];
}

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray titles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		_backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_backgroundView];
		
		self.buttons = [NSMutableArray arrayWithCapacity:[imageArray count]];
		KDMessageButton *btn;
        BtnView *btnView;
		CGFloat width = 320.0f / [imageArray count];
		for (int i = 0; i < [imageArray count]; i++)
		{
			btn = [KDMessageButton buttonWithType:UIButtonTypeCustom];
			btn.showsTouchWhenHighlighted = YES;
			btn.tag = i;
			btn.frame = CGRectMake(width * i, 0, width, frame.size.height);
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Default"] forState:UIControlStateNormal];
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Highlighted"] forState:UIControlStateHighlighted];
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Seleted"] forState:UIControlStateSelected];
			[btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn setMsgImage:[UIImage imageNamed:@"new_oranage.png"]];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            if (titles[i]) {
                
                if([titles[i] length] == 1){
                    [btn setImageEdgeInsets:UIEdgeInsetsMake(-5, 10.f, 5, -10.f)];
                    btn.titleLabel.font = [UIFont systemFontOfSize:10.f];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(15, -5, -15, 15)];
                }
                
                if([titles[i] length] == 2){
                    [btn setImageEdgeInsets:UIEdgeInsetsMake(-5, 10.f, 5, -10.f)];
                    btn.titleLabel.font = [UIFont systemFontOfSize:10.f];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(15, -15, -15, 15)];
                }
                else if([titles[i]length] == 3){
                    [btn setImageEdgeInsets:UIEdgeInsetsMake(-5, 15.f, 5, -15.f)];
                    btn.titleLabel.font = [UIFont systemFontOfSize:10.f];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(15, -20, -15, 10)];
                }
            }
            [btn setTitleColor:RGBCOLOR(0.f, 109.f, 255.f) forState:UIControlStateHighlighted];
            [btn setTitleColor:RGBCOLOR(0.f, 109.f, 255.f) forState:UIControlStateSelected];
            [btn setTitleColor:MESSAGE_TOPIC_COLOR forState:UIControlStateNormal];
			[self.buttons addObject:btn];
			[self addSubview:btn];
            
            //给tabbar每个按钮实现双击和单击事件
            btnView = [[BtnView alloc] initWithFrame:btn.bounds];// autorelease];
            btnView.backgroundColor = [UIColor clearColor];
            btnView.delegate = self;
            //[self setupView:btnView];
            [btn addSubview:btnView];
		}
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)img
{
	[_backgroundView setImage:img];
}

- (void)tabBarButtonClicked:(id)sender
{
	UIButton *btn = sender;
	[self selectTabAtIndex:btn.tag];
    NSLog(@"Select index: %d",btn.tag);
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
    {
        [_delegate tabBar:self didSelectIndex:btn.tag];
    }
}

- (void)tabBarButtonDouble:(id)sender
{
	UIButton *btn = sender;
	[self selectTabAtIndex:btn.tag];
    NSLog(@"Select index: %d",btn.tag);
    if ([_delegate respondsToSelector:@selector(tabBar:didDoubleSelectIndex:)])
    {
        [_delegate tabBar:self didDoubleSelectIndex:btn.tag];
    }
}

- (void)tabBarButtonLongPress:(id)sender
{
	UIButton *btn = sender;
	[self selectTabAtIndex:btn.tag];
    NSLog(@"Select index: %d",btn.tag);
    if ([_delegate respondsToSelector:@selector(tabBar:didLongPressSelectIndex:)])
    {
        [_delegate tabBar:self didLongPressSelectIndex:btn.tag];
    }
}

- (void)selectTabAtIndex:(NSInteger)index
{
	for (int i = 0; i < [self.buttons count]; i++)
	{
		UIButton *b = [self.buttons objectAtIndex:i];
		b.selected = NO;
		b.userInteractionEnabled = YES;
	}
	UIButton *btn = [self.buttons objectAtIndex:index];
	btn.selected = YES;
}

- (void)removeTabAtIndex:(NSInteger)index
{
    // Remove button
    [(UIButton *)[self.buttons objectAtIndex:index] removeFromSuperview];
    [self.buttons removeObjectAtIndex:index];
   
    // Re-index the buttons
     CGFloat width = 320.0f / [self.buttons count];
    for (UIButton *btn in self.buttons) 
    {
        if (btn.tag > index)
        {
            btn.tag --;
        }
        btn.frame = CGRectMake(width * btn.tag, 0, width, self.frame.size.height);
    }
}
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    // Re-index the buttons
    CGFloat width = 320.0f / ([self.buttons count] + 1);
    for (UIButton *b in self.buttons) 
    {
        if (b.tag >= index)
        {
            b.tag ++;
        }
        b.frame = CGRectMake(width * b.tag, 0, width, self.frame.size.height);
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.showsTouchWhenHighlighted = YES;
    btn.tag = index;
    btn.frame = CGRectMake(width * index, 0, width, self.frame.size.height);
    [btn setImage:[dict objectForKey:@"Default"] forState:UIControlStateNormal];
    [btn setImage:[dict objectForKey:@"Highlighted"] forState:UIControlStateHighlighted];
    [btn setImage:[dict objectForKey:@"Seleted"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons insertObject:btn atIndex:index];
    [self addSubview:btn];
}

- (void)dealloc
{
    //[super dealloc];
}

- (void)showNewMessage:(BUTTON_TYPE) type show:(BOOL) isShow
{
    for (KDMessageButton *b in self.buttons)
    {
        if(b.tag ==(type-3)){
            [b showMsgImage:isShow];
            break;
        }
    }
}

- (void)setBadgeValue:(BUTTON_TYPE) type count:(NSInteger)count
{
    for (KDMessageButton *b in self.buttons)
    {
        if(b.tag ==(type-3)){
            [b setBadgeValue:count];
            break;
        }
    }
}

#pragma mark - event

- (void)setupView:(UIView *)view
{
    view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] ;//autorelease];
    [view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];// autorelease];
    doubleTap.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];// autorelease];
    [view addGestureRecognizer:longPress];
}


- (void)tap:(UITapGestureRecognizer *)gesture
{
    id btn = [gesture.view superview];
    if ([btn isKindOfClass:[KDMessageButton class]]) {
        [self tabBarButtonClicked:btn];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    id btn = [gesture.view superview];
    if ([btn isKindOfClass:[KDMessageButton class]]) {
        [self tabBarButtonDouble:btn];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    id btn = [gesture.view superview];
    if ([btn isKindOfClass:[KDMessageButton class]]) {
        [self tabBarButtonLongPress:btn];
    }
}

- (void)singleTapBegin:(BtnView *)view
{
    UIButton *btn = (UIButton *)view.superview;
    if (iCurrentIndex != btn.tag)
    {
        view.bShouldSingleTapFire = NO;
        [self tabBarButtonClicked:btn];
    }
    else
    {
        view.bShouldSingleTapFire = YES;
    }
    iCurrentIndex = btn.tag;
}

- (void)singleTapFire:(BtnView *)view
{
    UIButton *btn = (UIButton *)view.superview;
    [self tabBarButtonClicked:btn];
}

- (void)doubleTapFire:(BtnView *)view
{
    UIButton *btn = (UIButton *)view.superview;
    [self tabBarButtonDouble:btn];
}

@end
