//
//  KWITutorialCardV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/14/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWITutorialCardV.h"

#import "UIDevice+KWIExt.h"
#import "KWIRootVCtrl.h"

@implementation KWITutorialCardV
{
    IBOutlet UIImageView *_bgV;    
}


+ (KWITutorialCardV *)view
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWITutorialCardV *view = (KWITutorialCardV *)[nib objectAtIndex:0];  
    
    return [view setUp];
}

- (id)setUp
{
    [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTutorialVTapped:)] autorelease]];
    [self addGestureRecognizer:[[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_onTutorialVTapped:)] autorelease]];
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    //[dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
    [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
    
    if ([UIDevice isPortrait]) {
        self.frame = [KWIRootVCtrl curInst].view.bounds;
        _bgV.image = [UIImage imageNamed:@"tutorial_card_bg_p_v1.0.0.png"];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_bgV release];
    [super dealloc];
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    NSUInteger left = 0;
//    NSUInteger top = 0;
//    NSUInteger right = CGRectGetWidth(self.frame) - CGRectGetWidth(_bgV.frame);
//    NSUInteger bottom = CGRectGetHeight(self.frame);        
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextMoveToPoint(context, left, top);
//    CGContextAddLineToPoint(context, right, top);
//    CGContextAddLineToPoint(context, right, bottom);
//    CGContextAddLineToPoint(context, left, bottom);
//    CGContextAddLineToPoint(context, left, top);
//    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor);
//    CGContextFillPath(context);
//}

- (void)_onTutorialVTapped:(UIGestureRecognizer *)gr
{
    for (UIGestureRecognizer *el in self.gestureRecognizers) {
        [self removeGestureRecognizer:el];
    }
    
    [self removeFromSuperview];
}

- (void)_onOrientationWillChange:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"isPortrait"] boolValue]) {
        _bgV.image = [UIImage imageNamed:@"tutorial_card_bg_p_v1.0.0.png"];
    } else {
        _bgV.image = [UIImage imageNamed:@"tutorial_card_bg_l_v1.0.0.png"];
    }
}


@end
