//
//  LeveyTabBar.m
//  LeveyTabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import "KDProfileDetailTabBar.h"
#import "KDMessageButton.h"

@implementation KDProfileDetailTabBar
@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize buttons = _buttons;
@synthesize bgMaskView = _bgMaskView;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray
{
    return [self initWithFrame:frame buttonImages:imageArray titles:nil];
}

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray titles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor clearColor];
        
        CGRect bgMaskFrame = frame;
        frame.origin.y = 1.0f;
        _bgMaskView = [[UIView alloc] initWithFrame:bgMaskFrame];
        _bgMaskView.backgroundColor = RGBCOLOR(237, 237, 237);
        [self addSubview:_bgMaskView];
        
		_backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_backgroundView];
		
		self.buttons = [NSMutableArray arrayWithCapacity:[imageArray count]];
		KDMessageButton *btn;
		CGFloat width = ScreenFullWidth / [imageArray count];
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
                btn.titleLabel.font = [UIFont systemFontOfSize:10.f];
                [btn.titleLabel sizeToFit];
                CGSize size = btn.titleLabel.bounds.size;
//                CGFloat spacing = 5.0f;
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, -btn.imageView.bounds.size.width, -28, 0.0f)];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, -size.width)];
            }
            
            [btn setTitleColor:RGBCOLOR(0.f, 109.f, 255.f) forState:UIControlStateHighlighted];
            [btn setTitleColor:RGBCOLOR(0.f, 109.f, 255.f) forState:UIControlStateSelected];
            [btn setTitleColor:MESSAGE_TOPIC_COLOR forState:UIControlStateNormal];
			[self.buttons addObject:btn];
			[self addSubview:btn];
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
    NSLog(@"Select index: %ld",(long)btn.tag);
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
    {
        [_delegate tabBar:self didSelectIndex:btn.tag];
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
	btn.userInteractionEnabled = NO;
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
//    [_backgroundView release];
//    [_bgMaskView release];
//    [_buttons release];
    //[super dealloc];
}

@end
