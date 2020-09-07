 //
 //  UIView+Blur.m
 //  kdweibo_common
 //
 //  Created by 王 松 on 13-11-19.
 //  Copyright (c) 2013年 kingdee. All rights reserved.
 //
 
 #import "UIView+Blur.h"
 
 #import <QuartzCore/QuartzCore.h>
 #import <CoreImage/CoreImage.h>
 #import "UIImage+BoxBlur.h"

 #define kBorderWidth (float) 1.0f
 #define kBorderColor RGBCOLOR(203.f, 203.f, 203.f);
 
 #define kBaseTag (int)10100
 
 @implementation UIView (Blur)
 

- (void)renderLayerWithView:(UIView *)superview
{
    [self renderLayerWithView:superview withBorder:KDBorderPositionNone];
}

- (void)renderLayerWithView:(UIView *)superview withBorder:(KDBorderPosition)position
{
    __block UIImage *bg = nil;
    CALayer *layer = nil;
    
    if (superview) {
        CGRect visibleRect = [superview convertRect:self.frame toView:self];
        visibleRect.origin.y += self.frame.origin.y;
        visibleRect.origin.x += self.frame.origin.x;
        //Render the layer in the image context
        UIGraphicsBeginImageContextWithOptions(visibleRect.size, NO, 1.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextTranslateCTM(context, -visibleRect.origin.x, -visibleRect.origin.y);
            layer = superview.layer;
            [layer renderInContext:context];
            
            bg = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
    }
    
//    if (bg) {
//        [bg retain];
//    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (superview && bg) {
            NSData *imageData = UIImageJPEGRepresentation(bg, 0.01);
//            [bg release];
            CALayer *bgLayer = [CALayer layer];
            bgLayer.frame = layer.bounds;
            //6.0之后才有的滤镜效果
            if ([UIDevice currentDevice].systemVersion.intValue >= 6) {
                CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                              keysAndValues:kCIInputImageKey, [UIImage imageWithData:imageData], nil];
                bgLayer.filters = @[filter];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[self selfLayer] insertSublayer:bgLayer atIndex:0];
                [self selfLayer].opacity = 0.98;
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addBorderAtPosition:position];
        });
    });
}



- (void)addBorderAtPosition:(KDBorderPosition)position
{
    [self setBorderAtPostion:position];
}

- (void)addBorderAtPosition:(KDBorderPosition)position color:(UIColor *)color{
    [self setBorderAtPostion:position color:color];
}

- (void)setBorderAtPostion:(NSInteger)position
{
    switch (position) {
        case KDBorderPositionLeft:
        {
            [self setLeftBorder];
        }
            break;
        case KDBorderPositionRight:
        {
            [self setRightBorder];
        }
            break;
        case KDBorderPositionTop:
        {
            [self setTopBorder];
        }
            break;
        case KDBorderPositionBottom:
        {
            [self setBottomBorder];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionLeft):
        {
            [self setLeftBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionTop | KDBorderPositionLeft):
        {
            [self setLeftBorder];
            [self setTopBorder];
        }
            break;
        case (KDBorderPositionBottom | KDBorderPositionLeft):
        {
            [self setLeftBorder];
            [self setBottomBorder];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionTop):
        {
            [self setTopBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionBottom):
        {
            [self setBottomBorder];
            [self setRightBorder];
        }
            break;
            
        case (KDBorderPositionTop | KDBorderPositionBottom):
        {
            [self setTopBorder];
            [self setBottomBorder];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionBottom):
        {
            [self setTopBorder];
            [self setLeftBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionTop):
        {
            [self setBottomBorder];
            [self setLeftBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionLeft):
        {
            [self setTopBorder];
            [self setBottomBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionRight):
        {
            [self setTopBorder];
            [self setBottomBorder];
            [self setLeftBorder];
        }
            break;
        case KDBorderPositionAll:
        {
            [self setTopBorder];
            [self setBottomBorder];
            [self setLeftBorder];
            [self setRightBorder];
        }
            break;
            
        default:
            break;
    }
}

- (void)setBorderAtPostion:(NSInteger)position  color:(UIColor*)color
{
    switch (position) {
        case KDBorderPositionLeft:
        {
            [self setLeftBorderWithColor:color];
        }
            break;
        case KDBorderPositionRight:
        {
            [self setRightBorderWithColor:color];
        }
            break;
        case KDBorderPositionTop:
        {
            [self setTopBorderWithColor:color];
        }
            break;
        case KDBorderPositionBottom:
        {
            [self setBottomBorderWithColor:color];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionLeft):
        {
            [self setLeftBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
        case (KDBorderPositionTop | KDBorderPositionLeft):
        {
            [self setLeftBorderWithColor:color];
            [self setTopBorderWithColor:color];
        }
            break;
        case (KDBorderPositionBottom | KDBorderPositionLeft):
        {
            [self setLeftBorderWithColor:color];
            [self setBottomBorderWithColor:color];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionTop):
        {
            [self setTopBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionBottom):
        {
            [self setBottomBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
            
        case (KDBorderPositionTop | KDBorderPositionBottom):
        {
            [self setTopBorderWithColor:color];
            [self setBottomBorderWithColor:color];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionBottom):
        {
            [self setTopBorderWithColor:color];
            [self setLeftBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionTop):
        {
            [self setBottomBorderWithColor:color];
            [self setLeftBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionLeft):
        {
            [self setTopBorderWithColor:color];
            [self setBottomBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
        case (KDBorderPositionAll ^ KDBorderPositionRight):
        {
            [self setTopBorderWithColor:color];
            [self setBottomBorderWithColor:color];
            [self setLeftBorderWithColor:color];
        }
            break;
        case KDBorderPositionAll:
        {
            [self setTopBorderWithColor:color];
            [self setBottomBorderWithColor:color];
            [self setLeftBorderWithColor:color];
            [self setRightBorderWithColor:color];
        }
            break;
            
        default:
            break;
    }
}

- (void)setTopBorder
{
    UIImageView *border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horizental_line_v3.png"]];// autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    border.tag = KDBorderPositionTop + kBaseTag;
    border.backgroundColor = [UIColor clearColor];
    border.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [self _borderWidth]);
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (void)setTopBorderWithColor : (UIColor *)color{
    UIView *border = [[UIView alloc]init];//autorelease];
    border.backgroundColor = color;
    border.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    border.tag = KDBorderPositionTop + kBaseTag;
    border.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [self _borderWidth] * 0.5);
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (void)setBottomBorder
{
    UIImageView *border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horizental_line_v3.png"]];// autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    border.tag = KDBorderPositionBottom + kBaseTag;
    border.backgroundColor = [UIColor clearColor];
    border.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - [self _borderWidth] * 0.5, CGRectGetWidth(self.frame), [self _borderWidth]);
    NSLog(@"borderHeight:%f",CGRectGetHeight(self.frame));
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (void)setBottomBorderWithColor : (UIColor *)color{
    UIView *border = [[UIView alloc]init];//autorelease];
    border.backgroundColor = color;
    border.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    border.tag = KDBorderPositionBottom + kBaseTag;
    border.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - [self _borderWidth] * 0.5 , CGRectGetWidth(self.frame), [self _borderWidth] * 0.5);
    NSLog(@"borderHeight:%f",CGRectGetHeight(self.frame));
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (void)setLeftBorder
{
    UIImageView *border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical_line_v3.png"]];// autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    border.tag = KDBorderPositionLeft + kBaseTag;
    border.backgroundColor = [UIColor clearColor];
    border.frame = CGRectMake(0.0f, 0.0f, [self _borderWidth], CGRectGetHeight(self.frame));
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (void)setLeftBorderWithColor : (UIColor *)color{
    UIView *border = [[UIView alloc]init];//autorelease];
    border.backgroundColor = color;
    border.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    border.tag = KDBorderPositionLeft + kBaseTag;
    border.frame = CGRectMake(0.0f, 0.0f, [self _borderWidth] * 0.5, CGRectGetHeight(self.frame));
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}


- (void)setRightBorder
{
    UIImageView *border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical_line_v3@2x.png"]];// autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    border.tag = KDBorderPositionRight + kBaseTag;
    border.backgroundColor = [UIColor clearColor];
    border.frame = CGRectMake(CGRectGetWidth(self.frame) - [self _borderWidth] * 0.5, 0.0f, [self _borderWidth], CGRectGetHeight(self.frame));
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (void)setRightBorderWithColor : (UIColor *)color{
    UIView *border = [[UIView alloc]init];//autorelease];
    border.backgroundColor = color;
    border.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    border.tag = KDBorderPositionRight + kBaseTag;
    border.frame = CGRectMake(CGRectGetWidth(self.frame) - [self _borderWidth] * 0.5, 0.0f, [self _borderWidth] * 0.5, CGRectGetHeight(self.frame));
    [[self selfView] addSubview:border];
    [[self selfView] bringSubviewToFront:border];
}

- (UIView *)borderView
{
    UIView *border = [[UIView alloc] initWithFrame:CGRectZero];// autorelease];
    border.backgroundColor = [self _borderColor];
    return border;
}

- (CALayer *)selfLayer
{
    if ([self isKindOfClass:[UITableViewCell class]]) {
        return ((UITableViewCell *)self).contentView.layer;
    }
    return self.layer;
}

- (UIView *)selfView
{
    if ([self isKindOfClass:[UITableViewCell class]]) {
        return ((UITableViewCell *)self).contentView;
    }
    return self;
}

- (CGFloat)_borderWidth
{
    return kBorderWidth;
}

- (UIColor *)_borderColor
{
    return kBorderColor;
}

- (void)removeAllBorderInView{
    NSInteger indexTag = 0x01;
    for(int i = 0;i < 4;i++){
        indexTag = indexTag << 1;
        UIView *view = [self viewWithTag:indexTag + kBaseTag];
        if(view)
            [view removeFromSuperview];
    }
}

@end
/**
// CALayer 版本
 
 //
 //  UIView+Blur.m
 //  kdweibo_common
 //
 //  Created by 王 松 on 13-11-19.
 //  Copyright (c) 2013年 kingdee. All rights reserved.
 //
 
 #import "UIView+Blur.h"
 
 #import <QuartzCore/QuartzCore.h>
 #import <CoreImage/CoreImage.h>
 #import "UIImage+BoxBlur.h"
 
 static NSString *kContext;
 #define kBorderWidth (float)1.f
 #define kBorderColor RGBCOLOR(203.f, 203.f, 203.f)
 
 @implementation UIView (Blur)
 
 
 *  设置模糊效果
 
- (void)renderLayerWithView:(UIView *)superview
{
    [self renderLayerWithView:superview withBorder:KDBorderPositionNone];
}

- (void)renderLayerWithView:(UIView *)superview withBorder:(KDBorderPosition)position
{
    __block UIImage *bg = nil;
    CALayer *layer = nil;
    
    if (superview) {
        CGRect visibleRect = [superview convertRect:self.frame toView:self];
        visibleRect.origin.y += self.frame.origin.y;
        visibleRect.origin.x += self.frame.origin.x;
        //Render the layer in the image context
        UIGraphicsBeginImageContextWithOptions(visibleRect.size, NO, 1.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextTranslateCTM(context, -visibleRect.origin.x, -visibleRect.origin.y);
            layer = superview.layer;
            [layer renderInContext:context];
            
            bg = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (superview && bg) {
            NSData *imageData = UIImageJPEGRepresentation(bg, 0.01);
            
            CALayer *bgLayer = [CALayer layer];
            bgLayer.frame = layer.bounds;
            //6.0之后才有的滤镜效果
            if ([UIDevice currentDevice].systemVersion.intValue >= 6) {
                CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                              keysAndValues:kCIInputImageKey, [UIImage imageWithData:imageData], nil];
                bgLayer.filters = @[filter];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[self selfLayer] insertSublayer:bgLayer atIndex:0];
                [self selfLayer].opacity = 0.98;
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addBorderAtPosition:position];
        });
    });
}

- (void)addBorderAtPosition:(KDBorderPosition)position
{
    [self setBorderAtPostion:position];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &kContext) {
        CGRect  newVal = [[change objectForKey:@"new"] CGRectValue];
        CGRect oldVal = [[change objectForKey:@"old"] CGRectValue];
        if (!CGRectEqualToRect(newVal, oldVal)) {
            [self resetBorders];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)setBorderAtPostion:(NSInteger)position
{
    switch (position) {
        case KDBorderPositionLeft:
        {
            [self setLeftBorder];
        }
            break;
        case KDBorderPositionRight:
        {
            [self setRightBorder];
        }
            break;
        case KDBorderPositionTop:
        {
            [self setTopBorder];
        }
            break;
        case KDBorderPositionBottom:
        {
            [self setBottomBorder];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionLeft):
        {
            [self setLeftBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionTop | KDBorderPositionLeft):
        {
            [self setLeftBorder];
            [self setTopBorder];
        }
            break;
        case (KDBorderPositionBottom | KDBorderPositionLeft):
        {
            [self setLeftBorder];
            [self setBottomBorder];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionTop):
        {
            [self setTopBorder];
            [self setRightBorder];
        }
            break;
        case (KDBorderPositionRight | KDBorderPositionBottom):
        {
            [self setBottomBorder];
            [self setRightBorder];
        }
            break;
            
        case (KDBorderPositionTop | KDBorderPositionBottom):
        {
            [self setTopBorder];
            [self setBottomBorder];
        }
            break;
        case KDBorderPositionAll:
        {
            [self setTopBorder];
            [self setBottomBorder];
            [self setLeftBorder];
            [self setRightBorder];
        }
            break;
            
        default:
            break;
    }
}

- (void)setTopBorder
{
    CALayer *border = [self borderLayer];
    border.name = @"Top";
    border.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [self _borderWidth]);
    [[self selfLayer] insertSublayer:border atIndex:0];
}

- (void)setBottomBorder
{
    CALayer *border = [self borderLayer];
    border.name = @"Bottom";
    border.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - [self _borderWidth], CGRectGetWidth(self.frame), [self _borderWidth]);
    [[self selfLayer] insertSublayer:border atIndex:0];
}

- (void)setLeftBorder
{
    CALayer *border = [self borderLayer];
    border.name = @"Left";
    border.frame = CGRectMake(0.0f, 0.0f, [self _borderWidth], CGRectGetHeight(self.frame));
    [[self selfLayer] insertSublayer:border atIndex:0];
}

- (void)setRightBorder
{
    CALayer *border = [self borderLayer];
    border.name = @"Right";
    border.frame = CGRectMake(CGRectGetWidth(self.frame) - [self _borderWidth], 0.0f, [self _borderWidth], CGRectGetHeight(self.frame));
    [[self selfLayer] insertSublayer:border atIndex:0];
}

- (CALayer *)borderLayer
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = [self _borderColor].CGColor;
    [border setActions:@{@"bounds": [NSNull null], @"position" : [NSNull null]}];
    return border;
}

- (void)resetBorders
{
    NSArray *subs = [self selfLayer].sublayers;
    for (CALayer *border in subs) {
        if ([border.name isEqual:@"Top"]) {
            border.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(border.frame));
        } else if ([border.name isEqual:@"Bottom"]) {
            border.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - CGRectGetHeight(border.frame), CGRectGetWidth(self.frame), CGRectGetHeight(border.frame));
        } else if ([border.name isEqual:@"Left"]) {
            border.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(border.frame), CGRectGetHeight(self.frame));
        } else if ([border.name isEqual:@"Right"]) {
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - CGRectGetWidth(border.frame), 0.0f, CGRectGetWidth(border.frame), CGRectGetHeight(self.frame));
        }
    }
}

- (CALayer *)selfLayer
{
    if ([self isKindOfClass:[UITableViewCell class]]) {
        return ((UITableViewCell *)self).contentView.layer;
    }
    return self.layer;
}

- (CGFloat)_borderWidth
{
    return [self respondsToSelector:@selector(borderWidth)] ? [self borderWidth] : kBorderWidth;
}

- (UIColor *)_borderColor
{
    return [self respondsToSelector:@selector(borderColor)] ? [self borderColor] : kBorderColor;
}

@end

 */

