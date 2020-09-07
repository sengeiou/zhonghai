//
//  KDStatusActionToolbar.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusActionToolbar.h"

#import "KDUICGAdditions.h"

@interface KDStatusActionToolbar ()

@property (nonatomic, retain) CAGradientLayer *shadowLayer;
@property (nonatomic, retain) CALayer *backgroundLayer;

@end

@implementation KDStatusActionToolbar

@synthesize shadowLayer=shadowLayer_;
@synthesize backgroundLayer=backgroundLayer_;

@dynamic barItems;

- (void) setupActionToolbar {
    /*
    // background layer
    backgroundLayer_ = [[CALayer layer] retain];
    backgroundLayer_.contentsScale = [UIScreen mainScreen].scale;
    
    UIImage *image = [UIImage imageNamed:@"status_toolbar_bg.png"];
    backgroundLayer_.contents = (id)image.CGImage;
    
    [self.layer insertSublayer:backgroundLayer_ atIndex:0x00];
     
    // shdow layer
    shadowLayer_ = [[CAGradientLayer layer] retain];
     
    UIColor *darkColor = RGBCOLOR(190.0, 190.0, 190.0);
    UIColor *lightColor = [darkColor colorWithAlphaComponent:0.2];
     
    shadowLayer_.colors = [NSArray arrayWithObjects:(id)lightColor.CGColor, (id)darkColor.CGColor, nil];
    [self.layer insertSublayer:shadowLayer_ atIndex:0x00];
     
    */
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupActionToolbar];
    }
    
    return self;
}

// Now, we just use button to replace an toolbar item
// TODO xxx please create new toolbar item replace this implementation
- (UIButton *) toolbarItemWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0.0, 0.0, 60.0, 40.0);
    
    if(imageName != nil){
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    if(highlightedImageName != nil){
        [btn setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    }
    
    return btn;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    /*
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    shadowLayer_.frame = CGRectMake(0.0, -3.0, self.bounds.size.width, 3.0);
    
    [CATransaction commit];
    */
    
    if(barItems_ != nil && [barItems_ count] > 0){
        CGFloat pw = self.bounds.size.width / [barItems_ count];
        
        NSInteger idx = 0;
        CGRect rect = CGRectZero;
        for(UIButton *item in barItems_){
            rect = item.bounds;
            
            rect.origin.x = pw * idx + (pw - rect.size.width) * 0.5;
            rect.origin.y = (self.bounds.size.height - rect.size.height) * 0.5;
            
            item.frame = rect;
            
            idx++;
        }
    }
}

- (void) drawRect:(CGRect)rect {
    // draw gradient
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGPoint sp = CGPointMake(0.5 * rect.size.width, rect.origin.y);
    CGPoint ep = CGPointMake(sp.x, sp.y + rect.size.height);
    CGFloat startColorValues[4] = {194.0/255.0, 207.0/255.0, 220.0/255.0, 1.0};
    CGFloat endColorValues[4] = {154.0/255.0, 171.0/255.0, 189.0/255.0, 1.0};
    
    CGContextDrawLinearGradientBetweenPoints(context, sp, startColorValues, ep, endColorValues);
    
    CGContextRestoreGState(context);
}

- (void) setBarItems:(NSArray *)barItems {
    if(barItems_ != barItems){
        if(barItems_ != nil){
            [barItems_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
//        [barItems_ release];
        barItems_ = barItems ;//retain];
        
        if(barItems_ != nil){
            for(UIView *item in barItems_){
                [self addSubview:item];
            }
        }
        
        [self setNeedsLayout];
    }
}

- (NSArray *) barItems {
    return barItems_;
}

- (BOOL) isValidIndex:(NSUInteger)index {
    return barItems_ != nil && index < [barItems_ count];
}

- (void) toolbarItemEnabled:(BOOL)enabled atIndex:(NSUInteger)index {
    if([self isValidIndex:index]){
        UIButton *btn = [barItems_ objectAtIndex:index]; 
        btn.enabled = enabled;
    }
}

- (void) toolbarItemHidden:(BOOL)hidden atIndex:(NSUInteger)index {
    if([self isValidIndex:index]){
        UIButton *btn = [barItems_ objectAtIndex:index]; 
        btn.hidden = hidden;
    }
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(backgroundLayer_);
    //KD_RELEASE_SAFELY(shadowLayer_);
    
    //KD_RELEASE_SAFELY(barItems_);
    
    //[super dealloc];
}

@end
